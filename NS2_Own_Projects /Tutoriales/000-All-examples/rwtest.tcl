# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>

#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
#set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     161                          ;# number of mobilenodes 20 40 60 80 100 
set val(rp)     rewarn                     ;# routing protocol
set val(x)      1000                        ;# X dimension of topography
set val(y)      1000                        ;# Y dimension of topography
set val(stop)   60.0                       ;# time of simulation end

#other default setting
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.0
Antenna/OmniAntenna set Gt_ 10.0
Antenna/OmniAntenna set Gr_ 1.0

## Initialize the SharedMedia interface with parameters to make
## it work like the 914MHz Lucent WaveLAN DSSS radio interface
#Phy/WirelessPhy set CPThresh_ 10.0
#Phy/WirelessPhy set CSThresh_ 1.559e-12
## below is original
##Phy/WirelessPhy set RXThresh_ 3.652e-10
## 95% pkts can be correctly received at 20m for 3/5.
#Phy/WirelessPhy set RXThresh_ 3.1705e-11
#Phy/WirelessPhy set bandwidth_ 2e6
#Phy/WirelessPhy set Pt_ 0.2818
#Phy/WirelessPhy set freq_ 914e+6 
#Phy/WirelessPhy set L_ 1.0

# Pt_ is transmitted signal power. The propagation model and Pt_ determines
# the received signal power of each packet. The packet can not be correctly
# received if received power is below RXThresh_.


#Phy/WirelessPhyExt set CSThresh_                3.162e-12   ;#-85 dBm Wireless interface sensitivity (sensitivity defined in the standard)
#Phy/WirelessPhyExt set Pt_                      0.001         
#Phy/WirelessPhyExt set freq_                    5.9e+9
#Phy/WirelessPhyExt set noise_floor_             1.26e-13    ;#-99 dBm for 10MHz bandwidth
#Phy/WirelessPhyExt set L_                       1.0         ;#default radio circuit gain/loss
#Phy/WirelessPhyExt set PowerMonitorThresh_      6.310e-14   ;#-102dBm power monitor  sensitivity
#Phy/WirelessPhyExt set HeaderDuration_          0.000040    ;#40 us
#Phy/WirelessPhyExt set BasicModulationScheme_   0
#Phy/WirelessPhyExt set PreambleCaptureSwitch_   1
#Phy/WirelessPhyExt set DataCaptureSwitch_       0
#Phy/WirelessPhyExt set SINR_PreambleCapture_    2.5118;     ;# 4 dB
#Phy/WirelessPhyExt set SINR_DataCapture_        100.0;      ;# 10 dB
#Phy/WirelessPhyExt set trace_dist_              1e6         ;# PHY trace until distance of 1 Mio. km ("infinty")
#Phy/WirelessPhyExt set PHY_DBG_                 0
#
#Mac/802_11Ext set CWMin_                        15
#Mac/802_11Ext set CWMax_                        1023
#Mac/802_11Ext set SlotTime_                     0.000013
#Mac/802_11Ext set SIFS_                         0.000032
#Mac/802_11Ext set ShortRetryLimit_              7
#Mac/802_11Ext set LongRetryLimit_               4
#Mac/802_11Ext set HeaderDuration_               0.000040
#Mac/802_11Ext set SymbolDuration_               0.000008
#Mac/802_11Ext set BasicModulationScheme_        0
#Mac/802_11Ext set use_802_11a_flag_             true
#Mac/802_11Ext set RTSThreshold_                 2346
#Mac/802_11Ext set MAC_DBG                       0
#
#


Mac/802_11 set SlotTime_          0.000050        ;# 50us
Mac/802_11 set SIFS_              0.000028        ;# 28us
Mac/802_11 set PreambleLength_    0               ;# no preamble
Mac/802_11 set PLCPHeaderLength_  128             ;# 128 bits
Mac/802_11 set PLCPDataRate_      1.0e6           ;# 1Mbps
Mac/802_11 set dataRate_          1.0e6           ;# 11Mbps
Mac/802_11 set basicRate_         1.0e6           ;# 1Mbps





# ======================================================================
# Main Program
# ======================================================================

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]


#define propagation models
# pathlossExp_ is path-loss exponent, for predicting mean received power
# std_db_ is shadowing deviation (dB), reflecting how large the propagation
# property changes within the environment.
# dist0_ is a close-in reference distance
#
set goodProp	[new Propagation/Shadowing]
$goodProp set pathlossExp_ 2
$goodProp set std_db_ 1.0
$goodProp set dist0_ 1000.0
$goodProp seed predef 0

set badProp	[new Propagation/Shadowing]
$badProp set pathlossExp_ 4.0
$badProp set std_db_ 5.0
$badProp set dist0_ 1
$badProp seed predef 0




#visibility-based shadowing model: line of sight or not using a bitmap
set prop [new Propagation/ShadowingVis]
$prop get-bitmap streetbig.pnm
# set number of pixels per meter
$prop set-ppm 1
# add previously defined models
$prop add-models $goodProp $badProp

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open fix_relay$val(nn).tr w]
$ns trace-all $tracefile

#Open the NAM trace file
#set namfile [open always_relay.nam w]
#$ns namtrace-all $namfile
#$ns namtrace-all-wireless $namfile $val(x) $val(y)

set chan [new $val(chan)] ;#Create wireless channel


#===================================
#     Mobile node parameter setup
#===================================
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propInstance  $prop \
                -phyType       $val(netif) \
                -channel       [new $val(chan)] \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      OFF \
                -movementTrace OFF
		

#===================================
#        Nodes Definition        
#===================================
#Create 5 nodes
#set n0 [$ns node]
#$n0 set X_ 499
#$n0 set Y_ 500
#$n0 set Z_ 0.0
#$ns initial_node_pos $n0 20
#set n1 [$ns node]
#$n1 set X_ 499
#$n1 set Y_ 400
#$n1 set Z_ 0.0
#$ns initial_node_pos $n1 20
#set n2 [$ns node]
#$n2 set X_ 499
#$n2 set Y_ 300
#$n2 set Z_ 0.0
#$ns initial_node_pos $n2 20
#set n3 [$ns node]
#$n3 set X_ 400
#$n3 set Y_ 500
#$n3 set Z_ 0.0
#$ns initial_node_pos $n3 20
#set n4 [$ns node]
#$n4 set X_ 300
#$n4 set Y_ 500
#$n4 set Z_ 0.0
#$ns initial_node_pos $n4 20

set n0 [$ns node]
$n0 set X_ 500
$n0 set Y_ 500
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20	

set space [expr 200 / ($val(nn)-1)]
	
for {set i 1} {$i <  [expr ($val(nn)+1)/2] } { incr i } {
	set n($i) [$ns node]
	$n($i) set X_ 505
	$n($i) set Y_ [expr 500-$i*$space]
	$n($i) set Z_ 0.0
	$ns initial_node_pos $n($i) 20	
}

for {set i [expr ($val(nn)+1)/2]} {$i < $val(nn) } { incr i } {
	set n($i) [$ns node]
	$n($i) set X_ [expr 500-($i-($val(nn)-1)/2)*$space]
	$n($i) set Y_ 495
	$n($i) set Z_ 0.0
	$ns initial_node_pos $n($i) 20	
}		
		
		
		
		
		
		
#===================================
#        Agents Definition        
#===================================

#===================================
#        Applications Definition        
#===================================

#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
#$ns at $val(stop) "$ns nam-end-wireless $val(stop)"

$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done!!!\""
proc finish {} {
    global ns tracefile ;#namfile
    puts "running ns..."

    $ns flush-trace
    close $tracefile
#    close $namfile
#    exec nam always_relay.nam &
    puts "Simulation is successful finished!!!!"
    exit 0
}

for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}

$ns run
