# http://ns2-wsn.blogspot.dk/2011/09/scenario1tcl.html


# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy/802_15_4
set val(mac)            Mac/802_15_4
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         150                         ;# max packet in ifq
set val(nn)             4                         ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)  50
set val(y)  50
#Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1
#LL set mindelay_                50us
#LL set delay_                   25us
#LL set bandwidth_               0       ;# not used
#LL set-limit 1000000




# ================================= 
# Antenna Settings 
# ================================= 
Antenna/OmniAntenna set X_ 0 
Antenna/OmniAntenna set Y_ 0 
Antenna/OmniAntenna set Z_ 1.5 
Antenna/OmniAntenna set Gt_ 1.0  
Antenna/OmniAntenna set Gr_ 1.0 
#======================
#Physica layer setting 
#======================
Phy/WirelessPhy set freq_ 2.4e+9 ;# The working band is 2.4GHz 
Phy/WirelessPhy set L_ 0.5   ;#Define teh system loss in TwoRayGround 
Phy/WirelessPhy set  bandwidth_  28.8*10e3   ;#28.8 kbps 
# For model 'TwoRayGround'
# Thereceived signals strenghts  in different distances 
set dist(5m)  7.69113e-06
set dist(9m)  2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07
Phy/WirelessPhy set CSThresh_  ;#$dist(40m)
Phy/WirelessPhy set RXThresh_  ;#$dist(40m)
#Phy/WirelessPhy set CPThresh_ 10 
# According to the Two-Ray Ground propagation model 
#Pr(d) = Pt*Gt*Gr*ht*ht*hr*hr/(d*d*d*d*L)
# thus the transmitted signal power
#average Pt= d*d*d*d*L*Pr(d)/(Gt*Gr*ht*ht*hr*hr) = 1mW     
Phy/WirelessPhy set  pt_ 0.001
#Specified Parameters for 802.15.4 MAC
Mac/802_15_4 wpanCmd verbose on   ;# to work in verbose mode 
Mac/802_15_4 wpanNam namStatus on  ;# default = off (should be turned on before other 'wpanNam' commands can work)

# Initialize Global Variables
set ns_  [new Simulator]
# Tell teh simulator to use teh new type trace data 
$ns_ use-newtrace
set scenario1   [open scenario1.tr w]
$ns_ trace-all $scenario1
#Define the NAM output file
set scenario1nam     [open scenario1.nam w]
$ns_ namtrace-all-wireless $scenario1nam $val(x) $val(y)
$ns_ puts-nam-traceall {# nam4wpan #}  ;# inform nam that this is a trace file for wpan (special handling needed)

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

# Create God 
set god_ [create-god $val(nn)]
set chan_1_ [new $val(chan)]

# configure node
$ns_ node-config -adhocRouting $val(rp) \
  -llType $val(ll) \
  -macType $val(mac) \
  -ifqType $val(ifq) \
  -ifqLen $val(ifqlen) \
  -antType $val(ant) \
  -propType $val(prop) \
  -phyType $val(netif) \
  -topoInstance $topo \
  -agentTrace OFF \
  -routerTrace OFF \
  -macTrace ON \
  #-movementTrace OFF \
                -energyModel "EnergyModel"\
                -initialEnergy 100\
                -rxPower 0.3\
                -txPower 0.3\
  -channel $chan_1_ 

for {set i 0} {$i < $val(nn) } {incr i} {
 set node_($i) [$ns_ node] 
 $node_($i) random-motion 0  ;# disable random motion
 $god_ new_node $node_($i)
}
#Lable the sink node 
$ns_ at 0.0 "$node_(3) NodeLabel Sink"
# Define the nodes positions 
$node_(0) set X_ 15.0
$node_(0) set Y_ 20.0
$node_(0) set Z_ 0.000000000000
$node_(1) set X_ 25.0
$node_(1) set Y_ 20.0
$node_(1) set Z_ 0.000000000000
$node_(2) set X_ 35.0
$node_(2) set Y_ 20.0
$node_(2) set Z_ 0.000000000000
$node_(3) set X_ 5.0
$node_(3) set Y_ 5.0
$node_(3) set Z_ 0.000000000000
#set null [new Agent/Null]
#$ns_ attach-agent $node_(3) $null
# Define the cbr traffic 
proc cbrtraffic { src dst interval starttime stoptime packetsize stage } {
   global ns_ node_
   set udp([expr $src + $stage]) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp([expr $src + $stage])
   set null([expr $src + $stage]) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null([expr $src + $stage])
   set cbr([expr $src + $stage]) [new Application/Traffic/CBR]
   eval \$cbr([expr $src + $stage]) set packetSize_ $packetsize
   eval \$cbr([expr $src + $stage]) set interval_ $interval
   eval \$cbr([expr $src + $stage]) set random_ 0
   #eval \$cbr($src) set maxpkts_ 10000
   eval \$cbr([expr $src + $stage]) attach-agent \$udp([expr $src + $stage])
   eval $ns_ connect \$udp([expr $src + $stage]) \$null([expr $src + $stage])
   $ns_ at $starttime "$cbr([expr $src + $stage]) start"
   $ns_ at $stoptime "$cbr([expr $src + $stage]) stop"
# $ns_ at $stoptime "$node_($src) reset" 
#$ns_ at $stoptime "$node_($dst) reset" 
}

## Establish traffic between nodes 
 puts "\nTraffic: cbr"
   Mac/802_15_4 wpanCmd ack4data off
   puts [format "Acknowledgement for data: %s" [Mac/802_15_4 wpanCmd ack4data]]
#src dest interval start stop packetsize stage 
#the first sensor activity
cbrtraffic 0 3 0.2 0.1 0.9 5 1;# target is in the range from 15 to 10 meters from the first sensor (sensed signal=5 bytes)
cbrtraffic 0 3 0.2 1.0 1.9 8 2;# target is in the range from 10 to 5 meters from the first sensor (sensed signal=8 bytes) 
cbrtraffic 0 3 0.2 2.0 3.9 10 3;#target is in the range from 5 to 0 meters from the first sensor (sensed signal=10 bytes) 
cbrtraffic 0 3 0.2 4.0 4.9 8 4;# target is in the range from 5 to 10 meters from the first sensor (sensed signal=8 bytes) 
cbrtraffic 0 3 0.2 5.0 5.9 5 5;# target is in the range from 10 to 15 meters from the first sensor (sensed signal=5 bytes)
cbrtraffic 0 3 0.2 6.0 6.9 3 6;# target is in the range from 15 to 20 meters from the first sensor (sensed signal=5 bytes)
cbrtraffic 0 3 0.2 7 7.9 1 7;# target is in the range from 20 to 25 meters from the first sensor (sensed signal=5 bytes) 
#the second sensor activity
cbrtraffic 1 3 0.2 0.2 0.9 1 1; # target is the range of 25 to 20 meters far from the sensor(sensed signal=1 bytes) 
cbrtraffic 1 3 0.2 1 1.9 3 2; # target is the range of 20 to 15 meters far from the sensor(sensed signal=3 bytes) 
cbrtraffic 1 3 0.2 2 2.9 5 3; # target is the range of 15 to 10 meters far from the sensor(sensed signal=5 bytes) 
cbrtraffic 1 3 0.2 3 3.9 8 4; # target is the range of 10 to 5 meters far from the sensor(sensed signal=8 bytes) 
cbrtraffic 1 3 0.2 4 5.9 10 5; # target is the range of 0 to 5 meters far from the sensor(sensed signal=10 bytes) 
cbrtraffic 1 3 0.2 6 6.9 8 6; # target is the range of 5 to 10 meters far from the sensor(sensed signal=8 bytes) 
cbrtraffic 1 3 0.2 7 7.9 5 7; # target is the range of 25 to 20 meters far from the sensor(sensed signal=5 bytes)
cbrtraffic 1 3 0.2 8 8.9 3 8; # target is the range of 25 to 20 meters far from the sensor(sensed signal=3 bytes)
cbrtraffic 1 3 0.2 9 9.9 1 9; # target is the range of 25 to 20 meters far from the sensor(sensed signal=1 bytes) 
#the third sensor activity
cbrtraffic 2 3 0.2 2 2.9 1 1; # target is the range of 25 to 20 meters far from the sensor(sensed signal=1 bytes)
cbrtraffic 2 3 0.2 3 3.9 3 2; # target is the range of 20 to 15 meters far from the sensor(sensed signal=3 bytes)
cbrtraffic 2 3 0.2 4 4.9 5 3; # target is the range of 15 to 10 meters far from the sensor(sensed signal=5 bytes)
cbrtraffic 2 3 0.2 5 5.9 8 4; # target is the range of 10 to 5 meters far from the sensor(sensed signal=8 bytes) 
cbrtraffic 2 3 0.2 6 7.9 10 5; # target is the range of 0 to 5 meters far from the sensor(sensed signal=10 bytes)
cbrtraffic 2 3 0.2 8 8.9 8 6; # target is the range of 5 to 10 meters far from the sensor(sensed signal=8 bytes) 
cbrtraffic 2 3 0.2 9 10 5 7; # target is the range of 25 to 20 meters far from the sensor(sensed signal=5 bytes) 

# defines the node size in nam
for {set i 0} {$i < $val(nn)} {incr i} {
 $ns_ initial_node_pos $node_($i) 5
}

# Tell nodes simulation ends at 10.0
for {set i 0} {$i < $val(nn) } {incr i} {
   $ns_ at 10 "$node_($i) reset";
}
$ns_ at 10 "stop"
$ns_ at 10 "puts \"\nNS EXITING...\""
$ns_ at 10 "$ns_ halt"

proc stop {} {
    global ns_ scenario1 scenario1nam
    $ns_ flush-trace
    close $scenario1
    #set hasDISPLAY 0
    exec nam scenario1.nam &
 
}
puts "\nStarting Simulation..."
$ns_ run
