#
# Verbal diarrhea...
#
# A Channel defines a physical network.  For example, if you wanted to model
# the behavior of nodes connected to an Ethernet segment, you would define
# a single channel to represent a single Ethernet segment.
#
# Similarly, if you were to designed a WaveLAN network, even with multiple
# cells, you would define a single channel as nodes in neighboring cells can
# interfere with each other.
#
# If, however, you want to model a wireless network, consisting of both
# WaveLAN and satellite hops, you would define (2) channels, one for WaveLAN
# and the other for satellite communication.
#

source cmu/mobile_node.tcl

Trace set show_tcphdr_ 1
LL set delay_ 5us
Agent/TCP set packetSize_ 1460

set opt(ifq)		Queue/DropTail
set opt(ifqsize)	50
set opt(prop)		Propagation/FreeSpace
set opt(chan)		Channel
set opt(netif)		NetIf/WaveLAN
set opt(tr)		out.tr
set opt(nc)		1		;# Number of Channels
set opt(nn)		2		;# Number of Nodes
set opt(stop)		60.0		;# seconds


Simulator instproc make-routes { iflist } {
# no static routes...

#	foreach i $iflist {
#		set src [$i node]
#		foreach j $iflist {
#			set dst [$j node]
#
#			if {$src == $dst} continue
#
#			set id [$i id]
#			set queue_ [$src get-queue $id]
#			$src add-route [$dst id] $queue_
#		}
#	}
}


Simulator instproc srnode  { chan } {
    global ns_ prop tracefd topo noroute opt
    
    set node [new SRNode]		;# create a mobile node
    $node topography $topo

    #
    # This Trace Target is used to log changes in direction
    # and velocity for the mobile node.
    #
    if {$tracefd != ""} {
	set T [new Trace/Generic]
	$T target [$ns_ set nullAgent_]
	$T attach $tracefd
	$T set src_ [$node id]
	$node tracetarget $T
    }
    
    $node add-if $chan $prop $tracefd
    
    return $node
}


Simulator instproc mobile-node { chan } {
	global ns_ prop tracefd topo noroute opt

	set node [new MobileNode]		;# create a mobile node
	$node mobile_ 1				;# enable mobility
	$node forwarding_ 0			;# not a router
	$node topography $topo

	#
	# This Trace Target is used to log changes in direction
	# and velocity for the mobile node.
	#
	if {$tracefd != ""} {
		set T [new Trace/Generic]
		$T target [$ns_ set nullAgent_]
		$T attach $tracefd
		$T set src_ [$node id]
		$node tracetarget $T
	}

	$node add-if $chan $prop $tracefd

	puts "Making routes\n"
	set cl [$node set classifier_]
	for {set i 0} {$i < $opt(nn) } {incr i} {
	    if {$i == [$node id]} continue;
	    $cl install $i $noroute
	}

	return $node
}


proc getopt {argc argv} {
	global opt
	lappend optlist tr stop num seed tmp
	lappend optlist qsize bw delay ll ifq mac chan tp sink source cbr

	for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $argv $i]
		if {[string range $arg 0 0] != "-"} continue

		set name [string range $arg 1 end]
		set opt($name) [lindex $argv [expr $i+1]]
	}
}


# *** MAIN PROGRAM ***

if {$argc == 0} {
	puts "Usage: $argv0 \[-stop sec\] \[-nn nodes\] \[-tr tracefile\]\n"
}

getopt $argc $argv

#
# Initialize Global Variables
#
set ns_		[new Simulator]
set prop	[new $opt(prop)]
set tracefd	[open $opt(tr) w]
set topo	[new Topography]

set noroute     [new Trace/Drop]
$noroute target [$ns_ set nullAgent_]
$noroute attach $tracefd
$noroute set src_ 254
$noroute set dst_ 254

#
# The following creates a flat grid that is 100m X 100m
#
$topo load_flatgrid 100 100


#
# Create the specified number of channels $opt(nc) and their
# corresponding network interfaces.
#
for {set i 0} {$i < $opt(nc) } {incr i} {
	set channel_($i) [new $opt(chan)]
	set iflist_($i) ""		;# interface list for channel $i
}


#
#  Create the specified number of nodes $opt(nn) and "attach" them
#  to channel 0.
#
for {set i 0} {$i < $opt(nn) } {incr i} {
    set node($i) [$ns_ mobile-node $channel_(0)]
    $ns_ at $i "$node($i) start"
    $node($i) set position_update_interval_ 5
}

#
# Setup the routing table for each node
#
for {set i 0} {$i < $opt(nc) } {incr i} {
	set id [$channel_($i) id]
	puts "\nMaking Channel $id Routes..."
	$ns_ make-routes $iflist_($id)
}

# Set up TCP connections
set maxi [expr $opt(nn) - 1]
for {set i 0} {$i < $maxi } {incr i} {
	set tcp_($i) [$ns_ create-connection \
			TCP $node($i) TCPSink $node([expr $i+1]) 0]
	$tcp_($i) set window_ 32

	set ftp_($i) [$tcp_($i) attach-source FTP]
	$ns_ at 0.$i "$ftp_($i) start"
}

$ns_ at $opt(stop) "$ns_ halt"

puts "Starting Simulation..."

$ns_ run
