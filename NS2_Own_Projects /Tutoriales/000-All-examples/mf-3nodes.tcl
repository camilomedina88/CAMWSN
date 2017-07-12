##################
set val(simDur) 5.0 ;#simulation duration

set val(basename)  mf-3nodes;#basename for this project or scenario

set val(statIntvl) 0.1 ;#statistics collection interval
set val(statStart) 0.5 ;

set val(cbrStart) 0.5 ;#CBR start time
set val(cbrIntvl) 1.0 ;#CBR traffic interval

set val(chan)           [ new Channel/WirelessChannel]    ;# channel model
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ifqlen)         50                         ;# max packet in ifq
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(nn)             3                          ;# number of mobilenodes
set val(rp)             MFlood                  ;# routing protocol
set val(topo_x_dim)	600
set val(topo_y_dim)	600

###################
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
	set node($i) [$ns node]
	$node($i) random-motion 0              ;# disable random motion
}

$node(0) set X_ 100.0
$node(0) set Y_ 250.0
$node(0) set Z_ 0.0

$node(1) set X_ 250.0
$node(1) set Y_ 250.0
$node(1) set Z_ 0.0

$node(2) set X_ 500.0
$node(2) set Y_ 250.0
$node(2) set Z_ 0.0

$ns initial_node_pos $node(0) 10
$ns initial_node_pos $node(1) 10
$ns initial_node_pos $node(2) 10

#Create a udp agent on node0
set sa [new Agent/UDP]
$ns attach-agent $node(0) $sa

# Create a CBR traffic source on node0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ $val(cbrIntvl)
$cbr0 set random_ 1
$cbr0 attach-agent $sa

#Create a Null agent (a traffic sink) on node1
set sink0 [new Agent/LossMonitor]
$ns attach-agent $node(2) $sink0

#Connet source and dest Agents
$ns connect $sa $sink0

proc record {} {
    global sink0 ns outfd val
    set bytes [$sink0 set bytes_]
    set now [$ns now]
    puts $outfd $bytes
    $sink0 set bytes_ 0
    $ns at [expr $now+$val(statIntvl)] "record"
}

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

#Schedule events for the CBR agent that starts at 0.5s and stops at 4.5s
$ns at $val(statStart) "record"
$ns at $val(cbrStart) "$cbr0 start"
$ns at $val(simDur) "$cbr0 stop"

#Call the finish procedure after 5s (of simulated time)
$ns at $val(simDur) "finish"

#
#Run the simulation
$ns run




