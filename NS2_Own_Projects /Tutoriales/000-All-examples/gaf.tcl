#    http://www.linuxquestions.org/questions/linux-newbie-8/error-in-implementing-gaf-in-tcl-script-4175457991/


set val(chan) Channel/WirelessChannel ;#Channel Type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 43 ;# number of mobilenodes
set val(rp) AODV ;# routing protocol
set val(x) 1000
set val(y) 1000
set val(stop) 150
#Creating trace file and nam file
set tracefd [open mob.tr w]
set windowVsTime2 [open win.tr w]
set namtrace [open mob.nam w]
set ns [new Simulator]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

# configure the nodes
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
ss -agentTrace ON \
-routerTrace ON \
-macTrace ON \
-movementTrace ON

for {set i 0} {$i < $val(nn) } { incr i } {
set node_($i) [$ns node]
$node_($i) attach-gafpartner
$node_($i) unset-gafpartner
}

$node_(0) set X_ 422.716707738489
$node_(0) set Y_ 450.707335765875

$node_(2) set X_ 350.192740186325
$node_(2) set Y_ 500.384818286195

$node_(1) set X_ 300.641181272212
$node_(1) set Y_ 250.333721576041
$node_(1) set Z_ 0.000000000000

$node_(3) set X_ 375.858918255772
$node_(3) set Y_ 400.839552218736
$node_(3) set Z_ 0.000000000000

$node_(4) set X_ 404.354417812321
$node_(4) set Y_ 354.700530392536
$node_(4) set Z_ 0.000000000000

$node_(5) set X_ 231.312312318255772
$node_(5) set Y_ 532.41235552218736

$node_(6) set X_ 114.63182318255772
$node_(6) set Y_ 534.631245552218736
$node_(6) set Z_ 0.000000000000

$node_(7) set X_ 246.716707738489
$node_(7) set Y_ 328.707335765875
$node_(7) set Z_ 0.000000000000

$node_(8) set X_ 536.716707738489
$node_(8) set Y_ 367.707335765875
$node_(8) set Z_ 0.000000000000

$node_(9) set X_ 483.716707738489
$node_(9) set Y_ 450.707335765875
$node_(9) set Z_ 0.000000000000

$node_(10) set X_ 325.716707738489
$node_(10) set Y_ 234.707335765875
$node_(10) set Z_ 0.000000000000

$node_(11) set X_ 500.858918255772
$node_(11) set Y_ 400.839552218736
$node_(11) set Z_ 0.000000000000

$node_(12) set X_ 600.858918255772
$node_(12) set Y_ 324.839552218736
$node_(12) set Z_ 0.000000000000

$node_(13) set X_ 550.858918255772
$node_(13) set Y_ 475.839552218736
$node_(13) set Z_ 0.000000000000

$node_(14) set X_ 423.858918255772
$node_(14) set Y_ 475.839552218736
$node_(14) set Z_ 0.000000000000

$node_(15) set X_ 634.858918255772
$node_(15) set Y_ 563.839552218736

$node_(16) set X_ 550.858918255772
$node_(16) set Y_ 475.839552218736
$node_(16) set Z_ 0.000000000000

$node_(17) set X_ 332.158918255772
$node_(17) set Y_ 425.4532452218736

$node_(18) set X_ 623.858918255772
$node_(18) set Y_ 534.839552218736

$node_(19) set X_ 234.1312918255772
$node_(19) set Y_ 287.57467552218736

$node_(20) set X_ 189.94830918255772
$node_(20) set Y_ 175.839552218736
$node_(21) set X_ 220.858918255772
$node_(21) set Y_ 435.839552218736
$node_(22) set X_ 321.63182318255772
$node_(22) set Y_ 275.45345552218736
$node_(23) set X_ 623.43123282318255772
$node_(23) set Y_ 432.817291345552218736
$node_(24) set X_ 287.63182318255772
$node_(24) set Y_ 275.1873892552218736
$node_(25) set X_ 321.63182318255772
$node_(25) set Y_ 117.45345552218736
$node_(26) set X_ 312.63182318255772
$node_(26) set Y_ 451.3133552218736
$node_(27) set X_ 642.63182318255772
$node_(27) set Y_ 231.45345552218736
$node_(28) set X_ 654.63182318255772
$node_(28) set Y_ 432.45345552218736
$node_(29) set X_ 613.63182318255772
$node_(29) set Y_ 689.1312552218736
$node_(30) set X_ 123.63182318255772
$node_(30) set Y_ 275.45345552218736
$node_(31) set X_ 310.63182318255772
$node_(31) set Y_ 475.45345552218736
$node_(32) set X_ 387.63182318255772
$node_(32) set Y_ 325.45345552218736
$node_(33) set X_ 354.716707738489
$node_(33) set Y_ 700.707335765875
$node_(34) set X_ 470.716707738489
$node_(34) set Y_ 500.707335765875
$node_(35) set X_ 750.63182318255772
$node_(35) set Y_ 500.45345552218736
$node_(36) set X_ 750.24428255772
$node_(36) set Y_ 507.45345552218736
$node_(37) set X_ 750.63182318255772
$node_(37) set Y_ 506.1312452218736
$node_(38) set X_ 750.2534772
$node_(38) set Y_ 502.3534218736
$node_(39) set X_ 750.8749355772
$node_(39) set Y_ 508.7832218736
$node_(40) set X_ 720.8749355772
$node_(40) set Y_ 508.7832218736
$node_(41) set X_ 720.8749355772
$node_(41) set Y_ 508.7832218736
$node_(42) set X_ 720.87493557727
$node_(42) set Y_ 508.7832218736

for {set i 0} { $i < 33 } { incr i} {
$ns initial_node_pos $node_($i) 30
}

for {set i 33} { $i < 43 } { incr i} {
$ns initial_node_pos $node_($i) 50
}

$ns duplex-link $node_(33) $node_(34) 100Mb 10ms DropTail

for {set i 0} {$i < 33} {incr i } {
$node_($i) color red
$ns at 0.0 "$node_($i) color red"
}
for {set i 10} {$i < 30 } {incr i} {

set node_($i) [$ns node]
$node_($i) random-motion 0

#attach gaf agent to this node, attach at port 254
set gafagent_ [new Agent/GAF [$node_($i) id]]
# $node_($i) attach $gafagent_ 254
# $node_($i) attach-gafpartner
# $gafagent_ adapt-mobility 1
# $ns at 0.0 "$gafagent_ start-gaf"
}

set udp [new Agent/UDP]
$ns attach-agent $node_(37) $udp
set null [new Agent/Null]
$ns attach-agent $node_(40) $null
$ns connect $udp $null
#
#creat cbr traffic source
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetsize- 1000
$cbr set rate- 1Mb
$ns at 6.0 "$cbr start"
#$ns at 11.00024 "$cbr stop"

set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
$ns attach-agent $node_(39) $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $node_(42) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start"
#$ns at 12.34343 "$ftp stop"


$ns at 15.0 "$node_(6) setdest 706.0 704.0 5.0"

# Printing the window size
proc plotWindow {tcpSource file} {
global ns
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }

#for {set i 1} {$i < $val(nn) } { incr i} {
$ns at 10.1 "plotWindow $tcp $windowVsTime2"
#$ns at 10.1 "plotWindow $udp $windowVsTime2"
#$ns at 10.1 "plotWindow $udp1 $windowVsTime2"
#}


# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
$ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
global ns tracefd namtrace
$ns flush-trace
close $tracefd
close $namtrace
exec nam mob.nam &
exit 0
}

$ns run
