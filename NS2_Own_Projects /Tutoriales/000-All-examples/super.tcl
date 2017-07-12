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
set opt(prop)		Propagation/FreeSpace
set opt(chan)		Channel
set opt(netif)		NetIf/WaveLAN
set opt(ll)		LL
#set opt(mac)		Mac/802_3
set opt(mac)		Mac/802_11
set opt(tr)		out.tr
set opt(nc)		1		;# Number of Channels
set opt(nn)		3		;# Number of Nodes
set opt(stop)		60.0		;# seconds
set opt(routes)		Static

####
# Configurations...
#   0 = line
#   1 = cross
#   2 = "motion"
# TCP Connections
#   0 = none
#   1 = all n-1
#   2 = first-to-last [useful for motion and line]
#   3 = 1-2, 3-4 [crosses cross]
set opt(move)           0
set opt(config)         0
set opt(perup)          15
set opt(few)            3
set opt(rtabfreq)       25
set opt(spacing)        150
set opt(connection)     1

Simulator instproc mobile-node { chan } {
	global ns_ prop tracefd topo opt

	set node [new DSDVNode]		;# create a mobile node
	$node mobile_ 0				;# enable mobility
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

	$node add-if $chan $prop $tracefd $opt(ll) $opt(mac)

	return $node
}


proc getopt {argc argv} {
	global opt
	lappend optlist tr stop num seed tmp
	lappend optlist qsize bw delay ll ifq mac chan tp sink source cbr
        lappend move config perup few rtabfreq spacing connection

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

#
# The following creates a flat grid that is 100m X 100m
#
# now 1km x 1km
$topo load_flatgrid 1000 1000


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

    $node($i) set perup_ $opt(perup)
    $node($i) set few_   $opt(few)
    [$node($i) set forwarder_] set wst0_ 6
    $ns_ at 0.0 "$node($i) start-dsdv"

#    for {set j 0.1} {$j < $opt(stop)} {set j [expr $opt(rtabfreq)+$j]} {
#	$ns_ at $j "[$node($i) set forwarder_] dumprtab"
#    } 
}

# Set up TCP connections
set maxi [expr $opt(nn) - 1]
for {set i 0} {$i < $maxi } {incr i} {
    set tcp_($i) [$ns_ create-connection \
		      TCP $node($i) TCPSink $node([expr $i+1]) 0]
    $tcp_($i) set window_ 32
    
    set ftp_($i) [$tcp_($i) attach-source FTP]
    $ns_ at [expr 0.1 * $i] "puts \"Starting $ftp_($i)\" ; $ftp_($i) start"
}

$ns_ at $opt(stop) "exit"

source cmu/foo.tcl

$ns_ run
