#======================================================================
# Define options
# ======================================================================
set val(ifqlen)         50                           ;# max packet in ifq
set val(nn)             3                           ;# number of mobilenodes
set val(rp)             MFlood                       ;# routing protocol
set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(stop)     200
 
# ======================================================================
# Main Program
# ======================================================================
 
#ns-random 0
 
# Initialize Global Variables
set ns_ [new Simulator]
set tracefd [open mflood.tr w]
$ns_ trace-all $tracefd
 
set namtrace    [open mflood.nam w]
$ns_ namtrace-all-wireless $namtrace 1000 500
 
# set up topography
set topo [new Topography]
$topo load_flatgrid 1000 500
 
# Create God
create-god $val(nn)
 
# Create the specified number of mobilenodes [$val(nn)] and "attach" them
# to the channel.
# configure node
set channel [new Channel/WirelessChannel]
$channel set errorProbability_ 0.0
 
  $ns_ node-config -adhocRouting $val(rp) \
    -llType $val(ll) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -ifqLen $val(ifqlen) \
    -antType $val(ant) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -channel $channel \
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace ON\
    -macTrace OFF \
    -movementTrace OFF  
   
 for {set i 0} {$i < $val(nn) } {incr i} {
  set node_($i) [$ns_ node]
  $node_($i) random-motion 0
 }
 
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
$node_(0) set X_ 100.0
$node_(0) set Y_ 200.0
$node_(0) set Z_ 0.0
 
$node_(1) set X_ 250.0
$node_(1) set Y_ 200.0
$node_(1) set Z_ 0.0
 
$node_(2) set X_ 400.0
$node_(2) set Y_ 200.0
$node_(2) set Z_ 0.0
 
# Define node initial position in nam
for {set i 0} {$i < $val(nn)} {incr i} {
 
    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
 
    $ns_ initial_node_pos $node_($i) 20
}
 
set udp_(0) [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp_(0)
 
set null_(0) [new Agent/Null]
$ns_ attach-agent $node_(2) $null_(0)
 
$ns_ connect $udp_(0) $null_(0)
 
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 512
$cbr_(0) set interval_ 0.5
$cbr_(0) set random_ 1
$cbr_(0) set maxpkts_ 10000
$cbr_(0) attach-agent $udp_(0)
$ns_ at 10.0 "$cbr_(0) start"
 
# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}
$ns_ at $val(stop).0 "stop"
$ns_ at $val(stop).01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}
 
puts "Starting Simulation..."
$ns_ run
