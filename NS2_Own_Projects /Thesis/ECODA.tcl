###################################################
#        	Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#		medina.camilo@javeriana.edu.co            #
###################################################

#=====================================================================
#     Simulation parameters setup
#=====================================================================

set val(chan)           Channel/WirelessChannel    ;# Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy/802_15_4
set val(mac)            Mac/802_15_4
set val(ifq)            Queue/Ecoda                ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         20                         ;# max packet in ifq
set val(nn)             33                         ;# number of mobilenodes
set val(rp)             ECODA                      ;# routing protocol
set val(x)				      150                         ;#Casi 4 canchas de futbol
set val(y)				      150
set val(energy) 		    "EnergyModel" 
set val(initialEnergy)	100                        ;#Calculado para pila AA
set val(rxPower)		    0.395
set vak(txPower)		    0.660
set val(sensePower)		  0.035

set val(nam)			/output/congestion.nam
set val(traffic)		poisson                        ;# cbr/poisson/ftp



#===================================================================================================
#        Initialization        
#===================================================================================================




#set appTime1         	8.3	;# in seconds 
set appTime1         	30.1	;# in seconds 
#set appTime2         	8.6	;# in seconds 
set appTime2         	100.1	;# in seconds 
#set appTime3         	25.0;# in seconds 
set appTime3         	150.0;# in seconds 
set stopTime            250	;# in seconds APROX 7 Minutos

# Initialize Global Variables
set ns_		[new Simulator]
set tracefd     [open ./output/congestionResults.tr w]

set f0 [open out0.tr w]



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


  set sink [$ns_ node] 
  $sink random-motion 0    ;# disable random motion

for {set i 1} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
}

## LOADING SCENARIO


source ./Scenario/ECODA.scn
#source ./Scenario/NodesInit

#if {
#    $vbl == 1
#    || $vbl == 2
#    || $vbl == 3
#} then {
#    puts "vbl is one, two or three"
#}


if {$val(rp) == "ECODA"} {
  $ns_ at 1.0 "[$sink set ragent_] sink"
  
}


Mac/802_15_4 wpanNam PlaybackRate 3ms


#$ns_ at $appTime1 "puts \"\nTransmitting data ...\n\""


$ns_ initial_node_pos $sink 3 
# defines the node size in nam
for {set i 1} {$i < $val(nn)} {incr i} {
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
   global ns_ node_ sink
   set udp($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp($src)
   set null($dst) [new Agent/Null]
   eval $ns_ attach-agent \$sink \$null($dst)
   set expl($src) [new Application/Traffic/Exponential]
   eval \$expl($src) set packetSize_ 70
   eval \$expl($src) set burst_time_ 0
   eval \$expl($src) set idle_time_ [expr $interval*1000.0-70.0*8/250]ms	;# idle_time + pkt_tx_time = interval
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
   

  
   ## AGREGADO A ECODA

   $val(traffic)traffic 2 0 0.2 40
   $val(traffic)traffic 3 0 0.2 40
   $val(traffic)traffic 19 0 0.2 40
   $val(traffic)traffic 23 0 0.2 40
   $val(traffic)traffic 25 0 0.2 40
   $val(traffic)traffic 27 0 0.2 40
   $val(traffic)traffic 30 0 0.2 40
   $val(traffic)traffic 31 0 0.2 40
   $val(traffic)traffic 32 0 0.2 40

  
   




   $ns_ at $appTime1 "$sink add-mark m1 blue circle"
   #$ns_ at $appTime1 "$node_(6) add-mark m2 blue circle"
   #$ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) $val(traffic) traffic from node 1 to node 6\""
   #$ns_ at $appTime2 "$node_(4) add-mark m3 green4 circle"
   #$ns_ at $appTime2 "$node_(10) add-mark m4 green4 circle"
   #$ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime2) $val(traffic) traffic from node 4 to node 10\""
   Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c green
   Mac/802_15_4 wpanNam FlowClr -p MAC -c navy
   if { "$val(traffic)" == "cbr" } {
   	set pktType cbr
   } else {
   	set pktType exp
   }
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 1 -d 6 -c blue
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 4 -d 10 -c green4

   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 1 -d 0 -c blue
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 2 -d 0 -c green4
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 3 -d 0 -c red
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 4 -d 0 -c blue
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 5 -d 0 -c green4
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 6 -d 0 -c red
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 7 -d 0 -c blue
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 8 -d 0 -c green4
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 9 -d 0 -c red
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 10 -d 0 -c blue
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 11 -d 0 -c green4
   #Mac/802_15_4 wpanNam FlowClr -p $pktType -s 12 -d 0 -c red
 

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


   $ns_ at $appTime1 "$sink add-mark m1 blue circle"
   $ns_ at $stopTime "$sink delete-mark m1"

   Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c green
   Mac/802_15_4 wpanNam FlowClr -p MAC -c navy
 
}





#===================================================================================================
#        Termination        
#===================================================================================================

proc record {} {
        global sink f0
  #Get an instance of the simulator
  set ns [Simulator instance]
  #Set the time after which the procedure should be called again
        set time 0.5
  #How many bytes have been received by the traffic sinks?
        set bw0 [$sink set bytes_]

  #Get the current time
        set now [$ns now]
  #Calculate the bandwidth (in MBit/s) and write it to the files
        puts $f0 "$now [expr $bw0/$time*8/1000000]"
        puts $f1 "$now [expr $bw1/$time*8/1000000]"
        puts $f2 "$now [expr $bw2/$time*8/1000000]"
  #Reset the bytes_ values on the traffic sinks
        $sink set bytes_ 0

  #Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}








$ns_ at 0.0 "record"




$ns_ at $stopTime "$sink reset";


# Tell nodes when the simulation ends
for {set i 1} {$i < $val(nn) } {incr i} {
    $ns_ at $stopTime "$node_($i) reset";
}

$ns_ at $stopTime "stop"
$ns_ at $stopTime "puts \"\nNS EXITING...\n\""
$ns_ at $stopTime "$ns_ halt"

proc stop {} {
    global f0 
    global ns_ tracefd appTime val env
    close $f0
    $ns_ flush-trace
    close $tracefd
    set hasDISPLAY 0
    exec xgraph out0.tr -geometry 800x400 &
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

