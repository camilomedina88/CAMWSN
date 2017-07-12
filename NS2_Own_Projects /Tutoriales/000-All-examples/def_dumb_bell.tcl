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
# $Id: def_dumb_bell.tcl,v 1.1 2008/11/03 06:25:46 wanggang Exp $
#
# This file is for dumb_bell simulation settings.
#
#
#            Src_1       Src_3      Src_4           Sink_1 
#                 \        \          \              / 
#                  \        \          \            /
#                Router1 ---Router2---Router3--- Router4  
#                  /        /          /             \ 
#                 /        /          /               \ 
#            Src_2       Sink_2     Sink_3          Sink_4 
#    
#                     Fig 1. A Dumb-bell topology. 
#

# Basic Scenario: Access Link

# 1, topology setting
set btnk_bw 100 	                                     ;# btnk bandwidth in Mbps
set per 0                                                ;# btnk packet error rate, range 0 to 1
set edge_delay [list 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10]   ;# edge link delay, two ways
set edge_bw [list 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000];# edge link bandwidth, two ways
set core_delay 10                                        ;# btnk rtt in ms
set buffer_length 100                                    ;# btnk buffer length in ms
set btnk_buf_bdp 1                                       ;# btnk buffer size %bdp

# 2, traffic setting
set sim_time 100 		                                 ;# total simulation time in sec, default 120s
set TCP_scheme FULLTCP			                         ;# the TCP scheme employed by ftp
set useAQM 0                                             ;# not to use AQM in routers

# 2.1 ftp
set num_ftp_fwd 0			                             ;# number of forward ftp flows
set num_ftp_rev 0			                             ;# number of reverse ftp flows

# 2.2 web
set http_rate 0	        	                             ;# http connection generation rate

# 2.3 voice
set num_voice 0			                                 ;# number of voice flows

# 2.4 video
set num_streaming_fwd 0			                         ;# number of forward streaming flows
set num_streaming_rev 0			                         ;# number of reverse streaming flows
set streaming_rate 640Kb		                         ;# rate of each streaming flow
set streaming_pktsize 840 		                         ;# packet size in byte

# 2.5 tmix
set num_tmix_flow 4			                             ;# number of tmix flows
set tmix_cv_name [list "../tmix-cv/sample-alt.cvec" "../tmix-cv/sample-alt.cvec" "../tmix-cv/sample-alt.cvec" "../tmix-cv/sample-alt.cvec"]
set tmix_tcp_scheme [list "Sack" "Sack" "Sack" "Sack"]   ;# tmix TCP schemes for section E
set num_btnk 3                                           ;# number of bottleneck


# 3, statistics/graph setting
set html_index 100 			                             ;# results in index100.html. if -1 no html file
set show_bottleneck_stats 1  	                         ;# btnk link stats (utilization and queue size)
set show_graph_ftp 0	                                 ;# ftp throughput
set show_graph_http 0                                    ;# http statistics
set show_graph_voice 0 			                         ;# voice statistics
set show_graph_streaming 0  	                         ;# streaming statistics
set show_graph_tmix 1  	                                 ;# tmix statistics
set show_convergence_time 0 	                         ;# FTP convergence time
set verbose 0				                             ;# detail information

# that's it -- end.
