# 
# Attempt to reproduce hidden node problem
#

set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             3                          ;# number of mobilenodes
set val(rp)             AODV ;# routing protocol
set val(x)              1000   ;# X dimension of the topography
set val(y)              300   ;# Y dimension of the topography


set rate 6Mb

# =====================================================================
# Main Program
# ======================================================================



#
# Initialize Global Variables
#
set ns_		[new Simulator]


Mac/802_11 set dataRate_ 11Mb
# disable RTS/CTS 
Mac/802_11 set RTSThreshold_ 3000

#puts [Phy/WirelessPhy set CPTresh_]
#puts [Phy/WirelessPhy set CSTresh_]
#puts [Phy/WirelessPhy set RXTresh_]

#Phy/WirelessPhy set CSTresh_ 5.659e-11 ;#400 meter range
Phy/WirelessPhy set RXThresh_ 3.65262e-10;#250 meter range/ =default
#Phy/WirelessPhy set CSThresh_ 3.0e-11 ;#467 meter range, < 2*rx range
Phy/WirelessPhy set CSThresh_ 5.659e-11 ;




#set data rate
set tracefd     [open simple2.tr w]
set nametracewl     [open simple-wl2.nam w]

# new trace format for proper parse
$ns_ use-newtrace
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $nametracewl $val(x) $val(y)
 
$ns_ color 1 RED 
# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
create-god $val(nn)

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 
#  Here two nodes are created : node(0) and node(1)

# configure node

        $ns_ node-config -adhocRouting $val(rp) \
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
			 -movementTrace OFF			
			 
	#set step  [lindex $argv 0]
	set step  220
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
		puts [expr $i*$step + 10.0]
		$node_($i) set X_ [expr $i*$step + 10.0]
		$node_($i) set Y_ 150.0
		$node_($i) set Z_ 0.0
		$ns_ at 0.000001 "$node_($i) setdest [expr $i*$step + 10.0] 150.0 1.0"
	}
	#$node_(0) set X_ 30

	puts "for done"



	
#  1 --> 2 	
	set udp12 [new Agent/UDP]
	$ns_ attach-agent $node_(1) $udp12

	set cbr12 [new Application/Traffic/CBR]
	$cbr12 attach-agent $udp12
	$cbr12 set rate_ 1Mb
	$udp12 set packetSize_ 1460
	$cbr12 set packetSize_ 1460

	set null12 [new Agent/Null]
	$ns_ attach-agent $node_(2) $null12
	$ns_ connect $udp12 $null12
	$ns_ at 0.1 "$cbr12 start"
	$ns_ at 0.3 "$cbr12 stop"	
	



$ns_ at 0.4 "set2"

proc set2 {} {
	global ns_
	global node_
#  1 --> 0 
	set udp10 [new Agent/UDP]
$ns_ attach-agent $node_(1) $udp10

set cbr10 [new Application/Traffic/CBR]
$cbr10 attach-agent $udp10
$cbr10 set rate_ 1Mb
$udp10 set packetSize_ 1460
$cbr10 set packetSize_ 1460

set null10 [new Agent/Null]
$ns_ attach-agent $node_(0) $null10
$ns_ connect $udp10 $null10
$ns_ at 0.4 "$cbr10 start"
$ns_ at 0.6 "$cbr10 stop"

}

# Some agents.
#  0 --> 1 
set udp01 [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp01

set cbr01 [new Application/Traffic/CBR]
$cbr01 attach-agent $udp01
$cbr01 set rate_ $rate
$udp01 set packetSize_ 1460
$cbr01 set packetSize_ 1460

set null01 [new Agent/Null]
$ns_ attach-agent $node_(1) $null01
$ns_ connect $udp01 $null01
$ns_ at 1 "$cbr01 start"

# 2 --> 1
set udp21 [new Agent/UDP]
$ns_ attach-agent $node_(2) $udp21

set cbr21 [new Application/Traffic/CBR]
$cbr21 attach-agent $udp21
$cbr21 set rate_ $rate
$udp21 set packetSize_ 1460
$cbr21 set packetSize_ 1460

set null21 [new Agent/Null]
$ns_ attach-agent $node_(1) $null21
$ns_ connect $udp21 $null21
$ns_ at 1 "$cbr21 start"





set stop_time 30.0

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $stop_time "$node_($i) reset";
}
$ns_ at $stop_time "stop"
$ns_ at [expr $stop_time +0.1] "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    global ns_ nametracewl
    $ns_ flush-trace
    close $tracefd
    close $nametracewl 
	puts "done";
}

puts "Starting Simulation..."
$ns_ run

