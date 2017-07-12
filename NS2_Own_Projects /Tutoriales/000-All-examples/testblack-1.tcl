# Black hole attack for a smart grid network
#    
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
set val(nn)         9                             ;# number of mobilenodes
set val(nnao)       7 
set val(rp)         AODV                          ;# routing protocol
set val(x)          500                          ;# X dimension of topography
set val(y)          500                          ;# Y dimension of topography
set val(stop)       190                             ;# time of simulation end
set val(t1)         0.0                             ;
set val(t2)         0.0                              ;  
set val(cc)        "cbr-9-test9" 			;#CBR Connections


#Create a ns simulator
set ns_ [new Simulator]
set tracefile [open outblack.tr w]
set namfile [open outblack.nam w]
$ns_ trace-all $tracefile
$ns_ namtrace-all-wireless $namfile $val(x) $val(y)
#Setup topography object
set topo           [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file




#Open the NAM trace file

#$ns_ namtrace-all $namfile


#set chan [new $val(chan)];#Create wireless channel

#$ns_ color 1 Blue
#$ns_ color 2 Red
 #-channel           $chan \
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
                    -channelType       $val(chan) \
                    -topoInstance  $topo \
                    -agentTrace        ON \
                    -routerTrace   ON \
                    -macTrace          ON \
                    -movementTrace ON

 # creating nodes for the simulation     


for {set i 0} {$i < $val(nnao)} {incr i} {
set node_($i) [$ns_ node] 
#$ns_ initial_node_pos $node_($i) 10
$node_($i) random-motion 0;
#}

# this is a black hole node
$ns_ node-config -adhocRouting blackholeAODV 
set node_(7) [$ns_ node] 
#$ns_ initial_node_pos $node_(8) 10
$node_(7) random-motion 0;

$ns_ node-config -adhocRouting AODV 
set node_(8) [$ns_ node] 
#$ns_ initial_node_pos $node_(9) 10
$node_(8) random-motion 0;


$node_(0) set X_ 20.0
$node_(0) set Y_ 50.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 22.0
$node_(1) set Y_ 52.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 21.0
$node_(2) set Y_ 53.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 22.0
$node_(3) set Y_ 53.3
$node_(3) set Z_ 0.0

$node_(4) set X_ 19.5
$node_(4) set Y_ 53.5
$node_(4) set Z_ 0.0

$node_(5) set X_ 23.0
$node_(5) set Y_ 55.0
$node_(5) set Z_ 0.0

$node_(6) set X_ 272.5
$node_(6) set Y_ 304.0
$node_(6) set Z_ 0.0

$node_(7) set X_ 273
$node_(7) set Y_ 304.5
$node_(7) set Z_ 0.0

$node_(8) set X_ 300.0
$node_(8) set Y_ 400.0
$node_(8) set Z_ 0.0

#$node_(9) set X_ 100
#$node_(9) set Y_ 250
#$node_(9) set Z_ 0.0


#$node_(9) set X_ 100
#$node_(9) set Y_ 250
#$node_(9) set Z_ 0.0

#cbr traffic using cbrgen
source $val(cc)

#stop CBR trrafic
for {set k 0} {$k<7} {incr k} {
$ns_ at 190 "$cbr_($k) stop";
}

$ns_ at 0.01 "$node_(7) label \"blackhole node\""
for {set i 0} {$i < 9 } {incr i} {
$ns_ initial_node_pos $node_($i) 10
}

#tell all nodes when simulation ends
for {set i 0} {$i<9} {incr i} {
$ns_ at $val(stop).000000001 "$node_($i) reset";
}


#ending nam and simulation
$ns_ at $val(stop) "finish"
$ns_ at $val(stop).0 "ns trace-annotate \"simulation has ended\""
$ns_ at $val(stop).00000001 "puts \"NS EXITING...\"; $ns_ halt"

#Define a 'finish' procedure
proc finish {} {
        global ns_ tracefile namfile 
        $ns_ flush-trace
        close $tracefile
        close $namfile
        exec nam outblack.nam &

exit 0

}

puts "Starting Simulation..."
$ns_ run

