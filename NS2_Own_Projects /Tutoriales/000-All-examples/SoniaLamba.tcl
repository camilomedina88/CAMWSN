#     https://groups.google.com/forum/?fromgroups=#!topic/ns-users/rdFGLp-axrM



# Chaitanya NS2 codes 
set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue             ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                        ;# max packet in ifq
set val(nn)             3                         ;# number of mobilenodes
set val(rp)             DSDV                 ;# routing protocol
set val(x)              600
set val(y)              600

Mac/802_11 set dataRate_ 11Mb

#  Global Variables
set ns_         [new Simulator]
set tracefd     [open project1.tr w]
$ns_ trace-all $tracefd

set namtrace [open project1.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

# Create God
create-god $val(nn)

# Create channel
set chan_1_ [new $val(chan)]

$ns_ node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -topoInstance $topo \
                -agentTrace OFF \
                -routerTrace OFF \
                -macTrace ON \
                -movementTrace ON \
                -channel $chan_1_

      for {set i 0} {$i < [expr $val(nn)]} {incr i} {
                  set node_($i) [$ns_ node]
                 $node_($i) random-motion 0              ;# disable random motion
                set mac_($i) [$node_($i) getMac 0]
                 $mac_($i) set RTSThreshold_ 3000       }

$node_(0) set X_ 300.0
$node_(0) set Y_ 250.0
$node_(0) set Z_ 0.0
               
$node_(1) set X_ 200.0
$node_(1) set Y_ 200.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 400.0
$node_(2) set Y_ 200.0
$node_(2) set Z_ 0.0


$ns_ at 0.0 "$node_(0) label AP"
$ns_ at 0.0 "$node_(1) label MN1"
$ns_ at 0.0 "$node_(2) label MN2"

$ns_ at 0.0 "$node_(0) add-mark m1 green circle"
$ns_ at 0.0 "$node_(1) add-mark m1 red circle"
$ns_ at 0.0 "$node_(2) add-mark m1 red circle"

#Set Node 0 as the AP. 
set AP_ADDR1 [$mac_(0) id]
$mac_(0) ap $AP_ADDR1
$mac_(0) ScanType ACTIVE
 $mac_(2) ScanType PASSIVE 

$ns_ at 1.0 "$mac_(1) ScanType ACTIVE"

Application/Traffic/CBR set packetSize_ 1023
Application/Traffic/CBR set rate_ 256Kb

      
set udp1(0) [new Agent/UDP]
$ns_ attach-agent $node_(1) $udp1(0)
set cbr1(0) [new Application/Traffic/CBR]
$cbr1(0) attach-agent $udp1(0)
set null0 [new Agent/Null]
$ns_ attach-agent $node_(2) $null0
$ns_ connect $udp1(0) $null0


for {set i 0} {$i < [expr $val(nn)]} {incr i} {
$ns_ initial_node_pos $node_($i) 40
}

$ns_ at 8.0 "$cbr1(0) start"

$ns_ at 100.0 "stop"
$ns_ at 100.0 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
    exec nam project1.nam &
    exit 0
}

puts "Starting Simulation..."
$ns_ run
