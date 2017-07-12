#    http://enggedu.com/source_code/ns2/ns2/wired/TCL_script_to_create_telnet_traffic.php


#Create a simulator object
set ns [new Simulator]

#Open a nam trace file

set nf [open out.nam w]

$ns namtrace-all $nf

#Define a 'finish' procedure

proc finish {} {

global ns nf

$ns flush-trace

close $nf

exec nam out.nam &

exit 0

}

set n0 [$ns node]
set n1 [$ns node]

$n0 color blue

$n1 color red

#Connect the nodes with two links

$ns duplex-link $n0 $n1 1Mb 10ms DropTail

proc telnet_traffic {node0 node1 } {

global ns

set telnet_TCP_agent [new Agent/TCP]

set telnet_TCP_sink [new Agent/TCPSink]

$ns attach-agent $node0 $telnet_TCP_agent

$ns attach-agent $node1 $telnet_TCP_sink

$ns connect $telnet_TCP_agent $telnet_TCP_sink

set telnet_TELNET_source [new Application/Telnet]

$telnet_TELNET_source attach-agent $telnet_TCP_agent

$telnet_TELNET_source set interval_ 20

$ns at 0.2 "$telnet_TELNET_source start"

$ns at 4.0 "$telnet_TELNET_source stop"

}

telnet_traffic $n0 $n1

$ns at 7.0 "finish"

$ns run 
