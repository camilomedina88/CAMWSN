###########################################
#           AODV over 802.15.4            #
#     Copyright (c) 2003 Samsung/CUNY     #
# - - - - - - - - - - - - - - - - - - - - #
#       Prepared by Jianliang Zheng       #
#        (zheng@ee.ccny.cuny.edu)         #
###########################################

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
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             25                         ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)		50
set val(y)		50

set val(nam)		wpan_demo1.nam
set val(traffic)	ftp                        ;# cbr/poisson/ftp

# =================================================


set val(dataStart)  1000.0
set val(dataStop)   2000.0
set val(signalStop) 2005.0
set val(finish)     2010.0
# =================================================


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

set appTime1            0.0	;# in seconds 
set appTime2            0.3	;# in seconds 
set appTime3            0.7	;# in seconds 
set stopTime            100	;# in seconds 


# =====================================================================
# 	This puts in only the headers that we need.   
# =====================================================================
remove-all-packet-headers
add-packet-header IP 
add-packet-header TCP 
add-packet-header Common 
add-packet-header LAR
add-packet-header AODV
add-packet-header Flags
add-packet-header LL
add-packet-header Mac



# ======================================================================
# Main Program
# ======================================================================

# Initialize Global Variables
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
                #-energyModel "EnergyModel" \
                #-initialEnergy 1 \
                #-rxPower 0.3 \
                #-txPower 0.3 \
		-channel $chan_1_ 

for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
}

source ./wpan_demo1.scn

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
   #eval \$cbr($src) set maxpkts_ 10000
   eval \$cbr($src) attach-agent \$udp($src)
   eval $ns_ connect \$udp($src) \$null($dst)
   $ns_ at $starttime "$cbr($src) start"
}

proc poissontraffic { src dst interval starttime } {
   global ns_ node_
   set udp($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp($src)
   set null($dst) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null($dst)
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
   set lowSpeed 0.5ms
   set highSpeed 1.5ms
   Mac/802_15_4 wpanNam PlaybackRate $lowSpeed
   $ns_ at [expr $appTime1+0.1] "Mac/802_15_4 wpanNam PlaybackRate $highSpeed"
   $ns_ at $appTime2 "Mac/802_15_4 wpanNam PlaybackRate $lowSpeed"
   $ns_ at [expr $appTime2+0.1] "Mac/802_15_4 wpanNam PlaybackRate $highSpeed"
   $ns_ at $appTime3 "Mac/802_15_4 wpanNam PlaybackRate $lowSpeed"
   $ns_ at [expr $appTime3+0.1] "Mac/802_15_4 wpanNam PlaybackRate $highSpeed"
   eval $val(traffic)traffic 19 6 0.2 $appTime1
   eval $val(traffic)traffic 10 4 0.2 $appTime2
   eval $val(traffic)traffic 3 2 0.2 $appTime3
   Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c green
   if { "$val(traffic)" == "cbr" } {
   	set pktType cbr
   } else {
   	set pktType exp
   }
   Mac/802_15_4 wpanNam FlowClr -p $pktType -s 19 -d 6 -c blue
   Mac/802_15_4 wpanNam FlowClr -p $pktType -s 10 -d 4 -c green4
   Mac/802_15_4 wpanNam FlowClr -p $pktType -s 3 -d 2 -c cyan4
   $ns_ at $appTime1 "$node_(19) NodeClr blue"
   $ns_ at $appTime1 "$node_(6) NodeClr blue"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) $val(traffic) traffic from node 19 to node 6\""
   $ns_ at $appTime2 "$node_(10) NodeClr green4"
   $ns_ at $appTime2 "$node_(4) NodeClr green4"
   $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime2) $val(traffic) traffic from node 10 to node 4\""
   $ns_ at $appTime3 "$node_(3) NodeClr cyan3"
   $ns_ at $appTime3 "$node_(2) NodeClr cyan3"
   $ns_ at $appTime3 "$ns_ trace-annotate \"(at $appTime3) $val(traffic) traffic from node 3 to node 2\""
}

proc ftptraffic { src dst starttime } {
   global ns_ node_
   set tcp($src) [new Agent/TCP]
   eval \$tcp($src) set packetSize_ 60
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
   set lowSpeed 0.20ms
   set highSpeed 1.5ms
   Mac/802_15_4 wpanNam PlaybackRate $lowSpeed
   $ns_ at [expr $appTime1+0.2] "Mac/802_15_4 wpanNam PlaybackRate $highSpeed"
   $ns_ at $appTime2 "Mac/802_15_4 wpanNam PlaybackRate $lowSpeed"
   $ns_ at [expr $appTime2+0.2] "Mac/802_15_4 wpanNam PlaybackRate $highSpeed"
   $ns_ at $appTime3 "Mac/802_15_4 wpanNam PlaybackRate $lowSpeed"
   $ns_ at [expr $appTime3+0.2] "Mac/802_15_4 wpanNam PlaybackRate 1ms"
   ftptraffic 19 6 $appTime1
   ftptraffic 10 4 $appTime2
   ftptraffic 3 2 $appTime3
   Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c green
   Mac/802_15_4 wpanNam FlowClr -p tcp -s 19 -d 6 -c blue
   Mac/802_15_4 wpanNam FlowClr -p ack -s 6 -d 19 -c blue
   Mac/802_15_4 wpanNam FlowClr -p tcp -s 10 -d 4 -c green4
   Mac/802_15_4 wpanNam FlowClr -p ack -s 4 -d 10 -c green4
   Mac/802_15_4 wpanNam FlowClr -p tcp -s 3 -d 2 -c cyan4
   Mac/802_15_4 wpanNam FlowClr -p ack -s 2 -d 3 -c cyan4
   $ns_ at $appTime1 "$node_(19) NodeClr blue"
   $ns_ at $appTime1 "$node_(6) NodeClr blue"
   $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) ftp traffic from node 19 to node 6\""
   $ns_ at $appTime2 "$node_(10) NodeClr green4"
   $ns_ at $appTime2 "$node_(4) NodeClr green4"
   $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime2) ftp traffic from node 10 to node 4\""
   $ns_ at $appTime3 "$node_(3) NodeClr cyan3"
   $ns_ at $appTime3 "$node_(2) NodeClr cyan3"
   $ns_ at $appTime3 "$ns_ trace-annotate \"(at $appTime3) ftp traffic from node 3 to node 2\""
}


# ===================================================
# #			LAR
# ===================================================
set val(sc)		wpan_demo1.scn
# Load the movement file
puts "Loading the mobility file..."
source ./wpan_demo1.scn

#Create lar agents and attach them to the nodes
puts "creating lar agents and attaching them to nodes..."
for {set i 0} {$i < $val(nn)} {incr i} {
  set g($i) [new Agent/LAR]
  $node_($i) attach $g($i) 254

  # need to tell the lar agents about their link layers
  set ll($i) [$node_($i) set ll_(0)]
  $ns_ at 0.0 "$g($i) set-ll $ll($i)"

  # need to tell the lar agents which nodes they're on also
  $ns_ at 0.0 "$g($i) set-node $node_($i)"
}

# the format now for the lar send is
#
# "$nodeId sendData <dest ID> <size> <method>"
#
# this will be used to test in a static configuration, and will
# change once the mobility portion is figured out.
#Schedule events

puts "Scheduling the send events"
for {set k $val(dataStart)} {$k < $val(dataStop)} {set k [expr $k + 0.25] } \
{
  $ns_ at $k "$g(0) sendData 49 64 B"
  $ns_ at [expr $k + .0001] "$g(1) sendData 48 64 B"
  $ns_ at [expr $k + .0002] "$g(2) sendData 47 64 B"
  $ns_ at [expr $k + .0003] "$g(3) sendData 46 64 B"
  $ns_ at [expr $k + .0004] "$g(4) sendData 45 64 B"
  $ns_ at [expr $k + .0005] "$g(5) sendData 44 64 B"
  $ns_ at [expr $k + .0006] "$g(6) sendData 43 64 B"
  $ns_ at [expr $k + .0007] "$g(7) sendData 42 64 B"
  $ns_ at [expr $k + .0008] "$g(8) sendData 41 64 B"
  $ns_ at [expr $k + .0009] "$g(9) sendData 40 64 B"
  $ns_ at [expr $k + .0010] "$g(10) sendData 39 64 B"
  $ns_ at [expr $k + .0011] "$g(11) sendData 38 64 B"
  $ns_ at [expr $k + .0012] "$g(12) sendData 37 64 B"
  $ns_ at [expr $k + .0013] "$g(13) sendData 36 64 B"
  $ns_ at [expr $k + .0014] "$g(14) sendData 35 64 B"
  $ns_ at [expr $k + .0015] "$g(15) sendData 34 64 B"
  $ns_ at [expr $k + .0016] "$g(16) sendData 33 64 B"
  $ns_ at [expr $k + .0017] "$g(17) sendData 32 64 B"
  $ns_ at [expr $k + .0018] "$g(18) sendData 31 64 B"
  $ns_ at [expr $k + .0019] "$g(19) sendData 30 64 B"
}
# ===========================================================


# defines the node size in nam
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 2
}

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
