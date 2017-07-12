#  https://github.com/wujingbang/TEST/blob/master/%E5%AE%9E%E9%AA%8C%E5%9B%9B%EF%BC%9A%E8%8A%82%E7%82%B9%E7%AA%81%E7%84%B6%E6%8B%90%E5%BC%AF/aodv.tcl


#load ~/Desktop/ns2/ns-allinone-2.35/dei80211mr-1.1.4/src/.libs/libdei80211mr.so

set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(ifqlen) 50
set val(nn) 4
set val(rp) AODV

#Agent/Bundle set helloInterval_ 100 ; # [ms]
#Agent/Bundle set bundleStorageSize_ 100000000 ; # Bytes

set opt(sc) "./scence1"
set opt(cp) "./cbr1"

Agent/Bundle set helloInterval_ 100 ; # [ms]
Agent/Bundle set bundleStorageSize_ 100000000 ; # Bytes


puts "\n"
puts "Simulation of a simple wireless topology running with AODV\n"
puts "Starting simulation...\n"

set ns_ [new Simulator]
set tracefd [open aodv.tr w]
$ns_ use-newtrace
$ns_ trace-all $tracefd
set namtracefd [open aodv.nam w]
$ns_ namtrace-all-wireless $namtracefd 1000 1000
set topo [new Topography]
$topo load_flatgrid 1000 1000
set god_ [new God]
create-god $val(nn)
 
$ns_ node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace OFF
for {set i 0} {$i < $val(nn)} {incr i} {
set node_($i) [$ns_ node]
$node_($i) random-motion 0
$node_($i) set id_ $i
$node_($i) set address_ $i
$node_($i) nodeid $i
}

puts "Loading connection pattern file\n"
source $opt(cp)
puts "Connection pattern file loading complete...\n"

puts "Loading scenario file...\n"
source $opt(sc)
puts "Scenario file loading complete...\n"
puts "Simulation may take a few minutes...\n"
puts "A sample script runs"
#设置在nam中移动节点显示的大小，否则，nam中无法显示节点
for {set i 0} {$i < $val(nn)} {incr i} {
$ns_ initial_node_pos $node_($i) 20
}
for {set i 0} {$i < $val(nn)} {incr i} {
$ns_ at 50000.1 "$node_($i) reset"
}
$ns_ at 50000.2 "stop"
$ns_ at 50000.3 "puts\”Simulation runs sucessfully and NS exiting…\"; $ns_ halt"
proc stop {} {
global ns_ tracefd namtracefd
$ns_ flush-trace
close $tracefd
close $namtracefd
#exec nam aodv.nam &
exit 0
}
puts $tracefd "Here is a trace for simple wireless simulation\n"
puts $tracefd "The nodes movement file is $opt(cp)\n"
puts $tracefd "The traffic flow between nodes is $opt(sc)\n"
$ns_ run
