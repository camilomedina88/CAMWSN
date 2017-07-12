#Note that this time changing the queue limit to numbers > 1 works.  This results
#in more dropped packets, which is what we want.

#The main purpose of this file, is to use the QueueMonitor class to monitor the
#queue from node 2 to 3.

#One interesting things is that the exact same run happens each time...the same
#number of packets are dropped.  Maybe I am doing something wrong?  With further
#investigation and data output, it is seen that exactly the same number of packets
#are generated each time, and exactly the same number are dropped/serviced.

#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows
$ns color 1 Blue
$ns color 2 Red

#Open the nam trace file
set nf [open out.nam w]
$ns namtrace-all $nf

set tracefd [open qmonitor.tr w]
$ns trace-all $tracefd

#We can also do an event trace, this may or may not be interesting and I do not
#think that it is included in the above trace-all, but it may be.
set eventfd [open events.tr w]
$ns eventtrace-all $eventfd

set q_f [open queue.tr w]

#Here we define a que monitor output procedure
proc qout {} {
   global ns tracefd qmon
   set nowtime [$ns now]
   set numpack [$qmon set pkts_]
   set sizeq [$qmon set size_]
   puts $tracefd "- $nowtime - Size of queue: $sizeq"
   puts $tracefd "- $nowtime - Packets in queue: $numpack"
}

#Define a 'finish' procedure
proc finish {} {
        global ns nf tracefd qmon
        $ns flush-trace
	#Close the trace file
        close $nf
        
        #Print out queue monitor data to the trace file
        set numdrops [$qmon set pdrops_]
        set totalpackets [$qmon set parrivals_]
        set notdrop [$qmon set pdepartures_]
        puts $tracefd "Total packets: $totalpackets"
        puts $tracefd "Nondropped packets: $notdrop"
        puts $tracefd "Dropped packets: $numdrops"
        
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

#Control the number of dropped packets here by setting max queue size
$ns queue-limit $n2 $n3 10

#Initialize the queue monitor
set qmon [$ns monitor-queue $n2 $n3 $q_f 0.1]

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

#Monitor the queue for the link between node 2 and node 3
$ns duplex-link-op $n2 $n3 queuePos 0.5

#Create a UDP agent and attach it to node n0
set udp0 [new Agent/UDP]
$udp0 set class_ 1
$ns attach-agent $n0 $udp0

# Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

#Create a UDP agent and attach it to node n1
set udp1 [new Agent/UDP]
$udp1 set class_ 2
$ns attach-agent $n1 $udp1

# Create a CBR traffic source and attach it to udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.005
$cbr1 attach-agent $udp1

#Create a Null agent (a traffic sink) and attach it to node n3
set null0 [new Agent/Null]
$ns attach-agent $n3 $null0

#Connect the traffic sources with the traffic sink
$ns connect $udp0 $null0  
$ns connect $udp1 $null0

#Schedule events for the CBR agents
$ns at 0.5 "$cbr0 start"
$ns at 1.0 "$cbr1 start"
$ns at 4.0 "$cbr1 stop"
$ns at 4.5 "$cbr0 stop"

#We want to schedule some queue output statements at 0.5 second increments.
for {set i 0} {$i < 5} {set i [expr $i+.5]} {
        $ns at $i "qout"
}

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Run the simulation
$ns run
