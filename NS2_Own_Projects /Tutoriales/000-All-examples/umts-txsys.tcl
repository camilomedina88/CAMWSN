#    http://code.google.com/p/txsys/source/browse/trunk/ubiquitous/ns2/eurane/umts.tcl?r=390 



remove-all-packet-headers
add-packet-header MPEG4 MAC_HS RLC LL Mac RTP TCP IP Common Flags

set ns [new Simulator]
set f [open umts.tr w]
$ns trace-all $f

proc finish {} {
    global ns
    global f
    $ns flush-trace
    close $f
    puts "Simulation ended."
    exit 0
}

$ns node-config -UmtsNodeType rnc

set rnc [$ns create-Umtsnode]

$ns node-config -UmtsNodeType bs \
-downlinkBW 32kbs \
-downlinkTTI 10ms \
-uplinkBW 32kbs \
-uplinkTTI 10ms \
-hs_downlinkTTI 2ms \
-hs_downlinkBW 64kbs

set bs [$ns create-Umtsnode]

$ns setup-Iub $bs $rnc 622Mbit 622Mbit 15ms 15ms DummyDropTail 2000

$ns node-config -UmtsNodeType ue \
-baseStation $bs \
-radioNetworkController $rnc

set ue1 [$ns create-Umtsnode]
set ue2 [$ns create-Umtsnode]

set sgsn0 [$ns node]
set ggsn0 [$ns node]

set node1 [$ns node]
set node2 [$ns node]

$ns duplex-link $rnc $sgsn0 622Mbit 0.4ms DropTail 1000
$ns duplex-link $sgsn0 $ggsn0 622Mbit 10ms DropTail 1000
$ns duplex-link $ggsn0 $node1 10MBit 15ms DropTail 1000
$ns duplex-link $node1 $node2 10MBit 35ms DropTail 1000
$rnc add-gateway $sgsn0

set tcp0 [new Agent/TCP]
$tcp0 set fid_ 0
$tcp0 set prio_ 2

set tcp1 [new Agent/TCP]
$tcp1 set fid_ 1
$tcp1 set prio_ 2

$ns attach-agent $node2 $tcp0
$ns attach-agent $node2 $tcp1

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

# Create and attach sinks
set sink0 [new Agent/TCPSink]
$sink0 set fid_ 0
$ns attach-agent $ue1 $sink0

set sink1 [new Agent/TCPSink]
$sink1 set fid_ 1
$ns attach-agent $ue2 $sink1

# Connect sinks to TCP agents
$ns connect $tcp0 $sink0
$ns connect $tcp1 $sink1

$ns node-config -llType UMTS/RLC/AM \
-downlinkBW 64kbs \
-uplinkBW 64kbs \
-downlinkTTI 20ms \
-uplinkTTI 20ms \
-hs_downlinkTTI 2ms \
-hs_downlinkkBW 64kbs

# Create HS-DSCH and attach TCP agent for ue1
$ns create-hsdsch $ue1 $sink0

# Attach TCP agent for ue2 to exsiting HS-DSCH
$ns attach-hsdsch $ue2 $sink1

# Load input tracefile for each UE, identified by its fid_
$bs setErrorTrace 0 "UE1_trace_file"
$bs setErrorTrace 1 "UE2_trace_file"
$bs loadSnrBlerMatrix "SNRBLERMatrix"

# Tracing for all HSDPA traffic in downtarget
$rnc trace-inlink-tcp $f 0
$bs trace-outlink $f 2

# UE1 Tracing
#$ue1 trace-inlink $f 2
#$ue1 trace-outlink $f 3
#$bs trace-inlink $f 3
#$ue1 trace-inlink-tcp $f 2

# UE2 Tracing
#$ue2 trace-inlink $f 2
#$ue2 trace-inlink $f 3
#$bs trace-inlink $f 4
#$ue2 trace-inlink-tcp $f 2


$ns at 0.0 "$ftp0 start"
$ns at 0.002 "$ftp1 start"
$ns at 10.1 "$ftp0 stop"
puts ">>>>>>>>>>>ns reaches here."
$ns at 10.102 "$ftp1 stop"
$ns at 10.201 "finish"

$ns run
