set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             2                          ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol

# ======================================================================
# Main Program  https://groups.google.com/forum/?fromgroups=#!topic/ns-users/VetJf8ljslI
# ======================================================================
#
# Initialize Global Variables
#
set ns_		[new Simulator]
set tracefd     [open wireless.tr w]
set namtrace    [open error5.nam w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace 100 100
# set up topography object
set topo       [new Topography]
$topo load_flatgrid 100 100

#
# Create god object
#
create-god $val(nn)

#
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
		 -movementTrace OFF \	
		 -IncomingErrProc UniformErr 
		 
$ns_ node-config -IncomingErrProc $val(em)
# -OutgoingErrProc UniformErr	

			 
for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
}

#set node_(0) [$ns_ node]	
#set node_(1) [$ns_ node]	

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$node_(0) set X_ 5.0
$node_(0) set Y_ 10.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 25.0
$node_(1) set Y_ 10.0
$node_(1) set Z_ 0.0

#
# Now produce some simple node movements
# Node_(1) starts to move towards node_(0)
#
$ns_ at 0.0 "$node_(1) setdest 5.0 15.0 0.0"
$ns_ at 0.0 "$node_(0) setdest 20.0 40.0 0.0"

# Node_(1) then starts to move away from node_(0)
#$ns_ at 30.0 "$node_(1) setdest 90.0 80.0 15.0" 

# Setup traffic flow between nodes
# TCP connections between node_(0) and node_(1)
set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(1) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns_ at 5.0 "$ftp start" 



proc UniformErr {} {
set em [new ErrorModel/Uniform 0.05 pkt]
#$em unit packet
#$em set rate_ 0.01
#$em ranvar [new RandomVariable/Uniform]
#$em drop-target [new Agent/Null]
return $em
}

#$ns_ link-lossmodel $em $node_(0) $node_(1)

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 30.0 "$node_($i) reset";
}
$ns_ at 35.0 "stop"
$ns_ at 35.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
}

puts "Starting Simulation..."
$ns_ run 
