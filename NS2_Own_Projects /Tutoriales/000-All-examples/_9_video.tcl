set ns [new Simulator]
$ns color 1 Blue
#open trace files
set tracefile1 [open out.tr w]
set winfile [open Winfile w]
$ns trace-all $tracefile1
set namfile [open out.nam w]
$ns namtrace-all $namfile
#define finish
proc finish {} {
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
}
#declear nodes
set n0 [$ns node]
set n1 [$ns node]
$n0 color red
$n1 color blue
#creat links
$ns duplex-link $n0 $n1 2Mbps 10ms DropTail
$ns duplex-link-op $n0 $n1 orient right-up
$ns duplex-link-op $n0 $n1 color green
#set queue size of link
$ns queue-limit $n0 $n1 20
#creat connection
set udp [new Agent/UDP]
set null [new Agent/Null]
$ns attach-agent $n0 $udp
$ns attach-agent $n1 $null
$ns connect $udp $null
set vdo [new Application/Traffic/MPEG4]
$vdo set initialSeed_ 0.4
$vdo set rateFactor_ 5
$vdo attach-agent $udp

#ftp connection
$ns at 1.8 "$vdo start"
$ns at 50.0 "finish"
$ns run
