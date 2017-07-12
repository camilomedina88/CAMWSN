
#     file:///home/knudfl/1-download/aodv10ms.tcl


# Define options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             10                        ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)              1100                        ;# X dimension of topography
set val(y)              600                       ;# Y dimension of topography
set val(stop)           150                        ;# time of simulation endset ns [new Simulator]

LL set mindelay_		50us
LL set delay_			25us
LL set bandwidth_		0	;# not used
LL set off_prune_		0	;# not used
LL set off_CtrMcast_		0	;# not used

Agent/Null set sport_		0
Agent/Null set dport_		0

Agent/CBR set sport_		0
Agent/CBR set dport_		0

Agent/TCPSink set sport_	0
Agent/TCPSink set dport_	0

Agent/TCP set sport_		0
Agent/TCP set dport_		0
Agent/TCP set packetSize_	1460
Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6 
Phy/WirelessPhy set L_ 1.0

set ns_ [new Simulator]
#create trace file and nam file
set tracefile [open aodv10.tr w]
$ns_ trace-all $tracefile
set namtrace [open out.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
# set up topography object
set topo [new Topography]
 $topo load_flatgrid $val(x) $val(y)
# Create God
create-god $val(nn)
# For model 'TwoRayGround'
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
      set dist(40m) 1.56962e-10
      set dist(45m) 1.56962e-11
      set dist(50m) 1.20174e-13
      Phy/WirelessPhy set CSThresh_ $dist(40m)
      Phy/WirelessPhy set RXThresh_ $dist(40m)

set chan [new $val(chan)]
# configure the nodes
 $ns_ node-config -adhocRouting $val(rp) \
                 -llType $val(ll) \
                 -macType $val(mac)\
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 -topoInstance $topo \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -movementTrace ON \
                 -channel $chan
## Creating node objects...
for {set i 0} {$i < $val(nn) } { incr i } {
       set node_($i) [$ns_ node]
       $node_($i) random-motion 0 ;# disable random motion
     }
set opt(seed) 0.1
      set a [ns-random $opt(seed)]
      set i 0
      while {$i < 5} {
      incr i
      }
#setting animation rate
$ns_ at 0.0 "$ns_ set-animation-rate 20.0ms"
# set plan nodes
#30 defines the size for nam
 for {set i 0} {$i < $val(nn)} { incr i } {
 $ns_ initial_node_pos $node_($i) 30
}

# Provide initial location of mobile nodes
$node_(0) set X_ 100.0
$node_(0) set Y_ 500.0
$node_(0) set Z_ 0.0
$node_(0) shape box
$node_(0) color blue
$ns_ at 0.0 "$node_(0) shape box"
$ns_ at 0.0 "$node_(0) color blue"
$ns_ at 1.5 "$node_(0) setdest 1000.0 500.0 15.0"
$ns_ at 60.0 "$node_(0) setdest 1000.0 300.0 10.0"
$ns_ at 80.0 "$node_(0) setdest 100.0 300.0 20.0"
$ns_ at 125.0 "$node_(0) setdest 1000.0 500.0 20.0"

$node_(1) set X_ 600.0
$node_(1) set Y_ 599.0
$node_(1) set Z_ 0.0
$node_(1) shape box
$node_(1) color yellow
$ns_ at 0.0 "$node_(1) shape box"
$ns_ at 0.0 "$node_(1) color yellow"
$ns_ at 2.5 "$node_(1) setdest 600.0 1.0 20.0"
$ns_ at 32.5 "$node_(1) setdest 1000.0 1.0 10.0"
$ns_ at 72.5 "$node_(1) setdest 1000.0 500.0 25.0"
$ns_ at 92.5 "$node_(1) setdest 100.0 500.0 25.0"

$node_(2) set X_ 1000.0
$node_(2) set Y_ 500.0
$node_(2) set Z_ 0.0
$node_(2) shape box
$node_(2) color red
$ns_ at 0.0 "$node_(2) shape box"
$ns_ at 0.0 "$node_(2) color red"
$ns_ at 1.5 "$node_(2) setdest 100.0 500.0 15.0"
$ns_ at 61.5 "$node_(2) setdest 100.0 100.0 10.0"
$ns_ at 101.5 "$node_(2) setdest 500.0 100.0 20.0"
$ns_ at 100.0 "$node_(2) setdest 500.0 500.0 20.0"
# connect 2 nodes
  set udp1 [$ns_ create-connection UDP $node_(0) LossMonitor $node_(5) 0]
  $udp1 set fid_ 1
  set cbr1 [$udp1 attach-app Traffic/CBR]
  $cbr1 set packetSize_ 1000   
  $cbr1 set interval_ .07
  $ns_ at 11.0 "$cbr1 start"
  $ns_ at 200.0 "$cbr1 stop"

$node_(3) set X_ 1000.0
$node_(3) set Y_ 500.0
$node_(3) set Z_ 0.0
$node_(3) shape box
$node_(3) color red
$ns_ at 0.0 "$node_(3) shape box"
$ns_ at 0.0 "$node_(3) color red"
$ns_ at 1.5 "$node_(3) setdest 100.0 500.0 10.0"
$ns_ at 91.0 "$node_(3) setdest 500.0 500.0 20.0"
$ns_ at 111.0 "$node_(3) setdest 501.0 200.0 10.0"

$node_(4) set X_ 999.0
$node_(4) set Y_ 300.0
$node_(4) set Z_ 0.0
$node_(4) shape box
$node_(4) color yellow
$ns_ at 0.0 "$node_(4) shape box"
$ns_ at 0.0 "$node_(4) color yellow"
$ns_ at 1.5 "$node_(4) setdest 100.0 300.0 10.0"
$ns_ at 20.0 "$node_(4) setdest 100.0 500.0 20.0"
$ns_ at 44.0 "$node_(4) setdest 700.0 500.0 25.0"
$ns_ at 68.0 "$node_(4) setdest 100.0 500.0 25.0"
$ns_ at 98.0 "$node_(4) setdest 700.0 500.0 20.0"
$ns_ at 128.0 "$node_(4) setdest 700.0 100.0 10.0"


$node_(5) set X_ 999.0
$node_(5) set Y_ 350.0
$node_(5) set Z_ 0.0
$node_(5) shape box
$node_(5) color red
$ns_ at 0.0 "$node_(5) shape box"
$ns_ at 0.0 "$node_(5) color red"
$ns_ at 1.5 "$node_(5) setdest 100.0 350.0 20.0"
$ns_ at 46.5 "$node_(5) setdest 500.0 350.0 15.0"
$ns_ at 73.0 "$node_(5) setdest 500.0 500.0 25.0"
$ns_ at 79.0 "$node_(5) setdest 900.0 500.0 5.0"

$node_(6) set X_ 400.0
$node_(6) set Y_ 50.0
$node_(6) set Z_ 0.0
$node_(6) shape box
$node_(6) color red
$ns_ at 0.0 "$node_(6) shape box"
$ns_ at 0.0 "$node_(6) color red"
$ns_ at 1.5 "$node_(6) setdest 400.0 599.0 20.0"
$ns_ at 28.5 "$node_(6) setdest 400.0 300.0 15.0"
$ns_ at 48.5 "$node_(6) setdest 700.0 300.0 10.0"
$ns_ at 78.5 "$node_(6) setdest 700.0 500.0 10.0"
$ns_ at 98.5 "$node_(6) setdest 100.0 500.0 10.0"

$node_(7) set X_ 600.0
$node_(7) set Y_ 50.0
$node_(7) set Z_ 0.0
$node_(7) shape box
$node_(7) color green
$ns_ at 0.0 "$node_(7) shape box"
$ns_ at 0.0 "$node_(7) color green"
$ns_ at 2.0 "$node_(7) setdest 600.0 599.0 15.0"
$ns_ at 38.5 "$node_(7) setdest 1000.0 599.0 20.0"
$ns_ at 58.5 "$node_(7) setdest 100.0 599.0 10.0"

$node_(8) set X_ 500.0
$node_(8) set Y_ 50.0
$node_(8) set Z_ 0.0
$node_(8) shape box
$node_(8) color red
$ns_ at 0.0 "$node_(8) shape box"
$ns_ at 0.0 "$node_(8) color red"
$ns_ at 3.5 "$node_(8) setdest 500.0 599.0 10.0"
$ns_ at 58.5 "$node_(8) setdest 700.0 599.0 20.0"
$ns_ at 68.5 "$node_(8) setdest 100.0 599.0 5.0"

$node_(9) set X_ 600.0
$node_(9) set Y_ 50.0
$node_(9) set Z_ 0.0
$node_(9) shape box
$node_(9) color red
$ns_ at 0.0 "$node_(9) shape box"
$ns_ at 0.0 "$node_(9) color red"
$ns_ at 4.5 "$node_(9) setdest 1099.0 50.0 25.0"
$ns_ at 24.5 "$node_(9) setdest 1099.0 599.0 20.0"
$ns_ at 52 "$node_(9) setdest 100.0 599.0 10.0"

# Telling nodes when the simulation ends
 for {set i 0} {$i < $val(nn) } { incr i } {
    $ns_ at $val(stop) "$node_($i) reset";
    }
    $ns_ at $val(stop) "stop"

# Ending nam and the simulation
  $ns_ at $val(stop) "$ns_ nam-end-wireless $val(stop)"
  $ns_ at 150.0 "puts \"end simulation\"; $ns_ halt"
      puts "Starting Simulation…"

#stop procedure:
proc stop { } {
   global ns_ tracefile namtrace
   $ns_ flush-trace
      close $tracefile
      close $namtrace
      exec nam out.nam &
      exit 0
    }
   $ns_ at 150 "stop"
$ns_ run
