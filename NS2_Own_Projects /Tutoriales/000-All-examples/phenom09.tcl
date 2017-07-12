################################################################################
# AUTHOR: Ian Downard
# DATE: 10 FEB 2003
# DESCRIPTION:
#     This simulation creates one sensor, two phenom nodes, and one data 
# collection node.  This simulation demonstrates the capability for emanating 
# two different types of PHENOM packets at two different pulserates.
#
# BUG: simulation won't run for some pulserates.  Not really sure what's going 
#      on here.  Seems sporadic.  Probably due to NRLOLSR.
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
set val(nn)             4                          ;# number of mobilenodes
set val(rp)             AODV                    ;# routing protocol
set val(x)	            400
set val(y)	            400

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# specify the transmit power
# (see wireless-shadowing-vis-test.tcl for another example)
Phy/WirelessPhy set Pt_ 0.3

puts "This is a multi-channel sensor network test program."

# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

set ns_		[new Simulator]
set tracefd [open phenom09.tr w]
$ns_ trace-all $tracefd

set namtrace [open phenom09.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
set god_ [create-god $val(nn)]
$god_ off
$god_ allow_to_stop
$god_ num_data_types 1

set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]

# configure two phenomenon nodes
#
set val(rp) PHENOM                              ;# PHENOM routing protocol
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

    set node_(0) [$ns_ node 0]
    $node_(0) random-motion 0		            ;# disable random motion
    $god_ new_node $node_(0)
    $node_(0) namattach $namtrace
    $ns_ initial_node_pos $node_(0) 25
    [$node_(0) set ragent_] pulserate 0.1        ;#configures PHENOM node
    [$node_(0) set ragent_] phenomenon CO       ;#configures PHENOM node

    set node_(1) [$ns_ node 1]
    $god_ new_node $node_(1)
    $node_(1) namattach $namtrace
    $ns_ initial_node_pos $node_(1) 25
    [$node_(1) set ragent_] pulserate 0.1        ;#configures PHENOM node
    [$node_(1) set ragent_] phenomenon LIGHT_GEO ;#configures PHENOM node

# configure sensor node
#
set val(rp) AODV
$ns_ node-config \
     -adhocRouting $val(rp) \
	 -channel $chan_2_ \
     -PHENOMchannel $chan_1_                    ;# adds the PHENOM iface

    set node_(2) [$ns_ node 2]
    $node_(2) random-motion 0		            ;# disable random motion
    $god_ new_node $node_(2)
    $node_(2) namattach $namtrace
    $ns_ initial_node_pos $node_(2) 25

# data collection node
#
$ns_ node-config \
     -PHENOMchannel "off"

    set node_(3) [$ns_ node 3]
    $node_(3) random-motion 0		            ;# disable random motion
    $god_ new_node $node_(3)
    $node_(3) namattach $namtrace
    $ns_ initial_node_pos $node_(3) 25

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$node_(0) set X_ 1.0
$node_(0) set Y_ 1.0
$node_(1) set X_ 300.0
$node_(1) set Y_ 1.0
$node_(2) set X_ 150.0
$node_(2) set Y_ 150.0
$node_(3) set X_ 200.0
$node_(3) set Y_ 200.0

# syntax:     node id            X     Y    speed
#
$ns_ at 0.01 "$node_(0) setdest 1.0 1.0 50.0"
$ns_ at 0.01 "$node_(1) setdest 300.0 1.0 50.0"
$ns_ at 0.01 "$node_(2) setdest 150.0 150.0 50.0"
$ns_ at 0.01 "$node_(3) setdest 200.0 200.0 50.0"


$ns_ at 2.00 "$node_(2) setdest 1.0 80.0 350.0"
$ns_ at 3.00 "$node_(2) setdest 300.0 80.0 350.0"
$ns_ at 5.00 "$node_(2) setdest 250.0 350.0 150.0"
$ns_ at 5.00 "$node_(3) setdest 350.0 350.0 150.0"

$ns_ at .01 "$node_(0) color blue"
$ns_ at .01 "$node_(1) color blue"

#attach sensor agent to sensor node
#
set sensor01 [new Agent/SensorAgent]
$ns_ attach-agent $node_(2) $sensor01
[$node_(2) set ll_(1)] up-target $sensor01

$ns_ at 0.1 "$sensor01 start"

#setup connection between sensor node and data collection node
#
set src [new Agent/UDP]
set sink [new Agent/UDP]
$ns_ attach-agent $node_(2) $src
$ns_ attach-agent $node_(3) $sink
$ns_ connect $src $sink

#attach and start sensor app to sensor node
#
set sensor_app [new Application/SensorApp]
$sensor_app attach-agent $src

$ns_ at 0.2 "$sensor_app start $sensor01"

#disable a phenom
#
#$ns_ at 0.01 {[$node_(1) set netif_(0)] set Pt_ 0.0001}


#Tell nodes when the simulation ends
#
$ns_ at 10.0 "$node_(0) reset";
$ns_ at 10.0 "$node_(1) reset";
$ns_ at 10.0 "$node_(2) reset";
$ns_ at 10.0 "$node_(3) reset";

$ns_ at 10.0 "stop"
$ns_ at 10.01 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
}

#Begin command line parsing
puts "Starting Simulation..."
$ns_ run
