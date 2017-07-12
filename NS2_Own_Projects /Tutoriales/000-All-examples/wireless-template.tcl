#######################
#######################
set val(simDur) 5.0 ;#simulation duration

set val(basename)  wireless;#basename for this project or scenario

set val(statIntvl) 0.1 ;#statistics collection interval
set val(statStart) 0.5 ;

set val(trafStart) 0.5 ;#CBR start time
set val(cbrIntvl) 1.0 ;#CBR traffic interval

set val(chan)           [ new Channel/WirelessChannel]    ;# channel model
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ifqlen)         50                         ;# max packet in ifq
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(nn)             2                          ;# number of mobilenodes
set val(rp)             AODV                  ;# routing protocol
set val(topo_x_dim)	600
set val(topo_y_dim)	600

#######################
#######################
#Initialize and create output files
#Create a simulator instance
set ns [new Simulator]

#Crate a trace file and animation record
set tracefd [open $val(basename).tr w]
$ns trace-all $tracefd
set namtracefd [open $val(basename).nam w]
$ns namtrace-all-wireless $namtracefd $val(topo_x_dim) $val(topo_y_dim)

set outfd [open $val(basename).out w]

#######################
#######################
#Create Topology

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(topo_x_dim) $val(topo_y_dim)

#
# Create God
#
create-god $val(nn)

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 

# configure node

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
		 -macTrace OFF \
		 -movementTrace OFF \
		 -channel $val(chan)

for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns node]
	$node_($i) random-motion 0              ;# disable random motion
}

$node_(0) set X_ 100.0
$node_(0) set Y_ 250.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 250.0
$node_(1) set Y_ 250.0
$node_(1) set Z_ 0.0

$ns initial_node_pos $node_(0) 10
$ns initial_node_pos $node_(1) 10

#########################
#########################
#Modify these variables accordingly
#########################
set proto "tcp"
set src $node_(0)
set dst $node_(1)
#########################

if {$proto=="udp"} {
    #Create a udp agent on node0
    set udp [new Agent/UDP]
    $ns attach-agent $src $udp

    # Create a CBR traffic source on node0
    set cbr0 [new Application/Traffic/CBR]
    $cbr0 set packetSize_ 500
    $cbr0 set interval_ $val(cbrIntvl)
    $cbr0 set random_ 1
    $cbr0 attach-agent $udp

    #Create a Null agent (a traffic sink) on node1
    set sink0 [new Agent/LossMonitor]
    $ns attach-agent $dst $sink0

    #Connet source and dest Agents
    $ns connect $udp $sink0
    $ns at $val(trafStart) "$cbr0 start"
    $ns at $val(simDur) "$cbr0 stop"
} elseif {$proto=="tcp"} {
    #Create a tcp agent on the source node
    set tcp [new Agent/TCP]
    $tcp set class_ 2
    $ns attach-agent $src $tcp

    # Create a CBR traffic source on node0
    set ftp [new Application/FTP]
    $ftp attach-agent $tcp

    #Create a sink(a traffic sink) on the destination node
    set sink0 [new Agent/TCPSink]
    $ns attach-agent $dst $sink0

    #Connet source and dest Agents
    $ns connect $tcp $sink0
    $ns at $val(trafStart) "$ftp start"
}

#########################
#a procedure to record stats
proc record {} {
    global sink0 ns outfd val
    set bytes [$sink0 set bytes_]
    set now [$ns now]
    puts $outfd "$now $bytes"
    $sink0 set bytes_ 0
    $ns at [expr $now+$val(statIntvl)] "record"
}

#########################
#a procedure to close trace file and nam file
proc finish {} {

	global ns tracefd namtracefd basename val
	$ns flush-trace

	close $tracefd
	close $namtracefd
	
	exit 0
}

#
#Schedule trigger events
$ns at $val(statStart) "record"

#Call the finish procedure after 5s (of simulated time)
$ns at $val(simDur) "finish"

#Run the simulation
$ns run




