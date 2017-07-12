#
# Copyright (c) 2012 Regents of the SIGNET lab, University of Padova.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the University of Padova (SIGNET lab) nor the 
#    names of its contributors may be used to endorse or promote products 
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# This script is used to test UWALOHA protocol
# There are 25 nodes placed on the seafloor in a square of 5x5 nodes at a depth of
# 1000 m and an AUV that patrols the network at a depth of 600 m retreiving data packets
# making a trajectory described in the WayPoints
#
# N.B.: This Example require WOSS installed for the UnderwaterChannel and positioning
#
# Author: Federico Favaro
# Version: 1.0.0
#
# NOTE: tcl sample tested on Ubuntu 11.10, 64 bits OS
#
# Stack of the nodes
#   +-------------------------+
#   |  7. UW/CBR              |
#   +-------------------------+
#   |  6. UW/UDP              |
#   +-------------------------+
#   |  5. UW/STATICROUTING    |
#   +-------------------------+
#   |  4. UW/IP               |
#   +-------------------------+
#   |  3. UW/MLL              |
#   +-------------------------+
#   |  2. UW/ALOHA            |
#   +-------------------------+
#   |  1. MPHY/BPSK/Underwater|
#   +-------------------------+
#           |         |    
#   +-------------------------+
#   |    UnderwaterChannel    |
#   +-------------------------+

######################################
# Flags to enable or disable options #
######################################
set opt(verbose) 			0
set opt(trace_files)		0
set opt(bash_parameters) 	0

#####################
# Library Loading   #
#####################
load libMiracle.so
load libmphy.so
load libmmac.so
load libMiracleBasicMovement.so
load libUwmStd.so
load libWOSS.so
load libWOSSPhy.so
load libuwip.so
load libuwstaticrouting.so
load libuwmll.so
load libuwudp.so
load libuwcbr.so
load libuwsr.so


#############################
# NS-Miracle initialization #
#############################
set ns [new Simulator]
$ns use-Miracle

##################
# Tcl variables  #
##################

set opt(start_clock) [clock seconds]


set opt(start_lat)      41.90    ;#starting Latitude 
set opt(start_long)       17.51    ;#starting Longitude
set opt(nn)         25.0    ;#Number of nodes
set opt(pktsize)      125     ;# Size of the packet in Bytes
set opt(stoptime)         214000  
set opt(dist_nodes)     1000.0  ;# Distace of the nodes in m
set opt(nn_in_row)      5       ;# Number of a nodes in m
set opt(ack_mode)     "setNoAckMode"
set opt(knots)            4       ;# speed of the AUV in knots
set opt(speed)            [expr $opt(knots) * 0.51444444444] ;# speed of the AUV in m/s

set rng [new RNG]
if {$opt(bash_parameters)} {
	if {$argc != 2} {
		puts "Tcl example need two parameters"
		puts "- The first for seed"
		puts "- The second for CBR period"
		puts "For example, ns test_uw_csma_aloha.tcl 4 100"
    puts "If you want to leave the default values, please set to 0"
    puts "the value opt(bash_parameters) in the tcl script"
		puts "Please try again."
	} else { 
		$rng seed 					[lindex $argv 0]
		set opt(rep_num)			[lindex $argv 0]
		set opt(cbr_period)	 		[lindex $argv 1]
	}
} else {
	$rng seed 			1
	set opt(rep_num) 	1
	set opt(cbr_period)	100
}

set opt(cbrpr) [expr int($opt(cbr_period))]
set opt(rnpr)  [expr int($opt(rep_num))]
set opt(apr)   "a"

if {$opt(ack_mode) == "setNoAckMode"} {
   set opt(apr)  "na" 
}
set opt(starttime)       	0.1
set opt(txduration)     	[expr $opt(stoptime) - $opt(starttime)]
set opt(extra_time)			250.0

#PHY PARAMETERS:
# TO BE VERIFIED

set opt(txpower)	 		150
set opt(per_tgt)	 		0.1
set opt(rx_snr_penalty_db)	0.0
set opt(tx_margin_db)		0.0

set opt(node_min_angle)		-90.0
set opt(node_max_angle)		90.0
set opt(sink_min_angle)		-90.0
set opt(sink_max_angle) 	90.0
set opt(node_bathy_offset)	-2.0

set opt(maxinterval_)    	10.0
set opt(freq) 				25000.0
set opt(bw)              	5000.0
set opt(bitrate)	 		4800.0


for {set id 0} {$id < 8} {incr id} {
  set position_waypoint_auv($id) [new "WOSS/Position/WayPoint"]
}



########################
#     TRACE FILES      #
########################
if {$opt(trace_files)} {
	
	set opt(tracefilename) "./uw_csma_aloha.tr"
	set opt(tracefile) [open $opt(tracefilename) w]
	set opt(cltracefilename) "./uw_csma_aloha.cltr"
	set opt(cltracefile) [open $opt(cltracefilename) w]
} else {
	set opt(tracefilename) "/dev/null"
	set opt(tracefile) [open $opt(tracefilename) w]
	set opt(cltracefilename) "/dev/null/"
	set opt(cltracefile) [open $opt(cltracefilename) w]
}

###########################
#Random Number Generators #
###########################

global def_rng
set def_rng [new RNG]
$def_rng default

for {set k 0} {$k < $opt(rep_num)} {incr k} {
     $def_rng next-substream
}

#########################
# Module Configuration  #
#########################

WOSS/Utilities set debug 0
set woss_utilities [new WOSS/Utilities]


set woss_utilities [new "WOSS/Utilities"]
WOSS/Manager/Simple set debug 0
WOSS/Manager/Simple set space_sampling 0.0
set woss_manager [new "WOSS/Manager/Simple"]


set channel [new Module/UnderwaterChannel]
set propagation [new MPropagation/Underwater]

set data_mask [new MSpectralMask/Rect]
$data_mask setFreq       $opt(freq)
$data_mask setBandwidth  $opt(bw)

Module/CBR set debug_		    0
Module/CBR set packetSize_          $opt(pktsize)
Module/CBR set period_              $opt(cbr_period)
Module/CBR set PoissonTraffic_      1


#PHY BPSK
WOSS/Module/MPhy/BPSK  set debug_                     0
WOSS/Module/MPhy/BPSK  set bitrate_                   $opt(bitrate)
WOSS/Module/MPhy/BPSK  set AcquisitionThreshold_dB_   5.0 
WOSS/Module/MPhy/BPSK  set RxSnrPenalty_dB_           $opt(rx_snr_penalty_db)
WOSS/Module/MPhy/BPSK  set TxSPLMargin_dB_            $opt(tx_margin_db)
WOSS/Module/MPhy/BPSK  set MaxTxSPL_dB_               $opt(txpower)
WOSS/Module/MPhy/BPSK  set MinTxSPL_dB_               10
WOSS/Module/MPhy/BPSK  set MaxTxRange_                50000
WOSS/Module/MPhy/BPSK  set PER_target_                $opt(per_tgt)
WOSS/Module/MPhy/BPSK  set CentralFreqOptimization_   0
WOSS/Module/MPhy/BPSK  set BandwidthOptimization_     0
WOSS/Module/MPhy/BPSK  set SPLOptimization_           0

WOSS/Position/WayPoint set time_threshold_            [expr 1.0 / $opt(speed)]
WOSS/Position/WayPoint set compDistance_              0.0
WOSS/Position/WayPoint set verticalOrientation_       0.0
WOSS/Position/WayPoint set minVerticalOrientation_    -40.0
WOSS/Position/WayPoint set maxVerticalOrientation_    40.0


################################
# Procedure(s) to create nodes #
################################


proc createNode { id } {
    
    global channel propagation data_mask ns cbr position node port portnum ipr ipif channel_estimator
    global phy_data posdb opt rvposx rvposy rvposz mhrouting mll mac woss_utilities woss_creator db_manager
    global row
    
    set node($id) [$ns create-M_Node $opt(tracefile) $opt(cltracefile)]

    set cbr($id)  [new Module/UW/CBR] 
    set port($id) [new Module/UW/UDP]
    set ipr($id)  [new Module/UW/StaticRouting]
    set ipif($id) [new Module/UW/IP]
    set mll($id)  [new Module/UW/MLL] 
    set mac($id)  [new Module/UW/USR]
    set phy_data($id)  [new WOSS/Module/MPhy/BPSK]


    $node($id)  addModule 7 $cbr($id)   1  "CBR"
    $node($id)  addModule 6 $port($id)  1  "PRT"
    $node($id)  addModule 5 $ipr($id)   1  "IPR"
    $node($id)  addModule 4 $ipif($id)  1  "IPF"   
    $node($id) addModule  3 $mll($id)   1  "MLL"
    $node($id)  addModule 2 $mac($id)   1  "MAC"
    $node($id)  addModule 1 $phy_data($id)   1  "PHY"

    $node($id) setConnection $cbr($id)   $port($id)  0
    $node($id) setConnection $port($id)  $ipr($id)   0
    $node($id) setConnection $ipr($id)   $ipif($id)  0
    $node($id) setConnection $ipif($id)  $mll($id)   0
    $node($id) setConnection $mll($id)   $mac($id)   0
    $node($id) setConnection $mac($id)   $phy_data($id)   1
    $node($id) addToChannel  $channel    $phy_data($id)   1


    set portnum($id) [$port($id) assignPort $cbr($id) ]

    $ipif($id) addr "1.0.0.${id}"

    set position($id) [new "WOSS/Position/WayPoint"]
    $node($id) addPosition $position($id)
    set posdb($id) [new "PlugIn/PositionDB"]
    $node($id) addPlugin $posdb($id) 20 "PDB"
    $posdb($id) addpos [$ipif($id) addr] $position($id)
     ##########################
     #  NODES PLACEMENT	      #
     ##########################
    set curr_x 0.0
    set curr_y 0.0
    if { $id < 5 } {
    	set curr_x [expr $opt(dist_nodes) * $id ]
    	set row 0
    	set curr_y  [expr $row * $opt(dist_nodes) ]
    } elseif { ($id >= 5)  &&  ($id < 10) } {
    	set curr_x  [expr ($id -($opt(nn)/5 )) * $opt(dist_nodes) ]
    	set row 1
    	set curr_y  [expr $row * $opt(dist_nodes) ]
    } elseif { ($id >= 10) && ($id < 15) } {
	set curr_x  [expr ($id -($opt(nn)/5 )*2) * $opt(dist_nodes) ]
    	set row 2
    	set curr_y  [expr $row * $opt(dist_nodes) ]
    } elseif { ($id >= 15) && ($id < 20) } {
	set curr_x  [expr ($id -($opt(nn)/5 )*3) * $opt(dist_nodes) ]
    	set row 3
    	set curr_y  [expr $row * $opt(dist_nodes) ]
    } elseif { ($id >= 20) && ($id < 25) } {
	set curr_x  [expr ($id -($opt(nn)/5 )*4) * $opt(dist_nodes) ]
    	set row 4
    	set curr_y  [expr $row * $opt(dist_nodes) ]
    }

    set curr_lat    [ $woss_utilities getLatfromDistBearing  $opt(start_lat) $opt(start_long) 180.0 $curr_y ]
    set curr_lon    [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) 90.0  $curr_x ]
    set curr_depth 1000
    puts "$curr_x $curr_y $curr_depth"

    
    $position($id) setLatitude_  $curr_lat
    $position($id) setLongitude_ $curr_lon
    $position($id) setAltitude_  [expr -1.0 * $curr_depth]


    puts "node $id at ([$position($id) getLatitude_], [$position($id) getLongitude_], [$position($id) getAltitude_]) , ([$position($id) getX_], [$position($id) getY_], [$position($id) getZ_])"


    set interf_data($id) [new "MInterference/MIV"]
    $interf_data($id) set maxinterval_ $opt(maxinterval_)
    $interf_data($id) set debug_       0


    
    $phy_data($id) setSpectralMask $data_mask
    $phy_data($id) setInterference $interf_data($id)
    $phy_data($id) setPropagation $propagation
    $phy_data($id) set debug_ 0


    $mac($id) initialize

}

proc createSink { } {
    global channel propagation smask data_mask ns cbr_sink position_sink node_sink port_sink portnum_sink interf_data_sink
    global phy_data_sink posdb_sink opt mll_sink mac_sink ipr_sink ipif_sink bpsk interf_sink channel_estimator
    global woss_utilities woss_creator
    global auv_curr_depth

    set node_sink [$ns create-M_Node $opt(tracefile) $opt(cltracefile)]

    for { set cnt 0} {$cnt < $opt(nn)} {incr cnt} {
	  set cbr_sink($cnt)  [new Module/UW/CBR] 
      }
    
    set port_sink      [new Module/UW/UDP]
    set ipr_sink       [new Module/UW/StaticRouting]
    set ipif_sink      [new Module/UW/IP]
    set mll_sink       [new Module/UW/MLL] 
    set mac_sink       [new Module/UW/USR]
    set phy_data_sink  [new WOSS/Module/MPhy/BPSK]

    for { set cnt 0} {$cnt < $opt(nn)} {incr cnt} {
	$node_sink addModule 7 $cbr_sink($cnt) 0 "CBR"
     }
     $node_sink addModule 6 $port_sink      0 "PRT"
     $node_sink addModule 5 $ipr_sink       0 "IPR"
     $node_sink addModule 4 $ipif_sink      0 "IPF"   
     $node_sink addModule 3 $mll_sink       0 "MLL"
     $node_sink addModule 2 $mac_sink       1 "MAC"
     $node_sink addModule 1 $phy_data_sink  1 "PHY"

     for { set cnt 0} {$cnt < $opt(nn)} {incr cnt} {
     $node_sink setConnection $cbr_sink($cnt)  $port_sink     	1   
      }
     $node_sink setConnection $port_sink $ipr_sink      	0
     $node_sink setConnection $ipr_sink  $ipif_sink       	0
     $node_sink setConnection $ipif_sink $mll_sink        	0 
     $node_sink setConnection $mll_sink  $mac_sink        	0
     $node_sink setConnection $mac_sink  $phy_data_sink   	1
     $node_sink addToChannel $channel    $phy_data_sink   	1

     for { set cnt 0} {$cnt < $opt(nn)} {incr cnt} {
       set portnum_sink($cnt) [$port_sink assignPort $cbr_sink($cnt)]
     }

     set auv_curr_depth 600
     
     set curr_lat    [ $woss_utilities getLatfromDistBearing  $opt(start_lat) $opt(start_long) 180.0 0 ]
     set curr_lon    [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) 90.0  1000 ]

     set position_sink [new "WOSS/Position/WayPoint"]
     $position_sink addStartWayPoint $curr_lat $curr_lon [expr -1.0 * $auv_curr_depth] $opt(speed) 0.0
     $node_sink addPosition $position_sink

    
     $ipif_sink addr "1.0.0.253"

    
      
     puts "node sink at ([$position_sink getLatitude_], [$position_sink getLongitude_], [$position_sink getAltitude_]) , ([$position_sink getX_], [$position_sink getY_], [$position_sink getZ_])"

     set interf_data_sink [new "MInterference/MIV"]
     $interf_data_sink set maxinterval_ $opt(maxinterval_)
     $interf_data_sink set debug_       0

     $phy_data_sink setSpectralMask     $data_mask
     $phy_data_sink setPropagation      $propagation
     $phy_data_sink setInterference     $interf_data_sink


     $mac_sink initialize

}

#############################
# CREATION OF THE WAYPOINTS #
#############################
proc createPositionWaypoints { } {
  global opt auv_curr_depth
  #global position_waipoint_auv
  global woss_utilities

  global position_waypoint_auv
  
  set curr_x 1000
  set curr_y 0
  set curr_lat    [ $woss_utilities getLatfromDistBearing  $opt(start_lat) $opt(start_long) 180.0 $curr_y ]
  set curr_lon    [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) 90.0  $curr_x ]
  $position_waypoint_auv(0) setLatitude_ $curr_lat
  $position_waypoint_auv(0) setLongitude_ $curr_lon
  $position_waypoint_auv(0) setAltitude_ [expr -1.0 * $auv_curr_depth] 
  ##########################################################################################################
  set curr_x 1000
  set curr_y 8000
  set curr_lat    [ $woss_utilities getLatfromDistBearing  $opt(start_lat) $opt(start_long) 180.0 $curr_y ]
  set curr_lon    [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) 90.0  $curr_x ]
  $position_waypoint_auv(1) setLatitude_ $curr_lat
  $position_waypoint_auv(1) setLongitude_ $curr_lon
  $position_waypoint_auv(1) setAltitude_ [expr -1.0 * $auv_curr_depth] 
  ##########################################################################################################
set curr_x 3000
  set curr_y 8000
  set curr_lat    [ $woss_utilities getLatfromDistBearing  $opt(start_lat) $opt(start_long) 180.0 $curr_y ]
  set curr_lon    [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) 90.0  $curr_x ]
  $position_waypoint_auv(2) setLatitude_ $curr_lat
  $position_waypoint_auv(2) setLongitude_ $curr_lon
  $position_waypoint_auv(2) setAltitude_ [expr -1.0 * $auv_curr_depth] 
  ##########################################################################################################
set curr_x 3000
  set curr_y 0
  set curr_lat    [ $woss_utilities getLatfromDistBearing  $opt(start_lat) $opt(start_long) 180.0 $curr_y ]
  set curr_lon    [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) 90.0  $curr_x ]
  $position_waypoint_auv(3) setLatitude_ $curr_lat
  $position_waypoint_auv(3) setLongitude_ $curr_lon
  $position_waypoint_auv(3) setAltitude_ [expr -1.0 * $auv_curr_depth] 
  ##########################################################################################################
set curr_x 5000
  set curr_y 0
  set curr_lat    [ $woss_utilities getLatfromDistBearing  $opt(start_lat) $opt(start_long) 180.0 $curr_y ]
  set curr_lon    [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) 90.0  $curr_x ]
  $position_waypoint_auv(4) setLatitude_ $curr_lat
  $position_waypoint_auv(4) setLongitude_ $curr_lon
  $position_waypoint_auv(4) setAltitude_ [expr -1.0 * $auv_curr_depth] 
  ##########################################################################################################
set curr_x 5000
  set curr_y 8000
  set curr_lat    [ $woss_utilities getLatfromDistBearing  $opt(start_lat) $opt(start_long) 180.0 $curr_y ]
  set curr_lon    [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) 90.0  $curr_x ]
  $position_waypoint_auv(5) setLatitude_ $curr_lat
  $position_waypoint_auv(5) setLongitude_ $curr_lon
  $position_waypoint_auv(5) setAltitude_ [expr -1.0 * $auv_curr_depth] 
  ##########################################################################################################
set curr_x 7000
  set curr_y 8000
  set curr_lat    [ $woss_utilities getLatfromDistBearing  $opt(start_lat) $opt(start_long) 180.0 $curr_y ]
  set curr_lon    [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) 90.0  $curr_x ]
  $position_waypoint_auv(6) setLatitude_ $curr_lat
  $position_waypoint_auv(6) setLongitude_ $curr_lon
  $position_waypoint_auv(6) setAltitude_ [expr -1.0 * $auv_curr_depth] 
  ##########################################################################################################
set curr_x 7000
  set curr_y 0
  set curr_lat    [ $woss_utilities getLatfromDistBearing  $opt(start_lat) $opt(start_long) 180.0 $curr_y ]
  set curr_lon    [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) 90.0  $curr_x ]
  $position_waypoint_auv(7) setLatitude_ $curr_lat
  $position_waypoint_auv(7) setLongitude_ $curr_lon
  $position_waypoint_auv(7) setAltitude_ [expr -1.0 * $auv_curr_depth] 
  ##########################################################################################################
}

########################
# WAYPOINT OF THE SINK #
########################
proc createSinkWaypoints { } {
  global position_waypoint_auv opt position woss_utilities
  global position_sink

  set toa 0.0
  set curr_lat [$position_waypoint_auv(1) getLatitude_]
  set curr_lon [$position_waypoint_auv(1) getLongitude_]
  set curr_depth [expr -1.0 * 600]
  set toa      [$position_sink addWayPoint $curr_lat $curr_lon $curr_depth $opt(speed) 0.0]
  puts "waypoint 1  lat = $curr_lat; long = $curr_lon ; depth = $curr_depth ; toa = $toa"


  set curr_lat [$position_waypoint_auv(2) getLatitude_]
  set curr_lon [$position_waypoint_auv(2) getLongitude_]
  set curr_depth [expr -1.0 * 600]
  set toa      [$position_sink addWayPoint $curr_lat $curr_lon $curr_depth $opt(speed) 0.0]
  puts "waypoint 2  lat = $curr_lat; long = $curr_lon ; depth = $curr_depth ; toa = $toa"


  set curr_lat [$position_waypoint_auv(3) getLatitude_]
  set curr_lon [$position_waypoint_auv(3) getLongitude_]
  set curr_depth [expr -1.0 * 600]
  set toa      [$position_sink addWayPoint $curr_lat $curr_lon $curr_depth $opt(speed) 0.0]
  puts "waypoint 3  lat = $curr_lat; long = $curr_lon ; depth = $curr_depth ; toa = $toa"


  set curr_lat [$position_waypoint_auv(4) getLatitude_]
  set curr_lon [$position_waypoint_auv(4) getLongitude_]
  set curr_depth [expr -1.0 * 600]
  set toa      [$position_sink addWayPoint $curr_lat $curr_lon $curr_depth $opt(speed) 0.0]
  puts "waypoint 4  lat = $curr_lat; long = $curr_lon ; depth = $curr_depth ; toa = $toa"


  set curr_lat [$position_waypoint_auv(5) getLatitude_]
  set curr_lon [$position_waypoint_auv(5) getLongitude_]
  set curr_depth [expr -1.0 * 600]
  set toa      [$position_sink addWayPoint $curr_lat $curr_lon $curr_depth $opt(speed) 0.0]
  puts "waypoint 5  lat = $curr_lat; long = $curr_lon ; depth = $curr_depth ; toa = $toa"

  set curr_lat [$position_waypoint_auv(6) getLatitude_]
  set curr_lon [$position_waypoint_auv(6) getLongitude_]
  set curr_depth [expr -1.0 * 600]
  set toa      [$position_sink addWayPoint $curr_lat $curr_lon $curr_depth $opt(speed) 0.0]
  puts "waypoint 6  lat = $curr_lat; long = $curr_lon ; depth = $curr_depth ; toa = $toa"


  set curr_lat [$position_waypoint_auv(7) getLatitude_]
  set curr_lon [$position_waypoint_auv(7) getLongitude_]
  set curr_depth [expr -1.0 * 600]
  set toa      [$position_sink addWayPoint $curr_lat $curr_lon $curr_depth $opt(speed) 0.0]
  puts "waypoint 7  lat = $curr_lat; long = $curr_lon ; depth = $curr_depth ; toa = $toa"

  set curr_lat [$position_waypoint_auv(0) getLatitude_]
  set curr_lon [$position_waypoint_auv(0) getLongitude_]
  set curr_depth [expr -1.0 * 600]
  set toa      [$position_sink addLoopPoint $curr_lat $curr_lon $curr_depth $opt(speed) 0.0 1 8]
  puts "waypoint 0  lat = $curr_lat; long = $curr_lon ; depth = $curr_depth ; toa = $toa"
  #1 TOTAL LOOPS
  #0.0 loop_id


}

###############################
# routing of nodes
###############################

proc connectNodes {id1} {
    global ipif ipr portnum cbr cbr_sink ipif_sink portnum_sink ipr_sink

    $cbr($id1) set destAddr_ [$ipif_sink addr]
    $cbr($id1) set destPort_ $portnum_sink($id1)
    $cbr_sink($id1) set destAddr_ [$ipif($id1) addr]
    $cbr_sink($id1) set destPort_ $portnum($id1)  
    $ipr($id1) addRoute "1.0.0.253"    "255.255.255.255" "1.0.0.253"
    $ipr_sink  addRoute "1.0.0.${id1}" "255.255.255.255" "1.0.0.${id1}"
}

###############################
# create nodes
###############################

for {set id 0} {$id < $opt(nn)} {incr id}  {
    createNode $id
}

###############################
# create sink
###############################

createSink
createPositionWaypoints
createSinkWaypoints
################################
#Setup flows
################################

for {set id1 0} {$id1 < $opt(nn)} {incr id1}  {
    connectNodes $id1
}

################################
#fill ARP tables
################################

for {set id1 0} {$id1 < $opt(nn)} {incr id1}  {
    for {set id2 0} {$id2 < $opt(nn)} {incr id2}  {
	$mll($id1) addentry [$ipif($id2) addr] [$mac($id2) addr]
    }   
    $mll($id1) addentry [$ipif_sink addr] [ $mac_sink addr]
    $mll_sink addentry [$ipif($id1) addr] [ $mac($id1) addr]
}


################################
#Start cbr(s)
################################


set force_stop $opt(stoptime)

for {set id1 0} {$id1 < $opt(nn)} {incr id1}  {
      $ns at $opt(starttime)	     "$cbr($id1) start"
      $ns at $opt(stoptime)          "$cbr($id1) stop"
}




proc finish { } {
    global ns opt cbr mac propagation cbr_sink mac_sink phy_data phy_data_sink channel db_manager propagation
    global woss_manager outfile outfile_sink
    
	if {$opt(verbose)} {
		puts "\n"
		puts "CBR_PERIOD : $opt(cbr_period)"
		puts "SEED: $opt(rep_num)"
		puts "NUMBER OF NODES: $opt(nn)"
	} else {
		puts "Simulation done!"
	}
    set sum_cbr_throughput 	0
    set sum_per		0
    set sum_cbr_sent_pkts	0.0
    set sum_cbr_rcv_pkts	0.0
    set consumed_energy_tx_node	0.0
    set consumed_energy_rx_node	0.0
    set stdby_time		0.0
    set total_stdby_time	0.0

	
    for {set id3 0} {$id3 < $opt(nn)} {incr id3}  {
	set cbr_throughput	   [$cbr_sink($id3) getthr]
	set cbr_per	           [$cbr_sink($id3) getper]
	set cbr_pkts         [$cbr($id3) getsentpkts]
	set cbr_rcv_pkts       [$cbr_sink($id3) getrecvpkts]
	################################################
	set ftt					[$cbr_sink($id3) getftt]
	set ftt_std				[$cbr_sink($id3) getfttstd]
	#################################################
	if {$opt(verbose)} {
		puts "cbr_sink($id3) throughput                : $cbr_throughput"
		puts "cbr_sink($id3) packet error rate         : $cbr_per"
		puts "cbr($id3) sent packets 	       	       : $cbr_pkts"
		puts "cbr_sink($id3) received packets          : $cbr_rcv_pkts"
	}
	

	set sum_cbr_throughput [expr $sum_cbr_throughput + $cbr_throughput]
	set sum_per [expr $sum_per + $cbr_per]
	set sum_cbr_sent_pkts [expr $sum_cbr_sent_pkts + $cbr_pkts]
	set sum_cbr_rcv_pkts  [expr $sum_cbr_rcv_pkts + $cbr_rcv_pkts]
	###############################################
	###############################################
    }
    if {$opt(verbose)} {
		puts "Throughput medio:  [expr ($sum_cbr_throughput/($opt(nn)))]"
		puts "Totale pacchetti trasmessi: [expr ($sum_cbr_sent_pkts)]"
		puts "Totale pacchetti ricevuti : [expr ($sum_cbr_rcv_pkts)]"
		puts "PER medio: [expr (1 - ($sum_cbr_rcv_pkts/($sum_cbr_sent_pkts)))]"
	}
    $ns flush-trace
    close $opt(tracefile)
}


###################
# start simulation
###################

puts -nonewline "\nSimulating...\n"

$ns at [expr $opt(stoptime) + $opt(extra_time)]  "finish; $ns halt" 

$ns run
    
