#LC tcl file for trust simulations with DSR
#==========================================================
# Define options
#==========================================================
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
#set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 1000 ;# max packet in ifq
set val(rp) DSR ;# routing protocol
set val(seed) 1.0 ;#
if { $val(rp) == "DSR" } {
set val(ifq) CMUPriQueue
} else {
set val(ifq) Queue/DropTail/PriQueue
}
# ------------------- simulation with 25 nodes ------------
set val(nn) 50 ;# number of mobilenodes
set val(x) 1000 ;# X dimension of the topography
set val(y) 1000 ;# Y dimension of the topography
set val(stop) 900.0 ;# simulation time
set val(path) /home/s031001/projects/NetSim/ns-allinone-2.28/ns-2.28
#The cbr pattern is defined in this file and assiociated with cb
#30 connections
set val(cp) "$val(path)/tcl/ex/confdiant/50nodes/cbr-50-r2";
#The scenario (nodes movement and connections) is defined in this file and assiociated with sc
set val(sc) "$val(path)/tcl/ex/confdiant/50nodes/scen-50-m1-1";

#==========================================================
Agent/Null set sport_ 0
Agent/Null set dport_ 0
Agent/CBR set sport_ 0
Agent/CBR set dport_ 0
# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0
# the above parameters result in a nominal range of 250m
set nominal_range 250.0
set configured_range -1.0
set configured_raw_bitrate -1.0
#Phy/WirelessPhy set bandwidth_ 11e6
#Mac/802_11 set basicRate_ 0
#Mac/802_11 set dataRate_ 0
#Mac/802_11 set bandwidth_ 11e6 ;
#Mac/802_11 set PLCPDataRate_ 11e6;


#==========================================================
# Main Program
#==========================================================
#Create a simulator object
set ns_ [new Simulator]
#Open the trace file
set tracefd [open conf-out-tdsr.tr w]
$ns_ trace-all $tracefd
#$ns_ use-newtrace
# set the new channel interface.
#set chan [new $val(chan)]
#Open the nam file
set namtrace [open confout.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
#Set up topography object to keep track of movement of nodes
set topo [new Topography]
#Provide topography object with coordinates
$topo load_flatgrid $val(x) $val(y)

# Create God
create-god $val(nn)

#Configure the nodes
$ns_ node-config -adhocRouting $val(rp) \
	-llType $val(ll) \
	-macType $val(mac) \
	-ifqType $val(ifq) \
	-ifqLen $val(ifqlen) \
	-antType $val(ant) \
	-propType $val(prop) \
	-phyType $val(netif) \
	-channelType $val(chan)\
	-topoInstance $topo \
	-agentTrace ON \
	-routerTrace OFF \
	-macTrace OFF \
	-movementTrace ON

#-channel $chan
#Create the specified number of mobilenodes [$val(nn)] and "attach" them to the channel.
for {set i 0} {$i < $val(nn) } {incr i} {
puts "i: $i"
set node_($i) [$ns_ node]
$node_($i) random-motion 0 ;# disable random motion
}
#Define node movement model
puts "Loading connection pattern..."
source $val(cp)
#Define traffic model
puts "Loading scenario file..."
source $val(sc)
# Define node initial position in nam
for {set i 0} {$i < $val(nn)} {incr i} {
# 25 defines the node size in nam, must adjust it according to your
scenario
# The function must be called after mobility model is defined
$ns_ initial_node_pos $node_($i) 50
}
#Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at $val(stop).0 "$node_($i) reset";
}
$ns_ at $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
puts $tracefd "Confidant Wrote this!"
puts $tracefd "M 0.0 nn $val(nn) x $val(x) y $val(y) rp $val(rp)"
puts $tracefd "M 0.0 sc $val(sc) cp $val(cp) seed $val(seed)"
puts $tracefd "M 0.0 prop $val(prop) ant $val(ant)"
puts "Starting Simulation..."
$ns_ run
