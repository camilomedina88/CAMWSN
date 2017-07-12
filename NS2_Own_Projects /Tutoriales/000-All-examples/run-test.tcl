# ======================================================================
# Default Script Options
# ======================================================================
set opt(chan)		Channel
set opt(prop)		Propagation/TwoRayGround
set opt(netif)		NetIf/WaveLAN
set opt(mac)		Mac/802_11
set opt(ifq)		Queue/DropTail/PriQueue
set opt(ll)		LL

set opt(x)		0		;# X dimension of the topography
set opt(y)		0		;# Y dimension of the topography
set opt(cp)		""		;# connection pattern file
set opt(sc)		""		;# scenario file

set opt(ifqlen)		50		;# max packet in ifq
set opt(nn)		50		;# number of nodes
set opt(seed)		0.0
set opt(stop)		900.0		;# simulation time
set opt(tr)		out.tr		;# trace file
set opt(rp)             ""              ;# routing protocol script
set opt(lm)             "off"           ;# log movement

# ======================================================================

set AgentTrace			ON
set RouterTrace			ON
set MacTrace			ON

LL set delay_			5us
LL set bandwidth_		0	;# not used
LL set off_prune_		0	;# not used
LL set off_CtrMcast_		0	;# not used

Agent/Null set sport_		0
Agent/Null set dport_		0

Agent/CBR set sport_		0
Agent/CBR set dport_		0

Agent/TCPSink set sport_	0
Agent/TCPSink set dport_	0

Agent/TCP set sport_		0
Agent/TCP set dport_		0
Agent/TCP set packetSize_	1460

# ======================================================================

proc usage { argv0 }  {
	puts "Usage: $argv0"
	puts "\tmandatory arguments:"
	puts "\t\t\[-x MAXX\] \[-y MAXY]\]"
	puts "\toptional arguments:"
	puts "\t\t\[-cp conn pattern\] \[-sc scenario\] \[-nn nodes\]"
	puts "\t\t\[-seed seed\] \[-stop sec\] \[-tr tracefile\]\n"
}


proc getopt {argc argv} {
	global opt
	lappend optlist cp nn seed sc stop tr x y

	for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $argv $i]
		if {[string range $arg 0 0] != "-"} continue

		set name [string range $arg 1 end]
		set opt($name) [lindex $argv [expr $i+1]]
	}
}


proc cmu-trace { ttype atype node } {
	global ns_ tracefd

	if { $tracefd == "" } {
		return ""
	}
	set T [new CMUTrace/$ttype $atype]
	$T target [$ns_ set nullAgent_]
	$T attach $tracefd
        $T set src_ [$node id]

        $T node $node

	return $T
}


proc create-god { nodes } {
	global ns_ god_ tracefd

	set godtrace     [new Trace/Generic]
	$godtrace target [$ns_ set nullAgent_]
	$godtrace attach $tracefd

	set god_        [new God]
	$god_ num_nodes $nodes
	$god_ tracetarget $godtrace
}

proc log-movement {} {
    global logtimer ns_ ns

    set ns $ns_
    source tcl/ex/timer.tcl
    Class LogTimer -superclass Timer
    LogTimer instproc timeout {} {
	global opt node_;
	for {set i 1} {$i <= $opt(nn)} {incr i} {
	    $node_($i) log-movement
	}
	$self sched 0.1
    }

    set logtimer [new LogTimer]
    $logtimer sched 0.1
}

# ======================================================================
# Main Program
# ======================================================================
getopt $argc $argv

#
# Source External TCL Scripts
#
source cmu/scripts/mobile_node.tcl
if { $opt(rp) != "" } {
        source $opt(rp)
} elseif { [catch { set env(NS_PROTO_SCRIPT) } ] == 1 } {
	puts "\nenvironment variable NS_PROTO_SCRIPT not set!\n"
	exit
} else {
	puts "\n*** using script $env(NS_PROTO_SCRIPT)\n\n";
        source $env(NS_PROTO_SCRIPT)
}
source cmu/scripts/cmu-trace.tcl

# do the get opt again incase the routing protocol file added some more
# options to look for
getopt $argc $argv

if { $opt(x) == 0 || $opt(y) == 0 } {
	usage $argv0
	exit 1
}

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

$topo load_flatgrid $opt(x) $opt(y)

#
# Create God
#
create-god $opt(nn)


#
# log the mobile nodes movements if desired
#
if { $opt(lm) == "on" } {
    log-movement
}

#
#  Create the specified number of nodes $opt(nn) and "attach" them
#  the channel.
#
for {set i 1} {$i <= $opt(nn) } {incr i} {
	create-mobile-node $i
}


#
# Source the Connection and Movement scripts
#
if { $opt(cp) == "" } {
	puts "*** NOTE: no connection pattern specified."
        set opt(cp) "none"
} else {
	source $opt(cp)
}

if { $opt(sc) == "" } {
	puts "*** NOTE: no scenario file specified."
        set opt(sc) "none"
} else {
	source $opt(sc)
}

#
# Setup some test connections
#
set cbr_(0) [$ns_ create-connection  CBR $node_(1) CBR $node_(3) 0]
$cbr_(0) set packetSize_ 1024
$cbr_(0) set interval_ 0.25
$cbr_(0) set random_ 1
$cbr_(0) set maxpkts_ 10000
$ns_ at 5.0 "$cbr_(0) start"

#set cbr_(1) [$ns_ create-connection  CBR $node_(2) CBR $node_(3) 0]
#$cbr_(1) set packetSize_ 1024
#$cbr_(1) set interval_ 0.25
#$cbr_(1) set random_ 1
#$cbr_(1) set maxpkts_ 10000
#$ns_ at 5.0 "$cbr_(1) start"

$ns_ at $opt(stop) "puts \"NS EXITING...\" ; exit"

puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp $opt(rp)"
puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"

puts "Starting Simulation..."

$ns_ run

