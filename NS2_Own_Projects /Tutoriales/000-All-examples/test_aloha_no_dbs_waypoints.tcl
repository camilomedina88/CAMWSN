
##-------------------------------------------------------------------------
# Author: Federico Guerra
# Date: March 2010
# Department of Information Engineering (DEI), University of Padova
#-------------------------------------------------------------------------
#
# Copyright (c) 2009 Regents of the SIGNET lab, University of Padova.
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


# Module libraries

load libMiracle.so
load libmiraclecbr.so
load libmphy.so
load libmmac.so
load libMiracleIp.so
load libMiracleIpRouting.so
load libmiracleport.so
load libmll.so

load libUwmStd.so
load libWOSS.so
load libWOSSPhy.so

load libcbrtracer.so
load libUwmStdPhyBpskTracer.so
load libroutingtracer.so


#####################################
#  
#           x axis (longitude)
#       ------------------>
#       |    
#  y    |     0------>1
#       |     ^       |
#  a    |     |       |
#  x    |     |       |
#  i    |     2<------3
#  s    |
#       |
# (lat) |
#       |
#
#
#  AUV loops on the following path:
#   2 -> 0 -> 1 -> 3 -> 
#   ^_________________|
#
###################################


#### Read first test_aloha_no_dbs.tcl and test_aloha_with_dbs.tcl for
#### basic info.

######################################
# global allocations & misc options
######################################


set opt(nn)           4
set opt(knots)        4
set opt(speed)        [expr $opt(knots) * 0.51444444444]
set opt(pktsize)      512.0
set opt(period)       500.0
set opt(rep_num)      13
set opt(ack_mode)     "setNoAckMode" 
# set opt(ack_mode)     "setAckMode" 

set opt(starttime)    0.1
set opt(stoptime)     10800.0 
set opt(txduration)   [expr $opt(stoptime) - $opt(starttime)]

set opt(start_lat)    42.59
set opt(start_long)   10.125


set opt(maxinterval_) 10.0
set opt(freq)         17500.0
set opt(bw)           5000.0
set opt(bitrate)      4800.0
set opt(geom_freq)    [expr sqrt( ( $opt(freq) - $opt(bw) / 2.0 ) * ( $opt(freq) + $opt(bw) / 2.0 ) ) ]

set opt(ctrl_pkt_size)      4
set opt(tx_SPL)            190.0
set opt(per_tgt)            0.01
set opt(rx_snr_penalty_db)  -10.0
set opt(tx_margin_db)       10.0


# offset in meter from bathymetry depth
set opt(node_bathy_offset) -2.0
set opt(auv_depth)         10.0


# set opt(db_path)     "insert_db_path_here"
set opt(db_path)     "/home/fedwar/ns/ocean_database/"
set opt(db_res_path)  "."

if { $opt(db_path) == "insert_db_path_here" } {
  puts "You have to set the database path first."
  exit
}

set opt(tracefilename) "/tmp/${argv0}.tr"
# set opt(tracefilename) "/dev/null"
set opt(tracefile) [open $opt(tracefilename) w]

#set opt(cltracefilename) "/tmp/${argv0}.cltr"
set opt(cltracefilename) "/dev/null"
set opt(cltracefile) [open $opt(cltracefilename) w]


set ns [new Simulator]
$ns use-Miracle

set opt(start_clock) [clock seconds]


########################################
# Random Number Generators
########################################

global def_rng
set def_rng [new RNG]
$def_rng default

set positionrng [new RNG]

set rbathy [new RandomVariable/Uniform]
$rbathy set min_ 0.0
$rbathy set max_ 3.5
$rbathy use-rng $positionrng


set rdepth [new RandomVariable/Uniform]
$rdepth set min_ 1.0
$rdepth set max_ 8.0
$rdepth use-rng $positionrng


for {set k 0} {$k < $opt(rep_num)} {incr k} {
     $def_rng next-substream
     $positionrng next-substream
}


########################################
# global setup
########################################


WOSS/Definitions/RandomGenerator/NS2 set rep_number_ $opt(rep_num)
WOSS/Definitions/RandomGenerator/C set seed_ $opt(rep_num)

set ssp_creator         [new "WOSS/Definitions/SSP"]
set sediment_creator    [new "WOSS/Definitions/Sediment"]
set pressure_creator    [new "WOSS/Definitions/Pressure"]
set time_arr_creator    [new "WOSS/Definitions/TimeArr"]
set time_reference      [new "WOSS/Definitions/TimeReference/NS2"]
set transducer_creator  [new "WOSS/Definitions/Transducer"]
# set rand_generator      [new "WOSS/Definitions/RandomGenerator/NS2"]
set rand_generator      [new "WOSS/Definitions/RandomGenerator/C"]
$rand_generator initialize

set def_handler [new "WOSS/Definitions/Handler"]
$def_handler setSSPCreator         $ssp_creator
$def_handler setSedimentCreator    $sediment_creator
$def_handler setPressureCreator    $pressure_creator
$def_handler setTimeArrCreator     $time_arr_creator
$def_handler setTransducerCreator  $transducer_creator
$def_handler setTimeReference      $time_reference
$def_handler setRandomGenerator    $rand_generator


WOSS/Utilities set debug 0
set woss_utilities [new WOSS/Utilities]

# 
# WOSS/Creator/Database/Textual/Results/TimeArr set debug           0
# WOSS/Creator/Database/Textual/Results/TimeArr set woss_db_debug   0
# WOSS/Creator/Database/Textual/Results/TimeArr set space_sampling  2.0
# 
# set db_res_arr [new WOSS/Creator/Database/Textual/Results/TimeArr]
# $db_res_arr setDbPathName "${opt(db_res_path)}/arr_aloha_cluster1_cbrp${opt(cbr_pattern)}_knts${opt(kntpr)}_ack${opt(apr)}_freq${opt(geom_freq)}_rng${opt(rep_num)}.txt"

WOSS/Creator/Database/Binary/Results/TimeArr set debug           0
WOSS/Creator/Database/Binary/Results/TimeArr set woss_db_debug   0
WOSS/Creator/Database/Binary/Results/TimeArr set space_sampling  2.0

set db_res_arr [new "WOSS/Creator/Database/Binary/Results/TimeArr"]
$db_res_arr setDbPathName "${opt(db_res_path)}/test_aloha_no_dbs_waypoints_res_arr.dat"


WOSS/Creator/Database/NetCDF/Sediment/DECK41 set debug         0
WOSS/Creator/Database/NetCDF/Sediment/DECK41 set woss_db_debug 0


WOSS/Database/Manager set debug 0
set db_manager [new WOSS/Database/Manager]
$db_manager setCustomSediment   "Test Sedim" 1560 200 1.5 0.9 0.8 1.0
$db_manager setCustomSSP        "./ssp-test.txt"


WOSS/Creator/Bellhop set debug                        0.0
WOSS/Creator/Bellhop set woss_debug                   0.0
WOSS/Creator/Bellhop set max_time_values              20
WOSS/Creator/Bellhop set total_runs                   5
WOSS/Creator/Bellhop set frequency_step               0.0
WOSS/Creator/Bellhop set total_range_steps            20.0
WOSS/Creator/Bellhop set tx_min_depth_offset          0.0
WOSS/Creator/Bellhop set tx_max_depth_offset          0.0
WOSS/Creator/Bellhop set total_transmitters           1
WOSS/Creator/Bellhop set total_rx_depths              2
WOSS/Creator/Bellhop set rx_min_depth_offset          -0.1
WOSS/Creator/Bellhop set rx_max_depth_offset          0.1
WOSS/Creator/Bellhop set total_rx_ranges              2
WOSS/Creator/Bellhop set rx_min_range_offset          -0.1
WOSS/Creator/Bellhop set rx_max_range_offset          0.1
WOSS/Creator/Bellhop set total_rays                   0.0
WOSS/Creator/Bellhop set min_angle                    -180.0
WOSS/Creator/Bellhop set max_angle                    180.0
WOSS/Creator/Bellhop set ssp_depth_precision          1.0e-8
WOSS/Creator/Bellhop set normalized_ssp_depth_steps   100000
WOSS/Creator/Bellhop set ssp_seed                     10   

set woss_creator [new WOSS/Creator/Bellhop]
$woss_creator setWorkDirPath     "/dev/shm/woss/test_aloha_no_dbs_waypoints/woss_channel_"
$woss_creator setBellhopMode     0 0 "A"
$woss_creator setBeamOptions     0 0 "B"
$woss_creator setBathymetryType  0 0 "L"
$woss_creator setSimulationTimes 0 0 1 1 2010 0 0 1 2 1 2010 0 0 1


WOSS/Manager/Simple set debug 0
WOSS/Manager/Simple set space_sampling 2.0
set woss_manager [new "WOSS/Manager/Simple"]

# WOSS/Manager/Simple/MultiThread set debug               0
# WOSS/Manager/Simple/MultiThread set space_sampling      2.0
# WOSS/Manager/Simple/MultiThread set concurrent_threads  3
# set woss_manager [new "WOSS/Manager/Simple/MultiThread"]


WOSS/Definitions/TransducerHandler set debug 0
set transducer_handler [new WOSS/Definitions/TransducerHandler]

#### we import a transducer and we link it to "ITC-3001" tag
$transducer_handler importAscii "ITC-3001" "$opt(db_path)/transducers/ITC/ITC-ITC-3001-17.5kHz.txt"
# $transducer_handler importAscii "NEPTUNE-T186" "$opt(db_path)/transducers/Neptune/Neptune-T186-17kHz.txt"

WOSS/Controller set debug 0
set woss_controller [new WOSS/Controller]
$woss_controller setTimeArrResultsDbCreator  $db_res_arr
$woss_controller setWossDbManager            $db_manager
$woss_controller setWossManager              $woss_manager
$woss_controller setWossCreator              $woss_creator
$woss_controller setTransducerhandler        $transducer_handler
$woss_controller initialize


WOSS/PlugIn/ChannelEstimator set debug_ 0

WOSS/ChannelEstimator set debug_           0.0
WOSS/ChannelEstimator set space_sampling_  2.0
WOSS/ChannelEstimator set avg_coeff_       0.9
set channel_estimator [ new "WOSS/ChannelEstimator"]


WOSS/Module/Channel set channel_time_resolution_  -1.0
WOSS/Module/Channel set debug_                    0.0

set channel [new "WOSS/Module/Channel"]
$channel setWossManager      $woss_manager
$channel setChannelEstimator $channel_estimator


WOSS/MPropagation set debug_ 0
set propagation [new WOSS/MPropagation]
$propagation setWossManager $woss_manager


set data_mask [new MSpectralMask/Rect]
$data_mask setFreq       $opt(freq)
$data_mask setBandwidth  $opt(bw)


WOSS/Module/CBR set debug_               0
WOSS/Module/CBR set packetSize_          $opt(pktsize)
WOSS/Module/CBR set period_              $opt(period)
WOSS/Module/CBR set PoissonTraffic_      1


set diag [expr sqrt(1000.0*1000.0 + 1000.0*1000.0) ]
set opt(ACK_timeout) [expr 2.0 * (($diag + 100.0) / 1500.0)]

Module/MMac/ALOHA/ADV set debug_                0
Module/MMac/ALOHA/ADV set HDR_size_             0
Module/MMac/ALOHA/ADV set ACK_size_             $opt(ctrl_pkt_size)
Module/MMac/ALOHA/ADV set wait_costant_         0.1
Module/MMac/ALOHA/ADV set backoff_tuner_        1.0
Module/MMac/ALOHA/ADV set max_payload_          $opt(pktsize)
Module/MMac/ALOHA/ADV set ACK_timeout_          $opt(ACK_timeout)
Module/MMac/ALOHA/ADV set alpha_                0.8
Module/MMac/ALOHA/ADV set max_tx_tries_         -1
Module/MMac/ALOHA/ADV set buffer_pkts_          5000
Module/MMac/ALOHA/ADV set listen_time_          0.5
Module/MMac/ALOHA/ADV set max_backoff_counter_  4


#### MaxTxSPL_dB_ was previously named MaxTxPower_dB_
#### MinTxSPL_dB_ was previously named MinTxPower_dB_
#### TxSPLMargin_dB_ was previously named TxPowerMargin_dB_
#### SPLOptimization_, CentralFreqOptimization_, BandwidthOptimization_ added
WOSS/Module/MPhy/BPSK  set debug_                     0
WOSS/Module/MPhy/BPSK  set AcquisitionThreshold_dB_   10.0
WOSS/Module/MPhy/BPSK  set BitRate_                   $opt(bitrate)
WOSS/Module/MPhy/BPSK  set MaxTxSPL_dB_               $opt(tx_SPL)
WOSS/Module/MPhy/BPSK  set MinTxSPL_dB_               1
WOSS/Module/MPhy/BPSK  set MaxTxRange_                50000
WOSS/Module/MPhy/BPSK  set PER_target_                $opt(per_tgt)
WOSS/Module/MPhy/BPSK  set RxSnrPenalty_dB_           $opt(rx_snr_penalty_db)
WOSS/Module/MPhy/BPSK  set TxSPLMargin_dB_            $opt(tx_margin_db)
WOSS/Module/MPhy/BPSK  set SPLOptimization_           1
WOSS/Module/MPhy/BPSK  set CentralFreqOptimization    0
WOSS/Module/MPhy/BPSK  set BandwidthOptimization_     0


WOSS/Position/WayPoint set time_threshold_            [expr 1.0 / $opt(speed)]
WOSS/Position/WayPoint set compDistance_              0.0
WOSS/Position/WayPoint set verticalOrientation_       0.0
WOSS/Position/WayPoint set minVerticalOrientation_    -40.0
WOSS/Position/WayPoint set maxVerticalOrientation_    40.0


 ###############################
 # Procedure for creating nodes
 ###############################

 proc createNode { id dist_x dist_y }  {
  global channel propagation data_mask ns cbr position node port portnum ipr ipif channel_estimator
  global phy_data posdb opt rvposx rvposy rvposz mhrouting mll mac woss_creator woss_utilities db_manager

  set node($id) [$ns create-M_Node $opt(tracefile) $opt(cltracefile)] 

  #### we don't need the IP routing anymore layer for basic sample.
  #### ChannelEstimatorPlugin now expects as input MAC addresses.
  #### MLL is therefore needed to properly map IP to MAC addresses.
  set cbr($id)       [new WOSS/Module/CBR] 
  set port($id)      [new Module/Port/Map]
  set ipif($id)      [new Module/IP/Interface]
  set mll($id)       [new Module/MLL] 
  set mac($id)       [new Module/MMac/ALOHA/ADV] 
  set phy_data($id)  [new WOSS/Module/MPhy/BPSK]

  $node($id) addModule 6 $cbr($id)       0 "CBR"
  $node($id) addModule 5 $port($id)      0 "PRT"
  $node($id) addModule 4 $ipif($id)      0 "IPF"   
  $node($id) addModule 3 $mll($id)       0 "MLL"
  $node($id) addModule 2 $mac($id)       0 "MAC"
  $node($id) addModule 1 $phy_data($id)  0 "DPHY"

  $node($id) setConnection $cbr($id)  $port($id)       1
  $node($id) setConnection $port($id) $ipif($id)       0
  $node($id) setConnection $ipif($id) $mll($id)        0 
  $node($id) setConnection $mll($id)  $mac($id)        0
  $node($id) setConnection $mac($id)  $phy_data($id)   0
  $node($id) addToChannel  $channel   $phy_data($id)   1

  set portnum($id) [$port($id) assignPort $cbr($id)]
  if {$id > 254} {
    puts "hostnum > 254!!! exiting"
    exit
  }

  $ipif($id) addr "1.0.0.${id}"
  #interface can reach directly all nodes if needed
  $ipif($id) subnet "0.0.0.0"

  set position($id) [new "WOSS/Position/WayPoint"]

  set curr_lat    [ $woss_utilities getLatfromDistBearing  $opt(start_lat) $opt(start_long) 180.0 $dist_y ]
  set curr_lon    [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) 90.0  $dist_x ]
  set curr_depth  [expr [ $db_manager getBathymetry $curr_lat $curr_lon] + $opt(node_bathy_offset)] 

  #### we add the start way point
  $position($id) addStartWayPoint $curr_lat $curr_lon [expr -1.0 * $curr_depth] 0.0 0.0 
  $node($id) addPosition $position($id)

  set ch_estimator_plugin($id) [ new "WOSS/PlugIn/ChannelEstimator"]
  $ch_estimator_plugin($id) setChannelEstimator $channel_estimator
  $ch_estimator_plugin($id) insertNode [$mac($id) addr] $position($id)
  $node($id) addPlugin $ch_estimator_plugin($id) 19 "CHE"

  puts "node $id at ( ($dist_x, $dist_y) [$position($id) getLatitude_], [$position($id) getLongitude_], [$position($id) getAltitude_]) , ([$position($id) getX_], [$position($id) getY_], [$position($id) getAltitude_])"

  #### we set the transducer labeled "ITC-3001" for the tx woss::Location and for all rx woss::Locations.
  #### Initial rotation is -45.0°, multiply costant is 1, add costant is 0
  $woss_creator setCustomTransducerType $position($id) 0 "ITC-3001" -45.0 0.0 1.0 0.0
#   $woss_creator setCustomTransducerType $position($id) 0 "NEPTUNE-T186" -45.0 0.0 1.0 0.0

  set interf_data($id) [new WOSS/MInterference/MIV]
  $interf_data($id) set maxinterval_ $opt(maxinterval_)

  $phy_data($id) setSpectralMask    $data_mask
  $phy_data($id) setPropagation     $propagation
  $phy_data($id) setInterference    $interf_data($id)
  #### we set the transducer labeled "ITC-3001" for SPL, input power and energy consumpion computations
  $phy_data($id) setTransducerType  [expr [$data_mask getFreq] - [$data_mask getBandwidth] / 2.0 ] [expr [$data_mask getFreq] + [$data_mask getBandwidth] / 2.0 ] "ITC-3001"
#   $phy_data($id) setTransducerType  [expr [$data_mask getFreq] - [$data_mask getBandwidth] / 2.0 ] [expr [$data_mask getFreq] + [$data_mask getBandwidth] / 2.0 ] "NEPTUNE-T186"

  $mac($id) $opt(ack_mode)
  $mac($id) initialize
}


proc createAUV { } {
  global channel propagation tone_mask data_mask ns cbr_auv position_auv node_auv port_auv portnum_auv 
  global phy_data_auv posdb_auv opt rvposx rvposy rvposz mhrouting mll_auv mac_auv ipr_auv ipif_auv 
  global woss_creator woss_utilities db_manager channel channel_estimator ch_estimator_plugin_auv


  set node_auv [$ns create-M_Node $opt(tracefile) $opt(cltracefile)] 

  set port_auv      [new Module/Port/Map]
  set ipif_auv      [new Module/IP/Interface]
  set mll_auv       [new Module/MLL] 
  set mac_auv       [new Module/MMac/ALOHA/ADV] 
  set phy_data_auv  [new WOSS/Module/MPhy/BPSK]

  $node_auv addModule 5 $port_auv      0 "PRT"
  $node_auv addModule 4 $ipif_auv      0 "IPF"   
  $node_auv addModule 3 $mll_auv       0 "MLL"
  $node_auv addModule 2 $mac_auv       0 "MAC"
  $node_auv addModule 1 $phy_data_auv  0 "DPHY"

  for { set cnt 0} {$cnt < $opt(nn)} {incr cnt} {
    set cbr_auv($cnt)  [new WOSS/Module/CBR] 

    $node_auv addModule 6 $cbr_auv($cnt) 0 "CBR"

    $node_auv setConnection $cbr_auv($cnt)  $port_auv     1

    set portnum_auv($cnt) [$port_auv assignPort $cbr_auv($cnt)]
    if {$cnt > 254} {
    puts "hostnum > 254!!! exiting"
    exit
    }
  }

  $ipif_auv addr "1.0.0.253"
  #interface can reach directly all nodes if needed
  $ipif_auv subnet "0.0.0.0"

  $node_auv setConnection $port_auv $ipif_auv       0
  $node_auv setConnection $ipif_auv $mll_auv        0 
  $node_auv setConnection $mll_auv  $mac_auv        0
  $node_auv setConnection $mac_auv  $phy_data_auv   0
  $node_auv addToChannel  $channel  $phy_data_auv   1

  set curr_lat    [ $woss_utilities getLatfromDistBearing  $opt(start_lat) $opt(start_long) 180.0 1000.0 ]
  set curr_lon    [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) 90.0  0 ]
  set curr_depth  $opt(auv_depth)

  set position_auv [new "WOSS/Position/WayPoint"]
  $position_auv addStartWayPoint $curr_lat $curr_lon [expr -1.0 * $curr_depth] $opt(speed) 0.0 
  $node_auv addPosition $position_auv

  set ch_estimator_plugin_auv [ new "WOSS/PlugIn/ChannelEstimator"]
  $ch_estimator_plugin_auv setChannelEstimator $channel_estimator
  $ch_estimator_plugin_auv insertNode [$mac_auv addr] $position_auv
  $node_auv addPlugin $ch_estimator_plugin_auv 19 "CHE"

  puts  "node_auv at ( (0, 1000.0) [$position_auv getLatitude_], [$position_auv getLongitude_], [$position_auv getAltitude_])"

  $woss_creator setCustomTransducerType $position_auv 0 "ITC-3001" 0.0 0.0 1.0 0.0
#   $woss_creator setCustomTransducerType $position_auv 0 "NEPTUNE-T186" 0.0 0.0 1.0 0.0

  set interf_data_auv [new WOSS/MInterference/MIV]
  $interf_data_auv set maxinterval_ $opt(maxinterval_)
  $interf_data_auv set debug_       0

  $phy_data_auv setSpectralMask    $data_mask
  $phy_data_auv setPropagation     $propagation
  $phy_data_auv setInterference    $interf_data_auv
  $phy_data_auv setTransducerType  [expr [$data_mask getFreq] - [$data_mask getBandwidth] / 2.0 ] [expr [$data_mask getFreq] + [$data_mask getBandwidth] / 2.0 ] "ITC-3001"
#   $phy_data_auv setTransducerType  [expr [$data_mask getFreq] - [$data_mask getBandwidth] / 2.0 ] [expr [$data_mask getFreq] + [$data_mask getBandwidth] / 2.0 ] "NEPTUNE-T186"

  $mac_auv initialize
  $mac_auv $opt(ack_mode)
}

proc connectNodes {id1} {
  global ipif ipr portnum cbr cbr_auv ipif_auv portnum_auv ipr_auv

  $cbr($id1)     set destAddr_ [$ipif_auv addr]
  $cbr($id1)     set destPort_ $portnum_auv($id1)
  $cbr_auv($id1) set destAddr_ [$ipif($id1) addr]
  $cbr_auv($id1) set destPort_ $portnum($id1)  
}

#### we create a bathymetry grid 2500m x 2500m 
#### with depth increasing from 40m to 240m
proc createBathymetryMap { } {
  global db_manager woss_utilities opt rbathy

  set long [ $woss_utilities getLongfromDistBearing $opt(start_lat) $opt(start_long) -90.0 500.0 ]
  set bathy_start 40.0
  set bathy_end   240.0
  set line_range  250.0

  set bathy_incr [ expr ($bathy_end - $bathy_start) / $line_range ]

  for { set bid 0.0 } { $bid < 2500.0 } { set bid [expr $bid + 10.0]} {
    set lat [ $woss_utilities getLatfromDistBearing $opt(start_lat) $long 180.0 $bid ]

#     puts "createBathymetryMap latitude = $lat ; longitude = $long"

    for { set bid2 0.0 } { $bid2 < 250.0 } { set bid2 [expr $bid2 + 10.0] } {
      set rb [$rbathy value]
      $db_manager setCustomBathymetry $lat $opt(start_long) 90.0 1 [expr 10.0 * $bid2] [expr $bathy_start + $bid2 * $bathy_incr + $rb ] 
    }   

  }

}

#### we set the AUV waypoints and set final loop point (3 loops)
proc createAUVWaypoints { } {
  global position_auv opt position woss_utilities rdepth
  set toa 0.0
  set curr_lat   [ $position(0) getLatitude_]
  set curr_lon   [ $position(0) getLongitude_]
  set curr_depth [expr -1.0 * $opt(auv_depth) * [$rdepth value]]
  set toa        [$position_auv addWayPoint $curr_lat $curr_lon $curr_depth $opt(speed) 0.0 ]
  puts "waypoint 1 lat = $curr_lat ; lon = $curr_lon ; depth = $curr_depth; toa = $toa"

  set curr_lat   [ $position(1) getLatitude_]
  set curr_lon   [ $position(1) getLongitude_]
  set curr_depth [expr -1.0 * $opt(auv_depth) * [$rdepth value]]
  set toa        [$position_auv addWayPoint $curr_lat $curr_lon $curr_depth $opt(speed) 0.0 ]
  puts "waypoint 2 lat = $curr_lat ; lon = $curr_lon ; depth = $curr_depth; toa = $toa"

  set curr_lat   [ $position(3) getLatitude_]
  set curr_lon   [ $position(3) getLongitude_]
  set curr_depth [expr -1.0 * $opt(auv_depth) * [$rdepth value]]
  set toa        [$position_auv addWayPoint $curr_lat $curr_lon $curr_depth $opt(speed) 0.0 ]
  puts "waypoint 3 lat = $curr_lat ; lon = $curr_lon ; depth = $curr_depth; toa = $toa"

  set curr_lat   [ $position(2) getLatitude_]
  set curr_lon   [ $position(2) getLongitude_]
  set curr_depth [expr -1.0 * $opt(auv_depth) * [$rdepth value]]
  set toa        [$position_auv addLoopPoint $curr_lat $curr_lon [expr -1.0 * $opt(auv_depth)] $opt(speed) 0.0 0 4 ]
  puts "waypoint 4 lat = $curr_lat ; lon = $curr_lon ; depth = $curr_depth; toa = $toa"
}


proc min { x y } {
  if { $x < $y } { return $x
  } else {
    return $y
  }
}

###############################
# create nodes
###############################

createBathymetryMap

createNode 0 0       0
createNode 1 1000.0  0
createNode 2 0       1000.0
createNode 3 1000.0  1000.0

createAUV

createAUVWaypoints

###############################
# fill ARP tables
###############################

for {set id1 0} {$id1 < $opt(nn)} {incr id1}  {
    connectNodes $id1
}


for {set id1 0} {$id1 < $opt(nn)} {incr id1}  {
    for {set id2 0} {$id2 < $opt(nn)} {incr id2}  {
      $mll($id1) addentry [$ipif($id2) addr] [$mac($id2) addr]
    }   
    $mll($id1) addentry [$ipif_auv addr]    [$mac_auv addr]
    $mll_auv   addentry [$ipif($id1) addr]  [$mac($id1) addr]
}

###############################
# finish 
###############################

proc finish {} {
  global ns opt cbr mac propagation cbr_auv mac_auv phy_data phy_data_auv channel db_manager

  $db_manager closeAllConnections

  set totenergy                     0.0
  set total_cbr_tx_pkts             0.0
  set total_cbr_rx_pkts             0.0

  puts "\n"

  for {set id3 0} {$id3 < $opt(nn)} {incr id3}  {

    set cbr_pkts        [$cbr_auv($id3) getsentpkts]
    set cbr_throughput  [$cbr($id3) getthr]
    set cbr_delay       [$cbr($id3) getftt]
    set cbr_per         [$cbr($id3) getper]
    set cbr_rx          [$cbr($id3) getrecvpkts]
    set cbr_first_rx    [$cbr($id3) getFirstTimeRx]
    set cbr_last_rx     [$cbr($id3) getLastTimeRx]

    set nodeenergy  [ $phy_data($id3) set ConsumedEnergy_]
    set totenergy   [expr $totenergy + $nodeenergy]

    puts "node($id3) consumed energy              : $nodeenergy"
    puts "cbr($id3) app data pkts tx              : $cbr_pkts"
    puts "cbr_rx($id3) app data pkts rx           : $cbr_rx"
    puts "cbr_rx($id3) throughput                 : $cbr_throughput"
    puts "cbr_rx($id3) delay                      : $cbr_delay"
    puts "cbr_rx($id3) first pkt rx time          : $cbr_first_rx"
    puts "cbr_rx($id3) last pkt rx time           : $cbr_last_rx"
    puts "cbr_rx($id3) packet error rate          : $cbr_per"
    puts "\n"
  }

  set nodeenergy_auv  [ $phy_data_auv set ConsumedEnergy_]
  set totenergy       [expr $totenergy + $nodeenergy_auv]


  puts "node auv consumed energy              : $nodeenergy_auv"
  puts "\n"

  set opt(end_clock) [clock seconds]

  puts  "done in [expr $opt(end_clock) - $opt(start_clock)] seconds!"
  puts  "tracefile: $opt(tracefilename)"

  $ns flush-trace
  close $opt(tracefile)

}
 

###################
# start simulation
###################

$ns at [expr $opt(starttime) ] "$cbr_auv(0) start"
$ns at [expr $opt(starttime) ] "$cbr_auv(1) start"
$ns at [expr $opt(starttime) ] "$cbr_auv(2) start"
$ns at [expr $opt(starttime) ] "$cbr_auv(3) start"

$ns at [expr $opt(stoptime) ] "$cbr_auv(0) stop"
$ns at [expr $opt(stoptime) ] "$cbr_auv(1) stop"
$ns at [expr $opt(stoptime) ] "$cbr_auv(2) stop"
$ns at [expr $opt(stoptime) ] "$cbr_auv(3) stop"


puts -nonewline "Simulating"

for {set t $opt(starttime)} {$t <= $opt(stoptime)} {set t [expr $t + $opt(txduration) / 40.0 ]} {
    $ns at $t "puts -nonewline ."
}

$ns at [expr $opt(stoptime) + 0.2 * $opt(stoptime) ]  " puts [expr $opt(stoptime) + 0.2 * $opt(stoptime) ]; finish; $ns halt"
$ns run

