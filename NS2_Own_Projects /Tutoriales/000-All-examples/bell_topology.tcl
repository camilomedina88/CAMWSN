#
# paced_bell_topology.tcl
#

# usage
if {$argc != 11} {
	puts "Usage: ns bell_topology.tcl \[flow_start\] \[tras_end\] \[flow_end\] \[num_long_tcp\] \[num_senders\] \[num_access\] \[core_buffer\] \[pace_type\] \[num_paced_access] \[q_max\] \[seed\]"
	puts " flow_start - time to start flows (seconds)"
	puts " tras_end - end time of transient state (seconds)"
	puts " flow_end - time to stop flows (seconds)"
	puts " num_long_tcp - num of long TCP sessions"
	puts " num_senders - num of senders attached to each access routers"
	puts " num_access - num of access routers connected to core router 0"
	puts " core_buffer - num of packets"
	puts " pace_type - 0: no pacing, 1: QLBP pacing, 2: TCP pacing"
	puts " num_paced_access - num of access routers from which long TCP flows are paced"
	puts " q_max - a parameter for QLBP pacer"
	puts " seed - random seed"
	exit
}

set i 0
set flow_start_time [lindex $argv $i]
set i [expr $i + 1]
set tras_end_time [lindex $argv $i]
set i [expr $i + 1]
set flow_stop_time [lindex $argv $i]
set i [expr $i + 1]
set num_long_tcps [lindex $argv $i]
set i [expr $i + 1]
set num_senders [lindex $argv $i]
set i [expr $i + 1]
set num_access_routers [lindex $argv $i]
set i [expr $i + 1]
set core_qlim [lindex $argv $i]
set i [expr $i + 1]
set pace_type [lindex $argv $i]
set i [expr $i + 1]
set num_paced_access [lindex $argv $i]
set i [expr $i + 1]
set q_max_ [lindex $argv $i]
set i [expr $i + 1]
set seed_ [lindex $argv $i]

# create a simulator project
set ns [new Simulator]
# 0 tells the simulator to set the current system time as seed
#ns-random 0
# Set random seed
global defaultRNG
$defaultRNG seed $seed_

# create trace file
set f_ns_tr_ [open ns-tr.tr w]
#$ns trace-all $f_ns_tr_
set f_core_que_tr_ [open core_queue_trace.tr w]
set f_core_que_mon_ [open core_queue_monitor.tr w]
set f_access_que_mon_ [open access_queue_monitor.tr w]
set f_long_tcp_seqno_ [open long_tcp_seqno.tr w]

# set parameters
set smpl_itvl 0.01

set num_short_tcps 0
set num_remote_routers 1
set num_receivers 2
set cbr_rate_ 1
set flow_type 0

set stage1_bw 100Mb
set stage1_qlim 10000
set stage2_bw 100Mb 
set stage2_delay 20ms
set stage2_qlim 10000
set core_bw 100Mb
set core_delay 20ms
set stage3_qlim 10000

set stg1_min_delay 0.001
set stg1_max_delay 0.01
set stg1_delay_RNG [new RNG]
$stg1_delay_RNG next-substream
set stg1_delay_ [new RandomVariable/Uniform]
$stg1_delay_ set min_ $stg1_min_delay
$stg1_delay_ set max_ $stg1_max_delay
$stg1_delay_ use-rng $stg1_delay_RNG

set rcv_min_delay 0.001
set rcv_max_delay 0.01
set rcv_delay_RNG [new RNG]
$rcv_delay_RNG next-substream
set rcv_delay_ [new RandomVariable/Uniform]
$rcv_delay_ set min_ $rcv_min_delay
$rcv_delay_ set max_ $rcv_max_delay
$rcv_delay_ use-rng $rcv_delay_RNG

set init_min_delay 0.01
set init_max_delay 100.0
set init_delay_RNG [new RNG]
$init_delay_RNG next-substream
set init_delay_ [new RandomVariable/Uniform]
$init_delay_ set min_ $init_min_delay
$init_delay_ set max_ $init_max_delay
$init_delay_ use-rng $init_delay_RNG

set rcv_RNG [new RNG]
$rcv_RNG next-substream


#### for a short-term flow's characteristics ####
set avg_interval 50
set intervalRNG [new RNG]
$intervalRNG next-substream
if { $flow_type == 0 } {
	set flow_interval_ [new RandomVariable/Pareto]
	$flow_interval_ set avg_ $avg_interval
	$flow_interval_ set shape_ 1.5
} else {
	set flow_interval_ [new RandomVariable/Exponential]
	$flow_interval_ set avg_ $avg_interval
}
$flow_interval_ use-rng $intervalRNG
set avg_flow_size 100
set sizeRNG [new RNG]
$sizeRNG next-substream
if { $flow_type == 0 } {
	set flow_size_ [new RandomVariable/Pareto]
	$flow_size_ set avg_ $avg_flow_size
	$flow_size_ set shape_ 1.2
} else {
	set flow_size_ [new RandomVariable/Exponential]
	$flow_size_ set avg_ $avg_flow_size
}
$flow_size_ use-rng $sizeRNG

#
# create a topology
#
proc create_topology {} {
	global ns num_senders num_access_routers num_paced_access num_remote_routers num_receivers
	global snd acr cr rcr rcv
	global stage1_bw stage1_delay stage1_qlim
	global stage2_bw stage2_delay stage2_qlim
	global stage3_qlim
	global core_bw core_delay core_qlim
	global stg1_delay_ rcv_delay_
	global access_que_mon_ f_access_que_mon_ 
	global f_core_que_tr_ core_que_mon_ f_core_que_mon_
	global q_max_ pace_type
	
	# create nodes	
	# create source nodes: each access router is attached with num_senders source nodes
	for {set i 0} {$i < $num_access_routers} {incr i} {
		for {set j 0} {$j < $num_senders} {incr j} {
			set snd([expr $i * $num_senders + $j]) [$ns node]
		}
	}
	# create access router nodes	
	for {set i 0} {$i < $num_access_routers} {incr i} {
		set acr($i) [$ns node]
	}
	# create core router nodes
	for {set i 0} {$i < 1} {incr i} {
		set cr($i) [$ns node]
	}
	# create remote core router nodes
	for {set i 0} {$i < $num_remote_routers} {incr i} {
		set rcr($i) [$ns node]
	}
	# create receiver nodes
	for {set i 0} {$i < $num_remote_routers} {incr i} {
		for {set j 0} {$j < $num_receivers} {incr j} {
			set rcv([expr $i * $num_receivers + $j]) [$ns node]
		}
	}
	
	# connect nodes
	# connect source nodes (snd) to access routers (acr), access routers (acr) to core router 0 (cr)
	for {set j 0} {$j < $num_senders} {incr j} {
		#set rnd_delay [$stg1_delay_ value]
		for {set i 0} {$i < $num_access_routers} {incr i} {
			set rnd_delay [$stg1_delay_ value]
			$ns duplex-link $snd([expr $i * $num_senders + $j]) $acr($i) $stage1_bw $rnd_delay DropTail
			$ns queue-limit $snd([expr $i * $num_senders + $j]) $acr($i) $stage1_qlim
			$ns queue-limit $acr($i) $snd([expr $i * $num_senders + $j]) $stage1_qlim
		}
	}
	for {set i 0} {$i < $num_access_routers} {incr i} {
		# QLBP pacing is enabled
		if {$pace_type == 1} {
			if {$i < $num_paced_access} {
				$ns duplex-link $acr($i) $cr(0) $stage2_bw $stage2_delay QLBP
				# create inbound pacers
				set pacedque_($i) [[$ns link $acr($i) $cr(0)] queue]
				$pacedque_($i) set umax_ $stage2_bw
				$pacedque_($i) set umin_ 1Mb
				$pacedque_($i) set qmax_ $q_max_
				$pacedque_($i) set linespeed_ $stage2_bw
				# create outbound pacers with no pacing effect
				set pque_($i) [[$ns link $cr(0) $acr($i)] queue]
				$pque_($i) set umax_ $stage2_bw
				$pque_($i) set umin_ $stage2_bw
				$pque_($i) set qmax_ $q_max_
				$pque_($i) set linespeed_ $stage2_bw
			} else {	
				$ns duplex-link $acr($i) $cr(0) $stage2_bw $stage2_delay DropTail
			}
		} else {
			$ns duplex-link $acr($i) $cr(0) $stage2_bw $stage2_delay DropTail
		}
		$ns queue-limit $acr($i) $cr(0) $stage2_qlim
		$ns queue-limit $cr(0) $acr($i) $stage2_qlim
		set access_que_mon_($i) [$ns monitor-queue $acr($i) $cr(0) $f_access_que_mon_]
	}
	# connect core router 0 to remote core routers
	for {set i 0} {$i < $num_remote_routers} {incr i} {
		$ns duplex-link $cr(0) $rcr($i) $core_bw $core_delay DropTail
		$ns queue-limit $cr(0) $rcr($i) $core_qlim
		$ns queue-limit $rcr($i) $cr(0) $core_qlim
	}
	# trace and monitor the core link
	#$ns trace-queue $cr(0) $rcr(0) $f_core_que_tr_
	set core_que_mon_ [$ns monitor-queue $cr(0) $rcr(0) $f_core_que_mon_]
	# connect remote core routers to destination nodes (rcv)
	for {set i 0} {$i < $num_remote_routers} {incr i} {
		for {set j 0} {$j < $num_receivers} {incr j} {
			set rnd_delay [$rcv_delay_ value]
			#puts "Delay for receiver [expr $i * $num_receivers + $j] is $rnd_delay seconds"
			$ns duplex-link $rcr($i) $rcv([expr $i * $num_receivers + $j]) $core_bw $rnd_delay DropTail
		}
	}
	for {set i 0} {$i < $num_remote_routers} {incr i} {
		for {set j 0} {$j < $num_receivers} {incr j} {
 			$ns queue-limit $rcr($i) $rcv([expr $i * $num_receivers + $j]) $stage3_qlim
			$ns queue-limit $rcv([expr $i * $num_receivers + $j]) $rcr($i) $stage3_qlim
		}
	}
}

#
# create long-term TCP sources
#
proc create_long_sources {} {
	global ns num_senders num_access_routers num_remote_routers num_receivers num_long_tcps
	global snd acr cr rcv
	global rcv_RNG pace_type num_paced_access
	global long_tcp_ ftp_ 
	
	set cwnd_max 32
	set rwnd_max 64
	set tcp_packet_size 1000
	
	# create a set of TCP sessions, num_long_tcps TCP sessions for each sender
	for {set i 0} {$i < $num_access_routers} {incr i} {
		for {set j 0} {$j < $num_senders} {incr j} {
			for {set k 0} {$k < $num_long_tcps} {incr k} {
				set session_idx [expr ($i * $num_senders + $j) * $num_long_tcps + $k]
				
				# create TCP sources
				#set long_tcp_($session_idx) [new Agent/TCP/Sack1]
				set long_tcp_($session_idx) [new Agent/TCP/Reno]
				$long_tcp_($session_idx) set window_ $rwnd_max
				$long_tcp_($session_idx) set maxcwnd_ $cwnd_max
				$long_tcp_($session_idx) set packetSize_ $tcp_packet_size
				$long_tcp_($session_idx) set fid_ $session_idx
				$long_tcp_($session_idx) set tcpTick_ 0.001
				$long_tcp_($session_idx) set overhead_ 0
				# TCP pacing is enabled
				if {$pace_type == 2 } {
					if {$i < $num_paced_access} {
						# use aggresive version of TCP pacing
						$long_tcp_($session_idx) set pace_packet_ 2
					}
				}
				$ns attach-agent $snd([expr $i * $num_senders + $j]) $long_tcp_($session_idx)
				
				# create TCP sinks and randomly assign them to num_receivers destination nodes
				#set tcp_snk_($session_idx) [new Agent/TCPSink/Sack1]
				set tcp_snk_($session_idx) [new Agent/TCPSink]
				$ns attach-agent $rcv([$rcv_RNG integer [expr $num_remote_routers * $num_receivers]]) $tcp_snk_($session_idx)
				
				# connect a TCP source to its corresponding sink
				$ns connect $long_tcp_($session_idx) $tcp_snk_($session_idx)		
				
				# create long-term TCP connection (FTP)
				set ftp_($session_idx) [new Application/FTP]
				$ftp_($session_idx) attach-agent $long_tcp_($session_idx)	
			}
		}
	}
}

#
# create short-term TCP sources
#
proc create_short_sources {} {
	global ns num_senders num_access_routers num_remote_routers num_receivers num_long_tcps num_short_tcps
	global snd acr cr rcv
	global rcv_RNG
	global short_tcp_ tcp_snk_
	
	set cwnd_max 64
	set rwnd_max 64
	set tcp_packet_size 960
	
	# create a set of TCP sessions, num_short_tcps TCP sessions for each sender
	# session_idx starts from $num_access_routers *  $num_senders * $num_long_tcps, the number of long TCP sessions
	for {set i 0} {$i < $num_access_routers} {incr i} {
		for {set j 0} {$j < $num_senders} {incr j} {
			for {set k 0} {$k < $num_short_tcps} {incr k} {
				set session_idx [expr $num_access_routers *  $num_senders * $num_long_tcps + ($i * $num_senders + $j) * $num_short_tcps + $k]
				
				# create TCP sources
				set short_tcp_($session_idx) [new Agent/TCP/Sack1]
				$short_tcp_($session_idx) set window_ $rwnd_max
				$short_tcp_($session_idx) set maxcwnd_ $cwnd_max
				$short_tcp_($session_idx) set packetSize_ $tcp_packet_size
				$short_tcp_($session_idx) set fid_ $session_idx
				$short_tcp_($session_idx) set tcpTick_ 0.001
				$ns attach-agent $snd([expr $i * $num_senders + $j]) $short_tcp_($session_idx)
				
				# create TCP sinks and randomly assign them to num_receivers destination nodes
				set tcp_snk_($session_idx) [new Agent/TCPSink/Sack1]
				$ns attach-agent $rcv([$rcv_RNG integer [expr $num_remote_routers * $num_receivers]]) $tcp_snk_($session_idx)
				
				# connect a TCP source to its corresponding sink
				$ns connect $short_tcp_($session_idx) $tcp_snk_($session_idx)
			}
		}
	}
}

#
# create CBR traffic between access routers and core router 0
#
proc create_cbr_sources {} {
	global ns num_access_routers acr cr
	global cbr_ cbr_rate_
	
	set udp_pktSize_ 1000
	
	for {set i 0} {$i < $num_access_routers} {incr i} {
		set udp_($i) [new Agent/UDP]
		$ns attach-agent $acr($i) $udp_($i)
		set null_($i) [new Agent/Null]
		$ns attach-agent $cr(0) $null_($i)
		$ns connect $udp_($i) $null_($i)
		$udp_($i) set fid_ $i
	
		set cbr_($i) [new Application/Traffic/CBR]
		$cbr_($i) attach-agent $udp_($i)
		$cbr_($i) set type_ CBR
		$cbr_($i) set packet_size_ $udp_pktSize_
		$cbr_($i) set rate_ $cbr_rate_
		$cbr_($i) set random_ false
	}	
}

# define a procedure to start long TCP sessions
proc start_long_tcp {} {
	global ns num_senders num_access_routers num_long_tcps
	global ftp_ init_delay_
	
	set now [$ns now]
	# create a set of TCP sessions, num_long_tcps TCP sessions for each sender
	for {set i 0} {$i < $num_access_routers} {incr i} {
		for {set j 0} {$j < $num_senders} {incr j} {
			for {set k 0} {$k < $num_long_tcps} {incr k} {
				set session_idx [expr ($i * $num_senders + $j) * $num_long_tcps + $k]
				$ns at [expr $now + [$init_delay_ value]] "$ftp_($session_idx) start"
				#$ns at $now "$ftp_($session_idx) start"		
			}
		}
	}
}

# define a procedure to stop long TCP sessions
proc stop_long_tcp {} {
	global ns num_senders num_access_routers num_long_tcps
	global ftp_ 
	
	set now [$ns now]
	# create a set of TCP sessions, num_long_tcps TCP sessions for each sender
	for {set i 0} {$i < $num_access_routers} {incr i} {
		for {set j 0} {$j < $num_senders} {incr j} {
			for {set k 0} {$k < $num_long_tcps} {incr k} {
				set session_idx [expr ($i * $num_senders + $j) * $num_long_tcps + $k]
				$ns at $now "$ftp_($session_idx) stop"			
			}
		}
	}
}

# define a procedure to start all short TCP sessions
proc start_short_tcp {} {
	global ns num_senders num_access_routers num_long_tcps num_short_tcps init_delay_
	
	set now [$ns now]
	for {set i 0} {$i < $num_access_routers} {incr i} {
		for {set j 0} {$j < $num_senders} {incr j} {
			for {set k 0} {$k < $num_short_tcps} {incr k} {
				set session_idx [expr $num_access_routers *  $num_senders * $num_long_tcps + ($i * $num_senders + $j) * $num_short_tcps + $k]
				$ns at [expr $now + [$init_delay_ value]] "start-short-tcp-flow 0 $session_idx [expr $i * $num_senders + $j]"			
			}
		}
	}
}

# define a procedure to stop all short TCP sessions
proc stop_short_tcp {} {
	global ns num_senders num_access_routers num_long_tcps num_short_tcps
	
	set now [$ns now]
	for {set i 0} {$i < $num_access_routers} {incr i} {
		for {set j 0} {$j < $num_senders} {incr j} {
			for {set k 0} {$k < $num_short_tcps} {incr k} {
				set session_idx [expr $num_access_routers *  $num_senders * $num_long_tcps + ($i * $num_senders + $j) * $num_short_tcps + $k]
				$ns at $now "stop-short-tcp-flow 1 $session_idx [expr $i * $num_senders + $j] 0"			
			}
		}
	}
}

# define a procedure to specify a particular number of packets for a short TCP session
proc start-short-tcp-flow { ifreset session_idx sender_idx } {
	global ns short_tcp_ tcp_snk_ flow_size_
	
	if { $ifreset == 1 } {
		$short_tcp_($session_idx) reset
		$tcp_snk_($session_idx) reset
	}
	
	set size_ [expr round([$flow_size_ value])]
	$short_tcp_($session_idx) proc done {} "stop-short-tcp-flow 0 $session_idx $sender_idx $size_"
	$short_tcp_($session_idx) advanceby $size_
}

# define a procedure to schedule another short TCP session after the current one is done
proc stop-short-tcp-flow { ifstop session_idx sender_idx size_ } {
	global ns snd short_tcp_ flow_interval_
	
	if { $ifstop == 0 } {
		set now_ [$ns now]
		set interval_ [$flow_interval_ value]
		$ns at [expr $now_ + $interval_] "start-short-tcp-flow 1 $session_idx $sender_idx"
	} else {
		$ns detach-agent $snd($sender_idx) $short_tcp_($session_idx)
	}
}

# define a procedure to start CBR flows
proc start_cbr_flow {} {
	global ns num_access_routers cbr_
	set now [$ns now]
	for {set i 0} {$i < $num_access_routers} {incr i} {
		$ns at $now "$cbr_($i) start"
	}		
}

# define a procedure to stop CBR flows
proc stop_cbr_flow {} {
	global ns num_access_routers cbr_
	set now [$ns now]
	for {set i 0} {$i < $num_access_routers} {incr i} {
		$ns at $now "$cbr_($i) stop"
	}
}

# print queue sizes
proc record_core_queue {} {
	global ns smpl_itvl core_que_mon_ f_core_que_mon_
	
	set curr_time [$ns now]
	set core_que_len [$core_que_mon_ set pkts_] 
	
	puts -nonewline $f_core_que_mon_ "$curr_time $core_que_len "
	puts $f_core_que_mon_ " "
	
	$ns at [expr $curr_time + $smpl_itvl] "record_core_queue"	
}

# print queue sizes
proc record_access_queue {} {
	global ns smpl_itvl num_access_routers access_que_mon_ f_access_que_mon_
	
	set curr_time [$ns now]
	puts -nonewline $f_access_que_mon_ "$curr_time "
	for {set i 0} {$i < $num_access_routers} {incr i} {
		puts -nonewline $f_access_que_mon_ "[$access_que_mon_($i) set pkts_] "
	}
	puts $f_access_que_mon_ " "
}

# define a procedure to start long TCP sessions
proc report_seqno {} {
	global ns num_senders num_access_routers num_long_tcps
	global long_tcp_ f_long_tcp_seqno_
	
	# create a set of TCP sessions, num_long_tcps TCP sessions for each sender
	for {set i 0} {$i < $num_access_routers} {incr i} {
		for {set j 0} {$j < $num_senders} {incr j} {
			for {set k 0} {$k < $num_long_tcps} {incr k} {
				set session_idx [expr ($i * $num_senders + $j) * $num_long_tcps + $k]
				#puts -nonewline $f_long_tcp_seqno_ "[$long_tcp_($session_idx) set t_seqno_] [$long_tcp_($session_idx) set seqno_] "
				puts -nonewline $f_long_tcp_seqno_ "[$long_tcp_($session_idx) set t_seqno_] "
			}
		}
	}
	puts $f_long_tcp_seqno_ " "
}

# define a "finish" procedure
proc finish {} {
	global ns 
	global f_ns_tr_ f_core_que_tr_ f_core_que_mon_ f_access_que_mon_ f_long_tcp_seqno_
		
	$ns flush-trace
	close $f_ns_tr_
	close $f_core_que_tr_
	close $f_core_que_mon_
	close $f_access_que_mon_
	close $f_long_tcp_seqno_
	
	exit 0
}

# schedule events for simulation
create_topology

create_long_sources
#create_short_sources
#create_cbr_sources

$ns at $flow_start_time "record_core_queue"

$ns at $flow_start_time "start_long_tcp"
#$ns at $flow_start_time "start_cbr_flow"
#$ns at $flow_start_time "start_short_tcp"

$ns at $tras_end_time "report_seqno"

$ns at [expr $flow_stop_time - 0.001] "record_access_queue"
$ns at [expr $flow_stop_time - 0.001] "report_seqno"

$ns at $flow_stop_time "stop_long_tcp"
#$ns at $flow_stop_time "stop_cbr_flow"
#$ns at $flow_stop_time "stop_short_tcp"

$ns at [expr $flow_stop_time + 0.001] "finish"
$ns at [expr $flow_stop_time + 0.002] "$ns halt"

# run simulation
$ns run
				