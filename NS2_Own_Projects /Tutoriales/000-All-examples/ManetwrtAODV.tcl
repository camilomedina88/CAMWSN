#Parameters like number of nodes and routing protocol should be changed.
#scenario file val(cp) and val(sc) should be changed according to the number of nodes.
#=======================================================
# Define options
#=======================================================
set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
#set val(x) 500 ;# X dimension of the topography
#set val(y) 500 ;# Y dimension of the topography
set val(ifqlen) 50 ; # max packet in ifq
set val(seed) 0.0
set val(adhocRouting) OLSR
#set val(adhocRouting) DSDV
#set val(adhocRouting) AODV
set val(nn) 21
set val(cp) "cbr-20.sc" ;# connection pattern
set val(sc) "mobile-20.sc" ;# mobility
set val(stop) 200.0 ;# simulation time
#=======================================================
# Main Program
#=======================================================
set ns_ [new Simulator]
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
set god_ [create-god $val(nn)]
#create-god $val(nn)
# create trace object for ns and nam
puts "Routing Protocol is $val(adhocRouting)"
set tracefd [open $val(adhocRouting).tr w]
set namtrace [open $val(adhocRouting).nam w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
# node configuration
$ns_ node-config -adhocRouting $val(adhocRouting) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF\
-movementTrace ON
# common initialization should be done before creating the nodes.
if { $val(adhocRouting) == 'OLSR' } {
#Agent/OLSR set debug_ true
#Agent/OLSR set hello_ival_ 2
#Agent/OLSR set enc_rate_ 50 in MBps, 0.0 means no ecnryption.
#Agent/OLSR set delay_enc_session_key_ 0.0
# 0.0 means no encryption.
}
# Create the specified number of nodes [$val(nn)]
for {set i 0} {$i < $val(nn) } {incr i} {
set node_($i) [$ns_ node]
# $node_($i) random-motion 0 ;# disable random motion
}
puts "Loading connection pattern..."
source $val(cp)
puts "Loading scenario file..."
source $val(sc)
# Define node initial position in nam
for {set i 0} {$i < $val(nn)} {incr i} {
$ns_ initial_node_pos $node_($i) 30
}
# Specific settings for OLSR
#if { $val(adhocRouting) == "OLSR" } {
#$ns_ at 1.0 "print_all_for_all_nodes";
#$ns_ at 105.0 "print_all_for_all_nodes"
#$ns_ at 160.0 "print_all_for_all_nodes"
#$ns_ at 135.0 "print $node_(8)"
#$ns_ at 135.0 "print $node_(4)"
#$ns_ at 135.0 "print $node_(7)"
#}
# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at $val(stop).0 "$node_($i) reset";
}
$ns_ at $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"

puts $tracefd "M 0.0 nn $val(nn) x $val(x) y $val(y) rp
$val(adhocRouting)"
puts $tracefd "M 0.0 prop $val(prop) ant $val(ant)"
puts "Starting Simulation..."
$ns_ run
#=======================================================
# utility procedures
#=======================================================
# print all possible OLSR repository for this node.
proc print { node } {
[$node agent 255] print_rtable
[$node agent 255] print_linkset
[$node agent 255] print_nbset
[$node agent 255] print_nb2hopset
[$node agent 255] print_mprset
[$node agent 255] print_mprselset
}

# print routing table for all nodes in this simulation
proc print_all_rtable { } {
global node_ val
for {set i 0} {$i < $val(nn)} {incr i} {
[$node_($i) agent 255] print_rtable
}
}
# print all nodes tables
proc print_all_for_all_nodes { } {
global node_ val
for {set i 0} {$i < $val(nn)} {incr i} {
print $node_($i)
}
}
