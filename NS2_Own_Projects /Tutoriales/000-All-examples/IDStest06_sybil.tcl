################################################################################
# AUTHOR: Ian Downard
# DATE: 03 JAN 2003
# DESCRIPTION:
#   This simulation tests the cooperability of NRLOLSR and PHENOM.  This
#  simulation also stresses scaleability by creating lots of sensor nodes.
#
# BUG: search for _26_ in phenom06.tr, and you will find a 26th node.  But, I
#      only configure 0 thru 25 nodes.  Nowhere have I configured node id #26.
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
Phy/WirelessPhy set Pt_ 0.1

puts "This is a multi-channel sensor network test program."

# =====================================================================
# Main Program
# ======================================================================
#source ../../ns-allinone-2.27/ns-2.27/tcl/lib/ns-lib.tcl
#
# Initialize Global Variables
#

set ns_		[new Simulator]
set tracefd [open phenom06.tr w]
set idstracefd [open idstrace_uu.tr w]
$ns_ trace-all $tracefd

#set namtrace [open phenom06.nam w]
#$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
set sybilinterfaces 2
set numnodes_ $val(nn)+$sybilinterfaces-1; #if the sybilnode only cheat those node addresses which already exist
set numnodes_ 51; #if sybilnode also pretend some address which doesn't exist, make sure the simulated nodes number is bigger than that. Otherwise the mac-802_11.cc has some problem in detecting the duplicate packets.
set god_ [create-god $numnodes_]
$god_ off
$god_ allow_to_stop
$god_ num_data_types 1

#configure phenomenon channel and data channel
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
	 -agentTrace OFF \
	 -routerTrace OFF \
	 -macTrace OFF \
	 -movementTrace OFF 

    set node_(0) [$ns_ node 0]
    $node_(0) random-motion 0		            ;# disable random motion
    $god_ new_node $node_(0)
   # $node_(0) namattach $namtrace
    $ns_ initial_node_pos $node_(0) 25
    [$node_(0) set ragent_] pulserate .09       ;#configures PHENOM node
    [$node_(0) set ragent_] phenomenon CO      ;#configures PHENOM node

# configure sensor nodes
set val(rp) AODVUU                                ;# AODV routing protocol
$ns_ node-config \
     -adhocRouting $val(rp) \
	 -channel $chan_2_ \
	 -macTrace ON \
	 -ids MIUN_IDS \
     -PHENOMchannel $chan_1_

	for {set i 1} {$i < $val(nn)-2 } {incr i} {
		set node_($i) [$ns_ node]
		$node_($i) random-motion 0
        $god_ new_node $node_($i)
       # $node_($i) namattach $namtrace
	}

# configure SYBIL/ID SPOOFING sensor node
# $i==$val(nn)-2 now
set node_($i) [new SybilNode $sybilinterfaces]
set sybilnode_ $node_($i)
incr i
# configure data collection point
set val(rp) AODVUU                             ;# AODV routing protocol
$ns_ node-config \
     -adhocRouting $val(rp) \
	 -channel $chan_2_ \
	 -ids MIUN_IDS \
     -PHENOMchannel "off"                       ;# adds the PHENOM iface

set node_($i) [$ns_ node]
$node_($i) random-motion 0
$god_ new_node $node_($i)
#$node_($i) namattach $namtrace

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
#$node_(24) set X_ 400.0
#$node_(24) set Y_ 300.0
# $node_(24) is the sybilnode now
$node_(24) setposition 400.0 300.0

$node_(25) set X_ 400.0
$node_(25) set Y_ 400.0
# node_(25) is the data collection point

$ns_ at .01 "$node_(0) color blue"

#set dest format is "setdest <x> <y> <speed>"
# node_(0) is the phenominon.


for {set time 0} {$time < 251 } {incr time 50} {
	$ns_ at [expr 0.01+$time] "$node_(0) setdest 50.0 50.0 100.0"
	$ns_ at [expr 10.01+$time] "$node_(0) setdest 350.0 350.0 100.0"
	$ns_ at [expr 20.01+$time] "$node_(0) setdest 1.0 350.0 100.0"
	$ns_ at [expr 30.01+$time] "$node_(0) setdest 50.0 50.0 100.0"
	$ns_ at [expr 40.01+$time] "$node_(0) setdest 350.0 1.0 100.0"
}

###############################################################################
# Attach the sensor agent to the sensor node, and build a conduit thru which
# recieved PHENOM packets will reach the sensor agent's recv routine

# attach a Sensor Agent (i.e. phenom agent) to sensor node
for {set i 1} {$i < $val(nn)-2 } {incr i} {
  set sensor_($i) [new Agent/SensorAgent]
  $ns_ attach-agent $node_($i) $sensor_($i)
}
set sensor_($i) [new Agent/SensorAgent]
#SybilNode cannot attach agents currently, any agent (including the sensor agent) must be attached to a sub node of the SybilNode
$ns_ attach-agent [$node_($i) set subnode_(0)] $sensor_($i)

# specify the sensor agent as the up-target for the sensor node's link layer
# configured on the PHENOM interface
for {set i 1} {$i < $val(nn)-2 } {incr i} {
  [$node_($i) set ll_(1)] up-target $sensor_($i)
  $ns_ at 4.0 "$sensor_($i) start"
}
[[$node_($i) set subnode_(0)] set ll_(1)] up-target $sensor_($i)
$ns_ at 4.0 "$sensor_($i) start"

###############################################################################

# setup UDP connections to data collection point, and attach sensor apps
set sink [new Agent/UDP/MIUN_WSN]
$ns_ attach-agent $node_(25) $sink
$ns_ set_sinknode $node_(25)
for {set i 1} {$i < $val(nn)-2 } {incr i} {
  set src_($i) [new Agent/UDP/MIUN_WSN]
  $ns_ attach-agent $node_($i) $src_($i)
  #$ns_ connect $src_($i) $sink
  set app_($i) [new Application/SensorApp]
  $app_($i) attach-agent $src_($i)
  $app_($i) dst_agent $sink
}
# for each subnode inside the Sybilnode, an agent is created
set sybilapp_ [new Application/SensorApp/SybilApp]
$sybilapp_ attach-sybilnode $sybilnode_
for {set i 0} {$i < $sybilinterfaces} {incr i} {
	set subsrc_($i) [new Agent/UDP/MIUN_WSN]
	$ns_ attach-agent [$sybilnode_ set subnode_($i)] $subsrc_($i)

	set subapp_($i) [new Application/SensorApp]
	$subapp_($i) attach-agent $subsrc_($i)
	$subapp_($i) dst_agent $sink

	$sybilapp_ attach-application $i $subapp_($i)
}

for {set i 1} {$i < $val(nn)-2 } {incr i} {
  $ns_ at 5.0 "$app_($i) start $sensor_($i)"
}
$ns_ at 5.0 "$sybilapp_ start $sensor_($i)"

$ns_ at 100.0 "$sybilnode_ set-interface-state 1 ACTIVATED"
$ns_ at 150.0 "$sybilnode_ ChangeAddrTo 0 50 50"

#set the IDS state.
$ns_ at 60.0 "$ns_ set_ids_state training"
$ns_ at 250.0 "$ns_ set_ids_state detecting"

#Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn)-1 } {incr i} {
  $ns_ at 300.0 "$node_($i) reset";
}  

$ns_ at 300.0 "stop"
$ns_ at 300.1 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ idstracefd tracefd
    $ns_ flush-trace
    close $tracefd
    #close $namtrace
    close $idstracefd
}

#Begin command line parsing

puts "Starting Simulation..."
$ns_ run


