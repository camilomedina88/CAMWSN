

set val(chan) 		Channel/WirelessChannel		;# channel type
set val(prop) 		Propagation/TwoRayGround	;# radio-propagation model
set val(netif)		Phy/WirelessPhy			;# network interface type
set val(mac)		Mac/802_11			;# MAC type
set val(ifq)		Queue/DropTail/PriQueue		;# Interface queue type
set val(ll)		LL				;# Link layer type
set val(ant) 		Antenna/OmniAntenna 		;# Antenna type
set val(ifqlen)		50				;# max packet in ifq
set val(nn) 		2				;# number of mobilenodes
set val(rp) 		DSDV				;# ad-hoc routing protocol

# create simulator instance
set ns_		     [new Simulator]

# create trace object for ns and nam
set tracefd	[open simple.tr w]
$ns_ use-newtrace
$ns_ trace-all $tracefd

#set up topography object  
set topo	[new Topography]
$topo load_flatgrid 500 500

set chan [new $val(chan)]



create-god $val(nn)

	$ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channel $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace OFF \
			 -macTrace OFF \
			 -movementTrace OFF

for {set i 0} {$i < $val(nn) } {incr i} {
    	set node_($i) [$ns_ node ]
    $node_($i) random-motion 0	;#disable random motion
}

$node_(0) set X_ 5.0
$node_(0) set Y_ 2.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 390.0
$node_(1) set Y_ 385.0
$node_(1) set Z_ 0.0

set god_ [God instance]

$ns_ at 50.0 "$node_(1) setdest 25.0 20.0 15.0"

$ns_ at 10.0 "$node_(0) setdest 20.0 18.0 1.0"

$ns_ at 100.0 "$node_(1) setdest 490.0 480.0 15.0"

set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(1) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns_ at 10.0 "$ftp start"

for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at 150.0 "$node_($i) reset";
}
$ns_ at 150.0001 "stop"
$ns_ at 150.0002 "puts \"NS EXITING...\"; $ns_ halt"
proc stop {} {
	global ns_ tracefd
	close $tracefd
}

puts "Starting Simulation.."
$ns_ run


