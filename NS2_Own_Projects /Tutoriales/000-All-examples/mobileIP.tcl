set opt(chan)   Channel/WirelessChannel        ;# channel type
set opt(prop)   Propagation/TwoRayGround       ;# radio-propagation model
set opt(netif)  Phy/WirelessPhy                ;# network interface type
set opt(mac)    Mac/802_11                     ;# MAC type
set opt(ifq)    Queue/DropTail/PriQueue        ;# interface queue type
set opt(ll)     LL                             ;# link layer type
set opt(ant)    Antenna/OmniAntenna            ;# antenna model
set opt(ifqlen)         50                     ;# max packet in ifq
set opt(nn)             2                      ;# number of mobilenodes
set opt(adhocRouting)   DSDV                   ;# routing protocol

set opt(x)      400                            ;# x coordinate of topology
set opt(y)      400                            ;# y coordinate of topology
set opt(stop)   60                            ;# time to stop simulation

set ns [new Simulator]
set tracefd [open hiermip-out.tr w]
$ns trace-all $tracefd
set tracefile [open hiermip-out.nam w]
$ns namtrace-all $tracefile

$ns node-config -addressType hierarchical

AddrParams set domain_num 3
AddrParams set cluster_num {2 1 2}
AddrParams set nodes_num {3 2 1 2 1}

set topo [new Topography]
$topo load_flatgrid 400 400

set god [create-god 9]

#wired nodes
set chan1 [new $opt(chan)]
set chan2 [new $opt(chan)]

set LSR(1) [$ns node 0.0.0]
set LSR(2) [$ns node 0.0.1]
set LSR(3) [$ns node 0.0.2]

set LSR(4) [$ns node 0.1.0]
set LSR(6) [$ns node 0.1.1]

# Configure for ForeignAgent and HomeAgent nodes
$ns node-config -mobileIP ON \
                 -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -channel $chan2 \
		 -topoInstance $topo \
                 -wiredRouting ON \
		 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF

set HA [$ns node 1.0.0]
set FA1 [$ns node 2.0.0]
set FA2 [$ns node 2.1.0]

#$HA random-motion 0
$FA1 random-motion 0
$FA2 random-motion 0

$HA set X 100.00
$HA set Y 150.00
$HA set Z 0.00

$FA1 set X 100.00
$FA1 set Y 500.00
$FA1 set Z 0.00

$FA2 set X 200.00
$FA2 set Y 50.00
$FA2 set Z 0.00

#mobile node

set MN [$ns node 2.0.1]
set node(0) $MN
set HAaddress [AddrParams addr2id [$HA node-addr]]
	       [$MN set regagent_] set homeagent $HAaddress

$ns duplex-link $LSR(1) $LSR(2) 5Mb 2ms DropTail
$ns duplex-link-op $LSR(1) $LSR(2) orient right

$ns duplex-link $LSR(2) $LSR(3) 5Mb 2ms DropTail
$ns duplex-link-op $LSR(2) $LSR(3) orient right

$ns duplex-link $LSR(3) $LSR(4) 5Mb 2ms DropTail
$ns duplex-link-op $LSR(3) $LSR(4) orient down

$ns duplex-link $LSR(4) $LSR(6) 5Mb 2ms DropTail
$ns duplex-link-op $LSR(4) $LSR(6) orient right

$ns duplex-link $LSR(6) $FA1 5Mb 2ms DropTail
$ns duplex-link-op $LSR(6) $FA1 orient left

$ns duplex-link  $LSR(6) $FA2 5Mb 2ms DropTail
$ns duplex-link-op $LSR(6) $FA2 orient right

proc finish {} {
    global ns  
    $ns flush-trace
   
    exec nam s1a-out.nam &
    exit 0
}
$ns at 60.0 "finish"
$ns run
