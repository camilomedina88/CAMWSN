#      http://www.linuxquestions.org/questions/linux-software-2/getting-error-in-tcl-while-creating-malicious-node-in-aodv-in-ns2-35-a-4175505657/

set ns [new Simulator]
set tf [open tf.tr w]
set ntf [open ntf.nam w]
set val(nn)		15
$ns trace-all $tf
$ns namtrace-all-wireless $ntf 600 600

set topo [new Topography]

$topo load_flatgrid 600 600

create-god 500

$ns node-config -adhocRouting AODV
$ns node-config -antType Antenna/OmniAntenna
$ns node-config -propType Propagation/TwoRayGround
$ns node-config -channelType Channel/WirelessChannel
$ns node-config -macType Mac/802_11
$ns node-config -phyType Phy/WirelessPhy
$ns node-config -ifqType Queue/DropTail/PriQueue
$ns node-config -ifqLen 50
$ns node-config -llType LL
$ns node-config -topoInstance $topo
$ns node-config -macTrace ON
$ns node-config -movementTrace ON
$ns node-config -agentTrace ON
$ns node-config -routerTrace ON


set n0 [$ns node]
set n1 [$ns node]


set n2 [$ns node]

set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]


set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]
set n11 [$ns node]
set n12 [$ns node]
set n13 [$ns node]
set n14 [$ns node]

for {set i 0} {$i < $val(nn) } { incr i } {
        set mnode_($i) [$ns node]
}

$ns at 0.0 "[$mnode_(5) set ragent_] hacker"
for {set i 0} {$i < $val(nn)} { incr i } {
	$ns initial_node_pos $mnode_($i) 10
}

#$ns at 0.04 "[$n2 set ragent_] malicious"

$ns initial_node_pos $n0 40
$ns initial_node_pos $n1 40
$ns initial_node_pos $n2 40
$ns initial_node_pos $n3 40
$ns initial_node_pos $n4 40
$ns initial_node_pos $n5 40

$ns initial_node_pos $n6 40
$ns initial_node_pos $n7 40
$ns initial_node_pos $n8 40
$ns initial_node_pos $n9 40
$ns initial_node_pos $n10 40
$ns initial_node_pos $n11 40
$ns initial_node_pos $n12 40
$ns initial_node_pos $n13 40
$ns initial_node_pos $n14 40
$n0 set X_ 30
$n0 set Y_ 40
$n0 set Z_ 40

$n1 set X_ 100
$n1 set Y_ 100
$n1 set Z_ 40

$n2 set X_ 120
$n2 set Y_ 70
$n2 set Z_ 40

$n3 set X_ 180
$n3 set Y_ 120
$n3 set Z_ 40

$n4 set X_ 130
$n4 set Y_ 220
$n4 set Z_ 40

$n5 set X_ 90
$n5 set Y_ 180
$n5 set Z_ 40




$n6 set X_ 100
$n6 set Y_ 120
$n6 set Z_ 40

$n7 set X_ 220
$n7 set Y_ 370
$n7 set Z_ 40

$n8 set X_ 130
$n8 set Y_ 232
$n8 set Z_ 40

$n9 set X_ 12
$n9 set Y_ 321
$n9 set Z_ 40

$n10 set X_ 424
$n10 set Y_ 123
$n10 set Z_ 40

$n11 set X_ 432
$n11 set Y_ 231
$n11 set Z_ 40

$n12 set X_ 190
$n12 set Y_ 231
$n12 set Z_ 40

$n13 set X_ 134
$n13 set Y_ 421
$n13 set Z_ 40

$n14 set X_ 432
$n14 set Y_ 120
$n14 set Z_ 45




$ns at 0.0 "$n0 setdest 100 50 100"
$ns at 0.02 "$n1 setdest 50 150 100"
$ns at 0.04 "$n2 setdest 200 100 100"
$ns at 0.06 "$n3 setdest 100 200 100"
$ns at 0.08 "$n4 setdest 300 150 40"
$ns at 0.10 "$n5 setdest 200 30 100"

$ns at 0.10 "$n6 setdest 130 130 30"
$ns at 0.10 "$n7 setdest 343 150  200"
$ns at 0.10 "$n8 setdest 450 320 160"
$ns at 0.10 "$n9 setdest 278 340 120"
$ns at 0.10 "$n10 setdest 335 330 30"
$ns at 0.10 "$n11 setdest 300 420 60"
$ns at 0.10 "$n12 setdest 321 120 30"
$ns at 0.10 "$n13 setdest 421 423 89"
$ns at 0.10 "$n14 setdest 342 150 12"



set udp [new Agent/UDP]
set sink [new Agent/LossMonitor]
set vbr [new Application/Traffic/Exponential]


$ns attach-agent $n0 $udp 
$ns attach-agent $n5 $sink
$vbr attach-agent $udp
$vbr set packetSize_ 200
$vbr set idle_time_ 12ms
$vbr set burst_time_ 20ms
$vbr set rate_ 100k

$ns connect $udp $sink


set f1 [open f1.tr w]
set f2 [open f2.tr w]
set f3 [open f3.tr w]

set a1 [open a1.tr w]
set a2 [open a2.tr w]
set a3 [open a3.tr w]


proc record {} {

global ns f1 f2 f3 sink
global f1 f2 f3 a1 a2 a3
set time 0.5
set now [$ns now]

set bw1 [$sink set bytes_]
set bw2 [$sink set npkts_]
set bw3 [$sink set lastPktTime_]

puts $a1 "$now [expr $bw1/$time*8/1000]"
puts $a2 "$now $bw2"
puts $a3 "$now $bw3"

$sink set bytes_ 0
$sink set npkts_ 0
$sink set nlost_ 0

$ns at [expr $now+$time] "record"

}


proc finish {} {

global ns tf ntf  a1 a2 a3
$ns flush-trace 
close $tf
close $ntf
close $a1
close $a2
close $a3
exec nam ntf.nam &
exec xgraph a1.tr a2.tr a3.tr &
exit 0
}

$ns at 0.0 "$vbr start"
$ns at 0.3 "record"

$ns at 20.0 "$vbr stop"
$ns at 20.1 "finish"
$ns run
