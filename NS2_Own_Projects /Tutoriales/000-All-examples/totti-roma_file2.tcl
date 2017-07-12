
#      https://groups.google.com/forum/?fromgroups#!topic/ns-users/TGTH3Hu89UM

 

set x 500
set y 500
set nn 2
set ns [new Simulator]
set f1 [open out5.tr w]
set topo [new Topography]
$topo load_flatgrid $x $y
set tracefd [open aodv.tr w]
$ns trace-all $tracefd
$ns use-newtrace
set namtrace [open sim12.nam w]
$ns namtrace-all-wireless $namtrace $x $y
set val(chan)         Channel/WirelessChannel
create-god $nn
$ns node-config -adhocRouting AODV \
        -llType LL \
        -macType Mac/802_11 \
        -ifqType Queue/DropTail/PriQueue \
        -ifqLen 50 \
        -antType Antenna/OmniAntenna \
        -propType Propagation/TwoRayGround \
        -phyType Phy/WirelessPhy \
        -channelType Channel/WirelessChannel \
        -topoInstance $topo \
        -agentTrace ON \
        -routerTrace ON \
        -macTrace OFF \
        -movementTrace OFF
set n(0) [$ns node]
set n(1) [$ns node]
$ns initial_node_pos $n(0) 30
$ns initial_node_pos $n(1) 30
for {set i 0} {$i < 2} { incr i } {
            $n($i) random-motion 1
}
$ns at 0.0 "$n(0) setdest 91.7 68.0 10000.0"
$ns at 0.0 "$n(1) setdest 28.4 168.3 10000.0"
#node0

set sctp [new Agent/SCTP]
$ns attach-agent $n(0) $sctp

$sctp attach $tracefd

set sink1 [new Agent/SCTP]
$ns attach-agent $n(1) $sink1
$ns connect $sctp $sink1


set ftp [new Application/FTP]
$ftp set packetSize_ 200
$ftp set burst_time_ 2s
$ftp set idle_time_ 1s
$ftp set rate_ 100kb
$ftp attach-agent $sctp

set holdrate1 0
$sink1 set bytes_ 0
proc record {} {
        global sink1 f0 f1 f2 holdrate1 
        set ns [Simulator instance]
        set time 0.5
    set now [$ns now]
    set bw1 [$sink1 set bytes_]
        puts $f1 "$now [expr (($bw1+$holdrate1)*8)/($time*1000000)]"
        set holdrate1 $bw1
    $ns at [expr $now+$time] "record"
}
for {set i 0} {$i < $nn } {incr i} {
    $ns at 60.0 "$n($i) reset";
}
proc finish {} {
        global ns f0 f1 f2 tracefd namtrace
    close $f1
        $ns flush-trace
        close $tracefd
    close $namtrace
    exec nam sim12.nam &
     exec xgraph out5.tr -geometry 800x400 &
        exit 0
}
$ns at 0.0 "record"
$ns at 10.0 "$ftp start"
$ns at 50.0 "$ftp stop"
$ns at 60.0 "finish"
puts "Starting Simulation..."
$ns run
