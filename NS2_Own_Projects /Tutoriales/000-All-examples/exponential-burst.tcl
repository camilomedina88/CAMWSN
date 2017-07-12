#     http://bhupirajput.blogspot.dk/2012/12/exponential-burst-traffic-using-ns2.html


#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red
$ns color 3 black

#Open the output files
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]


#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red
$ns color 3 black

#Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

set ne [open out.tr w]
$ns trace-all $ne

#Define a 'finish' procedure
proc finish {} {
        global ns nf ne f0 f1 f2
        $ns flush-trace
        #Close the NAM trace file
        close $nf
     close $ne
    close $f0
    close $f1
    close $f2
        #Execute NAM on the trace file
        exec nam out.nam
        exec xgraph out0.tr out1.tr out2.tr -geometry 800x400 -P -bg white &
        exit 0
}

#Create four nodes
set a1 [$ns node]
set a2 [$ns node]
set a3 [$ns node]
set r1 [$ns node]
set r2 [$ns node]
set r3 [$ns node]
set r4 [$ns node]
set r5 [$ns node]
set r6 [$ns node]
set r7 [$ns node]
set r8 [$ns node]
set v [$ns node]


#Create links between the nodes
$ns duplex-link $a1 $r1 4Mb 1ms DropTail
$ns duplex-link $a2 $r2 2Mb 1ms DropTail
$ns duplex-link $a3 $r3 2Mb 2ms DropTail
$ns duplex-link $r1 $r4 4Mb 1ms DropTail
$ns duplex-link $r2 $r5 2Mb 1ms DropTail
$ns duplex-link $r3 $r6 2Mb 2ms DropTail
$ns duplex-link $r4 $r7 4Mb 1ms DropTail
$ns duplex-link $r5 $r7 2Mb 15ms DropTail
$ns duplex-link $r6 $r8 2Mb 20ms DropTail
$ns duplex-link $r7 $v 0.7Mb 10ms SFQ
$ns duplex-link $r8 $v 0.7Mb 15ms SFQ

# --------------LABELLING -----------------------------#

$ns at 0.0 "$a1 label a1"
$ns at 0.0 "$a2 label a2"
$ns at 0.0 "$a3 label a3"
$ns at 0.0 "$r1 label r1"
$ns at 0.0 "$r2 label r2"
$ns at 0.0 "$r3 label r3"
$ns at 0.0 "$r4 label r4"
$ns at 0.0 "$r5 label r5"
$ns at 0.0 "$r6 label r6"
$ns at 0.0 "$r7 label r7"
$ns at 0.0 "$r8 label r8"
$ns at 0.0 "$v label v"

#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $r1 $r4 20
$ns queue-limit $r2 $r5 20
$ns queue-limit $r3 $r6 20
$ns queue-limit $r4 $r7 20
$ns queue-limit $r5 $r7 20
$ns queue-limit $r6 $r8 20
$ns queue-limit $v $r7 10
$ns queue-limit $v $r8 20

#Give node position (for NAM)
$ns duplex-link-op $v $r7 orient left-up
$ns duplex-link-op $v $r8 orient left-down
$ns duplex-link-op $r7 $r4 orient left-up
$ns duplex-link-op $r7 $r5 orient left-down
$ns duplex-link-op $r4 $r1 orient left
$ns duplex-link-op $r5 $r2 orient left
$ns duplex-link-op $r1 $a1 orient left-up
$ns duplex-link-op $r2 $a2 orient left
$ns duplex-link-op $r8 $r6 orient left-down
$ns duplex-link-op $r6 $r3 orient left
$ns duplex-link-op $r3 $a3 orient left

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $r4 $r7 queuePos 0.5
$ns duplex-link-op $r5 $r7 queuePos 0.5
$ns duplex-link-op $r7 $v  queuePos 0.5
$ns duplex-link-op $r8 $v  queuePos 0.5


proc attach-expoo-traffic { node sink size burst idle rate } {
    #Get an instance of the simulator
    set ns [Simulator instance]

    #Create a UDP agent and attach it to the node
    set source [new Agent/UDP]
    $ns attach-agent $node $source

    #Create an Expoo traffic agent and set its configuration parameters
    set traffic [new Application/Traffic/Exponential]
    $traffic set packetSize_ $size
    $traffic set burst_time_ $burst
    $traffic set idle_time_ $idle
    $traffic set rate_ $rate
       
        # Attach traffic source to the traffic generator
        $traffic attach-agent $source
    #Connect the source and the sink
    $ns connect $source $sink
    return $traffic
}


proc record {} {
        global sink0 sink1 sink2 f0 f1 f2
    #Get an instance of the simulator
    set ns [Simulator instance]
    #Set the time after which the procedure should be called again
        set time 0.5
    #How many bytes have been received by the traffic sinks?
        set bw0 [$sink0 set bytes_]
        set bw1 [$sink1 set bytes_]
        set bw2 [$sink2 set bytes_]
    #Get the current time
        set now [$ns now]
    #Calculate the bandwidth (in MBit/s) and write it to the files
        puts $f0 "$now [expr $bw0/$time*8/1000000]"
        puts $f1 "$now [expr $bw1/$time*8/1000000]"
        puts $f2 "$now [expr $bw2/$time*8/1000000]"
    #Reset the bytes_ values on the traffic sinks
        $sink0 set bytes_ 0
        $sink1 set bytes_ 0
        $sink2 set bytes_ 0
    #Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}

#Create three traffic sinks and attach them to the node n4
set sink0 [new Agent/LossMonitor]
set sink1 [new Agent/LossMonitor]
set sink2 [new Agent/LossMonitor]
$ns attach-agent $v $sink0
$ns attach-agent $v $sink1
$ns attach-agent $v $sink2

#Create three traffic sources
set source0 [attach-expoo-traffic $a1 $sink0 2000 2s 1s 1000k]
set source1 [attach-expoo-traffic $a2 $sink1 2000 2s 1s 2000k]
set source2 [attach-expoo-traffic $a3 $sink2 2000 2s 1s 3000k]


#Start logging the received bandwidth
$ns at 0.0 "record"
#Start the traffic sources
$ns at 10.0 "$source0 start"
$ns at 10.0 "$source1 start"
$ns at 10.0 "$source2 start"
#Stop the traffic sources
$ns at 50.0 "$source0 stop"
$ns at 50.0 "$source1 stop"
$ns at 50.0 "$source2 stop"
#Call the finish procedure after 60 seconds simulation time
$ns at 60.0 "finish"




#Run the simulation
$ns run 
