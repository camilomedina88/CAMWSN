# Define options
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy/MIMO ;# network interface type
set val(mac) Mac/dcma ;# MAC type
set val(ifq) Queue/Aggr/APriQ ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 50 ;# number of mobilenodes
set val(rp) AODV ;# routing protocol
set val(end) 200.0 ;
set opt(energymodel) EnergyModel ;
set opt(initialenergy) 100.0
set intr 0.01

if {$argc == 1} {
set intr [lindex $argv 0]
}

set CST 9.652e-09 ;

Phy/WirelessPhy/MIMO set CPThresh_ 10.0
Phy/WirelessPhy/MIMO set CSThresh_ $CST
Phy/WirelessPhy/MIMO set RXThresh_ $CST

Mac/dcma set RTSThreshold 3000

set size 512
Mac/dcma set cfb_ 0;

# Initialize Global Variables
set ns_ [new Simulator]

set tracefd [open out.tr w]
$ns_ trace-all $tracefd

$ns_ namtrace-all-wireless [open out.nam w] 500 500
$ns_ use-newtrace

# set up topography object
set topo [new Topography]
$topo load_flatgrid 1000 1000

set god_ [create-god $val(nn)]

$ns_ node-config -adhocRouting $val(rp) \
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
-energyModel $opt(energymodel) \
-initialEnergy $opt(initialenergy) \
-macTrace OFF \
-movementTrace OFF
for {set i 0 } {$i < $val(nn) } { incr i } {
set node_($i) [$ns_ node]
set ragent_($i) [$node_($i) set ragent_]

$node_($i) NumAntenna 4
$node_($i) MIMOSystem 2

}

source scen_$val(nn)


for {set i 0 } {$i < $val(nn) } { incr i } {
$ns_ initial_node_pos $node_($i) 20
}

puts "Starting Simulation..."

proc create_cbr_connection {id src dst invl st sp} {
global ns_ node_
set udp_($id) [new Agent/UDP]
$ns_ attach-agent $node_($src) $udp_($id)
$udp_($id) set fid_ $id
set cbr_($id) [new Application/Traffic/CBR]
$cbr_($id) set interval_ $invl
$cbr_($id) set packetSize_ 500
$cbr_($id) attach-agent $udp_($id)

set null_($id) [new Agent/Null]
$ns_ attach-agent $node_($dst) $null_($id)

$ns_ connect $udp_($id) $null_($id)

$ns_ at $st "$cbr_($id) start"
$ns_ at $sp "$cbr_($id) stop"
}

proc create_tcp_connection {id src dst invl st sp} {
global ns_ node_
set tcp($id) [new Agent/TCP]
$tcp($id) set class_ 2

set sink($id) [new Agent/TCPSink]
$ns_ attach-agent $node_($src) $tcp($id)
$ns_ attach-agent $node_($dst) $sink($id)
$ns_ connect $tcp($id) $sink($id)

set cbr($id) [new Application/Traffic/CBR]
$cbr($id) attach-agent $tcp($id)
$cbr($id) set interval_ $invl
$cbr($id) set packetSize_ 1024

$ns_ at $st "$cbr($id) start"
$ns_ at $sp "$cbr($id) stop"
}
#create_tcp_connection 0 0 13 0.1 5 75
create_tcp_connection 1 22 2 0.1 6 76
create_tcp_connection 1 2 22 0.1 6 76

#create_tcp_connection 2 24 15 0.1 7 77
#create_tcp_connection 3 12 27 0.1 8 78
#create_tcp_connection 4 4 36 0.1 9 79

$ns_ at $val(end).0000001 "$node_(0) reset";
$ns_ at $val(end).000001 "$ns_ halt; exit 0"
$ns_ run
