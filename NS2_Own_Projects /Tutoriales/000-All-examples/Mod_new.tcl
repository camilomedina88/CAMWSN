#====   https://groups.google.com/forum/?fromgroups#!topic/ns-users/uyrd5IuYTTI
#	setting up environment
#==============================================================

set val(chan) 	Channel/WirelessChannel 	;#Channel Type
set val(prop) 	Propagation/TwoRayGround 	;# radio-propagation model
set val(netif) 	Phy/WirelessPhy 		;# network interface type
set val(mac) 	Mac/802_11 			;# MAC type
set val(ifq) 	Queue/DropTail/PriQueue 	;# interface queue type
set val(ll) 	LL 				;# link layer type
set val(ant) 	Antenna/OmniAntenna 		;# antenna model
set val(ifqlen) 50 				;# max packet in ifq
set val(nn) 	43 				;# number of mobilenodes
set val(rp) 	AODV 				;# routing protocol
set val(x) 	1000
set val(y) 	1000
set val(stop) 	150

#=============================================================
#Creating trace file and nam file; initialization
#=============================================================
set tracefd [open mob.tr w]
set namtrace [open mob.nam w]
set ns [new Simulator]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

#===========================================================
# configure the nodes
#===========================================================

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
		-movementTrace ON

#=========================================================
# attaching GAF algorithm
#=========================================================

for {set i 0} {$i < $val(nn) } { incr i } {
set node_($i) [$ns node]
$node_($i) attach-gafpartner
$node_($i) unset-gafpartner
}

#=========================================================
# setting up node coordinates
#=========================================================

$node_(0) set X_ 422.71
$node_(0) set Y_ 450.70
$node_(0) set Z_ 0.0

$node_(2) set X_ 350.19
$node_(2) set Y_ 500.38
$node_(2) set Z_ 0.0

$node_(1) set X_ 300.64
$node_(1) set Y_ 250.33
$node_(1) set Z_ 0.0

$node_(3) set X_ 375.85
$node_(3) set Y_ 400.83
$node_(3) set Z_ 0.0

$node_(4) set X_ 404.35
$node_(4) set Y_ 354.70
$node_(4) set Z_ 0.0

$node_(5) set X_ 231.31
$node_(5) set Y_ 532.41
$node_(5) set Z_ 0.0

$node_(6) set X_ 114.63
$node_(6) set Y_ 534.63
$node_(6) set Z_ 0.0

$node_(7) set X_ 246.71
$node_(7) set Y_ 328.70
$node_(7) set Z_ 0.0

$node_(8) set X_ 536.71
$node_(8) set Y_ 367.70
$node_(8) set Z_ 0.0

$node_(9) set X_ 483.71
$node_(9) set Y_ 450.70
$node_(9) set Z_ 0.0

$node_(10) set X_ 325.71
$node_(10) set Y_ 234.70
$node_(10) set Z_ 0.000000000000

$node_(11) set X_ 500.85
$node_(11) set Y_ 400.83
$node_(11) set Z_ 0.000000000000

$node_(12) set X_ 600.85
$node_(12) set Y_ 324.83
$node_(12) set Z_ 0.000000000000

$node_(13) set X_ 550.85
$node_(13) set Y_ 475.83
$node_(13) set Z_ 0.0000

$node_(14) set X_ 423.85
$node_(14) set Y_ 475.83
$node_(14) set Z_ 0.0000

$node_(15) set X_ 634.85
$node_(15) set Y_ 563.83
$node_(15) set Z_ 0.0
$node_(16) set X_ 550.85
$node_(16) set Y_ 475.83
$node_(16) set Z_ 0.0000

$node_(17) set X_ 332.15
$node_(17) set Y_ 425.45
$node_(17) set Z_ 0.0

$node_(18) set X_ 623.85
$node_(18) set Y_ 534.83
$node_(18) set Z_ 0.0

$node_(19) set X_ 234.13
$node_(19) set Y_ 287.57
$node_(19) set Z_ 0.0

$node_(20) set X_ 189.94
$node_(20) set Y_ 175.83
$node_(20) set Z_ 0.0

$node_(21) set X_ 220.85
$node_(21) set Y_ 435.83
$node_(21) set Z_ 0.0

$node_(22) set X_ 321.63
$node_(22) set Y_ 275.45
$node_(22) set Z_ 0.0

$node_(23) set X_ 623.43
$node_(23) set Y_ 432.81
$node_(23) set Z_ 0.0

$node_(24) set X_ 287.63
$node_(24) set Y_ 275.18
$node_(24) set Z_ 0.0

$node_(25) set X_ 321.63
$node_(25) set Y_ 117.45
$node_(25) set Z_ 0.0

$node_(26) set X_ 312.63
$node_(26) set Y_ 451.31
$node_(26) set Z_ 0.0

$node_(27) set X_ 642.63
$node_(27) set Y_ 231.45
$node_(27) set Z_ 0.0

$node_(28) set X_ 654.63
$node_(28) set Y_ 432.45
$node_(28) set Z_ 0.0

$node_(29) set X_ 613.63
$node_(29) set Y_ 689.13
$node_(29) set Z_ 0.0

$node_(30) set X_ 123.63
$node_(30) set Y_ 275.45
$node_(30) set Z_ 0.0

$node_(31) set X_ 310.63
$node_(31) set Y_ 475.45
$node_(31) set Z_ 0.0

$node_(32) set X_ 387.63
$node_(32) set Y_ 325.45
$node_(32) set Z_ 0.0

$node_(33) set X_ 354.71
$node_(33) set Y_ 700.70
$node_(33) set Z_ 0.0

$node_(34) set X_ 470.71
$node_(34) set Y_ 500.70
$node_(34) set Z_ 0.0

$node_(35) set X_ 750.63
$node_(35) set Y_ 500.45
$node_(35) set Z_ 0.0

$node_(36) set X_ 750.24
$node_(36) set Y_ 507.45
$node_(36) set Z_ 0.0

$node_(37) set X_ 750.63
$node_(37) set Y_ 506.13
$node_(37) set Z_ 0.0

$node_(38) set X_ 750.25
$node_(38) set Y_ 502.35
$node_(38) set Z_ 0.0

$node_(39) set X_ 750.87
$node_(39) set Y_ 508.78
$node_(39) set Z_ 0.0

$node_(40) set X_ 720.87
$node_(40) set Y_ 508.78
$node_(40) set Z_ 0.0

$node_(41) set X_ 720.87
$node_(41) set Y_ 508.78
$node_(41) set Z_ 0.0

$node_(42) set X_ 720.87
$node_(42) set Y_ 508.78
$node_(42) set Z_ 0.0

#============================================
# setting up initial node size 
#============================================

for {set i 0} { $i < 33 } { incr i} {
$ns initial_node_pos $node_($i) 30
}

for {set i 33} { $i < 43 } { incr i} {
$ns initial_node_pos $node_($i) 50
}

#===========================================================
# setting duplex link between node 33 and 34
#===========================================================

$ns duplex-link $node_(33) $node_(34) 100Mb 10ms DropTail

#==========================================================
#	setting up node colour
#==========================================================

for {set i 0} {$i < 33} {incr i } {
$node_($i) color red
$ns at 0.0 "$node_($i) color red"
}

#=================================================================================
#	node 10 to 30 will have random motion and will be attached with GAF agent
#================================================================================

for {set i 10} {$i < 30 } {incr i} {

#set node_($i) [$ns node]
#$node_($i) random-motion 0 

#attach gaf agent to this node, attach at port 254

 set gafagent_ [new Agent/GAF [$node_($i) i]]
 $node_($i) attach $gafagent_ 254
 $node_($i) attach-gafpartner
 $gafagent_ adapt-mobility 1
 $ns at 0.0 "$gafagent_ start-gaf"
}

#==============================================================
# setting up UDP  agent between nodes
#==============================================================

set udp [new Agent/UDP]
$ns attach-agent $node_(37) $udp
set null [new Agent/Null]
$ns attach-agent $node_(40) $null
$ns connect $udp $null

#============================================================
#creat cbr traffic source
#============================================================

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

#=============================================
# Printing the window size
#=============================================

#proc plotWindow {tcpSource file} {
#global ns
#set time 0.01
#set now [$ns now]
#set cwnd [$tcpSource set cwnd_]
#puts $file "$now $cwnd"
#$ns at [expr $now+$time] "plotWindow $tcpSource $file" }

#for {set i 1} {$i < $val(nn) } { incr i} {
#$ns at 10.1 "plotWindow $tcp $windowVsTime2"
#$ns at 10.1 "plotWindow $udp $windowVsTime2"
#$ns at 10.1 "plotWindow $udp1 $windowVsTime2"
#}


# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
$ns at $val(stop) "$node_($i) reset";
}

#===================================================
# ending nam and the simulation
#===================================================

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
