# ################################################################ #
# #                         PARAMETERS                               #
# # ################################################################ #

set val(stop)                   50
set val(rp)                     AODV
set val(agentTr)                ON
set val(routerTr)               ON
set val(macTr)                  ON
set val(movementTr)             OFF
set val(prop)                   Propagation/TwoRayGround
set val(netif)                  Phy/WirelessPhy 
set val(ifq)                    Queue/DropTail/PriQueue
set val(ll)                     LL
set val(ant)                    Antenna/OmniAntenna
set val(chan)                   Channel/WirelessChannel
set val(mac)                    Mac/802_11
set val(ifqlen)                 100
set val(width)                  500
set val(height)                 500
set val(nn)                     4

#Queue/DropTail/PriQueue set Prefer_Routing_Protocols 0

Phy/WirelessPhy set CSThresh_ 1.14323e-10
Phy/WirelessPhy set RXThresh_ 1.14323e-10

#Phy/WirelessPhy set RXThresh_ 3.652e-10
#Phy/WirelessPhy set CSThresh_ 3.652e-10

#Queue/DropTail/PriQueue set Prefer_Routing_Protocols 0
Mac/802_11 set RTSThreshold_   2000
Mac/802_11 set dataRate_ 2e6
Mac/802_11 set basicRate_ 2e6
#

set ns_         [new Simulator]
set tracefd     [open test.tr w]
set grfd	[open test.dat w]
$ns_ trace-all $tracefd
set topo        [new Topography]
$topo load_flatgrid $val(width) $val(height)
create-god $val(nn)
set chan_1_     [new $val(chan)]

$ns_ node-config   -adhocRouting $val(rp)       \
                    -llType $val(ll)            \
                    -macType $val(mac)          \
                    -ifqType $val(ifq)          \
                    -ifqLen $val(ifqlen)        \
                    -antType $val(ant)          \
                    -propType $val(prop)        \
                    -phyType $val(netif)        \
                    -channel $chan_1_           \
                    -topoInstance $topo         \
                    -agentTrace $val(agentTr)   \
                    -routerTrace $val(routerTr) \
                    -macTrace $val(macTr)       \
                    -movementTrace $val(movementTr)

for {set i 0} {$i < $val(nn) } {incr i} {
        set node_($i) [$ns_ node]
        $node_($i) random-motion 0
}

$node_(0) set X_ 0.0
$node_(0) set Y_ 0.0
$node_(0) set Z_ 1.5

$node_(1) set X_ 50.0
$node_(1) set Y_ 0.0
$node_(1) set Z_ 1.5

$node_(2) set X_ 0.0
$node_(2) set Y_ 50.0
$node_(2) set Z_ 1.5

$node_(3) set X_ 50.0
$node_(3) set Y_ 50.0
$node_(3) set Z_ 1.5
# ################################################################ #
# #                             AGENTS                               #
# # ################################################################ #

#Agent 1 -------------------
set udp1 [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp1

$udp1 set fid_ 1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 1000
$cbr1 set rate_ 1000Kb 
$cbr1 set random_ 0
$cbr1 set maxpkts_ 1000000
$cbr1 attach-agent $udp1

set rcvr1 [new Agent/LossMonitor]
$ns_ attach-agent $node_(1) $rcvr1
$ns_ connect $udp1 $rcvr1

#Agent 2 -------------------
set udp2 [new Agent/UDP]
$ns_ attach-agent $node_(2) $udp2

$udp2 set fid_ 15
set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 1000
$cbr2 set rate_ 1000Kb 
$cbr2 set random_ 0
$cbr2 set maxpkts_ 1000000
$cbr2 attach-agent $udp2

set rcvr2 [new Agent/LossMonitor]
$ns_ attach-agent $node_(3) $rcvr2
$ns_ connect $udp2 $rcvr2

$ns_ at 0.0 "record"

#$ns_ at 0.5 {[$node_(0) set ragent_] findRoute_be 0 1 1000}
$ns_ at 1.0 "$cbr1 start"

#$ns_ at 4.5 {[$node_(2) set ragent_] findRoute 2 3 1000}
$ns_ at 5.0 "$cbr2 start"


$ns_ at 30.0 "$cbr2 stop"


for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop) "$node_($i) reset";
}
$ns_ at $val(stop) "stop"
$ns_ at $val(stop) "puts \"NS exitting...\" ; $ns_ halt"

proc stop {} {
    global ns_ tracefd grfd
    $ns_ flush-trace
    close $tracefd
    close $grfd
}
proc record {} {
	 global rcvr1 grfd
	 global rcvr2 grfd
	 set ns [Simulator instance]
	 set time 1
	 set bw1 [$rcvr1 set bytes_]
	 set bw2 [$rcvr2 set bytes_]
	 set now [$ns now]
	 puts $grfd "$now [expr $bw1/$time*8/1000]   [expr $bw2/$time*8/1000]"
	 $rcvr1 set bytes_ 0
	 $rcvr2 set bytes_ 0
	 $ns at [expr $now+$time] "record"
}
puts "Starting Simulation..."
$ns_ run

