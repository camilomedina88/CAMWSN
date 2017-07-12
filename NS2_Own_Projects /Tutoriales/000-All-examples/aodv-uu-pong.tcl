source dynlibutils.tcl

dynlibload Miracle
dynlibload miraclelink
dynlibload MiracleBasicMovement
dynlibload MiracleWirelessCh
dynlibload MiraclePhy802_11
dynlibload MiracleMac802_11
dynlibload miracleport
dynlibload miraclepong
dynlibload aodvuu
dynlibload aodvuutracer
dynlibload Trace
dynlibload aodvuutracer

dynlibload dei80211mr

dynlibload phytracer

set tracefname "/tmp/aodv-uu-pong.tr"

Phy/WirelessPhy/PowerAware set debug_ 0
Module/IP set debug_ 0
Module/AODVUU set llfeedback_ 1
Module/AODVUU set debug_ 10

proc finish {} {
    global ns tf tracefname
    puts "---> SIMULATION DONE."
    $ns flush-trace
    close $tf
    puts "Tracefile: $tracefname"
}

set ns [new Simulator]
$ns use-Miracle

set tf [open $tracefname w]
$ns trace-all $tf

######### Init stuff ##########
set pmodel [new Propagation/MrclFreeSpace]
set channel [new Module/DumbWirelessCh]
set per [new PER]
$per loadDefaultPERTable
$per set noise_ 7e-11
Mac/802_11 set RTSThreshold_ 2000
Mac/802_11 set ShortRetryLimit_ 4
Mac/802_11 set LongRetryLimit_ 3
Mac/802_11/Multirate set useShortPreamble_ true
Mac/802_11/Multirate set gSyncInterval_ 0.000005
Mac/802_11/Multirate set bSyncInterval_ 0.00001

Phy/WirelessPhy set Pt_ 0.01
Phy/WirelessPhy set freq_ 2437e6
Phy/WirelessPhy set L_ 1.0
Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1
Queue/DropTail/PriQueue set size_ 1000

ConnectorTrace/ChSAP set debug_ 0
ConnectorTrace/Bin set debug_ 0

ConnectorTrace/Bin set depth 5

Mac/802_11 set RTSThreshold_ 2000


create-god 3


######### Create Node 1 ##########
set node1 [$ns create-M_Node]
set pong1 [new Module/Pong]
set AODVUU1 [new Module/AODVUU]
set IPIF1 [new Module/IP/AODVInterface]

$IPIF1 addr 10.0.0.1
$IPIF1 subnet 255.255.255.0

set LL1 [create802_11MacModule "LL/Mrcl" "Queue/DropTail/PriQueue" "Mac/802_11/Multirate" [$IPIF1 addr] "" 100 ]
set PHY1 [createPhyModule "Phy/WirelessPhy/PowerAware" $pmodel "Antenna/OmniAntenna" $LL1 ""]

set mac1 [$LL1 getMac]
set phy1 [$PHY1 getPhy]
$mac1 basicMode_ Mode6Mb
$mac1 dataMode_ Mode6Mb
$mac1 per $per
set pp1 [new PowerProfile]
$mac1 powerProfile $pp1
$phy1 powerProfile $pp1


set ra1 [new RateAdapter/ARF]
$ra1 attach2mac $mac1
$ra1 use80211g
$ra1 setmodeatindex 0

$node1 addModule 5 $pong1 3 "APP"
$node1 addModule 4 $AODVUU1 3 "AODV"
$node1 addModule 3 $IPIF1 3 "IP"
$node1 addModule 2 $LL1 3 "LL"
$node1 addModule 1 $PHY1 3 "PHY"
$node1 setConnection $pong1 $AODVUU1 1
$node1 setConnection $AODVUU1 $IPIF1 1
$node1 setConnection $IPIF1 $LL1 1
$node1 setConnection $LL1 $PHY1 1
$node1 addToChannel $channel $PHY1 1

$AODVUU1 add-if $IPIF1
$AODVUU1 if-queue [$LL1 getQueue]


######### Create Node 2 ##########
set node2 [$ns create-M_Node]
set pong2 [new Module/Pong]
set AODVUU2 [new Module/AODVUU]
set IPIF2 [new Module/IP/AODVInterface]

$IPIF2 addr 10.0.0.2
$IPIF2 subnet 255.255.255.0

set LL2 [create802_11MacModule "LL/Mrcl" "Queue/DropTail/PriQueue" "Mac/802_11/Multirate" [$IPIF2 addr] "" 100 ]
set PHY2 [createPhyModule "Phy/WirelessPhy/PowerAware" $pmodel "Antenna/OmniAntenna" $LL2 ""]

set mac2 [$LL2 getMac]
set phy2 [$PHY2 getPhy]
$mac2 basicMode_ Mode6Mb
$mac2 dataMode_ Mode6Mb
$mac2 per $per
set pp2 [new PowerProfile]
$mac2 powerProfile $pp2
$phy2 powerProfile $pp2


set ra2 [new RateAdapter/ARF]
$ra2 attach2mac $mac2
$ra2 use80211g
$ra2 setmodeatindex 0

$node2 addModule 5 $pong2 3 "APP"
$node2 addModule 4 $AODVUU2 3 "AODV"
$node2 addModule 3 $IPIF2 3 "IP"
$node2 addModule 2 $LL2 3 "LL"
$node2 addModule 1 $PHY2 3 "PHY"
$node2 setConnection $pong2 $AODVUU2 1
$node2 setConnection $AODVUU2 $IPIF2 1
$node2 setConnection $IPIF2 $LL2 1
$node2 setConnection $LL2 $PHY2 1
$node2 addToChannel $channel $PHY2 1

$AODVUU2 add-if $IPIF2
$AODVUU2 if-queue [$LL2 getQueue]


######### Create Node 3 ##########
set node3 [$ns create-M_Node]
set pong3 [new Module/Pong]
set AODVUU3 [new Module/AODVUU]
set IPIF3 [new Module/IP/AODVInterface]

$IPIF3 addr 10.0.0.3
$IPIF3 subnet 255.255.255.0

set LL3 [create802_11MacModule "LL/Mrcl" "Queue/DropTail/PriQueue" "Mac/802_11/Multirate" [$IPIF3 addr] "" 100 ]
set PHY3 [createPhyModule "Phy/WirelessPhy/PowerAware" $pmodel "Antenna/OmniAntenna" $LL3 ""]

set mac3 [$LL3 getMac]
set phy3 [$PHY3 getPhy]
$mac3 basicMode_ Mode6Mb
$mac3 dataMode_ Mode6Mb
$mac3 per $per
set pp3 [new PowerProfile]
$mac3 powerProfile $pp3
$phy3 powerProfile $pp3


set ra3 [new RateAdapter/ARF]
$ra3 attach2mac $mac3
$ra3 use80211g
$ra3 setmodeatindex 0

$node3 addModule 5 $pong3 3 "APP"
$node3 addModule 4 $AODVUU3 3 "AODV"
$node3 addModule 3 $IPIF3 3 "IP"
$node3 addModule 2 $LL3 3 "LL"
$node3 addModule 1 $PHY3 3 "PHY"
$node3 setConnection $pong3 $AODVUU3 1
$node3 setConnection $AODVUU3 $IPIF3 1
$node3 setConnection $IPIF3 $LL3 1
$node3 setConnection $LL3 $PHY3 1
$node3 addToChannel $channel $PHY3 1

$AODVUU3 add-if $IPIF3
$AODVUU3 if-queue [$LL3 getQueue]


#### Position ####
set position1 [new "Position/BM"]
$node1 addPosition $position1
$position1 setX_ 0.0
$position1 setY_ 0.0

set position2 [new "Position/BM"]
$node2 addPosition $position2
$position2 setX_ 10.0
$position2 setY_ 10.0

set position3 [new "Position/BM"]
$node3 addPosition $position3
$position3 setX_ 80.0
$position3 setY_ 80.0

puts "---> BEGIN SIMULATION"

$ns at 0 "$AODVUU1 start"
$ns at 0 "$AODVUU2 start"
$ns at 0 "$AODVUU3 start"
$ns at 5 "$pong1 send [$IPIF2 addr]"
$ns at 6 "$pong1 send [$IPIF2 addr]"
$ns at 6 "$position2 setdest 160 160 10"
$ns at 7 "$pong1 send [$IPIF2 addr]"
$ns at 8 "$pong1 send [$IPIF2 addr]"
$ns at 9 "$pong1 send [$IPIF2 addr]"
$ns at 10 "$pong1 send [$IPIF2 addr]"
$ns at 11 "$pong1 send [$IPIF2 addr]"
$ns at 12 "$pong1 send [$IPIF2 addr]"
$ns at 13 "$pong1 send [$IPIF2 addr]"
$ns at 14 "$pong1 send [$IPIF2 addr]"
$ns at 15 "$pong1 send [$IPIF2 addr]"
$ns at 16 "$pong1 send [$IPIF2 addr]"
$ns at 17 "$pong1 send [$IPIF2 addr]"
$ns at 18 "$pong1 send [$IPIF2 addr]"
$ns at 19 "$pong1 send [$IPIF2 addr]"
$ns at 20 "$pong1 send [$IPIF2 addr]"
$ns at 21 "$pong1 send [$IPIF2 addr]"
$ns at 22 "$pong1 send [$IPIF2 addr]"
$ns at 23 "$pong1 send [$IPIF2 addr]"
$ns at 24 "$pong1 send [$IPIF2 addr]"
$ns at 25 "$pong1 send [$IPIF2 addr]"
$ns at 26 "$pong1 send [$IPIF2 addr]"
$ns at 27 "$pong1 send [$IPIF2 addr]"
$ns at 27 "$position2 setdest 160 160 0"
$ns at 28 "$pong1 send [$IPIF2 addr]"
$ns at 29 "$pong1 send [$IPIF2 addr]"
$ns at 30 "$pong1 send [$IPIF2 addr]"
$ns at 31 "$pong1 send [$IPIF2 addr]"
$ns at 32 "$pong1 send [$IPIF2 addr]"
$ns at 33 "$pong1 send [$IPIF2 addr]"
$ns at 34 "$pong1 send [$IPIF2 addr]"
$ns at 40 "finish; $ns halt"
$ns run

