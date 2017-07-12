# Copyright(c)2001 David Harrison. 
# Licensed according to the terms of the GNU Public License.
#
# rpi-queue-monitor
#
# author: David Harrison
#

# Stuff that should be set by the superclass, but I don't know how to make
# it do so...  -D. Harrison
QueueMonitor/ED/RPI set size_ 0
QueueMonitor/ED/RPI set pkts_ 0
QueueMonitor/ED/RPI set parrivals_ 0
QueueMonitor/ED/RPI set barrivals_ 0
QueueMonitor/ED/RPI set pdepartures_ 0
QueueMonitor/ED/RPI set bdepartures_ 0
QueueMonitor/ED/RPI set pdrops_ 0
QueueMonitor/ED/RPI set bdrops_ 0

QueueMonitor/ED/RPI set pmin_qlen_ -1   ;# minimum queue length so far.
QueueMonitor/ED/RPI set pmax_qlen_ 0    ;# maximum queue length so far.
QueueMonitor/ED/RPI set bmin_qlen_ -1   ;# minimum queue length in bytes so far.
QueueMonitor/ED/RPI set bmax_qlen_ 0    ;# maximum queue length in bytes so far.
QueueMonitor/ED/RPI set bmax_qlen_thresh_ -1 
QueueMonitor/ED/RPI set time_qlen_exceeded_thresh_ 0.0
QueueMonitor/ED/RPI set every_kth_ -1   ;# sample queue length every kth pkt.
QueueMonitor/ED/RPI set every_interval_ -1 ;# sample qlen once per interval.
QueueMonitor/ED/RPI set pabove_thresh_ 0
QueueMonitor/ED/RPI set babove_thresh_ 0
QueueMonitor/ED/RPI set debug_ false    ;# DEBUG

# Added in ns-2.1b9a. For some reason, these variables are not set
# from QueueMonitor in ns-default.tcl.
#QueueMonitor/ED/RPI set pmarks_ 0
#QueueMonitor/ED/RPI set k_ -1.1
#QueueMonitor/ED/RPI set prevTime_ 0
#QueueMonitor/ED/RPI set startTime_ 0
#QueueMonitor/ED/RPI set estRate_ 0
#QueueMonitor/ED/RPI set estimate_rate_ 0
#
## from QueueMonitor/ED in ns-default.tcl.
#QueueMonitor/ED/RPI set epdrops_ 0
#QueueMonitor/ED/RPI set ebdrops_ 0
#QueueMonitor/ED/RPI set mon_epdrops_ 0                     
#QueueMonitor/ED/RPI set mon_ebdrops_ 0
# End added in ns-2.1b9a
