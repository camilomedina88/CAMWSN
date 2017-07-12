################################################################################
# AUTHOR: Ian Downard
# DATE: 25 FEB 2003
# DESCRIPTION:
#    This simulation creates one sensor, 10 phenom nodes, and one data 
# collection node.  This simulation exposes the bug where Phenom nodes recieve
# PHENOM packets.  This doesn't really effect the simulation, because phenom
# nodes won't act on that event, but it's not really realistic to say that a
# phenomenon has any capacity for receiving anything.
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
set val(nn)             13                         ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)	            400
set val(y)	            400

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# specify the transmit power
# (see wireless-shadowing-vis-test.tcl for another example)
Phy/WirelessPhy set Pt_ 0.2

puts "This is a multi-channel sensor network test program."

# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

set ns_		[new Simulator]
set tracefd [open phenom12.tr w]
$ns_ trace-all $tracefd

set namtrace [open phenom12.nam w]
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

# configure phenomenon nodes
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

for {set i 0} {$i < 10 } {incr i } {
    set node_($i) [$ns_ node]
    $god_ new_node $node_($i)
    $node_($i) namattach $namtrace
    $ns_ initial_node_pos $node_($i) 25
    [$node_($i) set ragent_] pulserate 0.1        ;#configures PHENOM node
    [$node_($i) set ragent_] phenomenon LIGHT_GEO ;#configures PHENOM node  
}

# configure sensor node
#
set val(rp) AODV
$ns_ node-config \
     -adhocRouting $val(rp) \
	 -channel $chan_2_ \
     -PHENOMchannel $chan_1_                    ;# adds the PHENOM iface

    set node_(10) [$ns_ node]
    $node_(10) random-motion 0		            ;# disable random motion
    $god_ new_node $node_(10)
    $node_(10) namattach $namtrace
    $ns_ initial_node_pos $node_(10) 25

    set node_(11) [$ns_ node]
    $node_(11) random-motion 0		            ;# disable random motion
    $god_ new_node $node_(11)
    $node_(11) namattach $namtrace
    $ns_ initial_node_pos $node_(11) 25


# data collection node
#
$ns_ node-config \
     -PHENOMchannel "off"

    set node_(12) [$ns_ node]
    $node_(12) random-motion 0		            ;# disable random motion
    $god_ new_node $node_(12)
    $node_(12) namattach $namtrace
    $ns_ initial_node_pos $node_(12) 25

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$node_(0) set X_ 1.0
$node_(0) set Y_ 1.0
$node_(1) set X_ 50.0
$node_(1) set Y_ 1.0
$node_(2) set X_ 100.0
$node_(2) set Y_ 1.0
$node_(3) set X_ 150.0
$node_(3) set Y_ 1.0
$node_(4) set X_ 200.0
$node_(4) set Y_ 1.0
$node_(5) set X_ 250.0
$node_(5) set Y_ 1.0
$node_(6) set X_ 300.0
$node_(6) set Y_ 1.0
$node_(7) set X_ 25.0
$node_(7) set Y_ 1.0
$node_(8) set X_ 75.0
$node_(8) set Y_ 1.0
$node_(9) set X_ 125.0
$node_(9) set Y_ 1.0
$node_(10) set X_ 350.0
$node_(10) set Y_ 350.0
$node_(11) set X_ 350.0
$node_(11) set Y_ 25.0
$node_(12) set X_ 150.0
$node_(12) set Y_ 100.0

# syntax:     node id            X     Y    speed
#
$ns_ at 0.01 "$node_(0) setdest 1.0 1.0 150.0"
$ns_ at 0.01 "$node_(1) setdest 1.0 50.0 150.0"
$ns_ at 0.01 "$node_(2) setdest 1.0 100.0 150.0"
$ns_ at 0.01 "$node_(3) setdest 50.0 1.0 150.0"
$ns_ at 0.01 "$node_(4) setdest 50.0 50.0 150.0"
$ns_ at 0.01 "$node_(5) setdest 50.0 100.0 150.0"
$ns_ at 0.01 "$node_(6) setdest 100.0 1.0 150.0"
$ns_ at 0.01 "$node_(7) setdest 100.0 50.0 150.0"
$ns_ at 0.01 "$node_(8) setdest 100.0 100.0 150.0"
$ns_ at 0.01 "$node_(9) setdest 1.0 300.0 150.0"
$ns_ at 0.01 "$node_(10) setdest 350.0 350.0 200.0"
$ns_ at 0.01 "$node_(11) setdest 350.0 25.0 200.0"
$ns_ at 0.01 "$node_(12) setdest 150.0 100.0 50.0"
$ns_ at 2.0 "$node_(11) setdest 25.0 25.0 350.0"
$ns_ at 3.00 "$node_(10) setdest 25.0 25.0 350.0"
$ns_ at 4.00 "$node_(11) setdest 150.0 350.0 350.0"
$ns_ at 5.00 "$node_(10) setdest 150.0 350.0 350.0"
$ns_ at 5.50 "$node_(11) setdest 350.0 250.0 350.0"
$ns_ at 6.00 "$node_(10) setdest 350.0 350.0 350.0"
#$ns_ at 4.50 "$node_(12) setdest 150.0 200.0 150.0"


for {set i 0} {$i < 10 } {incr i } { 
$ns_ at .01 "$node_($i) color blue"
}

#attach sensor agent to sensor node
#
set sensor01 [new Agent/SensorAgent]
$ns_ attach-agent $node_(10) $sensor01
[$node_(10) set ll_(1)] up-target $sensor01

set sensor02 [new Agent/SensorAgent]
$ns_ attach-agent $node_(11) $sensor02
[$node_(11) set ll_(1)] up-target $sensor02

#setup connection between sensor node and data collection node
#
set src [new Agent/UDP]
set sink [new Agent/UDP]
$ns_ attach-agent $node_(10) $src
$ns_ attach-agent $node_(12) $sink
$ns_ connect $src $sink

#setup connection between sensor node and data collection node
#
set src2 [new Agent/UDP]
$ns_ attach-agent $node_(11) $src2
$ns_ connect $src2 $sink

#attach and start sensor app to sensor node
#
set sensor_app [new Application/SensorApp]
$sensor_app attach-agent $src
set sensor_app2 [new Application/SensorApp]
$sensor_app2 attach-agent $src2

$ns_ at 0.1 "$sensor_app start $sensor01"
$ns_ at 0.1 "$sensor_app2 start $sensor02"

$ns_ at 9.0 "stop"
$ns_ at 9.01 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
}

#Begin command line parsing
puts "Starting Simulation..."
$ns_ run
