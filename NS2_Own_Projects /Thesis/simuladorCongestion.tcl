###################################################
#        	Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#		medina.camilo@javeriana.edu.co            #
###################################################

#===================================
#     Simulation parameters setup
#===================================

set val(chan)           Channel/WirelessChannel    	;# Channel Type
set val(prop)           Propagation/Shadowing    	;# radio-propagation model
set val(netif)          Phy/WirelessPhy/802_15_4
set val(mac)            Mac/802_15_4
#set val(ifq)            Queue/DropTail/PriQueue    	;# interface queue type
set val(ifq) 			Queue/Ecoda
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             101                         ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)				50
set val(y)				50
set val(energy) 		"EnergyModel" 
set val(initialEnergy)	50
set val(rxPower)		0.75
set vak(txPower)		0.25
set val(sensePower)		0.10
set val(nam)			output/wpan_demo1.nam
set val(traffic)		ftp                        ;# cbr/poisson/ftp



#===================================
#        Initialization        
#===================================

set appTime1         	8.3	;# in seconds 
set appTime2         	8.6	;# in seconds 
set stopTime            100	;# in seconds 




#set appTime1            0.0	;# in seconds 
#set appTime2            0.3	;# in seconds 
#set appTime3            0.7	;# in seconds 
#set stopTime            40.0	;# in seconds 


set ns_		[new Simulator]
set tracefd     [open ./output/wpan_demo1.tr w]
$ns_ trace-all $tracefd
if { "$val(nam)" == "output/wpan_demo1.nam" } {
        set namtrace     [open ./$val(nam) w]
        $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
}

#$ns_ puts-nam-traceall {# nam4wpan #}		;# inform nam that this is a trace file for wpan (special handling needed)

Mac/802_15_4 wpanCmd verbose on
Mac/802_15_4 wpanNam namStatus on


#$ns_ puts-nam-traceall {# nam4wpan #}		;# inform nam that this is a trace file for wpan (special handling needed)
#Mac/802_15_4 wpanNam namStatus on		;# default = off (should be turned on before other 'wpanNam' commands can work)

#Mac/802_15_4 wpanNam ColFlashClr gold		;# default = gold
#Mac/802_15_4 wpanNam NodeFailClr grey		;# default = grey


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
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
# Create God
set god_ [create-god $val(nn)]
set chan_1_ [new $val(chan)]


#===================================
#     Mobile node parameter setup
#===================================
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


#===================================
#        Nodes Definition        
#===================================

for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
}

source ./Scenario/malla.scn

# defines the node size in nam

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 2
}

$ns_ at 0.0	"$node_(0) NodeLabel PAN Coor"
$ns_ at 0.0	"$node_(0) sscs startPANCoord 1"		;# startPANCoord <txBeacon=1> <BO=3> <SO=3>
$ns_ at 0.5	"$node_(1) sscs startDevice 1 1 1" 		;# startDevice <isFFD=1> <assoPermit=1> <txBeacon=0> <BO=3> <SO=3>
$ns_ at 1.5	"$node_(2) sscs startDevice 1 1 1"
$ns_ at 2.5	"$node_(3) sscs startDevice 1 1 1"
$ns_ at 3.5	"$node_(4) sscs startDevice 1 1 1"
$ns_ at 4.5	"$node_(5) sscs startDevice 1 1 1"
$ns_ at 5.5	"$node_(6) sscs startDevice 0"
$ns_ at 5.8	"$node_(7) sscs startDevice 0"
$ns_ at 6.5	"$node_(8) sscs startDevice 0"
$ns_ at 6.8	"$node_(9) sscs startDevice 0"
$ns_ at 7.0	"$node_(10) sscs startDevice 0"

$ns_ at 6.0 "$node_(3) sscs stopBeacon"
$ns_ at 8.0 "$node_(3) sscs startBeacon"
$ns_ at 9.0 "$node_(5) sscs startBeacon 4 4"		;# change beacon order and superframe order
$ns_ at 10.0 "$node_(4) sscs stopBeacon"

Mac/802_15_4 wpanNam PlaybackRate 3ms

$ns_ at $appTime1 "puts \"\nTransmitting data ...\n\""





#===================================
#        Applications Definition        
#===================================



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
}
     
if { "$val(traffic)" == "ftp" } {
   puts "\nTraffic: ftp"
   #Mac/802_15_4 wpanCmd ack4data off
   puts [format "Acknowledgement for data: %s" [Mac/802_15_4 wpanCmd ack4data]]
   $ns_ at $appTime1 "Mac/802_15_4 wpanNam PlaybackRate 0.17ms"
   $ns_ at [expr $appTime1 + 0.5] "Mac/802_15_4 wpanNam PlaybackRate 1.5ms"
   ftptraffic 1 6 $appTime1
   ftptraffic 4 10 $appTime2
   $ns_ at $appTime1 "$node_(1) add-mark m1 blue circle"
   #$ns_ at $stopTime "$node_(1) delete-mark m1"
   $ns_ at $appTime1 "$node_(6) add-mark m2 blue circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) ftp traffic from node 1 to node 6\""
   $ns_ at $appTime2 "$node_(4) add-mark m3 green4 circle"
   $ns_ at $appTime2 "$node_(10) add-mark m4 green4 circle"
   $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime2) ftp traffic from node 4 to node 10\""
   Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c green
   Mac/802_15_4 wpanNam FlowClr -p MAC -c navy
   Mac/802_15_4 wpanNam FlowClr -p tcp -s 1 -d 6 -c blue
   Mac/802_15_4 wpanNam FlowClr -p ack -s 6 -d 1 -c blue
   Mac/802_15_4 wpanNam FlowClr -p tcp -s 4 -d 10 -c green4
   Mac/802_15_4 wpanNam FlowClr -p ack -s 10 -d 4 -c green4
}






#Create a UDP agent and attach it to node n0
#set udp0 [new Agent/UDP]
#$ns_ attach-agent $node_(2) $udp0
# Create a CBR traffic source and attach it to udp0
#set cbr0 [new Application/Traffic/CBR]
#$cbr0 set packetSize_ 500
#$cbr0 set interval_ 0.005
#$cbr0 attach-agent $udp0
#set null0 [new Agent/Null] 
#$ns_ attach-agent $node_(76) $null0
#$ns_ connect $udp0 $null0



#set tcp [new Agent/TCP]
#$tcp set class_ 2
#set sink [new Agent/TCPSink]
#$ns_ attach-agent $node_(6) $tcp
#$ns_ attach-agent $node_(0) $sink
#$ns_ connect $tcp $sink
#set ftp [new Application/FTP]
#$ftp attach-agent $tcp
#$ns_ at 10.0 "$ftp start" 


#ns_ at 5.0 "$cbr0 start"
#$ns_ at 9.9 "$cbr0 stop"





#===================================
#        Termination        
#===================================


# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $stopTime "$node_($i) reset";
}

$ns_ at $stopTime "stop"
$ns_ at $stopTime "puts \"\nNS EXITING...\""
$ns_ at $stopTime "$ns_ halt"

proc stop {} {
    global ns_ tracefd val env
    $ns_ flush-trace
    close $tracefd
    set hasDISPLAY 0
    foreach index [array names env] {
        #puts "$index: $env($index)"
        if { ("$index" == "DISPLAY") && ("$env($index)" != "") } {
                set hasDISPLAY 1
        }
    }
    if { ("$val(nam)" == "output/wpan_demo1.nam") && ("$hasDISPLAY" == "1") } {
	    exec nam output/wpan_demo1.nam &
    }
}

puts "\nStarting Simulation..."
$ns_ run