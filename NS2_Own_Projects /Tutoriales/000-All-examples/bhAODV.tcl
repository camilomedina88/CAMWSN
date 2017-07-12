# Define options
set val(chan) Channel/WirelessChannel ;#Channel Type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 150 ;# max packet in ifq
set val(nn) 20 ;# total number of mobilenodes
set val(nnaodv) 19 ;# number of AODV mobilenodes
set val(rp) AODV ;# routing protocol
set val(x) 750 ;# X dimension of topography
set val(y) 750 ;# Y dimension of topography
set val(cstop) 451 ;# time of connections end
set val(stop) 500 ;# time of simulation end
#set val(cp) "/home/tclfiles/scenarios/scen1forAODV-n20-t500-x750-y750" ;#Connection Pattern
set val(cp) "./scenAODV"
set val(cc) "./cbr" ;#CBR Connections
# Initialize Global Variables
set ns_ [new Simulator]
$ns_ use-newtrace
set tracefd [open sim1forBlackHole.tr w]
$ns_ trace-all $tracefd
set namtrace [open sim1forBlackHole.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
# set up topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
# Create God
create-god $val(nn)
# Create channel #1 and #2
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]
# configure node, please note the change below.
$ns_ node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace ON \
-movementTrace ON \
-channel $chan_1_
# Creating mobile AODV nodes for simulation
puts "Creating nodes..."
for {set i 0} {$i < 20} {incr i} {
set node_($i) [$ns_ node]
$node_($i) random-motion 0 ;#disable random motion
}
# Creating Black Hole nodes for simulation
$ns_ node-config -adhocRouting blackholeAODV
for {set i 20} {$i < 21} {incr i} {
set node_($i) [$ns_ node]
$node_($i) random-motion 0 ;#disable random motion
$ns_ at 0.01 "$node_($i) label \"blackhole node\""
}
# Adding connection pattern which is created using setdest, parameters shown below
# ./setdest -n 20 -p 1.0 -M 20.0 -t 500 -x 750 -y 750 > scen1forAODV-n20-t500-x750-y750
puts "Loading random connection pattern..."
set god_ [God instance]
#source $val(cp) 
source $val(cc)
# Define initial node position
for {set i 0} {$i < 21 } {incr i} {
$ns_ initial_node_pos $node_($i) 30
}
# CBR connections stops
for {set i 0} {$i < 9 } {incr i} {
$ns_ at $val(cstop) "$cbr_($i) stop"
}
# Tell all nodes when the simulation ends
for {set i 0} {$i < 21 } {incr i} {
$ns_ at $val(stop).000000001 "$node_($i) reset";
}
# Ending nam and simulation
$ns_ at $val(stop) "finish"
$ns_ at $val(stop).0 "$ns_ trace-annotate \"Simulation has ended\""
$ns_ at $val(stop).00000001 "puts \"NS EXITING...\" ; $ns_ halt"
proc finish {} {
global ns_ tracefd namtrace
$ns_ flush-trace
close $tracefd
close $namtrace
exec nam sim1forBlackHole.nam &
exit 0
}
puts "Starting Simulation..."
$ns_ run
