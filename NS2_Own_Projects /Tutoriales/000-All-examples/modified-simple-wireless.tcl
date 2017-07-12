#
# http://www.linuxquestions.org/questions/showthread.php?p=4608985#4
#
 
Trace set show_sctphdr_ 1

# ======================================================================

# Define options

# ======================================================================

set val(chan) Channel/WirelessChannel ;# channel type

set val(prop) Propagation/TwoRayGround ;# radio-propagation model

set val(netif) Phy/WirelessPhy ;# network interface type

set val(mac) Mac/802_11 ;# MAC type

set val(ifq) Queue/DropTail/PriQueue ;# interface queue type

set val(ll) LL ;# link layer type

set val(ant) Antenna/OmniAntenna ;# antenna model

set val(ifqlen) 50 ;# max packet in ifq

set val(nn) 2 ;# number of mobilenodes

set val(rp) DSDV ;# routing protocol



# ======================================================================

# Main Program

# ======================================================================

#

# Initialize Global Variables

#

set ns [new Simulator]


set tr [open simple.tr w]

$ns trace-all $tr

set nf [open simple.nam w]
$ns namtrace-all $nf



# set up topography object

set topo [new Topography]



$topo load_flatgrid 500 500



#

# Create God

#

create-god $val(nn)



#

# Create the specified number of mobilenodes [$val(nn)] and "attach" them

# to the channel.

# Here two nodes are created : node(0) and node(1)



# configure node



$ns node-config -adhocRouting $val(rp) \

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

set node_($i) [$ns node]

$node_($i) random-motion 0 ;# disable random motion

}



#

# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes

#

$node_(0) set X_ 5.0

$node_(0) set Y_ 2.0

$node_(0) set Z_ 0.0



$node_(1) set X_ 390.0

$node_(1) set Y_ 385.0

$node_(1) set Z_ 0.0



#

# Now produce some simple node movements

# Node_(1) starts to move towards node_(0)

#

$ns at 50.0 "$node_(1) setdest 25.0 20.0 15.0"

$ns at 10.0 "$node_(0) setdest 20.0 18.0 1.0"



# Node_(1) then starts to move away from node_(0)

$ns at 100.0 "$node_(1) setdest 490.0 480.0 15.0"



# Setup traffic flow between nodes

# SCTP connections between node_(0) and node_(1)



set sctp0 [new Agent/SCTP]
$ns attach-agent $node_(0) $sctp0
$sctp0 set fid_ 1
set cbr0 [new Application/Traffic/CBR]

# set traffic class to 1

$cbr0 set class_ 1
$cbr0 attach-agent $sctp0

# Create a Null sink to receive Data

set sinknode1 [new Agent/LossMonitor]
$ns attach-agent $node_(1) $sinknode1
set sctp1 [new Agent/SCTP]
$ns attach-agent $node_(1) $sctp1
$sctp1 set fid_ 2
set cbr1 [new Application/Traffic/CBR]
$cbr1 set class_ 2
$cbr1 attach-agent $sctp1
set sinknode0 [new Agent/LossMonitor]
$ns attach-agent $node_(0) $sinknode0
$ns connect $sctp0 $sctp1


#

# Tell nodes when the simulation ends

#

for {set i 0} {$i < $val(nn) } {incr i} {

$ns at 150.0 "$node_($i) reset";

}

$ns at 15.0 "stop"

$ns at 15.01 "puts \"NS EXITING...\" ; $ns halt"

proc stop {} {

global ns tracefd

$ns flush-trace

close $tracefd

}
