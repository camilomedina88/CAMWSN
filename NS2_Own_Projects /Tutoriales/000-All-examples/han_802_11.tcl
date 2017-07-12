#Define options
set val(chan)	Channel/WirelessChannel
set val(prop)	Propagation/TwoRayGround
set val(netif)	Phy/WirelessPhy
set val(ant)	Antenna/OmniAntenna
set val(rp)	AODV
set val(ifq)	Queue/DropTail/PriQueue
set val(ifqlen)	50
#set val(mac)	Mac/802_11
#set val(mac)	Mac/Simple	;# Without control packets. Transmit whenever find idle channel
set val(mac)	Mac/Macng	;# For single-interface multi-channel functionality
set val(ll)	LL
set val(pu)	8
set val(nn)	14
set val(ni)	1
set val(channum) 10
set val(x)	100
set val(y)	100
set val(stop)	240

#Procedure finish
proc finish {} {
	global ns_ tracefd
	$ns_ flush-trace
	close $tracefd
	exit 0
}

#Create simulator
set ns_ [new Simulator]

#Open files for trace
set tracefd [open out-han_802.11.tr w]
$ns_ trace-all $tracefd

#Create topography
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

#Create GOD
set god_ [create-god [expr ($val(pu)+$val(nn)+1)*$val(ni)]] ;# Number of PU + number of SU + smart meter

#Node-configuration (802.11)
$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac) -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -topoInstance $topo -agentTrace ON -routerTrace ON -macTrace ON -movementTrace ON

#Create multiple-channels
for {set i 0} {$i < [expr $val(ni)*$val(channum)]} {incr i} {
	set chan_($i) [new $val(chan)]
}

$ns_ node-config -ifNum $val(ni) -ChannelNum $val(channum) -channel $chan_(0) 

for {set i 0} {$i < [expr $val(ni)*$val(channum)]} {incr i} {
	$ns_ add-channel $i $chan_($i)
}

#Create nodes
for {set i 0} {$i < [expr $val(pu)+$val(nn)+1]} {incr i} {
	set n($i) [$ns_ node]
        $n($i) set recordIfall 1	;# Measure interference 
	$n($i) set SingleIfMultiChan 1	;# From simple mac : enable single-interface multi-channel
	$n($i) random-motion 0		;# Disable random motion
}

#Position of the nodes
source "./node_position.tcl"

#SU: CBR with packet size 480 bytes (residential meter data size)
for {set i 0} {$i < $val(nn)} {incr i} {
	set udp($i) [new Agent/UDP]
	set sink($i) [new Agent/LossMonitor]
	$ns_ attach-agent $n([expr $i + $val(pu)]) $udp($i)
	$ns_ attach-agent $n([expr $val(nn)+$val(pu)]) $sink($i)
	$ns_ connect $udp($i) $sink($i)

	set traffic($i) [new Application/Traffic/CBR]
	$traffic($i) set packetSize_ 480
	$traffic($i) set interval_ 2.5
	$traffic($i) attach-agent $udp($i)
	$ns_ at [expr ($i*1.0)+(10.0/$val(nn))] "$traffic($i) start"
}

#PU1 (802.11): CBR traffic
for {set i 0} {$i<$val(pu)} {incr i 2} {
	if {$i==0} {
		$n($i) set chanis [expr $i % $val(channum)]
		$n([expr $i+1]) set chanis [expr $i % $val(channum)]

		set pudp($i)  [new Agent/UDP]
		set psink($i) [new Agent/LossMonitor]
		$ns_ attach-agent $n($i) $pudp($i)
		$ns_ attach-agent $n([expr $i+1]) $psink($i)
		$ns_ connect $pudp($i) $psink($i)
		set ptraffic($i)  [new Application/Traffic/CBR]
		$ptraffic($i) set packetSize_ 512
		$ptraffic($i) set rate_ 50
		$ptraffic($i) attach-agent $pudp($i)
	} elseif {$i==2} {
		$n($i) set chanis [expr $i % $val(channum)]
		$n([expr $i+1]) set chanis [expr $i % $val(channum)]

		set pudp([expr $i-1])  [new Agent/UDP]
		set psink([expr $i-1]) [new Agent/LossMonitor]
		$ns_ attach-agent $n($i) $pudp([expr $i-1])
		$ns_ attach-agent $n([expr $i+1]) $psink([expr $i-1])
		$ns_ connect $pudp([expr $i-1]) $psink([expr $i-1])
		set ptraffic([expr $i-1])  [new Application/Traffic/CBR]
		$ptraffic([expr $i-1]) set packetSize_ 512
		$ptraffic([expr $i-1]) set rate_ 50
		$ptraffic([expr $i-1]) attach-agent $pudp([expr $i-1])
	} elseif {$i==4} {
		$n($i) set chanis [expr $i % $val(channum)]
		$n([expr $i+1]) set chanis [expr $i % $val(channum)]

		set pudp([expr $i-2])  [new Agent/UDP]
		set psink([expr $i-2]) [new Agent/LossMonitor]
		$ns_ attach-agent $n($i) $pudp([expr $i-2])
		$ns_ attach-agent $n([expr $i+1]) $psink([expr $i-2])
		$ns_ connect $pudp([expr $i-2]) $psink([expr $i-2])
		set ptraffic([expr $i-2])  [new Application/Traffic/CBR]
		$ptraffic([expr $i-2]) set packetSize_ 512
		$ptraffic([expr $i-2]) set rate_ 50
		$ptraffic([expr $i-2]) attach-agent $pudp([expr $i-2])
	} elseif {$i==6} {
		$n($i) set chanis [expr $i % $val(channum)]
		$n([expr $i+1]) set chanis [expr $i % $val(channum)]

		set pudp([expr $i-3])  [new Agent/UDP]
		set psink([expr $i-3]) [new Agent/LossMonitor]
		$ns_ attach-agent $n($i) $pudp([expr $i-3])
		$ns_ attach-agent $n([expr $i+1]) $psink([expr $i-3])
		$ns_ connect $pudp([expr $i-3]) $psink([expr $i-3])
		set ptraffic([expr $i-3])  [new Application/Traffic/CBR]
		$ptraffic([expr $i-3]) set packetSize_ 512
		$ptraffic([expr $i-3]) set rate_ 50
		$ptraffic([expr $i-3]) attach-agent $pudp([expr $i-3])
	} elseif {$i==8} {
		$n($i) set chanis [expr $i % $val(channum)]
		$n([expr $i+1]) set chanis [expr $i % $val(channum)]

		set pudp([expr $i-4])  [new Agent/UDP]
		set psink([expr $i-4]) [new Agent/LossMonitor]
		$ns_ attach-agent $n($i) $pudp([expr $i-4])
		$ns_ attach-agent $n([expr $i+1]) $psink([expr $i-4])
		$ns_ connect $pudp([expr $i-4]) $psink([expr $i-4])
		set ptraffic([expr $i-4])  [new Application/Traffic/CBR]
		$ptraffic([expr $i-4]) set packetSize_ 512
		$ptraffic([expr $i-4]) set rate_ 50
		$ptraffic([expr $i-4]) attach-agent $pudp([expr $i-4])
	} elseif {$i==10} {
		$n($i) set chanis [expr $i % $val(channum)]
		$n([expr $i+1]) set chanis [expr $i % $val(channum)]

		set pudp([expr $i-5])  [new Agent/UDP]
		set psink([expr $i-5]) [new Agent/LossMonitor]
		$ns_ attach-agent $n($i) $pudp([expr $i-5])
		$ns_ attach-agent $n([expr $i+1]) $psink([expr $i-5])
		$ns_ connect $pudp([expr $i-5]) $psink([expr $i-5])
		set ptraffic([expr $i-5])  [new Application/Traffic/CBR]
		$ptraffic([expr $i-5]) set packetSize_ 512
		$ptraffic([expr $i-5]) set rate_ 50
		$ptraffic([expr $i-5]) attach-agent $pudp([expr $i-5])
	}
}
puts "Loading PU acitivity file..."
source "./ISM_pu_activity.tcl"

# Tell nodes when the simulation ends
for {set i 0} {$i < [expr $val(nn)+$val(pu)+1] } {incr i} {
      $ns_ at $val(stop).0 "$n($i) reset"; 
}

puts "Starting simulation..."
$ns_ at $val(stop) "finish"
$ns_ at $val(stop).001 "puts \"NS Exiting...\"; $ns_ halt"
$ns_ run
