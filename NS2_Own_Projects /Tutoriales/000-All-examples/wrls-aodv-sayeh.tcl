# wrls1.tcl     https://groups.google.com/forum/?fromgroups=#!topic/ns-users/SvormnFKPv4
# A 3-node example for ad-hoc simulation with AODV
set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             3                          ;# number of mobilenodes
                      
set val(rp)             AODV                       ;# routing protocol
set val(x)		500
set val(y)		500
  			   ;# Y dimension of topography  
set val(stop)		150			   ;# time of simulation end
set opt(energymodel) EnergyModel;
#----------------------------------------------------------------------------------------------

set ns	  [new Simulator]
set tracefd       [open simple.tr w]
set namtrace      [open simwrls.nam w]    

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

#
#  Create nn mobilenodes [$val(nn)] and attach them to the channel. 
#

# Create channel #1 and #2
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]

# configure the nodes
      $ns node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-movementTrace OFF \
		-channel $chan_1_ 

# Energy model
     $ns node-config  -energyModel EnergyModel \
                       -initialEnergy 50 \
                       -txPower 0.75
                       #-rxPower 0.25 \
                       #idlePower 0.0 \
                       #sensePower 0.0

for {set i 0} {$i < $val(nn) } { incr i } {
		set node_($i) [$ns node]	
	}			 
	

# Provide initial location of mobilenodes
$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 490.0
$node_(1) set Y_ 285.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 150.0
$node_(2) set Y_ 240.0
$node_(2) set Z_ 0.0

#set some label for nodes
$node_(0) label "source"
$node_(1) label "destination"

# Generation of movements
$ns at 10.0 "$node_(0) setdest 250.0 250.0 3.0"
$ns at 15.0 "$node_(1) setdest 45.0 285.0 5.0"
$ns  at 110.0 "$node_(0) setdest 480.0 300.0 5.0" 

# Set a TFRC connection between node_(0) and node_(1)
set dccp1 [new Agent/DCCP/TCPlike]
set dccpsink1 [new Agent/DCCP/TCPlike]
$ns attach-agent $node_(0) $dccp1
$ns attach-agent $node_(1) $dccpsink1
$dccp1 set fid_ 1
$dccp1 set window_ 7000

$ns connect $dccp1 $dccpsink1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $dccp1
$cbr1 set packetSize_ 160
$cbr1 set rate_ 80Kb
$cbr1 set random_ rng

$ns at 10.0 "$dccpsink1 listen"
$ns at 10.0 "$cbr1 start" 



# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 30 defines the node size for nam
$ns initial_node_pos $node_($i) 30
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
}

$ns run

