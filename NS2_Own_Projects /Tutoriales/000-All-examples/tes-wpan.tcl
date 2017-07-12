#    	http://network-simulator-ns-2.7690.n7.nabble.com/LAR-Patch-td27351.html#a28680 ======================================================================
#      	https://drive.google.com/file/d/0B_mjg76roz4CbWZxTERSRzVsZW8/edit?usp=sharing
# Define options ======================================================================
set val(chan)	Channel/WirelessChannel	;# Channel Type
set val(prop)           	Propagation/TwoRayGround	;# radio-propagation model
set val(netif)          	Phy/WirelessPhy/802_15_4
set val(mac)            	Mac/802_15_4
set val(ifq)            	Queue/DropTail/PriQueue    	;# interface queue type
set val(ll)             	LL                         	;# link layer type
set val(ant)            	Antenna/OmniAntenna        	;# antenna model
set val(ifqlen)         	50                         	;# max packet in ifq
set val(nn)             	21                         	;# number of nodes
set val(rp)             	AODV                      	;# routing protocol AODV
set val(x)			300 
set val(y)			300
set val(nam)	 		aodv20.nam
set val(traffic)	 	cbr                        	;# cbr
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
set appTime1            2.0	;# in seconds 
set appTime2            2.1	;# in seconds 
set appTime3            2.2	;# in seconds 
set appTime4            2.3	;# in seconds 
set appTime5            2.4	;# in seconds 
set stopTime            100	;# in seconds 
# Initialize Global Variables
set ns_		[new Simulator]
set tracefd     [open ./aodv20.tr w]
$ns_ trace-all $tracefd
if { "$val(nam)" == "aodv20.nam" } {
        set namtrace     [open ./$val(nam) w]
        $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
}
Mac/802_15_4 put-nam-traceall (# nam4wpan #)	;# inform nam that this is a trace file for wpan (special handling needed)
Mac/802_15_4 wpanCmd verbose on
Mac/802_15_4 wpanNam namStatus on	;# default = off (should be turned on before other 'wpanNam' commands can work)
#Mac/802_15_4 wpanNam ColFlashClr gold	;# default = gold
Mac/802_15_4 wpanNam PANCoorClr tomato
Mac/802_15_4 wpanNam CoorClr blue
Mac/802_15_4 wpanNam DevClr green

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
Phy/WirelessPhy set CSThresh_ $dist(20m)
Phy/WirelessPhy set RXThresh_ $dist(20m)
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
	-agentTrace ON \
	-routerTrace ON \
	-macTrace ON \
	-movementTrace OFF \
               	 -energyModel EnergyModel \
                	-initialEnergy 1000 \
                	-rxPower 0.1 \
                	-txPower 0.1\
	-channel $chan_1_ 
for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0	 ;# disable random motion
}

source ./kordinat_20_20.scn

$ns_ at 0.0	"$node_(0) NodeLabel Zigbee Coordinator"
$ns_ at 0.0	"$node_(0) sscs startPANCoord 1"		
$ns_ at 0.4	"$node_(1) sscs startDevice 1 1 1" 		
$ns_ at 0.5	"$node_(2) sscs startDevice 1 1 1"
$ns_ at 0.6	"$node_(3) sscs startDevice 1 1 1"
$ns_ at 0.7	"$node_(4) sscs startDevice 1 1 1"
$ns_ at 0.8	"$node_(5) sscs startDevice 1 1 1"
$ns_ at 0.9	"$node_(6) sscs startDevice 1 1 1"
$ns_ at 1.0	"$node_(7) sscs startDevice 1 1 1"
$ns_ at 1.1	"$node_(8) sscs startDevice 1 1 1"
$ns_ at 1.5	"$node_(9) sscs startDevice 0"
$ns_ at 1.5	"$node_(10) sscs startDevice 0"
$ns_ at 1.6	"$node_(11) sscs startDevice 0"
$ns_ at 1.6	"$node_(12) sscs startDevice 0"
$ns_ at 1.7	"$node_(13) sscs startDevice 0"
$ns_ at 1.7	"$node_(14) sscs startDevice 0"
$ns_ at 1.8	"$node_(15) sscs startDevice 0"
$ns_ at 1.8	"$node_(16) sscs startDevice 0"
$ns_ at 1.9	"$node_(17) sscs startDevice 0"
$ns_ at 1.9	"$node_(18) sscs startDevice 0"
$ns_ at 1.9	"$node_(19) sscs startDevice 0"
$ns_ at 1.9	"$node_(20) sscs startDevice 0"
Mac/802_15_4 wpanNam PlaybackRate 3ms
$ns_ at $appTime1 "puts \"\nTransmitting data ...\n\""
# Setup traffic flow between nodes
proc cbrtraffic { src dst interval starttime } {
   global ns_ node_
   set udp_($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp_($src)
   set null_($dst) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null_($dst)
   set cbr_($src) [new Application/Traffic/CBR]
   eval \$cbr_($src) set packetSize_ 70
   eval \$cbr_($src) set rate_ 250k
   eval \$cbr_($src) set interval_ $interval
   eval \$cbr_($src) set random_ 0
   eval \$cbr_($src) attach-agent \$udp_($src)
   eval $ns_ connect \$udp_($src) \$null_($dst)
   $ns_ at $starttime "$cbr_($src) start"
}
if {"$val(traffic)" == "cbr"} {
   puts "\nTraffic: cbr"
   #Mac/802_15_4 wpanCmd ack4data on
   puts [format "Acknowledgement for data: %s" [Mac/802_15_4 wpanCmd ack4data]]
   $ns_ at $appTime1 "Mac/802_15_4 wpanNam PlaybackRate 0.50ms"
   $ns_ at [expr $appTime1 + 0.5] "Mac/802_15_4 wpanNam PlaybackRate 1.5ms"
   cbrtraffic 12 0 0.6 $appTime1
   cbrtraffic 16 0 0.6 $appTime1
   cbrtraffic 11 0 0.6 $appTime1
   cbrtraffic 15 0 0.6 $appTime1
   cbrtraffic 19 0 0.6 $appTime1
   $ns_ at 0.0 "$node_(0) add-mark m1 red circle"
   $ns_ at $appTime1 "$node_(12) add-mark m2 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 12 to node 0\""
   $ns_ at $appTime1 "$node_(16) add-mark m3 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 16 to node 0\""
   $ns_ at $appTime1 "$node_(11) add-mark m4 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 11 to node 0\""
   $ns_ at $appTime1 "$node_(15) add-mark m5 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 15 to node 0\""
   $ns_ at $appTime1 "$node_(19) add-mark m6 black circle"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) cbr traffic from node 19 to node 0\"" 
   $ns_ at 0.0 "$node_(1) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(2) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(3) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(4) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(5) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(6) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(7) add-mark m1 blue circle"
   $ns_ at 0.0 "$node_(8) add-mark m1 blue circle"      
   Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c black
   Mac/802_15_4 wpanNam FlowClr -p MAC -c navy
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 12 -d 0 -c blue
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 16 -d 0 -c green
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 11 -d 0 -c black
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 15 -d 0 -c red
   Mac/802_15_4 wpanNam FlowClr -p cbr -s 19 -d 0 -c navy
}
# defines the node size in nam
for {set i 0} {$i < $val(nn)} {incr i} {
     $ns_ initial_node_pos $node_($i) 3
}
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
    if { ("$val(nam)" == "aodv20.nam") && ("$hasDISPLAY" == "1") } {
    	exec nam aodv20.nam &
	exec awk -f tess.awk aodv20.tr &
	exec awk -f energy.awk aodv20.tr &
		    }
}
puts "\nStarting Simulation..."
$ns_ run

