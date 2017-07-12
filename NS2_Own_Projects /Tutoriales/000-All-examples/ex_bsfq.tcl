#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green
$ns color 4 Yellow
$ns color 5 Purple
$ns color 6 Orange

#Open the nam trace file
set nf [open out.nam w]
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]
set f3 [open out3.tr w]
set f4 [open out4.tr w]
set f5 [open out5.tr w]
#set f6 [open out6.tr w]
#set f7 [open out7.tr w]
#set f8 [open out8.tr w]

$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
    global ns nf f0 f1 f2 f3 f4 f5
    $ns flush-trace
    #Close the trace file
    close $nf
    close $f0
    close $f1
    close $f2
    close $f3
    close $f4
    close $f5
#    close $f6
#    close $f7
#    close $f8
    
    #Execute nam on the trace file
    exec nam out.nam &
    #Call xgraph to display the results
    exec xgraph out0.tr out1.tr out2.tr out3.tr out4.tr out5.tr -geometry 800x400 &
    exit 0
}

proc record {} {
    global sink0 sink1 sink2 sink3 sink4 sink5 f0 f1 f2 f3 f4 f5
    #Get an instance of the simulator
    set ns [Simulator instance]
    #Set the time after which the procedure should be called again
    set time 0.5
    #How many bytes have been received by the traffic sinks?
    set bw0 [$sink0 set bytes_]
    set bw1 [$sink1 set bytes_]
    set bw2 [$sink2 set bytes_]
    set bw3 [$sink3 set bytes_]
    set bw4 [$sink4 set bytes_]
    set bw5 [$sink5 set bytes_]
#    set bw6 [$sink6 set bytes_]
#    set bw7 [$sink7 set bytes_]
#    set bw8 [$sink8 set bytes_]

    #Get the current time
    set now [$ns now]
    #Calculate the bandwidth (in MBit/s) and write it to the files
    puts $f0 "$now [expr $bw0/$time*8/1000000]"
    puts $f1 "$now [expr $bw1/$time*8/1000000]"
    puts $f2 "$now [expr $bw2/$time*8/1000000]"
    puts $f3 "$now [expr $bw3/$time*8/1000000]"
    puts $f4 "$now [expr $bw4/$time*8/1000000]"
    puts $f5 "$now [expr $bw5/$time*8/1000000]"
#    puts $f6 "$now [expr $bw6/$time*8/1000000]"
#    puts $f7 "$now [expr $bw7/$time*8/1000000]"
#    puts $f8 "$now [expr $bw8/$time*8/1000000]"

    #Reset the bytes_ values on the traffic sinks
    $sink0 set bytes_ 0
    $sink1 set bytes_ 0
    $sink2 set bytes_ 0
    $sink3 set bytes_ 0
    $sink4 set bytes_ 0
    $sink5 set bytes_ 0
#    $sink6 set bytes_ 0
#    $sink7 set bytes_ 0
#    $sink8 set bytes_ 0
    #Re-schedule the procedure
    $ns at [expr $now+$time] "record"
}


#Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
#set n6 [$ns node]
#set n7 [$ns node]
#set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]

#Create links between the nodes
$ns duplex-link $n0 $n9 1Mb 10ms DropTail
$ns duplex-link $n1 $n9 1Mb 10ms DropTail
$ns duplex-link $n2 $n9 1Mb 10ms DropTail
$ns duplex-link $n3 $n9 1Mb 10ms DropTail
$ns duplex-link $n4 $n9 1Mb 10ms DropTail
$ns duplex-link $n5 $n9 1Mb 10ms DropTail
$ns duplex-link $n9 $n10 1Mb 10ms BSFQ

Simulator instproc get-link { node1 node2 } {
    $self instvar link_
    set id1 [$node1 id]
    set id2 [$node2 id]
    return $link_($id1:$id2)
}

set l [$ns get-link $n9 $n10]
set q [$l queue]
 
#$q buckets 6
#$q bandwidth 100
#$q blimit 10000
#$q mask 0
#$q quantum 0 .18
#$q quantum 1 .18
#$q quantum 2 .18
#$q quantum 3 .18
#$q quantum 4 .18
#$q quantum 5 .18

$q num_bins 50
$q delta 5
$q flwcnt 7
$q quantum 1 1000
$q quantum 2 1000
$q quantum 3 1000
$q quantum 4 1000
$q quantum 5 1000
$q quantum 6 1000

#$ns duplex-link-op $n0 $n2 orient right-down
#$ns duplex-link-op $n1 $n2 orient right-up
#$ns duplex-link-op $n2 $n3 orient right

#Monitor the queue for the link between node 2 and node 3
$ns duplex-link-op $n9 $n10 queuePos 0.5
#$ns duplex-link-op $n0 $n2 queuePos 0.5
#$ns duplex-link-op $n1 $n2 queuePos 0.5

#Create a UDP agent and attach it to node n0
set udp0 [new Agent/UDP]
$udp0 set class_ 1
$ns attach-agent $n0 $udp0
# Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 5000
$cbr0 set rate_ 1Mb
$cbr0 attach-agent $udp0

#Create a UDP agent and attach it to node n1
set udp1 [new Agent/UDP]
$udp1 set class_ 2
$ns attach-agent $n1 $udp1
# Create a CBR traffic source and attach it to udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 5000
$cbr1 set rate_ 1Mb
$cbr1 attach-agent $udp1

#Create a UDP agent and attach it to node n2
set udp2 [new Agent/UDP]
$udp2 set class_ 3
$ns attach-agent $n2 $udp2
# Create a CBR traffic source and attach it to udp2
set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 5000
$cbr2 set rate_ 1Mb
$cbr2 attach-agent $udp2

#Create a UDP agent and attach it to node n3
set udp3 [new Agent/UDP]
$udp3 set class_ 4
$ns attach-agent $n3 $udp3
# Create a CBR traffic source and attach it to udp3
set cbr3 [new Application/Traffic/CBR]
$cbr3 set packetSize_ 5000
$cbr3 set rate_ 1Mb
$cbr3 attach-agent $udp3

#Create a UDP agent and attach it to node n4
set udp4 [new Agent/UDP]
$udp4 set class_ 5
$ns attach-agent $n4 $udp4
# Create a CBR traffic source and attach it to udp4
set cbr4 [new Application/Traffic/CBR]
$cbr4 set packetSize_ 5000
$cbr4 set rate_ 1Mb
$cbr4 attach-agent $udp4

#Create a UDP agent and attach it to node n5
set udp5 [new Agent/UDP]
$udp5 set class_ 6
$ns attach-agent $n5 $udp5
# Create a CBR traffic source and attach it to udp1
set cbr5 [new Application/Traffic/CBR]
$cbr5 set packetSize_ 5000
$cbr5 set rate_ 1Mb
$cbr5 attach-agent $udp5

#Create a Null agent (a traffic sink) and attach it to node n3
set sink0 [new Agent/LossMonitor]
set sink1 [new Agent/LossMonitor]
set sink2 [new Agent/LossMonitor]
set sink3 [new Agent/LossMonitor]
set sink4 [new Agent/LossMonitor]
set sink5 [new Agent/LossMonitor]

$ns attach-agent $n10 $sink0
$ns attach-agent $n10 $sink1
$ns attach-agent $n10 $sink2
$ns attach-agent $n10 $sink3
$ns attach-agent $n10 $sink4
$ns attach-agent $n10 $sink5

#Connect the traffic sources with the traffic sink
$ns connect $udp0 $sink0  
$ns connect $udp1 $sink1
$ns connect $udp2 $sink2
$ns connect $udp3 $sink3
$ns connect $udp4 $sink4
$ns connect $udp5 $sink5

#Schedule events for the CBR agents
$ns at 0 "record"
$ns at 1 "$cbr0 start"
$ns at 2 "$cbr1 start"
$ns at 3 "$cbr2 start"
$ns at 4 "$cbr3 start"
$ns at 5 "$cbr4 start"
$ns at 6 "$cbr5 start"

$ns at 32.5 "$cbr5 stop"
$ns at 35 "$cbr4 stop"
$ns at 37.5 "$cbr3 stop"
$ns at 40 "$cbr2 stop"
$ns at 42.5 "$cbr1 stop"
$ns at 45 "$cbr0 stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 50 "finish"

#Run the simulation
$ns run

