# ======================================================================
# Define options
# ======================================================================
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             6                          ;# number of mobilenodes
set val(rp)             Protoname                  ;# routing protocol
set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(stop)	    10

# ======================================================================
# Main Program
# ======================================================================

#ns-random 0

# Initialize Global Variables
set ns_ [new Simulator]
set tracefd [open protoname.tr w]
$ns_ trace-all $tracefd

set namtrace    [open protoname.nam w]
$ns_ namtrace-all-wireless $namtrace 1000 500

# set up topography
set topo [new Topography]
$topo load_flatgrid 1000 500

# Create God
create-god $val(nn)


# Create the specified number of mobilenodes [$val(nn)] and "attach" them
# to the channel. 
# configure node
set channel [new Channel/WirelessChannel]
$channel set errorProbability_ 0.0

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channel $channel \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON\
			 -macTrace OFF \
			 -movementTrace OFF			
			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]      
		$node_($i) random-motion 0;	
	}

# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
$node_(0) set X_ 100.0
$node_(0) set Y_ 200.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 250.0
$node_(1) set Y_ 200.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 400.0
$node_(2) set Y_ 200.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 400.0
$node_(3) set Y_ 350.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 250.0
$node_(4) set Y_ 350.0
$node_(4) set Z_ 0.0

$node_(5) set X_ 100.0
$node_(5) set Y_ 350.0
$node_(5) set Z_ 0.0

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined

    $ns_ initial_node_pos $node_($i) 20
}

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}

# $ns_ at 0.1 "[$node_(0) set ragent_] send-pkt-to [$node_(3) id]" 
for {set i 0} {$i < $val(nn) } {incr i} {   
    $ns_ at 0.0 "[$node_($i) set ragent_] initilize"; # all the node broadcast his key element
}

for {set i 0} {$i < $val(nn) } {incr i} {   
    $ns_ at 0.0 "[$node_($i) set ragent_] gen-pair-keys"; # all the node broadcast his key element
}

# $ns_ at 0.1 "[$node_(3) set ragent_] gen-pair-keys"
# $ns_ at 0.1 "[$node_(3) set ragent_] send-to [$node_(4) id]"
# $ns_ at 0.1 "[$node_(1) set ragent_] send-to [$node_(2) id]"
$ns_ at $val(stop).0 "stop"
$ns_ at $val(stop).01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
    exec nam protoname.nam
}

puts "Starting Simulation..."
$ns_ run






