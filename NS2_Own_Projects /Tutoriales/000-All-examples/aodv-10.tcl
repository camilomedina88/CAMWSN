Phy/WirelessPhy set freq_ 2.472e9  
Phy/WirelessPhy set RXThresh_ 2.62861e-09; #100m radius
Phy/WirelessPhy set CSThresh_ [expr 0.9*[Phy/WirelessPhy set RXThresh_]]
Phy/WirelessPhy set bandwidth_ 11.0e6 
Mac/802_11 set dataRate_ 11Mb 
Mac/802_11 set basicRate_ 2Mb 

set val(chan) Channel/WirelessChannel ;
set val(prop) Propagation/TwoRayGround ;
set val(netif) Phy/WirelessPhy ;
set val(mac) Mac/802_11 ;
set val(ifq) Queue/DropTail/PriQueue ;
set val(ll) LL ;
set val(ant) Antenna/OmniAntenna ;
set val(ifqlen) 30 ;
set val(nn) 10 ;
set val(rp) AODV ;
set val(x) 200 ;
set val(y) 200 ;
set val(stop) 50 ;

set ns [new Simulator]

set tracefd [open AODV_10.tr w]

set winFile [open CwMaodv_10 w]

set namtracefd [open namwrls.nam w]

$ns trace-all $tracefd
$ns use-newtrace

$ns namtrace-all-wireless $namtracefd $val(x) $val(y)

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

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
                -macTrace OFF \
                -movementTrace OFF \


for {set i 0} {$i < $val(nn) } {incr i} {
  set node_($i) [$ns node]
 }

$node_(0) set X_ 1.0
$node_(0) set Y_ 50.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 60.0
$node_(1) set Y_ 50.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 25.0
$node_(2) set Y_ 65.0
$node_(2) set Z_ 0.0



$node_(3) set X_ 70.0
$node_(3) set Y_ 40.0
$node_(3) set Z_ 0.0



$node_(4) set X_ 80.0
$node_(4) set Y_ 30.0
$node_(4) set Z_ 0.0


$node_(5) set X_ 90.0
$node_(5) set Y_ 20.0
$node_(5) set Z_ 0.0


$node_(6) set X_ 100.0
$node_(6) set Y_ 10.0
$node_(6) set Z_ 0.0


$node_(7) set X_ 110.0
$node_(7) set Y_ 100.0
$node_(7) set Z_ 0.0

$node_(8) set X_ 120.0
$node_(8) set Y_ 1.0
$node_(8) set Z_ 0.0

$node_(9) set X_ 130.0
$node_(9) set Y_ 5.0
$node_(9) set Z_ 0.0








$ns at 10.0 "$node_(2) setdest 135.0 65.0 8.0"

$ns at 10.0 "$node_(4) setdest 140.0 70.0 8.0"

$ns at 10.0 "$node_(8) setdest 125.0 100.0 8.0"



set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(2) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp


$ns at 0.1 "$ftp start"

for {set i 0} {$i < $val(nn) } {incr i} {
 $ns initial_node_pos $node_($i) 10
 }

for {set i 0} {$i < $val(nn) } {incr i} {
 $ns at $val(stop) "$node_($i) reset"
}

$ns at $val(stop) "stop"


proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
$ns at 0.1 "plotWindow $tcp $winFile"

proc stop {} {
global ns tracefd namtracefd
$ns flush-trace
close $tracefd
close $namtracefd
exec nam namwrls.nam &
exit 0
}


$ns run