source dynlibutils.tcl

dynlibload Miracle
dynlibload miraclelink
dynlibload MiracleBasicMovement
dynlibload MiracleWirelessCh
dynlibload MiraclePhy802_11
dynlibload MiracleMac802_11
dynlibload mac80211tracer
dynlibload arptracer
dynlibload miraclepong
dynlibload aodvuu
dynlibload Trace
dynlibload aodvuutracer
dynlibload dei80211mr
dynlibload phytracer

####################### Global settings ########################
set tracefname "/tmp/aodv-uu_mesh_plus_wired.tr"
# number of 802.11 nodes
set NUMWNODES		4
# number of APs, which also corresponds to
# the number of 802.11 interfaces per node
set NUMAPNODES		3
# number of wired nodes
set NUMWRDNODES		1
# Stop time
set STOP 100
# total number of wireless devices
set NUMWD [expr $NUMWNODES + $NUMAPNODES + $NUMWRDNODES]

# Phy
Phy/WirelessPhy set Pt_ 0.01
Phy/WirelessPhy set L_ 1.0
Phy/WirelessPhy/PowerAware set debug_ 0

# Mac
Mac/802_11 set debug_ 0
Mac/802_11 set RTSThreshold_ 2000
Mac/802_11 set ShortRetryLimit_ 4
Mac/802_11 set LongRetryLimit_ 3
Mac/802_11/Multirate set useShortPreamble_ true
Mac/802_11/Multirate set gSyncInterval_ 0.000005
Mac/802_11/Multirate set bSyncInterval_ 0.00001
Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1
Queue/DropTail/PriQueue set size_ 1000
# Sendmode for wireless nodes
set wlBasicRate Mode6Mb
set wlDataRate Mode6Mb
set apBasicRate Mode6Mb
set apDataRate Mode36Mb

# IP
Module/IP set debug_ 0
Module/IP set debug_ 0
Module/IP/Routing set debug_ 0

# AODV-UU
Module/AODVUU set llfeedback_ 1
Module/AODVUU set debug_ 0

# Tracer
ConnectorTrace/ChSAP set debug_ 0
ConnectorTrace/Bin set debug_ 0
ConnectorTrace/Bin set depth 5

######################## Finish routine ########################
proc finish {} {
	global ns tf tracefname
	puts "---> SIMULATION DONE."
	$ns flush-trace
	close $tf
	puts "Tracefile: $tracefname"
}

proc createWirelessNode {n ip netmask net defaultGw channel posX posY} {
	puts "Creating wireless node (n=$n)"
	global ns per pmodel wlBasicRate wlDataRate wlNodes wlPongs wlAodvs wlIpIfs wlMacs wlPhys wlPPs wlPositions

	set wlNodes($n)		[$ns create-M_Node]
	set wlPongs($n)		[new Module/Pong]
	set wlAodvs($n)		[new Module/AODVUU]
	set wlIpIfs($n)		[new Module/IP/AODVInterface]

	$wlIpIfs($n)		addr $ip
	$wlIpIfs($n)		subnet $netmask

	set wlMacs($n)		[create802_11MacModule "LL/Mrcl" "Queue/DropTail/PriQueue" "Mac/802_11/Multirate" [$wlIpIfs($n) addr] "" 100 ]
    set wlPhys($n)		[createPhyModule "Phy/WirelessPhy/PowerAware" $pmodel "Antenna/OmniAntenna" $wlMacs($n)  ""]

	set mac				[$wlMacs($n)  getMac]
	set phy				[$wlPhys($n)  getPhy]
	$mac				basicMode_ $wlBasicRate
	$mac				dataMode_ $wlDataRate
	$mac				per $per
	set wlPPs($n)		[new PowerProfile]
	$mac				powerProfile $wlPPs($n)
	$phy				powerProfile $wlPPs($n)
	$phy				set freq_ [$channel set freq_]

	$wlNodes($n) addModule 5 $wlPongs($n) 0 "wlPNG${n} "
	$wlNodes($n) addModule 4 $wlAodvs($n) 0 "wlAODV${n}"
	$wlNodes($n) addModule 3 $wlIpIfs($n) 0 "wlIP${n}  "
	$wlNodes($n) addModule 2 $wlMacs($n)  0 "wlMAC${n} "
	$wlNodes($n) addModule 1 $wlPhys($n)  0 "wlPHY${n} "

	$wlNodes($n) setConnection $wlPongs($n) $wlAodvs($n)  1
	$wlNodes($n) setConnection $wlAodvs($n)  $wlIpIfs($n) 1
	$wlNodes($n) setConnection $wlIpIfs($n) $wlMacs($n)   1
	$wlNodes($n) setConnection $wlMacs($n)  $wlPhys($n)   1

	$wlNodes($n) addToChannel $channel $wlPhys($n)       1

	$wlAodvs($n) add-if $wlIpIfs($n)
	$wlAodvs($n) if-queue [$wlMacs($n) getQueue]

	# Set position
	set wlPositions($n) [new "Position/BM"]
    $wlNodes($n) addPosition $wlPositions($n)

    $wlPositions($n) setX_ $posX
    $wlPositions($n) setY_ $posY
}

proc createAccessPoint {n apIp apNetmask apChannel bbIp bbNetmask bbChannel posX posY} {
	puts "Creating wireless access point (n=$n)"

	global ns per pmodel wlBasicRate wlDataRate apBasicMode apDataMode apNodes apAodvs apIpIfs apMacs apPhys apPPs apPositions apIpIfCounter

	set apNodes($n)		[$ns create-M_Node]
	set apAodvs($n)		[new Module/AODVUU]
	$apNodes($n)		addModule 4 $apAodvs($n)  0 "apAODV${n}"

	# Interface 0 (Access net)
	set apIpIfs($n,0)	[new Module/IP/AODVInterface]

	$apIpIfs($n,0)		addr $apIp
	$apIpIfs($n,0)		subnet $apNetmask

	set apMacs($n,0)	[create802_11MacModule "LL/Mrcl" "Queue/DropTail/PriQueue" "Mac/802_11/Multirate" [$apIpIfs($n,0) addr] "" 100 ]
    set apPhys($n,0)	[createPhyModule "Phy/WirelessPhy/PowerAware" $pmodel "Antenna/OmniAntenna" $apMacs($n,0)  ""]

	set mac				[$apMacs($n,0)  getMac]
	set phy				[$apPhys($n,0)  getPhy]
	$mac				basicMode_ $wlBasicRate
	$mac				dataMode_ $wlDataRate
	$mac				per $per
	set apPPs($n,0)		[new PowerProfile]
	$mac				powerProfile $apPPs($n,0)
	$phy				powerProfile $apPPs($n,0)
	$phy				set freq_ [$apChannel set freq_]

	$apNodes($n) addModule 3 $apIpIfs($n,0) 0 "apIP${n}0 "
	$apNodes($n) addModule 2 $apMacs($n,0)  0 "apMAC${n}0"
	$apNodes($n) addModule 1 $apPhys($n,0)  0 "apPHY${n}0"

	$apNodes($n) setConnection $apAodvs($n)   $apIpIfs($n,0) 1
	$apNodes($n) setConnection $apIpIfs($n,0) $apMacs($n,0)  1
	$apNodes($n) setConnection $apMacs($n,0)  $apPhys($n,0)  1

	$apNodes($n) addToChannel $apChannel $apPhys($n,0)       1

	$apAodvs($n) add-if $apIpIfs($n,0)
	$apAodvs($n) if-queue [$apMacs($n,0) getQueue]

	# Interface 1 (Backbone net)
	set apIpIfs($n,1)	[new Module/IP/AODVInterface]

	$apIpIfs($n,1)		addr $bbIp
	$apIpIfs($n,1)		subnet $bbNetmask

	set apMacs($n,1)	[create802_11MacModule "LL/Mrcl" "Queue/DropTail/PriQueue" "Mac/802_11/Multirate" [$apIpIfs($n,1) addr] "" 100 ]
    set apPhys($n,1)	[createPhyModule "Phy/WirelessPhy/PowerAware" $pmodel "Antenna/OmniAntenna" $apMacs($n,1)  ""]

	set mac				[$apMacs($n,1)  getMac]
	set phy				[$apPhys($n,1)  getPhy]
	$mac				basicMode_ $wlBasicRate
	$mac				dataMode_ $wlDataRate
	$mac				per $per
	set apPPs($n,1)		[new PowerProfile]
	$mac				powerProfile $apPPs($n,1)
	$phy				powerProfile $apPPs($n,1)
	$phy				set freq_ [$bbChannel set freq_]

	$apNodes($n) addModule 3 $apIpIfs($n,1) 0 "apIP${n}1 "
	$apNodes($n) addModule 2 $apMacs($n,1)  0 "apMAC${n}1"
	$apNodes($n) addModule 1 $apPhys($n,1)  0 "apPHY${n}1"

	$apNodes($n) setConnection $apAodvs($n)   $apIpIfs($n,1) 1
	$apNodes($n) setConnection $apIpIfs($n,1) $apMacs($n,1)  1
	$apNodes($n) setConnection $apMacs($n,1)  $apPhys($n,1)  1

	$apNodes($n) addToChannel $bbChannel $apPhys($n,1)       1

	$apAodvs($n) add-if $apIpIfs($n,1)
	$apAodvs($n) if-queue [$apMacs($n,1) getQueue]

	# Set position
	set apPositions($n) [new "Position/BM"]
    $apNodes($n) addPosition $apPositions($n)

    $apPositions($n) setX_ $posX
    $apPositions($n) setY_ $posY

	# Set ipif counter
	set apIpIfCounter($n) 2
}

proc addGwInterface {apNodeIndex ip netmask defaultGw} {
	puts "Adding gateway interface on AP node ${apNodeIndex}"
	global apNodes apAodvs apIpIfs apIpIfCounter
	set apIpIfs($apNodeIndex,$apIpIfCounter($apNodeIndex))		[new Module/IP/AODVInterface]

	set ipif $apIpIfs($apNodeIndex,$apIpIfCounter($apNodeIndex))

	$ipif	addr $ip
	$ipif	subnet $netmask

	# Add modules
	$apNodes($apNodeIndex)	addModule 3 $ipif     3 "apGWIP${apNodeIndex}"

	#Connect modules
	$apNodes($apNodeIndex)	setConnection $apAodvs($apNodeIndex) $ipif 1

	$apAodvs($apNodeIndex) add-gwif $ipif
	$apAodvs($apNodeIndex) set internet_gw_mode_ 1
	$apAodvs($apNodeIndex) set-default-gw $defaultGw

	set apIpfCounter($apNodeIndex) [expr $apIpIfCounter($apNodeIndex) + 1]
}

proc createWiredNode {n ip netmask defaultGw} {
	puts "Creating wired node (n=$n)"
	global ns wrdNodes wrdPongs wrdIpRts wrdIpIfs

	set wrdNodes($n)		[$ns create-M_Node]
	set wrdPongs($n)		[new Module/Pong]
	set wrdIpRts($n)		[new Module/IP/Routing]
	set wrdIpIfs($n)		[new Module/IP/Interface]

	$wrdIpIfs($n)		addr $ip
	$wrdIpIfs($n)		subnet $netmask

	$wrdIpRts($n)		defaultGateway $defaultGw

	$wrdNodes($n) addModule 3 $wrdPongs($n)  0 "wrdPNG${n}"
	$wrdNodes($n) addModule 2 $wrdIpRts($n)  0 "wrdIPR${n}"
	$wrdNodes($n) addModule 1 $wrdIpIfs($n)  0 "wrdIP${n} "

	$wrdNodes($n) setConnection $wrdPongs($n) $wrdIpRts($n)  1
	$wrdNodes($n) setConnection $wrdIpRts($n) $wrdIpIfs($n)  1
}

##################### Initialize simulator #####################
set ns [new Simulator]
$ns use-Miracle

set tf [open $tracefname w]
$ns trace-all $tf

# Create GOD
create-god $NUMWD

# Set Packet Error Rate
set per [new PER]
$per loadDefaultPERTable
$per set noise_ 7e-11

# Set p-model
set pmodel [new Propagation/MrclFreeSpace]

# Create channels
set channel_bb [new Module/DumbWirelessCh]
$channel_bb settag "CH_BB  "
$channel_bb set freq_ 5280e6
set channel_1 [new Module/DumbWirelessCh]
$channel_1 settag "CH_01  "
$channel_1 set freq_ 2412e6
set channel_6 [new Module/DumbWirelessCh]
$channel_6 settag "CH_06  "
$channel_6 set freq_ 2437e6
set channel_11 [new Module/DumbWirelessCh]
$channel_11 settag "CH_11  "
$channel_11 set freq_ 2462e6
# Create wired channel
set wired_link [new Module/DuplexLink]
$wired_link bandwidth 1000000
$wired_link delay 0.0001
$wired_link qsize 50
$wired_link settags "WIREDCH"

# Create Aps
createAccessPoint 0 10.0.1.1 255.255.0.0 $channel_1 10.0.0.2 255.255.0.0 $channel_bb 0 40
createAccessPoint 1 10.0.11.1 255.255.0.0 $channel_11 10.0.0.3 255.255.0.0 $channel_bb 300 40
createAccessPoint 2 10.0.6.1 255.255.0.0 $channel_6 10.0.0.1 255.255.0.0 $channel_bb 600 40
addGwInterface 2 192.168.0.1 255.255.0.0 0

# Create Wireless nodes
createWirelessNode 0 10.0.1.2 255.255.0.0 10.0.1.0 10.0.1.1 $channel_1 0 0
createWirelessNode 1 10.0.1.3 255.255.0.0 10.0.1.0 10.0.1.1 $channel_1 20 0
createWirelessNode 2 10.0.11.2 255.255.0.0 10.0.11.0 10.0.11.1 $channel_11 300 0
createWirelessNode 3 10.0.6.2 255.255.0.0 10.0.6.0 10.0.6.1 $channel_6 600 0

# Create sink node on wired interface
createWiredNode 0 192.168.0.3 255.255.255.0 192.168.0.1
$wired_link connect $apNodes(2) $apIpIfs(2,2) 1 $wrdNodes(0) $wrdIpIfs(0) 1

puts "---> BEGIN SIMULATION"

$ns at 0 "$wrdIpRts(0) printroutes"
$ns at 0 "$apAodvs(0) start"
$ns at 0 "$apAodvs(1) start"
$ns at 0 "$apAodvs(2) start"
$ns at 0 "$wlAodvs(0) start"
$ns at 0 "$wlAodvs(1) start"
$ns at 0 "$wlAodvs(2) start"
$ns at 0 "$wlAodvs(3) start"
$ns at 5 "$wlPongs(2) send [$wlIpIfs(3) addr]"
#$ns at 5 "$wlPongs(0) send [$wlIpIfs(1) addr]"
#$ns at 10 "$wlPongs(3) send [$wlIpIfs(0) addr]"
#$ns at 12 "$wlPongs(3) send [$wlIpIfs(1) addr]"
#$ns at 15 "$wlPongs(1) send [$wrdIpIfs(0) addr]"
#$ns at 20 "$wrdPongs(0) send [$wlIpIfs(0) addr]"
$ns at $STOP "finish; $ns halt"
$ns run