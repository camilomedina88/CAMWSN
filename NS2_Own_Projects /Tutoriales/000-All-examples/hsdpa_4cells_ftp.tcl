# scenario configuration
if {$argc < 4} {
	puts "some arguments are missing"
	exit 0
} else {
	set scenario_file [lindex $argv 0]
	set scenario [open $scenario_file]
	while {[gets $scenario line] >= 0} {
		if { [string match "#*" $line] != 1 } {
			set fields [split $line "="]
			set varName [lindex $fields 0]
			set varValue [lindex $fields 1]		
			switch $varName {
				"IDEAL" {
					set IDEAL $varValue
				}
				"APP_TYPE" {
					set APP_TYPE $varValue
				}
				"TCP_MSS" {
					set TCP_MSS $varValue
				}
				"FLOW_CONTROL_MODE" {
					set FLOW_CONTROL_MODE $varValue
				}
				"RLC_BUFFER_SIZE" {
					set RLC_BUFFER_SIZE $varValue
				}
				"MAC_HS_BUFFER_SIZE" {
					set MAC_HS_BUFFER_SIZE $varValue
				}
				"CREDIT_ALLOCATION_INTERVAL" {
					set CREDIT_ALLOCATION_INTERVAL $varValue
				}
				"FLOW_CONTROL_RTT" {
					set FLOW_CONTROL_RTT $varValue
				}
				"SCHEDULING_MODE" {
					set SCHEDULING_MODE $varValue
				}
				"SCHEDULING_ALPHA" {
					set SCHEDULING_ALPHA $varValue
				}
				"MIN_SPEED" {
					set MIN_SPEED $varValue
				}
				"MAX_SPEED" {
					set MAX_SPEED $varValue
				}
				"CHANNEL_TYPE" {
					set CHANNEL_TYPE $varValue
				}
				"MOBILITY_ENABLED" {
					set MOBILITY_ENABLED $varValue
				}
				"Iub_DELAY" {
					set Iub_DELAY $varValue
				}
				"FAST_RETRANSMIT" {
					set FAST_RETRANSMIT $varValue
				}	
				"ENHANCED_FLOW_CONTROL" {
					set ENHANCED_FLOW_CONTROL $varValue
				}
				"FLOW_CONTROL_DISABLED" {
					set FLOW_CONTROL_DISABLED $varValue
				}
				"CAP_REQ_HOLDDOWN_INTERVAL" {
					set CAP_REQ_HOLDDOWN_INTERVAL $varValue
				}
				"FC_UPDATE_INTERVAL" {
					set FC_UPDATE_INTERVAL $varValue
				}
				default {
					puts "Error: unrecognized line in the file: $scenario_file"
					puts "Empty lines must have # at the begining"
					exit 0
				}
			}
		}
		
		
	}
	close $scenario
	set ITER [lindex $argv 1]
	set NUM_USERS [lindex $argv 2]
	set SIMULATION_TIME [lindex $argv 3]

}

global ns

remove-all-packet-headers
add-packet-header MAC_HS RLC LL Mac TCP IP Common Flags

set ns [new Simulator]
#$ns use-scheduler Heap
#$ns use-scheduler Calendar2

# global flags:
$ns set hsdschEnabled_ 1
$ns set mixed_AM_UM_mode_ 0
# main trace file:
set f [open "temp/out.tr" w]
set mobilitytracefile "temp/mobility.tr"
set mob_tr_file [open $mobilitytracefile w]
#trace all events on Iub and other wired links
#Trace set show_tcphdr_ 1
#$ns trace-all $f
#---------------------------------- procedures ------------------------
Simulator instproc finish {} {
	global ns
	global f
	global rnc bs ue NUM_USERS NUM_CELLS
	$ns flush-trace
	close $f
	global src ftpsrc
	# tcp trace file:
	set tcptracefile "temp/tcp_stats.tr"
	set f_tcp [open $tcptracefile w]
	puts $f_tcp "time\t\tsrc\tdest\ttx_pkts\ttx_bytes rx_acks rtx_timeouts rtx_pkts rtx_bytes cwnd_cuts"
	close $f_tcp
	for { set i 0 } { $i < $NUM_USERS } { incr i } {
		#$ftpsrc($i) start
		$src($i) print_tcp_traced_var $tcptracefile
	}

	set rnc_file "temp/rlc_stats.tr"
	set f_rlc [open $rnc_file w]
	puts $f_rlc "RNC_LL\ttype\trlc_tx\trlc_rtx\trlc_ttx\trlc_rx\trlc_rrx\trlc_trx\trlc_trxttx"
	close $f_rlc
	set mac_file "temp/mac_stats.tr"
	set f_mac [open $mac_file w]
	puts $f_mac "cell\tmac_tx\tmac_rtx\tmac_ttx\tmac_rx\tmac_rrx\tmac_trx\tmac_erx\tmac_trxttx\trlc_rx\trlc_tx\trlc_dropped"
	close $f_mac
	set rnc_queue_file "temp/rnc_avg_queue_length.tr"
	set f_rnc_queue [open $rnc_queue_file w]
	puts $f_rnc_queue "cell\tflow\tavg_rnc_qlen"
	close $f_rnc_queue
	set bs_queue_file "temp/bs_avg_queue_length.tr"
	set f_bs_queue [open $bs_queue_file w]
	puts $f_bs_queue "cell\tflow\tavg_bs_qlen"
	close $f_bs_queue
	set flow_control_file "temp/flow_control_stats.tr"
	set f_flow_control [open $flow_control_file w]
	puts $f_flow_control "cell\tcap_req\tcap_alloc\ttotal_stallings\tstalling_fraction\thsdsch_utilization\tprob_empty_buffer\ttotal_bytes_tx\ttotal_capacity"
	close $f_flow_control	
	for { set i 0 } { $i < $NUM_CELLS } { incr i } {
		#print rlc packet stats
		$rnc print_rlc_stats_rnc $i $rnc_file		
		#print mac_hs packet stats
		$bs($i) print_mac_hs_stats $mac_file
		#print avg rnc queue length per flow
		$rnc print_rnc_queue_length $i $rnc_queue_file
		#print avg bs queue length per flow
		$bs($i) print_bs_queue_length $bs_queue_file
		#print flow control stats per priority queue
		$bs($i) print_flow_control_stats $flow_control_file
	}
	set rlc_file "temp/user_rlc_stats.tr"
	set f_rlc [open $rlc_file w]
	puts $f_rlc "node\ttype\trlc_tx\trlc_rtx\trlc_ttx\trlc_rx\trlc_rrx\trlc_trx\trlc_trxttx\trnc_queueing\tIub\tbs_queueing\tmac-hs\ttotal_rlc"
	close $f_rlc
	set mac_file "temp/user_mac_stats.tr"
	set f_mac [open $mac_file w]
	puts $f_mac "node\tmac_tx\tmac_rtx\tmac_ttx\tmac_rx\tmac_rrx\tmac_trx\tmac_erx\tmac_trxttx\trlc_rx\trlc_tx\trlc_dropped\tmac_erx1\tmac_erx2\tmac_erx3"
	close $f_mac
	
	for { set i 0 } { $i < $NUM_USERS } { incr i } {
		$ue($i) print_rlc_stats_ue $rlc_file
		$ue($i) print_mac_hs_stats $mac_file
		set pckt_delay_file "temp/user-[expr $i]-packet_delay.tr"
		$ue($i) print_packet_delays $pckt_delay_file
	}


	set t_now [clock seconds]
	set t [clock format $t_now -format %Y-%m-%d-%H:%M:%S]
	puts "r- $t Simulation ended"
	exit 0
}

#----------------- Global Settings for RLC/HS-MAC/PHY layers ----------
# RLC AM-HS entity settings: used at RNC only
UMTS/RLC/AMHS set buffer_level_max_ $RLC_BUFFER_SIZE 
UMTS/RLC/AMHS set flow_max_ $NUM_USERS
UMTS/RLC/AMHS set priority_max_ 1
UMTS/RLC/AMHS set credit_allocation_interval_ $CREDIT_ALLOCATION_INTERVAL

UMTS/RLC/AMHS set flow_control_enhanced_ $ENHANCED_FLOW_CONTROL
UMTS/RLC/AMHS set flow_control_disabled_ $FLOW_CONTROL_DISABLED
if {$FLOW_CONTROL_MODE == 5 } {
	UMTS/RLC/AMHS set flow_control_from_bs_ 1
	Mac/Hsdpa set Rdef_	100kb
	Mac/Hsdpa set Tu_	30ms
#	Mac/Hsdpa set Tu_	$FC_UPDATE_INTERVAL
	Mac/Hsdpa set a_	1.0
	Mac/Hsdpa set Tm_	50ms
	Mac/Hsdpa set Tw_	100ms
#	Mac/Hsdpa set TTIrlc_	10ms
}
if {$FLOW_CONTROL_MODE == 6 || $FLOW_CONTROL_MODE == 7} {
	UMTS/RLC/AMHS set flow_control_from_bs_ 1
	#AMM: 31/12/2007: added new variables for new flow control algorithm (CQI-based Flow Control)
	Mac/Hsdpa set avg_cqi_alpha_	0.1
	Mac/Hsdpa set fc_update_interval_	50ms
#	Mac/Hsdpa set fc_update_interval_	$Iub_DELAY
#	Mac/Hsdpa set fc_update_interval_	$FC_UPDATE_INTERVAL
	Mac/Hsdpa set max_fc_cqi_	22
}
# initial credits: must match between AMHS & Hsdpa
UMTS/RLC/AMHS set initial_credits_ 20
#/AMM: timer to hold down capacity-requests for a short interval while packets are arriving at RNC
# to avoid sending multiple requests
UMTS/RLC/AMHS set cap_req_holddown_interval_ $CAP_REQ_HOLDDOWN_INTERVAL
UMTS/RLC/AMHS set Iub_frame_period_	1000us


Mac/Hsdpa set flow_control_enhanced_ $ENHANCED_FLOW_CONTROL
Mac/Hsdpa set initial_credits_ 20

# MAC-hs entitiy settings: used at the BS only
Mac/Hsdpa set flow_max_ $NUM_USERS
Mac/Hsdpa set priority_max_ 1
Mac/Hsdpa set flow_control_mode_ $FLOW_CONTROL_MODE
Mac/Hsdpa set credit_allocation_interval_ $CREDIT_ALLOCATION_INTERVAL
Mac/Hsdpa set flow_control_rtt_ $FLOW_CONTROL_RTT
Mac/Hsdpa set max_mac_hs_buffer_level_ $MAC_HS_BUFFER_SIZE

Mac/Hsdpa set scheduler_type_ $SCHEDULING_MODE
# a flag to turn on integerated physical simulator instead of input trace files
Mac/Hsdpa set integerated_phy_sim_ 1
# Physical channel simulation parameters used in SNR/CQI generation
# global for all UE's
Mac/Hsdpa set min_block_duration_	10
Mac/Hsdpa set max_block_duration_	100
Mac/Hsdpa set CQIdelayinTTI_		3
Mac/Hsdpa set HARQcycle_		6
Mac/Hsdpa set lambda_			0.15
Mac/Hsdpa set samples_per_fade_		100
Mac/Hsdpa set max_samples_per_TTI_	10
Mac/Hsdpa set shadow_std_		8
Mac/Hsdpa set d_corr_			40
Mac/Hsdpa set PTx_			38
Mac/Hsdpa set GT_			17
Mac/Hsdpa set Linit_			137.4
Mac/Hsdpa set distlossexp_		3.52
Mac/Hsdpa set Iintra_			30
Mac/Hsdpa set Iinter_			-70
Mac/Hsdpa set minCQI_			0
Mac/Hsdpa set maxCQI_			22
if {$IDEAL == 1} {
	Mac/Hsdpa set maxCQI_			30
	Mac/Hsdpa set use_max_bandwidth_	1
}

# control weather to use online PHY SNR & CQI block generation or use offline files
Mac/Hsdpa set itpp_write_to_file_	0
Mac/Hsdpa set itpp_read_from_file_	0

#---------------------------- Topology configurayion -----------------
#first, setup UTRAN: rnc, bs and ue's
$ns node-config -UmtsNodeType rnc
# RNC Node address is 0
set rnc [$ns create-multicell-Umtsnode]

$ns node-config -UmtsNodeType bs \
		-downlinkBW 32kbs \
		-downlinkTTI 10ms \
		-uplinkBW 32kbs \
		-uplinkTTI 10ms
# Node address for bs0, bs1, bs2,,, etc is 1, 2, 3,,,$NUM_CELLS
set NUM_CELLS 4
for { set i 0 } { $i < $NUM_CELLS } { incr i } {
	set bs($i) [$ns create-multicell-Umtsnode]
	$ns setup-Iub-multicell $bs($i) $rnc 155Mbit 155Mbit $Iub_DELAY $Iub_DELAY DummyDropTail 50000
}

$ns node-config -UmtsNodeType ue \
		-radioNetworkController $rnc
# Node address for ue0, ue1, ue2,,, etc is NUM_CELLS+1, NUM_CELLS+2,,,, NUM_CELLS+NUM_USERS
for { set i 0 } { $i < $NUM_USERS } { incr i } {
	set ue($i) [$ns create-multicell-Umtsnode]
	$ue($i) set fid_ $i
}

# modify the default link q behaivour to drop tail not front
Queue/DropTail set drop_front_ false
Queue set limit_ 500

#second, setup the core netowrk: sgsn and ggsn
# Node address for sgsn, ggsn is $NUM_USERS+2,$NUM_USERS+3
set sgsn [$ns node]
set ggsn [$ns node]
$ns duplex-link $rnc $sgsn 155Mbit 6ms DropTail
$ns duplex-link $sgsn $ggsn 155Mbit 6ms DropTail
$rnc add-gateway $sgsn

#third, setup servers and attach them to core network
# number of servers is: 1 server for 10 users. if users less than 10, 1 server is used
# Node address for servers starts at $NUM_USERS+4
set NUM_SERVERS [expr $NUM_USERS/10]
if {$NUM_SERVERS < 1} {
	set NUM_SERVERS 1
}
for { set i 0 } { $i < $NUM_SERVERS } { incr i } {
	set server($i) [$ns node]
	$ns duplex-link $ggsn $server($i) 100Mbit 8ms DropTail
}

#---------------------------- Error Model ------------------
#fifth, configure the channel model for each UE
# setup the the channel type
Mac/Hsdpa set channel_type_	$CHANNEL_TYPE
# set the rng seed in IT++ for this iteration to be the ITER
Mac/Hsdpa set itpp_rng_seed_	$ITER

#----------------------------------- HS-DSCH Connections --------------
#forth, create HS-DSCH channel in each cell
$ns node-config -llType UMTS/RLC/AM \
		-uplinkBW 64kbs \
		-uplinkTTI 10ms \
      		-hs_downlinkTTI 2ms \
      		-hs_downlinkBW 64kbs

# setup the Hsdpa cell in this BS, create AM-HS, MAC-HS & PHY entities
#set SNR_DIR "snr_cqi_input/snr_blocks_iter-[expr $ITER]_N-[expr $NUM_USERS]"
#file mkdir $SNR_DIR
for {set i 0} {$i<$NUM_CELLS} { incr i } {
	$ns setup-hsdsch-cell $bs($i) $rnc
	#load the SNR-BLER Matrix from a pre-generated file
	$bs($i) loadSnrBlerMatrix "snr_cqi_input/SNRBLERMatrix"
	set nif [$bs($i) set hsdsch_nif_]
	set mac [$bs($i) set mac_($nif)]	
#	$mac setSNR_blocks_dir $SNR_DIR
}

#----------------------------------- Mobility Setup --------------
# enable tracing for mobility activities
$ns set-mobility-trace $mob_tr_file
set CELL_RADIUS 500	;# = 1 km
# create the cellular topology and each cell (site) location
# we use a simple cellular topology represnted by rectangular plane were 
# the 4 cells are layed-out 2 cells per row and 2 cells per column as follows:
#
#	  |     |
#	--3-- --4--
#	  |     |  
#	--1-- --2--
#	  |     |  
#
# The horizontal and vertical inter-site distance is 2 * cell_radius.
# The distance between edge cells and the borders is 1 * cell_radius.
# Therefore the area of the plane = 4*cell_radius X 4*cell_radius

# first, set the basestations positions according to above layout
set r $CELL_RADIUS
$bs(0) cell_site_position  $r $r
$bs(1) cell_site_position  [expr 3*$r] $r
$bs(2) cell_site_position  $r [expr 3*$r]
$bs(3) cell_site_position  [expr 3*$r] [expr 3*$r]
# save the list of basestations inside the UE structure
for {set i 0} {$i < $NUM_USERS} {incr i} {
	for {set j 0} {$j<$NUM_CELLS} { incr j } {
		$ue($i) set candidate_cells_($j) $bs($j)
	}
}
# second, setup random number rng for speed and position in the Random Waypoint model
# rng for speed:
set rng_speed [new RNG]
# rng for x position:
set rng_x_position [new RNG]
# rng for y position:
set rng_y_position [new RNG]
# set the RNGs to the correct substream, use the iteration number to
# seed the rng so that we can re-produce the same results for each iteration
for {set j 1} {$j < $ITER} {incr j} {
	$rng_speed next-substream
	$rng_x_position next-substream
	$rng_y_position next-substream
}
# rand var for speed:
set random_speed [new RandomVariable/Uniform]
$random_speed set min_ $MIN_SPEED
$random_speed set max_ $MAX_SPEED
$random_speed use-rng $rng_speed 
# randvar for x position:
set random_x_position [new RandomVariable/Uniform]
$random_x_position set min_ 0
$random_x_position set max_ [expr 4*$CELL_RADIUS]
$random_x_position use-rng $rng_x_position 
# randvar for y position:
set random_y_position [new RandomVariable/Uniform]
$random_y_position set min_ 0
$random_y_position set max_ [expr 4*$CELL_RADIUS]
$random_y_position use-rng $rng_y_position 
# then, assign the randvar to each user internal variable
for {set i 0} {$i < $NUM_USERS} {incr i} {
	$ue($i) ue_mobility_ranomvar $random_speed $random_x_position $random_y_position
}

# then, we initialize the initial positions, destination and speed for each user
#  sampled from the long-run stationary distribution instead of unifrom
# stationary distribution according to:
# W. Navidi and T. Camp. Stationary distributions for the random waypoint mobility model. 
# Technical Report MCS-03-04, Colorado School of Mines, 2003.
set tmp_rng [new RNG]
# set the RNGs to the correct substream, use the iteration number to
# seed the rng so that we can re-produce the same results for each iteration
for {set j 1} {$j < $ITER} {incr j} {
	$tmp_rng next-substream
}
set std_uniform [new RandomVariable/Uniform]
$std_uniform set min_ 0
$std_uniform set max_ 1
$std_uniform use-rng $tmp_rng
for {set i 0} {$i < $NUM_USERS} {incr i} {
	# if mobility is ON, we distrbute the users over
	# the celluar plane according to the Random Waypoint (without pause) 
	# Mobility Model
	if { $MOBILITY_ENABLED == 1 } {
		#sample initial speed from stationary distribution
		set u [$std_uniform value]
		set s0 [expr pow($MAX_SPEED,$u) / pow($MIN_SPEED,$u-1)]
		# use rejection sampling the find an initial position and destination 
		# that fit the stationary distribution:
		set found 0
		while {$found == 0} {
			set x1 [$std_uniform value]
			set y1 [$std_uniform value]
			set x2 [$std_uniform value]
			set y2 [$std_uniform value]
			set r [expr (sqrt(pow(($x2 - $x1),2) + pow(($y2 - $y1),2)))/sqrt(2) ]
			set u1 [$std_uniform value]
			if {$u1 < $r} {
				#accept (x1,y1) & (x2,y2)
				set found 1
			} else {
	#			puts "UE [$ue($i) id]: rejected the sample: (x1,y1)=[format "(%.2f,%.2f)" $x1 $y1], (x2,y2)=[format "(%.2f,%.2f)" $x2 $y2], r=[format "%f" $r], u1=[format "%f" $u1]"
			}	
		}
		set u2 [$std_uniform value]
		set x0 [expr $u2*$x1 + (1-$u2)*$x2]
		set y0 [expr $u2*$y1 + (1-$u2)*$y2]
		# adjust the scale from unit scale to 4*CELL_RADIUS
		set x0 [expr $x0 *4*$CELL_RADIUS]
		set y0 [expr $y0 *4*$CELL_RADIUS]
		set x2 [expr $x2 *4*$CELL_RADIUS]
		set y2 [expr $y2 *4*$CELL_RADIUS]
		$ue($i) set speed_ $s0
		$ue($i) set pos_x_ $x0
		$ue($i) set pos_y_ $y0
		$ue($i) set dest_x_ $x2
		$ue($i) set dest_y_ $y2
	} else {
	# if mobility is OFF, we distribute the users uniformely over
	# the cellular plane
		#use plain uniform from the start
		set s0 [[$ue($i) set random_speed_] value]
		set x0 [[$ue($i) set random_x_] value]
		set y0 [[$ue($i) set random_y_] value]
		set s0 0.5
		set x0 [expr $r - 10]
		set y0 $r
		$ue($i) set speed_ $s0
		$ue($i) set pos_x_ $x0
		$ue($i) set pos_y_ $y0
#		puts "user $i located at ($x0 , $y0) at speed $s0"
	}
}

# finally, we either start Random Waypoint process for each user
# or just attach the user to the closest cell
for {set i 0} {$i < $NUM_USERS} {incr i} {
	if { $MOBILITY_ENABLED == 1 } {
		# start the random walk which will first attach the user to
		# the initial cell and then schedul all handovers in the way
		$ue($i) start_new_random_waypoint
	} else {
		# mobility is OFF so assign the UE to the closest cell
		set s0 [$ue($i) set speed_]
		set x0 [$ue($i) set pos_x_]
		set y0 [$ue($i) set pos_y_]
		set home_cell [$ue($i) find_closest_cell $x0 $y0]
		set cell_x [$home_cell set pos_x_]
		set cell_y [$home_cell set pos_y_]
		# compute the distance, UE is at (x0,y0) moving on a circle around the cell
		$ue($i) update_channel_parameters $x0 $y0 $x0 $y0 $cell_x $cell_y $s0
		# attached to cell	
		# this will create the HsdpaMac objects and the associated physical channel HsdpaChannel using IT++ class with the defaults parameters above
		$ns attach-hsdsch-cell $home_cell $ue($i)
#		puts "attached user $i to cell [$home_cell id]"
	}
}


#------------------------------------ Application config  -------------------------
#Now, setup the application: use the recommned traffic model
Agent/TCP/FullTcp set segsize_ $TCP_MSS

for {set i 0} {$i<$NUM_USERS} { incr i } {
	#TCP transport agents	
	set src($i) [new Agent/TCP/Newreno]
#	set src($i) [new Agent/TCP]
#	set src($i) [new Agent/TCP/FullTcp/Newreno]
	$src($i) set fid_ $i
	$src($i) set prio_ 0
	set sink($i) [new Agent/TCPSink]
#	set sink($i) [new Agent/TCP/FullTcp/Newreno]
#	$sink($i) listen
	
	#FTP sources
	set ftpsrc($i) [new Application/FTP]
	$ftpsrc($i) attach-agent $src($i)

	#Connections
	set k [expr $i % $NUM_SERVERS]
	$ns attach-agent $server($k) $src($i)

	$ns attach-agent $ue($i) $sink($i)
	$ns connect $src($i) $sink($i)
	#first activate the flow just before the appropriate time instance
	set starttime 0.0001
	set tmp_bs [$ue($i) set bs_]
	$ns at $starttime "$tmp_bs activate_flow $i"
	set starttime [expr $starttime + .0001]
	$ns at $starttime "$ftpsrc($i) start"
}
#----------------------------- Trace Section --------------------------------
# 1 = summary
# 2 = summary + UTRAN downlink
# 3 = summary + UTRAN downlink + UTRAN uplinks
# 4 = all
set trace_detail_level 1

#trace when IP packet starts at the server
for { set i 0 } { $i < $NUM_SERVERS } { incr i } {
	$ns trace-queue $server($i) $ggsn $f
}
if { $trace_detail_level >= 4 } {
	#trace ggsn to sgsn
	$ns trace-queue $ggsn $sgsn $f
}

#trace when IP packets arrive at RNC buffer
$ns trace-queue $sgsn $rnc $f

for { set i 0 } { $i < $NUM_CELLS } { incr i } {
	if { $trace_detail_level >= 2 } {
		#trace when RLC PDUs arrive at BS buffer
		$ns trace-rlc-queue $rnc $bs($i) $f

		# trace RLC PDUs being forwarded (hop 'h' event only) to Iub from RLC entity at the RNC
		#	$rnc trace-outlink-multicell $f $i $bs($i)
		# trace RLC PDUs being queued at Node B MAC-hs entity and then sent (dequeued) in HARQ Transport Blocks (MAC-hs blocks)
		$bs($i) trace-outlink-multicell $f 2 $bs($i)
	}
}

for { set i 0 } {$i < $NUM_USERS } {incr i } {
	if { $trace_detail_level >= 2 } {
		# trace RLC PDU being received at RLC entity in each UE
		# this trace is required for calculating RLC throughput & queue sizes
		$ue($i) trace-inlink $f 2
	}
	# trace RLC SDU or traffic packets being sent to upper layer from RLC entity in each UE
	# this trace is required for calculating upper layers throughput e.g. CBR, TCP
	$ue($i) trace-inlink-tcp $f 2
}
#----------------------------- uplink direction:
for {set i 0} {$i<$NUM_USERS} { incr i } {
	if { $trace_detail_level >= 3 } {
		#at the BS: nif#0 is FACH, nif#1 is RACH, nif#2 is HS-DSCH, nif#3 is DCH for ue0, nif#4 is DCH for ue1 ... etc	
		# tracing for DCH traffic per UE in the uplink direction
		# trace '+' & '-' event of packets & acks being sent from RLC entity at each UE
		set base [$ue($i) set bs_]
		$ue($i) trace-outlink-multicell $f 3 $base
		# trace RLC PDU from UE1 being received at Node B	
		set nif [$ue($i) set uplink_dch_mac_]
		$base trace-inlink $f $nif
	}
}
for { set i 0 } { $i < $NUM_CELLS } { incr i } {
	if { $trace_detail_level >= 3 } {
		# Iub uplink direction
		$ns trace-rlc-queue $bs($i) $rnc $f
		# trace RLC SDU or traffic packets being sent to upper layer from RLC entity at the RNC
		$rnc trace-inlink-tcp-multicell $f $i $bs($i)
	}
}		

for { set i 0 } { $i < $NUM_SERVERS } { incr i } {
	if { $trace_detail_level >= 4 } {
		$ns trace-queue $rnc $sgsn $f
		$ns trace-queue $sgsn $ggsn $f
		# trace ACKs recived by servers
		$ns trace-queue $ggsn $server($i) $f		
	}
}

#------------------------------------------------------------------------------------------
# for debugging; plot TCP window size over time
#set win_trace [open "temp/cwnd_trace.tr" w]
#for {set i 0} {$i<$NUM_USERS} { incr i } {
#	$src($i) attach $win_trace
#	$src($i) tracevar cwnd_
#}

$ns at $SIMULATION_TIME "$ns finish"

set t_now [clock seconds]
set t [clock format $t_now -format %Y-%m-%d-%H:%M:%S]
puts "r+ $t Simulation is running ... simulation time = $SIMULATION_TIME seconds, number of users = $NUM_USERS"
$ns run
