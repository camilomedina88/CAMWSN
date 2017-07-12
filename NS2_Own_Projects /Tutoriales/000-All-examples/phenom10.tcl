################################################################################
# AUTHOR: Ian Downard
# DATE: 11 Feb 2003
# DESCRIPTION:
#     This simulation is meant to illustrate how long it takes for routes to be
# created in a MANET network running olsr.
#
################################################################################

#
# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             26                         ;# number of mobilenodes
set val(rp)             AODV                    ;# routing protocol
set val(x)	            451                 ;# grid width
set val(y)	            451                 ;# grid hieght

# specify the transmit power
# (see wireless-shadowing-vis-test.tcl for another example)
Phy/WirelessPhy set Pt_ 0.1

puts "This is a multi-channel sensor network test program."

# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

set ns_		[new Simulator]
set tracefd [open phenom10.tr w]
$ns_ trace-all $tracefd

set namtrace [open phenom10.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
create-god $val(nn)

set chan_1_ [new $val(chan)]

$ns_ node-config \
     -adhocRouting $val(rp) \
	 -llType $val(ll) \
	 -macType $val(mac) \
	 -ifqType $val(ifq) \
	 -ifqLen $val(ifqlen) \
	 -antType $val(ant) \
	 -propType $val(prop) \
	 -phyType $val(netif) \
	 -channel $chan_1_ \
	 -topoInstance $topo \
	 -agentTrace ON \
	 -routerTrace ON \
	 -macTrace ON \
	 -movementTrace ON

	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 1
		$ns_ initial_node_pos $node_($i) 25		;# disable random motion
	}

if {$val(rp) == "NRLOLSR"} {
  # alpha = .7 causes a segfault (alpha defaults to .7)
  [$node_(0) set ragent_] alpha .6
#  [$node_(0) set ragent_] T_up 0.5
#  [$node_(0) set ragent_] T_down 0.001
#  [$node_(0) set ragent_] TC_jitter .75
#  [$node_(0) set ragent_] Hello_jitter 0.5
#  [$node_(0) set ragent_] TC_timer 3
#  [$node_(0) set ragent_] Hello_timer .5
#  [$node_(0) set ragent_] TC_Timeout_Factor 3
#  [$node_(0) set ragent_] mac 1
#  [$node_(0) set ragent_] allLinks 1
#  [$node_(0) set ragent_] debugfile "tempolsr"
#  set debugvalue 0
}

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#

$node_(0) set X_ 50.0
$node_(0) set Y_ 50.0

$node_(1) set X_ 1.0
$node_(1) set Y_ 1.0
$node_(2) set X_ 1.0
$node_(2) set Y_ 100.0
$node_(3) set X_ 1.0
$node_(3) set Y_ 200.0
$node_(4) set X_ 1.0
$node_(4) set Y_ 300.0
$node_(5) set X_ 1.0
$node_(5) set Y_ 400.0
$node_(6) set X_ 100.0
$node_(6) set Y_ 1.0
$node_(7) set X_ 100.0
$node_(7) set Y_ 100.0
$node_(8) set X_ 100.0
$node_(8) set Y_ 200.0
$node_(9) set X_ 100.0
$node_(9) set Y_ 300.0
$node_(10) set X_ 100.0
$node_(10) set Y_ 400.0
$node_(11) set X_ 200.0
$node_(11) set Y_ 1.0
$node_(12) set X_ 200.0
$node_(12) set Y_ 100.0
$node_(13) set X_ 200.0
$node_(13) set Y_ 200.0
$node_(14) set X_ 200.0
$node_(14) set Y_ 300.0
$node_(15) set X_ 200.0
$node_(15) set Y_ 400.0
$node_(16) set X_ 300.0
$node_(16) set Y_ 1.0
$node_(17) set X_ 300.0
$node_(17) set Y_ 100.0
$node_(18) set X_ 300.0
$node_(18) set Y_ 200.0
$node_(19) set X_ 300.0
$node_(19) set Y_ 300.0
$node_(20) set X_ 300.0
$node_(20) set Y_ 400.0
$node_(21) set X_ 400.0
$node_(21) set Y_ 1.0
$node_(22) set X_ 400.0
$node_(22) set Y_ 100.0
$node_(23) set X_ 400.0
$node_(23) set Y_ 200.0
$node_(24) set X_ 400.0
$node_(24) set Y_ 300.0
$node_(25) set X_ 400.0
$node_(25) set Y_ 400.0


#set dest format is "setdest <x> <y> <speed>"

$ns_ at 0.01 "$node_(0) setdest 50.0 50.0 50.0"
$ns_ at 5.0 "$node_(0) setdest 150.0 250.0 300.0"
$ns_ at 6.0 "$node_(0) setdest 1.0 350.0 300.0"
$ns_ at 7.0 "$node_(0) setdest 50.0 50.0 300.0"
$ns_ at 8.0 "$node_(0) setdest 350.0 1.0 300.0"

$ns_ at 0.01 "$node_(1) setdest 1.0 1.0 50.0"
$ns_ at 0.01 "$node_(2) setdest 1.0 100.0 50.0"
$ns_ at 0.01 "$node_(3) setdest 1.0 200.0 50.0"
$ns_ at 0.01 "$node_(4) setdest 1.0 300.0 50.0"
$ns_ at 0.01 "$node_(5) setdest 1.0 400.0 50.0"
$ns_ at 0.01 "$node_(6) setdest 100.0 1.0 50.0"
$ns_ at 0.01 "$node_(7) setdest 100.0 100.0 50.0"
$ns_ at 0.01 "$node_(8) setdest 100.0 200.0 50.0"
$ns_ at 0.01 "$node_(9) setdest 100.0 300.0 50.0"
$ns_ at 0.01 "$node_(10) setdest 100.0 400.0 50.0"
$ns_ at 0.01 "$node_(11) setdest 200.0 1.0 50.0"
$ns_ at 0.01 "$node_(12) setdest 200.0 100.0 50.0"
$ns_ at 0.01 "$node_(13) setdest 200.0 200.0 50.0"
$ns_ at 0.01 "$node_(14) setdest 200.0 300.0 50.0"
$ns_ at 0.01 "$node_(15) setdest 200.0 400.0 50.0"
$ns_ at 0.01 "$node_(16) setdest 300.0 1.0 50.0"
$ns_ at 0.01 "$node_(17) setdest 300.0 100.0 50.0"
$ns_ at 0.01 "$node_(18) setdest 300.0 200.0 50.0"
$ns_ at 0.01 "$node_(19) setdest 300.0 300.0 50.0"
$ns_ at 0.01 "$node_(20) setdest 300.0 400.0 50.0"
$ns_ at 0.01 "$node_(21) setdest 400.0 1.0 50.0"
$ns_ at 0.01 "$node_(22) setdest 400.0 100.0 50.0"
$ns_ at 0.01 "$node_(23) setdest 400.0 200.0 50.0"
$ns_ at 0.01 "$node_(24) setdest 400.0 300.0 50.0"
$ns_ at 0.01 "$node_(25) setdest 400.0 400.0 50.0"

$ns_ at .01 "$node_(0) color red"
$ns_ at .01 "$node_(0) color green"

set src [new Agent/UDP]
set sink [new Agent/UDP]
$ns_ attach-agent $node_(0) $src
$ns_ attach-agent $node_(25) $sink
$ns_ connect $src $sink

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $src
$cbr set packetSize_ 210
$cbr set rate_ 100k

$ns_ at 0.5 "$cbr start"

#Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
  $ns_ at 23.0 "$node_($i) reset";
}  

$ns_ at 23.1 "stop"
$ns_ at 23.2 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
}

#Begin command line parsing

puts "Starting Simulation..."
$ns_ run


