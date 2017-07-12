# 
# damping2.tcl
# note that running this script will generate huge amount of output, much of which
# is chiefly for debugging purpose
#

puts ""
puts "Route Flap Damping Validation Test:"
puts ""
puts " Four ASes, each with one router. The routers are connected in a"
puts " T-shaped fashion, and are each running BGP."
puts ""
puts "      AS 2          AS 0        AS 1" 
puts "       n2 }--------{ n0 }-------{ n1"
puts "                     | "
puts "                     | "
puts "                     | "
puts "                   { n3 } "
puts "                    AS 3  "


set nf [open damping2.nam w]
set ns [new Simulator]
$ns namtrace-all $nf

$ns node-config -BGP ON
set n0 [$ns node 0:10.0.0.4]
set n1 [$ns node 1:10.0.1.3]
set n2 [$ns node 2:10.0.2.2]
set n3 [$ns node 3:10.0.3.1]
$ns node-config -BGP OFF

$ns duplex-link $n0 $n1 1Mb 1ms DropTail
$ns duplex-link $n2 $n0 1Mb 1ms DropTail
$ns duplex-link $n0 $n3 1Mb 1ms DropTail

set bgp_agent0 [$n0 get-bgp-agent]
$bgp_agent0 bgp-id 10.0.0.4
$bgp_agent0 neighbor 10.0.1.3 remote-as 1
$bgp_agent0 neighbor 10.0.2.2 remote-as 2
$bgp_agent0 neighbor 10.0.3.1 remote-as 3
$bgp_agent0 dampening 2 0 3000 750 900 1000 500 3600

set bgp_agent1 [$n1 get-bgp-agent]
$bgp_agent1 bgp-id 10.0.1.3
$bgp_agent1 neighbor 10.0.0.4 remote-as 0
$bgp_agent1 dampening 2 0 3000 750 900 1000 500 3600

set bgp_agent2 [$n2 get-bgp-agent]
$bgp_agent2 bgp-id 10.0.2.2
$bgp_agent2 neighbor 10.0.0.4 remote-as 0
$bgp_agent2 dampening 2 0 3000 750 900 1000 500 3600

set bgp_agent3 [$n3 get-bgp-agent]
$bgp_agent3 bgp-id 10.0.3.1
$bgp_agent3 neighbor 10.0.0.4 remote-as 0
$bgp_agent3 dampening 2 0 3000 750 900 1000 500 3600

$ns at 0.25 "puts \"\n time: 0.25 \n n0 (ip_addr 10.0.0.4) \
                       defines a network 10.0.4.0/24.\""
$ns at 0.25 "$bgp_agent0 network 10.0.4.0/24"

$ns at 0.26 "puts \"\n time: 0.26 \n n0 (ip_addr 10.0.0.4) \
                       defines a network 10.0.5.0/24.\""
$ns at 0.26 "$bgp_agent0 network 10.0.5.0/24"

$ns at 0.27 "puts \"\n time: 0.27 \n n0 (ip_addr 10.0.0.4) \
                       defines a network 10.0.6.0/24.\""
$ns at 0.27 "$bgp_agent0 network 10.0.6.0/24"

$ns at 0.3 "puts \"\n time: 0.3 \n n1 (ip_addr 10.0.1.3) \
                       defines a network 10.0.9.0/24.\""
$ns at 0.3 "$bgp_agent1 network 10.0.9.0/24"

$ns at 0.31 "puts \"\n time: 0.31 \n n1 (ip_addr 10.0.1.3) \
                       defines a network 10.0.7.0/24.\""
$ns at 0.31 "$bgp_agent1 network 10.0.7.0/24"

$ns at 0.32 "puts \"\n time: 0.32 \n n1 (ip_addr 10.0.1.3) \
                       defines a network 10.0.8.0/24.\""
$ns at 0.32 "$bgp_agent1 network 10.0.8.0/24"

$ns at 0.35 "puts \"\n time: 0.35 \n n2 (ip_addr 10.0.2.2) \
                       defines a network 10.1.7.0/24.\""
$ns at 0.35 "$bgp_agent2 network 10.1.7.0/24"

$ns at 0.37 "puts \"\n time: 0.37 \n n2 (ip_addr 10.0.2.2) \
                       defines a network 10.1.8.0/24.\""
$ns at 0.37 "$bgp_agent2 network 10.1.8.0/24"

$ns at 62.0 "puts \"\n time: 62 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 62.0 "$bgp_agent0 show-routes"
$ns at 62.0 "$bgp_agent0 show-all"
$ns at 62.0 "$bgp_agent1 show-routes"
$ns at 62.0 "$bgp_agent1 show-all"
$ns at 62.0 "$bgp_agent2 show-routes"
$ns at 62.0 "$bgp_agent2 show-all"
$ns at 62.0 "$bgp_agent3 show-routes"
$ns at 62.0 "$bgp_agent3 show-all"

$ns at 62.05 "puts \"\n time: 62.05 \n n2 (ip_addr 10.0.2.2) \
                       withdraws the network 10.1.7.0/24.\""
$ns at 62.05 "$bgp_agent2 no-network 10.1.7.0/24"

$ns at 62.85 "puts \"\n time: 62.85 \n n1 (ip_addr 10.0.1.3) \
                       withdraws the network 10.0.7.0/24.\""
$ns at 62.85 "$bgp_agent1 no-network 10.0.7.0/24"

$ns at 66.0 "puts \"\n time: 66 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 66.0 "$bgp_agent0 show-routes"
$ns at 66.0 "$bgp_agent0 show-all"
$ns at 66.0 "$bgp_agent1 show-routes"
$ns at 66.0 "$bgp_agent1 show-all"
$ns at 66.0 "$bgp_agent2 show-routes"
$ns at 66.0 "$bgp_agent2 show-all"
$ns at 66.0 "$bgp_agent3 show-routes"
$ns at 66.0 "$bgp_agent3 show-all"

$ns at 95.0 "puts \"\n time: 95.0 \n n1 (ip_addr 10.0.1.3) \
                       advertises the network 10.0.7.0/24.\""
$ns at 95.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 100.0 "puts \"\n time: 100 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 100.0 "$bgp_agent0 show-routes"
$ns at 100.0  "$bgp_agent0 show-all"
$ns at 100.0 "$bgp_agent1 show-routes"
$ns at 100.0 "$bgp_agent1 show-all"
$ns at 100.0 "$bgp_agent2 show-routes"
$ns at 100.0 "$bgp_agent2 show-all"
$ns at 100.0 "$bgp_agent3 show-routes"
$ns at 100.0 "$bgp_agent3 show-all"

$ns at 200.0 "puts \"\n time: 200.0 \n n1 (ip_addr 10.0.1.3) \
                       advertises the network 10.0.7.0/24.\""
$ns at 200.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 210.0 "puts \"\n time: 210 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 210.0 "$bgp_agent0 show-routes"
$ns at 210.0 "$bgp_agent0 show-all"
$ns at 210.0 "$bgp_agent0 show-damping"
$ns at 210.0 "$bgp_agent1 show-routes"
$ns at 210.0 "$bgp_agent1 show-all"
$ns at 210.0 "$bgp_agent1 show-damping"
$ns at 210.0 "$bgp_agent2 show-routes"
$ns at 210.0 "$bgp_agent2 show-all"
$ns at 210.0 "$bgp_agent2 show-damping"
$ns at 210.0 "$bgp_agent3 show-routes"
$ns at 210.0 "$bgp_agent3 show-all"
$ns at 210.0 "$bgp_agent3 show-damping"


$ns at 250.0 "puts \"\n time: 250.0 \n n1 (ip_addr 10.0.1.3) \
                       withdraws the network 10.0.7.0/24.\""
$ns at 250.0  "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 260.0 "puts \"\n time: 260 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 260.0 "$bgp_agent0 show-routes"
$ns at 260.0  "$bgp_agent0 show-all"
$ns at 260.0 "$bgp_agent1 show-routes"
$ns at 260.0 "$bgp_agent1 show-all"
$ns at 260.0 "$bgp_agent2 show-routes"
$ns at 260.0 "$bgp_agent2 show-all"
$ns at 260.0 "$bgp_agent3 show-routes"
$ns at 260.0 "$bgp_agent3 show-all"

$ns at 300.0 "puts \"\n time: 300.0 \n n1 (ip_addr 10.0.1.3) \
                       advertises the network 10.0.7.0/24.\""
$ns at 300.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 340.0 "puts \"\n time: 340 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 340.0 "$bgp_agent0 show-routes"
$ns at 340.0 "$bgp_agent0 show-all"
$ns at 340.0 "$bgp_agent0 show-damping"
$ns at 340.0 "$bgp_agent1 show-routes"
$ns at 340.0 "$bgp_agent1 show-all"
$ns at 340.0 "$bgp_agent1 show-damping"
$ns at 340.0 "$bgp_agent2 show-routes"
$ns at 340.0 "$bgp_agent2 show-all"
$ns at 340.0 "$bgp_agent2 show-damping"
$ns at 340.0 "$bgp_agent3 show-routes"
$ns at 340.0 "$bgp_agent3 show-all"
$ns at 340.0 "$bgp_agent3 show-damping"

$ns at 350.0 "puts \"\n time: 350.0 \n n1 (ip_addr 10.0.1.3) \
                       begins to have a series of advertisements and \
		       withdrawals regarding the network 10.0.7.0/24.\""
$ns at 350.0  "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 400.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 450.0  "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 500.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 550.0  "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 600.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 650.0  "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 700.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 750.0  "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 800.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 850.0 "puts \"\n time: 850 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 850.0 "$bgp_agent0 show-routes"
$ns at 850.0 "$bgp_agent0 show-all"
$ns at 850.0 "$bgp_agent0 show-damping"
$ns at 850.0 "$bgp_agent1 show-routes"
$ns at 850.0 "$bgp_agent1 show-all"
$ns at 850.0 "$bgp_agent1 show-damping"
$ns at 850.0 "$bgp_agent2 show-routes"
$ns at 850.0 "$bgp_agent2 show-all"
$ns at 850.0 "$bgp_agent2 show-damping"
$ns at 850.0 "$bgp_agent3 show-routes"
$ns at 850.0 "$bgp_agent3 show-all"
$ns at 850.0 "$bgp_agent3 show-damping"

$ns at 1200.0 "puts \"\n time: 1200.0 \n n2 (ip_addr 10.0.2.2) \
                       begins to have a series of advertisements and \
		       withdrawals regarding the network 10.1.7.0/24.\""
$ns at  1200.0 "$bgp_agent2 network 10.1.7.0/24"
$ns at  1300.0 "$bgp_agent2 no-network 10.1.7.0/24"
$ns at  1400.0 "$bgp_agent2 network 10.1.7.0/24"
$ns at  1500.0 "$bgp_agent2 no-network 10.1.7.0/24"
$ns at  1600.0 "$bgp_agent2 network 10.1.7.0/24"
$ns at  1700.0 "$bgp_agent2 no-network 10.1.7.0/24"
$ns at  1800.0 "$bgp_agent2 network 10.1.7.0/24"
$ns at  1900.0 "$bgp_agent2 no-network 10.1.7.0/24"
$ns at  2000.0 "$bgp_agent2 network 10.1.7.0/24"

$ns at 2005.0 "puts \"\n time: 2005 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 2005.0 "$bgp_agent0 show-routes"
$ns at 2005.0  "$bgp_agent0 show-all"
$ns at 2005.0 "$bgp_agent0 show-damping"
$ns at 2005.0 "$bgp_agent1 show-routes"
$ns at 2005.0  "$bgp_agent1 show-all"
$ns at 2005.0 "$bgp_agent1 show-damping"
$ns at 2005.0 "$bgp_agent2 show-routes"
$ns at 2005.0  "$bgp_agent2 show-all"
$ns at 2005.0 "$bgp_agent2 show-damping"
$ns at 2005.0 "$bgp_agent3 show-routes"
$ns at 2005.0  "$bgp_agent3 show-all"
$ns at 2005.0 "$bgp_agent3 show-damping"


$ns at 3500.0 "puts \"\n time: 3500 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 3500.0 "$bgp_agent0 show-routes"
$ns at 3500.0  "$bgp_agent0 show-all"
$ns at 3500.0 "$bgp_agent0 show-damping"
$ns at 3500.0 "$bgp_agent1 show-routes"
$ns at 3500.0  "$bgp_agent1 show-all"
$ns at 3500.0 "$bgp_agent1 show-damping"
$ns at 3500.0 "$bgp_agent2 show-routes"
$ns at 3500.0  "$bgp_agent2 show-all"
$ns at 3500.0 "$bgp_agent2 show-damping"
$ns at 3500.0 "$bgp_agent3 show-routes"
$ns at 3500.0  "$bgp_agent3 show-all"
$ns at 3500.0 "$bgp_agent3 show-damping"

$ns at 3530.0 "puts \"\n time: 3530.0 \n n1 (ip_addr 10.0.1.3) \
                       advertises the network 10.0.7.0/24.\""
$ns at 3530.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 3535.0 "puts \"\n time: 3535.0 \n n2 (ip_addr 10.0.2.2) \
                       advertises the network 10.1.7.0/24.\""
$ns at 3535.0  "$bgp_agent2 network 10.1.7.0/24"

$ns at 3550.0 "puts \"\n time: 3550 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 3550.0 "$bgp_agent0 show-routes"
$ns at 3550.0  "$bgp_agent0 show-all"
$ns at 3550.0 "$bgp_agent1 show-routes"
$ns at 3550.0  "$bgp_agent1 show-all"
$ns at 3550.0 "$bgp_agent2 show-routes"
$ns at 3550.0  "$bgp_agent2 show-all"
$ns at 3550.0 "$bgp_agent3 show-routes"
$ns at 3550.0  "$bgp_agent3 show-all"

$ns at 3580.0 "puts \"\n time: 3580.0 \n n1 (ip_addr 10.0.1.3) \
                       withdraws the network 10.0.7.0/24.\""
$ns at 3580.0  "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 3600.0 "puts \"\n time: 3600 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 3600.0 "$bgp_agent0 show-routes"
$ns at 3600.0  "$bgp_agent0 show-all"
$ns at 3600.0 "$bgp_agent1 show-routes"
$ns at 3600.0  "$bgp_agent1 show-all"
$ns at 3600.0 "$bgp_agent2 show-routes"
$ns at 3600.0  "$bgp_agent2 show-all"
$ns at 3600.0 "$bgp_agent3 show-routes"
$ns at 3600.0  "$bgp_agent3 show-all"

$ns at 3650.0 "puts \"\n time: 3650.0 \n n1 (ip_addr 10.0.1.3) \
                       advertises the network 10.0.7.0/24.\""
$ns at 3650.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 3700.0 "puts \"\n time: 3700 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 3700.0 "$bgp_agent0 show-routes"
$ns at 3700.0  "$bgp_agent0 show-all"
$ns at 3700.0 "$bgp_agent1 show-routes"
$ns at 3700.0  "$bgp_agent1 show-all"
$ns at 3700.0 "$bgp_agent2 show-routes"
$ns at 3700.0  "$bgp_agent2 show-all"
$ns at 3700.0 "$bgp_agent3 show-routes"
$ns at 3700.0  "$bgp_agent3 show-all"

$ns at 3750.0 "puts \"\n time: 3750.0 \n n1 (ip_addr 10.0.1.3) \
                       withdraws the network 10.0.7.0/24.\""
$ns at 3750.0  "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 3800.0 "puts \"\n time: 3800 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 3800.0 "$bgp_agent0 show-routes"
$ns at 3800.0  "$bgp_agent0 show-all"
$ns at 3800.0 "$bgp_agent1 show-routes"
$ns at 3800.0  "$bgp_agent1 show-all"
$ns at 3800.0 "$bgp_agent2 show-routes"
$ns at 3800.0  "$bgp_agent2 show-all"
$ns at 3800.0 "$bgp_agent3 show-routes"
$ns at 3800.0  "$bgp_agent3 show-all"

$ns at 3830.0 "puts \"\n time: 3830.0 \n n1 (ip_addr 10.0.1.3) \
                       begins to have a series of advertisements and \
		       withdrawals regarding the network 10.0.7.0/24.\""
$ns at 3830.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 3840.0  "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 3870.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 3880.0  "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 3910.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 3920.0  "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 3950.0  "$bgp_agent1 network 10.0.7.0/24"
$ns at 3960.0  "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 3990.0  "$bgp_agent1 network 10.0.7.0/24"

$ns at 4005.0 "puts \"\n time: 4005 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 4005.0 "$bgp_agent0 show-routes"
$ns at 4005.0  "$bgp_agent0 show-all"
$ns at 4005.0 "$bgp_agent0 show-damping"
$ns at 4005.0 "$bgp_agent1 show-routes"
$ns at 4005.0  "$bgp_agent1 show-all"
$ns at 4005.0 "$bgp_agent1 show-damping"
$ns at 4005.0 "$bgp_agent2 show-routes"
$ns at 4005.0  "$bgp_agent2 show-all"
$ns at 4005.0 "$bgp_agent2 show-damping"
$ns at 4005.0 "$bgp_agent3 show-routes"
$ns at 4005.0  "$bgp_agent3 show-all"
$ns at 4005.0 "$bgp_agent3 show-damping"

$ns at 6005.0 "puts \"\n time: 6005 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 6005.0 "$bgp_agent0 show-routes"
$ns at 6005.0  "$bgp_agent0 show-all"
$ns at 6005.0 "$bgp_agent1 show-routes"
$ns at 6005.0  "$bgp_agent1 show-all"
$ns at 6005.0 "$bgp_agent2 show-routes"
$ns at 6005.0  "$bgp_agent2 show-all"
$ns at 6005.0 "$bgp_agent3 show-routes"
$ns at 6005.0  "$bgp_agent3 show-all"

$ns at 8050.0 "puts \"\n time: 8050 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 8050.0 "$bgp_agent0 show-routes"
$ns at 8050.0  "$bgp_agent0 show-all"
$ns at 8050.0 "$bgp_agent0 show-damping"
$ns at 8050.0 "$bgp_agent1 show-routes"
$ns at 8050.0  "$bgp_agent1 show-all"
$ns at 8050.0 "$bgp_agent1 show-damping"
$ns at 8050.0 "$bgp_agent2 show-routes"
$ns at 8050.0  "$bgp_agent2 show-all"
$ns at 8050.0 "$bgp_agent2 show-damping"
$ns at 8050.0 "$bgp_agent3 show-routes"
$ns at 8050.0  "$bgp_agent3 show-all"
$ns at 8050.0 "$bgp_agent3 show-damping"

$ns at 8100.0 "puts \"\n time: 8100.0 \n n1 (ip_addr 10.0.1.3) \
                       begins to have a series of advertisements and \
		       withdrawals regarding the network 10.0.7.0/24.\""
$ns at 8100.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8120.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8140.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8160.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8180.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8200.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8220.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8240.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8260.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8280.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8300.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8320.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8340.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8360.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8380.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8400.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8420.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8430.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8460.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8480.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8500.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8520.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8535.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8550.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8570.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8580.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8605.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8610.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8640.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8650.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8675.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8690.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8710.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8720.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8750.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8760.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8785.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8800.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8820.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8830.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8855.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 8870.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 8890.0 "$bgp_agent1 network 10.0.7.0/24"

$ns at 8900.0 "puts \"\n time: 8900 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 8900.0 "$bgp_agent0 show-routes"
$ns at 8900.0  "$bgp_agent0 show-all"
$ns at 8900.0 "$bgp_agent0 show-damping"
$ns at 8900.0 "$bgp_agent1 show-routes"
$ns at 8900.0  "$bgp_agent1 show-all"
$ns at 8900.0 "$bgp_agent1 show-damping"
$ns at 8900.0 "$bgp_agent2 show-routes"
$ns at 8900.0  "$bgp_agent2 show-all"
$ns at 8900.0 "$bgp_agent2 show-damping"
$ns at 8900.0 "$bgp_agent3 show-routes"
$ns at 8900.0  "$bgp_agent3 show-all"
$ns at 8900.0 "$bgp_agent3 show-damping"

$ns at 12500.0 "puts \"\n time: 12500 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 12500.0 "$bgp_agent0 show-routes"
$ns at 12500.0  "$bgp_agent0 show-all"
$ns at 12500.0 "$bgp_agent0 show-damping"
$ns at 12500.0 "$bgp_agent1 show-routes"
$ns at 12500.0  "$bgp_agent1 show-all"
$ns at 12500.0 "$bgp_agent1 show-damping"
$ns at 12500.0 "$bgp_agent2 show-routes"
$ns at 12500.0  "$bgp_agent2 show-all"
$ns at 12500.0 "$bgp_agent2 show-damping"
$ns at 12500.0 "$bgp_agent3 show-routes"
$ns at 12500.0  "$bgp_agent3 show-all"
$ns at 12500.0 "$bgp_agent3 show-damping"

$ns at 12580.0 "puts \"\n time: 12580.0 \n n1 (ip_addr 10.0.1.3) \
                       withdraws the network 10.0.7.0/24.\""
$ns at 12580.0 "$bgp_agent1 no-network 10.0.7.0/24"
$ns at 12590.0 "puts \"\n time: 12590 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 12590.0 "$bgp_agent0 show-routes"
$ns at 12590.0  "$bgp_agent0 show-all"
$ns at 12590.0 "$bgp_agent1 show-routes"
$ns at 12590.0  "$bgp_agent1 show-all"
$ns at 12590.0 "$bgp_agent2 show-routes"
$ns at 12590.0  "$bgp_agent2 show-all"
$ns at 12590.0 "$bgp_agent3 show-routes"
$ns at 12590.0  "$bgp_agent3 show-all"

$ns at 12600.0 "puts \"\n time: 12600.0 \n n1 (ip_addr 10.0.1.3) \
                       advertises the network 10.0.7.0/24.\""
$ns at 12600.0 "$bgp_agent1 network 10.0.7.0/24"
$ns at 12610.0 "puts \"\n time: 12610 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 12610.0 "$bgp_agent0 show-routes"
$ns at 12610.0  "$bgp_agent0 show-all"
$ns at 12610.0 "$bgp_agent0 show-damping"
$ns at 12610.0 "$bgp_agent1 show-routes"
$ns at 12610.0  "$bgp_agent1 show-all"
$ns at 12610.0 "$bgp_agent1 show-damping"
$ns at 12610.0 "$bgp_agent2 show-routes"
$ns at 12610.0  "$bgp_agent2 show-all"
$ns at 12610.0 "$bgp_agent2 show-damping"
$ns at 12610.0 "$bgp_agent3 show-routes"
$ns at 12610.0  "$bgp_agent3 show-all"
$ns at 12610.0 "$bgp_agent3 show-damping"

$ns at 12800.0 "finish"

proc finish {} {
	global ns f nf
	$ns flush-trace
	close $nf
	puts "Simulation finished. Executing nam..."
	exec nam damping2.nam
	exit 0
}


puts "Simulation starts..."
$ns run
	
