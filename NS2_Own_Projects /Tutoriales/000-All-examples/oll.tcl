# Define options
# ======================================================================

set val(chan)       Channel/WirelessChannel  	;#channel type
set val(prop)       Propagation/TwoRayGround	;#radio propagation delay
set val(netif)      Phy/WirelessPhy		;#network interface type
set val(mac)        Mac/802_11			;#MAC type
set val(ifq)        Queue/DropTail/PriQueue	;#interface queue type
set val(ll)         LL				;#link layer type
set val(ant)        Antenna/OmniAntenna		;#antenna model
set val(x)              500 			;# X dimension of the topography
set val(y)              500  			;# Y dimension of the topography
set val(ifqlen)         50            		;# max packet in ifq
set val(seed)           0.0
set val(adhocRouting)   AODV			;#routing protocol
set val(nn)             50             		;# how many nodes are simulated
set val(cp)             "cbr_n50_mc5" 		;#cbr with 20 nodes and max connection 5
set val(sc)             "scen_n50_m150_p20"	;#scen with 20 node, speed of 10, pause time 30 
set val(stop)           900           		;# simulation time

# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

# create simulator instance
set ns_	[new Simulator]


# setup topography object
set topo	[new Topography]


# create trace object for ns and nam
#for new trace file format
$ns_ use-newtrace 

set tracefd	[open aodv_n50_mc5_m65_p0.tr w]
set namtrace    [open aodv_n50_mc5_m65_p0.nam w]

$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)



# define topology
$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
set god_ [create-god $val(nn)]


# New API to config node: 
# 1. Create channel (or multiple-channels);
# 2. Specify channel in node-config (instead of channelType);
# 3. Create nodes for simulations.

# Create channel #1 and #2
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]


#configure the node
$ns_ node-config -adhocRouting $val(adhocRouting) \
                 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 #-channelType $val(chan) \
		 -topoInstance $topo \
		 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
		 -movementTrace ON \
		 -channel $chan_1_ 

# node_(1) can also be created with the same configuration, or with a different
# channel specified.
# Uncomment below two lines will create node_(1) with a different channel.
#  $ns_ node-config \
#		 -channel $chan_2_ 


#
#  Create the specified number of nodes [$val(nn)] and "attach" them
#  to the channel. 

for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0		;# disable random motion	
	
}


# 
# Define node movement model, generated using cbr-gen
#
puts "Loading connection pattern..."
source $val(cp)

# 
# Define traffic model, generated using mov-gen
#
puts "Loading scenario file..."
source $val(sc)



# Define node initial position in nam
for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 20
}


#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}

#ending simulation
$ns_ at  $val(stop) "$ns_ nam-end-wireless $val(stop)"
$ns_ at $val(stop) "stop"
$ns_ at 900.01 "puts \"END SIMULATION!!!!\" ; $ns_ halt"

proc stop {} {
	global ns_ tracefd namtrace
	$ns_ flush-trace
	close $tracefd
	close $namtrace
	}

#run ns
$ns_ run
