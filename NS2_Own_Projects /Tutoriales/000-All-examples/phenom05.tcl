################################################################################
# AUTHOR: Ian Downard
# DATE: 03 JAN 2003
# DESCRIPTION:
#     This simulation creates three wireless nodes for a rudimentary sensor
# network test.  Nodes 1 is transmitting CBR traffic to node 2 on channel 2,
# via AODV.  Node 1 is configured with two wireless interfaces, one on channel
# 1, and the other on channel 2.  Node 0 is our phenominon, which is detected
# by the sensor node (represented by node 1) on channel 1.  We're using
# periodic broadcasts on channel 1 (our PHENOM channel) to simulate the
# presence of a phenominon (like a chemical cloud, or rolling armor) in our
# simulated world.  We can see that node 1 detects the phenominon's presence by
# looking at the trace file, and observing that node 1 is recieving node 0's 
# broadcasts.
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
set val(nn)             2                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
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
set tracefd [open phenom05.tr w]
$ns_ trace-all $tracefd

set namtrace [open phenom05.nam w]
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

#configure phenomenon
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]

# configure phenomenon node
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
    [$node_(0) set ragent_] pulserate .5        ;#configures PHENOM node
    [$node_(0) set ragent_] phenomenon CO      ;#configures PHENOM node

# configure wireless nodes

# configure dual-homed node (i.e. sensor node)
set val(rp) AODVUU                                ;# AODV routing protocol
$ns_ node-config \
     -adhocRouting $val(rp) \
	 -channel $chan_2_ \
     -PHENOMchannel $chan_1_                    ;# adds the PHENOM iface

    set node_(1) [$ns_ node 1]
    $node_(1) random-motion 0		            ;# disable random motion
    $god_ new_node $node_(1)
    $node_(1) namattach $namtrace
    $ns_ initial_node_pos $node_(1) 25

    set r [$node_(1) set ragent_]   ;# get the routing agent
    $r set debug_ 1                     ;# configure the routing agent
    $r set rt_log_interval_ 1000
    $r set log_to_file_ 1

# configure CBR sink.  Not a sensor node.  Eventually, may be a gateway for
# sensor alarms.
$ns_ node-config \
     -PHENOMchannel "off"

    set node_(2) [$ns_ node 2]
    $node_(2) random-motion 0		            ;# disable random motion
    $god_ new_node $node_(2)
    $node_(2) namattach $namtrace
    $ns_ initial_node_pos $node_(2) 25

    set r [$node_(2) set ragent_]   ;# get the routing agent
    $r set debug_ 1                     ;# configure the routing agent
    $r set rt_log_interval_ 1000
    $r set log_to_file_ 1

# output node object names for debugging
puts "node_(0) = $node_(0)     node_(1) = $node_(1)     node_(2) = $node_(2)"

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$node_(0) set X_ 1.0
$node_(0) set Y_ 1.0
$node_(1) set X_ 399.0
$node_(1) set Y_ 399.0
$node_(2) set X_ 360.0
$node_(2) set Y_ 300.0

$ns_ at 0.01 "$node_(0) setdest 300.0 300.0 150.0"
$ns_ at 0.01 "$node_(1) setdest 399.0 399.0 50.0"
$ns_ at 0.01 "$node_(2) setdest 360.0 300.0 50.0"

$ns_ at 4.0 "$node_(1) setdest 1.0 1.0 200.0"
$ns_ at 3.5 "$node_(2) setdest 100.0 100.0 200.0"

set src [new Agent/UDP]
set sink [new Agent/UDP]
$ns_ attach-agent $node_(1) $src
$ns_ attach-agent $node_(2) $sink
$ns_ connect $src $sink

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $src
$cbr set packetSize_ 210
$cbr set rate_ 100k

$ns_ at 5.0 "$cbr start"

###############################################################################
# Attach the sensor agent to the sensor node, and build a conduit thru which
# recieved PHENOM packets will reach the sensor agent's recv routine

# attach a Phenom Agent (i.e. sensor agent) to sensor node
set sensor01 [new Agent/SensorAgent]
    puts "\tphenom05.tcl: sensor01 is object $sensor01"
$ns_ attach-agent $node_(1) $sensor01

# specify the sensor agent as the up-target for the sensor node's link layer
# configured on the PHENOM interface
[$node_(1) set ll_(1)] up-target $sensor01

$ns_ at 0.2 "$sensor01 start"

###############################################################################

#Tell nodes when the simulation ends
#
$ns_ at 10.0 "$node_(1) reset";
$ns_ at 10.0 "$node_(2) reset";

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
