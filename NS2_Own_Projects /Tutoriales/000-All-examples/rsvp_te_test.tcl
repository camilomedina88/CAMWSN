set ns [new Simulator]

$ns color 0 yellow
$ns color 1 blue
$ns color 2 green
$ns color 50 black
$ns color 46 purple
$ns color 3 red
$ns color 4 magenta

set nf [open testing.nam w]
$ns namtrace-all $nf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns mpls-node]
set n5 [$ns mpls-node]
set n6 [$ns mpls-node]
set n7 [$ns mpls-node]
set n8 [$ns mpls-node]
set n9 [$ns mpls-node]
set n10 [$ns mpls-node]
set n11 [$ns mpls-node]
set n12 [$ns mpls-node]
set n13 [$ns mpls-node]
set n14 [$ns mpls-node]
set n15 [$ns mpls-node]
set n16 [$ns mpls-node]
set n17 [$ns node]
set n18 [$ns node]
set n19 [$ns node]
set n20 [$ns node]

$ns duplex-rsvp-link $n0 $n4 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n1 $n4 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n2 $n6 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n3 $n7 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n4 $n5 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n5 $n6 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n4 $n9 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n6 $n7 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n7 $n12 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n12 $n13 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n13 $n14 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n13 $n15 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n14 $n15 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n6 $n11 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n11 $n14 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n14 $n16 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n15 $n16 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n9 $n10 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n10 $n16 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n5 $n8 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n8 $n10 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n16 $n17 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n16 $n18 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n16 $n19 1Mb 10ms 0.99 1000 10000 Param Null
$ns duplex-rsvp-link $n15 $n20 1Mb 10ms 0.99 1000 10000 Param Null


# Enable upcalls on all nodes
Agent/RSVP set noisy_ 255

set rsvp0 [$n0 add-rsvp-agent]
set rsvp1 [$n1 add-rsvp-agent]
set rsvp2 [$n2 add-rsvp-agent]
set rsvp3 [$n3 add-rsvp-agent]
set rsvp4 [$n4 add-rsvp-agent]
set rsvp5 [$n5 add-rsvp-agent]
set rsvp6 [$n6 add-rsvp-agent]
set rsvp7 [$n7 add-rsvp-agent]
set rsvp8 [$n8 add-rsvp-agent]
set rsvp9 [$n9 add-rsvp-agent]
set rsvp10 [$n10 add-rsvp-agent]
set rsvp11 [$n11 add-rsvp-agent]
set rsvp12 [$n12 add-rsvp-agent]
set rsvp13 [$n13 add-rsvp-agent]
set rsvp14 [$n14 add-rsvp-agent]
set rsvp15 [$n15 add-rsvp-agent]
set rsvp16 [$n16 add-rsvp-agent]
set rsvp17 [$n17 add-rsvp-agent]
set rsvp18 [$n18 add-rsvp-agent]
set rsvp19 [$n19 add-rsvp-agent]
set rsvp20 [$n20 add-rsvp-agent]

set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
$udp0 set packetSize_ 500
$udp0 set fid_ 1
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set rate_ 400Kb
$cbr0 attach-agent $udp0

set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1
$udp1 set packetSize_ 500
$udp1 set fid_ 2
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500
$cbr1 set rate_ 400Kb
$cbr1 attach-agent $udp1

set udp2 [new Agent/UDP]
$ns attach-agent $n2 $udp2
$udp2 set packetSize_ 500
$udp2 set fid_ 3
set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 500
$cbr2 set rate_ 400Kb
$cbr2 attach-agent $udp2

set udp3 [new Agent/UDP]
$ns attach-agent $n3 $udp3
$udp3 set packetSize_ 500
$udp3 set fid_ 4
set cbr3 [new Application/Traffic/CBR]
$cbr3 set packetSize_ 500
$cbr3 set rate_ 400Kb
$cbr3 attach-agent $udp3

set sink17 [new Agent/LossMonitor]
$ns attach-agent $n17 $sink17
set sink18 [new Agent/LossMonitor]
$ns attach-agent $n18 $sink18
set sink19 [new Agent/LossMonitor]
$ns attach-agent $n19 $sink19
set sink20 [new Agent/LossMonitor]
$ns attach-agent $n20 $sink20

$ns connect $udp0 $sink17
$ns connect $udp1 $sink18
$ns connect $udp2 $sink19
$ns connect $udp3 $sink20

for {set i 4} {$i < 17} {incr i} {
	set a n$i
	set m [eval $$a get-module "MPLS"]
	eval set LSRmpls$i $m
}

proc finish {} {
        global ns nf
	close $nf
	puts "END"
        exit 0
}


$ns at 0.2    "$cbr0 start"
$ns at 50.0   "$cbr0 stop"
$ns at 0.2    "$cbr1 start"
$ns at 50.0   "$cbr1 stop"
$ns at 0.2    "$cbr2 start"
$ns at 50.0   "$cbr2 stop"
$ns at 0.2    "$cbr3 start"
$ns at 50.0   "$cbr3 stop"

$ns at 5.0 "$LSRmpls4 create-crlsp $n0 $n16 0 1 0 +400000 5000 32 4_5_8_10_16_"
$ns at 7.0 "$LSRmpls4 create-crlsp $n1 $n16 1 2 1 +400000 5000 32 4_5_6_11_14_16_"
$ns at 9.0 "$LSRmpls6 create-crlsp $n2 $n16 1 3 2 +400000 5000 32 6_7_12_13_15_16_"
$ns at 11.0 "$LSRmpls7 create-crlsp $n3 $n15 1 4 3 +400000 5000 32 7_6_11_14_15_"

$ns at 6.0 "$LSRmpls4 bind-flow-erlsp 17 1 0"
$ns at 8.0 "$LSRmpls4 bind-flow-erlsp 18 2 1"
$ns at 10.0 "$LSRmpls6 bind-flow-erlsp 19 3 2"
$ns at 12.0 "$LSRmpls7 bind-flow-erlsp 20 4 3"

$ns at 15 "$LSRmpls13 pft-dump"
$ns at 15 "$LSRmpls13 erb-dump"
$ns at 15 "$LSRmpls13 lib-dump"

$ns at 20.0 "$rsvp4 release-LSP 0 1" 

$ns at 25.0 "$LSRmpls4 create-crlsp $n0 $n16 2 1 0 +400000 5000 32 4_5_6_7_12_13_15_16_"
$ns at 26.0 "$LSRmpls4 bind-flow-erlsp 17 1 0"

$ns rtmodel-at 30.0 down $n11 $n14 
$ns at 30.0 "$rsvp11 break-link $n14"  

$ns at 28.0 "$LSRmpls4 reroute-precalc $n1 $n16 $n18 1 2 15 +400000 5000 32 4_5_8_10_16_"

$ns at 50.0 "finish"

$ns run
