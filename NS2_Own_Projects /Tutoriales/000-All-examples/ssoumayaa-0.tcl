# http://www.linuxquestions.org/questions/linux-networking-3/using-gpsr-vanet-simulation-4175440313/#1
# -------------------------------------------- #


# ======================================================================
# Define options
# ======================================================================
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhyExt ;# network interface type
set val(mac) Mac/802_11Ext ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 4 ;# number of mobilenodes
set val(rp) GPSR ;# routing protocol
set val(cp) "./changjing1.tcl"

# ======================================================================
#802.11p parameters
# ======================================================================

Phy/WirelessPhyExt set CSThresh_ 3.9810717055349694e-13	;# -94 dBm wireless interface sensitivity
Phy/WirelessPhyExt set Pt_ 0.1	 ;# equals 20dBm when considering antenna gains of 1.0
Phy/WirelessPhyExt set freq_ 5.9e+9
Phy/WirelessPhyExt set noise_floor_ 1.26e-13 ;# -99 dBm for 10MHz bandwidth
Phy/WirelessPhyExt set L_ 1.0 ;# default radio circuit gain/loss
Phy/WirelessPhyExt set PowerMonitorThresh_ 3.981071705534985e-18 ;# -174 dBm power monitor sensitivity (=level of gaussian noise)
Phy/WirelessPhyExt set HeaderDuration_ 0.000040 ;# 40 us
Phy/WirelessPhyExt set BasicModulationScheme_ 0
Phy/WirelessPhyExt set PreambleCaptureSwitch_ 1
Phy/WirelessPhyExt set DataCaptureSwitch_ 1
Phy/WirelessPhyExt set SINR_PreambleCapture_ 3.1623; ;# 5 dB
Phy/WirelessPhyExt set SINR_DataCapture_ 10.0; ;# 10 dB
Phy/WirelessPhyExt set trace_dist_ 1e6 ;# PHY trace until distance of 1 Mio. km ("infinity")
Phy/WirelessPhyExt set PHY_DBG_ 0

Mac/802_11Ext set CWMin_ 15
Mac/802_11Ext set CWMax_ 1023
Mac/802_11Ext set SlotTime_ 0.000013
Mac/802_11Ext set SIFS_ 0.000032
Mac/802_11Ext set ShortRetryLimit_ 7
Mac/802_11Ext set LongRetryLimit_ 4
Mac/802_11Ext set HeaderDuration_ 0.000040
Mac/802_11Ext set SymbolDuration_ 0.000008
Mac/802_11Ext set BasicModulationScheme_ 0
Mac/802_11Ext set use_802_11a_flag_ true
Mac/802_11Ext set RTSThreshold_ 2346
Mac/802_11Ext set MAC_DBG 0


# ======================================================================
#configure RF model parameters
# ======================================================================
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0
Propagation/Nakagami set use_nakagami_dist_ false
Propagation/Nakagami set gamma0_ 2.0
Propagation/Nakagami set gamma1_ 2.0
Propagation/Nakagami set gamma2_ 2.0
Propagation/Nakagami set d0_gamma_ 200
Propagation/Nakagami set d1_gamma_ 500
Propagation/Nakagami set m0_ 1.0
Propagation/Nakagami set m1_ 1.0
Propagation/Nakagami set m2_ 1.0
Propagation/Nakagami set d0_m_ 80
Propagation/Nakagami set d1_m_ 200


#======================================================================
# Main Program
#======================================================================
#======================================================================
#Initialization
#======================================================================


set ns_	 [new Simulator]	 ;#Create a ns simulator
set tracefd	[open fangzhen1.tr w]	;# setting up output files
set nf [open fangzhen1.nam w]	;# trace and nam file
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $nf 2000 500 ;# mobily topo x&y
set topo [new Topography]	 ;# set up topography object
$topo load_flatgrid 1600 1600 ;#set mobile sensior
set chan [new $val(chan)]

#======================================================================
# Create God
#======================================================================
set god_ [create-god $val(nn)]

#======================================================================
# Create the specified number of mobilenodes [$val(nn)] and "attach" them
# to the channel. 
#======================================================================

#======================================================================
# configure node
#======================================================================
$ns_ node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channel $chan \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace ON \
-movementTrace ON
#======================================================================
#nodes Definition
#======================================================================
# Creating node objects	
#======================================================================

for {set i 0} {$i < $val(nn) } {incr i} {
set ID_($i) $i
set node_($i) [$ns_ node]
$node_($i) set id_ $ID_($i)
$node_($i) set address_ $ID_($i)
$node_($i) nodeid $ID_($i)
$node_($i) random-motion 0; # disable random motion
}

#======================================================================
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#======================================================================
# set mobility file
#======================================================================
source $val(cp)

#======================================================================
# Setup traffic flow between nodes
#======================================================================

#======================================================================
#Setup UDP connection
#======================================================================
set udp_s [new Agent/UDP]
set udp_r [new Agent/Null]
$ns_ attach-agent $node_(1) $udp_s
$ns_ attach-agent $node_(3) $udp_r


#======================================================================
#Setup a MM Application
#======================================================================
set e [new Application/Traffic/CBR]
$e set packetSize_ 500
$e set rate_ 20Kb
$e set random_ 1
#$e attach-agent $udp_r
$e attach-agent $udp_s
$ns_ connect $udp_s $udp_r

#======================================================================
#Simulation Scenario
#======================================================================
$ns_ at 1.0 "$e start"
#======================================================================
#Tell nodes when the simulation ends
#======================================================================
for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at 80.0 "$node_($i) reset";
}
$ns_ at 80.000 "stop"
$ns_ at 80.010 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
global ns_ tracefd
global ns_ nf
$ns_ flush-trace
close $nf
close $tracefd
exit 0
}

puts "Starting Simulation..."
$ns_ run
