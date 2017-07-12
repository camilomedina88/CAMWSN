# This software was developed at the National Institute of Standards and
# Technology by employees of the Federal Goverment in the course of their
# official duties. This software is an experimental objects. NIST assumes
# no responsibility whatsoever for its use by other parties, and makes no
# guarantees, expressed or implied, about its quality, reliability, or any
# other characteristic. We would appreicate acknowledgement if the software
# is used.

# This software can be redistributed and/or modified freely. We respect 
# that any derivative works bear some notice that they are derived from it,
# any any modified versions bear some notice that they have been modified.

# Jin-Woo Jung, jjw@korea.ac.kr


#initilizations
set ns [new Simulator]
set tf [open out_sip_test.tr w]

$ns namtrace-all $tf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns duplex-link $n4 $n5 1Mb 10ms DropTail
$ns duplex-link-op $n4 $n5 orient right

$ns duplex-link $n0 $n4 1Mb 10ms DropTail
$ns duplex-link-op $n0 $n4 orient down-right

$ns duplex-link $n5 $n1 1Mb 10ms DropTail
$ns duplex-link-op $n5 $n1 orient up-right

$ns duplex-link $n2 $n4 1Mb 10ms DropTail
$ns duplex-link-op $n2 $n4 orient up-right

$ns duplex-link $n3 $n5 1Mb 10ms DropTail
$ns duplex-link-op $n3 $n5 orient up-left


set serverid [$n3 id]
set serverid1 [$n2 id]
set dnsid	[$n5 id]


# agents
set sipA [new Agent/SIP jwjung www.nist.gov]
$sipA set packetSize_ 1000
$sipA set print_ 0
$sipA set Server_ $serverid
$sipA set Lifetime_ 120
$sipA set Mode_ 1
$ns attach-agent $n0 $sipA   

set sipB [new Agent/SIP bykim www.antd.gov]
$sipB set packetSize_ 1000
$sipB set print_ 0
$sipB set Server_ $serverid1
$sipB set Mode_ 1
$sipB set Lifetime_ 120
$ns attach-agent $n1 $sipB

#set sipC[new Agent/SIP culkim www.antd.gov]


set dnsServer [new Agent/DNSAgent]
$dnsServer set print_ 0
$ns attach-agent $n5 $dnsServer


set sipC [new Agent/SIPRedirect www.nist.gov]
$sipC set packetSize_ 1000
$sipC set print_ 0
$ns attach-agent $n3 $sipC

set sipD [new Agent/SIPRedirect www.antd.gov]
$sipD set packetSize_ 1000
$sipD set print_ 0
$ns attach-agent $n2 $sipD

#$ns connect $sipA $sipB


#Setup a RTP traffic over SIP connection
set st [new Application/SIPTraffic]
$st attach-agent $sipA
#$cbr set type_ CBR
$st set packetSize_ 500
$st set rate_ 1mb
$st set random_ false


#finish procedure
proc finish {} {
	global ns tf
	$ns flush-trace
	close $tf
	puts "Running NS-simulation"
#	exec nam out_sip_test.nam &
	exit 0
	}

#$ns at 1.0 "$sipA start"
#$ns at 0.5 "$st register 10"
$ns at 1.0 "$sipA register $serverid"		;# register its location with proxy or redirect server
$ns at 1.2 "$sipB register $serverid1"		;# register its location with protyx or redirect server
$ns at 1.4 "$sipC register $dnsid"
$ns at 1.4 "$sipD register $dnsid"
$ns at 2.0 "$st start bykim www.antd.gov"
$ns at 4.0 "$st send"

$ns at 8.0 "$st stop"
$ns at 10.0 "finish"

$ns run
