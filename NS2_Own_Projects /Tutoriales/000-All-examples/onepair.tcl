set i 0
set have(-Mtime) "false"

while {$i<$argc} {
	switch [lindex $argv $i] {
		Mtime {
			set arguments(-Mtime) "[lindex $argv [expr {$i + 1}]]"
			set i [expr {$i + 1}]
			set have(-Mtime) "true"
		}
	}
	set i [expr {$i + 1}]
}

if {$have(-Mtime) == "false"} {
	set arguments(-Mtime) 1
}

set arguments(-scenarioname) "onepair.measuredTime.$arguments(-Mtime)"
set arguments(-tracefile) "$arguments(-scenarioname).tracefile"
set arguments(-namfile) "$arguments(-scenarioname).namfile"
set arguments(-bwfile) "$arguments(-scenarioname).bwmonitor"

puts "Scenario one pair"
puts "Measureed time : $arguments(-Mtime)"


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
set val(stop)		60				;#time of simulation end
set val(rate)		2e6				;#rate physic of medium

set ns [new Simulator]
set tracefd		[open $arguments(-tracefile) w]
set namtrace		[open $arguments(-namfile) w]
set grfd		[open $arguments(-bwfile) w]

Phy/WirelessPhy set CSThresh_ 1.55924e-11	;#CS Threshold is 550m
Phy/WirelessPhy set RXThresh_ 3.65262e-10	;#RS Threshold is 250m

Mac/802_11 set RTSThreshold_   2000
Mac/802_11 set dataRate_ $val(rate)
Mac/802_11 set basicRate_ $val(rate)
Mac/802_11 set measuredTime $arguments(-Mtime)
Mac/802_11 set improveIAB false

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

for {set i 0} {$i < $val(nn)} {incr i} {
	set node_($i) [$ns node]
#	$node_($i) random-motion 0
}
#access routing agent of node_(0)
#set node0RT [$node_(0) set ragent_]
#set prtRT [$node0RT set desire_]
#puts "$prtRT"

#provide initial location of mobilenodes
$node_(0) set X_ 250.0
$node_(0) set Y_ 250.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 250.0
$node_(1) set Y_ 450.0
$node_(1) set Z_ 0.0

#generation of movements
#$ns at 10.0 "$node_(0) setdest 250.0 250.0 3.0"

#setup a UDP connection between node_(0) and node_(1)
set udp_(0) [new Agent/UDP]
$ns attach-agent $node_(0) $udp_(0)
set recv_(1) [new Agent/LossMonitor]
$ns attach-agent $node_(1) $recv_(1)
$ns connect $udp_(0) $recv_(1)
$udp_(0) set fid_ 1

#setup a CBR over UDP connection
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) attach-agent $udp_(0)
$cbr_(0) set packetSize_ 1000
$cbr_(0) set rate_ 0
$cbr_(0) set random_ 1

#define node initial position in nam
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns initial_node_pos $node_($i) 30
}

#telling nodes when the simulation ends
for {set i 0} {$i < $val(nn)} {incr i} {
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
	global recv_ grfd node_
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

	set sortie "$now"
	foreach item [array names bw_] {
		#set sortie "$sortie recv_($item) [expr $bw_($item)/$time*8/1000] $pk_($item)"
		#set sortie "$sortie \t[expr $item/1]"
		set sortie "$sortie \t[expr $bw_($item)/$time*8/1000]"
	}

	#puts $grfd "$sortie (TOT) $somme_bw $somme_pk"; #[expr $pos2 - $pos1]"
	puts $grfd "$sortie \tTOT \t$somme_bw"
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
$ns at 0.0 "$cbr_(0) set rate_ 38e4"
$ns at 0.0 "$cbr_(0) start"
$ns at 22.5 "$cbr_(0) stop"
$ns at 22.5 "$cbr_(0) set rate_ 15e4"
$ns at 22.5 "$cbr_(0) start"
$ns at 43.5 "$cbr_(0) stop"
$ns at 43.5 "$cbr_(0) set rate_ 38e4"
$ns at 43.5 "$cbr_(0) start"
$ns at $val(stop) "$cbr_(0) stop"

$ns at 0.0 "[$node_(0) getMac 0] show-measured-bandwidth"
$ns at 0.0 "[$node_(1) getMac 0] show-measured-bandwidth"
$ns run

