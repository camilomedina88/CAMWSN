#     https://github.com/fotis-dmc/NS2/blob/master/ns-2.33/test_o.tcl


set ns_ [new Simulator]
#-------------------------------------------------------------------------------------
# Initialize Wireless settings
#-------------------------------------------------------------------------------------
#=====================================================================================================================================================
set opt(chan) Channel/WirelessChannel ;# channel type
set opt(prop) Propagation/TwoRayGround ;# radio-propagation model
set opt(netif) Phy/WirelessPhy ;# network interface type
#set opt(mac) Mac/802_11e ;# MAC type
set opt(mac) Mac/802_11 ;# MAC type
#set opt(ifq) Queue/DTail/PriQ ;# interface queue type
set opt(ifq) Queue/DropTail/PriQueue ;# interface queue type
set opt(adhocRouting) AODV ;# routing protocol
#set opt(adhocRouting) OLSR ;# routing protocol
set opt(ifqlen) 50 ;# max packet in ifq
set opt(ll) LL ;# link layer type
set opt(ant) Antenna/OmniAntenna ;# antenna model
set opt(nn) 19 ;# number of mobilenodes
set opt(x) 2100 ;# X dimens_ion of the topography
set opt(y) 2100 ;# Y dimens_ion of the topography
set opt(sc) "operation.ns_movements"
set opt(sampleTime) 0.5
#set opt(bt) "cbr.out"
#set opt(out_dir) /home/fotis/Documents/Research-unit_6/ns-eval-testing/wifi/adhoc-video-adam/
#=====================================================================================================================================================
#===================================
# Simulation parameters setup
#===================================
set simtime 1000 ;# Simulation time in seconds # to video xreiazetai peripou 375 sec ara opt(simtime) prepei peripou na einai vbr start_time+375
set max_fragmented_size 1200
set frames_per_second 25 ;# Evalvid-RA, All video is treated with equal fps in current release
set q_variants 30 ;# Evalvid-RA, number of quantiser scale range
#set p_aqm_true 0 ;# 0 = droptail, >0 = RED
set count_bytes 1 ;# 1 = true (qib_ true), 0 = false (count packets)
set cbr_true 1 ;# 0 = RA-SVBR, 1 = CBR_RA
set vbr_rate 0.3Mb ;#500000 ;# Evalvid-RA video: select base rate on VBR sources (includes IP overhead)
#add up RTP/UDP header(12+8=20 bytes) and IP header (20bytes):
set packetSize [expr $max_fragmented_size + 36]
#Queue/DTail/PriQ set Prefer_Routing_Protocols 1
#-------------------------------------------------------------------------------------
# Set values for the antenna position ,Tx and Rx gain
#-------------------------------------------------------------------------------------
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0
#-------------------------------------------------------------------------------------
# Initialize the sharedMedia interface with parameters to make it
# work like the 914MHz Lucent WaveLAN DSSS radio
#-------------------------------------------------------------------------------------
#Phy/WirelessPhy set Rb_ 2*1e6
# AYTA TA SETTINGS ΓΙΑ ΤΟ WIRELESS ΘΕΛΟΥΝ ΛΙΓΟ ΠΑΡΑΠΑΝΩ ΨΑΞΙΜΟ
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6
Phy/WirelessPhy set L_ 1.0
Phy/WirelessPhy set dataRate_ 1Mb
#Mac/802_11e set dataRate_ 1Mb
Mac/802_11 set dataRate_ 1Mb
# SETTING GLOBAL TFRC DEFAULTS:
Agent/TFRC set ss_changes_ 1 ; # Added on 10/21/2004
Agent/TFRC set slow_increase_ 1 ; # Added on 10/20/2004
Agent/TFRC set rate_init_ 2 ;
Agent/TFRC set rate_init_option_ 2 ; # Added on 10/20/2004
#
Agent/TFRC set SndrType_ 1
Agent/TFRC set oldCode_ false
Agent/TFRC set packetSize_ packetSize
Agent/TFRC set maxqueue_ 50
Agent/TFRC set printStatus_ true ;# AYTOS EINAI O "DIAKOPTHS" GIA NA KANEI ADAPTATION TO TFRC...
Agent/TFRC set ecn_ 0
Agent/TFRC set useHeaders_ true
#-------------------------------------------------------------------------------------
# Initialize Global Variables
#-------------------------------------------------------------------------------------
#Open the NS trace file
set tracefile [open operation-f.tr w]
$ns_ trace-all $tracefile
#Open the NAM trace file
set namfile [open out.nam w]
#$ns_ namtrace-all $namfile
#------------------------------------------------------------------------------------
# set up topography object
#------------------------------------------------------------------------------------
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
#------------------------------------------------------------------------------------
# Create God
#------------------------------------------------------------------------------------
#####################################################################################
create-god $opt(nn)
	set god_ [new God]

#------------------------------------------------------------------------------------
# Create channel
#------------------------------------------------------------------------------------
set chan [new $opt(chan)]
#------------------------------------------------------------------------------------
# Create nodes
#------------------------------------------------------------------------------------
$ns_ node-config -adhocRouting $opt(adhocRouting) \
-llType $opt(ll) \
-macType $opt(mac) \
-ifqType $opt(ifq) \
-ifqLen $opt(ifqlen) \
-propInstance [new $opt(prop)] \
-antType $opt(ant) \
-phyType $opt(netif) \
-wiredRouting OFF \
-channel [new $opt(chan)] \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace ON \
-movementTrace ON
for {set i 0} {$i < $opt(nn)} {incr i} {
set node_($i) [$ns_ node]
#set r_($i) [$node_($i) set ragent_]
# $ns_ at 0.0 "$r_($i) radius 2.0"
$node_($i) random-motion 0
}
#------------------------------------------------------------------------------------
# Define node movement model
#------------------------------------------------------------------------------------
puts "Loading mobility scenario file..."
source $opt(sc)
# puts "Loading background traffic..."
# source $opt(bt)
#------------------------------------------------------------------------------------
# RA-Evalvid
#------------------------------------------------------------------------------------
#=====================================================================================================================================================
proc prepare_evalvid_trace {connection_number_eva} {
global ns_ trace_file end_sim_time packetSize frames_per_second max_fragmented_size q_variants
set con $connection_number_eva
puts "Evalvid-RA: Start making GOP and Frame trace files for q_variants Rate variants"
for {set i 1} {$i <= $q_variants} {incr i} {
set original_file_name($con,$i) st_final.yuv_Q[expr $i + 1].txt
set original_file_id($con,$i) [open $original_file_name($con,$i) r]
}
set trace_file_name($con) video$con.dat
set trace_file_id($con) [open $trace_file_name($con) w]
set trace_file($con) [new vbrTracefile2]
$trace_file($con) filename $trace_file_name($con)
set frame_count($con) 0
set last_time 0
# AL: toggle between multiple input files!
#set original_file_id $original_file_id(1)
set source_select 1
set frame_size_file($con) frame_size($con).dat
set frame_size_file_id($con) [open $frame_size_file($con) w]
for {set i 1} {$i <= $q_variants} {incr i} {
set frame_size($i) 0
}
set gop_size_file($con) gop_size$con.dat
set gop_size_file_id($con) [open $gop_size_file($con) w]
for {set i 1} {$i <= $q_variants} {incr i} {
set gop_size($con,$i) 0
}
set gop_numb($con) 0
# Convert ASCII sender file on frame size granularity to ns-2 adapted internal format
while {[eof $original_file_id($con,1)] == 0} {
for {set i 1} {$i <= $q_variants} {incr i} {
gets $original_file_id($con,$i) current_line($i)
}
scan $current_line(1) "%d%s%d%s%s%s%d%s" no_ frametype_ length_ tmp1_ tmp2_ tmp3_ tmp4_ tmp5_
#puts "$no_ $frametype_ $length_ $tmp1_ $tmp2_ $tmp3_ $tmp4_ $tmp5_"
# 30 frames/sec. if one want to generate 25 frames/sec, one can use set time [expr 1000*1000/25]
set tempStr "%.0f"
set time [expr 1000 * 1000/$frames_per_second]
# puts $f5 [format $tempStr $time]
set time [format $tempStr $time]
if { $frametype_ == "I" } {
set type_v 1
set time 0
# set prio_p 3
}
if { $frametype_ == "P" } {
set type_v 2
# set prio_p 3
}
if { $frametype_ == "B" } {
set type_v 3
# set prio_p 3
}
# Write to GOP size file after each H-frame found:
if { $frametype_ == "H" } {
set puts_string "$gop_numb($con)"
for {set i 1} {$i <= $q_variants} {incr i} {
set puts_string "$puts_string $gop_size($con,$i)"
}
puts $gop_size_file_id($con) $puts_string
set gop_numb($con) [expr $gop_numb($con) + 1]
set type_v 0 ;# Must have different type than I-frame so that the LB(r,b) algorithm finds it!
# set prio_p 0
}
# Write to frame_size.dat:
set puts_string "$no_"
for {set i 1} {$i <= $q_variants} {incr i} {
set puts_string "$puts_string $gop_size($con,$i)"
}
puts $frame_size_file_id($con) $puts_string
for {set i 1} {$i <= $q_variants} {incr i} {
scan $current_line($i) "%d%s%d%s%s%s%d%s" no_ frametype_ length($i) tmp1_ tmp2_ tmp3_ tmp4_ tmp5_
set gop_size($con,$i) [expr $gop_size($con,$i) + $length($i) ]
}
# Write to video$con.dat:
set puts_string "$time $length_ $type_v $max_fragmented_size"
for {set i 2} {$i <= $q_variants} {incr i} {
set puts_string "$puts_string $length($i)"
}
puts $trace_file_id($con) $puts_string
incr frame_count($con)
}
puts "Evalvid-RA: #of frames written to GOP and Frame trace files: $frame_count($con)"
#close $original_file_id($con,1)
close $trace_file_id($con) ;# Note that this new trace file is closed for writing and
# opened below for reading through being a new Tracefile in eraTraceFile2::setup()
#set end_sim_time($con) [expr 1.0 * 1000/$frames_per_second * ($frame_count($con) + 1) / 1000]
#puts "$end_sim_time($con)"
}
#=====================================================================================================================================================
#######################################################################
# Add Evalvid-RA RA-SVBR sources #
#######################################################################
#====================================================================================================
proc attach_TFRC_traffic {startnode endnode connection_number} {
global ns_ node_ vbr packetSize vbr_rate trace_file frames_per_second dest_node cconnection_number
#set con_num $connection_number
#$startnode color green
#$endnode color green
#set start_id [$startnode id] ;# 8 h' 13
#set end_id [$endnode id] ;# 1 h' 2
set source_node $node_($startnode)
set dest_node $node_($endnode)
set cconnection_number $connection_number
set tfrc_($cconnection_number) [new Agent/TFRC]
$tfrc_($cconnection_number) set packetSize_ $packetSize
$tfrc_($cconnection_number) set prio_ 1
$tfrc_($cconnection_number) set TOS_field_ 1
#puts "START ----------------- $startnode $endnode $connection_number"
$tfrc_($cconnection_number) set_filename sd_be.$cconnection_number
$ns_ attach-agent $source_node $tfrc_($cconnection_number)	
set sink_($cconnection_number) [new Agent/TFRCSink] ;#ok
$ns_ attach-agent $dest_node $sink_($cconnection_number)	;#ok
#if {$cconnection_number == 0} {
$sink_($cconnection_number) set_trace_filename rd_be.$cconnection_number	;#ok
#}
$ns_ connect $tfrc_($cconnection_number) $sink_($cconnection_number)	;#ok
set vbr($cconnection_number) [new Application/Traffic/eraVbrTrace] ;#set vbr0 [new Application/
$vbr($cconnection_number) attach-agent $tfrc_($cconnection_number)	;#$vbr0 attach-agent $tfrc_(0)
$vbr($cconnection_number) set running_ 0 ;# ok
$vbr($cconnection_number) set r_ $vbr_rate ;# ok
$vbr($cconnection_number) attach-tracefile $trace_file($cconnection_number)	;#ok
$vbr($cconnection_number) set b_ 1.5 ;#ok
$vbr($cconnection_number) set q_ 2 ;#ok 2 adi g 4
$vbr($cconnection_number) set GoP_ 12 ;#ok
$vbr($cconnection_number) set fps_ $frames_per_second	;#ok
$vbr($cconnection_number) set isTFRC_ 1 ;#ok
$vbr($cconnection_number) set packetSize_ $packetSize
#$sink_($cconnection_number) set bytes_ 0
set bwt [ open bwt.TFRC.$cconnection_number.tr w ] ; #$ opt (bwtDelimiter ) .
$ns_ at 0.0 "record $sink_($cconnection_number) $bwt"
puts "added TFRC connection number $cconnection_number (vbr($cconnection_number)) between nodes $startnode and $endnode"
}
#================================================================================================
proc record { sink bwt } {
global opt
set ns_ [Simulator instance]
set time $opt(sampleTime)
#How many bytes have been received by the traffic sink ?
set bw [$sink set bytes_]
# Get the current time
set now [$ns_ now]
#Open a file to write bandwidth − trace
# Calculate the bandwidth ( in MBit / s ) and write it to the file
puts $bwt "$now [expr $bw/$time*8/1000000]"
# Reset the bytes values on the traffic sinks
$sink set bytes_ 0
# Re − schedule the procedure
$ns_ at [expr $now+$time] "record $sink $bwt"
}
#================================================================================================
Agent/TFRC instproc tfrc_ra {bytes_per_sec backlog snr} {
global vbr ns_ dest_node cconnection_number connections
for {set i 0} { $i < $connections } {incr i} {
set now [ $ns_ now ]
$self instvar node_
set node_id [ $node_ id ]
puts "node_id = $node_id"
set vbr_number $i
puts "connection = $i"
#if {$snr < 32.5} {
#set bytes_per_sec [expr $bytes_per_sec/2]
#set bytes_per_sec 512
#set ragent [$node_ set ragent_]
#$ns_ at [expr $now] "$ragent rt_down 30"
#puts "rt_down at $now"
#set rragent [$dest_node set ragent_]
#$ns_ at [expr $now] "$rragent rt_down 10"
#
#}
#if {$snr == -10.0} {
#set snr 200.0
#}
#puts "In TFRC instproc:Time = $now rate = $bytes_per_sec (B/s), backlog = $backlog , node_id = $node_id, SNR = $snr"
#if {$snr < 200.0} {
puts "TCL: before vbr($i) TFRC_rateadapt rate=$bytes_per_sec node=$node_id"
$ns_ at [expr $now] "$vbr($i) TFRC_rateadapt $bytes_per_sec $node_id $backlog"
#set bytes_per_sec [expr $bytes_per_sec/$connections]
#}
puts "TCL: after vbr($i) TFRC_rateadapt rate=$bytes_per_sec node=$node_id"
}
}
set source1 8
set source2 7
set source3 4
set source4 4
set sink1 1
set sink2 1
set sink3 1
set sink4 1
set con1 0
set con2 1
set con3 2
set con4 3
set connections 2
for {set i 0} { $i < $connections } {incr i} {
prepare_evalvid_trace $i
}
attach_TFRC_traffic $source1 $sink1 $con1 ;# stelnei o 8 ston 1
attach_TFRC_traffic $source2 $sink2 $con2 ;# stelnei o 13 ston 2
#attach_TFRC_traffic $source3 $sink3 $con3 ;# stelnei o 13 ston 2
#attach_TFRC_traffic $source4 $sink4 $con4 ;# stelnei o 13 ston 2
#=====================================================================================================================================================
proc finish {} {
global ns_ tracefile namfile
$ns_ flush-trace
close $tracefile
close $namfile
exit 0
}
for {set i 0 } { $i < $connections } {incr i} {
$ns_ at 325.0 "$vbr($i) start"
}
#for {set i 0 } { $i < $connections } {incr i} {
#$ns_ at [expr 325.0+$end_sim_time($i)] "$vbr($i) stop" ;#end_sim_time($i) has been set previously from prepare_evalvid_trace
#puts "vbr $i stops at [expr 325.0+$end_sim_time($i)]"
#}
$ns_ at [expr $simtime+0.01] "finish"
#set ragent [$node_(10) set ragent_]
#$ns_ at 0.2 "$ragent rt_down 30"
#$ns_ at 0.25 "finish"
$ns_ run

