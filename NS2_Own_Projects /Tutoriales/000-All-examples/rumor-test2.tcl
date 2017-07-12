# ======================================================================
# Default Script Options
# ======================================================================

set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
#set opt(netif)		NetIf/SharedMedia
set opt(netif)		Phy/WirelessPhy
#set opt(mac)		Mac/802_11
set opt(mac)		Mac/802_11
set opt(ifq)		Queue/DropTail/PriQueue
set opt(ll)		LL
set opt(ant)            Antenna/OmniAntenna

set opt(x)		1500	        ;# X dimension of the topography
set opt(y)		1500		;# Y dimension of the topography
#set opt(sc)		"rumor/scen2"   ;# 15 nodes
#set opt(sc)             "rumor/scene_1500x1500_540nodes"
set opt(sc)		scen2
#set opt(sc)		"rumor/scene_1000x1000_100nodes"

set opt(ifqlen)		50		;# max packet in ifq
#set opt(nn)		15		;# number of nodes
set opt(nn)		540		;# number of nodes
set opt(seed)		0.0
set opt(start_ANT)      5.0             ;#time to start ANTs
#set opt(stop)		100.0		;# simulation time
set opt(tr)		hailin-rumor.tr		;# trace file
set opt(rp)             RUMOR           ;# routing protocol script

set opt(lm)             "off"           ;# log movement
set opt(energymodel)    EnergyModel     ;
set opt(initialenergy)  1000             ;# Initial energy in Joules

# ======================================================================

set AgentTrace			OFF
set RouterTrace			OFF
set MacTrace			OFF

LL set mindelay_		50us
LL set delay_			25us
LL set bandwidth_		0	;# not used

Agent/Null set sport_		0
Agent/Null set dport_		0

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface

# Parameters produced to enable sensor's transmission distance of 100 meters
# ns/indep-utils/propagation/threshhold -m TwoRayGround -Pt 0.66 100

Phy/WirelessPhy set CPThresh_ 10.0
#Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.34125e-08
#Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.66
Phy/WirelessPhy set freq_ 9.14e+08 
Phy/WirelessPhy set L_ 1.0

#initialize Rumor parameters
Agent/RUMOR set QUERY_TTL   50
Agent/RUMOR set ANT_TTL     50

# ======================================================================

proc usage { argv0 }  {
	puts "Usage: $argv0"
	puts "\tmandatory arguments:"
	puts "\t\t\[-x MAXX\] \[-y MAXY\]"
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

proc create-god { nodes } {
	global ns_ god_ tracefd

	set god_ [new God]
	$god_ num_nodes $nodes
}

proc stop {} {
    global ns_ f
    $ns_ flush-trace
    close $f
   
}

proc printInfo {} {
    global opt ns_

#for {set i 0} {$i < $opt(nn) } {incr i} {
#	[$ns_ set rumor_instances_($i)] printEventTable 
#   }

    # note that opt(num_of_events) are indirectly  set via 
    # generate_events_queries.tcl
    puts "\n-----Parameters----------------------------------------"
    puts "num_of_events         = $opt(num_of_events)"        
    puts "num_of_ants_per_event = $opt(num_of_ants_per_event)"    
    puts "num_of_queries        = $opt(num_of_queries)" 
    puts "QUERY_TTL             = [Agent/Rumor set QUERY_TTL ]"
    puts "ANT_TTL               = [Agent/Rumor set ANT_TTL]"
    puts "--------------------------------------------------------"
    [$ns_ set rumor_instances_(0)] printVitalStatistics
}

# ======================================================================
# Main Program
# ======================================================================
getopt $argc $argv

if { $opt(x) == 0 || $opt(y) == 0 } {
	usage $argv0
	exit 1
}

if {$opt(seed) > 0} {
	puts "Seeding Random number generator with $opt(seed)\n"
	ns-random $opt(seed)
}

#Remove redundant headers to save memory and speed up our simulation
remove-all-packet-headers
add-packet-header IP Rumor Mac ARP LL

#
# Initialize Global Variables
#

set ns_		[new Simulator]
set chan	[new $opt(chan)]
set prop	[new $opt(prop)]
set topo	[new Topography]
set tracefd	[open $opt(tr) w]


set f [open trace-out-test.tr w]
$ns_ trace-all $f

$topo load_flatgrid $opt(x) $opt(y)

$prop topography $topo


# Create God
create-god $opt(nn)

$ns_ node-config -adhocRouting RUMOR \
		-llType $opt(ll) \
		-macType $opt(mac) \
		-ifqType $opt(ifq) \
		-ifqLen $opt(ifqlen) \
		-antType $opt(ant) \
		-propType $opt(prop) \
		-phyType $opt(netif) \
		-channel [new $opt(chan)] \
		-topoInstance $topo \
		-agentTrace OFF \
		-routerTrace OFF \
		-macTrace OFF \
		-toraDebug OFF \
		-movementTrace OFF \
	        -energyModel $opt(energymodel) \
		-rxPower 0.395 \
		-txPower 0.660 \
	        -idlePower 0 \
		-initialEnergy $opt(initialenergy)
    
	for {set i 0} {$i < $opt(nn) } {incr i} {
                set node_($i) [$ns_ node]
                $node_($i) random-motion 0              ;# disable random motion
	}

# setup events,  generates ANTs, and start queries

source ./input2

$ns_ at [expr $opt(stop)-5]  printInfo



# Tell all the nodes when the simulation ends

for {set i } {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).000000001 "$node_($i) reset";
}

$ns_ at $opt(stop).1 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $opt(stop) "stop"

if { $opt(sc) == "" } {
	puts "*** NOTE: no scenario file specified."
        set opt(sc) "none"
} else {
	puts "Loading scenario file..."
	source $opt(sc)
	puts "Load complete..."
}

puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp $opt(rp)"
puts $tracefd "M 0.0 sc $opt(sc) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"

puts "Starting Simulation..."

$ns_ run

