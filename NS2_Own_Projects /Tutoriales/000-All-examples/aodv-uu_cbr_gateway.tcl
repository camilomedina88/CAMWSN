source dynlibutils.tcl

dynlibload Miracle
dynlibload miraclelink
dynlibload MiracleBasicMovement
dynlibload MiracleWirelessCh
dynlibload MiraclePhy802_11
dynlibload MiracleMac802_11
dynlibload miracleport
dynlibload miraclecbr
dynlibload cbrtracer
dynlibload aodvuu
dynlibload Trace
dynlibload aodvuutracer

dynlibload dei80211mr

dynlibload phytracer

set tracefname "/tmp/aodv-uu_cbr_gateway.tr"

Phy/WirelessPhy/PowerAware set debug_ 0
Module/IP set debug_ 0
Module/AODVUU set llfeedback_ 1
Module/AODVUU set debug_ 0

proc finish {} {
    global ns tf tracefname sink_cbr
    puts "---> SIMULATION DONE."
    $ns flush-trace
    close $tf
    puts "PER: [$sink_cbr getper]"
    puts "FTT: [$sink_cbr getftt]"
    puts "Tracefile: $tracefname"
}

set ns [new Simulator]
$ns use-Miracle

set tf [open $tracefname w]
$ns trace-all $tf

######### Init stuff ##########
set pmodel [new Propagation/MrclFreeSpace]
set channel_1 [new Module/DumbWirelessCh]
set channel_11 [new Module/DumbWirelessCh]
set channel_6 [new Module/DumbWirelessCh]

# create the link between sink node and base station
set duplexlink [new Module/DuplexLink]
$duplexlink bandwidth 100Mb
$duplexlink delay 0.001
$duplexlink qsize 50
$duplexlink settags "wired"

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


create-god 5


######### Create Node 0 ##########
set node0           [$ns create-M_Node]
set node0_cbr       [new Module/CBR]
set node0_port      [new Module/Port/Map]
set node0_aodvuu    [new Module/AODVUU]
set node0_ipif      [new Module/IP/AODVInterface]

$node0_cbr set period_ 0.05

$node0_ipif         addr 10.0.0.2
$node0_ipif         subnet 255.255.255.0

set node0_ll        [create802_11MacModule "LL/Mrcl" "Queue/DropTail/PriQueue" "Mac/802_11/Multirate" [$node0_ipif addr] "" 100 ]
set node0_phy       [createPhyModule "Phy/WirelessPhy/PowerAware" $pmodel "Antenna/OmniAntenna" $node0_ll ""]

set mac             [$node0_ll getMac]
set phy             [$node0_phy getPhy]
$mac                basicMode_ Mode6Mb
$mac                dataMode_ Mode6Mb
$mac                per $per
set node0_pp        [new PowerProfile]
$mac                powerProfile $node0_pp
$phy                powerProfile $node0_pp

set node0_ra        [new RateAdapter/ARF]
$node0_ra           attach2mac $mac
$node0_ra           use80211g
$node0_ra           setmodeatindex 0

# Add modules
$node0 addModule 6 $node0_cbr       3 "n0_CBR"
$node0 addModule 5 $node0_port      3 "n0_PORT"
$node0 addModule 4 $node0_aodvuu    3 "n0_AODV"
$node0 addModule 3 $node0_ipif      3 "n0_IP"
$node0 addModule 2 $node0_ll        3 "n0_LL"
$node0 addModule 1 $node0_phy       3 "n0_PHY"

#Connect modules
$node0 setConnection $node0_cbr     $node0_port 1
$node0 setConnection $node0_port    $node0_aodvuu 1
$node0 setConnection $node0_aodvuu  $node0_ipif 1
$node0 setConnection $node0_ipif    $node0_ll 1
$node0 setConnection $node0_ll      $node0_phy

#Add to channel
$node0 addToChannel $channel_1 $node0_phy 1

$node0_aodvuu add-if $node0_ipif
$node0_aodvuu if-queue [$node0_ll getQueue]


######### Create Node 1 ##########
set node1           [$ns create-M_Node]
set node1_aodvuu    [new Module/AODVUU]

#### IF0 ####
set node1_ipif0     [new Module/IP/AODVInterface]

$node1_ipif0        addr 10.0.0.3
$node1_ipif0        subnet 255.255.255.0

set node1_ll0       [create802_11MacModule "LL/Mrcl" "Queue/DropTail/PriQueue" "Mac/802_11/Multirate" [$node1_ipif0 addr] "" 100 ]
set node1_phy0      [createPhyModule "Phy/WirelessPhy/PowerAware" $pmodel "Antenna/OmniAntenna" $node1_ll0 ""]

set mac             [$node1_ll0 getMac]
set phy             [$node1_phy0 getPhy]
$mac                basicMode_ Mode6Mb
$mac                dataMode_ Mode6Mb
$mac                per $per
set node1_pp0       [new PowerProfile]
$mac                powerProfile $node1_pp0
$phy                powerProfile $node1_pp0

set node1_ra0       [new RateAdapter/ARF]
$node1_ra0          attach2mac $mac
$node1_ra0          use80211g
$node1_ra0          setmodeatindex 0

# Add modules
$node1 addModule 4 $node1_aodvuu    3 "n1_AODV"
$node1 addModule 3 $node1_ipif0     3 "n1_IP0"
$node1 addModule 2 $node1_ll0       3 "n1_LL0"
$node1 addModule 1 $node1_phy0      3 "n1_PHY0"

set node0_cbr_port [$node0_port assignPort $node0_cbr]

#Connect modules
$node1 setConnection $node1_aodvuu  $node1_ipif0 1
$node1 setConnection $node1_ipif0   $node1_ll0 1
$node1 setConnection $node1_ll0     $node1_phy0 1

#Add to channel
$node1 addToChannel $channel_1 $node1_phy0 1

$node1_aodvuu add-if $node1_ipif0
$node1_aodvuu if-queue [$node1_ll0 getQueue]

#### IF1 ####
set node1_ipif1     [new Module/IP/AODVInterface]

$node1_ipif1        addr 10.0.0.4
$node1_ipif1        subnet 255.255.255.0

set node1_ll1       [create802_11MacModule "LL/Mrcl" "Queue/DropTail/PriQueue" "Mac/802_11/Multirate" [$node1_ipif1 addr] "" 100 ]
set node1_phy1      [createPhyModule "Phy/WirelessPhy/PowerAware" $pmodel "Antenna/OmniAntenna" $node1_ll1 ""]

set mac             [$node1_ll1 getMac]
set phy             [$node1_phy1 getPhy]
$mac                basicMode_ Mode6Mb
$mac                dataMode_ Mode6Mb
$mac                per $per
set node1_pp1       [new PowerProfile]
$mac                powerProfile $node1_pp1
$phy                powerProfile $node1_pp1

set node1_ra1       [new RateAdapter/ARF]
$node1_ra1          attach2mac $mac
$node1_ra1          use80211g
$node1_ra1          setmodeatindex 0

# Add modules
$node1 addModule 3 $node1_ipif1     3 "n1_IP1"
$node1 addModule 2 $node1_ll1       3 "n1_LL1"
$node1 addModule 1 $node1_phy1      3 "n1_PHY1"

#Connect modules
$node1 setConnection $node1_aodvuu  $node1_ipif1 1
$node1 setConnection $node1_ipif1   $node1_ll1 1
$node1 setConnection $node1_ll1     $node1_phy1 1

#Add to channel
$node1 addToChannel $channel_11 $node1_phy1 1

$node1_aodvuu add-if $node1_ipif1
$node1_aodvuu if-queue [$node1_ll1 getQueue]

######### Create Node 2 ##########
set node2           [$ns create-M_Node]
set node2_aodvuu    [new Module/AODVUU]

#### IF0 ####
set node2_ipif0     [new Module/IP/AODVInterface]

$node2_ipif0        addr 10.0.0.5
$node2_ipif0        subnet 255.255.255.0

set node2_ll0       [create802_11MacModule "LL/Mrcl" "Queue/DropTail/PriQueue" "Mac/802_11/Multirate" [$node2_ipif0 addr] "" 100 ]
set node2_phy0      [createPhyModule "Phy/WirelessPhy/PowerAware" $pmodel "Antenna/OmniAntenna" $node2_ll0 ""]

set mac             [$node2_ll0 getMac]
set phy             [$node2_phy0 getPhy]
$mac                basicMode_ Mode6Mb
$mac                dataMode_ Mode6Mb
$mac                per $per
set node2_pp0       [new PowerProfile]
$mac                powerProfile $node2_pp0
$phy                powerProfile $node2_pp0

set node2_ra0       [new RateAdapter/ARF]
$node2_ra0          attach2mac $mac
$node2_ra0          use80211g
$node2_ra0          setmodeatindex 0

# Add modules
$node2 addModule 4 $node2_aodvuu    3 "n2_AODV"
$node2 addModule 3 $node2_ipif0     3 "n2_IP0"
$node2 addModule 2 $node2_ll0       3 "n2_LL0"
$node2 addModule 1 $node2_phy0      3 "n2_PHY0"

#Connect modules
$node2 setConnection $node2_aodvuu  $node2_ipif0 1
$node2 setConnection $node2_ipif0   $node2_ll0 1
$node2 setConnection $node2_ll0     $node2_phy0 1

#Add to channel
$node2 addToChannel $channel_11 $node2_phy0 1

$node2_aodvuu add-if $node2_ipif0
$node2_aodvuu if-queue [$node2_ll0 getQueue]

#### IF1 ####
set node2_ipif1     [new Module/IP/AODVInterface]

$node2_ipif1        addr 10.0.0.6
$node2_ipif1        subnet 255.255.255.0

set node2_ll1       [create802_11MacModule "LL/Mrcl" "Queue/DropTail/PriQueue" "Mac/802_11/Multirate" [$node2_ipif1 addr] "" 100 ]
set node2_phy1      [createPhyModule "Phy/WirelessPhy/PowerAware" $pmodel "Antenna/OmniAntenna" $node2_ll1 ""]

set mac             [$node2_ll1 getMac]
set phy             [$node2_phy1 getPhy]
$mac                basicMode_ Mode6Mb
$mac                dataMode_ Mode6Mb
$mac                per $per
set node2_pp1       [new PowerProfile]
$mac                powerProfile $node2_pp1
$phy                powerProfile $node2_pp1

set node2_ra1       [new RateAdapter/ARF]
$node2_ra1          attach2mac $mac
$node2_ra1          use80211g
$node2_ra1          setmodeatindex 0

# Add modules
$node2 addModule 3 $node2_ipif1     3 "n2_IP1"
$node2 addModule 2 $node2_ll1       3 "n2_LL1"
$node2 addModule 1 $node2_phy1      3 "n2_PHY1"

#Connect modules
$node2 setConnection $node2_aodvuu  $node2_ipif1 1
$node2 setConnection $node2_ipif1   $node2_ll1 1
$node2 setConnection $node2_ll1     $node2_phy1 1

#Add to channel
$node2 addToChannel $channel_6 $node2_phy1 1

$node2_aodvuu add-if $node2_ipif1
$node2_aodvuu if-queue [$node2_ll1 getQueue]


######### Create Node 3 (gateway) ##########
set node3           [$ns create-M_Node]
set node3_aodvuu    [new Module/AODVUU]

#### IF0 ####
set node3_ipif0     [new Module/IP/AODVInterface]

$node3_ipif0        addr 10.0.0.1
$node3_ipif0        subnet 255.255.255.0

set node3_ll0       [create802_11MacModule "LL/Mrcl" "Queue/DropTail/PriQueue" "Mac/802_11/Multirate" [$node3_ipif0 addr] "" 100 ]
set node3_phy0      [createPhyModule "Phy/WirelessPhy/PowerAware" $pmodel "Antenna/OmniAntenna" $node3_ll0 ""]

set mac             [$node3_ll0 getMac]
set phy             [$node3_phy0 getPhy]
$mac                basicMode_ Mode6Mb
$mac                dataMode_ Mode6Mb
$mac                per $per
set node3_pp0       [new PowerProfile]
$mac                powerProfile $node3_pp0
$phy                powerProfile $node3_pp0

set node3_ra0       [new RateAdapter/ARF]
$node3_ra0          attach2mac $mac
$node3_ra0          use80211g
$node3_ra0          setmodeatindex 0

# Add modules
$node3 addModule 4 $node3_aodvuu    3 "n3_AODV"
$node3 addModule 3 $node3_ipif0     3 "n3_IP0"
$node3 addModule 2 $node3_ll0       3 "n3_LL0"
$node3 addModule 1 $node3_phy0      3 "n3_PHY0"

#Connect modules
$node3 setConnection $node3_aodvuu  $node3_ipif0 1
$node3 setConnection $node3_ipif0   $node3_ll0 1
$node3 setConnection $node3_ll0     $node3_phy0 1

#Add to channel
$node3 addToChannel $channel_6 $node3_phy0 1

$node3_aodvuu add-if $node3_ipif0
$node3_aodvuu if-queue [$node3_ll0 getQueue]

#### IF1 wired ####
set node3_ipif1     [new Module/IP/AODVInterface]

$node3_ipif1        addr 192.168.0.1
$node3_ipif1        subnet 255.255.255.0

# Add modules
$node3 addModule 3 $node3_ipif1     3 "n3_IP1"

#Connect modules
$node3 setConnection $node3_aodvuu  $node3_ipif1 1

$node3_aodvuu add-gwif $node3_ipif1

$node3_aodvuu set internet_gw_mode_ 1

######### Create sink node ##########
set sink           [$ns create-M_Node]
set sink_cbr       [new Module/CBR]
set sink_port      [new Module/Port/Map]
set sink_ipif      [new Module/IP]

$sink_ipif         addr 192.168.0.3
$sink_ipif         subnet 255.255.255.0

# Add modules
$sink addModule 3 $sink_cbr    3 "snk_CBR "
$sink addModule 2 $sink_port   3 "snk_PORT"
$sink addModule 1 $sink_ipif   3 "snk_IPIF"

set sink_cbr_port [$sink_port assignPort $sink_cbr]

#Connect modules
$sink setConnection $sink_cbr  $sink_port 1
$sink setConnection $sink_port   $sink_ipif 1

# create link between sink node and gateway
$duplexlink connect $node3 $node3_ipif1 1 $sink $sink_ipif 1


#### Positions ####
set node0_position [new "Position/BM"]
$node0 addPosition $node0_position
$node0_position setX_ 0.0
$node0_position setY_ 0.0

set node1_position [new "Position/BM"]
$node1 addPosition $node1_position
$node1_position setX_ 0.0
$node1_position setY_ 100.0

set node2_position [new "Position/BM"]
$node2 addPosition $node2_position
$node2_position setX_ 0.0
$node2_position setY_ 200.0

set node3_position [new "Position/BM"]
$node3 addPosition $node3_position
$node3_position setX_ 0.0
$node3_position setY_ 300.0

$node0_cbr set destAddr_ [$sink_ipif addr]
$node0_cbr set destPort_ $sink_cbr_port

$sink_cbr set destAddr_ [$node0_ipif addr]
$sink_cbr set destPort_ $node0_cbr_port

puts "---> BEGIN SIMULATION"

$ns at 0 "$node0_aodvuu start"
$ns at 0 "$node1_aodvuu start"
$ns at 0 "$node2_aodvuu start"
$ns at 0 "$node3_aodvuu start"
$ns at 5 "$node0_cbr start"
$ns at 100 "$node0_cbr stop"
$ns at 110 "finish; $ns halt"
$ns run

