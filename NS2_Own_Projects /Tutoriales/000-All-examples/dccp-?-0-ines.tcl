#  http://www.linuxquestions.org/questions/linux-networking-3/floating-point-exception-error-while-executing-tcl-with-ns2-4175457326/#post4927449


set ns [new Simulator]
set testTime 102.0

Agent/TCP set window_ 64


set C [lindex $argv 0]
set tcpver [lindex $argv 1]

# Create a nam trace datafile.
#set namfile [open out.nam w]
#$ns namtrace-all $namfile

#open the trace file
set tracefile1 [open out_tfrc.tr w]
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

# TFRC
set ftp2 [$ns create-connection TFRC $s2 TFRCSink $dest2 0]

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
global ns namfile tracefile1 C tcpver

$ns flush-trace
close $tracefile1
exec $file $C $tcpver
#Execute nam on the trace file
exec nam out.nam &
exit 0
}

$ns at 0.3 "$ftp1 start"
$ns at 20.0 "$ftp2 start"
$ns at [expr $testTime - 20] "$ftp2 stop"
$ns at $testTime "$ftp1 stop"
$ns at [expr $testTime + 1.0] "finish"

$ns at 2.0 "finish"
$ns run
