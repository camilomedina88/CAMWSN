#      20 Jan 2015, @billyfuad / @Muhammed Fuad  ←  mail

set stopTime 100
set BO 3
set SO 3
set speed 1
#speed is in m/s
 #======================================================================
# Default Script valions
# ======================================================================
set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
set opt(netif)		Phy/WirelessPhy/802_15_4
set opt(mac)		Mac/802_15_4
set opt(ifq)		Queue/DropTail/PriQueue	
set opt(ll)		LL
set opt(ant)            Antenna/OmniAntenna
set opt(x)		300		;# koordinat X untuk topologi
set opt(y)		300		;# koordinat Y untuk topologi
#set opt(cp)		"./cbr100.tcl"
#set opt(sc)		"./grid-deploy10x10.tcl"
set opt(ifqlen)		50		;# paket maksimal ifq
set opt(nn)		50		;# jumlah nodes
set opt(seed)		0.0
set opt(stop)		100		;# waktu simulasi
set opt(tr)		gpsr50.tr	;# trace file
set opt(nam)            gpsr50.nam
set opt(rp)             gpsr		;# routing protocol script (Greedy Perimeter Stateless Routing)
set opt(lm)             "off"		;# log movement
set opt(traffic)	cbr             ;# cbr
set opt(energy)         EnergyModel
set opt(AnH)            1.5             ;# Antenna Height
set PI                  3.1415926
set opt(Pt)             25.0 		;# Transmission Power/Range in meters
set opt(initialenergy)  1000            ;# Initial energy in Joules
# ======================================================================

LL set mindelay_		50us
LL set delay_			25us
LL set bandwidth_		0	;# not used

Agent/Null set sport_		0
Agent/Null set dport_		0

Agent/CBR set sport_		0
Agent/CBR set dport_		0

Agent/TCPSink set sport_	0
Agent/TCPSink set dport_	0

Agent/TCP set sport_		0
Agent/TCP set dport_		0
Agent/TCP set packetSize_	1460

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# Agent/GPSR setting
Agent/GPSR set planar_type_  1   ;#1=GG planarize, 0=RNG planarize
Agent/GPSR set hello_period_   5.0 ;#Hello message period


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
Phy/WirelessPhy set CSThresh_ 8.91754e-10  ;#sensing range of 200m
Phy/WirelessPhy set RXThresh_ 8.91754e-10  ;#communication range of 200m
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set freq_ 914e+6 
Phy/WirelessPhy set L_ 1.0


# The transimssion radio range 
#Phy/WirelessPhy set Pt_ 6.9872e-4    ;# ?m
#Phy/WirelessPhy set Pt_ 8.5872e-4    ;# 40m
#Phy/WirelessPhy set Pt_ 1.33826e-3   ;# 50m
#Phy/WirelessPhy set Pt_ 7.214e-3     ;# 100m
Phy/WirelessPhy set Pt_ 0.2818       ;# 250m
#Phy/WirelessPhy set Pt_ 2.28289e-11 ;# 500m
# ======================================================================

#yang dihapus new

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

set appTime1            2.0	;# in seconds 
set appTime2            2.1	;# in seconds 
set appTime3            2.2	;# in seconds 
set appTime4            2.3	;# in seconds 
set appTime5            2.4	;# in seconds 
set stopTime            100	;# in seconds 


#======================================================================
# Parameter untuk 802.11p
#======================================================================

Mac/802_15_4 put-nam-traceall (# nam4wpan #)	;# inform nam that this is a trace file for wpan (special handling needed)
Mac/802_15_4 wpanCmd verbose on
Mac/802_15_4 wpanNam namStatus on	;# default = off (should be turned on before other 'wpanNam' commands can work)
#Mac/802_15_4 wpanNam ColFlashClr gold	;# default = gold
Mac/802_15_4 wpanNam PANCoorClr tomato
Mac/802_15_4 wpanNam CoorClr blue
Mac/802_15_4 wpanNam DevClr green
# For model 'TwoRayGround'
set dist(5m)  7.69113e-06
set dist(9m)  2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07
set dist(100m) 7.214e-3
set dist(500m) 2.28289e-11

Phy/WirelessPhy set CSThresh_ $dist(500m)
Phy/WirelessPhy set RXThresh_ $dist(500m)
# ======================================================================

# ======================================================================


#proc cmu-trace { ttype atype node } {
#	global ns_ tracefd
#
#        puts ABC
#	if { $tracefd == "" } {
#		return ""
#	}
#	puts BCD
#	set T [new CMUTrace/$ttype $atype]
#	$T target [$ns_ set nullAgent_]
#	$T attach $tracefd
#        $T set src_ [$node id]
#	
#        $T node $node
#
#	return $T
#}


# ======================================================================
# Main Program
# ======================================================================
#
# Source External TCL Scripts
#
#source ../lib/ns-mobilenode.tcl

#if { $opt(rp) != "" } {
	#source ../mobility/$opt(rp).tcl
	#} elseif { [catch { set env(NS_PROTO_SCRIPT) } ] == 1 } {
	#puts "\nenvironment variable NS_PROTO_SCRIPT not set!\n"
	#exit
#} else {
	#puts "\n*** using script $env(NS_PROTO_SCRIPT)\n\n";
        #source $env(NS_PROTO_SCRIPT)
#}
#source ../tcl/lib/ns-cmutrace.tcl
#source ../tcl/lib/ns-bsnode.tcl
#source ../tcl/mobility/com.tcl

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


set tracefd   [open $opt(tr) w]
$ns_ trace-all  $tracefd

set namfile [open $opt(nam) w]
$ns_ namtrace-all-wireless $namfile $opt(x) $opt(y)

$topo load_flatgrid $opt(x) $opt(y)

$prop topography $topo

#
# Create God
set god_ [create-god $opt(nn)]
set chan_1_ [new $opt(chan)]
#
 
proc UniformErr {} {
set erm [new ErrorModel]
$erm unit packet
$erm set rate_ 0.5
$erm ranvar [new RandomVariable/Uniform]
$erm drop-target [new Agent/Null]
return $erm
}


#
#  Create the specified number of nodes $opt(nn) and "attach" them
#  the channel.
#  Each routing protocol script is expected to have defined a proc
#  create-mobile-node that builds a mobile node and inserts it into the
#  array global $node_($i)

#configure node
$ns_ node-config -adhocRouting gpsr \
			 -llType $opt(ll) \
			 -macType $opt(mac) \
			 -ifqType $opt(ifq) \
			 -ifqLen $opt(ifqlen) \
			 -antType $opt(ant) \
			 -propType $opt(prop) \
			 -phyType $opt(netif) \
			-channelType $opt(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace ON \
			 -movementTrace OFF \
			 -IncomingErrProc UniformErr
			 #-energyModel EnergyModel \
                		#-initialEnergy 1000 \
                		#-rxPower 0.1 \
                		#-txPower 0.1\
			-channel $chan_1_

		
source ./gpsr.tcl

for {set i 0} {$i < $opt(nn) } {incr i} {
    gpsr-create-mobile-node $i
    
}

#=======================================================================
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#=======================================================================
$node_(0) set X_ 150
$node_(0) set Y_ 300
$node_(0) set Z_ 3
$node_(1) set X_ 75
$node_(1) set Y_ 250
$node_(1) set Z_ 3
$node_(2) set X_ 150
$node_(2) set Y_ 250
$node_(2) set Z_ 3
$node_(3) set X_ 225
$node_(3) set Y_ 250
$node_(3) set Z_ 3
$node_(4) set X_ 50
$node_(4) set Y_ 225
$node_(4) set Z_ 3
$node_(5) set X_ 250
$node_(5) set Y_ 225
$node_(5) set Z_ 3
$node_(6) set X_ 75
$node_(6) set Y_ 150
$node_(6) set Z_ 3
$node_(7) set X_ 150
$node_(7) set Y_ 150
$node_(7) set Z_ 3
$node_(8) set X_ 225
$node_(8) set Y_ 150
$node_(8) set Z_ 3
$node_(9) set X_ 50
$node_(9) set Y_ 75
$node_(9) set Z_ 3
$node_(10) set X_ 75
$node_(10) set Y_ 50
$node_(10) set Z_ 3
$node_(11) set X_ 150
$node_(11) set Y_ 50
$node_(11) set Z_ 3
$node_(12) set X_ 225
$node_(12) set Y_ 50
$node_(12) set Z_ 3
$node_(13) set X_ 250
$node_(13) set Y_ 75
$node_(13) set Z_ 3
$node_(14) set X_ 25
$node_(14) set Y_ 275
$node_(14) set Z_ 3
$node_(15) set X_ 75
$node_(15) set Y_ 275
$node_(15) set Z_ 3
$node_(16) set X_ 125
$node_(16) set Y_ 275
$node_(16) set Z_ 3
$node_(17) set X_ 175
$node_(17) set Y_ 275
$node_(17) set Z_ 3
$node_(18) set X_ 225
$node_(18) set Y_ 275
$node_(18) set Z_ 3
$node_(19) set X_ 275
$node_(19) set Y_ 275
$node_(19) set Z_ 3
$node_(20) set X_ 25
$node_(20) set Y_ 225
$node_(20) set Z_ 3
$node_(21) set X_ 75
$node_(21) set Y_ 225
$node_(21) set Z_ 3
$node_(22) set X_ 125
$node_(22) set Y_ 225
$node_(22) set Z_ 3
$node_(23) set X_ 175
$node_(23) set Y_ 225
$node_(23) set Z_ 3
$node_(24) set X_ 225
$node_(24) set Y_ 225
$node_(24) set Z_ 3
$node_(25) set X_ 275
$node_(25) set Y_ 225
$node_(25) set Z_ 3
$node_(26) set X_ 25
$node_(26) set Y_ 175
$node_(26) set Z_ 3
$node_(27) set X_ 75
$node_(27) set Y_ 175
$node_(27) set Z_ 3
$node_(28) set X_ 125
$node_(28) set Y_ 175
$node_(28) set Z_ 3
$node_(29) set X_ 175
$node_(29) set Y_ 175
$node_(29) set Z_ 3
$node_(30) set X_ 225
$node_(30) set Y_ 175
$node_(30) set Z_ 3
$node_(31) set X_ 275
$node_(31) set Y_ 175
$node_(31) set Z_ 3
$node_(32) set X_ 25
$node_(32) set Y_ 125
$node_(32) set Z_ 3
$node_(33) set X_ 75
$node_(33) set Y_ 125
$node_(33) set Z_ 3
$node_(34) set X_ 125
$node_(34) set Y_ 125
$node_(34) set Z_ 3
$node_(35) set X_ 175
$node_(35) set Y_ 125
$node_(35) set Z_ 3
$node_(36) set X_ 225
$node_(36) set Y_ 125
$node_(36) set Z_ 3
$node_(37) set X_ 275
$node_(37) set Y_ 125
$node_(37) set Z_ 3
$node_(38) set X_ 25
$node_(38) set Y_ 75
$node_(38) set Z_ 3
$node_(39) set X_ 75
$node_(39) set Y_ 75
$node_(39) set Z_ 3
$node_(40) set X_ 125
$node_(40) set Y_ 75
$node_(40) set Z_ 3
$node_(41) set X_ 175
$node_(41) set Y_ 75
$node_(41) set Z_ 3
$node_(42) set X_ 225
$node_(42) set Y_ 75
$node_(42) set Z_ 3
$node_(43) set X_ 275
$node_(43) set Y_ 75
$node_(43) set Z_ 3
$node_(44) set X_ 25
$node_(44) set Y_ 25
$node_(44) set Z_ 3
$node_(45) set X_ 75
$node_(45) set Y_ 25
$node_(45) set Z_ 3
$node_(46) set X_ 125
$node_(46) set Y_ 25
$node_(46) set Z_ 3
$node_(47) set X_ 175
$node_(47) set Y_ 25
$node_(47) set Z_ 3
$node_(48) set X_ 225
$node_(48) set Y_ 25
$node_(48) set Z_ 3
$node_(49) set X_ 275
$node_(49) set Y_ 25
$node_(49) set Z_ 3

#=======================================================================
# set mobility file
#=======================================================================

$ns_ at 0.0  "$node_(0) NodeLabel PAN Coor"
$ns_ at 0.0  "$node_(0) sscs startPANCoord "  ;# startPANCoord <txBeacon=1> <BO=3> <SO=3>
$ns_ at 0.4	"$node_(1) sscs startDevice 1 1 1"
$ns_ at 0.5	"$node_(2) sscs startDevice 1 1 1"
$ns_ at 0.6	"$node_(3) sscs startDevice 1 1 1"
$ns_ at 0.7	"$node_(4) sscs startDevice 1 1 1"
$ns_ at 0.8	"$node_(5) sscs startDevice 1 1 1"
$ns_ at 0.9	"$node_(6) sscs startDevice 1 1 1"
$ns_ at 1.0	"$node_(7) sscs startDevice 1 1 1"
$ns_ at 1.1	"$node_(8) sscs startDevice 1 1 1"
$ns_ at 1.2	"$node_(9) sscs startDevice 1 1 1"
$ns_ at 1.3	"$node_(10) sscs startDevice 1 1 1"
$ns_ at 1.4	"$node_(11) sscs startDevice 1 1 1"
$ns_ at 1.5	"$node_(12) sscs startDevice 1 1 1"
$ns_ at 1.6	"$node_(13) sscs startDevice 1 1 1"
$ns_ at 1.7	"$node_(14) sscs startDevice 0"
$ns_ at 1.8	"$node_(15) sscs startDevice 0"
$ns_ at 1.9	"$node_(16) sscs startDevice 0"
$ns_ at 2.0	"$node_(17) sscs startDevice 0"
$ns_ at 2.1	"$node_(18) sscs startDevice 0"
$ns_ at 2.2	"$node_(19) sscs startDevice 0"
$ns_ at 2.3	"$node_(20) sscs startDevice 0"
$ns_ at 2.4	"$node_(21) sscs startDevice 0"
$ns_ at 2.5	"$node_(22) sscs startDevice 0"
$ns_ at 2.6	"$node_(23) sscs startDevice 0"
$ns_ at 2.7	"$node_(24) sscs startDevice 0"
$ns_ at 2.8	"$node_(25) sscs startDevice 0"
$ns_ at 2.9	"$node_(26) sscs startDevice 0"
$ns_ at 3.0	"$node_(27) sscs startDevice 0"
$ns_ at 3.1	"$node_(28) sscs startDevice 0"
$ns_ at 3.2	"$node_(29) sscs startDevice 0"
$ns_ at 3.3	"$node_(30) sscs startDevice 0"
$ns_ at 3.4	"$node_(31) sscs startDevice 0"
$ns_ at 3.5	"$node_(32) sscs startDevice 0"
$ns_ at 3.6	"$node_(33) sscs startDevice 0"
$ns_ at 3.7	"$node_(34) sscs startDevice 0"
$ns_ at 3.8	"$node_(35) sscs startDevice 0"
$ns_ at 3.9	"$node_(36) sscs startDevice 0"
$ns_ at 4.0	"$node_(37) sscs startDevice 0"
$ns_ at 4.1	"$node_(38) sscs startDevice 0"
$ns_ at 4.2	"$node_(39) sscs startDevice 0"
$ns_ at 4.3	"$node_(40) sscs startDevice 0"
$ns_ at 4.4	"$node_(41) sscs startDevice 0"
$ns_ at 4.5	"$node_(42) sscs startDevice 0"
$ns_ at 4.6	"$node_(43) sscs startDevice 0"
$ns_ at 4.7	"$node_(44) sscs startDevice 0"
$ns_ at 4.8	"$node_(45) sscs startDevice 0"
$ns_ at 4.9	"$node_(46) sscs startDevice 0"
$ns_ at 5.0	"$node_(47) sscs startDevice 0"
$ns_ at 5.1	"$node_(48) sscs startDevice 0"
$ns_ at 5.2	"$node_(49) sscs startDevice 0"

Mac/802_15_4 wpanNam PlaybackRate 3ms
$ns_ at $appTime1 "puts \"\nTransmitting data ...\n\""



# Setup traffic flow between nodes
proc cbrtraffic { src dst interval starttime } {
   global ns_ node_
   set udp_($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp_($src)
   set null_($dst) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null_($dst)
   set cbr_($src) [new Application/Traffic/CBR]
   eval \$cbr_($src) set packetSize_ 70
   eval \$cbr_($src) set rate_ 250k
   eval \$cbr_($src) set interval_ $interval
   eval \$cbr_($src) set random_ 0
   eval \$cbr_($src) attach-agent \$udp_($src)
   eval $ns_ connect \$udp_($src) \$null_($dst)
   $ns_ at $starttime "$cbr_($src) start"
}
# yang dihapus
if {"$opt(traffic)" == "cbr"} {
   puts "\nTraffic: cbr"
   #Mac/802_15_4 wpanCmd ack4data on
   puts [format "Acknowledgement for data: %s" [Mac/802_15_4 wpanCmd ack4data]]
   $ns_ at $appTime1 "Mac/802_15_4 wpanNam PlaybackRate 0.50ms"
   $ns_ at [expr $appTime1 + 0.5] "Mac/802_15_4 wpanNam PlaybackRate 1.5ms"
   cbrtraffic 14 0 0.6 $appTime1
   cbrtraffic 15 0 0.6 $appTime2
   cbrtraffic 16 0 0.6 $appTime3
   cbrtraffic 17 0 0.6 $appTime4
   cbrtraffic 18 0 0.6 $appTime1
   cbrtraffic 19 0 0.6 $appTime2
   cbrtraffic 20 0 0.6 $appTime3
   cbrtraffic 21 0 0.6 $appTime4
   cbrtraffic 22 0 0.6 $appTime5
   cbrtraffic 23 0 0.6 $appTime1
   cbrtraffic 24 0 0.6 $appTime2
   cbrtraffic 25 0 0.6 $appTime3
   cbrtraffic 26 0 0.6 $appTime4
   cbrtraffic 27 0 0.6 $appTime5
   cbrtraffic 28 0 0.6 $appTime1
   cbrtraffic 29 0 0.6 $appTime2
   cbrtraffic 30 0 0.6 $appTime1
   cbrtraffic 31 0 0.6 $appTime2
   cbrtraffic 32 0 0.6 $appTime3
   cbrtraffic 33 0 0.6 $appTime4
   cbrtraffic 34 0 0.6 $appTime5
   cbrtraffic 35 0 0.6 $appTime1
   cbrtraffic 36 0 0.6 $appTime2
   cbrtraffic 37 0 0.6 $appTime3
   cbrtraffic 38 0 0.6 $appTime4
   cbrtraffic 39 0 0.6 $appTime5
   cbrtraffic 40 0 0.6 $appTime1
   cbrtraffic 41 0 0.6 $appTime2
   cbrtraffic 42 0 0.6 $appTime3
   cbrtraffic 43 0 0.6 $appTime4
   cbrtraffic 44 0 0.6 $appTime5
   cbrtraffic 45 0 0.6 $appTime1
   cbrtraffic 46 0 0.6 $appTime2
   cbrtraffic 47 0 0.6 $appTime3
   cbrtraffic 48 0 0.6 $appTime4
   cbrtraffic 49 0 0.6 $appTime5

   $ns_ at 0.0 "$node_(0) add-mark m1 red circle"
   $ns_ at $appTime1 "$node_(14) add-mark m2 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 14 to node 0\""
   $ns_ at $appTime2 "$node_(15) add-mark m3 black circle"
   $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 15 to node 0\""
   $ns_ at $appTime3 "$node_(16) add-mark m4 black circle"
   $ns_ at $appTime3 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 16 to node 0\""
   $ns_ at $appTime4 "$node_(17) add-mark m5 black circle"
   $ns_ at $appTime4 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 17 to node 0\""
   $ns_ at $appTime5 "$node_(18) add-mark m6 black circle"
   $ns_ at $appTime5 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 18 to node 0\"" 
   $ns_ at $appTime1 "$node_(19) add-mark m7 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 19 to node 0\""
   $ns_ at $appTime2 "$node_(20) add-mark m8 black circle"
   $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 20 to node 0\""
   $ns_ at $appTime3 "$node_(21) add-mark m9 black circle"
   $ns_ at $appTime3 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 21 to node 0\""
   $ns_ at $appTime4 "$node_(22) add-mark m10 black circle"
   $ns_ at $appTime4 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 22 to node 0\""
   $ns_ at $appTime5 "$node_(23) add-mark m11 black circle"
   $ns_ at $appTime5 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 23 to node 0\""
   $ns_ at $appTime1 "$node_(24) add-mark m12 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 24 to node 0\"" 
   $ns_ at $appTime2 "$node_(25) add-mark m13 black circle"
   $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 25 to node 0\""
   $ns_ at $appTime1 "$node_(26) add-mark m14 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 26 to node 0\""
   $ns_ at $appTime2 "$node_(27) add-mark m15 black circle"
   $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 27 to node 0\""
   $ns_ at $appTime3 "$node_(28) add-mark m16 black circle"
   $ns_ at $appTime3 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 28 to node 0\""
   $ns_ at $appTime4 "$node_(29) add-mark m17 black circle"
   $ns_ at $appTime4 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 29 to node 0\""
   $ns_ at $appTime5 "$node_(30) add-mark m18 black circle"
   $ns_ at $appTime5 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 30 to node 0\"" 
   $ns_ at $appTime1 "$node_(31) add-mark m19 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 31 to node 0\""
   $ns_ at $appTime2 "$node_(32) add-mark m20 black circle"
   $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 32 to node 0\""
   $ns_ at $appTime3 "$node_(33) add-mark m21 black circle"
   $ns_ at $appTime3 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 33 to node 0\""
   $ns_ at $appTime4 "$node_(34) add-mark m22 black circle"
   $ns_ at $appTime4 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 34 to node 0\""
   $ns_ at $appTime5 "$node_(35) add-mark m23 black circle"
   $ns_ at $appTime5 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 35 to node 0\""
   $ns_ at $appTime1 "$node_(36) add-mark m24 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 36 to node 0\"" 
   $ns_ at $appTime2 "$node_(37) add-mark m25 black circle"
   $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 37 to node 0\""
   $ns_ at $appTime1 "$node_(38) add-mark m26 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 38 to node 0\""
   $ns_ at $appTime2 "$node_(39) add-mark m27 black circle"
   $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 39 to node 0\""
   $ns_ at $appTime3 "$node_(40) add-mark m28 black circle"
   $ns_ at $appTime3 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 40 to node 0\""
   $ns_ at $appTime4 "$node_(41) add-mark m29 black circle"
   $ns_ at $appTime4 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 41 to node 0\""
   $ns_ at $appTime5 "$node_(42) add-mark m30 black circle"
   $ns_ at $appTime5 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 42 to node 0\"" 
   $ns_ at $appTime1 "$node_(43) add-mark m31 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 43 to node 0\""
   $ns_ at $appTime2 "$node_(44) add-mark m32 black circle"
   $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 44 to node 0\""
   $ns_ at $appTime3 "$node_(45) add-mark m33 black circle"
   $ns_ at $appTime3 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 45 to node 0\""
   $ns_ at $appTime4 "$node_(46) add-mark m34 black circle"
   $ns_ at $appTime4 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 46 to node 0\""
   $ns_ at $appTime5 "$node_(47) add-mark m35 black circle"
   $ns_ at $appTime5 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 47 to node 0\""
   $ns_ at $appTime1 "$node_(48) add-mark m36 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 48 to node 0\"" 
   $ns_ at $appTime2 "$node_(49) add-mark m37 black circle"
   $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 49 to node 0\""
   $ns_ at 0.0 "$node_(1) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(2) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(3) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(4) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(5) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(6) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(7) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(8) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(9) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(10) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(11) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(12) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(13) add-mark m1 blue circle"
   
   Mac/802_15_4 wpanNam FlowClr -p GPSR -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c black
   Mac/802_15_4 wpanNam FlowClr -p MAC -c navy
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 14 -d 0 -c black
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 15 -d 0 -c red
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 16 -d 0 -c navy
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 17 -d 0 -c blue
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 18 -d 0 -c blue
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 19 -d 0 -c green
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 20 -d 0 -c black
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 21 -d 0 -c red
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 22 -d 0 -c navy
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 23 -d 0 -c blue
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 24 -d 0 -c green
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 25 -d 0 -c black
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 26 -d 0 -c red
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 27 -d 0 -c navy
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 28 -d 0 -c blue
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 29 -d 0 -c green
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 30 -d 0 -c black
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 31 -d 0 -c red
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 32 -d 0 -c navy
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 33 -d 0 -c blue
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 34 -d 0 -c green
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 35 -d 0 -c black
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 36 -d 0 -c red
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 37 -d 0 -c navy
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 38 -d 0 -c blue
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 39 -d 0 -c green
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 40 -d 0 -c black
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 41 -d 0 -c red
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 42 -d 0 -c navy
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 43 -d 0 -c blue
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 44 -d 0 -c green
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 45 -d 0 -c black
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 46 -d 0 -c red
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 47 -d 0 -c navy
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 48 -d 0 -c blue
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 49 -d 0 -c green

   
}

# defines the node size in nam
for {set i 0} {$i < $opt(nn)} {incr i} {
     $ns_ initial_node_pos $node_($i) 3
}

# Tell nodes when the simulation ends
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $stopTime "$node_($i) reset";
}
$ns_ at $stopTime "stop"
$ns_ at $stopTime "puts \"\nNS EXITING...\n\""
$ns_ at $stopTime "$ns_ halt"
proc stop {} {
    global ns_ tracefd appTime opt env
    $ns_ flush-trace
    close $tracefd
    set hasDISPLAY 0
    foreach index [array names env] {
        #puts "$index: $env($index)"
        if { ("$index" == "DISPLAY") && ("$env($index)" != "") } {
                set hasDISPLAY 1
        }
    }
    if { ("$opt(nam)" == "gpsr50.nam") && ("$hasDISPLAY" == "1") } {
    	#exec nam gpsr50.nam &
	#exec awk -f energy.awk gpsr50.tr &
		    }
}
puts "\nStarting Simulation..."
$ns_ run



