# ################################################################ #
# #                         PARAMETERS                               #
# # ################################################################ #

set val(stop)                   100
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
set val(width)                 	1000
set val(height)                 	1000
set val(nn)                     	20

#Queue/DropTail/PriQueue set Prefer_Routing_Protocols 0

#Phy/WirelessPhy set RXThresh_ 3.652e-10
#Phy/WirelessPhy set CSThresh_ 3.652e-10
Queue/DropTail/PriQueue set Prefer_Routing_Protocols 0
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

$node_(0) set X_ 944.1
$node_(0) set Y_ 803.3
$node_(0) set Z_ 1.5

$node_(1) set X_ 149.0
$node_(1) set Y_ 785.8
$node_(1) set Z_ 1.5

$node_(2) set X_ 194.2
$node_(2) set Y_ 445.1
$node_(2) set Z_ 1.5

$node_(3) set X_ 21.3
$node_(3) set Y_ 793.5
$node_(3) set Z_ 1.5

$node_(4) set X_ 95.0
$node_(4) set Y_ 467.7
$node_(4) set Z_ 1.5

$node_(5) set X_ 176.3
$node_(5) set Y_ 81.1
$node_(5) set Z_ 1.5

$node_(6) set X_ 938.2
$node_(6) set Y_ 40.9
$node_(6) set Z_ 1.5

$node_(7) set X_ 361.9
$node_(7) set Y_ 87.6
$node_(7) set Z_ 1.5

$node_(8) set X_ 365.1
$node_(8) set Y_ 3.6
$node_(8) set Z_ 1.5

$node_(9) set X_ 952.4
$node_(9) set Y_ 46.5
$node_(9) set Z_ 1.5

$node_(10) set X_ 35.1
$node_(10) set Y_ 566.6
$node_(10) set Z_ 1.5

$node_(11) set X_ 85.9
$node_(11) set Y_ 673.7
$node_(11) set Z_ 1.5

$node_(12) set X_ 819.0
$node_(12) set Y_ 500.1
$node_(12) set Z_ 1.5

$node_(13) set X_ 53.3
$node_(13) set Y_ 367.5
$node_(13) set Z_ 1.5

$node_(14) set X_ 390.3
$node_(14) set Y_ 406.4
$node_(14) set Z_ 1.5

$node_(15) set X_ 338.5
$node_(15) set Y_ 154.2
$node_(15) set Z_ 1.5

$node_(16) set X_ 225.1
$node_(16) set Y_ 488.5
$node_(16) set Z_ 1.5

$node_(17) set X_ 168.7
$node_(17) set Y_ 924.8
$node_(17) set Z_ 1.5

$node_(18) set X_ 314.9
$node_(18) set Y_ 489.3
$node_(18) set Z_ 1.5

$node_(19) set X_ 737.1
$node_(19) set Y_ 172.3
$node_(19) set Z_ 1.5


# ################################################################ #
# #                             AGENTS                               #
# # ################################################################ #

#Agent 1 -------------------
set udp1 [new Agent/UDP]
$ns_ attach-agent $node_(15) $udp1

$udp1 set fid_ 1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 1000
$cbr1 set rate_ 171Kb 
$cbr1 set random_ 0
$cbr1 set maxpkts_ 1000000
$cbr1 attach-agent $udp1

set rcvr1 [new Agent/LossMonitor]
$ns_ attach-agent $node_(17) $rcvr1
$ns_ connect $udp1 $rcvr1

#Agent 2 -------------------
set udp2 [new Agent/UDP]
$ns_ attach-agent $node_(7) $udp2

$udp2 set fid_ 1
set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 1000
$cbr2 set rate_ 140Kb 
$cbr2 set random_ 0
$cbr2 set maxpkts_ 1000000
$cbr2 attach-agent $udp2

set rcvr2 [new Agent/LossMonitor]
$ns_ attach-agent $node_(12) $rcvr2
$ns_ connect $udp2 $rcvr2

#Agent 3 -------------------
set udp3 [new Agent/UDP]
$ns_ attach-agent $node_(8) $udp3

$udp3 set fid_ 1
set cbr3 [new Application/Traffic/CBR]
$cbr3 set packetSize_ 1000
$cbr3 set rate_ 90Kb 
$cbr3 set random_ 0
$cbr3 set maxpkts_ 1000000
$cbr3 attach-agent $udp3

set rcvr3 [new Agent/LossMonitor]
$ns_ attach-agent $node_(1) $rcvr3
$ns_ connect $udp3 $rcvr3

#Agent 4 -------------------
set udp4 [new Agent/UDP]
$ns_ attach-agent $node_(5) $udp4

$udp4 set fid_ 2
set cbr4 [new Application/Traffic/CBR]
$cbr4 set packetSize_ 1000
$cbr4 set rate_ 58Kb 
$cbr4 set random_ 0
$cbr4 set maxpkts_ 1000000
$cbr4 attach-agent $udp4

set rcvr4 [new Agent/LossMonitor]
$ns_ attach-agent $node_(7) $rcvr4
$ns_ connect $udp4 $rcvr4

#Agent 5 -------------------
set udp5 [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp5

$udp5 set fid_ 3
set cbr5 [new Application/Traffic/CBR]
$cbr5 set packetSize_ 1000
$cbr5 set rate_ 136Kb 
$cbr5 set random_ 0
$cbr5 set maxpkts_ 1000000
$cbr5 attach-agent $udp5

set rcvr5 [new Agent/LossMonitor]
$ns_ attach-agent $node_(12) $rcvr5
$ns_ connect $udp5 $rcvr5

#Agent 6 -------------------
set udp6 [new Agent/UDP]
$ns_ attach-agent $node_(12) $udp6

$udp6 set fid_ 4
set cbr6 [new Application/Traffic/CBR]
$cbr6 set packetSize_ 1000
$cbr6 set rate_ 149Kb 
$cbr6 set random_ 0
$cbr6 set maxpkts_ 1000000
$cbr6 attach-agent $udp6

set rcvr6 [new Agent/LossMonitor]
$ns_ attach-agent $node_(17) $rcvr6
$ns_ connect $udp6 $rcvr6

$ns_ at 0.0 "record"
$ns_ at 4.5 {[$node_(15) set ragent_] findRoute_be 15 17 171}
$ns_ at 5 "$cbr1 start"

$ns_ at 9.5 {[$node_(7) set ragent_] findRoute_be 7 12 140}
$ns_ at 10 "$cbr2 start"

$ns_ at 14.5 {[$node_(8) set ragent_] findRoute_be 8 1 90}
$ns_ at 15 "$cbr3 start"

$ns_ at 19.5 {[$node_(5) set ragent_] findRoute 5 7 58}
$ns_ at 20 "$cbr4 start"

$ns_ at 24.5 {[$node_(0) set ragent_] findRoute 0 12 136}
$ns_ at 25 "$cbr5 start"

$ns_ at 29.5 {[$node_(12) set ragent_] findRoute 12 17 149}
$ns_ at 30 "$cbr6 start"


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
	 global rcvr3 grfd
	 global rcvr4 grfd
	 global rcvr5 grfd
	 global rcvr6 grfd
	 set ns [Simulator instance]
	 set time 1
	 set bw1 [$rcvr1 set bytes_]
	 set bw2 [$rcvr2 set bytes_]
	 set bw3 [$rcvr3 set bytes_]
	 set bw4 [$rcvr4 set bytes_]
	 set bw5 [$rcvr5 set bytes_]
	 set bw6 [$rcvr6 set bytes_]
	 set now [$ns now]
	 puts $grfd "$now [expr $bw1/$time*8/1000]   [expr $bw2/$time*8/1000]   [expr $bw3/$time*8/1000]   [expr $bw4/$time*8/1000]   [expr $bw5/$time*8/1000]   [expr $bw6/$time*8/1000]   "
	 $rcvr1 set bytes_ 0
	 $rcvr2 set bytes_ 0
	 $rcvr3 set bytes_ 0
	 $rcvr4 set bytes_ 0
	 $rcvr5 set bytes_ 0
	 $rcvr6 set bytes_ 0
	 $ns at [expr $now+$time] "record"
}
puts "Starting Simulation..."
$ns_ run
