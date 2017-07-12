# http://imraan-prrec.blogspot.dk/2012/05/black-hole-blackhole-attack-in-aodv.html


set val(chan) Channel/WirelessChannel ;
set val(prop) Propagation/TwoRayGround ;
set val(netif) Phy/WirelessPhy ;
set val(mac) Mac/802_11 ;
set val(ifq) Queue/DropTail/PriQueue ;
set val(ll) LL ;
set val(ant) Antenna/OmniAntenna ;
set val(ifqlen) 40 ;
set val(nn) 3 ;
set val(rp) AODV ;
set val(brp) blackholeAODV ; # blackhole aodv protocol mentioned here....
set val(x) 1000 ;
set val(y) 1000 ;
set val(stop) 20 ;

set ns [new Simulator]
set tracefd [open bhatk.tr w]
set namtracefd [open wrlsaodv.nam w]
$ns trace-all $tracefd
$ns use-newtrace
$ns namtrace-all-wireless $namtracefd $val(x) $val(y)
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

#GOD (General Operations Director)
create-god $val(nn)
$ns node-config -adhocRouting $val(rp) \
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
-macTrace ON \
-movementTrace OFF \


set node_(0) [$ns node]
set node_(1) [$ns node]

$node_(0) label "sender"
$node_(1) label "destination"



#########################################
$ns node-config -adhocRouting $val(brp)
set node_(2) [$ns node]
#blackhole node creation
#######################################

$node_(0) set X_ 0.0
$node_(0) set Y_ 350.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 120.0
$node_(1) set Y_ 400.0
$node_(1) set Z_ 0.

$node_(2) set X_ 160.0
$node_(2) set Y_ 290.0
$node_(2) set Z_ 0.0

set udp [new Agent/UDP]
$udp set class_ 1
set sink [new Agent/UDP]
$ns attach-agent $node_(0) $udp
$ns attach-agent $node_(1) $sink
$ns connect $udp $sink

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 512


$ns at 0.1 "$cbr start"
$ns at 19.0 "$cbr stop"

$ns at 0.01 "$node_(2) label \"blackhole node\""

for {set i 0} {$i < $val(nn) } {incr i} {
$ns initial_node_pos $node_($i) 10
}

for {set i 0} {$i < $val(nn) } {incr i} {
$ns at $val(stop) "$node_($i) reset"
}

$ns at $val(stop) "stop"

proc stop {} {
global ns tracefd namtracefd
$ns flush-trace
close $tracefd
close $namtracefd
exec nam wrlsaodv.nam &
exit 0
}
$ns run
