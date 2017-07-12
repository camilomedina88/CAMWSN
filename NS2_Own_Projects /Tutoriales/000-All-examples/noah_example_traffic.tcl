
set ns_ [new Simulator]
$ns_ node-config -addressType hierarchical

AddrParams set domain_num_ 8
lappend cluster_num 1 2 1 1 1 1 1 1
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 2 1 1 1 1 1 1 1 1
AddrParams set nodes_num_ $eilastlevel

set tracefd [open noah_example.tr w]
$ns_ trace-all $tracefd

set namtracefd [open noah_example.nam w]
$ns_ namtrace-all $namtracefd


set topo [new Topography]
$topo load_flatgrid 60 40
set god_ [create-god 10]

# wired nodes
set node_(0) [$ns_ node 1.0.0]
set node_(1) [$ns_ node 1.1.0]

set chan_ [new Channel/WirelessChannel]

$ns_ node-config -mobileIP ON \
                  -adhocRouting NOAH \
                  -llType LL \
                  -macType Mac/802_11 \
                  -ifqType Queue/DropTail/PriQueue \
                  -ifqLen 50 \
                  -antType Antenna/OmniAntenna \
					-propType 	Propagation/TwoRayGround \
                  -phyType Phy/WirelessPhy \
                  -channel $chan_ \
	 	  -topoInstance $topo \
                  -wiredRouting ON \
		  -agentTrace ON \
                  -routerTrace OFF \
                  -macTrace ON

# Pmsrve: note: this line was replaced from NOAH example to work with regular NS2.31
#                  -propType Propagation/SimpleDistance \
#

# home agents
$ns_ node-config -rxPower 0.1 -txPower 0.1
set node_(2) [$ns_ node 0.0.0]

# Pmsrve: removed in NOAH example to work with regular NS2.31
#[$node_(2) set regagent_] priority 3

$ns_ node-config -wiredRouting OFF

# mobile agents
$ns_ node-config -rxPower 73 -txPower 73
set node_(3) [$ns_ node 0.0.1]
[$node_(3) set regagent_] set home_agent_ [AddrParams addr2id [$node_(2) node-addr]]

$ns_ node-config -wiredRouting ON

# foreign agents
$ns_ node-config -rxPower 0.3 -txPower 0.3
set node_(4) [$ns_ node 2.0.0]
#[$node_(4) set regagent_] priority 3
$ns_ node-config -rxPower 9.0 -txPower 9.0
set node_(5) [$ns_ node 3.0.0]
#[$node_(5) set regagent_] priority 2
$ns_ node-config -rxPower 18.0 -txPower 18.0
set node_(6) [$ns_ node 4.0.0]
#[$node_(6) set regagent_] priority 1
$ns_ node-config -rxPower 0.3 -txPower 0.3
set node_(7) [$ns_ node 5.0.0]
#[$node_(7) set regagent_] priority 3
$ns_ node-config -rxPower 9.0 -txPower 9.0
set node_(8) [$ns_ node 6.0.0]
#[$node_(8) set regagent_] priority 2
$ns_ node-config -rxPower 18.0 -txPower 18.0
set node_(9) [$ns_ node 7.0.0]
#[$node_(9) set regagent_] priority 1

# source connection-pattern and node-movement scripts
source "noah_example_traffic.scn"
source "noah_example_traffic.com"

# Tell all nodes when the simulation ends
for {set i 0} {$i < 10 } {incr i} {
    $ns_ at 920.0 "$node_($i) reset";
}

# Progress
for {set t 10} {$t < 920} {incr t 10} {
    $ns_ at $t "puts stderr \"completed through $t/920 secs...\""
}

#set opt(stop) 100
set opt(stop) 900

$ns_ at 0.0 "puts stderr \"Simulation started...\""
$ns_ at [expr $opt(stop) + 0.0000] "puts stderr \"Simulation finished\""
$ns_ at [expr $opt(stop) + 0.0001] "close $tracefd"

$ns_ at [expr $opt(stop) + 0.0001] "close $namtracefd"

#$ns_ at [expr $opt(stop) + 0.0002] "exec run_plot_tp.sh traffic.tr 3"
$ns_ at [expr $opt(stop) + 0.0003] "$ns_ halt"

puts $tracefd "M 0.0 nn 10 x 60 y 40 rp NOAH"
puts $tracefd "M 0.0 sc traffic.scn cp traffic.com seed 0"

$ns_ run

