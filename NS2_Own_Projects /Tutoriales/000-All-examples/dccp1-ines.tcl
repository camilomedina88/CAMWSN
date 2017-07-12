#
#
# http://www.linuxquestions.org/questions/linux-desktop-74/floating-point-exception-error-while-executing-tcl-with-ns2-4175457686/
#
# ---------------------------------------------------------------


set ns [new Simulator]
set testTime 102.0

#if {$argc < 3} {
#puts stderr "ns dccp.tcl \[x (bottleneck in Mbit/s)\] \[ 2|3 (ccid)\] \[Sack|Newreno (TCP version)\]"
#exit 1
#}

set C [lindex $argv 0]
set ccid [lindex $argv 1]
set tcpver [lindex $argv 2]

# Create a nam trace datafile.
set namfile [open out.nam w]
$ns namtrace-all $namfile

#open the trace file
set tracefile1 [open out_dccp.tr w]
$ns trace-all $tracefile1

# Set up the network topology shown at the top of this file:
set s1 [$ns node]
set s2 [$ns node]
set e1 [$ns node]
set e2 [$ns node]
set dest1 [$ns node]
set dest2 [$ns node]

$ns duplex-link $s1 $e1 10Mb 0ms DropTail
$ns duplex-link $s2 $e1 10Mb 0ms DropTail

$ns duplex-link $e1 $e2 $C.Mb 15ms DropTail

$ns duplex-link $e2 $dest1 10Mb 0ms DropTail
$ns duplex-link $e2 $dest2 10Mb 0ms DropTail

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
$ns attach-agent $s2 $dccp1
$ns attach-agent $dest2 $dccp2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $dccp1
$ns connect $dccp1 $dccp2

# TCP
if {$tcpver == "Sack"} {
set tcp1 [new Agent/TCP/FullTcp/Sack]
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
set sink [new Agent/TCP/FullTcp/Sack]
$ns attach-agent $s1 $tcp1
$ns attach-agent $dest1 $sink
#$tcp1 set window_ $win
#$sink set window_ $win
$tcp1 set fid_ 1
$sink set fid_ 1
$ns connect $tcp1 $sink
# set up TCP-level connections
$sink listen ; # will figure out who its peer is
} else {
set agent(1) [new Agent/TCP/Newreno]
$ns attach-agent $s1 $agent(1)
set ftp1 [new Application/FTP]
$ftp1 attach-agent $agent(1)
set agent(2) [new Agent/TCPSink]
$ns attach-agent $dest1 $agent(2)
$ns connect $agent(1) $agent(2)
}

proc finish {} {
global ns namfile tracefile1 C ccid tcpver
$ns flush-trace
close $tracefile1
exec $file $C $ccid $tcpver
#Execute nam on the trace file
exec nam out.nam &
exit 0
}

proc init {} {
global dccp1 dccp2

$dccp1 reset
$dccp2 reset
}

$ns at 0.1 "init"
$ns at 0.2 "$dccp2 listen"
$ns at 0.3 "$ftp1 start"
$ns at 20.0 "$ftp2 start"
$ns at [expr $testTime - 20] "$ftp2 stop"
$ns at $testTime "$ftp1 stop"
$ns at [expr $testTime + 1.0] "finish"

$ns run
