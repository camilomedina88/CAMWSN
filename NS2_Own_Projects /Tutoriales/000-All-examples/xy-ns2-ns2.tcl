#===============================================================================
# Define options
#===============================================================================
set opt(chan) Channel/WirelessChannel ;# channel type
set opt(prop) Propagation/TwoRayGround ;# radio-propagation model
set opt(netif) Phy/WirelessPhy ;# network interface type
set opt(mac) Mac/802_11
set opt(ifq) Queue/DropTail/PriQueue ;# interface queue type
set opt(ll) LL ;# Link layer type
set opt(rlc) RLC ;# Radio Link Control
set opt(ant) Antenna/OmniAntenna ;# antenna model
set opt(ifqlen) 500 ;# max packet in ifq
set opt(adhocRouting) SARP ;# routing protocol
set opt(x) 1000 ;# x coordinate of topology
set opt(y) 1000 ;# y coordinate of topology
set opt(nn) 100 ;# number of mobilenodes
set opt(start) 1 ;# simulation start time
set opt(stop) 15 ;# simulation stop time
set opt(att) 5 ;# number of attackers
set st_atk 56 ;# starting attacker node
set opt(pause) 10
#==============================================================================

set ns_ [new Simulator]
# $ns_ use-newtrace
set nf [open out.nam w]
set tf [open out.tr w]
$ns_ namtrace-all-wireless $nf $opt(x) $opt(y)
$ns_ trace-all $tf

set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)

set god_ [create-god $opt(nn)]

set channel [new $opt(chan)]

$ns_ node-config -adhocRouting $opt(adhocRouting) \
-llType $opt(ll) \
-rlcType $opt(rlc) \
-macType $opt(mac) \
-ifqType $opt(ifq) \
-ifqLen $opt(ifqlen) \
-antType $opt(ant) \
-propType $opt(prop) \
-phyType $opt(netif) \
-topoInstance $topo \
-wiredRouting OFF \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace OFF \
-channel $channel

#node creation
for {set i 0} {$i < $opt(nn) } {incr i} {
set node_($i) [$ns_ node]
$node_($i) random-motion 0 ;# disable random motion
}

#$ns_ color 0 red

puts "Loading scenario files .."
source "../scen/SCENP$opt(pause)"

for {set i $st_atk} {$i < [expr $st_atk+$opt(att)] } {incr i} {
$ns_ at 0.0 "$node_($i) add-mark m1 red circle"
}

set rate [expr $opt(att)*50]kb

set udp1 [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp1
set null1 [new Agent/Null]
$ns_ attach-agent $node_(50) $null1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 1000
$cbr1 set rate_ $rate
$cbr1 attach-agent $udp1
$ns_ connect $udp1 $null1
$ns_ at 1.0 "$node_(0) label Src";
$ns_ at 1.0 "$node_(50) label Dest";
$ns_ at 1.0 "$cbr1 start"


for {set i 0} {$i < $opt(nn) } {incr i} {
$ns_ at $opt(stop) "$node_($i) reset";
}

for {set i 0} {$i < $opt(nn)} {incr i} {
$ns_ initial_node_pos $node_($i) 20
}

$ns_ at $opt(stop).01 "puts \"NS EXITING...\" ; $ns_ halt"
#===============================================================================
# Define options
#===============================================================================
set opt(chan) Channel/WirelessChannel ;# channel type
set opt(prop) Propagation/TwoRayGround ;# radio-propagation model
set opt(netif) Phy/WirelessPhy ;# network interface type
set opt(mac) Mac/802_11
set opt(ifq) Queue/DropTail/PriQueue ;# interface queue type
set opt(ll) LL ;# Link layer type
set opt(rlc) RLC ;# Radio Link Control
set opt(ant) Antenna/OmniAntenna ;# antenna model
set opt(ifqlen) 500 ;# max packet in ifq
set opt(adhocRouting) SARP ;# routing protocol
set opt(x) 1000 ;# x coordinate of topology
set opt(y) 1000 ;# y coordinate of topology
set opt(nn) 100 ;# number of mobilenodes
set opt(start) 1 ;# simulation start time
set opt(stop) 15 ;# simulation stop time
set opt(att) 5 ;# number of attackers
set st_atk 56 ;# starting attacker node
set opt(pause) 10
#==============================================================================

set ns_ [new Simulator]
# $ns_ use-newtrace
set nf [open out.nam w]
set tf [open out.tr w]
$ns_ namtrace-all-wireless $nf $opt(x) $opt(y)
$ns_ trace-all $tf

set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)

set god_ [create-god $opt(nn)]

set channel [new $opt(chan)]

$ns_ node-config -adhocRouting $opt(adhocRouting) \
-llType $opt(ll) \
-rlcType $opt(rlc) \
-macType $opt(mac) \
-ifqType $opt(ifq) \
-ifqLen $opt(ifqlen) \
-antType $opt(ant) \
-propType $opt(prop) \
-phyType $opt(netif) \
-topoInstance $topo \
-wiredRouting OFF \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace OFF \
-channel $channel

#node creation
for {set i 0} {$i < $opt(nn) } {incr i} {
set node_($i) [$ns_ node]
$node_($i) random-motion 0 ;# disable random motion
}

#$ns_ color 0 red

puts "Loading scenario files .."
source "../scen/SCENP$opt(pause)"

for {set i $st_atk} {$i < [expr $st_atk+$opt(att)] } {incr i} {
$ns_ at 0.0 "$node_($i) add-mark m1 red circle"
}

set rate [expr $opt(att)*50]kb

set udp1 [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp1
set null1 [new Agent/Null]
$ns_ attach-agent $node_(50) $null1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 1000
$cbr1 set rate_ $rate
$cbr1 attach-agent $udp1
$ns_ connect $udp1 $null1
$ns_ at 1.0 "$node_(0) label Src";
$ns_ at 1.0 "$node_(50) label Dest";
$ns_ at 1.0 "$cbr1 start"


for {set i 0} {$i < $opt(nn) } {incr i} {
$ns_ at $opt(stop) "$node_($i) reset";
}

for {set i 0} {$i < $opt(nn)} {incr i} {
$ns_ initial_node_pos $node_($i) 20
}

$ns_ at $opt(stop).01 "puts \"NS EXITING...\" ; $ns_ halt"

proc finish {} {
global nf tf ns_
$ns_ flush-trace
close $nf
close $tf
exec ./find2.bin
#exec nam out.nam &
exit 0
}

$ns_ at $opt(stop) "finish"
$ns_ run
proc finish {} {
global nf tf ns_
$ns_ flush-trace
close $nf
close $tf
exec ./find2.bin
#exec nam out.nam &
exit 0
}

$ns_ at $opt(stop) "finish"
$ns_ run
