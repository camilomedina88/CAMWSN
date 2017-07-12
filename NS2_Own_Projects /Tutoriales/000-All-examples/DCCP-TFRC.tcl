#    http://www.net.c.dendai.ac.jp/~maeda/dccp.html#c14


#   シミュレーションプログラム

Agent/TCP set window 64
set ns [new Simulator]
set testTime 100.0
#if {$argc $lt; 3} {
#puts stderr "ns dccp.tcl \[x (bottleneck in Mbit/s)\] \[ 2|3 (ccid)\] \[Sack|Newreno (TCP version)\]" 
#exit 1 
#}
set ccid [lindex $argv 1]
set tcpver [lindex $argv 2]
set namfile [open out.nam w]
$ns namtrace-all $namfile
set tracefile1 [open out_dccp.tr w]
$ns trace-all $tracefile1
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
$ns duplex-link $n0 $n2 10Mb 0ms DropTail
$ns duplex-link $n1 $n2 10Mb 0ms DropTail
$ns duplex-link $n2 $n3 10Mb 0ms DropTail
# DCCP
if {$ccid == 3} {
        set dccp1 [new Agent/DCCP/TFRC]
        set dccp2 [new Agent/DCCP/TFRC]
} else {
        set dccp1 [new Agent/DCCP/TCPlike]
        set dccp2 [new Agent/DCCP/TCPlike]
}
$dccp1 set fid_ 2
$dccp2 set fid_ 2
$dccp1 set packetSize_ 552
$dccp2 set packetSize_ 552
$ns attach-agent $n0 $dccp1
$ns attach-agent $n3 $dccp2
set cbr2 [new Application/CBR]
$cbr2 attach-agent $dccp1
$ns connect $dccp1 $dccp2
# TCP
set tcp1 [new Agent/TCP/FullTcp/Sack]
set cbr1 [new Application/CBR]
$cbr1 attach-agent $tcp1
set sink [new Agent/TCP/FullTcp/Sack]
$ns attach-agent $n1 $tcp1
$ns attach-agent $n3 $sink
$tcp1 set fid_ 1
$sink set fid_ 1
$tcp1 set packetSize_ 552
$ns connect $tcp1 $sink
$sink listen
proc finish {} {
   global ns namfile tracefile1  ccid tcpver
   set file "./script-dccp.sh"
   $ns flush-trace
   close $tracefile1
   exec $file $ccid $tcpver
   exit 0
}
proc init {} {
    global dccp1 dccp2
    $dccp1 reset
    $dccp2 reset
}
$ns at 0.1 "init"
$ns at 0.2 "$dccp2 listen"
$ns at 0.3 "$cbr1 start"
$ns at 20.0 "$cbr2 start"
$ns at [expr $testTime - 20] "$cbr2 stop"
$ns at $testTime "$cbr1 stop"
$ns at [expr $testTime + 1.0] "finish"
$ns run
