###############################################################################
# AUTHOR: Ian Downard
# DATE: 28 jul 2006
# PURPOSE:
#
# Stress testing of client/server comms thru agentj in a wireless network.
#
# Client requests X responses from server, and server send those responses via
# UDP packets at 500ms intervals.
#
################################################################################

#
# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel     ;# channel type
set val(prop)           Propagation/TwoRayGround    ;# radio-propagation model
set val(netif)          Phy/WirelessPhy             ;# network interface type
set val(mac)            Mac/802_11                  ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue     ;# interface queue type
set val(ll)             LL                          ;# link layer type
set val(ant)            Antenna/OmniAntenna         ;# antenna model
set val(ifqlen)         50                          ;# max packet in ifq
set val(rp)             ProtolibManetKernel         ;# routing protocol
set val(x)	            200                         ;# width of map
set val(y)	            200                         ;# height of map
set val(stop)           10.0                         ;# simulation stop time

set val(nn) 2

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# specify the transmit power
# (see wireless-shadowing-vis-test.tcl for another example)
Phy/WirelessPhy set Pt_ 0.01

# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

set ns_		[new Simulator]
set tracefd [open NetEcho_wireless.tr w]
$ns_ trace-all $tracefd

set namtrace [open NetEcho_wireless.nam w]
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

#configure phenomenon node
set chan_1_ [new $val(chan)]

#configure prey node
$ns_ node-config \
     -adhocRouting $val(rp) \
	 -channel $chan_1_ \
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
    set node_($i) [$ns_ node $i]
    $god_ new_node $node_($i)
    $node_($i) namattach $namtrace
    $ns_ initial_node_pos $node_($i) 25
}

# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes

set x 100.0
set y 100.0
#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
for {set i 0} {$i < $val(nn) } {incr i} {
  $node_($i) set X_ $x
  $node_($i) set Y_ $y
  $ns_ at 0.1 "$node_($i) setdest $x $y 150.0"
}

if {$val(rp) == "ProtolibManetKernel"} {
  for {set i 0} {$i < $val(nn) } {incr i} {
	set p($i) [new Agent/NrlolsrAgent]
	$ns_ attach-agent $node_($i) $p($i)
	$ns_ at 0.0 "$p($i) startup -tcj .75 -hj .5 -tci 2.5 -hi .5 -d 0"
	[$node_($i) set ragent_] attach-manet $p($i)
	$p($i) attach-protolibManetKernel [$node_($i) set ragent_]
	$p($i) -flooding s-mpr
  }
}

###############################################################################
# Attach GodView agents to nodes with "eyes"

# Every node has eyes, so we need GodView agents, and eyes are implemented in 
# C++ but used from Java so we need AgentJ.  So, for every node, do...
for {set i 0} {$i < $val(nn)} {incr i} {
  set agentJ_($i) [new Agent/Agentj]
  $ns_ attach-agent $node_($i) $agentJ_($i)
  $ns_ at 0.0 "$agentJ_($i) initAgent"
}


puts "Setting Java Object to use by each agent ..." 

$ns_ at 0.0 "$agentJ_(0) attach-agentj agentj.examples.gui.NetClientUDP"
$ns_ at 0.0 "$agentJ_(1) attach-agentj agentj.examples.gui.NetEchoUDP"

puts "Starting simulation ..." 

$ns_ at 1.0 "$agentJ_(1) agentj init [$node_(0) node-addr]"

# The argument after the init specifies how many responses will be 
# requested from the server.
$ns_ at 1.0 "$agentJ_(0) agentj init 100 [$node_(1) node-addr]"

set endTime 150
$ns_ at $endTime "puts \"NS-2 finished.  Exiting...\""
$ns_ at $endTime "finish $ns_"

proc finish {ns_} {
$ns_ halt
delete $ns_
}

$ns_ run

