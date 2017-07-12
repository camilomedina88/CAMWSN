#Black hole attack for a smart grid network
#      https://groups.google.com/forum/?fromgroups#!topic/ns-users/K2pQg96g6pE
#===================================
#         Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel        ;# channel type
set val(prop)   Propagation/TwoRayGround   ;    # radio-propagation model
set val(netif)  Phy/WirelessPhy                ;# network interface type
set val(mac)        Mac/802_11                     ;# MAC type
set val(ifq)        Queue/DropTail/PriQueue        ;# interface queue type
set val(ll)         LL                             ;# link layer type
set val(ant)        Antenna/OmniAntenna            ;# antenna model
set val(ifqlen)     50                             ;# max packet in ifq
set val(nn)         6                             ;# number of mobilenodes
set val(nnaodv)     5                             ;
set val(rp)         AODV                          ;# routing protocol
set val(x)          500                          ;# X dimension of topography
set val(y)          500                          ;# Y dimension of topography
set val(stop)       100                          ;# time of simulation end
set val(t1)         0.0                             ;
set val(t2)         0.0                              ;  


#Create a ns simulator
set ns_ [new Simulator]

#Setup topography object
set topo           [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open out.tr w]
$ns_ trace-all $tracefile

#Open the NAM trace file
set namfile [open out.nam w]

$ns_ namtrace-all $namfile
$ns_ namtrace-all-wireless $namfile $val(x) $val(y)

set chan [new $val(chan)];#Create wireless channel

#$ns_ color 1 Blue
#$ns_ color 2 Red

#===================================
#         Mobile node parameter setup
#===================================
$ns_ node-config    -adhocRouting      $val(rp) \
                    -llType            $val(ll) \
                    -macType           $val(mac) \
                    -ifqType           $val(ifq) \
                    -ifqLen            $val(ifqlen) \
                    -antType           $val(ant) \
                    -propType          $val(prop) \
                    -phyType           $val(netif) \
                    -channel           $chan \
                    -topoInstance  $topo \
                    -agentTrace        ON \
                    -routerTrace   ON \
                    -macTrace          ON \
                    -movementTrace ON

 # creating nodes for the simulation     

for {set i 0} {$i < $val(nnaodv)} {incr i} {
set node_($i) [$ns_ node] 
$ns_ initial_node_pos $node_($i) 10
$node_($i) random-motion 0;
}

#here we work with blackholeaodv for node 5 (malicious node)
$ns_ node-config        -adhocRouting blackholeAODV 

for {set i $val(nnaodv)} {$i < $val(nn)} {incr i} {
set node_($i) [$ns_ node]
$ns_ initial_node_pos $node_($i) 10
$node_($i) random-motion 0 ; # disable random motion
$ns_ at 0.01 "$node_($i) label \"blackhole node\""
} 

$node_(0) set X_ 10
$node_(0) set Y_ 10
$node_(0) set Z_ 0.0

$node_(1) set X_ 270
$node_(1) set Y_ 280
$node_(1) set Z_ 0.0

$node_(2) set X_ 20
$node_(2) set Y_ 50
$node_(2) set Z_ 0.0

$node_(3) set X_ 40
$node_(3) set Y_ 70
$node_(3) set Z_ 0.0

$node_(4) set X_ 100
$node_(4) set Y_ 120
$node_(4) set Z_ 0.0

$node_(5) set X_ 70
$node_(5) set Y_ 80
$node_(5) set Z_ 0.0

set null0 [new Agent/Null]
$ns_ attach-agent $node_(1) $null0
set  udp(0) [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp(0)
#$udp(0) set packetSize_ 1500
set cbr(0) [new Application/Traffic/CBR]
$cbr(0) set packetSize_ 500
$cbr(0) set interval_ 0.005
#$cbr(0) set random_ null
$cbr(0) attach-agent $udp(0)
$ns_ connect $udp(0) $null0
$ns_ at 20 "$cbr(0) start"

set null1 [new Agent/Null]
$ns_ attach-agent $node_(3) $null1
set  udp(1) [new Agent/UDP]
$ns_ attach-agent $node_(2) $udp(1)
#$udp(0) set packetSize_ 1500
set cbr(1) [new Application/Traffic/CBR]
$cbr(1) set packetSize_ 500
$cbr(1) set interval_ 0.005
#$cbr(0) set random_ null
$cbr(1) attach-agent $udp(1)
$ns_ connect $udp(1) $null1
$ns_ at 21 "$cbr(1) start"

set null2 [new Agent/Null]
$ns_ attach-agent $node_(5) $null2
set  udp(2) [new Agent/UDP]
$ns_ attach-agent $node_(4) $udp(2)
#$udp(0) set packetSize_ 1500
set cbr(2) [new Application/Traffic/CBR]
$cbr(2) set packetSize_ 500
$cbr(2) set interval_ 0.005
#$cbr(0) set random_ null
$cbr(2) attach-agent $udp(2)
$ns_ connect $udp(2) $null2
$ns_ at 22 "$cbr(2) start"

#tell all nodes when simulation ends
for {set i 0} {$i<$val(nn)} {incr i} {
$ns_ at $val(stop).000000001 "$node_($i) reset";
}

$ns_ at 100 "$cbr(0) stop";
$ns_ at 100 "$cbr(1) stop";
$ns_ at 100 "$cbr(2) stop";

$ns_ at $val(stop) "finish"
$ns_ at $val(stop).0 "ns trace-annotate \"simulation has ended\""
$ns_ at $val(stop).00000001 "puts \"NS EXITING...\"; $ns_ halt"

proc finish {} {
        global ns_ tracefile namfile 
        $ns_ flush-trace
        close $tracefile
        close $namfile
    
       
        exec nam out.nam &


exit 0
}
puts "Starting Simulation..."
$ns_ run
