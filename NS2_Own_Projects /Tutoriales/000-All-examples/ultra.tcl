source cmu/mobile_node.tcl
source cmu/dsdvnode.tcl

Trace set show_tcphdr_ 1

LL set delay_ 5us

Agent/TCP set packetSize_ 1460

NetHold	set offset_	[Classifier set offset_]
NetHold set shift_	[Classifier/Addr set shift_]
NetHold	set mask_	[Classifier/Addr set mask_]
NetHold set ifq_maxlen_	50


set opt(ifq)		Queue/DropTail
set opt(ifqsize)	50
set opt(prop)		Propagation/TwoRayGround
set opt(chan)		Channel
set opt(netif)		NetIf/WaveLAN
set opt(ll)		LL
#set opt(mac)		Mac/802_3
set opt(mac)		Mac/802_11
set opt(tr)		out.tr
set opt(nc)		1		;# Number of Channels
set opt(nn)		50		;# Number of Nodes
set opt(stop)		900.0		;# seconds
set opt(routes)		Static
set opt(movement)       500x500-1.0-1

Simulator instproc mobile-node { chan } {
	global ns_ prop tracefd topo opt

	set node [new DSDVNode $tracefd]	;# create a mobile node
#	$node mobile_ 0				;# enable mobility
#	$node forwarding_ 0			;# not a router
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

	$node add-if $chan $prop $tracefd $opt(ll) $opt(mac)

	return $node
}


proc getopt {argc argv} {
	global opt
	lappend optlist tr stop num seed tmp
	lappend optlist qsize bw delay ll ifq mac chan tp sink source cbr
        lappend optlist movement

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
	exit 1
}

getopt $argc $argv

#
# Initialize Global Variables
#
set ns_		[new Simulator]
set prop	[new $opt(prop)]
set tracefd	[open $opt(tr) w]
set topo	[new Topography]

set godtrace     [new Trace/Generic]
$godtrace target [$ns_ set nullAgent_]
$godtrace attach $tracefd

set god_        [new God]
$god_ num_nodes $opt(nn)
$god_ tracetarget $godtrace

set dsdvtrace     [new Trace/Generic]
$dsdvtrace target [$ns_ set nullAgent_]
$dsdvtrace attach [open /dev/null w]

#
# The following creates a flat grid that is 100m X 100m
#
# now 500mx500m
$topo load_flatgrid 500 500

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

    [$node($i) set forwarder_] tracetarget $dsdvtrace
    $ns_ at 0.0 "$node($i) start-dsdv"
}

$ns_ at $opt(stop) "exit"

source cmu/scenarios/$opt(movement)
source cmu/scenarios/COMMPATTERN

$ns_ run
