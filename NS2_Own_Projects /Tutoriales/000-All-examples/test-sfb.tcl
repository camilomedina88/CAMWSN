#Illustrates use of Stochastic Fair Blue (SFB)
#TCP Senders are TCP-SACK , and receivers are TCP-SACK sinks

#non TCP senders are UDP
#Test uses 5 TCP (responsive) flows and one 
#non-responsive flow (UDP)

set ns [new Simulator]

# turn on ns and nam tracing
set f [open out.tr w]
$ns trace-all $f
$ns namtrace-all [open out.nam w]

#set the no of TCP flows here
set nodenum 5

#set no. of non TCP flows here
set nontcp 1

set start_time 1.0
set finish_time 100

# create the nodes
#First create TCP senders and receivers

for {set i 0} {$i < $nodenum} {incr i} {
    
    set s($i) [$ns node]
    set r($i) [$ns node]
}

#create non TCP senders and receivers here
for {set i 0} {$i < $nontcp} {incr i} {
    
    set nons($i) [$ns node]
    set nonr($i) [$ns node]
}


#Create back-bone routers
set n1 [$ns node]
set n2 [$ns node]


# create the links 
#betwwen the senders and n1, receivers and n2
for {set i 0} {$i < $nodenum} {incr i} {

    $ns duplex-link $s($i) $n1 10Mb 1ms DropTail
    $ns duplex-link $r($i) $n2 10Mb 1ms DropTail

}

for {set i 0} {$i < $nontcp} {incr i} {
    
    $ns duplex-link $nons($i) $n1 10Mb 1ms DropTail
    $ns duplex-link $nonr($i) $n2 10Mb 1ms DropTail
}

#Bottle-neck between n1 and n2
$ns simplex-link $n1 $n2 1Mbps 100ms SFB
$ns simplex-link $n2 $n1 1Mbps 100ms DropTail


#configure SFB parameters here
set sfbq [[$ns link $n1 $n2] queue]
$sfbq set decrement 0.001
$sfbq set increment 0.005
$sfbq set hold-time 100ms
#Enable ECN here
$sfbq set setbit true


#pbox-time should be vaaried according to the bandwidth
#to be assigned to non-responsive flows. This represents the duration 
#when packets from rogue flows will not be queued.
$sfbq set pbox-time 50ms

#hinterval variation will influence how soon
#non-responsive flows are first detected.
$sfbq set hinterval 20s


#set the queue-limit between n1 and n2
$ns queue-limit $n1 $n2 50

#set up queue monitor, sample every 0.5 seconds
set qfile [open "test-sfb-qsize.out" w]
set qm [$ns monitor-queue $n1 $n2 $qfile 0.5]
[$ns link $n1 $n2] queue-sample-timeout 

#create the random number generator
set rng [new RNG]

# create TCP agents
for {set i 0} {$i < $nodenum} {incr i} {

    set tcp($i) [new Agent/TCP/Sack1]
    $tcp($i) set fid_ [expr ($i + 1)]
    $tcp($i) set ecn_ 1
    set sink($i) [new Agent/TCPSink/Sack1/DelAck]
    $sink($i) set ecn_ 1
    $ns attach-agent $s($i) $tcp($i)
    $ns attach-agent $r($i) $sink($i)
    $ns connect $tcp($i) $sink($i)
    set ftp($i) [new Application/FTP]
    $ftp($i) attach-agent $tcp($i)
    #set p($i) [new Application/Traffic/Pareto]
    #$p($i) set packetSize_ 1000
    #$p($i) set burst_time_ 200ms
    #$p($i) set idle_time_ 200ms
    #$p($i) set shape_ 1.5
    #$p($i) set rate_ 10000K
    #$p($i) attach-agent $tcp($i)
    set start_time [$rng uniform 0 1]
    $ns at $start_time "$ftp($i) start"
    #$ns at $start_time "$p($i) start"
}


#create non TCP agents (UDP)
for {set i 0} {$i < $nontcp} {incr i} {
set udp($i) [new Agent/UDP]
$ns attach-agent $nons($i) $udp($i)
set udpsink($i) [new Agent/UDP]
$ns attach-agent $nonr($i) $udpsink($i)
$ns connect $udp($i) $udpsink($i)
set cbr($i) [new Application/Traffic/CBR]
$cbr($i) set packetSize_ 1000
$cbr($i) attach-agent $udp($i)
set start_time2 [$rng uniform 0 1]
$ns at $start_time2 "$cbr($i) start"
}


$ns at $finish_time "finish"

proc finish {} {
    global ns sink nodenum qfile nontcp
    $ns flush-trace
    close $qfile
    #puts "running nam..."
    #exec nam out.nam &
    #    exec xgraph *.tr -geometry 800x400 &
    exit 0
}

$ns run


