#     http://ns2homeworkforbeginner.blogspot.dk/


#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Chocolate
$ns color 4 Brown
$ns color 5 Tan
$ns color 6 Gold

#Open the output files
set f0 [open CBR_MB.tr w]
set f1 [open VBR_MB.tr w]
set f3 [open out3.tr w]




#Open the nam trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
global ns nf f0 f1 f3
$ns flush-trace
#Close the trace file
close $nf
#Close the output files
close $f0
close $f1
close $f3
#Call xgraph to display the results
exec xgraph CBR_MB.tr VBR_MB.tr -geometry 800x400 &
exec xgraph out3.tr -geometry 800x400 &

#Execute nam on the trace file
exec nam out.nam &
exit 0
}


#Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]


#Create links between the nodes
$ns duplex-link $n0 $n2 3Mb 1ms DropTail
$ns duplex-link $n1 $n2 5Mb 1ms DropTail
$ns duplex-link $n3 $n2 5Mb 1ms SFQ
$ns duplex-link $n2 $n5 1Mb 5ms DropTail
$ns duplex-link $n5 $n4 4Mb 1ms DropTail
$ns duplex-link $n5 $n6 3Mb 1ms SFQ
$ns queue-limit $n1 $n2 50;
$ns queue-limit $n2 $n5 12;
$ns queue-limit $n0 $n2 50;
$ns queue-limit $n3 $n2 50;
$ns queue-limit $n5 $n4 50;
$ns queue-limit $n5 $n6 50;

$ns duplex-link-op $n0 $n2 orient right
$ns duplex-link-op $n1 $n2 orient down
$ns duplex-link-op $n3 $n2 orient up
$ns duplex-link-op $n2 $n5 orient right
$ns duplex-link-op $n5 $n4 orient right-up
$ns duplex-link-op $n5 $n6 orient right-down


#Monitor the queue for the link between node 2 and node 3
$ns duplex-link-op $n2 $n5 queuePos 0.5
$ns duplex-link-op $n1 $n2 queuePos 0.5
$ns duplex-link-op $n0 $n2 queuePos 0.5
$ns duplex-link-op $n5 $n6 queuePos 0.5
$ns duplex-link-op $n3 $n2 queuePos 0.5


#Create a UDP agent and attach it to node n0
set udp0 [new Agent/UDP]
$udp0 set class_ 1
$ns attach-agent $n0 $udp0

#Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set interval_ 0.01
$cbr0 set packetSize_ 280

$cbr0 attach-agent $udp0

#Create a TCP agent and attach it to node n1 --1 to 6
# setup TCP connections
set tcp1 [new Agent/TCP/Reno]
$tcp1 set fid_ 2
$tcp1 set window_ 40

$tcp1 set packetSize_ 280
$tcp1 set minrto_ 0.2
set sink3 [new Agent/TCPSink]
$ns attach-agent $n1 $tcp1
$ns attach-agent $n6 $sink3
$ns connect $tcp1 $sink3
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1




#Create a UDP agent and attach it to node3
set udp1 [new Agent/UDP]
$udp1 set class_ 3
$ns attach-agent $n3 $udp1

# Create a VBR traffic source and attach it to node3
set vbr1 [new Application/Traffic/Exponential]
$vbr1 set packetSize_ 280
$vbr1 set rate_ 600k
$vbr1 set burst_time_ 150ms
$vbr1 set idle_time_ 100ms
$vbr1 attach-agent $udp1

proc plotWindow {tcpsource} {
global ns f3
set time 0.01
set now [$ns now]
set cwnd [$tcpsource set cwnd_]
puts $f3 "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpsource"
}

#Define a procedure which periodically records the bandwidth received by the
#two traffic sinks sink0/1 and writes it to the three files f0/1.
proc record {} {
global sink0 sink1 f0 f1
#Get an instance of the simulator
set ns [Simulator instance]
#Set the time after which the procedure should be called again
set time 0.05
#How many bytes have been received by the traffic sinks?
set bw0 [$sink0 set bytes_]
set bw1 [$sink1 set bytes_]
#Get the current time
set now [$ns now]
#Calculate the bandwidth (in MBit/s) and write it to the files
puts $f0 "$now [expr $bw0/$time*8/1000000]"
puts $f1 "$now [expr $bw1/$time*8/1000000]"
#Reset the bytes_ values on the traffic sinks
$sink0 set bytes_ 0
$sink1 set bytes_ 0
#Re-schedule the procedure
$ns at [expr $now+$time] "record"
}

#Create 2 Loss monitors (a traffic sink) and attach them to node n6
set sink0 [new Agent/LossMonitor]
$ns attach-agent $n6 $sink0
set sink1 [new Agent/LossMonitor]
$ns attach-agent $n6 $sink1


#Connect the traffic sources with the traffic sink
$ns connect $udp0 $sink0
$ns connect $udp1 $sink1



#Start logging the received bandwidth
$ns at 0.0 "record"
$ns at 0.0 "plotWindow $tcp1"

#Schedule events for the CBR agents
$ns at 2.0 "$cbr0 start"
$ns at 0.0 "$ftp1 start"
$ns at 7.0 "$vbr1 start"


#Call the finish procedure after 5 seconds of simulation time
$ns at 7.0 "$cbr0 stop"
$ns at 15.0 "$ftp1 stop"
$ns at 11.0 "$vbr1 stop"
$ns at 18.0 "finish"

#Run the simulation
$ns run
 
