#   http://www.linuxquestions.org/questions/linux-software-2/xgraph-problm-urgent-please-4175506024/#3

## GPSR Options
Agent/GPSR set bdesync_ 0.5 ;# beacon desync random component
Agent/GPSR set bexp_ [expr 3*([Agent/GPSR set bint_]+[Agent/GPSR set bdesync_]*[Agent/GPSR set bint_])] ;# beacon timeout interval
Agent/GPSR set pint_ 1.5 ;# peri probe interval
Agent/GPSR set pdesync_ 0.5 ;# peri probe desync random component
Agent/GPSR set lpexp_ 8.0 ;# peris unused timeout interval
Agent/GPSR set drop_debug_ 1 ;#
Agent/GPSR set peri_proact_ 1 ;# proactively generate peri probes
Agent/GPSR set use_implicit_beacon_ 1 ;# all packets act as beacons; promisc.
Agent/GPSR set use_timed_plnrz_ 0 ;# replanarize periodically
Agent/GPSR set use_congestion_control_ 0
Agent/GPSR set use_reactive_beacon_ 0 ;# only use reactive beaconing

set val(bint) 0.5 ;# beacon interval
set val(use_mac) 1 ;# use link breakage feedback from MAC
set val(use_peri) 1 ;# probe and use perimeters
set val(use_planar) 1 ;# planarize graph
set val(verbose) 1 ;#
set val(use_beacon) 1 ;# use beacons at all
set val(use_reactive) 0 ;# use reactive beaconing
set val(locs) 0 ;# default to OmniLS
set val(use_loop) 0 ;# look for unexpected loops in peris

set val(agg_mac) 1 ;# Aggregate MAC Traces
set val(agg_rtr) 0 ;# Aggregate RTR Traces
set val(agg_trc) 0 ;# Shorten Trace File


# ======================================================================
# Define options
# ======================================================================
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 512 ;# max packet in ifq
set val(seed) 1.0
set val(rp) GPSR ;# routing protocol
set val(nn) 2 ;# number of mobilenodes
set val(cp) "./changjing1.tcl"
set val(stop) 40.0 ;# simulation time
set val(use_gk) 0 ;# > 0: use GridKeeper with this radius
set val(zip) 0 ;# should trace files be zipped


Agent/GPSR set locservice_type_ 3

add-all-packet-headers
remove-all-packet-headers
add-packet-header Common Flags IP LL Mac Message GPSR LOCS SR RTP Ping HLS

Agent/GPSR set bint_ $val(bint)
# Recalculating bexp_ here
Agent/GPSR set bexp_ [expr 3*([Agent/GPSR set bint_]+[Agent/GPSR set bdesync_]*[Agent/GPSR set bint_])] ;# beacon timeout interval
Agent/GPSR set use_peri_ $val(use_peri)
Agent/GPSR set use_planar_ $val(use_planar)
Agent/GPSR set use_mac_ $val(use_mac)

Agent/GPSR set verbose_ $val(verbose)
Agent/GPSR set use_reactive_beacon_ $val(use_reactive)
Agent/GPSR set use_loop_detect_ $val(use_loop)

CMUTrace set aggregate_mac_ $val(agg_mac)
CMUTrace set aggregate_rtr_ $val(agg_rtr)

# seeding RNG
ns-random $val(seed)

# ======================================================================
# - Define PHY --> According Orinoco cards and Antenna
Mac/802_11 set CWMin_ 15 ;#
Mac/802_11 set CWMax_ 1023 ;#
Mac/802_11 set SlotTime_ 0.000013 ;#
Mac/802_11 set SIFS_ 0.000032 ;#
Mac/802_11 set ShortRetryLimit_ 7 ;#
Mac/802_11 set LongRetryLimit_ 4 ;#
Mac/802_11 set HeaderDuration_ 0.000040 ;#
Mac/802_11 set SymbolDuration_ 0.000008 ;#
Mac/802_11 set BasicModulationScheme_ 0 ;#
Mac/802_11 set use_802_11a_flag_ true ;#
Mac/802_11 set RTSThreshold_ 2346 ;#
Mac/802_11 set MAC_DBG 0 ;#


Phy/WirelessPhy set CSThresh_ 3.162e-12 ;#-85 dBm Wireless interface sensitivity (sensitivity defined in the standard)
Phy/WirelessPhy set Pt_ 61.001
Phy/WirelessPhy set freq_ 5.9e+9
Phy/WirelessPhy set noise_floor_ 1.26e-13 ;#-99 dBm for 10MHz bandwidth
Phy/WirelessPhy set L_ 1.0 ;#default radio circuit gain/loss
Phy/WirelessPhy set PowerMonitorThresh_ 6.310e-14 ;#-102dBm power monitor sensitivity
Phy/WirelessPhy set HeaderDuration_ 0.000040 ;#40 us
Phy/WirelessPhy set BasicModulationScheme_ 0
Phy/WirelessPhy set PreambleCaptureSwitch_ 1
Phy/WirelessPhy set DataCaptureSwitch_ 0
Phy/WirelessPhy set SINR_PreambleCapture_ 2.5118 ;# 4 dB
Phy/WirelessPhy set SINR_DataCapture_ 100.0 ;# 10 dB
Phy/WirelessPhy set trace_dist_ 1e6 ;# PHY trace until distance of 1 Mio. km ("infinty")
Phy/WirelessPhy set PHY_DBG_ 0 ;#
Phy/WirelessPhy set CPThresh_ 0 ;# not used at the moment
Phy/WirelessPhy set RXThresh_ 10.0 ;# not used at the moment






set RxT_ 3.652e-10 ;#Receiving Threshold which mostly is a hardware feature
set Frequency_ 914e+6 ;# Signal Frequency which is also hardware feature

Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ $RxT_ ;# Receiving Threshold
Phy/WirelessPhy set Rb_ 2*1e6 ;# Bandwidth
Phy/WirelessPhy set freq_ $Frequency_
Phy/WirelessPhy set L_ 1.0

set opt(Pt) 61.0 ;# Transmission Power/Range in meters

if { $val(prop) == "Propagation/TwoRayGround" } {
set SL_ 300000000.0 ;# Speed of Light
set lambda [expr $SL_/$Frequency_] ;# wavelength
set lambda_2 [expr $lambda*$lambda] ;# lambda^2
set CoD_ [expr 4.0*$PI*$opt(AnH)*$opt(AnH)/$lambda] ;# Cross Over Distance

if { $opt(Pt) <= $CoD_ } {;#Free Space for short distance communication
set temp [expr 4.0*$PI*$opt(Pt)]
set TP_ [expr $RxT_*$temp*$temp/$lambda_2]
Phy/WirelessPhy set Pt_ $TP_ ;#Set the Transmissiont Power w.r.t Distance
} else { ;# TwoRayGround for communicating with far nodes
set d4 [expr $opt(Pt)*$opt(Pt)*$opt(Pt)*$opt(Pt)]
set hr2ht2 [expr $opt(AnH)*$opt(AnH)*$opt(AnH)*$opt(AnH)]
set TP_ [expr $d4*$RxT_/$hr2ht2]
Phy/WirelessPhy set Pt_ $TP_ ;#Set the Transmissiont Power w.r.t Distance
}
}
# ======================================================================
# Main Program
# ======================================================================
#
# Initialize Global Variables
#
set ns_ [new Simulator]
#tracefiles malik

#*** Throughput Trace ***
set f0 [open out02.tr w]

# *** Packet Loss Trace ***
set f4 [open lost02.tr w]

# *** Packet Delay Trace ***
set f8 [open delay02.tr w]


set tracefd [open malik2.tr w] ;# setting up output files
set nf [open malik2.nam w] ;# trace and nam file
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $nf 2000 500 ;# mobily topo x&y
#$ns_ use-newtrace

# set up topography object
set topo [new Topography]

$topo load_flatgrid 2000 500 ;#set mobile sensior
#Create PHY
set chan [new $val(chan)]
#
# Create God
#
set god_ [create-god $val(nn)]

# Attach Trace to God
set T [new Trace/Generic]
$T attach $tracefd
$T set src_ -5
$god_ tracetarget $T
#
# Create the specified number of mobilenodes [$val(nn)] and "attach" them
# to the channel.
# Here two nodes are created : node(0) and node(1)

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
$node_($i) random-motion 0 ;# disable random motion
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

set agent1 [new Agent/UDP] ;# Create UDP Agent
#$agent1 set prio_ 0 ;# Set Its priority to 0
set sink [new Agent/LossMonitor] ;# Create Loss Monitor Sink in order to be able to trace the number obytes received
$ns_ attach-agent $node_(0) $agent1 ;# Attach Agent to source node
$ns_ attach-agent $node_(1) $sink ;# Attach Agent to sink node
$ns_ connect $agent1 $sink ;# Connect the nodes
set app1 [new Application/Traffic/CBR] ;# Create Constant Bit Rate application
$app1 set packetSize_ 512 ;# Set Packet Size to 512 bytes
$app1 set rate_ 600Kb ;# Set CBR rate to 200 Kbits/sec
$app1 attach-agent $agent1 ;# Attach Application to agent
$ns_ at 0.0 "$app1 start"
$ns_ at 40.0 "$app1 stop"

# Initialize Flags
set holdtime 0
set holdseq 0
set holdrate1 0
proc record {} {
global sink f0 f4 holdtime holdseq f8 holdrate1
set ns [Simulator instance]

set time 0.9 ;#Set Sampling Time to 0.9 Sec

set bw0 [$sink set bytes_]
set bw4 [$sink set nlost_]
set bw8 [$sink set lastPktTime_]
set bw9 [$sink set npkts_]

set now [$ns now]
# Record Bit Rate in Trace Files
puts $f0 "$now [expr (($bw0+$holdrate1)*8)/(2*$time*1000000)]"

# Record Packet Loss Rate in File
puts $f4 "$now [expr $bw4/$time]"

# Record Packet Delay in File
if { $bw9 > $holdseq } {
puts $f8 "$now [expr ($bw8 - $holdtime)/($bw9 - $holdseq)]"
} else {
puts $f8 "$now [expr ($bw9 - $holdseq)]"
}
# Reset Variables
$sink set bytes_ 0
$sink set nlost_ 0
set holdtime $bw8
set holdseq $bw9
set holdrate1 $bw0
$ns at [expr $now+$time] "record" ; # Schedule Record after $time interval sec

}
# Start Recording at Time 0
$ns_ at 0.0 "record"
$ns_ at 1.0 "$app1 start" ;# Start transmission at time t = 1.0 Sec




#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at 40.0 "$node_($i) reset";
}
$ns_ at 40.000 "stop"
$ns_ at 40.010 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
global ns_ tracefd f0 f4 f8 f9
global ns_ nf
# Close Trace Files
close $f0
close $f4
close $f8


# Plot Recorded Statistics
exec xgraph out02.tr -geometry 800x400 &
exec xgraph lost02.tr -geometry 800x400 &
exec xgraph delay02.tr -geometry 800x400 &



$ns_ flush-trace
close $nf
close $tracefd
exit 0




}

puts "Starting Simulation..."
$ns_ run 
