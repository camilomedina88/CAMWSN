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
# $Id: def_parking_lot.tcl,v 1.4 2008/11/03 07:51:25 wanggang Exp $
#
# This file is for parking_lot simulation settings.
#
#
#    Src_1    CrossSrc_1   rossSrc_2  CrossSrc_3 ...               Sink_1 
#         \      |           |           |                        / 
#          \     |           |           |                       / 
#  Src_2 --- Router1 --- Router2 --- Router3 --- ... --- RouterN --- Sink_2 
#          /                 |           |                 |     \ 
#         /                  |           |                 |      \ 
#    Src_N             CrossSink_1 CrossSink_2   ... CrossSink_N   Sink_N 
#    
#
#                     Fig 2. A Parking-lot topology. 
#


# 1, topology setting
set num_btnk 3                         ;# number of btnk
set btnk_bw 10                         ;# Mbps
set rttp 80                            ;# round-trip propagation delay in ms
set crs_btnk_delay 10                  ;# cross link delay in ms
set per 0                              ;# static link packet error rate. range 0 to 1.
set rtt_diff 0                         ;# rtt difference in ms


# 2, traffic setting
set sim_time 100                       ;# total simulation time in sec

# 2.1 ftp
set num_ftp_fwd 5                      ;# number of forward ftp flows
set num_ftp_rev 5                      ;# number of reverse ftp flows
set num_ftp_cross 5                    ;# number of cross ftp flows
set TCP_scheme XCP                     ;# the TCP scheme employed by ftp
set useAQM 1                           ;# use AQM in routers

# 2.2 web
set http_rate 15                       ;# http connection generation rate

# 2.3 voice
set num_voice 5                        ;# number of voice flows

# 2.4 video
set num_streaming_fwd 5                ;# number of forward streaming flows
set num_streaming_rev 5                ;# number of reverse streaming flows
set streaming_rate 640Kb               ;# rate of each streaming flow
set streaming_pktsize 840              ;# packet size in bytes


# 3, statistics/graph setting
set html_index 100                     ;# save results in index100.html. if -1 no html file
set show_bottleneck_stats 1            ;# show bottleneck link stats, such as utilization, queue size
set show_graph_ftp 	1                  ;# show ftp throughput
set show_graph_http 1                  ;# show http statistics
set show_graph_voice 1                 ;# show voice statistics
set show_graph_streaming 1             ;# show streaming statistics
set show_convergence_time 0            ;# show forward FTP convergence time
set verbose 1                          ;# show details

# that's it -- end.
