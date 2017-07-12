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
# $Id: test_dumb_bell.tcl,v 1.1 2008/11/03 06:25:46 wanggang Exp $
#
#
#            Src_1                                    Sink_1 
#                 \                                  / 
#                  \           bottleneck           / 
#          Src_2 --- Router1 -------------- Router2 --- Sink_2 
#                  /                                \ 
#                 /                                  \ 
#            Src_N                                    Sink_N 
#    
#
#                     Fig 1. A Dumb-bell topology. 
#


# environment setting
# [randomize simulation] 
global defaultRNG
$defaultRNG seed 0

# [include external source code]
source $env(TCPEVAL)/tcl/create_topology.tcl
source $env(TCPEVAL)/tcl/create_traffic.tcl
source $env(TCPEVAL)/tcl/create_graph.tcl
source ./def_dumb_bell.tcl

set ns [new Simulator]
remove-all-packet-headers       ; # removes all except common
add-packet-header Flags IP TCP  ; # headers required by TCP
$ns use-scheduler Heap 

# [trace output]
#use-nam
#set tracefd [open BKtrace.tr w]
#$ns trace-all $tracefd

# [output to html files] 
if { $html_index != -1} {
    set sim_start_time [ exec date ]
    set file_html [open "/tmp/index$html_index.html" "w"]
    puts $file_html [format "<p> <font size=5 color=0066ff > Simulation starts at %s </font></p><br>" $sim_start_time ]
    close $file_html
}

# [show convergence time. One ftp flow starts every 200s.] 
if { $show_convergence_time == 1 } {
    set sim_time 1000
    set num_ftp_fwd 5 
    set num_ftp_rev 5 
}

# [graph, traffic and topology settings]
# [topology setting has to be the last one]
set graph [new Create_graph]
$graph config -show_bottleneck_stats $show_bottleneck_stats \
              -show_graph_ftp $show_graph_ftp \
              -show_graph_http $show_graph_http \
              -show_graph_voice $show_graph_voice \
              -show_graph_streaming $show_graph_streaming \
              -show_graph_tmix $show_graph_tmix \
              -error_rate $per \
       	      -show_convergence_time $show_convergence_time \
              -html_index $html_index \
              -verbose $verbose

set traffic [new Create_traffic]
# tmix traffic
$traffic config_tmix -num_tmix_flow $num_tmix_flow \
                     -tmix_cv_name $tmix_cv_name \
                     -tmix_tcp_scheme $tmix_tcp_scheme

$traffic config_ftp -num_ftp_flow_fwd $num_ftp_fwd \
                    -num_ftp_flow_rev $num_ftp_rev \
                    -scheme $TCP_scheme \
                    -useAQM $useAQM
$traffic config_http -rate_http_flow $http_rate 
$traffic config_voice -num_voice_flow $num_voice
$traffic config_streaming -num_streaming_flow_fwd $num_streaming_fwd \
                          -num_streaming_flow_rev $num_streaming_rev \
                          -rate_streaming $streaming_rate \
                          -packetsize_streaming $streaming_pktsize 

set topo [new Create_topology/Dumb_bell/Basic]
$topo config -btnk_bw $btnk_bw \
             -num_btnk $num_btnk \
             -rttp $core_delay \
             -verbose $verbose \
             -rtt_diff 0 \
             -edge_delay $edge_delay \
             -edge_bw $edge_bw \
             -core_delay $core_delay \
             -buffer_length $buffer_length \
             -btnk_buf_bdp $btnk_buf_bdp \
             -traffic $traffic \
             -graph $graph \
             -sim_time $sim_time \
             -html_index $html_index 
$topo create

# finish process
proc finish {} {
    global ns topo traffic graph sim_start_time html_index 
    #tracefd
    #run-nam
    #$ns flush-trace
    #close $tracefd
    $topo finish
    $traffic finish
    $graph finish
    if { $html_index != -1 } {
	    set sim_end_time [ exec date ]
	    set file_html1 [open "/tmp/index$html_index.html" "a"]
	    puts $file_html1 [format "<p> <font size=5 color=0066ff > Simulation ends at %s </font></p><br>" [exec date] ]
	    close $file_html1
    }
    exit 0
}

# show progress
proc display_running_process {} {
    global ns display_count_start counter sim_time
    puts [format "simulation completed %0.1f %% \ " [expr  $counter*$display_count_start*100/$sim_time]]
    set counter [ expr $counter + 1 ]
    $ns at [ expr $counter * $display_count_start ] "display_running_process"
}

set display_count_start [ expr 1.0 * $sim_time / 10 ]
set counter 1
#$ns at $display_count_start "display_running_process" 
$ns at $sim_time "finish"
$ns run
