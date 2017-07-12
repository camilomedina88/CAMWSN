# 
# copy-paste from simple-wireless
#

set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             5                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)              3000   ;# X dimension of the topography
set val(y)              300   ;# Y dimension of the topography

# =====================================================================
# Main Program
# ======================================================================


set a [lindex $argv 0]
set b [lindex $argv 1]
set c [lindex $argv 2]
puts $argv
if {[string length $a ]} {
set rate $a
puts $a
} else {
set rate 1.6Mb
puts def
}
if {[string length $b ]} {puts bOk } else {set b 250}

#
# Initialize Global Variables
#
set ns_		[new Simulator]
puts [Mac/802_11 set dataRate_]
Mac/802_11 set dataRate_ 11Mb
puts [Mac/802_11 set dataRate_]
# disable RTS/CTS 
if {[string length $c ]} { puts CTS} else { Mac/802_11 set RTSThreshold_ 3000
	puts NOCTS
}


#set data rate
set tracefd     [open raw/strait.$rate.$b.$c w]
set nametracewl     [open simple-wl.nam w]

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
	set step  $b
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
		puts [expr $i*$step + 10.0]
		$node_($i) set X_ [expr $i*$step + 10.0]
		$node_($i) set Y_ 150.0
		$node_($i) set Z_ 0.0
		$ns_ at 0.000001 "$node_($i) setdest [expr $i*$step + 10.0] 150.0 1.0"

		

	}
	puts [$node_(0) info vars]

	puts "for done"



# Some agents.
set udp0 [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp0

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$udp0 set class_ 0
$udp0 set fid_ 1 
#$cbr0 set  rate_ 3m
$cbr0 set rate_ $rate
$udp0 set packetSize_ 1000
$cbr0 set packetSize_ 1000

set null0 [new Agent/Null]
$ns_ attach-agent $node_([expr $val(nn)-1]) $null0
$ns_ connect $udp0 $null0
$ns_ at 0.0001 "$cbr0 start"


set stop_time 15.0

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

