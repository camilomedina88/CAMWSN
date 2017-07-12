#    http://enggedu.com/Tcl_script_to_create_the_dynamic_color_and_initial_location_to_nodes/index.php 


set val(chan)           Channel/WirelessChannel    ;# Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         5                         ;# max packet in ifq
set val(nn)             4                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)                      750
set val(y)                      550
set val(stop)                   3.0

#-------Event scheduler object creation--------#

      set ns [new Simulator]

## Create a trace file and nam file..
      set tracefd [open wireless1.tr w]
      set namtrace [open wireless1.nam w]   

## Trace the nam and trace details from the main simulation..
      $ns trace-all $tracefd
      $ns namtrace-all-wireless $namtrace $val(x) $val(y)

## set up topography object..
      set topo [new Topography]

      $topo load_flatgrid $val(x) $val(y)

      set god_ [create-god $val(nn)]

## Color Descriptions..
      $ns color 1 dodgerblue
      $ns color 2 blue
      $ns color 3 cyan
      $ns color 4 green
      $ns color 5 yellow
      $ns color 6 black
      $ns color 7 magenta
      $ns color 8 gold
      $ns color 9 red
     
## Array for dynamic color settings...
      set colorname(0) blue
      set colorname(1) cyan
      set colorname(2) green
      set colorname(3) red
      set colorname(4) gold
      set colorname(5) magenta

## Setting The Distance Variables..
# For model 'TwoRayGround'
      set dist(5m)  7.69113e-06
      set dist(9m)  2.37381e-06
      set dist(10m) 1.92278e-06
      set dist(11m) 1.58908e-06
      set dist(12m) 1.33527e-06
      set dist(13m) 1.13774e-06
      set dist(25m) 3.07645e-07
      set dist(30m) 2.13643e-07
      set dist(35m) 1.56962e-07
      set dist(40m) 1.56962e-10
      set dist(45m) 1.56962e-11
      set dist(50m) 1.20174e-13
      #Phy/WirelessPhy set CSThresh_ $dist(50m)
      #Phy/WirelessPhy set RXThresh_ $dist(50m)

## Setting node config event with set of inputs..
         $ns node-config -adhocRouting $val(rp) \
                   -llType $val(ll) \
                   -macType $val(mac) \
                   -ifqType $val(ifq) \
                   -ifqLen $val(ifqlen) \
                   -antType $val(ant) \
                   -propType $val(prop) \
                   -phyType $val(netif) \
                   -channelType $val(chan) \
                   -topoInstance $topo \
                   -agentTrace ON \
                   -routerTrace ON \
                   -macTrace OFF \
                   -movementTrace ON

     
## Creating node objects...              
      for {set i 0} {$i < $val(nn) } { incr i } {
            set node_($i) [$ns node]     
      }
      for {set i 0} {$i < $val(nn) } {incr i } {
            $node_($i) color blue
            $ns at 0.0 "$node_($i) color blue"
      }

## Provide initial location of mobilenodes...
            for {set i 0} {$i < $val(nn) } { incr i } {
                  set xx [expr rand()*600]
                  set yy [expr rand()*500]
                  $node_($i) set X_ $xx
                  $node_($i) set Y_ $yy
                  $node_($i) set Z_ 0.0
            }

## Define node initial position in nam...
      for {set i 0} {$i < $val(nn)} { incr i } {
      # 30 defines the node size for nam..
            $ns initial_node_pos $node_($i) 30
      }

## Dynamic color procedure..
$ns at 0.0 "dynamic-color"
proc dynamic-color {} {
      global ns val node_ colorname
      set time 0.3
      set now [$ns now]
      set Rand [expr round(rand()*5)]
      for {set i 0} {$i < $val(nn) } {incr i } {
            $node_($i) color $colorname($Rand)
            $ns at $now "$node_($i) color $colorname($Rand)"
      }
      $ns at [expr $now+$time] "dynamic-color"
}
## stop procedure..
$ns at $val(stop) "stop"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    puts "running nam..."
    exec nam wireless1.nam &
    exit 0
}

$ns runs