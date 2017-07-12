#
# Copyright (C) 2007 Dip. Ing. dell'Informazione, University of Pisa, Italy
# http://info.iet.unipi.it/~cng/ns2mesh80216/
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA, USA

#
# test 802.16 mesh Tcl scenario
# author: C.Cicconetti <claudio.cicconetti@iet.unipi.it>
# website: http://info.iet.unipi.it/~cng/ns2mesh80216/
#
#
# A simple string topology with four nodes is created:
#
#  0 -- 1 -- 2 -- 3
#
# Three traffic flows are established:
# - a VoIP flow with one aggregated source from 0 to 3, with priority 1
# - a VoIP flow with two aggregated sources from 1 to 3, with priority 1
# - a VoD flow with one aggregated source from 2 to 3, with priority 0
#

#
# load configuration file with default options
#
source header.msh
source traffic.msh
source metrics.msh

################################################################################
# SCENARIO CONFIGURATION
################################################################################

#
# simulation environment
#
set opt(run)        1         ;# replic ID
set opt(duration)   10.0      ;# run duration, in seconds
set opt(warm)       2.0       ;# run duration, in seconds
set opt(out)        "out"     ;# statistics output file
set opt(debug)      ""        ;# debug configuration file, "" = no debug
set opt(startdebug) 0.0       ;# start time of debug output

#
# topology
#
set opt(topology)       "chain"  ;# see TOPOLOGIES
set opt(n)              4        ;# meaningful with: chain, ring, grid,
                                 ;#    multiring, star, clique, bintree
											;#    trinagular (see TOPOLOGIES)
set opt(branches)       3        ;# meaningful with: star, multiring
                                 ;# (see TOPOLOGIES)
set opt(random-nodeid) "on"      ;# mix up NodeIDs randomly

#
# PHY
#
set opt(channel)        1      ;# number of channels
set opt(radio)          1      ;# number of radios
set opt(chan-data-per)  0      ;# channel data PDU error rate
set opt(chan-ctrl-per)  0      ;# channel control PDU error rate
set opt(propagation)    4      ;# physical propagation, in us
set opt(sym-duration)   20     ;# OFDM symbol duration, in us
set opt(sym-perframe)   500    ;# number of OFDM symbols per frame
set opt(bandwidth)      "10"   ;# in MHz, if set overrides the OFDM symbol
                               ;# duration and the number of OFDM symbols
                               ;# per frame (ie. the frame duration)
set opt(cyclic-prefix)  "1/16" ;# cyclic prefix, only used if bandwidth is set
set opt(control)        4      ;# number of MSH-DSCH opportunities per frame
set opt(cfg-interval)   16     ;# number of MSH-DSCH frames between two
                               ;# consecutive MSH-NCFG frames
set opt(msh-dsch-avg-bad)  -1  ;# consecutive bad MSH-DSCH messages
set opt(msh-dsch-avg-good) -1  ;# consecutive good MSH-DSCH messages

#
# MAC
#
set opt(allocation)  "contiguous"  ;# MSH-DSCH allocation type
set opt(hest-curr)   .1            ;# weight for H's estimations (current value)
set opt(hest-past)   .9            ;# weight for H's estimations (past values)

#
# bandwidth manager
#
set opt(bwmanager)            "fair-rr"  ;# bandwidth manager type
set opt(availabilities)       "on"       ;# RR, FairRR bwmanagers
set opt(regrant)              "on"       ;# RR, FairRR bwmanagers
set opt(regrant-offset)       1          ;# RR, FairRR bwmanagers, in frames
set opt(regrant-duration)     1          ;# RR, FairRR bwmanagers, in handshakes
set opt(grant-fairness)       "on"       ;# FairRR bwmanager = {on, off}
set opt(regrant-same-horizon) "off"      ;# FairRR bwmanager = {on, off}
set opt(regrant-fairness)     "on"       ;# FairRR bwmanager = {on, off}
set opt(request-fairness)     "on"       ;# FairRR bwmanager = {on, off}
set opt(bwm-round-duration)   21312      ;# FairRR bwmanager, in bytes
set opt(weight-timeout)       120        ;# FairRR bwmanager, in sec
set opt(max-deficit)          0          ;# FairRR bwmanager, in bytes
set opt(max-backlog)          0          ;# FairRR bwmanager, in bytes
set opt(weight-flow)          "on"       ;# FairRR bwmanager = {on, off}
set opt(grant-rnd-channel)    "on"       ;# FairRR bwmanager = {on, off}
set opt(dd-timeout)           "50"       ;# FairRR bwmanager, in MSH-DSCH opps
set opt(min-grant)            "1"        ;# FairRR bwmanager, in OFDM symbols

set opt(prio-weight)        "1 2 4"    ;# priority weights, used by both the
                                       ;# FairRR bwmanager and the scheduler

#
# distributed election coordinator
#
set opt(coordinator)      "standard" ;# coordinator type
set opt(coordmode)        "xmtunaware" ;# coordinator mode
set opt(holdoff-dsch-def) 0          ;# holdoff exponent for MSH-DSCH msgs
set opt(holdoff-ncfg-def) 0          ;# holdoff exponent for MSH-NCFG msgs
set opt(holdoff-dsch)     { }        ;# used to set different holdoffs
set opt(holdoff-ncfg)     { }        ;# used to set different holdoffs
set opt(control-period)   4          ;# dummy coordinator, number of frames
set opt(max-advertised)   -1         ;# maximum number of advertised neighbors

#
# forwarding
#
set opt(forwarding)           "spf"    ;# forwarding type
set opt(maxnumhops)           20       ;# maximum path length
set opt(profileupdateperiod)  4        ;# number of frames to update profiles
set opt(samplingperiod)       4        ;# sampling nodes'load period (frames)
set opt(chi)                  0.5      ;# weight of grants for links' cost
set opt(beta)                 0.5      ;# weight of new samples for nodes' load

#
# packet scheduler
#
set opt(scheduler)          "fair-rr"  ;# packet scheduler type
set opt(buffer)             1000000    ;# buffer size, in bytes
set opt(sch-round-duration) 21312      ;# FairRR scheduler, in bytes
set opt(buffer-sharing)     "per-flow" ;# FairRR scheduler only

#
# link profiles
#
set opt(prfall) 0    ;# default burst profile index, overriden by prfndx's
set opt(prfsrc) { }  ;# QPSK_1_2 = 0,  QPSK_3_4 = 1,
set opt(prfdst) { }  ;# QAM16_1_2 = 2, QAM16_3_4 = 3,
set opt(prfndx) { }  ;# QAM64_2_3 = 4, QAM64_3_4 = 5

################################################################################
# TRAFFIC CONFIGURATION
################################################################################

#
# traffic
#
set opt(trfsrc)   { 0 1 2 }
set opt(trfdst)   { 3 3 3 }
set opt(trftype-def)   "cbr"   ;# default traffic type
set opt(trfstart-def)   1.0     ;# default application start time
set opt(trfstop-def)   "never"  ;# default application start time
set opt(trfnsrc-def)    1       ;# default number of sources per flow
set opt(trfprio-def)    1       ;# default priority level
set opt(trftype)  { voip voip vod }
set opt(trfnsrc)  { 1    2    1 }
set opt(trfstart) { }
set opt(trfstop)  { }
set opt(trfprio)  { 1    1    0 }

#
# VoIP traffic
#
set opt(voip-model)  "one-to-one"   ;# VoIP VAD model
set opt(voip-codec)  "GSM.AMR"      ;# VoIP codec
set opt(voip-aggr)   2              ;# number of VoIP frames per packet

#
# BWA traffic
#
set opt(bwa-rate)    100000   ;# rate of BWA traffic
set opt(bwa-pkt)     192      ;# packet size of BWA traffic flows, in bytes

#
# CBR traffic
#
set opt(cbr-pkt)     1000     ;# packet size, in bytes
set opt(cbr-rate)    2000000  ;# rate, in b/s
set opt(cbr-rnd)     1        ;# set to 0 to have perfect CBR generation

#
# VoD traffic
#
set opt(vod-trace)   "traces/streaming.ns2"

#
# FTP traffic
#
set opt(ftp-wnd)    64      ;# TCP maximum congestion window size
set opt(ftp-pkt)    1024    ;# TCP Maximum Segment Size

################################################################################
# NETWORK ENTRY CONFIGURATION
################################################################################

# can be one of
# - scan
# - sponsor
# - tunnel
# - link-est
set opt(net-entry)          ""
set opt(net-entry-node)     12
set opt(net-entry-sponsor)  11
set opt(net-entry-start)    1
set opt(net-entry-bs)       0

#
# workload definition procedure
#
proc create_connections {} {
   global ns opt macmib node topo

	# create traffic sources
   for { set i 0 } { $i < [llength $opt(trfsrc)] } { incr i } {

		# if there is a default application, use it
		set traffic $opt(trftype-def)
		if { [llength $opt(trftype)] > 0 } {
			set traffic [lindex $opt(trftype) $i]
		}

		# if there is a default number of sources per flow, use it
		set nsources $opt(trfnsrc-def)
		if { [llength $opt(trfnsrc)] > 0 } {
			set nsources [lindex $opt(trfnsrc) $i ]
		}

		# if there is a default application start time, use it
		set start $opt(trfstart-def)
		if { [llength $opt(trfstart)] > 0 } {
			set start [lindex $opt(trfstart) $i ]
		}

		# if there is a default application stop time, use it
		set stop $opt(trfstop-def)
		if { [llength $opt(trfstop)] > 0 } {
			set stop [lindex $opt(trfstop) $i ]
		}

		# if there is a default priority level, use it
		set prio $opt(trfprio-def)
		if { [llength $opt(trfprio)] > 0 } {
			set prio [lindex $opt(trfprio) $i ]
		}

      # get the source/destination nodes
		set src [lindex $opt(trfsrc) $i]
		set dst [lindex $opt(trfdst) $i]

		# print some debug info about this flow
		if { $opt(debug) != "" } {
			puts "** creating flow $i ($src -> $dst) with priority $prio"
			puts "   traffic = $traffic, number of sources = $nsources"
		}

      for { set j 0 } { $j < $nsources } { incr j } {

			# create the application
         if { $traffic == "cbr" } {
				create_cbr $src $dst $prio $i $start "never"

         } elseif { $traffic == "bwa" } {
				create_bwa $src $dst $prio $i $start "never"

         } elseif { $traffic == "voip" } {
				create_voip $src $dst $prio $i $start "never"

         } elseif { $traffic == "ftp" } {
				create_ftp $src $dst $prio $i $start "never"

         } elseif { $traffic == "vod" } {
				create_vod $src $dst $prio $i $start "never"

			} elseif { $traffic == "udptunnel" } {
				create_udptunnel $src $dst $prio $i $start "never"

         } else {
            puts "traffic '$traffic' not available"
            exit 0
         }
      }
   }
}

################################################################################
# MAIN BODY
################################################################################

getopt $argc $argv

init
create_topology
create_nodes

if { $opt(net-entry) == "scan" } {
	$ns at $opt(net-entry-start) "[$node($opt(net-entry-node)) getMac 0] scan"
} elseif { $opt(net-entry) == "sponsor" } {
	$ns at $opt(net-entry-start) \
	"[$node($opt(net-entry-node)) getMac 0] open-sponsor $opt(net-entry-sponsor)"
} elseif { $opt(net-entry) == "tunnel" } {
	set src $opt(net-entry-node)
	set dst $opt(net-entry-bs)
	set start $opt(net-entry-start)

	lappend opt(trfsrc)    "$src"
	lappend opt(trfdst)    "$dst"
	lappend opt(trftype)   "udptunnel"
	lappend opt(trfnsrc)   "1"
	lappend opt(trfstart)  "$start"
	lappend opt(trfprio)   "0"

	set opt(trftype-def)   ""
	set opt(trfstart-def)  ""
	set opt(trfnsrc-def)   ""
	set opt(trfprio-def)   ""
} elseif { $opt(net-entry) == "link-est" } {
	$ns at $opt(net-entry-start) \
	"[$node($opt(net-entry-node)) getMac 0] link-establishment"
} 

create_connections
create_profiles
create_metrics
if { $opt(debug) != "" } {
	printopt
}
alive


$ns run
