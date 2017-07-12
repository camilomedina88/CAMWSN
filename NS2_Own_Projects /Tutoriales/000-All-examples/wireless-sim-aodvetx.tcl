source dynlibutils.tcl

dynlibload aodvetx     ../src/.libs

set val(chan)           Channel/WirelessChannel    ;# Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             9                          ;# number of mobilenodes
set val(rp)             AODVETX                    ;# routing protocol
set val(rtAgentFunction) create-aodvetx-agent
set val(x)                      500
set val(y)                      500

# Initialize Global Variables
set ns_         [new Simulator]
set tracefd     [open wireless-sim-aodvetx.tr w]
$ns_ trace-all  $tracefd

set namtrace    [open wireless-sim-aodvetx.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)

# Create God
create-god $val(nn)

# Create channel
set chan_ [new $val(chan)]

# Create node(0) "attached" to channel #1

# configure node, please note the change below.
$ns_ node-config -rtAgentFunction $val(rtAgentFunction) \
                -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace ON \
                -movementTrace OFF \
                -channel $chan_

for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns_ node]
}

for {set i 0} {$i < $val(nn)} {incr i} {
    $node_($i) random-motion 0
}

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$node_(0) set X_ 0.0
$node_(0) set Y_ 200.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 0.0
$node_(1) set Y_ 400.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 200.0
$node_(2) set Y_ 100.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 200.0
$node_(3) set Y_ 500.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 300.0
$node_(4) set Y_ 300.0
$node_(4) set Z_ 0.0

$node_(5) set X_ 400.0
$node_(5) set Y_ 100.0
$node_(5) set Z_ 0.0

$node_(6) set X_ 400.0
$node_(6) set Y_ 500.0
$node_(6) set Z_ 0.0

$node_(7) set X_ 600.0
$node_(7) set Y_ 200.0
$node_(7) set Z_ 0.0

$node_(8) set X_ 600.0
$node_(8) set Y_ 400.0
$node_(8) set Z_ 0.0

for {set i 0} {$i < $val(nn)} {incr i} {    
        $ns_ initial_node_pos $node_($i) 20
}

# Setup traffic flow between nodes
# TCP connections between node_(0) and node_(1)

set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp1
$ns_ attach-agent $node_(7) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at 3.0 "$ftp1 start"
set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp2
$ns_ attach-agent $node_(8) $sink2
$ns_ connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns_ at 5.0 "$ftp2 start"

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ at 450.0 "$node_($i) reset";
}

$ns_ at 450.0 "stop"
$ns_ at 450.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run
