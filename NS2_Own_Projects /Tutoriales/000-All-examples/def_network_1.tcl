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
# $Id: def_network_1.tcl,v 1.3 2008/11/03 07:51:44 wanggang Exp $
#
# This file is for network simulation settings.
#
#
#                                  CR1 
#               PC1               /   \                PC5 
#                  \             /     \              / 
#                   --- AR2 --- CR2    CR4 --- AR4 --- 
#                  /             \     /              \  
#               PC2               \   /                PC6 
#                                  CR3       
#                                   | 
#                                  / \ 
#                               PC3   PC4 
#    
#    
#                         PC: Personal Computer 
#                         AR: Access Router 
#                         CR: Core Router 
#    
#                    Fig 3. A simple network topology. 
#


# 1, topology setting
set num_transit 3                   ;# number of transit domain
set delay_core 10                   ;# delay of core links, ms
set bw_core 10                      ;# bw of core links, Mbps
set delay_transit 20                ;# dealy of transit links, ms
set bw_transit 10                   ;# bw of transit links, Mbps
set delay_stub 10                   ;# delay of stub links, ms
set bw_stub 10                      ;# bw of stub linsk, Mbps
set per 0                           ;# static link packet error rate. range 0 to 1.


# 2, traffic setting
set sim_time 100                    ;# total simulation time in sec

# 2.1 ftp
set num_ftp_flow 5                  ;# number of ftp flows
set TCP_scheme XCP                  ;# the TCP scheme employed by ftp
set useAQM 1                        ;# use AQM in routers

# 2.2 web
set http_rate 15                    ;# http connection generation rate

# 2.3 voice
set num_voice 5	                    ;# number of voice flows

# 2.4 video
set num_streaming_flow 5            ;# number of streaming flows
set streaming_rate 640Kb            ;# rate of each streaming flow
set streaming_pktsize 840           ;# packet size in bytes


# 3, statistics/graph setting
set html_index 100                  ;# save results in index100.html. if -1 no html file
set show_bottleneck_stats 1         ;# show bottleneck link stats, such as utilization, queue size
set show_graph_ftp 	1               ;# show ftp throughput
set show_graph_http 1               ;# show http statistics
set show_graph_voice 1 		        ;# show voice statistics
set show_graph_streaming 1          ;# show streaming statistics
set verbose 1                       ;# show detail info

# that's it -- end.
