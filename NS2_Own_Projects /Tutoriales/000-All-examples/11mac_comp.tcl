
#illidan.modeler@gmail.com

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
set val(nn)             2                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol

# ======================================================================
# Main Program
# ======================================================================


#
# Initialize Global Variables
#
set ns_		[new Simulator]
set token wireless-udp
set tracefd     [open $token.tr w]
set namfd	[open $token.nam w]
set f0 [open $token.data w]

$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namfd 20 20

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 20 20

#
# Create God
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
			 -movementTrace OFF			
			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
	}

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 15.0
$node_(1) set Y_ 15.0
$node_(1) set Z_ 0.0

$ns_ initial_node_pos $node_(0) 5
$ns_ initial_node_pos $node_(1) 5


# Setup traffic flow between nodes
# TCP connections between node_(0) and node_(1)
set s_agent [new Agent/UDP]
$s_agent set class_ 2
#set sink [new Agent/Null]
set sink [new Agent/LossMonitor]
$ns_ attach-agent $node_(0) $s_agent
$ns_ attach-agent $node_(1) $sink
$ns_ connect $s_agent $sink

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 700
$cbr set interval_ 0.001
$cbr attach-agent $s_agent

proc record {} {
        global sink f0 
        #Get an instance of the simulator
        set ns [Simulator instance]
        #Set the time after which the procedure should be called again
        set time 0.5
        #How many bytes have been received by the traffic sinks?
        set bytes [$sink set bytes_]
        #Get the current time
        set now [$ns now]
        #Calculate the bandwidth (in MBit/s) and write it to the files
        puts $f0 "$now [expr $bytes/$time*8]"
        #Reset the bytes_ values on the traffic sinks
        $sink set bytes_ 0

        #Re-schedule the procedure
        $ns at [expr $now+$time] "record"
    #    puts "getting out of record()"
    #    puts "$now"
}

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 150.0 "$node_($i) reset";
}

$ns_ at 10.0 "$cbr start" 
$ns_ at 150.0 "stop"
$ns_ at 150.01 "puts \"NS EXITING...\""
proc stop {} {
    global ns_ tracefd namfd f0
    $ns_ flush-trace
    close $namfd
    close $tracefd
    $ns_ halt
    exec nam wireless.nam &
}

puts "Starting Simulation..."
$ns_ at 0.0 "record"
$ns_ run


