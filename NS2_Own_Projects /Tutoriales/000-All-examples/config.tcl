# CONFIG ######### 

set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
set opt(ll)			LL
set opt(mac)		Mac/802_11 
set opt(ifq)		Queue/DropTail/PriQueue 
set opt(ifqlen)		50
set opt(netif)		Phy/WirelessPhy
set opt(rp)			DumbAgent
set opt(ant)		Antenna/OmniAntenna

set opt(tr) 		/dev/null
set opt(namtr)		/dev/null

#Number
set opt(nn) 		1000
set opt(x) 		1000
set opt(y) 		10000
set opt(stop) 		100
set opt(interval) 	100

set clustered		0
set chain		0
set adaptive		0
set balanced_children	0
set balanced_cluster	0

if [expr $clustered > 0] {
   puts "ENABLED: Clustering"
   set opt(chain_sync)		1
   set max_depth		4
} else {
   puts "DISABLED: Clustering"
   set opt(chain_sync)		1
   set max_depth		$opt(nn)
}

if [expr $chain > 0] {
   puts "ENABLED: Chain Synchronization"
   set opt(chain_sync_all)		1
   set opt(chain_sync_interrupt)	1
} else {
   puts "DISABLED: Chain Synchronization"
   set opt(chain_sync_all)			0
   set opt(chain_sync_interrupt)		0
}

if [expr $adaptive > 0] {
puts "ENABLED: Adaptive Synchronization"
set opt(keep_diff)		[expr $opt(interval) / 10]
} else {
   puts "DISABLED: Adaptive Synchronization"
   set opt(keep_diff)		0
}

if [expr $balanced_children > 0] {
   puts "ENABLED: Balancing Children Count"
   set max_child		4
} else {
puts "DISABLED: Balancing Children Count"
set max_child			0
}

if [expr $balanced_cluster > 0] {
   puts "ENABLED: Balancing Cluster Node Count"
   set max_node_in_cluster		12
} else {
puts "DISABLED: Balancing Cluster Node Count"
set max_node_in_cluster			0
}

#--------------------
set opt(seed)			0
 
