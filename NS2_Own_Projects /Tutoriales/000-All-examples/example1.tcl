#
#Initialize and create output files
#Create a simulator instance
set ns [new Simulator]

#Crate a trace file and animation record
set tracefd [open example1.tr w]
$ns trace-all $tracefd
set namtracefd [open example1.nam w]
$ns namtrace-all $namtracefd

#
#Create Topology
#Create two nodes: n0 and n1
set n0 [$ns node]
set n1 [$ns node]

#Create a duplex link between the nodes
$ns duplex-link $n0 $n1 1Mb 10ms DropTail

#Create a udp agent on node0
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

# Create a CBR traffic source on node0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 set random_ 1
$cbr0 attach-agent $udp0

#Create a Null agent (a traffic sink) on node1
set null0 [new Agent/Null]
$ns attach-agent $n1 $null0

#Connet source and dest Agents
$ns connect $udp0 $null0  

#a procedure to close trace file and nam file
proc finish {} {

	global ns tracefd namtracefd
	$ns flush-trace

	close $tracefd
	close $namtracefd
	
	exec nam example1.nam &
	exit 0
}

#
#Specify Discrete Event Simulation here

#Schedule events for the CBR agent that starts at 0.5s and stops at 4.5s
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"

#Call the finish procedure after 5s (of simulated time)
$ns at 5.0 "finish"

#
#Run the simulation
$ns run




