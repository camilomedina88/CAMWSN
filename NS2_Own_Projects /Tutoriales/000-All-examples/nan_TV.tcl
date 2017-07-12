# Define options
set val(chan)	Channel/WirelessChannel
set val(prop)	Propagation/TwoRayGround
set val(ant)	Antenna/OmniAntenna
set val(ll)	LL
set val(ifq)	Queue/DropTail/PriQueue
set val(ifqlen) 200
set val(netif)	Phy/WirelessPhy/OFDM
set val(mac)	Mac/802_11
set val(mac1)	Mac/802_16/BS
set val(mac2)	Mac/802_16/SS
set val(rp)	AODV
set val(nn)	100
set val(pu)	2
set val(x)	1000
set val(y)	1000
set val(stop)	240

# Define debug values
Mac/802_16 set debug_ 1
Mac/802_16 set rtg_ 10
Mac/802_16 set ttg_ 10
Mac/802_16 set frame_duration_ 0.010
Mac/802_16 set client_timeout_ 100 ;#to avoid BS disconnecting the SS since the traffic starts a 100s
Mac/802_16 set scan_duration_ 50
Phy/WirelessPhy/OFDM set g_ 0

Phy/WirelessPhy set freq_ 470e+6
Phy/WirelessPhy set CSThresh_ 1.0e-13
Phy/WirelessPhy set RXThresh_ 3.981072e-13
Phy/WirelessPhy set bandwidth_ 18e6

Mac/802_11 set basicRate_ 11Mb
Mac/802_11 set dataRate_ 11Mb
Mac/802_11 set bandwidth_ 11Mb

# Procedure finish
proc finish {} {
	global ns_ tracefd
	$ns_ flush-trace
	close $tracefd
	exit 0
}

# Create simulator
set ns_ [new Simulator]

# Open files for trace
set tracefd [open out-nan_TV.tr w]
$ns_ trace-all $tracefd


# Create topography
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

# Create GOD
set god_ [create-god [expr 3+$val(nn)+$val(pu)]]	;#number of smart meter + BS + billing center

# Create PU [regardless of mac]
$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac) -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -channelType $val(chan) -topoInstance $topo -wiredRouting OFF -agentTrace ON -routerTrace ON -macTrace ON -movementTrace OFF

set n(0) [$ns_ node]
$n(0) set recordIfall 1
$n(0) set SingleIfMultiChan 1
$n(0) random-motion 0		;# disable random motion
$n(0) set isprimaryuser 1

$ns_ node-config -macType $val(mac) -wiredRouting OFF -macTrace ON

for {set i 1} {$i < [expr $val(pu)+1]} {incr i} {
	set n($i) [$ns_ node]
        $n($i) set recordIfall 1
	$n($i) set SingleIfMultiChan 1
	$n($i) random-motion 0		;# disable random motion
	$n($i) set isprimaryuser 1
	$n($i) base-station [AddrParams addr2id [$n(0) node-addr]]
}
$n(0) set Pt_ 10.0

set pudp(0) [new Agent/UDP]
set psink(0) [new Agent/LossMonitor]
$ns_ attach-agent $n(0) $pudp(0)
$ns_ attach-agent $n(1) $psink(0)
$ns_ connect $pudp(0) $psink(0)
set ptraffic(0)  [new Application/Traffic/CBR]
$ptraffic(0) set packetSize_ 512
$ptraffic(0) set rate_ 50
$ptraffic(0) attach-agent $pudp(0)

set pudp(1) [new Agent/UDP]
set psink(1) [new Agent/LossMonitor]
$ns_ attach-agent $n(0) $pudp(1)
$ns_ attach-agent $n(2) $psink(1)
$ns_ connect $pudp(1) $psink(1)
set ptraffic(1)  [new Application/Traffic/CBR]
$ptraffic(1) set packetSize_ 512
$ptraffic(1) set rate_ 50
$ptraffic(1) attach-agent $pudp(1)

puts "Loading PU acitivity file..."
source "./TV_pu_activity.tcl"

#Create SU [with wimax mac]
$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac1) -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -channelType $val(chan) -topoInstance $topo -wiredRouting OFF -agentTrace ON -routerTrace ON -macTrace ON -movementTrace OFF

set n(3) [$ns_ node]
$n(3) random-motion 0
$n(3) set isprimaryuser 0
$n(3) set Pt_ 4.0

$ns_ node-config -macType $val(mac2) -wiredRouting OFF -macTrace ON

for {set i 0} {$i < [expr $val(nn)+1]} {incr i} {
	set n([expr $i+4]) [$ns_ node]
        $n([expr $i+4]) set recordIfall 1
	$n([expr $i+4]) set SingleIfMultiChan 1
	$n([expr $i+4]) random-motion 0		;# disable random motion
	$n([expr $i+4]) set isprimaryuser 0
	$n([expr $i+4]) base-station [AddrParams addr2id [$n(3) node-addr]]
	$n([expr $i+4]) set Pt_ 4.0
}

# Load position file
source "./nan_node_position.tcl"

# Traffic between smart meter and billing center
for {set i 0} {$i < $val(nn)} {incr i} {
	set udp($i) [new Agent/UDP]
	set sink($i) [new Agent/LossMonitor]
	$ns_ attach-agent $n([expr $i+4]) $udp($i)
	$ns_ attach-agent $n(10) $sink($i)
	$ns_ connect $udp($i) $sink($i)

	set traffic($i) [new Application/Traffic/CBR]
	$traffic($i) set packetSize_ 480
	$traffic($i) set interval_ 10.0
	$traffic($i) attach-agent $udp($i)
	$ns_ at [expr ($i*2.0)+(10.0/$val(nn))] "$traffic($i) start"
}

# Tell nodes when the simulation ends
for {set i 0} {$i < [expr $val(nn)+$val(pu)+3] } {incr i} {
      $ns_ at $val(stop).0 "$n($i) reset"; 
}

puts "Starting simulation..."
$ns_ at $val(stop) "finish"
$ns_ at $val(stop).001 "puts \"NS Exiting...\"; $ns_ halt"
$ns_ run
