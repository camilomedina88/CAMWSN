#
# reflection2.tcl
# 

puts ""
puts "REFLECTION2 VALIDATION TEST:"
puts ""
puts " Three ASes(AS0, AS1 and AS2) connected in a line, the middle "
puts " one(AS0) containing eight BGP routers, the others just one each."
puts " AS0 has two clusters: cluster 1000 and 2000. Cluster 1000 has "
puts " two reflectors: n0 and n1. n2, n3 and n4 are reflection clients of "
puts " both n0 and n1. Cluster 2000 contains one reflector n5, which has"
puts " n6 and n7 as its reflection clients. "
puts ""
puts "        AS 1         AS 0         AS 2 "   
puts "         n8 }------{ n0-7 }------{ n9 "
puts ""

set nf [open reflection2.nam w]
set ns [new Simulator]
$ns namtrace-all $nf
 
$ns node-config -BGP ON
set n0 [$ns node 0:10.0.0.1]
set n1 [$ns node 0:10.0.1.1]
set n2 [$ns node 0:10.0.2.1]
set n3 [$ns node 0:10.0.3.1]
set n4 [$ns node 0:10.0.4.1]
set n5 [$ns node 0:10.0.5.1]
set n6 [$ns node 0:10.0.6.1]
set n7 [$ns node 0:10.0.7.1]
set n8 [$ns node 1:10.0.8.1]
set n9 [$ns node 2:10.0.9.1]
$ns node-config -BGP OFF
set n10 [$ns node 1:10.0.8.2]

## SETUP INTER-REFRECTOR LINKS
$ns duplex-link $n0 $n1 1Mb 1ms DropTail
$ns duplex-link $n0 $n5 1Mb 1ms DropTail
$ns duplex-link $n1 $n5 1Mb 1ms DropTail

## SETUP REFRECTOR-CLIENT LINKS
$ns duplex-link $n0 $n2 1Mb 1ms DropTail
$ns duplex-link $n0 $n3 1Mb 1ms DropTail
$ns duplex-link $n0 $n4 1Mb 1ms DropTail
$ns duplex-link $n1 $n2 1Mb 1ms DropTail
$ns duplex-link $n1 $n3 1Mb 1ms DropTail
$ns duplex-link $n1 $n4 1Mb 1ms DropTail
$ns duplex-link $n5 $n6 1Mb 1ms DropTail
$ns duplex-link $n5 $n7 1Mb 1ms DropTail

## SETUP INTRA-AS LINKS
$ns duplex-link $n8 $n10 1Mb 1ms DropTail

## SETUP EBGP LINKS
$ns duplex-link $n2 $n8 1Mb 1ms DropTail
$ns duplex-link $n7 $n9 1Mb 1ms DropTail

## SETUP REFRECTORS
set bgp_agent0 [$n0 get-bgp-agent]
$bgp_agent0 bgp-id 10.0.0.1
$bgp_agent0 cluster-id 1000
$bgp_agent0 neighbor 10.0.2.1 route-reflector-client   
$bgp_agent0 neighbor 10.0.3.1 route-reflector-client
$bgp_agent0 neighbor 10.0.4.1 route-reflector-client
$bgp_agent0 neighbor 10.0.1.1 remote-as 0
$bgp_agent0 neighbor 10.0.5.1 remote-as 0

set bgp_agent1 [$n1 get-bgp-agent]
$bgp_agent1 bgp-id 10.0.1.1
$bgp_agent1 cluster-id 1000
$bgp_agent1 neighbor 10.0.2.1 route-reflector-client   
$bgp_agent1 neighbor 10.0.3.1 route-reflector-client
$bgp_agent1 neighbor 10.0.4.1 route-reflector-client
$bgp_agent1 neighbor 10.0.0.1 remote-as 0
$bgp_agent1 neighbor 10.0.5.1 remote-as 0

set bgp_agent5 [$n5 get-bgp-agent]
$bgp_agent5 bgp-id 10.0.5.1
$bgp_agent1 cluster-id 2000
$bgp_agent5 neighbor 10.0.6.1 route-reflector-client
$bgp_agent5 neighbor 10.0.7.1 route-reflector-client
$bgp_agent5 neighbor 10.0.1.1 remote-as 0
$bgp_agent5 neighbor 10.0.0.1 remote-as 0

## SETUP CLIENTS
set bgp_agent2 [$n2 get-bgp-agent]
$bgp_agent2 bgp-id 10.0.2.1
$bgp_agent2 neighbor 10.0.0.1 remote-as 0
$bgp_agent2 neighbor 10.0.1.1 remote-as 0
$bgp_agent2 neighbor 10.0.8.1 remote-as 1

set bgp_agent3 [$n3 get-bgp-agent]
$bgp_agent3 bgp-id 10.0.3.1
$bgp_agent3 neighbor 10.0.0.1 remote-as 0
$bgp_agent3 neighbor 10.0.1.1 remote-as 0

set bgp_agent4 [$n4 get-bgp-agent]
$bgp_agent4 bgp-id 10.0.4.1
$bgp_agent4 neighbor 10.0.0.1 remote-as 0
$bgp_agent4 neighbor 10.0.1.1 remote-as 0

set bgp_agent6 [$n6 get-bgp-agent]
$bgp_agent6 bgp-id 10.0.6.1
$bgp_agent6 neighbor 10.0.5.1 remote-as 0

set bgp_agent7 [$n7 get-bgp-agent]
$bgp_agent7 bgp-id 10.0.7.1
$bgp_agent7 neighbor 10.0.5.1 remote-as 0
$bgp_agent7 neighbor 10.0.9.1 remote-as 2

## SETUP EBGP'S
set bgp_agent8 [$n8 get-bgp-agent]
$bgp_agent8 bgp-id 10.0.8.1
$bgp_agent8 neighbor 10.0.2.1 remote-as 0

set bgp_agent9 [$n9 get-bgp-agent]
$bgp_agent9 bgp-id 10.0.9.1
$bgp_agent9 neighbor 10.0.7.1 remote-as 0

set udp0 [new Agent/UDP]
$udp0 set dst_addr_ [$n4 strtoaddr 10.0.8.2]
$udp0 set dst_port_ 0

set null0 [new Agent/Null]
$ns attach-agent $n10 $null0
$ns connect $udp0 $null0

set cbr0 [ new Application/Traffic/CBR]
$cbr0 set packetSize_ 20
$cbr0 set interval_ 0.001
$cbr0 attach-agent $udp0

$ns attach-agent $n4 $udp0

## The following command try to let cbr0 in n4 send out udp segments to 
## the destination n10 before n4 knows the route to network 10.0.8.0/24.
## In order to avoid the no-slot handler of classifier in n4, we need to  
## comment out the following line in Classifier::find(Packet* p) in the 
## file classifier/classifier.cc and recompile.
##      // Tcl::instance().evalf("%s no-slot %ld", name(), cl);

$ns at 0.23 "puts \"\n time: 0.23 \
                    \n cbr0 starts to send UDP segments to n10.\""
$ns at 0.23 "$cbr0 start"

$ns at 0.25 "puts \"\n time: 0.25 \n n8 (ip_addr 10.0.8.1) \
                       defines a network 10.0.8.0/24.\""
$ns at 0.25 "$bgp_agent8 network 10.0.8.0/24"

$ns at 0.35 "puts \"\n time: 0.35 \n n9 (ip_addr 10.0.9.1) \
                       defines a network 10.0.9.0/24.\""
$ns at 0.35 "$bgp_agent9 network 10.0.9.0/24"

$ns at 20.0 "puts \"\n time: 20 \n cbr0 stops.\""
$ns at 20.0 "$cbr0 stop"

$ns at 31.0 "puts \"\n time: 31 
                    \n dump routing tables in all BGP agents: \n\""
$ns at 31.0 "$bgp_agent0 show-routes"
$ns at 31.0 "$bgp_agent1 show-routes"
$ns at 31.0 "$bgp_agent2 show-routes"
$ns at 31.0 "$bgp_agent3 show-routes"
$ns at 31.0 "$bgp_agent4 show-routes"
$ns at 31.0 "$bgp_agent5 show-routes"
$ns at 31.0 "$bgp_agent6 show-routes"
$ns at 31.0 "$bgp_agent7 show-routes"
$ns at 31.0 "$bgp_agent8 show-routes"
$ns at 31.0 "$bgp_agent9 show-routes"

$ns at 40.0 "finish"

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	puts "Simulation finished. Executing nam..."
	exec nam reflection2 
	exit 0
}

puts "Simulation starts..."
$ns run
	
