###################################################
#         Tree Based Mesh Routing (TBMR)          #
#                                                 #
#        Copyright (c) 2005 Samsung/CUNY          #
# - - - - - - - - - - - - - - - - - - - - - - - - #
#           Prepared by Jianliang Zheng           #
#            (zheng@ee.ccny.cuny.edu)             #
###################################################

# usage examples:
# -- TBMR:
#       ns tbmr_demo.tcl -nam none
#       ns tbmr_demo.tcl -nx 10 -ny 10 -pc 0 -nam none -trInterval 0.2 -rtType 1 -tdlsHops 4 -tdlsScen 1 -tdma 4 -masmTSC 14 -uniRREQ false
# -- AODV:
#       ns tbmr_demo.tcl -rp AODV -nam none
#       ns tbmr_demo.tcl -nx 10 -ny 10 -pc 0 -rp AODV -nam none -trInterval 0.2 -tdma 4 -masmTSC 14

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
set val(ifqlen)         100                        ;# max packet in ifq
set val(nx)             10                         ;# x dimension
set val(ny)             10                         ;# y dimension
set val(pc)             auto                       ;# PAN coordinator
set val(rp)             TBMR                       ;# TBMR Routing
set val(rtType)         1                          ;# routing type (0 -- ART; 1 -- MART; 2 -- MART + AODV; 3 -- TDLS)
set val(tdlsHops)       4                          ;# hops TDLS covers
set val(tdlsScen)       0                          ;# special TDLS scenario
set val(tdma)           2                          ;# 0 -- no TDMA; 1 -- routing layer TDMA; 2 -- routing layer TDMA (only used in retransmissions); 3 -- MAC layer TDMA; 4 -- MASM
set val(masmTSC)        70                         ;# time slot cycle of MASM
set val(uniRREQ)        true                       ;# send unicast RREQ? (true/false)

set val(rndSeed)        100                        ;# random seed for traffic pairs

set val(errRate)	0                          ;# %
set val(traffic)	cbr                        ;# cbr/poisson/ftp
set val(trInterval)	1                          ;# in seconds
set val(trLenFactor)    1                          ;# duration of each traffic flow is $val(trLenFactor) * $val(nn)

set val(tr)             default
set val(nam)		default

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

set val(nn)             [expr $val(nx) * $val(ny)] ;# number of nodes
set val(x)		[expr $val(nx) * 10]
set val(y)		[expr $val(ny) * 10]

if { "$val(tr)" == "default" } {
	set val(tr)		tbmr_demo_$val(rp).tr
}
if { "$val(nam)" == "default" } {
	set val(nam)		tbmr_demo_$val(rp).nam
}

#set artTime         	100								;# in seconds 
set appTime         	200								;# in seconds 
#we limit the total traffic flows during a simulation run to 180 so that the running time is not too long
if { $val(nn) > 360 } {
	set totflows 180
} else {
	set totflows [expr $val(nn) / 2]
}
set grace [expr $val(trLenFactor) * $val(nn) / 10] 
set stopTime            [expr $appTime + $val(trLenFactor) * $totflows * 2 + $grace + 100]	;# in seconds 

# Before doing anything, generate some random values that will be same to both TBMR and AODV
for {set i 0} {$i < $val(nn)} {incr i} {
	set flag($i) 0
}
ns-random $val(rndSeed)		;# set random seed
for {set i 0} {$i < $val(nn)} {incr i} {
	set tf 1
	while {$tf == "1"} {
		set rnd($i) [ns-random]
		eval set tmp \$rnd($i)
		set rnd($i) [expr $tmp % $val(nn)]
		eval set tmp \$rnd($i)
		set tf [eval expr \$flag($tmp)]
		if { $i > 0 } {
			set j [expr $i - 1]
			eval set tmp2 \$rnd($j)
			if { $tmp == $tmp2 } {
				set tf 1
			}
		}
	}
	#set flag($s) 1
}

# Initialize Global Variables
set ns_		[new Simulator]
set tracefd     [open ./$val(tr) w]
$ns_ trace-all $tracefd
if { "$val(nam)" == "tbmr_demo_$val(rp).nam" } {
        set namtrace     [open ./$val(nam) w]
        $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
}

$ns_ puts-nam-traceall {# nam4wpan #}		;# inform nam that this is a trace file for wpan (special handling needed)

Mac/802_15_4 wpanCmd verbose on
Mac/802_15_4 wpanNam namStatus on		;# default = off (should be turned on before other 'wpanNam' commands can work)
#Mac/802_15_4 wpanNam ColFlashClr gold		;# default = gold
#Mac/802_15_4 wpanNam NodeFailClr grey		;# default = grey
Mac/802_15_4 wpanNam CoorClr tan3		;# default = blue

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

# For model 'Shadowing' (path loss exp 2, shadowing deviation 4)
set dist_sh(5m)  1.69063e-06
set dist_sh(9m)  5.218e-07
set dist_sh(10m) 4.22658e-07
set dist_sh(11m) 3.49304e-07
set dist_sh(12m) 2.93512e-07
set dist_sh(13m) 2.50093e-07
set dist_sh(14m) 2.15642e-07
set dist_sh(15m) 1.87848e-07
set dist_sh(16m) 1.65101e-07
set dist_sh(20m) 1.05664e-07
set dist_sh(25m) 6.76252e-08
set dist_sh(30m) 4.6962e-08
set dist_sh(35m) 3.45027e-08
set dist_sh(40m) 2.64161e-08

Phy/WirelessPhy set CSThresh_ $dist(12m)
Phy/WirelessPhy set RXThresh_ $dist(12m)

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

# Create God
set god_ [create-god $val(nn)]

set chan_1_ [new $val(chan)]

# configure node

if { "$val(tr)" == "tbmr_demo_$val(rp).tr" } {
	set aTrace ON
	set rTrace ON
	set mTrace ON
	set mvTrace OFF
} else {
	set aTrace OFF
	set rTrace OFF
	set mTrace OFF
	set mvTrace OFF
}
$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace $aTrace \
		-routerTrace $rTrace \
		-macTrace $mTrace \
		-movementTrace $mvTrace \
                #-energyModel "EnergyModel" \
                #-initialEnergy 1 \
                #-rxPower 0.3 \
                #-txPower 0.3 \
		-channel $chan_1_

# insert error model
if {$val(errRate) != 0} {
	$ns_ node-config -errProc UniformErr
}

proc UniformErr {} {
        set err [new ErrorModel]
        $err unit pkt 
        $err set rate_ [expr $val(errRate) / 100.0]
        #$err drop-target [new Agent/Null]
        return $err
}

for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0		;# disable random motion
}


# source ./tbmr_demo.scn
set DIMENSIONX $val(nx) 
set DIMENSIONY $val(ny) 
set lft 5.0
set top [expr $val(y) - 5.0]
set n_idx 0
for {set j 0} {$j < $DIMENSIONY} {incr j} {
for {set i 0} {$i < $DIMENSIONX} {incr i} {
	eval \$node_($n_idx) set X_ [expr $lft+$i*10.0]
	eval \$node_($n_idx) set Y_ [expr $top-$j*10.0]
	eval \$node_($n_idx) set Z_ 0.0
	incr n_idx;
}
}

if { "$val(rp)" == "TBMR" } {
	#Agent/TBMR verbose on				;# default on
	Agent/TBMR RoutingType $val(rtType)		;# routing type
	Agent/TBMR uniRREQ $val(uniRREQ)		;# send unicast RREQ or not
	Agent/TBMR TDLSHops $val(tdlsHops)		;# hops TDLS covers
	Agent/TBMR TDMA $val(tdma)			;# use TDMA or not
	#puts [format "TDMA: %s" [Agent/TBMR TDMA]]
	Agent/TBMR MASMTSC $val(masmTSC)		;# set time slot cycle of MASM
	#puts [format "MASMTSC: %s" [Agent/TBMR MASMTSC]]
	Mac/802_15_4 wpanCmd callBack 2	;# 0=none; 1=failure only (default); 2=both failure and success

	Agent/TBMR tbmrRouting				;# set variable tbmrRouting to 1

	set rv [new RandomVariable/Uniform]
	$rv set min_ 1
	$rv set max_ 5
	if { "$val(pc)" == "auto" } {
		if { [expr $val(ny) % 2] == 1 } {
			set row [expr ($val(ny) - 1) / 2]
		} else {
			set row [expr $val(ny) / 2 -1]
		}
		if { [expr $val(nx) % 2] == 1 } {
			set col [expr ($val(nx) - 1) / 2]
		} else {
			set col [expr $val(nx) / 2 -1]
		}
		set pc [expr $row * $val(nx) + $col]
	} else {
		set pc $val(pc)
	}

	$ns_ at 0.0	"\$node_($pc) NodeLabel \"PC\""
	$ns_ at 0.0	"\$node_($pc) sscs startPANCoord 0"	;# startPANCoord <txBeacon=1> <BO=3> <SO=3>
	for {set i 0} {$i < $pc} {incr i} {
		$ns_ at [$rv value]	"$node_($i) sscs startDevice"  	;# startDevice <isFFD=1> <assoPermit=1> <txBeacon=0> <BO=3> <SO=3>
	}
	for {set i [expr $pc + 1]} {$i < $val(nn)} {incr i} {
		$ns_ at [$rv value]	"$node_($i) sscs startDevice"  	;# startDevice <isFFD=1> <assoPermit=1> <txBeacon=0> <BO=3> <SO=3>
	}

	#$ns_ at $artTime "Mac/802_15_4 wpanCmd stopAsso"
	#$ns_ at $artTime "Agent/TBMR buildARTT"	;# no need to call buildARTT -- it will be done automatically
} else {
	Agent/AODV TDMA $val(tdma)			;# use TDMA at routing layer (default true)
	#puts [format "TDMA: %s" [Agent/AODV TDMA]]
	Agent/AODV MASMTSC $val(masmTSC)		;# set time slot cycle of MASM
	#puts [format "MASMTSC: %s" [Agent/AODV MASMTSC]]
}

Mac/802_15_4 wpanNam PlaybackRate 12ms
#$ns_ at $appTime "Mac/802_15_4 wpanNam PlaybackRate 1.0ms"
#$ns_ at [expr $appTime + 0.5] "Mac/802_15_4 wpanNam PlaybackRate 2.0ms"

$ns_ at $appTime "puts \"\n\nTransmitting data ...\n\""
$ns_ at $appTime "$ns_ trace-annotate \"(at $appTime) Transmitting data ...\""

# Setup traffic flow between nodes

proc cbrtraffic { src dst interval starttime stoptime } {
   global ns_ node_
   set udp_($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp_($src)
   set null_($dst) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null_($dst)
   set cbr_($src) [new Application/Traffic/CBR]
   eval \$cbr_($src) set packetSize_ 94		;# this will result in a max PPDU of 127 bytes
   eval \$cbr_($src) set interval_ $interval
   eval \$cbr_($src) set random_ 0
   #eval \$cbr_($src) set maxpkts_ 10000
   eval \$cbr_($src) attach-agent \$udp_($src)
   eval $ns_ connect \$udp_($src) \$null_($dst)
   $ns_ at $starttime "$cbr_($src) start"
   $ns_ at $stoptime "$cbr_($src) stop"
}

proc poissontraffic { src dst interval starttime stoptime } {
   global ns_ node_
   set udp($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp($src)
   set null($dst) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null($dst)
   set expl($src) [new Application/Traffic/Exponential]
   eval \$expl($src) set packetSize_ 94		;# this will result in a max PPDU of 127 bytes
   eval \$expl($src) set burst_time_ 0
   eval \$expl($src) set idle_time_ [expr $interval*1000.0-70.0*8/250]ms	;# idle_time + pkt_tx_time = interval
   eval \$expl($src) set rate_ 250k
   eval \$expl($src) attach-agent \$udp($src)
   eval $ns_ connect \$udp($src) \$null($dst)
   $ns_ at $starttime "$expl($src) start"
   $ns_ at $stoptime "$expl($src) stop"
}

proc ftptraffic { src dst starttime stoptime } {
   global ns_ node_
   set tcp($src) [new Agent/TCP]
   eval \$tcp($src) set packetSize_ 60		;# tcp packet size changes -- something is wrong with tcp?
   set sink($dst) [new Agent/TCPSink]
   eval $ns_ attach-agent \$node_($src) \$tcp($src)
   eval $ns_ attach-agent \$node_($dst) \$sink($dst)
   eval $ns_ connect \$tcp($src) \$sink($dst)
   set ftp($src) [new Application/FTP]
   eval \$ftp($src) attach-agent \$tcp($src)
   $ns_ at $starttime "$ftp($src) start"
   $ns_ at $stoptime "$ftp($src) stop"
}

if { ("$val(traffic)" == "cbr") || ("$val(traffic)" == "poisson") } {
   $ns_ at $appTime "puts \"\nTraffic: $val(traffic)\n\""
   $ns_ at $appTime "$ns_ trace-annotate \"(at $appTime) Traffic: $val(traffic)\""
   #Mac/802_15_4 wpanCmd ack4data on
   #puts [format "Acknowledgement for data: %s" [Mac/802_15_4 wpanCmd ack4data]]

   set trafficName $val(traffic)

   if { ("$val(tdlsScen)" == "0") } {
	set pairs [expr $val(nn) / 2]
	for {set i 0} {$i < $totflows} {incr i} {
		set six [expr 2 * $i]
		set dix [expr 2 * $i + 1]
		eval set s \$rnd($six)
		eval set d \$rnd($dix)
		set t [expr $appTime + 2 * $i * $val(trLenFactor)]
		#${trafficName}traffic $s $d 6 $t [expr $t + 5]		;# send one packet only to trigger route discovery
		set sn [format "%3d" [expr $i + 1]]
		$ns_ at $t "puts \"\t$sn: at $t: start traffic from $s to $d\""
		$ns_ at $t "$ns_ trace-annotate \"(at $t) start traffic from $s to $d\""
		#set t [expr $t + 6]
		${trafficName}traffic $s $d $val(trInterval) $t [expr $t + 2 * $val(trLenFactor) * $pairs / 10]
	}
   } else {
   	set s 0
   	set d [expr $s + $val(nx) - 1]
	Mac/802_15_4 wpanNam FlowClr -p cbr -s $s -d $d -c brown4
	Mac/802_15_4 wpanNam FlowClr -p exp -s $s -d $d -c brown4
	set t $appTime
	$ns_ at $t "puts \"\tat $t: start traffic from $s to $d\""
	$ns_ at $t "$ns_ trace-annotate \"(at $t) start traffic from $s to $d\""
	${trafficName}traffic $s $d $val(trInterval) $t [expr $t + $val(nn) / 2]
   	set s [expr ($val(ny) - 1) * $val(nx)]
   	set d [expr $s + $val(nx) - 1]
	Mac/802_15_4 wpanNam FlowClr -p cbr -s $s -d $d -c brown4
	Mac/802_15_4 wpanNam FlowClr -p exp -s $s -d $d -c brown4
	$ns_ at $t "puts \"\tat $t: start traffic from $s to $d\""
	$ns_ at $t "$ns_ trace-annotate \"(at $t) start traffic from $s to $d\""
	${trafficName}traffic $s $d $val(trInterval) $t [expr $t + $val(nn) / 2]
	# following node failure demo is good for (nx = 10; ny = 10; tdlsHops = 3)
	$ns_ at [expr $t + 5.0] "$node_(24) node-down"
	$ns_ at [expr $t + 20.0] "$node_(24) node-up"
	$ns_ at [expr $t + 10.0] "$node_(75) node-down"
	$ns_ at [expr $t + 25.0] "$node_(75) node-up"
        set tmpTime [format "%.2f" [expr $t + 5.0]]
        $ns_ at [expr $t + 5.0] "$ns_ trace-annotate \"(at $tmpTime) node down: 24\""
        set tmpTime [format "%.2f" [expr $t + 20.0]]
        $ns_ at [expr $t + 20.0] "$ns_ trace-annotate \"(at $tmpTime) node up: 24\""
        set tmpTime [format "%.2f" [expr $t + 10.0]]
        $ns_ at [expr $t + 10.0] "$ns_ trace-annotate \"(at $tmpTime) node down: 75\""
        set tmpTime [format "%.2f" [expr $t + 25.0]]
        $ns_ at [expr $t + 25.0] "$ns_ trace-annotate \"(at $tmpTime) node up: 75\""
   }

   Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c green
   Mac/802_15_4 wpanNam FlowClr -p MAC -c navy
}

if { "$val(traffic)" == "ftp" } {
   $ns_ at $appTime "puts \"\nTraffic: $val(traffic)\n\""
   $ns_ at $appTime "$ns_ trace-annotate \"(at $appTime) Traffic: $val(traffic)\""
   #Mac/802_15_4 wpanCmd ack4data off
   #puts [format "Acknowledgement for data: %s" [Mac/802_15_4 wpanCmd ack4data]]

   if { ("$val(tdlsScen)" == "0") } {
	set pairs [expr $val(nn) / 2]
	for {set i 0} {$i < $totflows} {incr i} {
		set six [expr 2 * $i]
		set dix [expr 2 * $i + 1]
		eval set s \$rnd($six)
		eval set d \$rnd($dix)
		set t [expr $appTime + 2 * $i * $val(trLenFactor)]
		ftptraffic $s $d $t [expr $t + 2 * $pairs * $val(trLenFactor) / 10]
		set sn [format "%3d" [expr $i + 1]]
		$ns_ at $t "puts \"\t$sn: at $t: start traffic from $s to $d\""
		$ns_ at $t "$ns_ trace-annotate \"(at $t) start traffic from $s to $d\""
	}
   } else {
   	set s 0
   	set d [expr $s + $val(nx) - 1]
	Mac/802_15_4 wpanNam FlowClr -p tcp -s $s -d $d -c brown4
	Mac/802_15_4 wpanNam FlowClr -p ack -s $s -d $d -c green4
	set t $appTime
	$ns_ at $t "puts \"\tat $t: start traffic from $s to $d\""
	$ns_ at $t "$ns_ trace-annotate \"(at $t) start traffic from $s to $d\""
	ftptraffic $s $d $t [expr $t + $val(nn) / 2]
   	set s [expr ($val(ny) - 1) * $val(nx)]
   	set d [expr $s + $val(nx) - 1]
	Mac/802_15_4 wpanNam FlowClr -p tcp -s $s -d $d -c brown4
	Mac/802_15_4 wpanNam FlowClr -p ack -s $s -d $d -c green4
	$ns_ at $t "puts \"\tat $t: start traffic from $s to $d\""
	$ns_ at $t "$ns_ trace-annotate \"(at $t) start traffic from $s to $d\""
	ftptraffic $s $d $t [expr $t + $val(nn) / 2]
	# following node failure demo is good for (nx = 10; ny = 10; tdlsHops = 3)
	$ns_ at [expr $t + 5.0] "$node_(24) node-down"
	$ns_ at [expr $t + 20.0] "$node_(24) node-up"
	$ns_ at [expr $t + 10.0] "$node_(75) node-down"
	$ns_ at [expr $t + 25.0] "$node_(75) node-up"
        set tmpTime [format "%.2f" [expr $t + 5.0]]
        $ns_ at [expr $t + 5.0] "$ns_ trace-annotate \"(at $tmpTime) node down: 24\""
        set tmpTime [format "%.2f" [expr $t + 20.0]]
        $ns_ at [expr $t + 20.0] "$ns_ trace-annotate \"(at $tmpTime) node up: 24\""
        set tmpTime [format "%.2f" [expr $t + 10.0]]
        $ns_ at [expr $t + 10.0] "$ns_ trace-annotate \"(at $tmpTime) node down: 75\""
        set tmpTime [format "%.2f" [expr $t + 25.0]]
        $ns_ at [expr $t + 25.0] "$ns_ trace-annotate \"(at $tmpTime) node up: 75\""
   }

   Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
   Mac/802_15_4 wpanNam FlowClr -p ARP -c green
   Mac/802_15_4 wpanNam FlowClr -p MAC -c navy
}

# defines the node size in nam
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 3
}

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $stopTime "$node_($i) reset";
}

$ns_ at $appTime "initxt"

$ns_ at $stopTime "stop"
$ns_ at $stopTime "puts \"\nNS EXITING...\n\""
$ns_ at $stopTime "$ns_ halt"

set totIniTxT 0.0
proc initxt {} {
	global totIniTxT
	set totIniTxT [Mac/802_15_4 wpanCmd totTxT]
}

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
    if { ("$val(nam)" == "tbmr_demo_$val(rp).nam") && ("$hasDISPLAY" == "1") } {
    	exec nam tbmr_demo_$val(rp).nam &
    }
}

puts "\nStarting Simulation..."
$ns_ run
