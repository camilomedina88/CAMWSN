################################################################################
# AUTHOR: Ian Downard
# DATE: 28 JAN 2003
# DESCRIPTION:
#   This simulation tests the cooperability of NRLOLSR and PHENOM.  This
# simulation is mostly useful as an example of how transmit power can be 
# modified during the simulation.  This simulation also shows the backlog
# of sensor data which exists in the network, since udp traffic (sensor traffic)
# is still being transmitted to the udp sink even after the phenom node has
# been turned off (by setting it's transmit power to 0.00001).  It's interesting
# to see how much longer that udp traffic lingers in the network with AODV as 
# opposed to NRLOLSR.
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

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# specify the transmit power
# (see wireless-shadowing-vis-test.tcl for another example)
Phy/WirelessPhy set Pt_ 0.03

puts "This is a multi-channel sensor network test program."

# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

set ns_		[new Simulator]
set tracefd [open phenom08.tr w]
$ns_ trace-all $tracefd

set namtrace [open phenom08.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
#set god_ [create-god $val(nn)]
set god_ [create-god 27]
$god_ off
$god_ allow_to_stop
$god_ num_data_types 1

#configure phenomenon channel and data channel
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]

# configure phenomenon node with the PHENOM routing protocol
$ns_ node-config \
     -adhocRouting PHENOM \
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
    [$node_(0) set ragent_] pulserate .09       ;#configures PHENOM node
    [$node_(0) set ragent_] phenomenon CO      ;#configures PHENOM node

# configure sensor nodes
$ns_ node-config \
     -adhocRouting $val(rp) \
	 -channel $chan_2_ \
     -PHENOMchannel $chan_1_                    ;# adds the PHENOM iface

	for {set i 1} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 1
        $god_ new_node $node_($i)
        $node_($i) namattach $namtrace
	}

# configure data collection point
$ns_ node-config \
     -adhocRouting $val(rp) \
	 -channel $chan_2_ \
     -PHENOMchannel "off"                       ;# adds the PHENOM iface

set node_($i) [$ns_ node]	
$node_($i) random-motion 1
$god_ new_node $node_($i)
$node_($i) namattach $namtrace

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#

# node_(0) is the phenominon.
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

# node_(26) is the data collection point
$node_(26) set X_ 450.0
$node_(26) set Y_ 450.0

$ns_ at .01 "$node_(0) color blue"

#set dest format is "setdest <x> <y> <speed>"

# node_(0) is the phenominon.
$ns_ at 0.01 "$node_(0) setdest 50.0 50.0 50.0"
$ns_ at 5.0 "$node_(0) setdest 350.0 350.0 300.0"
$ns_ at 6.0 "$node_(0) setdest 1.0 350.0 600.0"
$ns_ at 7.0 "$node_(0) setdest 50.0 50.0 600.0"

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
$ns_ at 0.01 "$node_(26) setdest 450.0 450.0 50.0"


###############################################################################
# Attach the sensor agent to the sensor node, and build a conduit thru which
# recieved PHENOM packets will reach the sensor agent's recv routine.

# attach a Sensor Agent (i.e. sensor agent) to sensor node
for {set i 1} {$i < $val(nn) } {incr i} {
  set sensor_($i) [new Agent/SensorAgent]
  $ns_ attach-agent $node_($i) $sensor_($i)
  
  # specify the sensor agent as the up-target for the sensor node's link layer
  # configured on the PHENOM interface, so that the sensor agent handles the 
  # received PHENOM packets instead of any other agent attached to the node.
  #
  [$node_($i) set ll_(1)] up-target $sensor_($i)
}

###############################################################################

# setup UDP connections to data collection point, and attach sensor apps
set sink [new Agent/UDP]
$ns_ attach-agent $node_(26) $sink
for {set i 1} {$i < $val(nn) } {incr i} {
  set src_($i) [new Agent/UDP]
  $ns_ attach-agent $node_($i) $src_($i)
  $ns_ connect $src_($i) $sink
  
  set app_($i) [new Application/SensorApp]
  $app_($i) attach-agent $src_($i)
}

for {set i 1} {$i < $val(nn) } {incr i} {
  $ns_ at 5.0 "$app_($i) start $sensor_($i)"
}

# disable phenomenon
#
$ns_ at 8.0 {[$node_(0) set netif_(0)] set Pt_ 0.0001}

# enable phenomenon
#
# $ns_ at 8.0 {[$node_(0) set netif_(0)] set Pt_ 0.1}

#Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
  $ns_ at 20.0 "$node_($i) reset";
}  

$ns_ at 20.0 "stop"
$ns_ at 20.1 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
}

#Begin command line parsing

puts "Starting Simulation..."
$ns_ run


