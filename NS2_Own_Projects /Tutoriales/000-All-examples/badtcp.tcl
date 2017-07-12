#The goal of this file is to create a simulation that performs very poorly.
#I attempt to do this here by limiting the size of single queue, the queue on
#node 2.  Since nodes 0 and 1 are transmitting through 2, this will create a lot
#of dropped packets.  This can then be observed in the trace file, badtcp.tr

#This experiment failed.  I do not know why, changing the queue size to be
#anything higher than 1 causes the trace file to be around 10 lines...opposed to
#thousands.

#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows
$ns color 1 Blue
$ns color 2 Red

#Open the nam trace file
set nf [open out.nam w]
$ns namtrace-all $nf

set tracefd [open badtcp.tr w]
$ns trace-all $tracefd

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
	#Close the trace file
        close $nf
	#Execute nam on the trace file
        #exec nam out.nam &
        exit 0
}

#Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#Create links between the nodes
$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
#$ns duplex-link $n3 $n2 1Mb 10ms SFQ
$ns duplex-link $n3 $n2 1Mb 10ms DropTail

#Limiting the queue size here
$ns queue-limit $n2 $n3 1

#Used for NAM visualization
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

#Monitor the queue for the link between node 2 and node 3
$ns duplex-link-op $n2 $n3 queuePos 0.5

#Create a UDP agent and attach it to node n0
set tcp0 [new Agent/TCP]
$tcp0 set fid_ 2
$ns attach-agent $n0 $tcp0

# Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $tcp0

#Create a UDP agent and attach it to node n1
set tcp1 [new Agent/TCP]
$tcp1 set fid_ 2
$ns attach-agent $n1 $tcp1

# Create a CBR traffic source and attach it to udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.005
$cbr1 attach-agent $tcp1

#Create a Null agent (a traffic sink) and attach it to node n3
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink

#Connect the traffic sources with the traffic sink
$ns connect $tcp0 $sink
$ns connect $tcp1 $sink

#Schedule events for the CBR agents
$ns at 0.5 "$cbr0 start"
$ns at 1.0 "$cbr1 start"
$ns at 4.0 "$cbr1 stop"
$ns at 4.5 "$cbr0 stop"
#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Run the simulation
$ns run
