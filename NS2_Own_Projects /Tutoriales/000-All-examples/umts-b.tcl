#
# http://www.linuxquestions.org/questions/linux-newbie-8/ns2-4175449125/page4.html#post4929043
# Post # 48

global ns
set ns [new Simulator]
set tracefile [open umts.tr w]
$ns trace-all $tracefile
set namfile [open u1.nam w]
$ns namtrace-all $namfile
$ns use-newtrace
proc finish {} {
global ns 
global tracefile
$ns flush-trace
close $tracefile
exec nam u1.nam &
puts "Simulation ended."
exit 0
}

$ns node-config -UmtsNodeType rnc

# Node address is 0.
set rnc [$ns create-Umtsnode]

$ns node-config -UmtsNodeType bs \
-downlinkBW 32kbs \
-downlinkTTI 10ms \
-uplinkBW 32kbs \
-uplinkTTI 10ms

# Node address is 1.
set bs [$ns create-Umtsnode]

$ns setup-Iub $bs $rnc 622Mbit 622Mbit 15ms 15ms DummyDropTail 2000

$ns node-config -UmtsNodeType ue \
-baseStation $bs \
-radioNetworkController $rnc

# Node addresses for ue1 and ue2 are 2 and 3, respectively.
set ue1 [$ns create-Umtsnode]
set ue2 [$ns create-Umtsnode]

# Node addresses for sgsn0 and ggsn0 are 4 and 5, respectively.
set sgsn0 [$ns node]
set ggsn0 [$ns node]

# Node addresses for node1 and node2 are 6 and 7, respectively.
set node1 [$ns node]
set node2 [$ns node]

$ns duplex-link $rnc $sgsn0 622Mbit 0.4ms DropTail 1000
$ns duplex-link $sgsn0 $ggsn0 622MBit 10ms DropTail 1000
$ns duplex-link $ggsn0 $node1 10MBit 15ms DropTail 1000
$ns duplex-link $node1 $node2 10MBit 35ms DropTail 1000
$rnc add-gateway $sgsn0

set tcp0 [new Agent/TCP]
$tcp0 set packetSize_ 2100
$tcp0 set fid_ 0
$ns attach-agent $node2 $tcp0

set traffic [new Application/Traffic/CBR]
$traffic set rate_ 100kbps
$traffic attach-agent $tcp0

set sink0 [new Agent/TCPSink]
$sink0 set fid_ 0
$ns attach-agent $ue1 $sink0

$ns connect $tcp0 $sink0

$ns node-config -llType UMTS/RLC/AM \
-downlinkBW 384kbs \
-uplinkBW 128kbs \
-downlinkTTI 10ms \
-uplinkTTI 20ms

set dch0 [$ns create-dch $ue1 $sink0]

$ns at 0.0 "$traffic start"
$ns at 200.0 "$traffic stop"
$ns at 210.0 "finish"
$ns run 
