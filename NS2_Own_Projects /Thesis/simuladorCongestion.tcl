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
set val(ifq)            Queue/DropTail/PriQueue    	;# interface queue type
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
set val(nam)		wpan_demo1.nam
set val(traffic)	ftp                        ;# cbr/poisson/ftp



#===================================
#        Initialization        
#===================================

set appTime1            0.0	;# in seconds 
set appTime2            0.3	;# in seconds 
set appTime3            0.7	;# in seconds 
set stopTime            100	;# in seconds 


set ns_		[new Simulator]
set tracefd     [open ./wpan_demo1.tr w]
$ns_ trace-all $tracefd
if { "$val(nam)" == "wpan_demo1.nam" } {
        set namtrace     [open ./$val(nam) w]
        $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
}

$ns_ puts-nam-traceall {# nam4wpan #}		;# inform nam that this is a trace file for wpan (special handling needed)
Mac/802_15_4 wpanNam namStatus on		;# default = off (should be turned on before other 'wpanNam' commands can work)
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

#===================================
#        Applications Definition        
#===================================





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
    if { ("$val(nam)" == "wpan_demo1.nam") && ("$hasDISPLAY" == "1") } {
	    exec nam wpan_demo1.nam &
    }
}

puts "\nStarting Simulation..."
$ns_ run
