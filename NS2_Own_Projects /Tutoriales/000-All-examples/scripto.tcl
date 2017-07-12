source mobile_node.tcl

Trace set show_tcphdr_ 1
LL set delay_ 5us
Agent/TCP set packetSize_ 1460

NetHold	set offset_	[Classifier set offset_]
NetHold set shift_	[Classifier/Addr set shift_]
NetHold	set mask_	[Classifier/Addr set mask_]
NetHold set ifq_maxlen_	50

set opt(chan)		Channel
set opt(ifq)		Queue/DropTail/PriQueue
set opt(ifqsize)	50
set opt(ll)		LL
#set opt(mac)		Mac/802_3
set opt(mac)		Mac/802_11
set opt(netif)		NetIf/WaveLAN
set opt(nn)		50		;# Number of Nodes
set opt(prop)		Propagation/TwoRayGround
set opt(ragent)		Agent/AODV
set opt(seed)		2.534985321
set opt(sc)		"scenarios/500x500-0.8-1"
set opt(stop)		70.0		;# seconds
set opt(tr)		out.tr

# ======================================================================
Agent instproc init args {
        $self next $args
}       

Agent/AODV instproc init args {
        $self next $args
}       

# ======================================================================

Simulator instproc mobile-node { chan } {
	global ns_ prop tracefd topo opt

	set node [new MobileNode $tracefd]	;# create a mobile node
	$node mobile_ 1				;# enable/disable mobility
	$node forwarding_ 1			;# enable/disable routing
	$node topography $topo

	#
	# Box Configuration
	#
	set spacing 100
	set maxrow 5
	set col [expr ([$node id] - 1) % $maxrow]
	set row [expr ([$node id] - 1) / $maxrow]
	$node set X_ [expr $col * $spacing]
	$node set Y_ [expr $row * $spacing]
	$node set Z_ 0.0
	$node set speed_ 0.0

	#
	# Straight Line Configuration
	#
#	$node set X_ [expr 100 * [$node id]]
#	$node set Y_ 150.0
#	$node set Z_ 0.0
#	$node set speed_ 0.0

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
	lappend optlist tr stop num seed sc

	for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $argv $i]
		if {[string range $arg 0 0] != "-"} continue

		set name [string range $arg 1 end]
		set opt($name) [lindex $argv [expr $i+1]]
	}
}


# *** MAIN PROGRAM ***

if {$argc == 0} {
	puts "Usage: $argv0 \[-stop sec\] \[-nn nodes\] \[-tr tracefile\] \[-seed seed\] \[-sc <source file>\]\n"
	exit 1
}

getopt $argc $argv

if {$opt(seed) > 0} {
	puts "Seeding Random number generator with $opt(seed)\n"
	ns-random $opt(seed)
}

#
# Initialize Global Variables
#
set ns_		[new Simulator]
set chan	[new $opt(chan)]
set prop	[new $opt(prop)]
set topo	[new Topography]
set tracefd	[open $opt(tr) w]

$topo load_flatgrid 2000 400  

#
# Keep track of the global routing view...
#
set godtrace     [new Trace/Generic]
$godtrace target [$ns_ set nullAgent_]
$godtrace attach $tracefd

set god_        [new God]
$god_ num_nodes $opt(nn)
$god_ tracetarget $godtrace


#
#  Create the specified number of nodes $opt(nn) and "attach" them
#  the channel.
#
for {set i 0} {$i < $opt(nn) } {incr i} {

	set node($i) [$ns_ mobile-node $chan]

	#
	#  Create the Routing Agent and attach it to port 255.
	#
	set ragent [new $opt(ragent) [$node($i) id] ]
	$node($i) attach $ragent 255

	#
	# The Routing Agent sends packets to the IFQ.
	#
	$ragent target [$node($i) get-queue 0]
#	$ragent drop-target [$node($i) set drpT_]


	$ragent if-queue [$node($i) get-queue 0]

        if {$tracefd != ""} {
                set T [new Trace/Generic]
                $T target [$ns_ set nullAgent_]
                $T attach $tracefd
                $T set src_ [$node($i) id]
#		$ragent log-target $T
        }

	#
	#  The Classifer sends all outgoing packets to the Routing Agent.
	#  The Classifer sends all incoming packets address to port 255
	#  to the routing agent.
	#
	[$node($i) set classifier_] defaulttarget $ragent

	$ns_ at 0.$i "$ragent start"	;# start BEACON/HELLO Messages
	$ns_ at 0.0 "$node($i) start"	;# start movement
}


#
# Source the connection script
#
source tcp-script

#
#  Source the Movement Scripts
#
if { $opt(sc) != "" } {
	source $opt(sc)
} else {
	puts "Error: no movement script...";
	exit;
}


$ns_ at $opt(stop) "puts \"NS EXITING...\" ; exit"

puts "Starting Simulation..."

$ns_ run

