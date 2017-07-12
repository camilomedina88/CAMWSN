#set i 0
set have(-enhance) false

#while {$i<$argc} {
#	switch [lindex $argv $i] {
#		enhance {
#			set have(-enhance) true
#		}
#	}
#	set i [expr {$i + 1}]
#}

set arguments(-scenarioname) "random.realbw"
set arguments(-tracefile) "$arguments(-scenarioname).tracefile"
set arguments(-namfile) "$arguments(-scenarioname).namfile"
set arguments(-bwfile) "$arguments(-scenarioname).bwmonitor"

puts "Scenario random"

set val(chan)		Channel/WirelessChannel		;#channel type
set val(prop)		Propagation/TwoRayGround	;#radio-propagation model
set val(netif)		Phy/WirelessPhy			;#network interface type
set val(mac)		Mac/802_11			;#MAC type
set val(ifq)		Queue/DropTail/PriQueue		;#interface queue type
set val(ll)		LL				;#link layer type
set val(ant)		Antenna/OmniAntenna		;#antenna model
set val(ifqlen)		50				;#max packet in ifq
set val(nn)		25				;#number of mobilenodes
set val(rp)		AODV				;#routing protocol
set val(x)		1000				;#X dimension of topology
set val(y)		1000						;#Y dimension of topology
set val(stop)		1200				;#time of simulation end
set val(rate)		2e6				;#rate physic of medium
set val(packetSize)	1000				;#size of packet
set val(height)		0

set ns [new Simulator]
set tracefd		[open $arguments(-tracefile) w]
set namtrace		[open $arguments(-namfile) w]
set grfd		[open $arguments(-bwfile) w]

Phy/WirelessPhy set CSThresh_ 1.55924e-11	;#CS Threshold is 550m
Phy/WirelessPhy set RXThresh_ 3.65262e-10	;#RS Threshold is 250m

Mac/802_11 set RTSThreshold_   2000		;#so we don't use RTS/CTS mechanism
Mac/802_11 set dataRate_ $val(rate)
Mac/802_11 set basicRate_ $val(rate)

Mac/802_11 set measuredTime 1
Mac/802_11 set improveIAB $have(-enhance)

remove-all-packet-headers		;#removes all except common headers
add-packet-header IP Message AODV	;#headers required for cbr traffic and AODV

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

#setup topography object
set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

#
#	Create nn mobilenodes
#

#configure the nodes
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
		-routerTrace OFF \
		-macTrace ON \
		-movementTrace OFF

for {set i 1} {$i <= $val(nn)} {incr i} {
	set node_($i) [$ns node]
}

#provide initial location of mobilenodes
$node_(1) set X_ 820.0
$node_(1) set Y_ 890.0
$node_(1) set Z_ $val(height)


$node_(2) set X_ 220.0
$node_(2) set Y_ 490.0
$node_(2) set Z_ $val(height)

$node_(3) set X_ 870.0
$node_(3) set Y_ 350.0
$node_(3) set Z_ $val(height)

$node_(4) set X_ 420.0
$node_(4) set Y_ 270.0
$node_(4) set Z_ $val(height)

$node_(5) set X_ 100.0
$node_(5) set Y_ 790.0
$node_(5) set Z_ $val(height)

$node_(6) set X_ 330.0
$node_(6) set Y_ 680.0
$node_(6) set Z_ $val(height)

$node_(7) set X_ 410.0
$node_(7) set Y_ 840.0
$node_(7) set Z_ $val(height)

$node_(8) set X_ 420.0
$node_(8) set Y_ 710.0
$node_(8) set Z_ $val(height)

$node_(9) set X_ 100.0
$node_(9) set Y_ 340.0
$node_(9) set Z_ $val(height)

$node_(10) set X_ 800.0
$node_(10) set Y_ 450.0
$node_(10) set Z_ $val(height)

$node_(11) set X_ 530.0
$node_(11) set Y_ 560.0
$node_(11) set Z_ $val(height)

$node_(12) set X_ 520.0
$node_(12) set Y_ 280.0
$node_(12) set Z_ $val(height)

$node_(13) set X_ 220.0
$node_(13) set Y_ 390.0
$node_(13) set Z_ $val(height)

$node_(14) set X_ 290.0
$node_(14) set Y_ 450.0
$node_(14) set Z_ $val(height)

$node_(15) set X_ 200.0
$node_(15) set Y_ 190.0
$node_(15) set Z_ $val(height)

$node_(16) set X_ 740.0
$node_(16) set Y_ 270.0
$node_(16) set Z_ $val(height)

$node_(17) set X_ 320.0
$node_(17) set Y_ 890.0
$node_(17) set Z_ $val(height)

$node_(18) set X_ 390.0
$node_(18) set Y_ 510.0
$node_(18) set Z_ $val(height)

$node_(19) set X_ 500.0
$node_(19) set Y_ 350.0
$node_(19) set Z_ $val(height)

$node_(20) set X_ 280.0
$node_(20) set Y_ 270.0
$node_(20) set Z_ $val(height)

$node_(21) set X_ 830.0
$node_(21) set Y_ 240.0
$node_(21) set Z_ $val(height)

$node_(22) set X_ 550.0
$node_(22) set Y_ 470.0
$node_(22) set Z_ $val(height)

$node_(23) set X_ 200.0
$node_(23) set Y_ 840.0
$node_(23) set Z_ $val(height)

$node_(24) set X_ 630.0
$node_(24) set Y_ 800.0
$node_(24) set Z_ $val(height)

$node_(25) set X_ 150.0
$node_(25) set Y_ 580.0
$node_(25) set Z_ $val(height)

#generation of movements
#$ns at 10.0 "$node_(0) setdest 250.0 250.0 3.0"

#setup a UDP connection between node_(1) and node_(15)
set udp_(1) [new Agent/UDP]
$ns attach-agent $node_(1) $udp_(1)
set recv_(15) [new Agent/LossMonitor]
$ns attach-agent $node_(15) $recv_(15)
$ns connect $udp_(1) $recv_(15)
$udp_(1) set fid_ 1

#setup a CBR over UDP connection
set cbr_(1) [new Application/Traffic/CBR]
$cbr_(1) attach-agent $udp_(1)
$cbr_(1) set packetSize_ $val(packetSize)
$cbr_(1) set rate_ 12e4
$cbr_(1) set random_ 1

#setup a UDP connection between node_(3) and node_(5)
set udp_(3) [new Agent/UDP]
$ns attach-agent $node_(3) $udp_(3)
set recv_(5) [new Agent/LossMonitor]
$ns attach-agent $node_(5) $recv_(5)
$ns connect $udp_(3) $recv_(5)
$udp_(3) set fid_ 3

#setup a CBR over UDP connection
set cbr_(3) [new Application/Traffic/CBR]
$cbr_(3) attach-agent $udp_(3)
$cbr_(3) set packetSize_ $val(packetSize)
$cbr_(3) set rate_ 3e4
$cbr_(3) set random_ 1

#setup a UDP connection between node_(18) and node_(22)
set udp_(18) [new Agent/UDP]
$ns attach-agent $node_(18) $udp_(18)
set recv_(22) [new Agent/LossMonitor]
$ns attach-agent $node_(22) $recv_(22)
$ns connect $udp_(18) $recv_(22)
$udp_(18) set fid_ 18

#setup a CBR over UDP connection
set cbr_(18) [new Application/Traffic/CBR]
$cbr_(18) attach-agent $udp_(18)
$cbr_(18) set packetSize_ $val(packetSize)
$cbr_(18) set rate_ 0
$cbr_(18) set random_ 1


#define node initial position in nam
for {set i 1} {$i <= $val(nn)} {incr i} {
	$ns initial_node_pos $node_($i) 30
}

#telling nodes when the simulation ends
for {set i 1} {$i <= $val(nn)} {incr i} {
	$ns at $val(stop) "$node_($i) reset";
}

#ending nam and the simulation
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at [expr $val(stop)+0.01] "puts \"end simulation\" ; $ns halt"
proc stop {} {
	global ns tracefd namtrace
	$ns flush-trace
	close $tracefd
	close $namtrace
}

proc record_ {} {
	global recv_ grfd node_ cbr_
	#Get an instance of the simulator
	set ns [Simulator instance]
	#Set the time after which the procedure should be called again
	set time 1.
				
	foreach IT [array names recv_] {
		set bw_($IT) [$recv_($IT) set bytes_]
		set pk_($IT) [$recv_($IT) set npkts_] 
	}
	
	#Get the current time
	set now [$ns now]
	#Calculate the bandwidth (in MBit/s) and write it to the files
	set somme_bw 0
	#set somme_pk 0

	foreach item [array names bw_] {
		set somme_bw [expr $somme_bw + $bw_($item)/$time*8/1000]
	}

	#foreach item [array names pk_] {
	#	set somme_pk [expr $somme_pk + $pk_($item)]
	#}

	set sortie "$now\t[$cbr_(18) set rate_]\t"
	foreach item [array names bw_] {
		set sortie [format "$sortie \trecv_($item)\t%.0f" [expr $bw_($item)/$time*8/1000]]
	}

	#puts $grfd "$sortie (TOT) $somme_bw $somme_pk"; #[expr $pos2 - $pos1]"
	puts $grfd [format "$sortie \tTOT \t%.0f" $somme_bw]
	#puts "$sortie (TOT) $somme_bw $somme_pk"
	
	#Reset the bytes_ values on the traffic sinks
	foreach IT [array names recv_] {
		$recv_($IT) set bytes_ 0
		#$recv_($IT) set npkts_ 0
	}

	#Re-schedule the procedure
	$ns at [expr $now+$time] "record_"
}
$ns at 1.0 "record_"

proc controlflux { cbrflux starttime stoptime } {
	set ns [Simulator instance]
	if {[$cbrflux set rate_] > 0} {
		$ns at $starttime "$cbrflux start"
		$ns at $stoptime "$cbrflux stop"
	}
}
controlflux $cbr_(1) 5.0 [expr $val(stop)-5.0]
controlflux $cbr_(3) 10.0 [expr $val(stop)-5.0]

set MyRng [new RNG]
$MyRng seed 0
set rUni [new RandomVariable/Uniform]
$rUni use-rng $MyRng
$rUni set min_ 0.0
$rUni set max_ 1000.0

proc increase_find {starttime stoptime i} {
	global arguments cbr_ rUni
	set ns [Simulator instance]
	set cbr18rate [expr 5e5 + $i*5e3]
	$cbr_(18) set rate_ $cbr18rate

	controlflux $cbr_(18) $starttime $stoptime

	$ns at $stoptime "$cbr_(18) set rate_ 0"
	set nextstarttime [expr $starttime+50]
	set nextstoptime [expr $stoptime+50]
	set nexti [expr $i+1]
	if {$i<20} {
		$ns at [expr $stoptime] "increase_find $nextstarttime $nextstoptime $nexti"
	}
}
$ns at 100.0 "increase_find 100 150 0"
$ns run

