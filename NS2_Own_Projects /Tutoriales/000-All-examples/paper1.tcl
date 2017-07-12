# script for paper data gathering

source cmu/dsr/srnode.tcl

Trace set show_tcphdr_ 1
LL set delay_ 5us
Agent/TCP set packetSize_ 1460

set opt(ifq)		Queue/DropTail
set opt(ifqsize)	50
set opt(prop)		Propagation/TwoRayGround
set opt(chan)		Channel
set opt(netif)		NetIf/WaveLAN
set opt(ll)             LL
#set opt(mac)           Mac/802_3
set opt(mac)            Mac/802_11
set opt(tr)		out.tr
set opt(nc)		1		;# Number of Channels
set opt(nn)		50		;# Number of Nodes
set opt(stop)		60.0		;# seconds
set opt(rt_port)        128             ;# must agree with packet.h
set opt(seed)           0
set opt(sc)             ""
set opt(geo)            "500x500"

Simulator instproc srnode  { chan } {
    global ns_ prop tracefd topo opt
    
    set node [new SRNode $tracefd]

    $node topography $topo

    $node add-if $chan $prop $tracefd $opt(ll) $opt(mac)

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
	puts "              \[-seed int\] \[-sc scenariofile\]\n"
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

#
# The following creates a flat grid that is 100m X 1000m
#
if {$opt(geo) == "100x1500"} {
    $topo load_flatgrid 100 1500
} elseif {$opt(geo) == "500x500"} {
    $topo load_flatgrid 500 1500
} else {
    $topo load_flatgrid 100 100
}

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
    puts "Making node $i"
    set node($i) [$ns_ srnode $channel_(0)]
    $ns_ at 0.0 "$node($i) start-dsr"
}


# Set up TCP connections
source cmu/tcp-comm-pattern

$ns_ at $opt(stop) "$ns_ halt"

if {$opt(sc) != "" } { source $opt(sc) }

puts "Starting Simulation..."

$ns_ run
