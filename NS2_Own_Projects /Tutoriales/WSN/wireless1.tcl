 # ==
 # Define options
 # ==
 set val(chan)   Channel/WirelessChannel;# Channel Type
 set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
 set val(netif)  Phy/WirelessPhy/802_15_4
 set val(mac)  Mac/802_15_4
 set val(ifq)  Queue/DropTail/PriQueue;# interface queue type
 set val(ll) LL ;# link layer type
 set val(ant)  Antenna/OmniAntenna;# antenna model
 set val(ifqlen) 50 ;# max packet in ifq
 set val(nn) 25 ;# number ofmobilenodes
 set val(rp) AODV   ;# routing protocol
 set val(x) 50
 set val(y) 50
 
 set val(nam)  wsn1.nam
 set val(traffic)  ftp;# cbr/poisson/ftp
 
 #read command line arguments
 proc getCmdArgu {argc argv} {
 global val
 for {set i 0} {$i  $argc} {incr i} {
 set arg [lindex $argv $i]
 if {[string range $arg 0 0] != -} continue
 set name [string range $arg 1 end]
 set val($name) [lindex $argv [expr $i+1]]
 }
 }
 getCmdArgu $argc $argv
 
 set appTime10.0   ;# in seconds
 set appTime20.3   ;# in seconds
 set appTime30.7   ;# in seconds
 set stopTime100   ;# in seconds
 
 # Initialize Global Variables
 set ns_   [new Simulator]
 set tracefd [open ./wsn1.tr w]
 $ns_ trace-all $tracefd
 if { $val(nam) == wsn1.nam } {
 set namtrace [open ./$val(nam) w]
 $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
 }
 
 $ns_ puts-nam-traceall {# nam4wpan #} ;# inform nam that this is a
 trace file for wpan (special handling needed)
 
 Mac/802_15_4 wpanNam namStatus on ;# default = off (should be turned on before other 'wpanNam' commands can work)
 #Mac/802_15_4 wpanNam ColFlashClr gold;# default = gold
 #Mac/802_15_4 wpanNam NodeFailClr grey;# default = grey
 
 
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
 set dist(40m) 1.20174e-07
 Phy/WirelessPhy set CSThresh_ $dist(15m)
 Phy/WirelessPhy set RXThresh_ $dist(15m)
 
 # set up topography object
 set topo   [new Topography]
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
   -movementTrace OFF \
 #-energyModel EnergyModel \
 #-initialEnergy 1 \
 #-rxPower 0.3 \
 #-txPower 0.3 \
   -channel $chan_1_
 
 for {set i 0} {$i  $val(nn) } {incr i} {
   set node_($i) [$ns_ node]   
   $node_($i) random-motion 0  ;# disable random motion
 }
 
 source ./wsn1.scn
 
 # Setup traffic flow between nodes
 
 proc cbrtraffic { src dst interval starttime } {
global ns_ node_
set udp($src) [new Agent/UDP]
eval $ns_ attach-agent \$node_($src) \$udp($src)
set null($dst) [new Agent/Null]
eval $ns_ attach-agent \$node_($dst) \$null($dst)
set cbr($src) [new Application/Traffic/CBR]
eval \$cbr($src) set packetSize_ 70
eval \$cbr($src) set interval_ $interval
eval \$cbr($src) set random_ 0
#eval \$cbr($src) set maxpkts_ 1
eval \$cbr($src) attach-agent \$udp($src)
eval $ns_ connect \$udp($src) \$null($dst)
$ns_ at $starttime $cbr($src) start
 }
 
 proc poissontraffic { src dst interval starttime } {
global ns_ node_
set udp($src) [new Agent/UDP]
eval $ns_ attach-agent \$node_($src) \$udp($src)
set null($dst) [new Agent/Null]
eval $ns_ attach-agent \$node_($dst) 