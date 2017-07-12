# #of nodes = 10, maxspeed = 20m/s, simulation time = 1000
# ======================================================================
# Default Script Options
# ======================================================================
set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
set opt(netif)		Phy/WirelessPhy
set opt(mac)		Mac/802_11
set opt(ifq)		Queue/DropTail/PriQueue	;# for AODV/DSDV
#set opt(ifq)           CMUPriQueue   ;for dsr
set opt(ll)		LL
set opt(ant)            Antenna/OmniAntenna

set opt(x)		1000		;# X dimension of the topography
set opt(y)		1000		;# Y dimension of the topography
set opt(cpTCP)		"tcp-50-test-10000"
set opt(cpCBR)          "cbr-50-test-10000"
set opt(sc)	   	"scen-50-1000*1000-10000"
set opt(ifqlen)		50		;# max packet in ifq
set opt(nn)	        10 		;# number of nodes
set opt(seed)		0.0
set opt(stop)		1000.0		;# simulation time
set opt(tr)		aodv_trace.tr		;# trace file
set opt(rp)             AODV	;# routing protocol script (dsr or aodv)
set opt(lm)             "on"		;# log movement
set opt(type)		""
# ======================================================================
#set AgentTrace			ON
#set RouterTrace		ON
#set MacTrace			ON
#set MovementTrace_             ON

Agent/TCP set packetSize_	1000 ;# 1460   ;# the default packet size is set to 1000

# ======================================================================

proc usage {}  {
	global argv0 

	puts "\nUsage: $argv0 \[-type tcp|cbr\] \[-nn nodes\] \[-stop time\]\n"
}


proc getopt {argc argv} {
	global opt
	lappend optlist cp nn seed sc stop tr x y

	for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $argv $i]
		puts " reading the command arguments"
		if {[string range $arg 0 0] != "-"} continue

		puts "reading arguments"
		set name [string range $arg 1 end]
		set opt($name) [lindex $argv [expr $i+1]]
	}
}


# log nodes' movement every 0.1 seconds
#proc log-movement {} {
#    global logtimer ns_ 

#    set ns $ns_
#    source /usr/ns/ns-allinone-2.27/ns-2.27/tcl/mobility/timer.tcl
#    Class LogTimer -superclass Timer
#    LogTimer instproc timeout {} {
#	global opt node_;
#	for {set i 0} {$i < $opt(nn)} {incr i} {
#	    $node_($i) log-movement
#	}
#	$self sched 0.1
#    }

#    set logtimer [new LogTimer]
#    $logtimer sched 0.1
#}

# ======================================================================
# Main Program
# ======================================================================

#source ../lib/ns-cmutrace.tcl
#source /usr/ns/ns-allinone-2.27/ns-2.27/tcl/lib/ns-bsnode.tcl
#source /usr/ns/ns-allinone-2.27/ns-2.27/tcl/mobility/com.tcl

getopt $argc $argv

if { $opt(type) == "" } {
	usage
	exit
}

if { $opt(x) == 0 || $opt(y) == 0 } {
	puts "not a valid grid"
	exit 1
}

if {$opt(seed) > 0} {
	puts "Seeding Random number generator with $opt(seed)\n"
	ns-random $opt(seed)
}

if {$opt(nn) == 10 } {
	set opt(sc) "scen-$opt(nn)-670*670-$opt(stop)"
	set opt(x) 670
	set opt(y) 670
}

if {$opt(nn) == 50 } {
	set opt(sc) "scen-$opt(nn)-1000*1000-$opt(stop)"
	set opt(x) 1000
	set opt(y) 1000
}

puts "opt(sc) : $opt(sc)"
puts "opt(x): $opt(x)"
puts "opt(y): $opt(y)"

set opt(cpCBR) "cbr-$opt(nn)-test-$opt(stop)"
set opt(cpTCP) "tcp-$opt(nn)-test-$opt(stop)"

puts "opt(cpCBR): $opt(cpCBR)"
puts "opt(cpTCP): $opt(cpTCP)"


#
# create simulation instance
set ns_		[new Simulator]

# create topography object

set topo	[new Topography]
$topo load_flatgrid $opt(x) $opt(y)

# trace 
set tracefd	[open $opt(tr) w]
#$ns_ use-newtrace
$ns_ trace-all $tracefd


# -----------create god ------------------#
set god_ [create-god $opt(nn)]


# Initialize Global Variables
set chan	[new $opt(chan)]

#if {$opt(lm) == "on"} {
# log-movement
#}

# global node setting
$ns_ node-config -adhocRouting $opt(rp) \
		-llType $opt(ll) \
		-macType $opt(mac) \
		-ifqType $opt(ifq) \
		-ifqLen  $opt(ifqlen) \
		-antType $opt(ant) \
		-propType $opt(prop) \
		-phyType $opt(netif) \
		-topoInstance $topo \
		-channel [new $opt(chan)] \
        	-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-movementTrace ON 


for {set i 0} {$i < $opt(nn)} {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0  ;#disable random motion
}

# the attack lasts for 50 seconds
 puts "start blackhole attack"
$ns_ at 100.0 "[$node_(0) set ragent_] blackhole 4"
$ns_ at 150.0 "[$node_(0) set ragent_] blackhole stop"

#
# Source the Connection and Movement scripts
#
	puts "Loading connection pattern..."
	if {$opt(type) == "tcp"} {
	   source $opt(cpTCP)
	} else {
	   source $opt(cpCBR)
	}


        puts "Loading scenario file..."
        source $opt(sc)
        puts "Load complete..."


#for {set i 0} {$i < $opt(nn)} { incr i} {
#set neighbors [$node_($i) neighbors]
#puts "Before the call"
#foreach nb $neighbors {
#    puts "The neighbors for node $i are: "    
#    puts [$nb id]
#}
#puts "After the call"
#}

#
# Tell all the nodes when the simulation ends
#
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).000000001 "$node_($i) reset";
}
$ns_ at $opt(stop).00000001 "puts \"NS EXITING...\" ; $ns_ halt"


puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp $opt(rp)"
if {$opt(type) == "tcp"} {
   puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cpTCP) seed $opt(seed)"
} else {
   puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cpCBR) seed $opt(seed)"
}
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"

puts "Starting Simulation..."
$ns_ run

