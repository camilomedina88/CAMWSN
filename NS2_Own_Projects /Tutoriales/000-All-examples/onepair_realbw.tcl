set i 0
set have(-f1) "false"
set have(-f2) "false"

while {$i<$argc} {
	switch [lindex $argv $i] {
		f1 {
			set arguments(-f1) "[lindex $argv [expr {$i + 1}]]"
			set i [expr {$i + 1}]
			set have(-f1) "true"
		}
		f2 {
			set arguments(-f2start) "[lindex $argv [expr {$i + 1}]]"
			set arguments(-f2stop) "[lindex $argv [expr {$i + 2}]]"
			set i [expr {$i + 2}]
			set have(-f2) "true"
		}
	}
	set i [expr {$i + 1}]
}

if {$have(-f1) == "false"} {
	set arguments(-f1) 0
}

if {$have(-f2) == "false"} {
	set arguments(-f2start) 0
	set arguments(-f2stop) 16e5
}

set arguments(-scenarioname) "onepair.$arguments(-f1).realbw"
set arguments(-tracefile) "$arguments(-scenarioname).tracefile"
set arguments(-namfile) "$arguments(-scenarioname).namfile"
set arguments(-bwfile) "$arguments(-scenarioname).bwmonitor"

puts "Scenario one pair"
puts "Flux rate from node 1 to node 2: f1 = $arguments(-f1)"

set val(chan)		Channel/WirelessChannel		;#channel type
set val(prop)		Propagation/TwoRayGround	;#radio-propagation model
set val(netif)		Phy/WirelessPhy			;#network interface type
set val(mac)		Mac/802_11			;#MAC type
set val(ifq)		Queue/DropTail/PriQueue		;#interface queue type
set val(ll)		LL				;#link layer type
set val(ant)		Antenna/OmniAntenna		;#antenna model
set val(ifqlen)		50				;#max packet in ifq
set val(nn)		2				;#number of mobilenodes
set val(rp)		AODV				;#routing protocol
set val(x)		500				;#X dimension of topology
set val(y)		750				;#Y dimension of topology
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
		-agentTrace OFF \
		-routerTrace OFF \
		-macTrace OFF \
		-movementTrace OFF

for {set i 1} {$i <= $val(nn)} {incr i} {
	set node_($i) [$ns node]
}

#provide initial location of mobilenodes
$node_(1) set X_ 250.0
$node_(1) set Y_ 250.0
$node_(1) set Z_ $val(height)

$node_(2) set X_ 250.0
$node_(2) set Y_ 450.0
$node_(2) set Z_ $val(height)

#setup a UDP connection between node_(1) and node_(2)
set udp_(1) [new Agent/UDP]
$ns attach-agent $node_(1) $udp_(1)
set recv_(2) [new Agent/LossMonitor]
$ns attach-agent $node_(2) $recv_(2)
$ns connect $udp_(1) $recv_(2)
$udp_(1) set fid_ 1

#setup a CBR over UDP connection
set cbr_(1) [new Application/Traffic/CBR]
$cbr_(1) attach-agent $udp_(1)
$cbr_(1) set packetSize_ $val(packetSize)
$cbr_(1) set rate_ $arguments(-f1)
$cbr_(1) set random_ 1


#setup an other UDP connection between node_(1) and node_(2)
set udp_(3) [new Agent/UDP]
$ns attach-agent $node_(1) $udp_(3)
set recv_(4) [new Agent/LossMonitor]
$ns attach-agent $node_(2) $recv_(4)
$ns connect $udp_(3) $recv_(4)
$udp_(3) set fid_ 3

#setup a CBR over UDP connection
set cbr_(3) [new Application/Traffic/CBR]
$cbr_(3) attach-agent $udp_(3)
$cbr_(3) set packetSize_ $val(packetSize)
$cbr_(3) set rate_ 0
$cbr_(3) set random_ 1					

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

proc controlflux { cbrflux starttime stoptime } {
	set ns [Simulator instance]
	if {[$cbrflux set rate_] > 0} {
		$ns at $starttime "$cbrflux start"
		$ns at $stoptime "$cbrflux stop"
	}
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

	set sortie "$now\t[$cbr_(3) set rate_]\t"
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

controlflux $cbr_(1) 5.0 [expr $val(stop)-5.0]

set MyRng [new RNG]
$MyRng seed 0
set rUni [new RandomVariable/Uniform]
$rUni use-rng $MyRng
$rUni set min_ 0.0
$rUni set max_ 1000.0

proc increase_find {starttime stoptime i} {
	global arguments cbr_ rUni
	set ns [Simulator instance]
	set cbr3rate [expr $arguments(-f2start)+$i*($arguments(-f2stop)-$arguments(-f2start))/20]
	$cbr_(3) set rate_ $cbr3rate

	controlflux $cbr_(3) $starttime $stoptime

	$ns at $stoptime "$cbr_(3) set rate_ 0"
	set nextstarttime [expr $starttime+50]
	set nextstoptime [expr $stoptime+50]
	set nexti [expr $i+1]
	if {$i<20} {
		#Re-schedule the procedure
		$ns at [expr $stoptime] "increase_find $nextstarttime $nextstoptime $nexti"
	}
}

$ns at 100.0 "increase_find 100 150 0"

$ns run

