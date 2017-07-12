# http://answerpot.com/showthread.php?2169637-error+model+under+EURANE
#

###############TCL script####################
global ns

# Remove all Packet headers and add only those that are required.
# This significantly reduces the memory requirements of large simulations
remove-all-packet-headers
add-packet-header MPEG4 MAC_HS RLC LL Mac RTP TCP IP Common Flags

set ns [new Simulator]

set f [open out.tr w]
$ns trace-all $f

ChannelSwitcher set noSwitching_ true

proc finish {} {
global ns
global f
$ns flush-trace
close $f
puts " Simulation ended."
exit 0
}


Mac/Hsdpa set max_mac_hs_buffer_level_ 1000
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

# Interface between RNC and BS
$ns setup-Iub $bs $rnc 622Mbit 622Mbit 15ms 15ms DummyDropTail 2000

$ns node-config -UmtsNodeType ue \
-baseStation $bs \
-radioNetworkController $rnc

# Node address for ue1 and ue2 is 2 and 3, respectively.
set ue1 [$ns create-Umtsnode]
set ue2 [$ns create-Umtsnode]

# Node address for node1 is 4
set node1 [$ns node]

# Connections between fixed network nodes
$ns duplex-link $rnc $node1 10Mbit 35ms DropTail 1000
$rnc add-gateway $node1

ChannelSwitcher set noSwitching_ true

#Setup a UDP connection
set udp [new Agent/UDP]
$udp set fid_ 0
$ns attach-agent $node1 $udp

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 4.2mb
$cbr set random_ false

set null [new Agent/Null]
#$null set fid_ 0
$ns attach-agent $ue1 $null
$ns connect $udp $null


$ns node-config -llType UMTS/RLC/AM \
-downlinkBW 64kbs \
-uplinkBW 64kbs \
-downlinkTTI 20ms \
-uplinkTTI 20ms \
-hs_downlinkTTI 2ms \
-hs_downlinkBW 64kbs

# Creat a DCH instead
set dch0 [$ns create-dch $ue1 $null]

#########################error model###########################
set em [new ErrorModel]
$em unit pkt
$em set rate 0.9
$em ranvar [new RandomVariable/Uniform]
$em drop-target [new Agent/Null]
$ue1 interface-errormodel $em 2
#########################error model###########################

# Tracing for all DCH traffic in downtarget
$rnc trace-inlink-tcp $f 0
$bs trace-outlink $f 2

# UE1 Tracing
$ue1 trace-inlink $f 1
$ue1 trace-inlink $f 2
#$ue1 trace-inlink-tcp $f 2


$ns at 1 "$cbr start"
$ns at 50 "$cbr stop"
$ns at 60 "finish"

puts " Simulation is running ... please wait ..."
$ns run 
