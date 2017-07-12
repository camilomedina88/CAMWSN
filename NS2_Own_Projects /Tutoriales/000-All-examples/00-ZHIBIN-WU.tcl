# ===================================================
# Author: ZHIBIN WU 06/19/2003
# http://www.winlab.rutgers.edu/~zhibinwu/html/NS_examp.html
# ==================================================



set cbr_size 500
set cbr_interval 0.002
set num_row 4
set time_duration 100

set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(rp) DSDV ;# routing protocol
# 
# Initialize ns
#
set ns_ [new Simulator]
set tracefd [open simple.tr w]
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]
$topo load_flatgrid 1000 1000

create-god [expr $num_row * $num_row ]

$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) \
     -macType $val(mac)  -ifqType $val(ifq) \
     -ifqLen $val(ifqlen) -antType $val(ant) \
     -propType $val(prop) -phyType $val(netif) \
     -channel  [new $val(chan)] -topoInstance $topo \
     -agentTrace ON -routerTrace OFF\
     -macTrace ON \
     -movementTrace OFF
 
for {set i 0} {$i < [expr $num_row*$num_row]} {incr i} {
    set node_($i) [$ns_ node]
}
set k 0;
while {$k < $num_row } {
    for {set i 0} {$i < $num_row } {incr i} {
	set m [expr $i+$k*$num_row];
	$node_($m) set X_ [expr $i*240];
	$node_($m) set Y_ [expr $k*240+20.0];
	$node_($m) set Z_ 0.0
    }
    incr k;
}; 
for {set i 0} {$i < $num_row } {incr i} {
    set udp_($i) [new Agent/UDP]
    set null_($i) [new Agent/Null]
} 
  $ns_ attach-agent $node_(0) $udp_(0)
  $ns_ attach-agent $node_(7) $udp_(1)
  $ns_ attach-agent $node_(2) $udp_(2)
  $ns_ attach-agent $node_(7) $udp_(3)
  $ns_ attach-agent $node_(6) $null_(0)
  $ns_ attach-agent $node_(1) $null_(1)
  $ns_ attach-agent $node_(8) $null_(2)
  $ns_ attach-agent $node_(15) $null_(3)
for {set i 0} {$i < $num_row } {incr i} {
     $ns_ connect $udp_($i) $null_($i)
}
for {set i 0} {$i < $num_row } {incr i} {
    set cbr_($i) [new Application/Traffic/CBR]
$cbr_($i) set packetSize_ $cbr_size
$cbr_($i) set interval_ 0.5
$cbr_($i) attach-agent $udp_($i)
} 
$ns_ at 11.0234 "$cbr_(0) start"
$ns_ at 10.4578 "$cbr_(1) start" 
$ns_ at 12.7184 "$cbr_(2) start"
$ns_ at 12.2456 "$cbr_(3) start" 
# Tell nodes when the simulation ends
#
for {set i 0} {$i < [expr $num_row*$num_row] } {incr i} {
    $ns_ at [expr $time_duration +10.0] "$node_($i) reset";
}
$ns_ at [expr $time_duration +10.0] "finish"
$ns_ at [expr $time_duration +10.01] "puts \"NS Exiting...\"; $ns_ halt"

proc finish {} {
global ns_ tracefd
$ns_ flush-trace
close $tracefd
}

puts "Starting Simulation..."
$ns_ run
