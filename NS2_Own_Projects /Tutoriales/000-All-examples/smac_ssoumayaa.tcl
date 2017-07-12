# http://www.linuxquestions.org/questions/linux-networking-3/using-gpsr-vanet-simulation-4175440313/#13
# ------------------------------------------------------ #

## GPSR Options
Agent/GPSR set bdesync_                0.5 ;# beacon desync random component
Agent/GPSR set bexp_                   [expr 3*([Agent/GPSR set bint_]+[Agent/GPSR set bdesync_]*[Agent/GPSR set bint_])] ;# beacon timeout interval
Agent/GPSR set pint_                   1.5 ;# peri probe interval
Agent/GPSR set pdesync_                0.5 ;# peri probe desync random component
Agent/GPSR set lpexp_                  8.0 ;# peris unused timeout interval
Agent/GPSR set drop_debug_             1   ;#
Agent/GPSR set peri_proact_            1 	 ;# proactively generate peri probes
Agent/GPSR set use_implicit_beacon_    1   ;# all packets act as beacons; promisc.
Agent/GPSR set use_timed_plnrz_        0   ;# replanarize periodically
Agent/GPSR set use_congestion_control_ 0
Agent/GPSR set use_reactive_beacon_    0   ;# only use reactive beaconing

set val(bint)           0.5  ;# beacon interval
set val(use_mac)        1    ;# use link breakage feedback from MAC
set val(use_peri)       1    ;# probe and use perimeters
set val(use_planar)     1    ;# planarize graph
set val(verbose)        1    ;#
set val(use_beacon)     1    ;# use beacons at all
set val(use_reactive)   0    ;# use reactive beaconing
set val(locs)           0    ;# default to OmniLS
set val(use_loop)       0    ;# look for unexpected loops in peris

set val(agg_mac)          1 ;# Aggregate MAC Traces
set val(agg_rtr)          0 ;# Aggregate RTR Traces
set val(agg_trc)          0 ;# Shorten Trace File


# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)		Mac/SMAC
# set val(mac)            Mac/802_11              ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         512                         ;# max packet in ifq
set val(seed)		1.0
set val(rp)             GPSR                       ;# routing protocol
set val(nn)             2                          ;# number of mobilenodes
set val(cp) 		"./changjing1.tcl"
set val(stop)		40.0     ;# simulation time
set val(use_gk)		0	  ;# > 0: use GridKeeper with this radius
set val(zip)		0         ;# should trace files be zipped

# Mac/SMAC set syncFlag_ 1
# Mac/SMAC set dutyCycle_ 10

Agent/GPSR set locservice_type_ 3

add-all-packet-headers
remove-all-packet-headers
add-packet-header Common Flags IP LL Mac Message GPSR  LOCS SR RTP Ping HLS

Agent/GPSR set bint_                  $val(bint)
# Recalculating bexp_ here
Agent/GPSR set bexp_                 [expr 3*([Agent/GPSR set bint_]+[Agent/GPSR set bdesync_]*[Agent/GPSR set bint_])] ;# beacon timeout interval
Agent/GPSR set use_peri_              $val(use_peri)
Agent/GPSR set use_planar_            $val(use_planar)
Agent/GPSR set use_mac_               $val(use_mac)

Agent/GPSR set verbose_               $val(verbose)
Agent/GPSR set use_reactive_beacon_   $val(use_reactive)
Agent/GPSR set use_loop_detect_       $val(use_loop)

CMUTrace set aggregate_mac_           $val(agg_mac)
CMUTrace set aggregate_rtr_           $val(agg_rtr)

# seeding RNG
ns-random $val(seed)

# ======================================================================
# - Define PHY --> According Orinoco cards and Antenna
Mac/802_11 set CWMin_            15                              ;#
Mac/802_11 set CWMax_            1023                            ;#
Mac/802_11 set SlotTime_         0.000013                        ;#
Mac/802_11 set SIFS_             0.000032                        ;#
Mac/802_11 set ShortRetryLimit_  7                               ;#
Mac/802_11 set LongRetryLimit_   4                               ;#
Mac/802_11 set HeaderDuration_   0.000040                        ;#
Mac/802_11 set SymbolDuration_   0.000008                        ;#
Mac/802_11 set BasicModulationScheme_ 0                          ;#
Mac/802_11 set use_802_11a_flag_ true                            ;#
Mac/802_11 set RTSThreshold_     2346                            ;#
Mac/802_11 set MAC_DBG           0                               ;#


Phy/WirelessPhy set CSThresh_           3.162e-12   ;#-85 dBm Wireless interface sensitivity (sensitivity defined in the standard)
Phy/WirelessPhy set Pt_                 0.001
Phy/WirelessPhy set freq_               5.9e+9
Phy/WirelessPhy set noise_floor_        1.26e-13    ;#-99 dBm for 10MHz bandwidth
Phy/WirelessPhy set L_                  1.0         ;#default radio circuit gain/loss
Phy/WirelessPhy set PowerMonitorThresh_ 6.310e-14   ;#-102dBm power monitor  sensitivity
Phy/WirelessPhy set HeaderDuration_     0.000040    ;#40 us
Phy/WirelessPhy set BasicModulationScheme_ 0        
Phy/WirelessPhy set PreambleCaptureSwitch_ 1
Phy/WirelessPhy set DataCaptureSwitch_     0
Phy/WirelessPhy set SINR_PreambleCapture_ 2.5118    ;# 4 dB
Phy/WirelessPhy set SINR_DataCapture_   100.0       ;# 10 dB
Phy/WirelessPhy set trace_dist_         1e6         ;# PHY trace until distance of 1 Mio. km ("infinty")
Phy/WirelessPhy set PHY_DBG_            0           ;#
Phy/WirelessPhy set CPThresh_           0 ;# not used at the moment
Phy/WirelessPhy set RXThresh_           0 ;# not used at the moment


# ======================================================================
# Main Program
# ======================================================================


#
# Initialize Global Variables
#
set ns_		[new Simulator]

set tracefd	[open fangzhen1.tr w]		;# setting up output files
set nf 		[open fangzhen1.nam w]		;# trace and nam file
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $nf 2000 500 ;# mobily topo x&y
#$ns_ use-newtrace

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 2000 500 ;#set mobile sensior
#Create PHY
set chan [new $val(chan)]
#
# Create God
#
set god_ [create-god $val(nn)]

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 
#  Here two nodes are created : node(0) and node(1)

# configure node

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
			 -macTrace OFF \
			 -movementTrace OFF
	
			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
	}
$node_(0) color red
$node_(1) color yellow
#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#



# set mobility file
 source $val(cp)

# Node_(1) then starts to move away from node_(0)

# Setup traffic flow between nodes

#Setup UDP connection
set udp_s [new Agent/UDP]
set udp_r [new Agent/Null]
$ns_ attach-agent $node_(0) $udp_s
$ns_ attach-agent $node_(1) $udp_r


#Setup a MM Application
set e [new Application/Traffic/CBR]
$e set packetSize_ 500
$e set rate_  20Kb
$e set random_ 1
#$e attach-agent $udp_r
$e attach-agent $udp_s
$ns_ connect $udp_s $udp_r


#Simulation Scenario
$ns_ at 1.0 "$e start"


#
# Tell nodes when the simulation ends
#
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
