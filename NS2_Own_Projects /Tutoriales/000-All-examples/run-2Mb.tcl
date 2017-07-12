# ======================================================================
# Default Script Options
# ======================================================================
set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
set opt(netif)		Phy/WirelessPhy
set opt(mac)		Mac/802_11
#set opt(ifq)		Queue/DropTail/PriQueue
set opt(ifq)		CMUPriQueue
set opt(ll)		LL
set opt(ant)            Antenna/OmniAntenna

set opt(x)		0		;# X dimension of the topography
set opt(y)		0		;# Y dimension of the topography
set opt(cp)		""		;# connection pattern file
set opt(sc)		""		;# scenario file
set opt(cmd)            ""              ;# shell cmd to run before ns start

set opt(progress)       4               ;# how many progress markers to show

set opt(ifqlen)		50		;# max packet in ifq
set opt(seed)		0.0
set opt(nn)             3               ;# nn
set opt(stop)           900             ;# time
set opt(ud)             50              ;# update distance
set opt(tr)		out.tr		;# trace file
set opt(rp)             ""              ;# routing protocol script
set opt(lm)             "off"           ;# log movement
set opt(imep)           "OFF"

set opt(debug)          "OFF"
set opt(errmodel)       ""            	;# for errmodel
set opt(em)             ""	      	;# set to name of errmodel file

set opt(ps)		128	      	;# cbr data pkt size
set opt(pi)		0.33	      	;# cbr data interval

set opt(usepsm)		1		;# use power saving mode
set opt(usespan)	1		;# use span election
set opt(spanopt)	1		;# use psm optimization

set opt(slaver)         ""   ;# remote drive an ad-hockey at this ip addr

# ======================================================================

set AgentTrace			ON
set RouterTrace			ON
set MacTrace		        ON

LL set delay_			0
LL set mindelay_		25us
LL set maxdelay_		50us
LL set bandwidth_		0	;# not used
LL set off_prune_		0	;# not used
LL set off_CtrMcast_		0	;# not used

Agent/CBR set sport_		0
Agent/CBR set dport_		0

Agent/TCPSink set sport_	0
Agent/TCPSink set dport_	0

Agent/TCP set sport_		0
Agent/TCP set dport_		0
Agent/TCP set packetSize_	1460

#Agent/IMEP set sport_		0
#Agent/IMEP set dport_		0

if [TclObject is-class Scheduler/RealTime] {
        Scheduler/RealTime set maxslop_ 10
}


# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set Rb_ 2.0e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6 
Phy/WirelessPhy set L_ 1.0

# the above parameters result in a nominal range of 250m
set nominal_range 250.0
set configured_range -1.0
set configured_raw_bitrate -1.0

# ======================================================================

proc finish {} {
    global ns_ tracefd
    puts "Stopping Simulation..."
    $ns_ flush-trace
    close $tracefd
    $ns_ halt
    exit 0
}

proc usage { argv0 }  {
	puts "Usage: $argv0"
	puts "\tmandatory arguments:"
	puts "\t\t\[-sc scenariofile\]"
        puts "\tmandatory, but may be set by scenario file:"
        puts "\t\t\[-x MAXX\] \[-y MAXY\]"
	puts "\toptional arguments (defaults provided by run.tcl):"
	puts "\t\t\[-cp conn pattern\] \[-nn nodes\] \[-rp routing-protocol-script\]"
	puts "\t\t\[-seed seed\] \[-stop sec\] \[-err em\] \[-tr output-tracefile\]"
        puts "\t\t see run.tcl for more options...\n"
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
	global ns_ tracefd opt

	if { $tracefd == "" } {
		return ""
	}
	set T [new CMUTrace/$ttype $atype ]
#	set T [new CMUTrace/$ttype $atype $opt(mac)]
	$T target [$ns_ set nullAgent_]
	$T attach $tracefd
        $T set src_ [$node id]

        $T node $node

	return $T
}


proc create-god { nodes } {
	global ns_ god_ tracefd

	set god_ [new God]
	$god_ num_nodes $nodes
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
if { $opt(em) == "" } {
    puts  "******: no errormodel specified."
    set opt(errmodel) "none"
} else {
    source $opt(em)
}

source tcl/lib/ns-mobilenode.tcl
if { $opt(rp) != "" } {
        source $opt(rp)
} elseif { [catch { set env(NS_PROTO_SCRIPT) } ] == 1 } {
	puts "\nenvironment variable NS_PROTO_SCRIPT not set and no -rp option provided!\n"
        usage $argv0
	exit 1
} else {
	puts "\n*** using script $env(NS_PROTO_SCRIPT)\n\n";
        source $env(NS_PROTO_SCRIPT)
}
source tcl/lib/ns-cmutrace.tcl

# read through the scenario file to see if it sets any options
if  { $opt(sc) == "" } {
    puts "\nNo scenario file specified with -sc option"
    usage $argv0
    exit 1
}
set f [open $opt(sc) r]
set r1 {^#}
set r2 {^# nodes: *([0-9]+).*time: *([0-9]+\.[0-9]+).*x: *([0-9]+\.[0-9]+).*y: *([0-9]+\.[0-9]+)}
set r3 {^# nominal range: *([0-9]+\.[0-9]+).*link bw: *([0-9]+\.[0-9]+)}
while {[gets $f line] >= 0} {
    if {[regexp $r1 $line]} {
        regexp $r2 $line junk opt(nn) opt(stop) opt(x) opt(y)
	regexp $r3 $line junk configured_range configured_raw_bitrate
    } else {
	break
    }
}
close $f
puts "read $opt(nn) as nn"
puts "read $configured_range as range, $configured_raw_bitrate as rate"

# if the scenario file set the range and/or bitrate, check to see if we
# have to adjust things
if { $configured_range > 0.0 && $configured_range != $nominal_range} {
    puts "WARNING: using code in run.tcl to set range to $configured_range"

    # set antenna gains to 12 db
    set Gt [ expr pow(10, (12 / 10))]
    set Gr [ expr pow(10, (12 / 10))]
    set Z 3  ;# antenna height in m

    set cst [Phy/WirelessPhy set CSThresh_]
    set rxt [Phy/WirelessPhy set RXThresh_]

    # assuming unity system gain (L = 1.0), required xmit power is
    # Pr = RXThresh;
    # Pt = Pr * (d^4)  / (Gt * Gr * (ht^2 * hr^2))

    set Pt [expr $rxt * pow($configured_range,4)  / ($Gt * $Gr * pow($Z,4))]

    Phy/WirelessPhy set Pt_ $Pt
    Antenna/OmniAntenna set Z_ $Z
    Antenna/OmniAntenna set Gt_ $Gt
    Antenna/OmniAntenna set Gr_ $Gr
    puts "    Set xmit power to $Pt\n"
}

# commented out by jinyang -i dont' want scen file to configure bitrate
#if { $configured_raw_bitrate > 0 } {
#    Phy/WirelessPhy set Rb_ $configured_raw_bitrate
#}

# do the getopt again in case the routing protocol file added some more
# options to look for, or the user wants to override options set by the
# scenario file
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

#
# Setup tracing
# 

$ns_ trace-all $tracefd

for {set i 1} {$i <= $opt(progress)} {incr i} {
    set t [expr $i * $opt(stop) / ($opt(progress) + 1)]
    $ns_ at $t "puts \"completed through $t secs...\""
}

$topo load_flatgrid $opt(x) $opt(y)

$prop topography $topo

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
#  Each routing protocol script is expected to have defined a proc
#  create-mobile-node that builds a mobile node and inserts it into the
#  array global $node_($i)
#
for {set i 1} {$i <= $opt(nn) } {incr i} {
    create-mobile-node $i
    $god_ new_node $node_($i)
}

#
# Source the Connection and Movement scripts
# i have to source this cp file after I created ns

if { $opt(cp) == "" } {
	puts "*** NOTE: no connection pattern specified."
        set opt(cp) "none"
} else {
	source $opt(cp)
}

#
# startup driver to send info to slaved ad-hockey
#
if { $opt(slaver) != "" } {
        puts "  Sending info to remote ad-hockey";
        AdHockeySlaver set interval_ 3.0
        set slaver [new AdHockeySlaver]
        $slaver ip-addr $opt(slaver)
        $slaver port 3636
        $ns_ at 0.1 "$slaver start"
}

#
# Tell all the nodes when the simulation ends
#
for {set i 1} {$i <= $opt(nn) } {incr i} {
    $ns_ at $opt(stop).000000001 "$node_($i) reset";
}
$ns_ at $opt(stop).00001 "puts \"NS EXITING...\" ; finish"

if { $opt(sc) == "" } {
	puts "*** NOTE: no scenario file specified."
        set opt(sc) "none"
} else {
	puts "Loading scenario file..."
	source $opt(sc)
	puts "Load complete..."
}

puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp $opt(rp)"
puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"

if { $opt(cmd) != "" } {
         puts "Executing shell command $opt(cmd) ..."
         eval exec $opt(cmd)
}

if { [Phy/WirelessPhy set Rb_] != 2.0e6 } {
	puts "\n\nWARNING!  SharedMedia bit rate set to other than 2.0e6\n"
}

puts "Starting Simulation..."

$ns_ run

