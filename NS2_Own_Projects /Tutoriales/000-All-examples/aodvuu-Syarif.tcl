# ========= https://abdusyarif.wordpress.com/2011/03/27/tcl-script-aodv-uu-ad-hoc-hybrid-network/#more-334
# ABDUSY SYARIF
# AODV DESIGN
# Februari 2011
#========================================================================
set opt(namfile)         nam_aodv_out.nam
set opt(tracefile)       uu-trace-new-aodv_m5_h2.tr
set val(chan)    Channel/WirelessChannel;    #channel type
set val(prop)    Propagation/TwoRayGround;   #radio-propagation model
set val(netif)   Phy/WirelessPhy;            #network interface type
set val(mac)     Mac/802_11;                 #MAC type
set val(ifq)     Queue/DropTail/PriQueue;    #interface queue type
set val(ifqlen)  50;                         #max nbr of packets in ifq
set val(ll)      LL;                         #link layer type
set val(ant)     Antenna/OmniAntenna;        #antenna type
set val(adhocRP) AODVUU;                       #routing protocol in used
set val(x)       1000;                        #x dimension of the topography
set val(y)       800;                        #y dimension of the topography
set val(stop)    500.0;                       #simulation time
set val(mobility) "./mobil5_4"
set val(start-src)     1
set val(stop-src)     500
set nbrOfWirelessNodes   5
set nbrOfWiredNodes      4
set nbrOfGateways        2
set val(gw_discovery) reactive;                #gateway discovery method

#---------------------------
#Initialize Global Variables
#---------------------------
#create a simulator object
set ns_ [new Simulator]
$ns_ color 0 Brown

#----------------------------------------
#Define The Hierachial Topology Structure
#----------------------------------------
$ns_ node-config -addressType hierarchical
#Nbr of domains
AddrParams set domain_num_ 4
#Nbr of clusters (=subdomains) in each domain
lappend clusterNbr 1 1 1 1
AddrParams set cluster_num_ $clusterNbr
#Nbr of nodes in each cluster
lappend eilastlevel 2 2 [expr $nbrOfWirelessNodes/2+1] [expr $nbrOfWirelessNodes/2+1]
#lappend eilastlevel 1 1 4
AddrParams set nodes_num_ $eilastlevel

#create trace objects for ns and nam
$ns_ use-newtrace
#$ns use-trace
set ns_trace [open $opt(tracefile) w]
$ns_ trace-all $nstrace

set namtrace [open $opt(namfile) w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

#--------------------------------------------------------
#create a topology object and define topology
#--------------------------------------------------------

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

#--------------------------------------------------------
#Agent AODV as gateway. 2=reactive 1=hybrid 0=proactive
#--------------------------------------------------------
#Agent/AODVUU set gw_discovery 2
#Agent/AODVUU set internet_gw_mode_ 1

#--------------------------------------------------------
# Create GOD
#--------------------------------------------------------
set god [create-god [expr $nbrOfWirelessNodes+$nbrOfGateways]]
set router(0) [$ns node 0.0.0]
set router(1) [$ns node 1.0.0]
set host(0)   [$ns node 0.0.1]
set host(1)   [$ns node 1.0.1]

#--------------------------------------
#Configure For Gateway and Mobile Nodes
#--------------------------------------

#Use hierarchical addresses for GWs and MNs
set chan1 [new $val(chan)]

#configure for gateway
$ns node-config -adhocRouting $val(adhocRP) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-topoInstance $topo \
-channel $chan1 \
-agentTrace ON \
-routerTrace ON \
-macTrace ON \
-movementTrace OFF

#create gateway and set initial coordinates
$ns node-config -wiredRouting ON
set gw(0) [$ns node 2.0.0]
$gw(0) random-motion 0
$gw(0) set X_ 100.0
$gw(0) set Y_ 150.0
$gw(0) set Z_ 0.0
$ns at 0.00 "$gw(0) setdest 100 150 0"

#gateway AODV-UU
$gw(0) random-motion 0
set r [$gw(0) set ragent_]
$r set debug_ 1
$r set internet_gw_mode_ 1
$r set expanding_ring_search_ 1
$r set llfeedback_ 1

#$r set rt_log_interval_ 1000
#$r set log_to_file_ 0

set gw(1) [$ns node 3.0.0]
$gw(1) random-motion 0
$gw(1) set X_ 300.0
$gw(1) set Y_ 150.0
$gw(1) set Z_ 0.0
$ns at 0.00 "$gw(1) setdest 300 150 0"

#gateway AODV-UU
$gw(1) random-motion 0
set r [$gw(1) set ragent_]
$r set debug_ 1
$r set internet_gw_mode_ 1
$r set expanding_ring_search_ 1
$r set llfeedback_ 1
#$r set rt_log_interval_ 1000
#$r set log_to_file_ 0

#create mobile nodes in the same domain as gw(0)
$ns node-config -wiredRouting OFF
$ns node-config -adhocRouting AODVUU
for {set i 0} {$i < [expr $nbrOfWirelessNodes/2]} {incr i} {
set node_($i) [$ns node 2.0.[expr $i + 1]]
$node_($i) base-station [AddrParams addr2id [$gw(0) node-addr]]

#for AODV-UU
$node_($i) random-motion 1
set r [$node_($i) set ragent_]
$r set debug_ 1
#$r set rt_log_interval_ 1000
#$r set log_to_file_ 0
}
for {set i [expr $nbrOfWirelessNodes/2]} {$i < [expr $nbrOfWirelessNodes]} {incr i} {
set node_($i) [$ns node 3.0.[expr $i - [expr $nbrOfWirelessNodes/2-1]]]
$node_($i) base-station [AddrParams addr2id [$gw(1) node-addr]]

#for AODV-UU
$node_($i) random-motion 1
set r [$node_($i) set ragent_]
$r set debug_ 1
}

#---------------------
#Source Mobility Pattern
#---------------------
source $val(mobility)

puts ""

puts "host0 = [$host(0) node-addr] = [AddrParams addr2id [$host(0) node-addr]]"
puts "host1 = [$host(1) node-addr] = [AddrParams addr2id [$host(1) node-addr]]"
puts "gw0 = [$gw(0) node-addr] = [AddrParams addr2id [$gw(0) node-addr]]"
puts "gw1 = [$gw(1) node-addr] = [AddrParams addr2id [$gw(1) node-addr]]"
[$node_($i) node-addr]]"
#}
puts ""
for {set i [expr $nbrOfWirelessNodes/2]} {$i < [expr $nbrOfWirelessNodes]} {incr i} {
puts "node_($i) = [$node_($i) node-addr] = [AddrParams addr2id [$node_($i) node-addr]]"
}
puts ""
#----------------
#Labels & Colour
#----------------
$host(0) color blue
$host(1) color blue
$router(0) color green
$router(1) color green
$gw(0) color red
$gw(1) color red

$ns at 0.0 "$host(0) label "HOST_0""
$ns at 0.0 "$host(1) label "HOST_1""
$ns at 0.0 "$router(0) label "RTR_1""
$ns at 0.0 "$router(1) label "RTR_2""
$ns at 0.0 "$gw(0) label GTW_1"
$ns at 0.0 "$gw(1) label GTW_2"
for {set i 0} {$i < [expr $nbrOfWirelessNodes]} {incr i} {
$ns at 0.0 "$node_($i) label "MN [expr $i]""
}

#-----------------------------------
#Define Node Initial Position In Nam
#-----------------------------------
#20 defines the node size in nam, must adjust it according to your scenario
#The function must be called after mobility model is defined
for {set i 0} {$i < [expr $nbrOfWirelessNodes]} {incr i} { 	    $ns initial_node_pos $node_($i) 20 	} 	#create links between wired nodes and basestation node 	$ns duplex-link $router(0) $host(0) 100Mb 1ms DropTail 	$ns duplex-link $router(1) $host(1) 100Mb 1ms DropTail 	$ns duplex-link $router(0) $router(1) 100Mb 1ms DropTail 	$ns duplex-link $router(0) $gw(0) 100Mb 2ms DropTail 	$ns duplex-link $router(1) $gw(1) 100Mb 2ms DropTail 	$ns duplex-link-op $router(0) $host(0) orient down 	$ns duplex-link-op $router(0) $host(0) orient down 	$ns duplex-link-op $router(0) $router(1) queuePos 0.5 	$ns duplex-link-op $router(0) $gw(0) orient up 	$ns duplex-link-op $router(1) $gw(1) orient up 	 #-----END OF TOPOLOGY------- #--------------------- #Setup Traffic #--------------------- #MN3 ==> HOST1
set src [new Agent/UDP]
set dst [new Agent/Null]
$ns attach-agent $node_(3) $src
$ns attach-agent $host(1) $dst
$src set fid_ 0
$ns connect $src $dst
#MN0 ==> HOST1
set src2 [new Agent/UDP]
set dst2 [new Agent/Null]
#$ns attach-agent $node_(11) $src2
$ns attach-agent $node_(0) $src2
$ns attach-agent $host(1) $dst2
$src2 set fid_ 0
$ns connect $src2 $dst2

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $src
$cbr set packetSize_ 512
$cbr set interval_ 0.2

set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $src2
$cbr2 set packetSize_ 512
$cbr2 set interval_ 0.2

$ns at $val(start-src) "$cbr start"
$ns at $val(stop-src) "$cbr stop"
$ns at $val(start-src) "$cbr2 start"
$ns at $val(stop-src) "$cbr2 stop"

#$ns at $val(start-src) "$ns trace-annotate "MN 3 ==> HOST 0 at t=$val(start-src) s!""
#$ns at $val(start-src) "$ns trace-annotate "MN 11 ==> HOST 1 at t=$val(start-src) s!""

#-----------------------------------
#Tell Nodes When The Simulation Ends --------------------------------------------------------> name trace file
#-----------------------------------
for {set i 0} {$i < [expr $nbrOfWirelessNodes]} {incr i} {
$ns at $val(stop).0 "$node_($i) reset";
}
$ns at $val(stop).0 "$gw(0) reset";
$ns at $val(stop).0 "$gw(1) reset";
$ns at $val(stop).0001 "stop"
$ns at $val(stop).0002 "puts "NS EXITING..." ; $ns halt"

proc stop {} {
global ns nstrace namtrace
$ns flush-trace
close $nstrace
close $namtrace
exec nam nam_aodv_out.nam &
exit 0
}

puts "Starting simulation..."
$ns at 0.0 "$ns set-animation-rate 5ms"

$ns run
