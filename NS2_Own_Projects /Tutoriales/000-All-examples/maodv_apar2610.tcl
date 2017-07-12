#    #14   http://www.linuxquestions.org/questions/linux-newbie-8/need-a-patch-for-maodv-plz-4175522238/#14


#===================================
# Simulation parameters setup
#===================================
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 25 ;# number of mobilenodes
set val(rp) AODV ;# routing protocol
set val(x) 1125 ;# X dimension of topography
set val(y) 571 ;# Y dimension of topography
set val(stop) 10.0 ;# time of simulation end

#===================================
# Initialization
#===================================
#Create a ns simulator
set ns [new Simulator]

#Setup topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open simulation.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open simulation.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

#===================================
# Mobile node parameter setup
#===================================
$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channel $chan \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace ON \
-movementTrace OFF

#===================================
# Nodes Definition
#===================================
#Create 25 nodes
set n0 [$ns node]
$n0 set X_ 225
$n0 set Y_ 471
$n0 set Z_ 0.0
$ns initial_node_pos $n0 50
set n1 [$ns node]
$n1 set X_ 425
$n1 set Y_ 471
$n1 set Z_ 0.0
$ns initial_node_pos $n1 50
set n2 [$ns node]
$n2 set X_ 625
$n2 set Y_ 471
$n2 set Z_ 0.0
$ns initial_node_pos $n2 50
set n3 [$ns node]
$n3 set X_ 825
$n3 set Y_ 471
$n3 set Z_ 0.0
$ns initial_node_pos $n3 50
set n4 [$ns node]
$n4 set X_ 1025
$n4 set Y_ 471
$n4 set Z_ 0.0
$ns initial_node_pos $n4 50
set n5 [$ns node]
$n5 set X_ 225
$n5 set Y_ 271
$n5 set Z_ 0.0
$ns initial_node_pos $n5 50
set n6 [$ns node]
$n6 set X_ 425
$n6 set Y_ 271
$n6 set Z_ 0.0
$ns initial_node_pos $n6 50
set n7 [$ns node]
$n7 set X_ 625
$n7 set Y_ 271
$n7 set Z_ 0.0
$ns initial_node_pos $n7 50
set n8 [$ns node]
$n8 set X_ 825
$n8 set Y_ 271
$n8 set Z_ 0.0
$ns initial_node_pos $n8 50
set n9 [$ns node]
$n9 set X_ 1025
$n9 set Y_ 271
$n9 set Z_ 0.0
$ns initial_node_pos $n9 50
set n10 [$ns node]
$n10 set X_ 225
$n10 set Y_ 71
$n10 set Z_ 0.0
$ns initial_node_pos $n10 50
set n11 [$ns node]
$n11 set X_ 425
$n11 set Y_ 71
$n11 set Z_ 0.0
$ns initial_node_pos $n11 50
set n12 [$ns node]
$n12 set X_ 625
$n12 set Y_ 71
$n12 set Z_ 0.0
$ns initial_node_pos $n12 50
set n13 [$ns node]
$n13 set X_ 825
$n13 set Y_ 71
$n13 set Z_ 0.0
$ns initial_node_pos $n13 50
set n14 [$ns node]
$n14 set X_ 1025
$n14 set Y_ 71
$n14 set Z_ 0.0
$ns initial_node_pos $n14 50
set n15 [$ns node]
$n15 set X_ 225
$n15 set Y_ -129
$n15 set Z_ 0.0
$ns initial_node_pos $n15 50
set n16 [$ns node]
$n16 set X_ 425
$n16 set Y_ -129
$n16 set Z_ 0.0
$ns initial_node_pos $n16 50
set n17 [$ns node]
$n17 set X_ 625
$n17 set Y_ -129
$n17 set Z_ 0.0
$ns initial_node_pos $n17 50
set n18 [$ns node]
$n18 set X_ 825
$n18 set Y_ -129
$n18 set Z_ 0.0
$ns initial_node_pos $n18 50
set n19 [$ns node]
$n19 set X_ 1025
$n19 set Y_ -129
$n19 set Z_ 0.0
$ns initial_node_pos $n19 50
set n20 [$ns node]
$n20 set X_ 225
$n20 set Y_ -329
$n20 set Z_ 0.0
$ns initial_node_pos $n20 50
set n21 [$ns node]
$n21 set X_ 425
$n21 set Y_ -329
$n21 set Z_ 0.0
$ns initial_node_pos $n21 50
set n22 [$ns node]
$n22 set X_ 625
$n22 set Y_ -329
$n22 set Z_ 0.0
$ns initial_node_pos $n22 50
set n23 [$ns node]
$n23 set X_ 825
$n23 set Y_ -329
$n23 set Z_ 0.0
$ns initial_node_pos $n23 50
set n24 [$ns node]
$n24 set X_ 1025
$n24 set Y_ -329
$n24 set Z_ 0.0
$ns initial_node_pos $n24 50

#=================================================================
# Multicast group - sender node 0 , receivers nodes 7,24
#=================================================================
set group0 [Node allocaddr]

#===================================
# Agents Definition
#===================================
#Setup a UDP connection
set udp0 [new Agent/UDP]
$udp0 set dst_addr_ $group0
$udp0 set dst_port_ 100
$ns attach-agent $n0 $udp0

#===================================
# Applications Definition
#===================================
#Setup a CBR Application over UDP connection
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set dst_ $group0

$ns at 1.0 "$cbr0 start"
$ns at 5.0 "$cbr0 stop"

$ns at 0.0100000000 "$n7 AODV join-group $group0"
$ns at 3.0 "$n7 AODV leave-group $group0"
$ns at 0.0100000000 "$n24 AODV join-group $group0"
$ns at 5.0 "$n24 AODV leave-group $group0"

#===================================
# Termination
#===================================
#Define a 'finish' procedure
proc finish {} {
global ns tracefile namfile
$ns flush-trace
close $tracefile
close $namfile
exec nam simulation.nam &
exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
$ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run

