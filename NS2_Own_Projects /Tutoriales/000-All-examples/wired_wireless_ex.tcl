# ======================================================================
# Define options
# ======================================================================
set opt(namfile)         out.nam
set opt(tracefile)       out.tr
set opt(x)               500;                #x dimension of the topography
set opt(y)               500;                #y dimension of the topography
set opt(wirelessNodes)   3;                  #mobile nodes
set opt(wiredNodes)      2;                  #hosts and routers
set opt(gatewayNodes)    1;                  #gateways

set val(stop)            60.0;               #simulation time
set val(start-src)       1
set val(stop-src)        50

set opt(gw_discovery)    reactive;             #gateway discovery method
# ======================================================================

#---------------------------
#Initialize Global Variables
#---------------------------
#create a simulator object
set ns [new Simulator]
$ns color 0 Brown

#----------------------------------------
#Define The Hierachial Topology Structure
#----------------------------------------
$ns node-config -addressType hierarchical
#Nbr of domains
AddrParams set domain_num_ 2
#Nbr of clusters (=subdomains) in each domain
lappend clusterNbr 2 1
AddrParams set cluster_num_ $clusterNbr
#Nbr of nodes in each cluster
lappend eilastlevel 1 1 4 
AddrParams set nodes_num_ $eilastlevel


#create trace objects for ns and nam
###$ns use-newtrace
set nstrace [open $opt(tracefile) w]
$ns trace-all $nstrace

set namtrace [open $opt(namfile) w]
$ns namtrace-all-wireless $namtrace $opt(x) $opt(y)


#create a topology object and define topology (500mx500m)
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)

#Choose method for gateway discovery
if {$opt(gw_discovery) == "proactive"} {
    Agent/AODV set gw_discovery 0
}
if {$opt(gw_discovery) == "hybrid"} {
    Agent/AODV set gw_discovery 1
}
if {$opt(gw_discovery) == "reactive"} {
    Agent/AODV set gw_discovery 2
}

#create God (General Operations Director)
create-god [expr $opt(wirelessNodes)+$opt(gatewayNodes)]]

#create wired nodes
set temp {0.0.0 0.1.0}
for {set i 0} {$i < $opt(wiredNodes)} {incr i} {
    set host($i) [$ns node [lindex $temp $i]]
}

#--------------------------------------
#Configure for Gateway and Mobile Nodes
#--------------------------------------
#Use hierarchical addresses for GWs and MNs

#configure for mobile nodes and gateways
$ns node-config -adhocRouting AODV
$ns node-config -llType LL
$ns node-config -macType Mac/802_11
$ns node-config -ifqType Queue/DropTail/PriQueue
$ns node-config -ifqLen  50
$ns node-config -antType Antenna/OmniAntenna
$ns node-config -propType Propagation/TwoRayGround
$ns node-config -phyType  Phy/WirelessPhy
$ns node-config -topoInstance $topo
$ns node-config -channel [new Channel/WirelessChannel]
$ns node-config -agentTrace ON
$ns node-config -routerTrace ON
$ns node-config -macTrace ON
$ns node-config -movementTrace OFF

#configure for gateways
$ns node-config -wiredRouting ON
#create gateway
set gw(0) [$ns node 1.0.0]
#set initial coordinates
$gw(0) set X_ 200.0
$gw(0) set Y_ 200.0
$gw(0) set Z_ 0.0
$ns at 0.00 "$gw(0) setdest 200 200 20"

#configure for mobile nodes
$ns node-config -wiredRouting OFF
#create mobile nodes in the same domain as gw(0)
set temp {1.0.1 1.0.2 1.0.3}
for {set i 3} {$i < $opt(wirelessNodes)+3} {incr i} {
    set mobile($i) [$ns node [lindex $temp [expr $i-3]]]
    $mobile($i) base-station [AddrParams addr2id [$gw(0) node-addr]]
}

$mobile(3) set X_ 100
$mobile(3) set Y_ 300
$mobile(3) set Z_ 0.0

$mobile(4) set X_ 300
$mobile(4) set Y_ 300
$mobile(4) set Z_ 0.0

$mobile(5) set X_ 400
$mobile(5) set Y_ 200
$mobile(5) set Z_ 0.0

puts ""
puts "host0 = [$host(0) node-addr] = [AddrParams addr2id [$host(0) node-addr]]"
puts "host1 = [$host(1) node-addr] = [AddrParams addr2id [$host(1) node-addr]]"
puts "gw0 = [$gw(0) node-addr] = [AddrParams addr2id [$gw(0) node-addr]]"
for {set i 3} {$i < $opt(wirelessNodes)+3} {incr i} {
    puts "mobile($i) = [$mobile($i) node-addr] = [AddrParams addr2id [$mobile($i) node-addr]]"
}
puts ""

$host(0) color blue
$host(1) color blue
$gw(0) color red


$ns at 0.0 "$host(0) label \"HOST 0\""
$ns at 0.0 "$host(1) label \"HOST 1\""
$ns at 0.0 "$gw(0) label GATEWAY"
for {set i 3} {$i < $opt(wirelessNodes)+3} {incr i} {
    $ns at 0.0 "$mobile($i) label \"MN $i\""
}

#create links between wired nodes and basestation node
$ns duplex-link $host(0) $host(1) 5Mb 2ms DropTail
$ns duplex-link $host(1) $gw(0) 5Mb 2ms DropTail

$ns duplex-link-op $host(0) $host(1) orient up
$ns duplex-link-op $host(1) $gw(0) orient right-up

#---------------------
#Setup Traffic
#---------------------
#MN5 ==> HOST0
set src [new Agent/UDP]
set dst [new Agent/Null]
$ns attach-agent $mobile(5) $src
$ns attach-agent $host(0) $dst
$src set fid_ 0
$ns connect $src $dst

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $src
$cbr set packetSize_ 512
$cbr set interval_ 0.2
$ns at $val(start-src) "$cbr start"
$ns at $val(stop-src) "$cbr stop"

$ns at $val(start-src) "$ns trace-annotate \"MN 5 ==> HOST 0 at t=$val(start-src) s!\""

#---------------------
#Setup Node Movement
#---------------------
$ns at 0.5 "$mobile(5) setdest 100 450 10"
$ns at 0.5 "$ns trace-annotate \"MN 5 starts moving at t=0.5 s.\""
$ns at 0.5 "$mobile(5) add-mark m1 green circle"


#-----------------------------------
#Define Node Initial Position In Nam
#-----------------------------------
#20 defines the node size in nam, must adjust it according to your scenario
#The function must be called after mobility model is defined
for {set i 3} {$i < $opt(wirelessNodes)+3} {incr i} {
    $ns initial_node_pos $mobile($i) 20
}

#-----------------------------------
#Tell Nodes When The Simulation Ends
#-----------------------------------
for {set i 3} {$i < $opt(wirelessNodes)+3} {incr i} {
    $ns at $val(stop).0 "$mobile($i) reset";
}
$ns at $val(stop).0 "$gw(0) reset";
$ns at $val(stop).0001 "stop"
$ns at $val(stop).0002 "puts \"NS EXITING...\" ; $ns halt"

proc stop {} {
    global ns nstrace namtrace opt
    $ns flush-trace
    close $nstrace
    close $namtrace
    exec nam $opt(namfile) &
    exit 0
}

puts "Starting simulation..."
$ns at 0.0 "$ns set-animation-rate 5ms"

$ns run
