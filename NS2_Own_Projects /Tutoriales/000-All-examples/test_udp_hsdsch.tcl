#debug 1
#
# Name: appTahoe-ftp.tcl
#
# The Uu interface is assumed to be ideal.
#
# TCP Tahoe
#
# $Id: test-2.tcl,v 1.4 2004/01/20 13:29:24 simon Exp $

global ns


remove-all-packet-headers
add-packet-header MPEG4 MAC_HS RLC LL Mac RTP TCP IP Common Flags


set ns [new Simulator]

set f [open out.tr w]
$ns trace-all $f


proc finish {} {
    global ns
    global f
    $ns flush-trace
    close $f
    puts " Simulation ended."
    exit 0
}

$ns set debug_ 0

$ns set hsdschEnabled_ 1
$ns set hsdsch_rlc_set_ 0
$ns set hsdsch_rlc_nif_ 0

$ns node-config -UmtsNodeType rnc

# Node address is 0.
set rnc [$ns create-Umtsnode]

$ns node-config -UmtsNodeType bs \
		-downlinkBW 32kbs \
		-downlinkTTI 10ms \
		-uplinkBW 32kbs \
		-uplinkTTI 10ms \
      -hs_downlinkTTI 2ms \
      -hs_downlinkBW 64kbs \

# Node address is 1.
set bs [$ns create-Umtsnode]

$ns setup-Iub $bs $rnc 622Mbit 622Mbit 15ms 15ms DummyDropTail 2000

$ns node-config -UmtsNodeType ue \
		-baseStation $bs \
		-radioNetworkController $rnc

# Node address for ue1 and ue2 is 2 and 3, respectively.
set ue1 [$ns create-Umtsnode]
set ue2 [$ns create-Umtsnode]

# Node address for sgsn0 and ggsn0 is 4 and 5, respectively.
set sgsn0 [$ns node]
set ggsn0 [$ns node]

# Node address for node1 and node2 is 6 and 7, respectively.
set node1 [$ns node]
set node2 [$ns node]

$ns duplex-link $rnc $sgsn0 622Mbit 0.4ms DropTail 1000
$ns duplex-link $sgsn0 $ggsn0 622MBit 10ms DropTail 1000
$ns duplex-link $ggsn0 $node1 10MBit 15ms DropTail 1000
$ns duplex-link $node1 $node2 10MBit 35ms DropTail 1000
$rnc add-gateway $sgsn0

set tcp0 [new Agent/UDP]
$tcp0 set fid_ 0
$tcp0 set prio_ 2

$ns attach-agent $node2 $tcp0
#$ns attach-agent $rnc $tcp0

set ftp0 [new Application/Traffic/CBR]
$ftp0 attach-agent $tcp0

set sink0 [new Agent/Null]
$sink0 set fid_ 0
$ns attach-agent $ue1 $sink0

$ns connect $tcp0 $sink0

$ns node-config -llType UMTS/RLC/UM \
		-downlinkBW 64kbs \
		-uplinkBW 64kbs \
		-downlinkTTI 20ms \
		-uplinkTTI 20ms \
      -hs_downlinkTTI 2ms \
      -hs_downlinkBW 64kbs

$ns create-hsdsch $ue1 $sink0


$bs setErrorTrace 0 "idealtrace"
$bs setErrorTrace 1 "idealtrace"
$bs loadSnrBlerMatrix "SNRBLERMatrix"

#set dch0 [$ns create-dch $ue1 $sink0]

$ue1 trace-inlink $f 1
$bs trace-outlink $f 1
$rnc trace-inlink-tcp $f 0
$rnc trace-outlink $f 2

# tracing for all hsdpa traffic in downtarget
$rnc trace-inlink-tcp $f 0
$bs trace-outlink $f 2

# per UE
$ue1 trace-inlink $f 2
$ue1 trace-outlink $f 3
$bs trace-inlink $f 3
$ue1 trace-inlink-tcp $f 2


$ns at 0.0 "$ftp0 start"
$ns at 100.0 "$ftp0 stop"
$ns at 100.401 "finish"

puts " Simulation is running ... please wait ..."
$ns run
