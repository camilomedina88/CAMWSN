 set ns [new Simulator -multicast on]

 set f [open out.tr w]
 $ns trace-all $f
 $ns namtrace-all [open out.nam w]

 $ns color 1 red
 # prune/graft packets
 $ns color 30 purple
 $ns color 31 bisque

 set n0 [$ns node]
 set n1 [$ns node]
 set n2 [$ns node]
 set n3 [$ns node]

 # Use automatic layout 
 $ns duplex-link $n0 $n1 1.5Mb 10ms DropTail
 $ns duplex-link $n1 $n2 1.5Mb 10ms DropTail
 $ns duplex-link $n1 $n3 1.5Mb 10ms DropTail

 $ns duplex-link-op $n0 $n1 orient right
 $ns duplex-link-op $n1 $n2 orient right-up
 $ns duplex-link-op $n1 $n3 orient right-down
 $ns duplex-link-op $n0 $n1 queuePos 0.5

 set mproto DM
 set mrthandle [$ns mrtproto $mproto {}]
 set group0 [Node allocaddr]
 set group1 [Node allocaddr]

 set udp0 [new Agent/UDP]
 $ns attach-agent $n1 $udp0
 $udp0 set dst_addr_ $group0
 $udp0 set dst_port_ 0
 set cbr0 [new Application/Traffic/CBR]
 $cbr0 attach-agent $udp0

 set udp1 [new Agent/UDP]
 $udp1 set dst_addr_ $group1
 $udp1 set dst_port_ 0
 $udp1 set class_ 1
 $ns attach-agent $n3 $udp1
 set cbr1 [new Application/Traffic/CBR]
 $cbr1 attach-agent $udp1

 set rcvr [new Agent/LossMonitor]
 $ns attach-agent $n2 $rcvr
 $ns at 1.2 "$n2 join-group $rcvr $group1"
 $ns at 1.25 "$n2 leave-group $rcvr $group1"
 $ns at 1.3 "$n2 join-group $rcvr $group1"
 $ns at 1.35 "$n2 join-group $rcvr $group0"

 $ns at 1.0 "$cbr0 start"
 #$ns at 1.001 "$cbr0 stop"
 $ns at 1.1 "$cbr1 start"

 #set tcp [new Agent/TCP]
 #set sink [new Agent/TCPSink]
 #$ns attach-agent $n0 $tcp
 #$ns attach-agent $n3 $sink
 #$ns connect $tcp $sink
 #set ftp [new Application/FTP]
 #$ftp attach-agent $tcp
 #$ns at 1.2 "$ftp start"

 #puts [$cbr0 set packetSize_]
 #puts [$cbr0 set interval_]

 $ns at 2.0 "finish"

 proc finish {} {
 global ns
 $ns flush-trace

 puts "running nam..."
 exec nam out.nam &
 exit 0
 }

 $ns run
