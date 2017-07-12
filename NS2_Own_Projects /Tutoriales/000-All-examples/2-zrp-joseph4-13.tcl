# ========================================================= 
# http://www.linuxquestions.org/questions/linux-newbie-8/how-to-add-more-nodes-to-ns2-tcl-script-4175497182/
# 
#                    Define options
# ========================================================= 

set val(chan) Channel/WirelessChannel ;# channel type 

set val(prop) Propagation/TwoRayGround ;# radio-propagation model 

set val(ant) Antenna/OmniAntenna ;# Antenna type 
set val(ll) LL ;# Link layer type 
set val(ifq) Queue/DropTail/PriQueue ;# Interface queue type 
set val(ifqlen) 50 ;# max packet in ifq 
set val(netif) Phy/WirelessPhy ;# network interface type 
set val(mac) Mac/802_11 ;# MAC type 
set val(nn) 13 ;# number of mobilenodes 
set val(rp) ZRP		 	;# routing protocol 
set val(x) 650 
set val(y) 650 

Agent/ZRP set radius_ 2 	;# Setting ZRP radius=2



#The Antenna height of transmitter and receiver is 1.5m. 
#The propagation model is TwoRayGround model. 
# set up the antennas to be centered in the node and 1.5 meters above it 

Antenna/OmniAntenna set X_ 0 
Antenna/OmniAntenna set Y_ 0 
Antenna/OmniAntenna set Z_ 1.5 
Antenna/OmniAntenna set Gt_ 1.0 ;# Transmit antenna gain 
Antenna/OmniAntenna set Gr_ 1.0 ;# Receive antenna gain 


Phy/WirelessPhy set bandwidth_ 54e6 ;#Data Rate 

# Initialize the SharedMedia interface with parameters to make 
# it work like the 914MHz Lucent WaveLAN DSSS radio interface 
#Collision Threshold 

Phy/WirelessPhy set CPThresh_ 10.0 

#Receive Power Threshold;calculated under TwoRayGround model by tools from NS2 
Phy/WirelessPhy set RXThresh_ 3.652e-10 

#Transmit Power 
Phy/WirelessPhy set Pt_ 0.28183815 

# Channel 2.4 GHz 
Phy/WirelessPhy set freq_ 2.4e9 

#System loss facor 
Phy/WirelessPhy set L_ 1.0 

#Carrier Sense Power 

Phy/WirelessPhy set CSThresh_ 1.559e-11

Phy/WirelessPhy set PowerMonitorThresh_ 6.310e-14 ;#-102dBm power monitor sensitivity 
Phy/WirelessPhy set HeaderDuration_ 0.000040 ;#40 us 
Phy/WirelessPhy set BasicModulationScheme_ 0 
Phy/WirelessPhy set PreambleCaptureSwitch_ 1 
Phy/WirelessPhy set DataCaptureSwitch_ 0 
Phy/WirelessPhy set SINR_PreambleCapture_ 2.5118; ;# 4 dB 
Phy/WirelessPhy set SINR_DataCapture_ 100.0; ;# 10 dB 
Phy/WirelessPhy set trace_dist_ 1e6 ;# PHY trace until distance of 1 Mio.km("infinty") 
Phy/WirelessPhy set PHY_DBG_ 0 
Phy/WirelessPhy set noise_floor_ 1.26e-13 ;#-99 dBm for 10MHz bandwidth 



#you can set dataRate for DATA here 
Mac/802_11 set dataRate_ 54e6 ;# Rate for Data frame 

#you can set basicRate for RTS/CTS, and ACK here 
Mac/802_11 set basicRate_ 6e6 ;# Rate for Control Frame 

#Mac/802_11 set RTSThreshold_ 3000 ;# Disable RTS/CTS 
# 802.11g parameters 

Mac/802_11 set CWMin_ 15 
Mac/802_11 set CWMax_ 1023 
Mac/802_11 set SlotTime_ 0.000009 ;# 9us 
Mac/802_11 set CCATime_ 0.000003 
Mac/802_11 set RxTxTurnaroundTime_ 0.000002 
Mac/802_11 set SIFSTime_ 0.000016 ;# 16us 
Mac/802_11 set DIFS_ 0.000028 ;# 50us 
Mac/802_11 set PreambleLength_ 96 ;# 96 bit 
Mac/802_11 set PLCPHeaderLength_ 40 ;# 40 bits 
Mac/802_11 set PLCPDataRate_ 6.0e6 ;# 6Mbps 
Mac/802_11 set MaxPropagationDelay_ 0.0000005 ;# 0.5us 


Mac/802_11 set ShortRetryLimit_ 7 
Mac/802_11 set LongRetryLimit_ 4 
Mac/802_11 set HeaderDuration_ 0.000040 
Mac/802_11 set SymbolDuration_ 0.000008 
Mac/802_11 set BasicModulationScheme_ 0 
Mac/802_11 set use_802_11a_flag_ true 
#Mac/802_11 set RTSThreshold_ 2346 
Mac/802_11 set MAC_DBG_ 0
# fix for when RTS/CTS not used 
#Mac/802_11 set RTS_ 20.0 
#Mac/802_11 set CTS_ 14.0



#To create a simulator object. This can be done with the command: 

set ns [new Simulator]
set f [open coop-13.tr w] 
$ns trace-all $f


set namtrace [open coop-13.nam w] 
$ns namtrace-all-wireless $namtrace $val(x) $val(y) 

set f0 [open co_packet_received.data w] 
set f1 [open co_packet_lost.data w] 
set f2 [open co_expected_packet.data w] 
set f3 [open byte.data w] 
set f4 [open receivingTime.data w] 
set f5 [open actual_Time.data w]
set f8 [open co_cbr6np.data w] 
set f9 [open co_cbr6nl.data w] 
set f10 [open co_cbr6ex.data w] 
set f11 [open cbr6by.data w]
set f12 [open cbr6re.data w]
set f13 [open co_sumband.data w]
set f14 [open co_avecbr6.data w]



set f6 [open co_sumband.data w]
set f7 [open co_aveband.data w]
#set f8 [open sequence_number.data w] 


set topo [new Topography] 
$topo load_flatgrid 650 650 

create-god $val(nn) 
set chan_1 [new $val(chan)] 
set chan_2 [new $val(chan)] 
set chan_3 [new $val(chan)] 
set chan_4 [new $val(chan)] 
set chan_5 [new $val(chan)]
set chan_6 [new $val(chan)] 
set chan_7 [new $val(chan)] 
set chan_8 [new $val(chan)]
set chan_9 [new $val(chan)] 
set chan_10 [new $val(chan)] 
set chan_11 [new $val(chan)] 
set chan_12 [new $val(chan)] 
set chan_13 [new $val(chan)]
#set chan_14 [new $val(chan)] 
#set chan_15 [new $val(chan)] 
#set chan_16 [new $val(chan)]




# CONFIGURE AND CREATE NODES 
proc UniformErr {} {
set err [new ErrorModel]
$err unit packet
$err set rate_ 0.05
$err ranvar [new RandomVariable/Uniform]
$err drop-target [new Agent/Null]
return $err}



# NODE CONFIG PART
$ns node-config -adhocRouting $val(rp) \
     -llType $val(ll) \
	 -macType $val(mac) \
	 -ifqType $val(ifq) \
	 -ifqLen $val(ifqlen) \
	 -antType $val(ant) \
	 -propType $val(prop) \
	 -phyType $val(netif) \
	 -topoInstance $topo \
	 -agentTrace OFF \
	 -routerTrace ON \
	 -macTrace ON \
	 -movementTrace OFF \
	 -channel $chan_1 \
	 -IncomingErrProc UniformErr


for {set i 0} {$i < $val(nn) } {incr i} {set node_($i) [$ns node] 
$node_($i) random-motion 0 ;# disable random motion
}

 
proc finish {} {
global ns f f0 f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 namtrace
$ns flush-trace 
close $namtrace 
close $f0 
close $f1 
close $f2 
close $f3 
close $f4
close $f5 
close $f6 
close $f7 
close $f8 
close $f9 
close $f10 
close $f11 
close $f12 
close $f13


exec xgraph co_packet_received.data co_packet_lost.data co_expected_packet.data &
exec xgraph receivingTime.data actual_Time.data -geometry 500x300 & 
exec xgraph byte.data co_sumband.data -geometry 400x300 &

exec xgraph co_cbr6np.data co_cbr6nl.data co_cbr6ex.data &
exec xgraph cbr6re.data -geometry 500x300 & 
exec xgraph byte.data co_sumband.data cbr6by.data co_sumcbr6.data -geometry 400x300 &

		exec nam -r 5m coop-13.nam & 

          exit 0 

} 

set co_sumband 0 
set co_aveband 0 
set co_sumcbr6 0 
set co_avecbr6 0


proc record {} { 
global sink0 sink1 sink2 sink3 sink4 sink5 sink6 sink7 f0 f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 co_sumband co_aveband co_sumcbr6 co_avecbr6 

#Get An Instance Of The Simulator 
set ns [Simulator instance]


#Set The Time After Which The Procedure Should Be Called Again 
set time 1.0 

#How Many Bytes Have Been Received By The Traffic Sinks? 

set bw0 [$sink5 set npkts_] 
set bw1 [$sink5 set nlost_] 
set bw [$sink5 set expected_] 
set byte [$sink5 set bytes_] 
set receivingTime [$sink5 set lastPktTime_]
set cbr6np [$sink0 set npkts_] 
set cbr6nl [$sink0 set nlost_] 
set cbr6ex [$sink0 set expected_] 
set cbr6by [$sink0 set bytes_] 
set cbr6re [$sink0 set lastPktTime_]



#Get The Current Time 
set now [$ns now] 

#Save Data To The Files 
puts $f0 "$now [expr $bw0]" 
puts $f1 "$now [expr $bw1]" 
puts $f2 "$now [expr $bw]" 
puts $f3 "$now [expr $byte]" 
puts $f4 "$now [expr $receivingTime]" 
puts $f5 "$now [expr $now]" 
puts $f6 "$now [expr $co_sumband]" 
puts $f7 "$now [expr $co_aveband]"

puts $f8 "$now [expr $cbr6np]" 
puts $f9 "$now [expr $cbr6nl]" 
puts $f10 "$now [expr $cbr6ex]" 
puts $f11 "$now [expr $cbr6by]"
puts $f12 "$now [expr $cbr6re]" 

puts $f13 "$now [expr $co_sumcbr6]" 
puts $f14 "$now [expr $co_avecbr6]"

#calculate loss ratio, to avoid divided-by-zero error 
if {$bw0==0} {set bw0 1} 
set co_sumband [expr $co_sumband + $byte] 

#average throughput in bps, 10 sec is session time 
set co_aveband [expr double($co_sumband)/10] 
puts "T=$now, Band=$bw0, co_sumband= $co_sumband, co_aveband=$co_aveband" 

#puts " At time =$now, Loss ratio [expr double($bw1)/double($bw1+$bw0)]"
if {$cbr6np==0} {set cbr6np 1} 
set co_sumcbr6 [expr $co_sumcbr6 + $cbr6by] 

#average throughput in bps, 10 sec is session time 
set co_avecbr6 [expr double($co_sumcbr6)/10] 

#Reset the bytes_ values on the traffic sinks 
#$sink5 set byte_ 0 
#reset the nlost_ values to zero 
#$sink0 set nlost_ 0 
#reset the npkts_ values to zero 
#$sink0 set npkts_ 0


#Re-Schedule The Procedure 
$ns at [expr $now+$time] "record" 

} 


# define color index 
$ns color 0 blue 
$ns color 1 red 
$ns color 2 chocolate 
$ns color 3 red 
$ns color 4 brown 
$ns color 5 tan 
$ns color 6 gold 
$ns color 7 black



for {set i 0} {$i < $val(nn)} {incr i} { 
$ns initial_node_pos $node_($i) 30+i*100 
} 

$node_(0) set X_ 0.0 
$node_(0) set Y_ 0.0 
$node_(0) set Z_ 0.0 

$node_(1) set X_ 0.0 
$node_(1) set Y_ 0.0 
$node_(1) set Z_ 0.0 

$node_(2) set X_ 0.0 
$node_(2) set Y_ 0.0 
$node_(2) set Z_ 0.0

$node_(3) set X_ 0.0 
$node_(3) set Y_ 0.0 
$node_(3) set Z_ 0.0 

$node_(4) set X_ 0.0 
$node_(4) set Y_ 0.0 
$node_(4) set Z_ 0.0 

$node_(5) set X_ 0.0 
$node_(5) set Y_ 0.0 
$node_(5) set Z_ 0.0 

$node_(6) set X_ 0.0 
$node_(6) set Y_ 0.0 
$node_(6) set Z_ 0.0 

$node_(7) set X_ 0.0
$node_(7) set Y_ 0.0
$node_(7) set Z_ 0.0

$ns at 0.0 "$node_(0) setdest 100.0 100.0 3000.0" 
$ns at 0.0 "$node_(1) setdest 200.0 200.0 3000.0" 
$ns at 0.0 "$node_(2) setdest 300.0 200.0 3000.0" 
$ns at 0.0 "$node_(3) setdest 400.0 300.0 3000.0" 
$ns at 0.0 "$node_(4) setdest 500.0 400.0 3000.0" 
$ns at 0.0 "$node_(5) setdest 100.0 280.0 3000.0" 
$ns at 0.0 "$node_(6) setdest 550.0 200.0 3000.0" 
$ns at 0.0 "$node_(7) setdest 600.0 300.0 3000.0"


 
$ns at 1.5 "$node_(5) setdest 100.0 400.0 500.0" 
#$ns at 1.0 "$node_(3) setdest 400.0 400.0 500.0" 
$ns at 2.5 "$node_(5) setdest 500.0 300.0 500.0" 
$ns at 3.5 "$node_(5) setdest 500.0 100.0 500.0" 
#$ns at 4.0 "$node_(3) setdest 600.0 400.0 500.0" 
#$ns at 3.5 "$node_(5) setdest 300.0 100.0 500.0" 
$ns at 7.0 "$node_(6) setdest 550.0 550.0 500.0" 
$ns at 8.0 "$node_(6) setdest 100.0 400.0 500.0"

 
$ns at 0.4 "$node_(0) label \"source\"" 
$ns at 0.4 "$node_(5) label \"destination\"" 
#$ns at 0.4 "$node_(3) label \"destination\""
$ns at 1.9 "$node_(1) label \"helper\"" 
#$ns at 2.4 "$node_(3) label \" \"" 
$ns at 3.3 "$node_(1) label \" \"" 
$ns at 3.4 "$node_(2) label \"helper\"" 
$ns at 4.8 "$node_(5) label \"\"" 

#$ns at 4.5 "$node_(3) label \"destination\"" 
$ns at 6.2 "$node_(6) label \"destination\"" 
$ns at 6.8 "$node_(2) label \"\"" 
$ns at 7.0 "$node_(3) label \"helper\"" 
$ns at 7.9 "$node_(3) label \"\"" 
$ns at 8.0 "$node_(4) label \"helper\"" 
$ns at 9.0 "$node_(4) label \"\"" 
$ns at 9.1 "$node_(1) label \"helper\""



# CONFIGURE AND SET UP A FLOW
set sink0 [new Agent/LossMonitor] 
set sink1 [new Agent/LossMonitor] 
set sink2 [new Agent/LossMonitor] 
set sink3 [new Agent/LossMonitor] 
set sink4 [new Agent/LossMonitor] 
set sink5 [new Agent/LossMonitor] 
set sink6 [new Agent/LossMonitor] 
set sink7 [new Agent/LossMonitor] 

$ns attach-agent $node_(0) $sink0 
$ns attach-agent $node_(1) $sink1 
$ns attach-agent $node_(2) $sink2 
$ns attach-agent $node_(3) $sink3 
$ns attach-agent $node_(4) $sink4 
$ns attach-agent $node_(5) $sink5 
$ns attach-agent $node_(6) $sink6 
$ns attach-agent $node_(7) $sink7 



#$ns attach-agent $sink2 $sink3 
set tcp0 [new Agent/TCP] 
$ns attach-agent $node_(0) $tcp0 
set tcp1 [new Agent/TCP] 
$ns attach-agent $node_(1) $tcp1 
set tcp2 [new Agent/TCP] 
$ns attach-agent $node_(2) $tcp2 
set tcp3 [new Agent/TCP] 
$ns attach-agent $node_(3) $tcp3
set tcp4 [new Agent/TCP] 
$ns attach-agent $node_(4) $tcp4 
set tcp5 [new Agent/TCP] 

$ns attach-agent $node_(5) $tcp5 
set tcp6 [new Agent/TCP] 
$ns attach-agent $node_(6) $tcp6 
set tcp7 [new Agent/TCP] 
$ns attach-agent $node_(7) $tcp7

proc attach-CBR-traffic { node sink size interval } { 

#Get an instance of the simulator 
set ns [Simulator instance] 

#Create a CBR agent and attach it to the node 
set cbr [new Agent/CBR] 
$ns attach-agent $node $cbr 
$cbr set packetSize_ $size 
$cbr set interval_ $interval 


#Attach CBR source to sink; 
$ns connect $cbr $sink 
return $cbr 

}



#src bitrate: 500*8/0.015=26.666 Kbps 
set cbr0 [attach-CBR-traffic $node_(0) $sink5 500 .015] 
set cbr1 [attach-CBR-traffic $node_(1) $sink2 500 .015] 
set cbr2 [attach-CBR-traffic $node_(2) $sink3 500 .015] 
set cbr3 [attach-CBR-traffic $node_(3) $sink0 500 .015] 
set cbr4 [attach-CBR-traffic $node_(4) $sink3 500 .015] 
set cbr5 [attach-CBR-traffic $node_(5) $sink0 500 .015] 
set cbr6 [attach-CBR-traffic $node_(6) $sink0 500 .015] 
set cbr7 [attach-CBR-traffic $node_(7) $sink0 500 .015] 



$ns at 0.0 "record" 
$ns at 0.5 "$cbr0 start" 
$ns at 0.6 "$cbr2 start" 
$ns at 2.0 "$cbr2 stop" 
$ns at 4.6 "$cbr4 start" 
$ns at 5.0 "$cbr0 stop" 
$ns at 5.8 "$cbr4 stop" 
$ns at 6.0 "$cbr0 stop" 
$ns at 6.0 "$cbr6 start" 
$ns at 9.0 "$cbr4 stop"
#$ns at 4.5 "$cbr2 start" 
#$ns at 6.0 "$cbr2 stop" 
#$ns at 5.4 "$cbr0 start" 


$ns at 10.0 "finish" 
puts "Start of simulation.." 

$ns run
