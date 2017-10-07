###################################################
#        	Congestion Control WSN                  #
#     Camilo ALejandro Medina Mondragón           #
#		medina.camilo@javeriana.edu.co                #
###################################################

#=====================================================================
#     Simulation parameters setup
#=====================================================================

## METODO DE CONGESTION ##
#set congestion  NONE
#set congestion  ECODA
#set congestion  DAIPAS
set congestion  FUSION
#set congestion  CAM

## TOPOLOGIA DE RED ##
set topologiaRed MALLA
#set topologiaRed ESTRELLA
#set topologiaRed ARBOL

## DISTRIBUCION DE NODOS ##
#set tipoTopologia HOMOGENEA
set tipoTopologia ALEATORIA

set val(chan)           Channel/WirelessChannel    ;# Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy/802_15_4
set val(mac)            Mac/802_15_4
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         20                         ;# max packet in ifq
set val(nn)             101                         ;# number of mobilenodes
set val(x)				      150                         ;#Casi 4 canchas de futbol
set val(y)				      150
set val(energy) 		    "EnergyModel" 
set val(initialEnergy)	3.9                        ;#Calculado para pila AA
set val(rxPower)		    0.020
set vak(txPower)		    0.010
set val(sensePower)		  0.035
set val(nam)			      /output/congestion.nam
set val(traffic)		    poisson                        ;# cbr/poisson/ftp

if {$congestion == "NONE"} {
  set val(rp)             AODV                      ;# routing protocol
  set val(ifq)            Queue/DropTail/PriQueue   ;# interface queue type
}

if {$congestion == "ECODA"} {
  set val(ifq)            Queue/Ecoda                ;# interface queue type
  set val(rp)             ECODA                      ;# routing protocol  
}

if {$congestion == "DAIPAS"} {
  set val(rp)             DAIPAS                      ;# routing protocol
  set val(ifq)            Queue/DropTail              ;# interface queue type  
}

if {$congestion == "FUSION"} {
  set val(rp)             FUSION                      ;# routing protocol
  set val(ifq)            Queue/DropTail              ;# interface queue type
}

if {$congestion == "CAM"} {  
}

#===================================================================================================
#        Initialization        
#===================================================================================================


#read command line arguments
proc getCmdArgu {argc argv} {
        global val
        for {set i 0} {$i < $argc} {incr i} {
                set arg [lindex $argv $i]
                if {[string range $arg 0 0] != "-"} continue
                set name [string range $arg 1 end]
                set val($name) [lindex $argv [expr $i+1]]
        }
}
getCmdArgu $argc $argv

#set appTime1         	8.3	;# in seconds 
set appTime1         	30.1	;# in seconds 
#set appTime2         	8.6	;# in seconds 
set appTime2         	100.1	;# in seconds 
#set appTime3         	25.0;# in seconds 
set appTime3         	150.0;# in seconds 
set stopTime            410	;# in seconds APROX 7 Minutos

# Initialize Global Variables
set ns_		[new Simulator]
set tracefd     [open ./output/congestionResults.tr w]
$ns_ trace-all $tracefd
if { "$val(nam)" == "/output/congestion.nam" } {
        set namtrace     [open ./$val(nam) w]
        $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
}

$ns_ puts-nam-traceall {# nam4wpan #}		;# inform nam that this is a trace file for wpan (special handling needed)

#Mac/802_15_4 wpanCmd verbose on
Mac/802_15_4 wpanNam namStatus on		;# default = off (should be turned on before other 'wpanNam' commands can work)
#Mac/802_15_4 wpanNam ColFlashClr gold		;# default = gold

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
set dist(50m) 3.98107e-10

#Potencia de transmisión 1 dBm segun Sky Mote

Phy/WirelessPhy set Pt_ 0.001 

#Carrier sense threshold (W) SkyMote: Receiver sensitivity -64 dBm
Phy/WirelessPhy set CSThresh_ $dist(50m)
#receive power threshold (W) SkyMote: Receiver sensitivity -64 dBm
Phy/WirelessPhy set RXThresh_ $dist(50m)


# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

# Create God
set god_ [create-god $val(nn)]

set chan_1_ [new $val(chan)]


#===================================================================================================
#     Mobile node parameter setup
#===================================================================================================



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
        -energyModel $val(energy) \
        -initialEnergy $val(initialEnergy) \
        -rxPower $val(rxPower) \
        -txPower $vak(txPower) \
        -sensePower val(sensePower)\
		-channel $chan_1_ 


#===================================================================================================
#        Nodes Definition        
#===================================================================================================


for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
}

## LOADING SCENARIO




if {$tipoTopologia == "HOMOGENEA"} {
  source ./Scenario/malla.scn
}


if {$tipoTopologia == "ALEATORIA"} {

  for {set i 1} {$i < $val(nn) } { incr i } {
  $node_($i) set X_ [ expr {$val(x) * rand()} ]
  $node_($i) set Y_ [ expr {$val(y) * rand()} ]
  $node_($i) set Z_ 0
  }
  # Position of Sink
  $node_(0) set X_ [ expr {$val(x)/2} ]
  $node_(0) set Y_ [ expr {$val(y)/2} ]
  $node_(0) set Z_ 0.0
  $node_(0) label "Sink"
}





if {$topologiaRed == "MALLA"} {
source ./Scenario/NodesInitMalla
}


if {$topologiaRed == "ESTRELLA"} {
source ./Scenario/NodesInitEstrella
}


if {$topologiaRed == "ARBOL"} {
source ./Scenario/NodesInitArbol
}


if {$val(rp) == "ECODA"} {
  $ns_ at 1.0 "[$node_(0) set ragent_] sink"
}

if {$val(rp) == "DAIPAS"} {
  $ns_ at 12.0 "[$node_(0) set ragent_] sink"
}

if {$val(rp) == "WFRP"} {
  $ns_ at 1.0 "[$node_(0) set ragent_] sink"
}

if {$val(rp) == "FUSION"} {
  $ns_ at 1.0 "[$node_(0) set ragent_] sink"
}


Mac/802_15_4 wpanNam PlaybackRate 3ms

#$ns_ at $appTime1 "puts \"\nTransmitting data ...\n\""

# defines the node size in nam
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 3
}


#===================================================================================================
#        Applications Definition        
#===================================================================================================


# Setup traffic flow between nodes

proc cbrtraffic { src dst interval starttime } {
   global ns_ node_
   set udp_($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp_($src)
   set null_($dst) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null_($dst)
   set cbr_($src) [new Application/Traffic/CBR]
   eval \$cbr_($src) set packetSize_ 70
   eval \$cbr_($src) set interval_ $interval
   eval \$cbr_($src) set random_ 0
   #eval \$cbr_($src) set maxpkts_ 10000
   eval \$cbr_($src) attach-agent \$udp_($src)
   eval $ns_ connect \$udp_($src) \$null_($dst)
   $ns_ at $starttime "$cbr_($src) start"
}

proc poissontraffic { src dst interval starttime } {
   global ns_ node_
   set udp($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp($src)
   set null($dst) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null($dst)
   set expl($src) [new Application/Traffic/Exponential]
   eval \$expl($src) set packetSize_ 70 ; #bytes
   eval \$expl($src) set burst_time_ 8ms
   eval \$expl($src) set idle_time_ 992ms

   #eval \$expl($src) set burst_time_ 0
   #eval \$expl($src) set idle_time_ [expr $interval*1000.0-70.0*8/250]ms	;# idle_time + pkt_tx_time = interval
   eval \$expl($src) set rate_ 250k
   eval \$expl($src) attach-agent \$udp($src)
   eval $ns_ connect \$udp($src) \$null($dst)
   $ns_ at $starttime "$expl($src) start"
}

if { ("$val(traffic)" == "cbr") || ("$val(traffic)" == "poisson") } {
   puts "\nTraffic: $val(traffic)"
   #Mac/802_15_4 wpanCmd ack4data on
   puts [format "Acknowledgement for data: %s" [Mac/802_15_4 wpanCmd ack4data]]
   $ns_ at $appTime1 "Mac/802_15_4 wpanNam PlaybackRate 1.00ms"
   $ns_ at [expr $appTime1 + 0.5] "Mac/802_15_4 wpanNam PlaybackRate 1.5ms"
   

   #$val(traffic)traffic 79 0 0.2 30
   #$val(traffic)traffic 55 0 0.2 45
   $val(traffic)traffic 9 0 0.2 60
   $val(traffic)traffic 13 0 0.2 75
   $val(traffic)traffic 26 0 0.2 90
   $val(traffic)traffic 31 0 0.2 105
   $val(traffic)traffic 35 0 0.2 120
   $val(traffic)traffic 37 0 0.2 135
   $val(traffic)traffic 40 0 0.2 150
   $val(traffic)traffic 45 0 0.2 165
   $val(traffic)traffic 59 0 0.2 180
   $val(traffic)traffic 67 0 0.2 195
   $val(traffic)traffic 93 0 0.2 210
   $val(traffic)traffic 99 0 0.2 225
   $val(traffic)traffic 83 0 0.2 240
   $val(traffic)traffic 10 0 0.2 255
   $val(traffic)traffic 12 0 0.2 270
   $val(traffic)traffic 46 0 0.2 285
   $val(traffic)traffic 50 0 0.2 300
   $val(traffic)traffic 75 10 0.2 315
   $val(traffic)traffic 28 0 0.2 330
   $val(traffic)traffic 55 0 0.2 345
   $val(traffic)traffic 73 0 0.2 360
   $val(traffic)traffic 84 0 0.2 375
   $val(traffic)traffic 61 0 0.2 390

   $ns_ at $appTime1 "$node_(0) add-mark m1 blue circle"
   Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c green
   Mac/802_15_4 wpanNam FlowClr -p MAC -c navy
   if { "$val(traffic)" == "cbr" } {
   	set pktType cbr
   } else {
   	set pktType exp
   }
}

proc ftptraffic { src dst starttime } {
   global ns_ node_
   set tcp($src) [new Agent/TCP]
   eval \$tcp($src) set packetSize_ 50
   set sink($dst) [new Agent/TCPSink]
   eval $ns_ attach-agent \$node_($src) \$tcp($src)
   eval $ns_ attach-agent \$node_($dst) \$sink($dst)
   eval $ns_ connect \$tcp($src) \$sink($dst)
   set ftp($src) [new Application/FTP]
   eval \$ftp($src) attach-agent \$tcp($src)
   $ns_ at $starttime "$ftp($src) start"
   set stopTimeTraffic [expr {$starttime + 30.0}]
   $ns_ at $stopTimeTraffic "$ftp($src) stop"
}
     
if { "$val(traffic)" == "ftp" } {
   puts "\nTraffic: ftp"
   #Mac/802_15_4 wpanCmd ack4data off
   puts [format "Acknowledgement for data: %s" [Mac/802_15_4 wpanCmd ack4data]]
   $ns_ at $appTime1 "Mac/802_15_4 wpanNam PlaybackRate 0.17ms"
   $ns_ at [expr $appTime1 + 0.5] "Mac/802_15_4 wpanNam PlaybackRate 1.5ms"
   
   ftptraffic 1 0 25
   ftptraffic 2 0 35
   ftptraffic 3 0 45
   ftptraffic 4 0 55
   ftptraffic 6 0 65
   ftptraffic 7 0 75
   ftptraffic 8 0 85
   ftptraffic 9 0 95
   ftptraffic 10 0 105
   ftptraffic 11 0 115
   ftptraffic 12 0 125
   ftptraffic 14 0 135
   ftptraffic 16 0 145
   ftptraffic 32 0 150
   ftptraffic 18 0 155
   ftptraffic 20 0 165
   ftptraffic 34 0 170
   ftptraffic 22 0 175
   ftptraffic 24 0 185
   ftptraffic 36 0 190
   ftptraffic 28 0 200
   ftptraffic 30 0 210   
   ftptraffic 38 0 211
   ftptraffic 40 0 230


   $ns_ at $appTime1 "$node_(0) add-mark m1 blue circle"
   $ns_ at $stopTime "$node_(0) delete-mark m1"
   Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c green
   #Mac/802_15_4 wpanNam FlowClr -p MAC -c navy
 
}


#===================================================================================================
#        Termination        
#===================================================================================================



# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $stopTime "$node_($i) reset";
}

$ns_ at $stopTime "stop"
$ns_ at $stopTime "puts \"\nNS EXITING...\n\""
$ns_ at $stopTime "$ns_ halt"

proc stop {} {
    global ns_ tracefd appTime val env
    $ns_ flush-trace
    close $tracefd
    set hasDISPLAY 0
    foreach index [array names env] {
        #puts "$index: $env($index)"
        if { ("$index" == "DISPLAY") && ("$env($index)" != "") } {
                set hasDISPLAY 1
        }
    }
    if { ("$val(nam)" == "/output/congestion.nam") && ("$hasDISPLAY" == "1") } {
    	exec nam output/congestion.nam &
    }
}

puts "\nStarting Simulation..."
$ns_ run

