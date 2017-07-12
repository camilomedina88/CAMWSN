# 
# withdrawals.tcl
#

puts ""
puts "WITHDRAWALS Validation Test:"
puts ""
puts " Two ASes, each with one router.  The routers are directly connected,"
puts " and are each running BGP."
puts ""
puts "       AS 0        AS 1" 
puts "        n0 }------{ n1"
puts ""


set nf [open withdrawals.nam w]
set ns [new Simulator]
$ns namtrace-all $nf

$ns node-config -BGP ON
set n0 [$ns node 0:10.0.0.1]
set n1 [$ns node 1:10.0.1.1]
$ns node-config -BGP OFF

$ns duplex-link $n0 $n1 1Mb 1ms DropTail

set bgp_agent0 [$n0 get-bgp-agent]
$bgp_agent0 bgp-id 10.0.0.1
$bgp_agent0 neighbor 10.0.1.1 remote-as 1

set bgp_agent1 [$n1 get-bgp-agent]
$bgp_agent1 bgp-id 10.0.1.1
$bgp_agent1 neighbor 10.0.0.1 remote-as 0

$ns at 0.25 "puts \"\n time: 0.25 \n n0 (ip_addr 10.0.0.1) \
                       defines a network 10.0.2.0/24.\""
$ns at 0.25 "$bgp_agent0 network 10.0.2.0/24"

$ns at 0.26 "puts \"\n time: 0.26 \n n0 (ip_addr 10.0.0.1) \
                       defines a network 10.0.5.0/24.\""
$ns at 0.26 "$bgp_agent0 network 10.0.5.0/24"

$ns at 0.27 "puts \"\n time: 0.27 \n n0 (ip_addr 10.0.0.1) \
                       defines a network 10.0.6.0/24.\""
$ns at 0.27 "$bgp_agent0 network 10.0.6.0/24"

$ns at 0.3 "puts \"\n time: 0.3 \n n1 (ip_addr 10.0.1.1) \
                       defines a network 10.0.3.0/24.\""
$ns at 0.3 "$bgp_agent1 network 10.0.3.0/24"

$ns at 0.31 "puts \"\n time: 0.31 \n n1 (ip_addr 10.0.1.1) \
                       defines a network 10.0.7.0/24.\""
$ns at 0.31 "$bgp_agent1 network 10.0.7.0/24"

$ns at 0.32 "puts \"\n time: 0.32 \n n1 (ip_addr 10.0.1.1) \
                       defines a network 10.0.8.0/24.\""
$ns at 0.32 "$bgp_agent1 network 10.0.8.0/24"

$ns at 31.0 "puts \"\n time: 31 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 31.0 "$bgp_agent0 show-routes"
$ns at 31.0 "$bgp_agent1 show-routes"

$ns at 31.25 "puts \"\n time: 31.25 \n n0 (ip_addr 10.0.0.1) \
                       withdraws the network 10.0.6.0/24.\""
$ns at 31.25 "$bgp_agent0 no-network 10.0.6.0/24"

$ns at 31.35 "puts \"\n time: 31.35 \n n1 (ip_addr 10.0.1.1) \
                       withdraws the network 10.0.3.0/24.\""
$ns at 31.35 "$bgp_agent1 no-network 10.0.3.0/24"

$ns at 62.0 "puts \"\n time: 62 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 62.0 "$bgp_agent0 show-routes"
$ns at 62.0 "$bgp_agent1 show-routes"

$ns at 70.0 "finish"

proc finish {} {
	global ns f nf
	$ns flush-trace
	close $nf
	puts "Simulation finished. Executing nam..."
	exec nam withdrawals.nam
	exit 0
}


puts "Simulation starts..."
$ns run
	
