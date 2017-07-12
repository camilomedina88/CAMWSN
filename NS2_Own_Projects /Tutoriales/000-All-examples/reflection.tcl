#
# reflection.tcl
#

puts ""
puts "REFLECTION Validation Test:"
puts ""
puts " Four ASes, three with a single BGP router and the other with a more"
puts " complex internal structure of route reflection clusters."
puts ""


set nf [open reflection.nam w]
set ns [new Simulator]
$ns namtrace-all $nf
 
$ns node-config -BGP ON
set n0 [$ns node 0:10.0.0.1]
set n1 [$ns node 0:10.0.1.1]
set n2 [$ns node 0:10.0.2.1]
set n3 [$ns node 0:10.0.3.1]
set n4 [$ns node 0:10.0.4.1]
set n5 [$ns node 0:10.0.5.1]
set n6 [$ns node 1:10.0.6.1]
set n7 [$ns node 2:10.0.7.1]
set n8 [$ns node 3:10.0.8.1]
$ns node-config -BGP OFF

## SETUP INTER-REFRECTOR LINKS
$ns duplex-link $n0 $n1 1Mb 1ms DropTail
$ns duplex-link $n0 $n2 1Mb 1ms DropTail
$ns duplex-link $n1 $n2 1Mb 1ms DropTail

## SETUP REFRECTOR-CLIENT LINKS
$ns duplex-link $n0 $n3 1Mb 1ms DropTail
$ns duplex-link $n0 $n4 1Mb 1ms DropTail
$ns duplex-link $n1 $n5 1Mb 1ms DropTail

## SETUP EBGP LINKS
$ns duplex-link $n3 $n6 1Mb 1ms DropTail
$ns duplex-link $n4 $n7 1Mb 1ms DropTail
$ns duplex-link $n5 $n8 1Mb 1ms DropTail

## SETUP REFRECTORS
set bgp_agent0 [$n0 get-bgp-agent]
$bgp_agent0 bgp-id 10.0.0.1
$bgp_agent0 cluster-id 1000
$bgp_agent0 neighbor 10.0.3.1 route-reflector-client   
$bgp_agent0 neighbor 10.0.4.1 route-reflector-client
$bgp_agent0 neighbor 10.0.1.1 remote-as 0
$bgp_agent0 neighbor 10.0.2.1 remote-as 0

set bgp_agent1 [$n1 get-bgp-agent]
$bgp_agent1 bgp-id 10.0.1.1
$bgp_agent1 cluster-id 1001
$bgp_agent1 neighbor 10.0.5.1 route-reflector-client   
$bgp_agent1 neighbor 10.0.0.1 remote-as 0
$bgp_agent1 neighbor 10.0.2.1 remote-as 0

set bgp_agent2 [$n2 get-bgp-agent]
$bgp_agent2 bgp-id 10.0.5.1
$bgp_agent2 cluster-id 1002
$bgp_agent2 neighbor 10.0.0.1 remote-as 0
$bgp_agent2 neighbor 10.0.1.1 remote-as 0

## SETUP CLIENTS
set bgp_agent3 [$n3 get-bgp-agent]
$bgp_agent3 bgp-id 10.0.3.1
$bgp_agent3 neighbor 10.0.0.1 remote-as 0
$bgp_agent3 neighbor 10.0.6.1 remote-as 1

set bgp_agent4 [$n4 get-bgp-agent]
$bgp_agent4 bgp-id 10.0.4.1
$bgp_agent4 neighbor 10.0.0.1 remote-as 0
$bgp_agent4 neighbor 10.0.7.1 remote-as 2

set bgp_agent5 [$n5 get-bgp-agent]
$bgp_agent5 bgp-id 10.0.5.1
$bgp_agent5 neighbor 10.0.1.1 remote-as 0
$bgp_agent5 neighbor 10.0.8.1 remote-as 3

## SETUP EBGP'S
set bgp_agent6 [$n6 get-bgp-agent]
$bgp_agent6 bgp-id 10.0.6.1
$bgp_agent6 neighbor 10.0.3.1 remote-as 0

set bgp_agent7 [$n7 get-bgp-agent]
$bgp_agent7 bgp-id 10.0.7.1
$bgp_agent7 neighbor 10.0.4.1 remote-as 0

set bgp_agent8 [$n8 get-bgp-agent]
$bgp_agent8 bgp-id 10.0.8.1
$bgp_agent8 neighbor 10.0.5.1 remote-as 0

$ns at 0.25 "puts \"\n time: 0.25 \n n6 (ip_addr 10.0.6.1) \
                       defines a network 10.0.6.0/24.\""
$ns at 0.25 "$bgp_agent6 network 10.0.6.0/24"

$ns at 0.25 "puts \"\n time: 0.25 \n n7 (ip_addr 10.0.7.1) \
                       defines a network 10.0.7.0/24.\""
$ns at 0.25 "$bgp_agent7 network 10.0.7.0/24"

$ns at 0.25 "puts \"\n time: 0.25 \n n8 (ip_addr 10.0.8.1) \
                       defines a network 10.0.8.0/24.\""
$ns at 0.25 "$bgp_agent8 network 10.0.8.0/24"

$ns at 31.0 "puts \"\n time: 31 \
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

$ns at 40.0 "finish"

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	puts "Simulation finished. Executing nam..."
	#exec nam reflection 
	exit 0
}

puts "Simulation starts..."
$ns run
	
