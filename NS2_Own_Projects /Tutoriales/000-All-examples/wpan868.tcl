#############################################
#             Star over 802.15.4            #
#              (beacon enabled)             #
#      Copyright (c) 2003 Samsung/CUNY      #
# - - - - - - - - - - - - - - - - - - - - - #
#        Prepared by Jianliang Zheng        #
#         (zheng@ee.ccny.cuny.edu)          #
#############################################

#############################################
#						         #
#Modified By: Vaddina Prakash Rao	         #
#Chair of Telecommunications, TU Dresden	   #
#							   #
#############################################

# Warning: The script file uses hardcoded paths to files.

# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy/802_15_4
set val(mac)            Mac/802_15_4
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         150                        ;# max packet in ifq
set val(rp)             AODV                       ;# routing protocol
set val(x)		50
set val(y)		50
set val(cp)		"/root/ns-2/ns-allinone-2.28/ns-2.28/examples/backoff_test/traffic"		;# point to the traffic characteristic file
set val(dst)		3			   ;# device start time(in secs). The time at which the first device will be started.
set val(dstit)		1			   ;# device start time increment time (in secs). The time value after which the next device will be started. 

# Parameters used for traffic generation
# Do not use more than 25 nodes. Else modify the awk script file analyzing the trace file, accordingly
# so that it can convert higher hex values to corresponding decimal values.
set val(nn)             15                         ;# nodechange: number of mobilenodes
set val(starttime)      20.0
set stopTime            1000                       ;# Non_Simulation time
set BO                  3                          ;# Non_Simulation time
set SO                  3                          ;# Non_Simulation time





set infile [open "current_seed.txt" r]
while {[gets $infile line] >= 0} {
set inputseed $line
}

set temp1 $val(nn)
incr temp1 -1
exec /root/ns-2/ns-allinone-2.28/ns-2.28/examples/backoff_test/scen_gen $temp1 25 25 9

global defaultRNG
$defaultRNG seed $inputseed

set val(nam)		wpan.nam
#set val(traffic)	ftp                        ;# cbr/poisson/ftp
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 0.0864
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

# Initialize Global Variables
set ns_		[new Simulator]
set tracefd     [open ./wpan.tr w]
$ns_ trace-all $tracefd
# A few statements to indicate the simulator, about the NS animator.
if { "$val(nam)" == "wpan.nam" } {
        set namtrace     [open ./$val(nam) w]
        $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
}

$ns_ puts-nam-traceall {# nam4wpan #}		;# inform nam that this is a trace file for wpan (special handling needed)

Mac/802_15_4 wpanCmd verbose on
Mac/802_15_4 wpanNam namStatus on		;# default = off (should be turned on before other 'wpanNam' commands can work)
Mac/802_15_4 wpanNam ColFlashClr black		;# default = gold

# For model 'TwoRayGround'
Phy/WirelessPhy set CSThresh_ 1.995e-13
Phy/WirelessPhy set RXThresh_ 1.995e-13
Phy/WirelessPhy set CPThresh_ 10


# The threshold values for the transmitter (CSThresh_) and receiver(RXThresh_). Values can be obtained from the "threshold" utility.
Phy/WirelessPhy set Pt_ 0.001			;# Transmitter power = 0.0456
Phy/WirelessPhy set freq_ 8.68e+08		;# frequency of operation = 8.68e+08
Phy/WirelessPhy set L_ 1.0			;# Path loss = 1.0

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

# Create God
set god_ [create-god $val(nn)]

set chan_1_ [new $val(chan)]

# configure node

$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-movementTrace ON \
                -energyModel "EnergyModel" \
                -initialEnergy 13000 \
                -rxPower 0.0648 \
                -txPower 0.0744 \
		-idlePower 0.00000552 \
		-channel $chan_1_

for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0		;# disable random motion
}

source /root/ns-2/ns-allinone-2.28/ns-2.28/examples/backoff_test/wpan.scn

# nodechange
$ns_ at 0.0	"$node_(0) NodeLabel PAN Coor"
$ns_ at 0.0	"$node_(0) sscs startPANCoord 1 $BO $SO"		;# startPANCoord <txBeacon=1> <BO=3> <SO=3>


# Loop to start all the other nodes, with the first node starting at val(dst) and the following nodes to
# start at times, incremented by val(dstit), to the starting time of the previous node.
set i 1
while {$i < $val(nn)} {
$ns_ at $val(dst)	"$node_($i) sscs startDevice 0 0 0 $BO $SO"	;# startDevice <isFFD=1> <assoPermit=1> <txBeacon=0> <BO=3> <SO=3>
incr val(dst) $val(dstit)
incr i 1
}

Mac/802_15_4 wpanNam PlaybackRate 3ms

$ns_ at $val(starttime) "puts \"\nTransmitting data ...\n\""

if { $val(cp) == "" } {
puts "*** NOTE: no connection pattern specified."
        set val(cp) "none"
} else {
puts "Loading connection pattern..."
source $val(cp)
}

# defines the node size in nam
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 2
}

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $stopTime "$node_($i) reset";
}

$ns_ at $stopTime "stop"
$ns_ at $stopTime "puts \"NS EXITING...\n\""
$ns_ at $stopTime "$ns_ halt"

proc stop {} {
    global ns_ tracefd val(starttime) val env
    $ns_ flush-trace
    close $tracefd
    set hasDISPLAY 0
    foreach index [array names env] {
        #puts "$index: $env($index)"
        if { ("$index" == "DISPLAY") && ("$env($index)" != "") } {
                set hasDISPLAY 1
        }
    }
#    if { ("$val(nam)" == "wpan.nam") && ("$hasDISPLAY" == "1") } {
#	exec /root/ns-2/ns-allinone-2.28/nam-1.11/nam wpan.nam &
#	exec kate /root/ns-2/ns-allinone-2.28/ns-2.28/examples/backoff_test/wpan.tr &
#	exec cp wpan.tr /root/downloads/scripts/awk/ &
	exec awk -f avg_throughput.awk wpan.tr
#    }
}

puts "\nStarting Simulation..."
$ns_ run

