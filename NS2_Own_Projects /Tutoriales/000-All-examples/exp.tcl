#  amit bhardwaj   https://groups.google.com/forum/?fromgroups#!topic/ns-users/JJVNvTnAdXY
# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround  ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)           Queue/DropTail/PriQueue   ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                      ;# max packet in ifq
set val(nn)             40                ;# number of mobilenodes
set val(rp)             ZRP            ;# routing protocol
set val(x)              500  ;# X dimension of the topography
set val(y)              500 ;# Y dimension of the topography$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
set val(mobi)             "/home/mscelectronics8/ns-allinone-2.33/ns-2.33/indep-utils/cmu-scen-gen/setdest/scen-40-test" 
set val(tp)             "/home/mscelectronics8/ns-allinone-2.33/ns-2.33/indep-utils/cmu-scen-gen/cbr-40-test" 
Agent/ZRP set radius_ 2 
# ======================================================================
# Main Program
# ======================================================================


#
# Initialize Global Variables
#
set ns_		[new Simulator]
set tracefd     [open exp.tr w]
$ns_ trace-all $tracefd
set namtrace    [open exp.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)


# set up topography object
set topo       [new Topography]

$topo load_flatgrid 500 500

#
# Create God
#
set god_ [create-god $val(nn)]


#Se
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 
#  Here two nodes are created : node(0) and node(1)

# configure node

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace OFF			
			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
	}

puts "Loading mobility pattern..."
source $val(mobi)


# Define node initial position in nam

for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 5
}

puts "Loading traffic pattern..."
source $val(tp)


#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 100.0 "$node_($i) reset";
}
$ns_ at 100.0 "stop"
$ns_ at 100.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run

