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
# $Id: test_network_1.tcl,v 1.4 2007/04/25 11:00:42 xiayong Exp $
#
#
#                              CR1 
#           PC1               /   \                PC5 
#              \             /     \              / 
#               --- AR2 --- CR2    CR4 --- AR4 --- 
#              /             \     /              \  
#           PC2               \   /                PC6 
#                              CR3       
#                               | 
#                              / \ 
#                           PC3  PC4 
#    
#    
#                     PC: Personal Computer 
#                     AR: Access Router 
#                     CR: Core Router 
#    
#               Fig 1. A simple network topology. 
#


Class Create_topology 
Class Create_topology/Dumb_bell -superclass Create_topology

# environment setting
# [randomize simulation] 
global defaultRNG
$defaultRNG seed 0

# [include external source code]
source $env(TCPEVAL)/tcl/create_topology.tcl
source $env(TCPEVAL)/tcl/create_traffic.tcl
source $env(TCPEVAL)/tcl/create_graph.tcl
source ./def_network_1.tcl

set ns [new Simulator]
remove-all-packet-headers       ; # removes all except common
add-packet-header Flags IP TCP  ; # headers required by TCP
$ns use-scheduler Heap 

# [trace output]
#use-nam
#set tracefd [open BKtrace.tr w]
#$ns trace-all $tracefd

# [output to html files ]  
if { $html_index != -1} {
    set sim_start_time [ exec date ]
    set file_html [open "/tmp/index$html_index.html" "w"]
    puts $file_html [format "<p> <font size=5 color=0066ff > Simulation starts at %s </font></p><br>" $sim_start_time ]
    close $file_html
}

# [graph, traffic and topology settings]
# [topology setting has to be the last one]
set graph [new Create_graph]
$graph config -show_bottleneck_stats $show_bottleneck_stats \
              -show_graph_ftp $show_graph_ftp \
              -show_graph_http $show_graph_http \
              -show_graph_voice $show_graph_voice \
              -show_graph_streaming $show_graph_streaming \
              -error_rate $per \
              -html_index $html_index \
              -verbose $verbose

set traffic [new Create_traffic]
$traffic config_ftp -num_ftp_flow $num_ftp_flow \
                    -scheme $TCP_scheme \
                    -useAQM $useAQM
$traffic config_http -rate_http_flow $http_rate 
$traffic config_voice -num_voice_flow $num_voice
$traffic config_streaming -num_streaming_flow $num_streaming_flow \
                          -rate_streaming $streaming_rate \
                          -packetsize_streaming $streaming_pktsize 
                                    
set topo [new Create_topology/Network_1]
$topo config -verbose $verbose \
             -num_transit $num_transit \
             -delay_core $delay_core \
             -delay_transit $delay_transit \
             -delay_stub $delay_stub \
             -bw_core $bw_core \
             -bw_transit $bw_transit \
             -bw_stub $bw_stub \
             -traffic $traffic \
             -graph $graph \
             -sim_time $sim_time \
             -html_index $html_index
$topo create

# [finish process]
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

# [show progress]
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
