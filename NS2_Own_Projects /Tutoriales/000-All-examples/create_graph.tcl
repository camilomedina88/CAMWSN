#
# Copyright (c) 2007  NEC Laboratories China.
# All rights reserved.
#
# Released under the GNU General Public License version 2.
#
# Authors:
# - Gang Wang (wanggang@research.nec.com.cn)
# - Yong Xia   (xiayong@research.nec.com.cn)
#
#
# $Id: create_graph.tcl,v 1.5 2008/11/03 09:08:54 wanggang Exp $
#
# This code creates the graphs with settable parameters. It
# also contains the figure parameters for various metrics.
#


# include David Harrison's graphing package
source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/file-tools.tcl
source $env(NS)/tcl/rpi/link-stats.tcl
source $env(NS)/tcl/rpi/tcp-stats.tcl
source $env(NS)/tcl/rpi/graph.tcl

# create_graph base class
Class Create_graph

Create_graph instproc init args {
    # system settings
    $self instvar show_bottleneck_stats_   ;# show bottleneck statistics
    $self instvar show_graph_ftp_          ;# show ftp statistics main switch
    $self instvar show_graph_http_         ;# http main switch
    $self instvar show_graph_voice_        ;# voice main switch
    $self instvar show_graph_streaming_    ;# streaming main switch
    $self instvar show_graph_tmix_         ;# tmix main switch
    $self instvar show_graph_fwd_          ;# show foward graph
    $self instvar show_graph_rev_          ;# show reverse graph
    $self instvar show_graph_uitl_         ;# show link utilization
    $self instvar show_graph_percentile_   ;# show queue length percentile
    $self instvar show_graph_qlen_         ;# show bottleneck queue length
    $self instvar step_large_              ;# show graph large  interval
    $self instvar step_small_              ;# show graph small interval
    $self instvar sim_time_                ;# total simulation time
    $self instvar topology_                ;# topology instance
    $self instvar percentile_              ;# queue percentile 
    
    # Traffic ftp settings
    $self instvar show_graph_throughput_   ;# show throughput
    $self instvar show_graph_cross_        ;# show cross traffic throughput
    $self instvar show_tcp_throughput_	   ;# show tcp throughput statistics
    $self instvar show_graph_fairness_	   ;# show fairness
    $self instvar show_graph_response_function_         ;# show response function
    $self instvar error_rate_              ;# error rate
    
    # Tcp statistics, now disabled
    $self instvar show_graph_srtt_	   ;# show smoothed RTT
    $self instvar show_graph_rtt_	   ;# show RTT
    $self instvar show_graph_seqno_	   ;# show seqno
    $self instvar show_graph_cwnd_         ;# show cwnd 

    $self instvar if_html_                 ;# show graphs in html
    $self instvar html_index_              ;# the html file name, indexhtml_index_.html
    $self instvar verbose_                 ;# printed text setting information
    $self instvar show_convergence_time_   ;# each flow starts at an interval
    $self instvar start_time_              ;# simulation start time
    
    $self instvar show_secD_               ;# if show section D in the paper

    # Initialize parameters
    set show_graph_fwd_ 1
    set show_graph_rev_ 1
    $self show_bottleneck_stats 0    
    $self show_graph_ftp 0    
    $self show_graph_http 0
    $self show_graph_voice 0
    $self show_graph_streaming 0
    $self show_graph_tmix 0
    
    set step_large_ 2.0                   
    set step_small_ 1.0
    set percentile_ 90
    set error_rate_ 0
    set show_graph_response_function_  0
    set if_html_ 0 ;
    set show_convergence_time_ 0
    set start_time_ [clock seconds] 
    set show_secD_ 0
    Graph set plot_device_ [new postscript] ;# using eps graph by default
    eval $self next $args
}

# config procedures
Create_graph instproc show_bottleneck_stats {val} {
    $self set show_bottleneck_stats_ $val
    $self set show_graph_util_ $val
    $self set show_graph_percentile_ $val
    $self set show_graph_qlen_ $val
}

Create_graph instproc show_graph_ftp {val} {
    $self set show_graph_ftp_ $val
    $self set show_graph_throughput_ $val
    $self set show_graph_fairness_ $val
    $self set show_graph_cross_ $val
    $self set show_graph_srtt_ 0
    $self set show_graph_cwnd_ 0
    $self set show_graph_rtt_ 0
    $self set show_graph_seqno_ 0
    $self set show_tcp_throughput_ 0
}

Create_graph instproc show_graph_response_function {val} {
    $self set show_graph_response_function_ $val
}
Create_graph instproc show_graph_http {val} {
    $self set show_graph_http_ $val
}

Create_graph instproc show_graph_voice {val} {
    $self set show_graph_voice_ $val
    #$self set show_voice_delay_ $val   
    #$self set show_voice_loss_	$val
}

Create_graph instproc show_graph_streaming {val} {    
    $self set show_graph_streaming_ $val
}

Create_graph instproc show_graph_tmix {val} {
    $self set show_graph_tmix_ $val
}

Create_graph instproc show_graph_fwd {val} {
    $self set show_graph_fwd_ $val
}

Create_graph instproc show_graph_rev {val} {
    $self set show_graph_rev_ $val
}

Create_graph instproc show_graph_util {val} {
    $self set show_graph_util_ $val
}

Create_graph instproc show_graph_percentile {val} {
    $self set show_graph_percentile_ $val
}

Create_graph instproc show_graph_qlen {val} {
    $self set show_graph_qlen_ $val
}

Create_graph instproc show_graph_cwnd {val} {
    $self set show_graph_cwnd_ $val
}

Create_graph instproc show_graph_throughput {val} {
    $self set show_graph_throughput_ $val
}

Create_graph instproc error_rate {val} {
	$self instvar error_rate_ show_graph_response_function_
    set error_rate_ $val
    if { $error_rate_ > 0 && $error_rate_ < 1} {
        $self set show_graph_response_function_ 1
    } else {
 	if { $error_rate_ == 0 || $error_rate_== 0.0 } {
	    set show_graph_response_function_ 0
	} else {
	    puts "error rate beyonds \[0,1)"
	    exit
	}
    }
}

Create_graph instproc show_graph_cross {val} {
    $self set show_graph_cross_ $val
}
Create_graph instproc show_graph_fairness {val} {
    $self set show_graph_fairness_ $val
}

Create_graph instproc show_graph_srtt {val} {
    $self set show_graph_srtt_ $val
}

Create_graph instproc show_graph_rtt {val} {
    $self set show_graph_rtt_ $val
}

Create_graph instproc show_graph_seqno {val} {
    $self set show_graph_seqno_ $val
}

Create_graph instproc show_tcp_throughput {val} {
    $self set show_tcp_throughput_ $val
}


Create_graph instproc show_voice_delay {val} {
    $self set show_voice_delay_ $val
}

Create_graph instproc show_voice_loss {val} {
    $self set show_voice_loss_ $val
}

Create_graph instproc html_index {val} {
    $self instvar if_html_
    $self set html_index_ $val
    if {$val != -1} {
        set if_html_ 1
    }
}

Create_graph instproc verbose {val} {
    $self instvar verbose_
    set verbose_ $val
}

Create_graph instproc show_convergence_time {val} {
    $self set show_convergence_time_ $val
}

# dispatch args
Create_graph instproc init_var args {
    set shadow_args ""
    for {} {$args != ""} {set args [lrange $args 2 end]} {
        set key [lindex $args 0]
        set val [lindex $args 1]
        if {$val != "" && [string match {-[A-z]*} $key]} {
            set cmd [string range $key 1 end]
            if ![catch "$self $cmd $val"] {
                continue
            }
        }
        lappend shadow_args $key $val
    }
    return $shadow_args
}

# config parameters
Create_graph instproc config args {
    set args [eval $self init_var $args]
    # save graph in current dir
    $self instvar html_dir_
    global tmp_directory_
    if { ![info exists tmp_directory_] } {
        set tmp_directory_ [create-tmp-directory]
    }    
    set html_dir_ $tmp_directory_
}

# choose a subset to display
Create_graph instproc show_subset {total} {
    set a [expr round($total)]
    set b 1
    if { $a >3 } {
        set b [expr $a /3]
    }
    set i 0
    set c 0
    for { set i [expr $i+$b]} {$i<$a} {set i [expr $i+$b]} {
        set c "$c $i"
    }
    return $c 
} 


####################### system statistics ######################## 

#****************** btnk overall statistics *******************
# forward
Create_graph instproc create_bottleneck_stats_fwd {b0 b1 neglect_time btnk_buf i} {
    $self instvar stats0_fwd_ stats1_fwd_ neglect_time_fwd_ btnk_buf_fwd_
    set neglect_time_fwd_ $neglect_time
    set btnk_buf_fwd_ $btnk_buf
    set stats0_fwd_($i) [new LinkStats $b0 $b1]
    set stats1_fwd_($i) [new LinkStats $b0 $b1]
    set ns [Simulator instance]
    $ns at $neglect_time_fwd_ "$stats1_fwd_($i) reset"
}

# reverse
Create_graph instproc create_bottleneck_stats_rev {b0 b1 neglect_time btnk_buf i} {
    $self instvar stats0_rev_ stats1_rev_ neglect_time_rev_ btnk_buf_rev_
    set neglect_time_rev_ $neglect_time
    set btnk_buf_rev_ $btnk_buf
    set stats1_rev_($i) [new LinkStats $b0 $b1]
    set ns [Simulator instance]
    $ns at $neglect_time_rev_ "$stats1_rev_($i) reset"
}

#****************** btnk utilization *******************
# forward 
Create_graph instproc create_util_fwd {b0 b1 i graph_name} {
    $self instvar util_graph_fwd_ step_small_
    global tmp_directory_ 
    set util_graph_fwd_($i) [new Graph/UtilizationVersusTime $b0 $b1 $step_small_ "$tmp_directory_/data/btnk_util_fwd_$i"]
    $util_graph_fwd_($i) set title_ $graph_name
    $util_graph_fwd_($i) set comment_ "Interval=[expr $step_small_]s"
    $util_graph_fwd_($i) set output_filename_ "$tmp_directory_/figure/btnk_util_fwd_$i"
}

# reverse
Create_graph instproc create_util_rev {b0 b1 i graph_name} {
    $self instvar util_graph_rev_ step_small_
    global tmp_directory_ 
    set util_graph_rev_($i) [new Graph/UtilizationVersusTime $b1 $b0 $step_small_ "$tmp_directory_/data/btnk_uitl_rev_$i"]
    $util_graph_rev_($i) set title_ $graph_name
    $util_graph_rev_($i) set comment_ "Interval=[expr $step_small_]s"
    $util_graph_rev_($i) set output_filename_ "$tmp_directory_/figure/btnk_util_rev_$i"
}

#****************** btnk queue percentile *******************
# forward  
Create_graph instproc create_percentile_fwd {b0 b1 i percentile graph_name} {
    global tmp_directory_
    $self instvar percentile_graph_fwd_ percentile_name_fwd_ step_small_
    set percentile_graph_fwd_($i) [new LinkStats $b0 $b1]
    set percentile_name_fwd_($i) $graph_name
    set ns [Simulator instance]
    $percentile_graph_fwd_($i) trace-every-kth -1 "$tmp_directory_/data/link_stats_fwd_$i.trace"
    $ns at $step_small_ "$self get_percentile_fwd $i $percentile"
}

Create_graph instproc get_percentile_fwd {i percentile} {
    $self instvar percentile_graph_fwd_ step_small_
    global tmp_directory_
    set ns [Simulator instance]
    set file_open [open "$tmp_directory_/data/btnk_percentile_fwd_$i.trace" "a"]
    puts $file_open "[$ns now] [$percentile_graph_fwd_($i) get-percentile-packet-queue-length $percentile]"
    close $file_open
    $percentile_graph_fwd_($i) reset
    close [$percentile_graph_fwd_($i) set channel_]
    $percentile_graph_fwd_($i) trace-every-kth -1 "$tmp_directory_/data/link_stats_fwd_$i.trace"
    $ns at "[expr [$ns now] + $step_small_]" "$self get_percentile_fwd $i $percentile"
}

# reverse
Create_graph instproc create_percentile_rev {b0 b1 i percentile graph_name} {
    global tmp_directory_
    $self instvar percentile_graph_rev_ percentile_name_rev_ step_small_
    set percentile_graph_rev_($i) [new LinkStats $b0 $b1]
    set percentile_name_rev_($i) $graph_name
    set ns [Simulator instance]
    $percentile_graph_rev_($i) trace-every-kth -1 "$tmp_directory_/data/link_stats_rev_$i.trace"
    $ns at $step_small_ "$self get_percentile_rev $i $percentile"
}

Create_graph instproc get_percentile_rev {i percentile} {
    $self instvar percentile_graph_rev_ step_small_
    global tmp_directory_
    set ns [Simulator instance]
    set file_open [open "$tmp_directory_/data/btnk_percentile_rev_$i.trace" "a"]
    puts $file_open "[$ns now] [$percentile_graph_rev_($i) get-percentile-packet-queue-length $percentile]"
    close $file_open
    $percentile_graph_rev_($i) reset
    close [$percentile_graph_rev_($i) set channel_]
    $percentile_graph_rev_($i) trace-every-kth -1 "$tmp_directory_/data/link_stats_rev_$i.trace"
    $ns at "[expr [$ns now] + $step_small_]" "$self get_percentile_rev $i $percentile"

}

#****************** btnk queue length *******************
# forward
Create_graph instproc create_qlen_fwd {b0 b1 i graph_name} {
    $self instvar qlen_graph_fwd_ step_small_
    global tmp_directory_
    set qlen_graph_fwd_($i) [new Graph/QLenVersusTime $b0 $b1 $step_small_ "true" "true" "" "$tmp_directory_/data/btnk_qlen_fwd_$i"]
    $qlen_graph_fwd_($i) set title_ $graph_name
    $qlen_graph_fwd_($i) set output_filename_ "$tmp_directory_/figure/btnk_qlen_fwd_$i"
}

# reverse
Create_graph instproc create_qlen_rev {b0 b1 i graph_name} {
    $self instvar qlen_graph_rev_ step_small_
    global tmp_directory_
    set qlen_graph_rev_($i) [new Graph/QLenVersusTime $b0 $b1 $step_small_ "true" "true" "" "$tmp_directory_/data/btnk_qlen_rev_$i"]
    $qlen_graph_rev_($i) set title_ $graph_name
    $qlen_graph_rev_($i) set output_filename_ "$tmp_directory_/figure/btnk_qlen_rev_$i"
}

#****************** network overall statistics *******************
# forward
Create_graph instproc create_bottleneck_stats_fwd_core {b0 b1 neglect_time buf_core i} {
    $self instvar stats0_fwd_core_ stats1_fwd_core_ neglect_time_fwd_core_ buf_fwd_core_
    set neglect_time_fwd_core_ $neglect_time
    set buf_fwd_core_ $buf_core
    set stats0_fwd_core_($i) [new LinkStats $b0 $b1]
    set stats1_fwd_core_($i) [new LinkStats $b0 $b1]
    set ns [Simulator instance]
    $ns at $neglect_time_fwd_core_ "$stats1_fwd_core_($i) reset"
}

Create_graph instproc create_bottleneck_stats_fwd_transit {b0 b1 neglect_time buf_transit i} {
    $self instvar stats0_fwd_transit_ stats1_fwd_transit_ neglect_time_fwd_transit_ buf_fwd_transit_
    set neglect_time_fwd_transit_ $neglect_time
    set buf_fwd_transit_ $buf_transit
    set stats0_fwd_transit_($i) [new LinkStats $b0 $b1]
    set stats1_fwd_transit_($i) [new LinkStats $b0 $b1]
    set ns [Simulator instance]
    $ns at $neglect_time_fwd_transit_ "$stats1_fwd_transit_($i) reset"
}

# reverse statistics
Create_graph instproc create_bottleneck_stats_rev_core {b0 b1 neglect_time buf_core i} {
    $self instvar stats0_rev_core_ stats1_rev_core_ neglect_time_rev_core_ buf_rev_core_
    set neglect_time_rev_core_ $neglect_time
    set buf_rev_core_ $buf_core
    set stats0_rev_core_($i) [new LinkStats $b0 $b1]
    set stats1_rev_core_($i) [new LinkStats $b0 $b1]
    set ns [Simulator instance]
    $ns at $neglect_time_rev_core_ "$stats1_rev_core_($i) reset"
}

Create_graph instproc create_bottleneck_stats_rev_transit {b0 b1 neglect_time buf_transit i} {
    $self instvar stats0_rev_transit_ stats1_rev_transit_ neglect_time_rev_transit_ buf_rev_transit_
    set neglect_time_rev_transit_ $neglect_time
    set buf_rev_transit_ $buf_transit
    set stats0_rev_transit_($i) [new LinkStats $b0 $b1]
    set stats1_rev_transit_($i) [new LinkStats $b0 $b1]
    set ns [Simulator instance]
    $ns at $neglect_time_rev_transit_ "$stats1_rev_transit_($i) reset"
}

# generate graph 
Create_graph instproc generate_graph {graph_obj title comment xlabel ylabel ymax output} {
    upvar $graph_obj mygraph_
    $mygraph_ set title_ $title
    $mygraph_ set comment_ $comment
    $mygraph_ set xlabel_ $xlabel
    $mygraph_ set ylabel_ $ylabel
    $mygraph_ set yhigh_ $ymax
    $mygraph_ set output_filename_ $output
    $mygraph_ display
 }
    
################################## FTP #########################################

#****************** FTP throughput *******************
# forward
Create_graph instproc create_throughput_fwd { scheme tcp i } {
    $self instvar throughput_ftp_fwd_ scheme_ show_convergence_time_
    $self instvar trace_file_fwd_ step_small_
    global tmp_directory_
    set ns [Simulator instance]
    set throughput_ftp_fwd_($i) $tcp
    set scheme_ $scheme
    if { $show_convergence_time_ == 1 } {
        set trace_file_fwd_($i) "$tmp_directory_/data/ftp_thr_fwd$i"
        $ns at $step_small_ "$self get_throughput_fwd $tcp $i"
    }
}

Create_graph instproc get_throughput_fwd { tcp i } {
    $self instvar trace_file_fwd_ step_small_
    set ns [Simulator instance]
    set trace_tmp [open $trace_file_fwd_($i) "a"]
    puts $trace_tmp "[format "%f" [$ns now]] [$tcp get-goodput-bps]"
    close $trace_tmp
    $tcp init-stats
    $ns at [expr [$ns now] + $step_small_] "$self get_throughput_fwd $tcp $i"
}

# reverse
Create_graph instproc create_throughput_rev {scheme tcp i} {
    $self instvar throughput_ftp_rev_ scheme_
    set throughput_ftp_rev_($i) $tcp
    set scheme_ $scheme
}

# cross 
Create_graph instproc create_throughput_cross {tcp i k j} {
    $self instvar no_btnk_
    $self instvar no_flow_
    $self instvar throughput_ftp_cross_ 
    set no_btnk_($i) $k
    set no_flow_($i) $j
    set throughput_ftp_cross_($i) $tcp
}

#****************** TCP statistics, test use only *******************
# forward tcp cwnd
Create_graph instproc create_cwnd_fwd {tcp i} {
    $self instvar cwnd_graph_fwd_ step_small_
    global tmp_directory_
    set cwnd_graph_fwd_($i) [new Graph/CWndVersusTime $tcp $step_small_ "$tmp_directory_/data/tcp_cwnd_fwd_$i"]
    $cwnd_graph_fwd_($i) set title_ "Foward Congestion Window"
    $cwnd_graph_fwd_($i) set comment_ "Interval=[expr $step_small_]s"
    $cwnd_graph_fwd_($i) set output_filename_ "$tmp_directory_/figure/tcp_cwnd_fwd_$i"
}

Create_graph instproc create_cwnd_cross {tcp i} {
    $self instvar cwnd_graph_cross_ step_small_
    global tmp_directory_
    set cwnd_graph_cross_($i) [new Graph/CWndVersusTime $tcp $step_small_ "$tmp_directory_/data/tcp_cwnd_cross_$i"]
    $cwnd_graph_cross_($i) set title_ "Cross Congestion Window"
    $cwnd_graph_cross_($i) set comment_ "Interval=[expr $step_small_]s"
    $cwnd_graph_cross_($i) set output_filename_ "$tmp_directory_/figure/tcp_cwnd_cross_$i"
}

# reverse tcp cwnd
Create_graph instproc create_cwnd_rev {tcp i} {
    $self instvar cwnd_graph_rev_ step_small_
    global tmp_directory_
    set cwnd_graph_rev_($i) [new Graph/CWndVersusTime $tcp $step_small_ "$tmp_directory_/data/tcp_cwnd_rev_$i"]
    $cwnd_graph_rev_($i) set title_ "Reverse Congestion Window"
    $cwnd_graph_rev_($i) set comment_ "Interval=[expr $step_small_]s"
    $cwnd_graph_rev_($i) set output_filename_ "$tmp_directory_/data/tcp_cwnd_rev_$i"
}

# forward tcp smoothed rtt
Create_graph instproc create_srtt_fwd {tcp i} {
    $self instvar srtt_graph_fwd_ step_small_
    global tmp_directory_
    set srtt_graph_fwd_($i) [new Graph/SRTTVersusTime $tcp $step_small_ "$tmp_directory_/data/tcp_srtt_fwd_$i"]
    $srtt_graph_fwd_($i) set title_ "Foward SRTT"
    $srtt_graph_fwd_($i) set comment_ "Interval=[expr $step_small_]s"
    $srtt_graph_fwd_($i) set output_filename_ "$tmp_directory_/figure/tcp_srtt_fwd_$i"
}

# reverse tcp smoothed rtt
Create_graph instproc create_srtt_rev {tcp i} {
    $self instvar srtt_graph_rev_ step_small_
    global tmp_directory_
    set srtt_graph_rev_($i) [new Graph/SRTTVersusTime $tcp $step_small_ "$tmp_directory_/data/tcp_srtt_rev_$i"]
    $srtt_graph_rev_($i) set title_ "Reverse SRTT"
    $srtt_graph_rev_($i) set comment_ "Interval=[expr $step_small_]s"
    $srtt_graph_rev_($i) set output_filename_ "$tmp_directory_/figure/tcp_srtt_rev_$i"
}

# forward tcp rtt
Create_graph instproc create_rtt_fwd {tcp i} {
    $self instvar rtt_graph_fwd_ step_small_
    global tmp_directory_
    set rtt_graph_fwd_($i) [new Graph/RTTVersusTime $tcp $step_small_ "$tmp_directory_/data/tcp_rtt_fwd_$i" ]
    $rtt_graph_fwd_($i) set title_ "Foward RTT"
    $rtt_graph_fwd_($i) set comment_ "Interval=[expr $step_small_]s"
    $rtt_graph_fwd_($i) set output_filename_ "$tmp_directory_/figure/tcp_rtt_fwd_$i"
}

# reverse tcp rtt
Create_graph instproc create_rtt_rev {tcp i} {
    $self instvar rtt_graph_rev_ step_small_
    global tmp_directory_
    set rtt_graph_rev_($i) [new Graph/RTTVersusTime $tcp $step_small_ "$tmp_directory_/data/tcp_rtt_rev_$i"]
    $rtt_graph_rev_($i) set title_ "Reverse RTT"
    $rtt_graph_rev_($i) set comment_ "Interval=[expr $step_small_]s"
    $rtt_graph_rev_($i) set output_filename_ "$tmp_directory_/figure/tcp_rtt_rev_$i"
}

# forward tcp seqno
Create_graph instproc create_seqno_fwd {s b0 i} {
    $self instvar seqno_graph_fwd_ 
    global tmp_directory_
    set seqno_graph_fwd_($i) [new Graph/Sequence $s $b0  200000000 "$tmp_directory_/data/tcp_seqno_fwd_$i"]
    $seqno_graph_fwd_($i) set title_ "Foward Sequence Num"
    $seqno_graph_fwd_($i) set out_filename_ "$tmp_directory_/figure/tcp_seqno_fwd_$i"
}

# reverse seqno
Create_graph instproc create_seqno_rev {s b0 i} {
    $self instvar seqno_graph_rev_ 
    global tmp_directory_
    set seqno_graph_rev_($i) [new Graph/Sequence $s $b0 200000000 "$tmp_directory_/data/tcp_seqno_rev_$i"]
    $seqno_graph_rev_($i) set title_ "Reverse Sequence Num"
    $seqno_graph_rev_($i) set output_filename_ "$tmp_directory_/figure/tcp_seqno_rev_$i"
}

# TCP throughput, debug use.
Create_graph instproc create_tcp_throughput {tcp i} {
    $self instvar tcp_
    set tcp_($i) $tcp
}


################################## HTTP #########################################

################################## Voice ########################################
# voice and streaming throughput, loss and jitter
Create_graph instproc get_vos_stats {throughput_name loss_name jitter_name delay_monitor size} {
    $self instvar step_large_
    set ns [Simulator instance]
    set open_throughput [open $throughput_name "a"]
    set open_loss [open $loss_name "a"]
    set open_jitter [open $jitter_name "a"]
    set thr_tmp [expr [$delay_monitor get-n-samples] * $size * 8.0 / $step_large_ ]
    puts $open_throughput "[$ns now] $thr_tmp"
    puts $open_loss "[$ns now] [$delay_monitor get-interval-loss]"
    puts $open_jitter "[$ns now] [$delay_monitor get-standard-deviation]"
    $delay_monitor reset

    close $open_throughput
    close $open_loss
    close $open_jitter
    $ns at [expr [$ns now] + $step_large_] "$self get_vos_stats $throughput_name $loss_name $jitter_name $delay_monitor $size"
}

# voice throughput  
Create_graph instproc create_voice_stats {s b0 b1 d i size voice_list} {
    global tmp_directory_
    $self instvar step_large_
    $self instvar voice_list_
    $self instvar trace_delay_fwd_
    $self instvar trace_delay_rev_
    
    set ns [Simulator instance]
    
    set voice_list_ $voice_list
    set voice_stats_fwd [new DelayMonitor $s $b0 $b1 $d]
    set voice_stats_rev [new DelayMonitor $d $b1 $b0 $s]
        
    set trace_delay_fwd_($i) [open "$tmp_directory_/data/voice_delay_fwd_$i" w]
    $voice_stats_fwd set-trace $trace_delay_fwd_($i)
    $voice_stats_fwd set-delay-threshold 120ms 160ms
    
    set trace_delay_rev_($i) [open "$tmp_directory_/data/voice_delay_rev_$i" w]
    $voice_stats_rev set-trace $trace_delay_rev_($i)
    $voice_stats_rev set-delay-threshold 120ms 160ms
    
    set throughput_fwd "$tmp_directory_/data/voice_thr_fwd_$i"
    set throughput_rev "$tmp_directory_/data/voice_thr_rev_$i"
    set loss_fwd "$tmp_directory_/data/voice_loss_fwd_$i"
    set loss_rev "$tmp_directory_/data/voice_loss_rev_$i"
    set jitter_fwd "$tmp_directory_/data/voice_jitter_fwd_$i"
    set jitter_rev "$tmp_directory_/data/voice_jitter_rev_$i"
    
    $ns at $step_large_ "$self get_vos_stats $throughput_fwd $loss_fwd $jitter_fwd $voice_stats_fwd $size"
    $ns at $step_large_ "$self get_vos_stats $throughput_rev $loss_rev $jitter_rev $voice_stats_rev $size"
}


################################## Streaming #########################################

#****************** Streaming throughput *******************
# forward
Create_graph instproc create_streaming_stats_fwd {s b0 b1 d i size streaming_list_fwd} {
    global tmp_directory_
    $self instvar step_large_
    $self instvar streaming_list_fwd_
    $self instvar trace_streaming_delay_fwd_
    
    set streaming_list_fwd_ $streaming_list_fwd
    
    set ns [Simulator instance]
    set streaming_stats_fwd [new DelayMonitor $s $b0 $b1 $d]
    set throughput_fwd "$tmp_directory_/data/streaming_thr_fwd_$i"
    set loss_fwd  "$tmp_directory_/data/streaming_loss_fwd_$i"
    set jitter_fwd  "$tmp_directory_/data/streaming_jitter_fwd_$i"

    set trace_streaming_delay_fwd_($i) [open "$tmp_directory_/data/streaming_delay_fwd_$i" w]
    $streaming_stats_fwd set-trace $trace_streaming_delay_fwd_($i)
    $streaming_stats_fwd  set-delay-threshold 10s 10s

    $ns at $step_large_ "$self get_vos_stats $throughput_fwd $loss_fwd $jitter_fwd $streaming_stats_fwd $size"
}


# reverse
Create_graph instproc create_streaming_stats_rev {s b0 b1 d i size streaming_list_rev} {
    global tmp_directory_
    $self instvar step_large_
    $self instvar streaming_list_rev_
    $self instvar trace_streaming_delay_rev_
    
    set streaming_list_rev_ $streaming_list_rev
    set ns [Simulator instance]
    set streaming_stats_rev [new DelayMonitor $s $b0 $b1 $d]
    set throughput_rev "$tmp_directory_/data/streaming_thr_rev_$i"
    set loss_rev  "$tmp_directory_/data/streaming_loss_rev_$i"
    set jitter_rev  "$tmp_directory_/data/streaming_jitter_rev_$i"
    
    set trace_streaming_delay_rev_($i) [open "$tmp_directory_/data/streaming_delay_rev_$i" w]
    $streaming_stats_rev set-trace $trace_streaming_delay_rev_($i)
    $streaming_stats_rev  set-delay-threshold 10s 10s
    
    $ns at $step_large_ "$self get_vos_stats $throughput_rev $loss_rev $jitter_rev $streaming_stats_rev $size"
}

Create_graph instproc create_tmix_stats {num_tmix tmix_qdelay_forward tmix_qdelay_reverse tmix_flow sim_time btnk_buf_bdp} {
    $self instvar num_tmix_flow_ tmix_qdelay_forward_ tmix_qdelay_reverse_ tmix_flow_ sim_time_ btnk_buf_bdp_
    set num_tmix_flow_ $num_tmix
    set tmix_qdelay_forward_ $tmix_qdelay_forward
    set tmix_qdelay_reverse_ $tmix_qdelay_reverse
    set tmix_flow_ $tmix_flow
    set sim_time_ $sim_time
    set btnk_buf_bdp_ $btnk_buf_bdp
}

# section D in the paper  
Create_graph instproc create_secD_stats {cross_case tcp cbr btnk_buf tmix_s tmix_d b0 b1} {
    $self instvar secD_decreased_time max_changed_cw last_window show_secD_ secD_delaymon
    $self instvar secD_loss
    set ns [Simulator instance]
    set secD_decreased_time 0
    set max_changed_cw 0
    set last_window 0
    set secD_loss 0
    set show_secD_ 1

    if {$cross_case==1} {
        $ns at 1.0 "$self secD_decrease_bw $cbr"
        $ns at 0.1 "$self secD_log_cwnd $tcp $btnk_buf"
    }
    
    if {$cross_case==2} {
        $ns at 1.0 "$self secD_increase_bw $cbr"
        set secD_delaymon [new DelayMonitor $tmix_s $b0 $b1 $tmix_d]
    }
    
    if {$cross_case==3} {
        $ns at 1.0 "$self secD_increase_bw2 $cbr"
        set secD_delaymon [new DelayMonitor $tmix_s $b0 $b1 $tmix_d]
    }

}

Create_graph instproc secD_decrease_bw {cbr} {
    set ns [Simulator instance]
    set current_rate [$cbr set rate_]
    if {[expr $current_rate - 1000000] >=0.05} {
        $cbr set rate_ [expr $current_rate - 1000000]
    }
    $ns at "[expr [$ns now] + 1]" "$self secD_decrease_bw $cbr"
}

Create_graph instproc secD_increase_bw {cbr} {
    set ns [Simulator instance]
    set current_rate [$cbr set rate_]
    if {!$current_rate>=75000000} {
        set current_rate [expr $current_rate + 1000000]
        $cbr set rate_ $current_rate
    }
    $ns at "[expr [$ns now] + 1]" "$self secD_increase_bw $cbr"
}

Create_graph instproc secD_increase_bw2 {cbr} {
    set ns [Simulator instance]
    set current_rate [$cbr set rate_]
    if {!$current_rate>=75000000} {
        set current_rate [expr $current_rate + 2500000]
        $cbr set rate_ $current_rate
    }
    $ns at "[expr [$ns now] + 1]" "$self secD_increase_bw2 $cbr"
}

Create_graph instproc secD_log_cwnd {tcp btnk_buf} {
    $self instvar secD_decreased_time max_changed_cw last_window
    set ns [Simulator instance]
    set current_window [$tcp set cwnd_]
  
    if {$current_window > [expr $btnk_buf*0.01] && $secD_decreased_time==0} {
        set secD_decreased_time [$ns now]
    }
    if {$current_window < [expr $btnk_buf*0.01] && $secD_decreased_time==0} {
        if {[expr $current_window - $last_window] > $max_changed_cw} {
            set max_changed_cw [expr $current_window - $last_window]
        }
    }
    $ns at "[expr [$ns now] + 0.1]" "$self  secD_log_cwnd $tcp $btnk_buf"
}

Create_graph instproc secD_cbr_loss {my_delaymon} {
    $self instvar secD_loss
    set secD_loss [$my_delaymon get-total-loss-packet]
}

################################## finish process #########################################
# bottleneck stats
Create_graph instproc bottleneck_stats {stats0 stats1 buf_size stats_neglect_time stats_name} {
    upvar $stats0 stats0_copy
    upvar $stats1 stats1_copy
    global tmp_directory_
    $self instvar if_html_ html_index_ html_dir_ verbose_ start_time_ 
    set end_time_ [clock seconds]
    set min [expr ($end_time_ - $start_time_) / 60]
    set sec [expr ($end_time_ - $start_time_) % 60]
    if { $verbose_ == "1" } { 
    	set file_stats [open "$tmp_directory_/data/all_stats" "a"]
    	if { $if_html_ == "1" } {
		set file_html [open "/tmp/index$html_index_.html" "a"]
    	}
    	puts $file_stats "--------------------------------------------------------"
    	for { set i 0 } { $i < [array size stats0_copy] } { incr i } { 
        	# forward stats 
        	puts $file_stats [format "  $stats_name Bottleneck No.[expr $i+1] Average Utilization:       %.3f (%.3f Including 0~%0.1fs)" [$stats1_copy($i) get-utilization] [$stats0_copy($i) get-utilization] $stats_neglect_time]
        	set pq [$stats0_copy($i) get-mean-packet-queue-length] ;# in packets
        	set bq [$stats0_copy($i) get-mean-byte-queue-length]   ;# in bytes
        	set pq_min [$stats0_copy($i) get-min-packet-queue-length]
        	set bq_min [$stats0_copy($i) get-min-byte-queue-length]
        	set pq_max [$stats0_copy($i) get-max-packet-queue-length]
        	set bq_max [$stats0_copy($i) get-max-byte-queue-length]
        	puts $file_stats [format "  $stats_name Bottleneck No.[expr $i+1] Average Queue Size:  %.1f Packets, %.1f KB (%.2f%% Buffer)" $pq [expr $bq/1000.0] [expr $bq/(10.0*$buf_size)]]
        	puts $file_stats [format "  $stats_name Bottleneck No.[expr $i+1]  MIN Queue Size:  %.1f Packets, %.1f KB (%.2f%% Buffer)" $pq_min [expr $bq_min/1000.0] [expr $bq_min/(10.0*$buf_size)]]
        	puts $file_stats [format "  $stats_name Bottleneck No.[expr $i+1] MAX Queue Size:  %.1f Packets, %.1f KB (%.2f%% Buffer)" $pq_max [expr $bq_max/1000.0] [expr $bq_max/(10.0*$buf_size)]]
        	set pd [$stats0_copy($i) get-packet-drops]
        	set bd [$stats0_copy($i) get-byte-drops]
       	 	set pa [$stats0_copy($i) get-packet-arrivals]
        	set ba [$stats0_copy($i) get-byte-arrivals]
        	set pl [$stats0_copy($i) get-packet-departures]
        	set bl [$stats0_copy($i) get-byte-departures]
        	set qdelay [$stats0_copy($i) get-mean-queue-delay]
    		
            puts $file_stats [format "  $stats_name Bottleneck No.[expr $i+1] Average Queueing Delay:      %0.6f s " $qdelay] 
        	if { $pa >0 && $ba >0 } {
	    		puts $file_stats [format "  $stats_name Bottleneck No.[expr $i+1] Packet Drops:      %d Packets (%.2f%% Arrival), %d B (%.2f%% Arrival)" $pd [expr 100.0*$pd/$pa] $bd [expr 100.0*$bd/$ba]]
            }
        	puts $file_stats "--------------------------------------------------------"
        	if { $if_html_ == "1" } {
                puts $file_html "<p>"
           		puts $file_html [format "$stats_name Bottleneck No.[expr $i+1] Average Utilization: %.3f (%.3f Including 0~%0.1fs) <br>  " [$stats1_copy($i) get-utilization] [$stats0_copy($i) get-utilization] $stats_neglect_time]
            	puts $file_html [format "  $stats_name Bottleneck No.[expr $i+1] Average Queue Size:  %.1f Packets, %.1f KB (%.2f%% Buffer)  " $pq [expr $bq/1000.0] [expr $bq/(10.0*$buf_size)]]
            	puts $file_html "<br>"
            	puts $file_html [format "  $stats_name Bottleneck No.[expr $i+1]  MIN Queue Size:  %.1f Packets, %.1f KB (%.2f%% Buffer)  " $pq_min [expr $bq_min/1000.0] [expr $bq_min/(10.0*$buf_size)]]
            	puts $file_html "<br>"
            	puts $file_html [format "  $stats_name Bottleneck No.[expr $i+1] MAX Queue Size:  %.1f Packets, %.1f KB (%.2f%% Buffer)  " $pq_max [expr $bq_max/1000.0] [expr $bq_max/(10.0*$buf_size)]]
            	puts $file_html "<br>"
    		    puts $file_html [format "  $stats_name Bottleneck No.[expr $i+1] Average Queueing Delay:      %0.6f s " $qdelay] 
            	puts $file_html "<br>"
	            if { $pa >0 && $ba>0} {
		            puts $file_html [format "  $stats_name Bottleneck No.[expr $i+1] Packet Drops:      %d Packets (%.2f%% Arrival), %d B (%.2f%% Arrival)  " $pd [expr 100.0*$pd/$pa] $bd [expr 100.0*$bd/$ba]] 
                }
                puts $file_html "<br>"
                puts $file_html "<br>"
	        }
	
    }
    close $file_stats
    if { $if_html_ == "1" } {
	    close $file_html
    }
} elseif { $stats_name == "FWD" || $stats_name == "CORE_FWD" || $stats_name == "TRANSIT_FWD" } {
    	for { set i 0 } { $i < [array size stats1_copy] } { incr i } { 
        	set pq [$stats1_copy($i) get-mean-packet-queue-length] ;# in packets
        	set bq [$stats1_copy($i) get-mean-byte-queue-length]   ;# in bytes
        	set pq_min [$stats1_copy($i) get-min-packet-queue-length]
        	set bq_min [$stats1_copy($i) get-min-byte-queue-length]
        	set pq_max [$stats1_copy($i) get-max-packet-queue-length]
        	set bq_max [$stats1_copy($i) get-max-byte-queue-length]
        	set pd [$stats1_copy($i) get-packet-drops]
       	 	set pa [$stats1_copy($i) get-packet-arrivals]
        	set qdelay [$stats1_copy($i) get-mean-queue-delay]
        	set qdelay_var [$stats1_copy($i) get-queue-delay-stddev]
            if { $pa > 0 } {
		        set pdoverpa [expr 1.0*$pd/$pa] 
		    } else {
		        set pdoverpa 0
		    }
	        puts -nonewline [format "%3d %6.2f%% %8.1f %8.1f %6.2f%% %6.2f%% %8d %4.2f%% %0.6f %0.6f " $i [expr [$stats1_copy($i) get-utilization] * 100.0] $pq $buf_size [expr 100.0*$pq/$buf_size] [expr 100.0*$pq_max/$buf_size] $pd [expr 100.0*$pdoverpa] $qdelay $qdelay_var]
        }
    }
} 

# finish process, it displays all figures based on the above settings and statistics.
Create_graph instproc finish {} {
    $self instvar step_large_ step_small_ if_html_ html_index_ html_dir_  verbose_
    global tmp_directory_

    ################################ system statistics ################################### 
    # show bottleneck link stats
    if {[$self set show_bottleneck_stats_]==1} {
	    $self instvar stats0_fwd_ stats1_fwd_ neglect_time_fwd_ btnk_buf_fwd_
	    $self instvar stats0_rev_ stats1_rev_ neglect_time_rev_ btnk_buf_rev_
	    $self instvar stats0_fwd_core_ stats1_fwd_core_ neglect_time_fwd_core_ buf_fwd_core_
	    $self instvar stats0_rev_core_ stats1_rev_core_ neglect_time_rev_core_ buf_rev_core_
	    $self instvar stats0_fwd_transit_ stats1_fwd_transit_ neglect_time_fwd_transit_ buf_fwd_transit_
	    $self instvar stats0_rev_transit_ stats1_rev_transit_ neglect_time_rev_transit_ buf_rev_transit_
	    if { $if_html_ == "1" && $verbose_ == 1} {
	        set file_html [open "/tmp/index$html_index_.html" "a"]
	        puts $file_html "<p> <font size=5 color=0066ff>Bottleneck Statistics </font></p> "
	        close $file_html
	    }
	
	    if { [array size stats0_fwd_] > 0 } {
	        eval $self bottleneck_stats stats0_fwd_ stats1_fwd_ $btnk_buf_fwd_ $neglect_time_fwd_ FWD
	    }
	    
	    if { [array size stats0_rev_] > 0 } {
	        eval $self bottleneck_stats stats0_rev_ stats1_rev_ $btnk_buf_rev_ $neglect_time_rev_ REV
	    }
	
	    if { [array size stats0_fwd_core_] > 0 } {
	        eval $self bottleneck_stats stats0_fwd_core_ stats1_fwd_core_ $buf_fwd_core_ $neglect_time_fwd_core_ CORE_FWD
	    }
	
	    if { [array size stats0_rev_core_] > 0 } {
	        eval $self bottleneck_stats stats0_rev_core_ stats1_rev_core_ $buf_rev_core_ $neglect_time_rev_core_ CORE_REV
	    }
	
	    if { [array size stats0_fwd_transit_] > 0 } {
	        eval $self bottleneck_stats stats0_fwd_transit_ stats1_fwd_transit_ $buf_fwd_transit_ $neglect_time_fwd_transit_ TRANSIT_FWD
	    }
        
	    if { [array size stats0_rev_transit_] > 0 } {
	        eval $self bottleneck_stats stats0_rev_transit_ stats1_rev_transit_ $buf_rev_transit_ $neglect_time_rev_transit_ TRANSIT_REV
	    }
    }      

#******************************* forward ***********************************
    if { $if_html_ == "1" } {
       set file_html [open "/tmp/index$html_index_.html" "a"]
    }
    set png_graph [new png]
    if {[$self set show_graph_fwd_]==1} {
        if { $if_html_ == "1" } {
            puts $file_html "<font size=5 color=0066ff>Forward Bottleneck Statistics Figures</font> <br>"
        }
	# forward util
	    if {[$self set show_graph_util_]==1} {
	        $self instvar util_graph_fwd_
	        set figure_count 0
	        for {set i 0 } { $i < [array size util_graph_fwd_ ] } { incr i } {
                $util_graph_fwd_($i) display
                if { $if_html_ == "1" } {
                    $png_graph plot $util_graph_fwd_($i)
                    puts $file_html [format "<img src=$html_dir_/figure/btnk_util_fwd_%d_plot2.png> <br>" $i]
                } 
	        }
	    }
	
	# forward percentile
	if {[$self set show_graph_percentile_]==1} {
	    $self instvar percentile_graph_fwd_ percentile_name_fwd_
	    for {set i 0 } { $i < [array size percentile_graph_fwd_] } { incr i } {
                set xy_graph_percentile_fwd [new Graph/XY "$tmp_directory_/data/btnk_percentile_fwd_$i.trace" "" "steps"]
                set ymax [file-max 1 "$tmp_directory_/data/btnk_percentile_fwd_$i.trace"]
                if { $ymax < 0.00000001 } {
                    set ymax 1
                } else {
                    set ymax [expr $ymax + 5]
                }
                eval $self generate_graph xy_graph_percentile_fwd "\"$percentile_name_fwd_($i)\"" "\"Interval=[expr $step_small_]s\"" "seconds" "packets" $ymax "$tmp_directory_/figure/btnk_percentile_fwd_$i"
                if { $if_html_ == "1" } {
                    $png_graph plot $xy_graph_percentile_fwd
                    puts $file_html [format "<img src=$html_dir_/figure/btnk_percentile_fwd_%d_plot2.png> <br>" $i]
                } 
            }
	}
	
	# forward queue length
	if {[$self set show_graph_qlen_]==1} {
	    $self instvar qlen_graph_fwd_
	    for {set i 0 } { $i < [array size qlen_graph_fwd_] } { incr i } {
		$qlen_graph_fwd_($i) display
                if { $if_html_ == "1" } {
                    $png_graph plot $qlen_graph_fwd_($i) 
                    puts $file_html "<p>"
                    puts $file_html [format "<img src=$html_dir_/figure/btnk_qlen_fwd_%d_plot2.png> <br>" $i]
                } 
	    }
	}
    
    # Tmix forward queue delay
	if {[$self set show_graph_tmix_]==1} {
        $self instvar tmix_qdelay_forward_ 
        set xy_graph_qdelay_fwd [new Graph/XY "$tmp_directory_/data/$tmix_qdelay_forward_" "" "steps"]
        set ymax [file-max 1 "$tmp_directory_/data/$tmix_qdelay_forward_"]
        if { $ymax < 0.00000001 } {
            set ymax 1
        } else {
            set ymax [expr $ymax + 1]
        }
        eval $self generate_graph xy_graph_qdelay_fwd "\"Forward Bottleneck No.1 Queueing Delay\"" "\"Interval = 1s\"" "seconds" "microseconds" $ymax "$tmp_directory_/figure/btnk_qdelay_fwd_1"
        if { $if_html_ == "1" } {
            $png_graph plot $xy_graph_qdelay_fwd
            puts $file_html [format "<img src=$html_dir_/figure/btnk_qdelay_fwd_1_plot2.png> <br>"]
        } 
    }
    }

    #******************************* reverse ***********************************
    
    if {[$self set show_graph_rev_]==1} {
	
	# bottleneck util
	if { $if_html_ == "1" } {
	    puts $file_html "<font size=5 color=0066ff>Reverse Bottleneck Statistics Figures</font> <br>"
	}
	if {[$self set show_graph_util_]==1} {
	    $self instvar util_graph_rev_
	    for {set i 0 } { $i < [array size util_graph_rev_ ] } { incr i } {
                $util_graph_rev_($i) display
                if { $if_html_ == "1" } {
                    $png_graph plot $util_graph_rev_($i)
                    puts $file_html "<p>"
                    puts $file_html [format "<img src=$html_dir_/figure/btnk_util_rev_%d_plot2.png> <br>" $i]
                } 
            }
	}
	
	# queue percentile	
	if {[$self set show_graph_percentile_]==1} {
	    $self instvar percentile_graph_rev_ percentile_name_rev_
	    for {set i 0 } { $i < [array size percentile_graph_rev_] } { incr i } {
		    set xy_graph_percentile_rev [new Graph/XY "$tmp_directory_/data/btnk_percentile_rev_$i.trace" "" "steps"]
		    set ymax [file-max 1 "$tmp_directory_/data/btnk_percentile_rev_$i.trace"]
		    if { $ymax < 0.00000001 } {
                set ymax 1
            } else {
                set ymax [ expr $ymax + 5 ]
		    }
            eval $self generate_graph xy_graph_percentile_rev "\"$percentile_name_rev_($i)\"" "\"Interval=[expr $step_small_]s\"" "seconds" "packets" $ymax "$tmp_directory_/figure/btnk_percentile_rev_$i"
            if { $if_html_ == "1" } {
                $png_graph plot $xy_graph_percentile_rev
                puts $file_html "<p>"
                puts $file_html [format "<img src=$html_dir_/figure/btnk_percentile_rev_%d_plot2.png> <br>" $i]
            } 
	    }
	}
	
	# queue length
	if {[$self set show_graph_qlen_]==1} {
	    $self instvar qlen_graph_rev_
	    for {set i 0 } { $i < [array size qlen_graph_rev_] } { incr i } {
	        $qlen_graph_rev_($i) display
                if { $if_html_ == "1" } {
                    $png_graph plot $qlen_graph_rev_($i) 
                    puts $file_html "<p>"
                    puts $file_html [format "<img src=$html_dir_/figure/btnk_qlen_rev_%d_plot2.png> <br>" $i]
                } 
	    }
	}
    
    # Tmix reverse queue delay
	if {[$self set show_graph_tmix_]==1} {
        $self instvar tmix_qdelay_reverse_ 
        set xy_graph_qdelay_rev [new Graph/XY "$tmp_directory_/data/$tmix_qdelay_reverse_" "" "steps"]
        set ymax [file-max 1 "$tmp_directory_/data/$tmix_qdelay_reverse_"]
        if { $ymax < 0.00000001 } {
            set ymax 1
        } else {
            set ymax [expr $ymax + 1]
        }
        eval $self generate_graph xy_graph_qdelay_rev "\"Reverse Bottleneck No.1 Queueing Delay\"" "\"Interval = 1s\"" "seconds" "microseconds" $ymax "$tmp_directory_/figure/btnk_qdelay_rev_1"
        if { $if_html_ == "1" } {
            $png_graph plot $xy_graph_qdelay_rev
            puts $file_html [format "<img src=$html_dir_/figure/btnk_qdelay_rev_1_plot2.png> <br>" ]
        } 
    }
}
    
################################ FTP statistics ################################### 
#******************************* forward ***********************************
if {[$self set show_graph_fwd_]==1} {
    # FTP throughput and fairness
    if {[$self set show_graph_throughput_]==1} {
	
	if { $if_html_ == "1" } {
	    puts $file_html "<br>"
	    puts $file_html "<font size=5 color=0066ff>Forward FTP Statistics</font> <br>"
	}
        $self instvar show_convergence_time_
        $self instvar  throughput_ftp_fwd_
	if { [ info exists throughput_ftp_fwd_ ] } {
	    set num_ftp_fwd [array size throughput_ftp_fwd_]
	    if { $show_convergence_time_==0 } {
		    set sum_ftp 0
		    set sum_square 0
		    set file_ftp [open "$tmp_directory_/data/ftp_thr_fwd" "a"]
		    puts $file_ftp "Forward FTP Throughput #No  #Throughput"
            if { $if_html_ == "1" } {
                puts $file_html "Forward FTP Throughput <br>" 
            } 
		    for {set i 0 } { $i < $num_ftp_fwd} { incr i } {
                 set throughput [format "%.2f" [$throughput_ftp_fwd_($i) get-goodput-bps] ]
                 puts $file_ftp "[expr $i + 1]  $throughput bps"
                 if { $if_html_ == "1" } {
                     puts $file_html "[expr $i + 1], $throughput bps<br>" 
                 }
                 set sum_ftp  [expr $sum_ftp + $throughput]
                 set sum_square [expr $throughput * $throughput + $sum_square]
            }
		    set sum_ftp [format "%.2f" $sum_ftp ]
		    puts $file_ftp "Total Throughput $sum_ftp bps"
		    if { $num_ftp_fwd >=1 } {
                 puts $file_ftp [format "Average throughput %0.2f bps" [expr $sum_ftp * 1.0 / $num_ftp_fwd ] ]
            }
            if { $if_html_ == "1" } {
		        puts $file_html "Total Throughput $sum_ftp bps<br>"
		        puts $file_html [format "Average Throughput %0.2f bps <br>" [expr $sum_ftp * 1.0 / $num_ftp_fwd ] ]
		    }
		
		    if { $sum_square > 0 && $num_ftp_fwd > 0 } {
                set fairness [format "%.3f" [expr $sum_ftp * $sum_ftp / $sum_square / $num_ftp_fwd] ]
            } else {
                set fairness 0
            }
		    puts $file_ftp "Fairness  $fairness"

		    if { $if_html_ == "1" } {
		        puts $file_html "Fairness  $fairness <br>"
            }

            close $file_ftp
	    }  else {
            global tmp_directory_
            for {set i 0 } { $i < $num_ftp_fwd } { incr i } {
                set xy_graph_throughput_fwd($i) [new Graph/XY "$tmp_directory_/data/ftp_thr_fwd$i" "flow$i" "lines"]
                if { $i>0} {
                    $xy_graph_throughput_fwd(0) overlay $xy_graph_throughput_fwd($i)
                }
		    }
            if { $num_ftp_fwd > 0 }  {
                eval $self generate_graph xy_graph_throughput_fwd(0) "\"Forward FTP Throughput\"" "\"Interval=[expr $step_small_]s\"" "seconds" "\"Throughput (bps)\"" "\" \"" "$tmp_directory_/figure/ftp_thr_fwd"
                if { $if_html_ == "1" } {
                    $png_graph plot  $xy_graph_throughput_fwd(0) 
                    puts $file_html "<p>" 
                    puts $file_html "<img src=$html_dir_/figure/ftp_thr_fwd_plot2.png> <br>"
                }
            }
	    }
	}
    }
    # response function
    if {[$self set show_graph_response_function_]==1} {
        $self instvar throughput_ftp_fwd_ error_rate_ scheme_
        set num_ftp_fwd [array size throughput_ftp_fwd_]
        set sum_ftp 0
	    for {set i 0 } { $i < $num_ftp_fwd } { incr i } {
            set throughput [$throughput_ftp_fwd_($i) get-goodput-bps]
            set sum_ftp [expr $sum_ftp + $throughput]
        }
        set average [expr $sum_ftp * 1.0  / $num_ftp_fwd]
        set filename [format "$tmp_directory_/data/%s_response_fwd" $scheme_]   
        set file_response [open $filename "a"]
        puts $file_response "$error_rate_ $average"
        close $file_response
    }
    
    # TCP stats
    if {[$self set show_graph_cwnd_]==1} {
	$self instvar cwnd_graph_fwd_
	for {set i 1 } { $i < [array size cwnd_graph_fwd_] } { incr i } {
	    $cwnd_graph_fwd_(0) overlay $cwnd_graph_fwd_($i) 
	}
	if { [ array size cwnd_graph_fwd_ ] > 0 } {
	    $cwnd_graph_fwd_(0) display
	    if { $if_html_ == "1" } {
		$png_graph plot $cwnd_graph_fwd_(0) 
		puts $file_html "<p>"
		puts $file_html "<img src=$html_dir_/figure/tcp_cwnd_fwd_0_plot2.png> <br>"
	    } 
	}
    
	# cross cwnd, for debug use
	$self instvar cwnd_graph_cross_
	for {set i 1 } { $i < [array size cwnd_graph_cross_] } { incr i } {
	    $cwnd_graph_cross_(0) overlay $cwnd_graph_cross_($i) 
	}
	if { [ array size cwnd_graph_cross_ ] > 0 } {
	    $cwnd_graph_cross_(0) display
	    if { $if_html_ == "1" } {
		$png_graph plot $cwnd_graph_cross_(0) 
		puts $file_html "<p>"
		puts $file_html "<img src=$html_dir_/figure/tcp_cwnd_cross_0_plot2.png> <br>"
	    } 
	}
    }
    
    # SRTT
    if {[$self set show_graph_srtt_]==1} {
	$self instvar srtt_graph_fwd_
	for {set i 1 } { $i < [array size srtt_graph_fwd_] } { incr i } {
	    $srtt_graph_fwd_(0) overlay $srtt_graph_fwd_($i) 
	}
	if { [ array size srtt_graph_fwd_ ] > 0 } {
	    $srtt_graph_fwd_(0) display
	}
    }
    
    # RTT
    if {[$self set show_graph_rtt_]==1} {
	$self instvar rtt_graph_fwd_
	for {set i 1 } { $i < [array size rtt_graph_fwd_] } { incr i } {
	    $rtt_graph_fwd_(0) overlay $rtt_graph_fwd_($i) 
	}
	if { [ array size rtt_graph_fwd_ ] > 0 } {
	    $rtt_graph_fwd_(0) display
	}
    }
    
    if {[$self set show_graph_seqno_]==1} {
	$self instvar seqno_graph_fwd_
	for {set i 1 } { $i < [array size seqno_graph_fwd_] } { incr i } {
	    $seqno_graph_fwd_(0) overlay $seqno_graph_fwd_($i) "Fwd Flow $i "
	}   
	if { [ array size seqno_graph_fwd_ ] > 0 } {
	    $seqno_graph_fwd_(0) display
	}
    }    
}

#******************************* cross ***********************************
# throughput
if {[$self set show_graph_cross_]==1} {
    $self instvar  throughput_ftp_cross_
    $self instvar  no_btnk_ no_flow_
    if { [ info exists throughput_ftp_cross_ ] } {
	    set num_ftp_cross [array size throughput_ftp_cross_]
	    if { $if_html_ == "1" } {
	       puts $file_html "<br>"
	       puts $file_html "<font size=5 color=0066ff>Cross FTP Statistics</font> <br>"
	    }
        set sum_ftp 0
        set sum_square 0
        set file_cross [open "$tmp_directory_/data/ftp_thr_cross" "a"]
	    puts $file_cross "Cross FTP Throughput #btnk - No  #Throughput"
	    if { $if_html_ == "1" } {
	        puts $file_html "Cross FTP Throughput <br>" 
	    } 
	    for {set i 0 } { $i < $num_ftp_cross } { incr i } {
	        set a $no_btnk_($i)
	        set b $no_flow_($i)
            set throughput [format "%.2f" [$throughput_ftp_cross_($i) get-goodput-bps]]
	        puts $file_cross "[expr $a+1] - [expr $b+1], $throughput bps"
	        if { $if_html_ == "1" } {
		    puts $file_html "[expr $a+1] - [expr $b+1], $throughput bps<br>"
	        } 
        }
    close $file_cross
    }  
}

	
#******************************* reverse ***********************************
# FTP throughtput
if {[$self set show_graph_rev_]==1} {
    
    if {[$self set show_graph_throughput_]==1 }  {
	    $self instvar  throughput_ftp_rev_
	    if { [ info exists throughput_ftp_rev_ ] } {
	        set num_ftp_rev [array size throughput_ftp_rev_]
	        set sum_ftp 0
	        set sum_square 0
	        set file_rev [open "$tmp_directory_/data/ftp_thr_rev" "a"]
	        puts $file_rev "Reverse FTP Throughput #No  #Throughput"
	        if { $if_html_ == "1" } {
		        puts $file_html "<br>"
		        puts $file_html "<font size=5 color=0066ff>Reverse FTP Statistics</font> <br>"
	        }
	        for {set i 0 } { $i < $num_ftp_rev} { incr i } {
		        set throughput [format "%.2f" [$throughput_ftp_rev_($i) get-goodput-bps]]
	            puts $file_rev "[expr $i+1]  $throughput bps"
		        set sum_ftp [expr $sum_ftp + $throughput]
		        set sum_square [expr $throughput * 1.0 * $throughput + $sum_square]
		        if { $if_html_ == "1" } {
		            puts $file_html "[expr $i+1],  $throughput bps<br>"
		        } 
	        }
            set sum_ftp [format "%.2f" $sum_ftp] 
	        puts $file_rev "Total Throughput $sum_ftp bps"
	        puts $file_rev [format "Average Throughput %0.2f bps" [expr $sum_ftp * 1.0 / $num_ftp_rev ] ]
	        if { $if_html_ == "1" } {
	            puts $file_html "Total Throughput $sum_ftp bps <br>"
	            puts $file_html [format "Average throughput %0.2f bps<br>" [expr $sum_ftp * 1.0 / $num_ftp_rev ] ]
	        }
	        if { $sum_square > 0 && $num_ftp_rev > 0 } {
		        set fairness [format "%.3f" [expr $sum_ftp * $sum_ftp * 1.0 / $sum_square / $num_ftp_rev]]
	        } else {
		        set fairness 0
	        }
	        puts $file_rev "Fairness  $fairness"
	        if { $if_html_ == "1" } {
		        puts $file_html "Fairness  $fairness <br>"
	        } 
	        close $file_rev
	    }
    }
    
    if {[$self set show_graph_response_function_]==1} {
        $self instvar throughput_ftp_rev_ error_rate_ scheme_
	    set num_ftp_rev [array size throughput_ftp_rev_]
        set sum_ftp 0
	    for {set i 0 } { $i < $num_ftp_rev } { incr i } {
            set throughput [$throughput_ftp_rev_($i) get-goodput-bps]
            set sum_ftp [expr $sum_ftp + $throughput]
        }
        set average [expr $sum_ftp * 1.0  / $num_ftp_rev]
	
        set filename [format "$tmp_directory_/data/%s_response_rev" $scheme_]   
        set file_response [open $filename "a"]
        puts $file_response "$error_rate_ $average"
    }
    
    # TCP stats  
    # CWND
    if {[$self set show_graph_cwnd_]==1} {
	    $self instvar cwnd_graph_rev_
	    for {set i 1 } { $i < [array size cwnd_graph_rev_] } { incr i } {
            $cwnd_graph_rev_(0) overlay $cwnd_graph_rev_($i) 
	    }
	    if { [ array size cwnd_graph_rev_ ] > 0 } {
            $cwnd_graph_rev_(0) display
	    }
    }
    
    # SRTT
    if {[$self set show_graph_srtt_]==1} {
	    $self instvar srtt_graph_rev_
	    for {set i 1 } { $i < [array size srtt_graph_rev_] } { incr i } {
	        $srtt_graph_rev_(0) overlay $srtt_graph_rev_($i) 
	    }
	    if { [ array size srtt_graph_rev_ ] > 0 } {
	        $srtt_graph_rev_(0) display
	    }
    }
   
    # RTT
    if {[$self set show_graph_rtt_]==1} {
	    $self instvar rtt_graph_rev_
	    for {set i 1 } { $i < [array size rtt_graph_rev_] } { incr i } {
	        $rtt_graph_rev_(0) overlay $rtt_graph_rev_($i) 
	    }
	    if { [ array size rtt_graph_rev_ ] > 0 } {
	        $rtt_graph_rev_(0) display
	    }
	}

    # seqno
    if {[$self set show_graph_seqno_]==1} {
	    $self instvar seqno_graph_rev_
	    for {set i 1 } { $i < [array size seqno_graph_rev_] } { incr i } {
	        $seqno_graph_rev_(0) overlay $seqno_graph_rev_($i) "Reverse Flow $i "
	    }
	    if { [ array size seqno_graph_rev_ ] > 0 } {
	        $seqno_graph_rev_(0) display
	    }
    }
}
# End displaying reverse graphs

# TCP throughput statistics, for debug use
set total_rate 0
if {[$self set show_tcp_throughput_]==1} {
    $self instvar tcp_
    for { set i 0 } { $i < [array size tcp_] } { incr i } {
	    set rate_i [expr [$tcp_($i) get-throughput-bps] / 1000000.0] ;# Mbps
	    set total_rate [expr $total_rate + $rate_i]
	    puts [format "  fwd ftp flow %d throughput:    %.3f Mbps" $i $rate_i]
    }
    puts [format "  fwd ftp flow throughput sum:  %.3f Mbps" $total_rate]
    #puts [format "  fwd ftp flow timeout sum:  %d" $total_timeout]
    #puts [format "  fwd ftp flow runtime sum:  %.1f s" $total_runtime]    
}
   
################################ HTTP statistics ################################### 
# Forward
if {[$self set show_graph_fwd_]==1} {
    if {[$self set show_graph_http_]==1 && [file exists "$tmp_directory_/data/pm.dat" ] } {
        if { $if_html_ == "1" } {
	        puts $file_html "<font size=5 color=0066ff>Forward HTTP Statistics Figures</font> <br>"
	    }
	    $self instvar num_http_fwd_
	    set ymax_req_tmp ""
        set ymax_res_tmp ""
        set ymax_time_tmp ""
	    set http_thr_request_awk "\{\n\
        if (NF==6) print \$1,\$2*8*1000/\$4
        \}"	
	    set http_thr_response_awk "\{\n\
        if (NF==6) print \$1,\$3*8*1000/\$4
        \}"	
	    set http_response_time_awk "\{\n\
        if (NF==6) print \$1,\$4/1000
        \}"	
		exec awk $http_thr_request_awk $tmp_directory_/data/pm.dat > $tmp_directory_/data/http_req_thr
		exec awk $http_thr_response_awk $tmp_directory_/data/pm.dat > $tmp_directory_/data/http_res_thr
		set xy_graph_request [new Graph/XY "$tmp_directory_/data/http_req_thr" "" "steps"]
		set xy_graph_response [new Graph/XY "$tmp_directory_/data/http_res_thr" "" "steps"]
		
		# extract response time
		exec awk  $http_response_time_awk $tmp_directory_/data/pm.dat > $tmp_directory_/data/http_res_time
		set xy_graph_response_time [new Graph/XY "$tmp_directory_/data/http_res_time" "" "steps"]
		set ymax_req_tmp "$ymax_req_tmp $tmp_directory_/data/http_req_thr"
		set ymax_res_tmp "$ymax_res_tmp $tmp_directory_/data/http_res_thr"
		set ymax_time_tmp "$ymax_time_tmp $tmp_directory_/data/http_res_time"
		
		set ymax_req [file-max 1 $ymax_req_tmp]
		set ymax_res [file-max 1 $ymax_res_tmp]
		set ymax_time [file-max 1 $ymax_time_tmp]
		if { $ymax_req < 0.00000001 } {
		    set ymax_req 1
		} else {
		    set ymax_req [expr $ymax_req + 5]
		}
		if { $ymax_res < 0.00000001 } {
		    set ymax_res 1
		} else {
		    set ymax_res [expr $ymax_res + 5]
		}
		if { $ymax_time < 0.00000001 } {
		    set ymax_time 1
		} else {
		    set ymax_time [expr $ymax_time + 5]
		}
		
        eval $self generate_graph xy_graph_request "\"Forward HTTP Traffic Request Throughput\"" "\" \"" "seconds" "\"Throughput (bps)\"" $ymax_req "$tmp_directory_/figure/http_req_thr"
        eval $self generate_graph xy_graph_response "\"Forward HTTP Traffic Response Throughput\"" "\" \"" "seconds" "\"Throughput (bps)\"" $ymax_res "$tmp_directory_/figure/http_res_thr"
        eval $self generate_graph xy_graph_response_time "\"Forward HTTP Traffic Response Time\"" "\" \"" "seconds" "seconds" $ymax_time "$tmp_directory_/figure/http_res_time"
        if { $if_html_ == "1" } {
            $png_graph plot $xy_graph_request
            $png_graph plot $xy_graph_response
            $png_graph plot $xy_graph_response_time
            puts $file_html "<p>"
            puts $file_html [format "<img src=$html_dir_/figure/http_req_thr_plot2.png> <br>" $i]
            puts $file_html [format "<img src=$html_dir_/figure/http_res_thr_plot2.png> <br>" $i]
            puts $file_html [format "<img src=$html_dir_/figure/http_res_time_plot2.png> <br>" $i]
        } 
	}
}                                                                

################################ Voice statistics ################################### 
# show voice delay, packet loss and jitter
if {[$self set show_graph_voice_]==1} {
    $self instvar trace_delay_fwd_
    $self instvar trace_loss_fwd_
    $self instvar trace_delay_rev_
    $self instvar trace_loss_rev_
    $self instvar trace_sv_fwd_
    $self instvar trace_sv_rev_
    $self instvar  step_small_ voice_list_
    
    set ymax_fwd_tmp ""
    set ymax_rev_tmp ""
    set ymax_delay_tmp ""
    set ymax_loss_tmp ""
    set ymax_jitter_tmp ""
    
    # throughput
    if { [info exists voice_list_] } {
        if { $if_html_ == "1" } {
	        puts $file_html "<br>"
	        puts $file_html "<font size=5 color=0066ff>Voice Statistics Figures</font> <br>"
	    }
        foreach i $voice_list_ { 
	        set xy_graph_voice_fwd($i) [new Graph/XY "$tmp_directory_/data/voice_thr_fwd_$i" "flow[expr $i+1]" "steps"]
	        set xy_graph_voice_rev($i) [new Graph/XY "$tmp_directory_/data/voice_thr_rev_$i" "flow[expr $i+1]" "steps"]
	        set ymax_fwd_tmp "$ymax_fwd_tmp $tmp_directory_/data/voice_thr_fwd_$i"
	        set ymax_rev_tmp "$ymax_rev_tmp $tmp_directory_/data/voice_thr_rev_$i"
	        if { $i>0} {
		        $xy_graph_voice_fwd(0) overlay $xy_graph_voice_fwd($i)
		        $xy_graph_voice_rev(0) overlay $xy_graph_voice_rev($i)
	        }
	    }
	    set ymax_fwd [file-max 1 $ymax_fwd_tmp]
	    set ymax_rev [file-max 1 $ymax_rev_tmp]
	    if { $ymax_fwd < 0.00000001 } {
	        set ymax_fwd 1
	    } else {
	        set ymax_fwd [expr $ymax_fwd + 5]
        }
	
	    if { $ymax_rev < 0.00000001 } {
	        set ymax_rev 1
	    } else {
	        set ymax_rev [expr $ymax_rev + 5]
	    }

        eval $self generate_graph xy_graph_voice_fwd(0) "\"Forward Voice Throughput\"" "\"Interval=[expr $step_small_]s\"" "seconds" "\"throughput (bps)\"" $ymax_fwd "$tmp_directory_/figure/voice_thr_fwd"
        eval $self generate_graph xy_graph_voice_rev(0) "\"Reverse Voice Throughput\"" "\"Interval=[expr $step_small_]s\"" "seconds" "\"throughput (bps)\"" $ymax_rev "$tmp_directory_/figure/voice_thr_rev"
	    if { $if_html_ == "1" } {
	        $png_graph plot $xy_graph_voice_fwd(0)
	        $png_graph plot $xy_graph_voice_rev(0)
	        puts $file_html "<p>"
	        puts $file_html [format "<img src=$html_dir_/figure/voice_thr_fwd_plot2.png> <br>" $i]
	        puts $file_html [format "<img src=$html_dir_/figure/voice_thr_rev_plot2.png> <br>" $i]
	    }
        foreach i $voice_list_ { 
	        close $trace_delay_fwd_($i)
	    }
    
	# Delay, loss, jitter.	
	    foreach i $voice_list_ {
	        set xy_voice_delay_fwd($i) [new Graph/XY "$tmp_directory_/data/voice_delay_fwd_$i" "flow[expr $i+1]" "steps"]
	        set xy_voice_loss_fwd($i) [new Graph/XY "$tmp_directory_/data/voice_loss_fwd_$i" "flow[expr $i+1]" ""]
	        set xy_voice_sv_fwd($i) [new Graph/XY "$tmp_directory_/data/voice_jitter_fwd_$i" "flow[expr $i+1]" "steps"]
	        set ymax_delay_tmp "$ymax_delay_tmp $tmp_directory_/data/voice_delay_fwd_$i"
	        set ymax_loss_tmp "$ymax_loss_tmp $tmp_directory_/data/voice_loss_fwd_$i"
	        set ymax_jitter_tmp "$ymax_jitter_tmp $tmp_directory_/data/voice_jitter_fwd_$i"
	        if { $i>0} {
		        $xy_voice_delay_fwd(0) overlay $xy_voice_delay_fwd($i) 
		        $xy_voice_loss_fwd(0) overlay $xy_voice_loss_fwd($i)
		        $xy_voice_sv_fwd(0) overlay $xy_voice_sv_fwd($i)
	        }
	    }
	
	    set ymax_delay [file-max 1 $ymax_delay_tmp]
	    set ymax_loss [file-max 1 $ymax_loss_tmp]
	    set ymax_jitter [file-max 1 $ymax_jitter_tmp]
	    if { $ymax_delay < 0.00000001 } {
	        set ymax_delay 1
	    } else {
	        set ymax_delay [expr $ymax_delay + 0.1]
        }
	    if { $ymax_loss < 0.00000001 } {
	        set ymax_loss 1
	    }
	    if { $ymax_jitter < 0.00000001 } {
	        set ymax_jitter 1
	    } else {
	        set ymax_jitter [expr $ymax_jitter + 0.05]
	    }
        eval $self generate_graph xy_voice_delay_fwd(0) "\"Forward Voice Traffic Delay\"" "\"Interval=[expr $step_large_]s\"" "seconds" "seconds" $ymax_delay "$tmp_directory_/figure/voice_delay_fwd"
        eval $self generate_graph xy_voice_loss_fwd(0) "\"Forward Voice Traffic Loss\"" "\"Interval=[expr $step_large_]s\"" "seconds" "percentage" $ymax_loss "$tmp_directory_/figure/voice_loss_fwd"
        eval $self generate_graph xy_voice_sv_fwd(0) "\"Forward Voice Traffic Jitter\"" "\"Interval=[expr $step_large_]s\"" "seconds" "seconds" $ymax_jitter "$tmp_directory_/figure/voice_jitter_fwd"
                
	    if { $if_html_ == "1" } {
	        $png_graph plot $xy_voice_delay_fwd(0)
	        $png_graph plot $xy_voice_loss_fwd(0)
	        $png_graph plot $xy_voice_sv_fwd(0)
	        puts $file_html "<p>"
	        puts $file_html [format "<img src=$html_dir_/figure/voice_delay_fwd_plot2.png> <br>" $i]
	        puts $file_html [format "<img src=$html_dir_/figure/voice_loss_fwd_plot2.png> <br>" $i]
	        puts $file_html [format "<img src=$html_dir_/figure/voice_jitter_fwd_plot2.png> <br>" $i]
	    }
        
	    # Reverse
	    set ymax_delay_tmp ""
	    set ymax_loss_tmp ""
	    set ymax_jitter_tmp ""
        foreach i $voice_list_ { 
	        close $trace_delay_rev_($i)
	    }
	
        foreach i $voice_list_ { 
	        set xy_voice_delay_rev($i) [new Graph/XY "$tmp_directory_/data/voice_delay_rev_$i" "flow[expr $i+1]" "steps"]
	        set xy_voice_loss_rev($i) [new Graph/XY "$tmp_directory_/data/voice_loss_rev_$i" "flow[expr $i+1]" ""]
	        set xy_voice_sv_rev($i) [new Graph/XY "$tmp_directory_/data/voice_jitter_rev_$i" "flow[expr $i+1]" "steps"]
	        set ymax_delay_tmp "$ymax_delay_tmp $tmp_directory_/data/voice_delay_rev_$i"
	        set ymax_loss_tmp "$ymax_loss_tmp $tmp_directory_/data/voice_loss_rev_$i"
	        set ymax_jitter_tmp "$ymax_jitter_tmp $tmp_directory_/data/voice_jitter_rev_$i"
	        if { $i>0} {
		        $xy_voice_delay_rev(0) overlay $xy_voice_delay_rev($i) 
		        $xy_voice_loss_rev(0) overlay $xy_voice_loss_rev($i)
		        $xy_voice_sv_rev(0) overlay $xy_voice_sv_rev($i)
	        }
	    }
	
	    set ymax_delay [file-max 1 $ymax_delay_tmp]
	    set ymax_loss [file-max 1 $ymax_loss_tmp]
	    set ymax_jitter [file-max 1 $ymax_jitter_tmp]
	    if { $ymax_delay < 0.00000001 } {
	        set ymax_delay 1
	    } else {
	        set ymax_delay [expr $ymax_delay + 0.1]
        }
	    if { $ymax_loss < 0.00000001 } {
	        set ymax_loss 1
        }
	    if { $ymax_jitter < 0.00000001 } {
	        set ymax_jitter 1
        } else {
	        set ymax_jitter [expr $ymax_jitter + 0.05]
        }
        eval $self generate_graph xy_voice_delay_rev(0) "\"Reverse Voice Traffic Delay\"" "\"Interval=[expr $step_large_]s\"" "seconds" "seconds" $ymax_delay "$tmp_directory_/figure/voice_delay_rev"
        eval $self generate_graph xy_voice_loss_rev(0) "\"Reverse Voice Traffic Loss\"" "\"Interval=[expr $step_large_]s\"" "seconds" "percentage" $ymax_loss "$tmp_directory_/figure/voice_loss_rev"
        eval $self generate_graph xy_voice_sv_rev(0) "\"Reverse Voice Traffic Jitter\"" "\"Interval=[expr $step_large_]s\"" "seconds" "seconds" $ymax_jitter "$tmp_directory_/figure/voice_jitter_rev"
        
	    if { $if_html_ == "1" } {
	        $png_graph plot $xy_voice_delay_rev(0)
	        $png_graph plot $xy_voice_loss_rev(0)
	        $png_graph plot $xy_voice_sv_rev(0)
	        puts $file_html "<p>"
	        puts $file_html [format "<img src=$html_dir_/figure/voice_delay_rev_plot2.png> <br>" $i]
	        puts $file_html [format "<img src=$html_dir_/figure/voice_loss_rev_plot2.png> <br>" $i]
	        puts $file_html [format "<img src=$html_dir_/figure/voice_jitter_rev_plot2.png> <br>" $i]
	    }
    }
}

################################ Streaming statistics ################################### 
# forward    
if {[$self set show_graph_fwd_]==1} {
    $self instvar  step_small_
    $self instvar trace_streaming_delay_fwd_ streaming_list_fwd_
    if {[$self set show_graph_streaming_]==1 && [info exists streaming_list_fwd_]} {
        if { $if_html_ == "1" } {
	        puts $file_html "<br>"
	        puts $file_html "<font size=5 color=0066ff>Forward Streaming Statistics Figures</font> <br>"
	    }
	
	    set ymax_tmp ""
	    set ymax_delay_tmp ""
	    set ymax_loss_tmp ""
	    set ymax_jitter_tmp ""
    
	    # throughput
	    foreach i $streaming_list_fwd_ { 
	        set xy_graph_streaming_fwd($i) [new Graph/XY "$tmp_directory_/data/streaming_thr_fwd_$i" "flow$i" "steps"]
	        set ymax_tmp "$ymax_tmp $tmp_directory_/data/streaming_thr_fwd_$i"
	        if { $i>0} {
		        $xy_graph_streaming_fwd(0) overlay $xy_graph_streaming_fwd($i)
	        }
	    }

	    set ymax [file-max 1 $ymax_tmp]
	    if { $ymax < 0.00000001 } {
	        set ymax 1
	    } else {
	        set ymax [expr $ymax +5 ]
	    }
        eval $self generate_graph xy_graph_streaming_fwd(0) "\"Forward Streaming Throughput\"" "\"Interval=[expr $step_small_]s\"" "seconds" "\"throughput (bps)\"" $ymax "$tmp_directory_/figure/streaming_thr_fwd"
	    if { $if_html_ == "1" } {
	        $png_graph plot $xy_graph_streaming_fwd(0)
	        puts $file_html "<p>"
	        puts $file_html [format "<img src=$html_dir_/figure/streaming_thr_fwd_plot2.png> <br>" $i]
	    }
    
	# delay and loss
	    foreach i $streaming_list_fwd_ { 
	        close $trace_streaming_delay_fwd_($i)
	    }
	    foreach i $streaming_list_fwd_ { 
	        set xy_streaming_delay_fwd($i) [new Graph/XY "$tmp_directory_/data/streaming_delay_fwd_$i" "flow[expr $i+1]" "steps"]
	        set xy_streaming_loss_fwd($i) [new Graph/XY "$tmp_directory_/data/streaming_loss_fwd_$i" "flow[expr $i+1]" ""]
	        set xy_streaming_sv_fwd($i) [new Graph/XY "$tmp_directory_/data/streaming_jitter_fwd_$i" "flow[expr $i+1]" "steps"]
	        set ymax_delay_tmp "$ymax_delay_tmp $tmp_directory_/data/streaming_delay_fwd_$i"
	        set ymax_loss_tmp "$ymax_loss_tmp $tmp_directory_/data/streaming_loss_fwd_$i"
	        set ymax_jitter_tmp "$ymax_jitter_tmp $tmp_directory_/data/streaming_jitter_fwd_$i"
	        if { $i>0} {
		        $xy_streaming_delay_fwd(0) overlay $xy_streaming_delay_fwd($i) 
		        $xy_streaming_loss_fwd(0) overlay $xy_streaming_loss_fwd($i)
		        $xy_streaming_sv_fwd(0) overlay $xy_streaming_sv_fwd($i)
	        }
	    }
	
	    set ymax_delay [file-max 1 $ymax_delay_tmp]
	    set ymax_loss [file-max 1 $ymax_loss_tmp]
	    set ymax_jitter [file-max 1 $ymax_jitter_tmp]
	    if { $ymax_delay < 0.00000001 } {
	        set ymax_delay 1
	    } else {
	        set ymax_delay [expr $ymax_delay + 0.1]
        }
	    if { $ymax_loss < 0.00000001 } {
	        set ymax_loss 1
	    }
	    if { $ymax_jitter < 0.00000001 } {
	        set ymax_jitter 1
        } else {
	        set ymax_jitter [expr $ymax_jitter + 0.05]
	    }
        eval $self generate_graph xy_streaming_delay_fwd(0) "\"Forward Streaming Traffic Delay\"" "\"Interval=[expr $step_large_]s\"" "seconds" "seconds" $ymax_delay "$tmp_directory_/figure/streaming_delay_fwd"
        eval $self generate_graph xy_streaming_loss_fwd(0) "\"Forward Streaming Traffic Loss\"" "\"Interval=[expr $step_large_]s\"" "seconds" "percentage" $ymax_loss "$tmp_directory_/figure/streaming_loss_fwd"
        eval $self generate_graph xy_streaming_sv_fwd(0) "\"Forward Streaming Traffic Jitter\"" "\"Interval=[expr $step_large_]s\"" "seconds" "seconds" $ymax_jitter "$tmp_directory_/figure/streaming_jitter_fwd"
	
        if { $if_html_ == "1" } {
	        $png_graph plot $xy_streaming_delay_fwd(0)
	        $png_graph plot $xy_streaming_loss_fwd(0)
	        $png_graph plot $xy_streaming_sv_fwd(0)
	        puts $file_html "<p>"
	        puts $file_html [format "<img src=$html_dir_/figure/streaming_delay_fwd_plot2.png> <br>" $i]
	        puts $file_html [format "<img src=$html_dir_/figure/streaming_loss_fwd_plot2.png> <br>" $i]
            puts $file_html [format "<img src=$html_dir_/figure/streaming_jitter_fwd_plot2.png> <br>" $i]
        }
    }
}

# Reverse    
if {[$self set show_graph_rev_]==1} {
    $self instvar  step_small_
    $self instvar trace_streaming_delay_rev_ streaming_list_rev_
    if {[$self set show_graph_streaming_]==1 && [info exists streaming_list_rev_]} {
        if { $if_html_ == "1" } {
	        puts $file_html "<br>"
	        puts $file_html "<font size=5 color=0066ff>Reverse Streaming Statistics Figures</font> <br>"
	    }
	    set ymax_tmp ""
	    set ymax_delay_tmp ""
	    set ymax_loss_tmp ""
	    set ymax_jitter_tmp ""
	    foreach i $streaming_list_rev_ { 
	        set xy_graph_streaming_rev($i) [new Graph/XY "$tmp_directory_/data/streaming_thr_rev_$i" "flow[expr $i +1]" "steps"]
	        set ymax_tmp "$ymax_tmp $tmp_directory_/data/streaming_thr_rev_$i"
	        if { $i>0} {
		       $xy_graph_streaming_rev(0) overlay $xy_graph_streaming_rev($i)
	        }
	    }
	    set ymax [file-max 1 $ymax_tmp]
	    if { $ymax < 0.00000001 } {
	        set ymax 1
	    } else {
	        set ymax [expr $ymax +5 ]
	    }
        eval $self generate_graph xy_graph_streaming_rev(0) "\"Reverse Streaming Throughput\"" "\"Interval=[expr $step_small_]s\"" "seconds" "\"throughput (bps)\"" $ymax "$tmp_directory_/figure/streaming_thr_rev"
	    if { $if_html_ == "1" } {
	        $png_graph plot $xy_graph_streaming_rev(0)
	        puts $file_html "<p>"
	        puts $file_html [format "<img src=$html_dir_/figure/streaming_thr_rev_plot2.png> <br>" $i]
	    }
	
            # show delay and loss
	    foreach i $streaming_list_rev_ { 
	        close $trace_streaming_delay_rev_($i)
	    }
	    foreach i $streaming_list_rev_ { 
	        set xy_streaming_delay_rev($i) [new Graph/XY "$tmp_directory_/data/streaming_delay_rev_$i" "flow[expr $i+1]" "steps"]
	        set xy_streaming_loss_rev($i) [new Graph/XY "$tmp_directory_/data/streaming_loss_rev_$i" "flow[expr $i+1]" ""]
	        set xy_streaming_sv_rev($i) [new Graph/XY "$tmp_directory_/data/streaming_jitter_rev_$i" "flow[expr $i+1]" "steps"]
	        set ymax_delay_tmp "$ymax_delay_tmp $tmp_directory_/data/streaming_delay_rev_$i"
	        set ymax_loss_tmp "$ymax_loss_tmp $tmp_directory_/data/streaming_loss_rev_$i"
	        set ymax_jitter_tmp "$ymax_jitter_tmp $tmp_directory_/data/streaming_jitter_rev_$i"
	        #set xy_streaming_delay_rev($i) [new Graph/XY "$tmp_directory_/streaming_delay_rev$i" "flow$i" "steps"]
	        #set xy_streaming_loss_rev($i) [new Graph/XY "$tmp_directory_/streaming_loss_rev$i" "flow$i" "steps"]
	        if { $i>0} {
		        $xy_streaming_delay_rev(0) overlay $xy_streaming_delay_rev($i) 
		        $xy_streaming_loss_rev(0) overlay $xy_streaming_loss_rev($i)
		        $xy_streaming_sv_rev(0) overlay $xy_streaming_sv_rev($i)
	        }
	    }
	    
	    set ymax_delay [file-max 1 $ymax_delay_tmp]
	    set ymax_loss [file-max 1 $ymax_loss_tmp]
	    set ymax_jitter [file-max 1 $ymax_jitter_tmp]
	    if { $ymax_delay < 0.00000001 } {
	        set ymax_delay 1
	    } else {
	        set ymax_delay [expr $ymax_delay + 0.1]
	    }
	    if { $ymax_loss < 0.00000001 } {
	        set ymax_loss 1
	    }
	    if { $ymax_jitter < 0.00000001 } {
	        set ymax_jitter 1
	    } else {
	        set ymax_jitter [expr $ymax_jitter + 0.05]
	    }
        eval $self generate_graph xy_streaming_delay_rev(0) "\"Reverse Streaming Traffic Delay\"" "\"Interval=[expr $step_large_]s\"" "seconds" "seconds" $ymax_delay "$tmp_directory_/figure/streaming_delay_rev"
        eval $self generate_graph xy_streaming_loss_rev(0) "\"Reverse Streaming Traffic Loss\"" "\"Interval=[expr $step_large_]s\"" "seconds" "percentage" $ymax_loss "$tmp_directory_/figure/streaming_loss_rev"
        eval $self generate_graph xy_streaming_sv_rev(0) "\"Reverse Streaming Traffic Jitter\"" "\"Interval=[expr $step_large_]s\"" "seconds" "seconds" $ymax_jitter "$tmp_directory_/figure/streaming_jitter_rev"
	
        if { $if_html_ == "1" } {
            $png_graph plot $xy_streaming_delay_rev(0)
            $png_graph plot $xy_streaming_loss_rev(0)
            $png_graph plot $xy_streaming_sv_rev(0)
            puts $file_html "<p>"
            puts $file_html [format "<img src=$html_dir_/figure/streaming_delay_rev_plot2.png> <br>" $i]
            puts $file_html [format "<img src=$html_dir_/figure/streaming_loss_rev_plot2.png> <br>" $i]
            puts $file_html [format "<img src=$html_dir_/figure/streaming_jitter_rev_plot2.png> <br>" $i]
        }
    }
}

################################ tmix ################################### 
$self instvar num_tmix_flow_ tmix_qdelay_forward_ tmix_qdelay_reverse_ tmix_flow_ sim_time_ btnk_buf_bdp_
$self instvar secD_decreased_time max_changed_cw last_window show_secD_
$self instvar secD_loss secD_delaymon 
if {[$self set show_graph_tmix_]==1 && $num_tmix_flow_>0} {
    set file_name [open "$tmp_directory_/data/tmix_flow" "r"]
    set i 0
    foreach line [split [read $file_name] \n] {
        set j 0
        foreach row [split $line \ ] {
            set flow($i,$j) [format "%0.2f" [expr $row * 8 / $sim_time_]]
            set j [expr $j +1]
        }
        set i [expr $i +1]
    }
    # for sectionC
    set nth_time(0) 0
    set nth_time(1) 0
    if [file exist "$tmp_directory_/data/tmix_nth_time_1"] {
        set file_name [open "$tmp_directory_/data/tmix_nth_time_1" "r"]
        set line [read $file_name]
        set i 0
        foreach row [split $line \ ] {
           set nth_time($i) $row
           set i [expr $i +1]
        }
    }

    set rate(0) 0
    set rate(1) 0
    set rate(2) 0
    set rate(3) 0
	if { $if_html_ == "1" } {
        puts $file_html "<br>" 
        puts $file_html "<font size=5 color=0066ff>Tmix Statistics</font> <br>"
	    puts $file_html "Tmix Flow  Throughput <br>"
    }
    for { set i 0 } { $i < $num_tmix_flow_ } { incr i } {           
	    if { $if_html_ == "1" } {
            puts $file_html "Flow $i initiator sending throughput $flow($i,0) bps <br>"
            puts $file_html "Flow $i initiator receiving throughput $flow($i,1) bps <br>"
	        puts $file_html "Flow $i acceptor sending throughput $flow($i,2) bps <br>"
	        puts $file_html "Flow $i acceptor receiving $flow($i,3) bps <br>"
		    puts $file_html "<br>"
        }
        set rate(0) [expr $rate(0) + $flow($i,0)]
        set rate(1) [expr $rate(1) + $flow($i,1)]
        set rate(2) [expr $rate(2) + $flow($i,2)]
        set rate(3) [expr $rate(3) + $flow($i,3)]
    }
    set avg_rate_init_s [format "%0.2f" [expr $rate(0)/$num_tmix_flow_]]
    set avg_rate_init_r [format "%0.2f" [expr $rate(1)/$num_tmix_flow_]]
    set avg_rate_acc_s  [format "%0.2f" [expr $rate(2)/$num_tmix_flow_]]
    set avg_rate_acc_r  [format "%0.2f" [expr $rate(3)/$num_tmix_flow_]]
    if { $if_html_ == "1" } {
	     puts $file_html "Average throughput, initiator sending: $avg_rate_init_s bps, initiator receiving: $avg_rate_init_r bps, acceptor sending: $avg_rate_acc_s bps, acceptor receiving: $avg_rate_acc_r bps <br>"
    }

    if {!$show_secD_} {
        set secD_decreased_time 0
        set max_changed_cw 0
        set secD_loss 0
    } else {
        $self  secD_cbr_loss $secD_delaymon
    }
    if { $verbose_ ==0 } {
	    puts -nonewline [format "%0.2f %0.2f %0.2f %0.2f %0.1f %d %0.6f %0.6f %0.6f %d " $avg_rate_init_s $avg_rate_init_r $avg_rate_acc_s $avg_rate_acc_r [expr $btnk_buf_bdp_ *100] $nth_time(0) $nth_time(1) $secD_decreased_time $max_changed_cw $secD_loss ]
        for { set i 0 } { $i < $num_tmix_flow_ } { incr i } {  
            puts -nonewline [format "%0.2f " $flow($i,1)]
        }
    }
}

if { $if_html_ == "1" } {
    close $file_html
}
$self instvar start_time_
if { $verbose_ ==0 } {
    set end_time_ [clock seconds]
    set min [expr ($end_time_ - $start_time_) / 60]
    set sec [expr ($end_time_ - $start_time_) % 60]
    puts [format "%3dm:%02ds"  $min $sec ]
}
}
