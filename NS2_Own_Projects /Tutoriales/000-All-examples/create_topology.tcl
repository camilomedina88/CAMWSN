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
# $Id: create_topology.tcl,v 1.10 2008/11/07 05:42:21 wanggang Exp $
#
# This code creates the simulation topology with settable 
# parameters. It contains one base class "Create_topology" and  
# three inherited classes, "Dumb_bell", "Paring_lot" and "Network_1".
# The base class mainly includes setting the topology, such as 
# btnk_topology, btnk_traffic_ftp, and telling create_graph what 
# metrics to show in the figures, such as btnk_show_voice. Topologies
# are shown below.
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
#                     Fig 1. A Dumb-bell topology. 
#    
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


Class Create_topology 
Class Create_topology/Dumb_bell -superclass Create_topology
# basic scenario
Class Create_topology/Dumb_bell/Basic -superclass Create_topology/Dumb_bell
Class Create_topology/Parking_lot -superclass Create_topology
Class Create_topology/Network_1 -superclass Create_topology

Create_topology instproc init args {
    # system parameters
    $self instvar traffic_         ;# the traffic instance
    $self instvar graph_           ;# the graph instance
    $self instvar sim_time_	       ;# simulation stop time
    $self instvar if_html_         ;# if use html to show results
    $self instvar html_index_      ;# if use html to show results
    
    # topology parameters
    $self instvar btnk_bw_         ;# bottleneck capacity, Mbps
    $self instvar num_btnk_        ;# number of btnk, for Parking lot
    $self instvar rttp_            ;# round trip propagation delay, ms
    $self instvar verbose_         ;# output format
    $self instvar rtt_diff_        ;# flow rtt difference, ms
    $self instvar delay_diff_      ;# delay differences
    $self instvar btnk_delay_	   ;# bottleneck delay
    $self instvar non_btnk_delay_  ;# non bottleneck delay
    $self instvar non_btnk_bw_     ;# non bottleneck bandwidth
    $self instvar btnk_buf_	       ;# bottleneck buffer
    $self instvar non_btnk_buf_	   ;# non bottleneck buffer
    $self instvar crs_btnk_delay_  ;# cross btnk delay
    $self instvar edge_delay_      ;# edge link delay
    $self instvar edge_bw_         ;# edge link bandwidth
    $self instvar core_delay_      ;# core delay for intermediate link
    $self instvar if_wireless_     ;# wireless enabled
    $self instvar tmix_enabled_    ;# tmix enabled, compatible for former release
    $self instvar btnk_buf_bdp_    ;# buffer size % bdp
    
    eval $self random_start_time   ;# randomize start time      
    eval $self next $args
    set if_html_ 0
    set if_wireless_ 0
    set edge_delay_ [list]
    set edge_bw_ [list]
    set tmix_enabled_ 0
    set btnk_buf_bdp_ 1.0
}

# Randomize flow start time
Create_topology instproc random_start_time {} {
    $self instvar start_time_RNG_
    $self instvar start_time_rnd_
    $self instvar neglect_time_
    set start_time_RNG_ [new RNG]
    $start_time_RNG_ next-substream
    set start_time_rnd_ [new RandomVariable/Uniform]
    $start_time_rnd_ set min_ 1    ;# ms
    $start_time_rnd_ set max_ 300  ;# [expr 2 * $rttp + $num_ftp_flow * $rtt_diff]
}

# Config procedures
Create_topology instproc btnk_bw {val} {
    $self set btnk_bw_ $val
}

Create_topology instproc num_btnk {val} {
    $self set num_btnk_ $val
}

Create_topology instproc rttp {val} {
    $self set rttp_ $val
}

Create_topology instproc crs_btnk_delay {val} {
    $self set crs_btnk_delay_ $val
}
Create_topology instproc verbose {val} {
    $self set verbose_ $val
}

Create_topology instproc rtt_diff {val} {
    $self set rtt_diff_ $val
}

Create_topology instproc traffic {val} {
    $self set traffic_  $val
}

Create_topology instproc graph {val} {
    $self set graph_  $val
}

Create_topology instproc sim_time {val} {
    $self set sim_time_  $val
}

# basic scenario
Create_topology instproc edge_delay {val} {
    $self instvar edge_delay_
    lappend edge_delay_ $val
}

Create_topology instproc edge_bw {val} {
    $self instvar edge_bw_
    lappend edge_bw_ $val
}

# basic scenario
Create_topology instproc core_delay {val} {
    $self set core_delay_ $val
}

# basic scenario
Create_topology instproc buffer_length {val} {
    $self set buffer_length_ $val
}

# basic scenario
Create_topology instproc if_wireless {val} {
    $self set if_wireless_ $val
}

Create_topology instproc btnk_buf_bdp {val} {
    $self set btnk_buf_bdp_ $val
}



Create_topology instproc html_index {val} {
   $self instvar if_html_ 
   $self set html_index_  $val
    if {$val!= -1} {
	set if_html_ 1
    }
}


# Dispatch args
Create_topology instproc init_var args {
    set shadow_args ""
    $self instvar btnk_bw_
    for {} {$args != ""} {set args [lrange $args 2 end]} {
        set key [lindex $args 0]
        set val [lindex $args 1]
        if {$val != "" && [string match {-[A-z]*} $key]} {
            set cmd [string range $key 1 end]
            foreach arg_item $val {
                $self $cmd $arg_item
              #  if ![catch "$self $cmd $arg_item"] {
		      #      continue
              #  }
            lappend shadow_args $key $arg_item
        }
    }
    }
    return $shadow_args
}

# Config the parameters
Create_topology instproc config args {
    set args [ eval $self init_var $args]
}

# Choose a subset to display
Create_topology instproc show_subset {total} {
    set total_ [expr round($total)] ;# disable cases such as 15.0
    set interval_ 1
    if { $total_ >3 } {
	set interval_ [expr $total_ /3]
    }
    set start_ 0
    set list_ 0
    for { set start_ [expr $start_ + $interval_] } { $start_ < $total_ } { set start_ [expr $start_+$interval_] } {
	set list_ "$list_ $start_"
    }
    return $list_
}

# Bottleneck parameters
Create_topology instproc set_parameters {topo num_btnk} {
    $self instvar rttp_ rtt_diff_ btnk_bw_ traffic_ graph_
    $self instvar delay_diff_ btnk_delay_ non_btnk_delay_ non_btnk_bw_ 
    #$self instvar btnk_buf_ bdp_   non_btnk_buf_ verbose_
    $self instvar btnk_buf_ non_btnk_buf_ verbose_
    $self instvar sim_time_
    $self instvar crs_btnk_delay_
    $self instvar if_html_ html_index_
    $self instvar traffic_
    $self instvar tmix_enabled_
    $self instvar btnk_buf_bdp_
    # Initialize parameters
    set btnk_delay_ [expr $rttp_ * 0.5 * 0.8 / $num_btnk] 
    set delay_diff_ [expr $rtt_diff_ * 1.0 / 4.0]  ;# ms
    set non_btnk_delay_ [expr $rttp_ * 0.5 * 0.2 / 2.0]
    set non_btnk_bw_ [expr $btnk_bw_ * 1.0 * 2]    ;# Mbps
    set num_ftp [$traffic_ set num_ftp_flow_fwd_]
    set num_rev [$traffic_ set num_ftp_flow_rev_]
    set num_cross [$traffic_ set num_ftp_flow_cross_]
    set rate_http [$traffic_ set rate_http_flow_]
    set num_voice [$traffic_ set num_voice_flow_]
    set num_streaming_fwd [$traffic_ set num_streaming_flow_fwd_]
    set num_streaming_rev [$traffic_ set num_streaming_flow_rev_]
    set rate_streaming [$traffic_ set rate_streaming_]
    set packet_streaming [$traffic_ set packetsize_streaming_]
    set min_btnk_buf_ [expr 2 * 1.0 * ($num_ftp + $num_rev)] ;# pkt, at least 2 pkts per flow
    set avg_rtt_ [expr $rttp_ + $rtt_diff_ * 1.0 * ($num_ftp - 1) / 2]
    set btnk_buf_ [expr $btnk_buf_bdp_ * $btnk_bw_ * $avg_rtt_ / 8.0]  ;# in 1KB pkt
    if { $btnk_buf_ < $min_btnk_buf_ } { set btnk_buf_ $min_btnk_buf_ }
    if { $tmix_enabled_ == 1 } {
        $self instvar buffer_length_
        set btnk_buf_ [format "%0.2f" [expr $btnk_buf_bdp_ * $btnk_bw_ * $buffer_length_ / 8.0 / 1.5] ]  ;# in 1.5KB pkt
        set num_tmix [$traffic_ set num_tmix_flow_]
    } else {
        set num_tmix 0
    }
    set non_btnk_buf_ [expr $btnk_buf_]
    global tmp_directory_
    if { ![info exists tmp_directory_] } {
        set tmp_directory_ [create-tmp-directory]
    }
    set scheme [$traffic_ set scheme_]
    # show verbose
    if { $verbose_== 1 } {
	if { $if_html_ == "1" } { 
	    #; print to html
	    set html_file [open "/tmp/index$html_index_.html" "a"]
	    puts $html_file "<p><font size=5 color=0066ff>Scenario Settings</font></p>"
	    puts $html_file "<table border=1>"
	    puts $html_file "<tr>"
	    puts $html_file "<th align=center>Name</th>"
	    puts $html_file "<th align=center>Sim Time</th>"
	    puts $html_file "<th align=center>Output</th>"
	    puts $html_file "<th align=center>Disp. Bottleneck</th>"
	    puts $html_file "<th align=center>Disp. FTP</th>"
	    puts $html_file "<th align=center>Disp. HTTP</th>"
	    puts $html_file "<th align=center>Disp. Voice</th>"
	    puts $html_file "<th align=center>Disp. Streaming</th>"
	    puts $html_file "<th align=center>Disp. Tmix</th>"
	    puts $html_file "</tr>"
	    puts $html_file "<tr>"
	    puts $html_file "<th align=center>Value</th>"
	    puts $html_file "<td align=center>$sim_time_ s</td>"
	    puts $html_file "<td align=center>index$html_index_.html</td>"
	    set show_btnk_stat [$graph_ set show_bottleneck_stats_]
	    set show_ftp       [$graph_ set show_graph_ftp_]
	    set show_http      [$graph_ set show_graph_http_]
	    set show_voice     [$graph_ set show_graph_voice_]
	    set show_streaming [$graph_ set show_graph_streaming_]
	    set show_tmix      [$graph_ set show_graph_tmix_]
	    
	    puts $html_file "<td align=center>$show_btnk_stat</td>"
	    puts $html_file "<td align=center>$show_ftp</td>"
	    puts $html_file "<td align=center>$show_http</td>"
	    puts $html_file "<td align=center>$show_voice</td>"
	    puts $html_file "<td align=center>$show_streaming</td>"
	    puts $html_file "<td align=center>$show_tmix</td>"
	    puts $html_file "</tr>"
	    puts $html_file "</table>"
	    puts $html_file "<br>"
	    puts $html_file "<p><font size=5 color=0066ff>Topology Settings</font></p>"
	    puts $html_file "<table border=1>"
	    puts $html_file "<tr>"
	    puts $html_file "<th align=center>Name</th>"
	    puts $html_file "<th align=center>Topology</th>"
	    puts $html_file "<th align=center>Bottleneck Bandwidth</th>"
        if { $tmix_enabled_ == 0 } {
	        puts $html_file "<th align=center>RTT Propagation</th>"
        }
	    puts $html_file "<th align=center>Bottleneck Buffer</th>"
	    puts $html_file "<th align=center>Packet Error Rate</th>"
	    puts $html_file "<th align=center>RTT Differentiation</th>"
	    puts $html_file "<th align=center>Use AQM</th>"
	    puts $html_file "</tr>"
	    puts $html_file "<tr>"
	    puts $html_file "<th align=center>Value</th>"
	    puts $html_file "<td align=center>$topo</td>"
	    puts $html_file "<td align=center>$btnk_bw_ Mbps</td>"
        if { $tmix_enabled_ == 0 } {
	        puts $html_file "<td align=center>$rttp_ ms</td>"
        }
	    puts $html_file "<td align=center>$btnk_buf_ </td>"
	    set error_rate [$graph_ set error_rate_]
	    puts $html_file "<td align=center>$error_rate</td>"
	    puts $html_file "<td align=center>$rtt_diff_ ms</td>"
	    set useAQM [$traffic_ set useAQM_]
	    puts $html_file "<td align=center>$useAQM </td>"
	    puts $html_file "</tr>"
	    puts $html_file "</table>"
	    puts $html_file "<br>"
	    puts $html_file "<p><font size=5 color=0066ff>Traffic Settings</font></p>"
	    puts $html_file "<table border=1>"
	    puts $html_file "<tr>"
	    puts $html_file "<th align=center rowspan=2>Name</th>"
	    puts $html_file "<th align=center colspan=4>FTP</th>"
	    puts $html_file "<th align=center colspan=1>HTTP</th>"
	    puts $html_file "<th align=center colspan=1>Voice</th>"
	    puts $html_file "<th align=center colspan=4>Streaming</th>"
	    puts $html_file "<th align=center colspan=1>Tmix</th>"
	    puts $html_file "</tr>"
	    puts $html_file "<tr>"
	    puts $html_file "<td align=center>Num.FWD</td>"
	    puts $html_file "<td align=center>Num.REV</td>"
	    puts $html_file "<td align=center>Num.Cross</td>"
	    puts $html_file "<td align=center>TCP</td>"
	    puts $html_file ""
	    puts $html_file "<td align=center>Rate</td>"
	    puts $html_file "<td align=center>Num.</td>"
	    puts $html_file "<td align=center>Num.FWD</td>"
	    puts $html_file "<td align=center>Num.REV</td>"
	    puts $html_file "<td align=center>Rate.REV</td>"
	    puts $html_file "<td align=center>Packet Size</td>"
	    puts $html_file "<td align=center>Num.</td>"
	    puts $html_file "</tr>"
	    puts $html_file "<tr>"
	    puts $html_file "<th align=center>Value</th>"
	    puts $html_file "<td align=center>$num_ftp</td>"
	    puts $html_file "<td align=center>$num_rev</td>"
	    puts $html_file "<td align=center>$num_cross</td>"
	    puts $html_file "<td align=center>$scheme</td>"
	    puts $html_file "<td align=center>$rate_http /s</td>"
	    puts $html_file "<td align=center>$num_voice</td>"
	    puts $html_file "<td align=center>$num_streaming_fwd</td>"
	    puts $html_file "<td align=center>$num_streaming_rev</td>"
	    puts $html_file "<td align=center>$rate_streaming</td>"
	    puts $html_file "<td align=center>$packet_streaming B</td>"
	    puts $html_file "<td align=center>$num_tmix</td>"
	    puts $html_file "</tr>"
	    puts $html_file "</table>"
	    puts $html_file "<br>"
	    puts $html_file "The simulation DATA results will be stored in $tmp_directory_/data<br>"
	    puts $html_file "The simulation GRAPH results will be stored in $tmp_directory_/figure<br>"
	    puts $html_file "</body>"
	    puts $html_file "</html>"
	    close $html_file
	} else {
	    # print to screen
	    puts "+++++++++++++++++++++++++++++++"
	    puts "fixed parameter settings:"
	    puts "+++++++++++++++++++++++++++++++"
	    puts "  TCP:                   $scheme"
	    puts "  btnk num:              $num_btnk"
	    puts "  btnk bw:               $btnk_bw_ Mbps"
	    puts "  btnk buf:              $btnk_buf_ KB"
	    puts "  rtt:                   $rttp_ ms"
	    puts "  rtt diff:              $rtt_diff_ ms"
	    puts "  ftp num (fwd):         $num_ftp"
	    puts "  ftp num (rev):         $num_rev"
	    puts "  http rate    :         $rate_http /s"
	    puts "  voice num      :       $num_voice"
	    puts "  streaming flow (fwd):  $num_streaming_fwd"
	    puts "  streaming flow (rev):  $num_streaming_rev"
	    puts "  tmix flow:             $num_tmix"
	    puts "  simulation time:       $sim_time_ s"
	    puts "+++++++++++++++++++++++++++++++"
	    puts ""
	    puts "The simulation DATA results will be stored in $tmp_directory_/data"
	    puts "The simulation GRAPH results will be stored in $tmp_directory_/figure"
	    puts "Simulation starts..."
	}
    } else {
        # put in simple text in order to mass data extraction.
	if { $tmix_enabled_ == 1 } {
        puts -nonewline [format "%s %2d %6.3f %4d " $scheme $num_btnk $btnk_bw_ $num_tmix]
     } else {
	    puts -nonewline [format "%s %2d %6.3f %6.1f %4d %4d %4d %4d %4d %4d " $scheme $num_btnk $btnk_bw_ $rttp_ $num_ftp $num_rev $rate_http $num_voice $num_streaming_fwd $num_streaming_rev]
     }
            
    }
}

# Choose approate TCP src, TCP sink and Queue.
# Currently, it inlucdes 10 TCP variants: 
# Reno, SACK, HSTCP, STCP, HTCP, BIC, CUBIC, FAST, XCP, and VCP.
Create_topology instproc get_tcp_params { scheme } {
    $self instvar SRC SINK QUEUE OTHERQUEUE
    $self instvar queue_core_ queue_transit_ queue_stub_ 
    $self instvar btnk_buf_ traffic_
    
    set useAQM [$traffic_ set useAQM_]
    set QUEUE DropTail
    set OTHERQUEUE DropTail
    set queue_core_ DropTail
    set queue_transit_ DropTail
    set queue_stub_ DropTail
    
    if { $scheme == "Reno" } {
        set SRC   TCP/Reno
        set SINK  TCPSink
        if { $useAQM == "1" } {
            set QUEUE RED
            set queue_core_ RED
            set queue_transit_ RED
	        Agent/TCP set ecn_ 1 ;
        } 
    }
    
    if { $scheme == "SACK" } {
	    set SRC   TCP/Sack1
	    set SINK  TCPSink/Sack1
        if { $useAQM == "1" } {
            set QUEUE RED
            set queue_core_ RED
            set queue_transit_ RED
	        Agent/TCP set ecn_ 1 ;
        } 
    }
    
    if { $scheme == "HSTCP" } {
	    Agent/TCP set windowOption_ 8
	    Agent/TCP set hstcp_fix_ 1
	    set SRC   TCP/Sack1
	    set SINK  TCPSink/Sack1
        if { $useAQM == "1" } {
            set QUEUE RED
            set queue_core_ RED
            set queue_transit_ RED
	        Agent/TCP set ecn_ 1 ;
        } 
    }
    
    if { $scheme == "STCP" } {
	    Agent/TCP set windowOption_ 9
	    set SRC   TCP/Sack1
	    set SINK  TCPSink/Sack1
        if { $useAQM == "1" } {
            set QUEUE RED
            set queue_core_ RED
            set queue_transit_ RED
	        Agent/TCP set ecn_ 1 ;
        } 
    }
    
    if { $scheme == "HTCP" } {
	    Agent/TCP set windowOption_ 10
	    set SRC   TCP/Sack1
	    set SINK  TCPSink/Sack1
        if { $useAQM == "1" } {
            set QUEUE RED
            set queue_core_ RED
            set queue_transit_ RED
	        Agent/TCP set ecn_ 1 ;
        } 
    }
    
    if { $scheme == "BIC" } {
	    Agent/TCP set windowOption_ 12
	    Agent/TCP set hstcp_fix_ 1
        set SRC   TCP/Sack1
	    set SINK  TCPSink/Sack1
        if { $useAQM == "1" } {
            set QUEUE RED
            set queue_core_ RED
            set queue_transit_ RED
        } 
    }
    
    if { $scheme == "CUBIC" } {
	    Agent/TCP set windowOption_ 13
        set SRC   TCP/Sack1
	    set SINK  TCPSink/Sack1
        if { $useAQM == "1" } {
            set QUEUE RED
            set queue_core_ RED
            set queue_transit_ RED
        } 
    }

    if { $scheme == "FAST" } {
        set SRC   TCP/Fast
	    set SINK  TCPSink/Sack1
        if { $useAQM == "1" } {
            set QUEUE REM
            set queue_core_ REM
            set queue_transit_ REM
	        Agent/TCP set ecn_ 1 ;
        } 
    }
    
   if { $scheme == "XCP" } {
       set SRC   TCP/Reno/XCP
       set SINK  TCPSink/XCPSink
       set QUEUE XCP
       set OTHERQUEUE XCP
       set queue_core_ XCP
       set queue_transit_ XCP
       set queue_stub_ XCP
       #Agent/TCP set minrto_ 1 ;# frin XCP sample script
   }
    
    if { $scheme == "VCP" } {
        set SRC   TCP/Reno/VcpSrc
        set SINK  VcpSink
        set QUEUE DropTail2/VcpQueue
        set queue_core_ DropTail2/VcpQueue
        set queue_transit_ DropTail2/VcpQueue
    }
    
# FullTCP initialization. Tmix use it.
# Reno
    if { $scheme == "FULLTCP" } {
        Agent/TCP/FullTcp set segsize_ 1460;           # set MSS to 1460 bytes
        Agent/TCP/FullTcp set nodelay_ true;           # disabling nagle
        Agent/TCP/FullTcp set segsperack_ 2;           # delayed ACKs
        Agent/TCP/FullTcp set interval_ 0.1;           # 100 ms
        #Agent/TCP/FullTcp set ssthresh_ 64;           # slow start threshold ms
        if { $useAQM == "1" } {
            set QUEUE RED
            set queue_core_ RED
            set queue_transit_ RED
    	    Agent/TCP set ecn_ 1 ;
        } 
}   
}

# Set RED parameters, if not called, use default in ns-default.tcl.
Create_topology instproc set_red_params { qsize } {
     Queue/RED set thresh_ [expr 0.6 * $qsize]
     Queue/RED set maxthresh_ [expr 0.8 * $qsize]
     Queue/RED set q_weight_ 0.001
     Queue/RED set linterm_ 10
     Queue/RED set bytes_ false ;
     Queue/RED set queue_in_bytes_ false ;
     Queue/RED set old_ecn_ true ;
     Queue/RED set setbit_ true
     Queue/RED set gentle_ true
     Queue/RED set adaptive_ true
     Queue/RED set bottom_ 0.001
    
     Queue/RED set thresh_ 0
     Queue/RED set maxthresh_ 0
     Queue/RED set qweight_ 0
     Queue/RED set drop_tail_ 0
     Queue/RED set setbit_ 1
     Queue/RED set targetdelay_ 0.005 
     Queue/RED set queue_in_bytes_ false ;
     Queue/RED set bytes_ false ;
}

# Create btnk like topologies, such as Dumb-Bell and Parking-Lot.
Create_topology instproc btnk_topology {} {
    $self instvar btnk_             ;# bottleneck nodes
    $self instvar btnk_bw_ num_btnk_ btnk_buf_ btnk_delay_ ; # bottleneck parameters
    $self instvar graph_ traffic_ 
    $self instvar SRC SINK QUEUE OTHERQUEUE
    set scheme [$traffic_ set scheme_] 
    $self get_tcp_params $scheme
    if { $QUEUE == "RED"} {
        $self set_red_params $btnk_buf_
    }
    
    # bottleneck links
    set ns [Simulator instance]
    for { set i 0 } { $i <= $num_btnk_ } { incr i } {
        set btnk_($i) [$ns node]
    }
    for { set i 0 } { $i < $num_btnk_ } { incr i } {
        $ns duplex-link $btnk_($i) $btnk_([expr $i+1]) [expr $btnk_bw_]Mb  [expr $btnk_delay_]ms $QUEUE
                if { $QUEUE == "XCP" } {
                    $ns queue-limit $btnk_($i) $btnk_([expr $i+1]) [expr $btnk_buf_]
                    $ns queue-limit $btnk_([expr $i+1]) $btnk_($i) [expr $btnk_buf_]
                    # since XCP has 3 seperate queues, so the queue size may changed accordingly.
                    # $ns queue-limit $btnk_($i) $btnk_([expr $i+1]) [expr $btnk_buf_/3]
                    # $ns queue-limit $btnk_([expr $i+1]) $btnk_($i) [expr $btnk_buf_/3]
                } else {
                    $ns queue-limit $btnk_($i) $btnk_([expr $i+1]) [expr $btnk_buf_]
                    $ns queue-limit $btnk_([expr $i+1]) $btnk_($i) [expr $btnk_buf_]
                }
        
	if { $QUEUE == "XCP" || $QUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $btnk_($i) $btnk_([expr $i+1])]
	    set rlink [$ns link $btnk_([expr $i+1])  $btnk_($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
        }
    }

    # Add static error in the path
    if { [$graph_ set show_graph_response_function_]==1 } {
	for { set i 0 } { $i < $num_btnk_ } { incr i } {
            set em($i) [new ErrorModel]
            $em($i) unit pkt
            $em($i) set rate_ [$graph_ set error_rate_]
            $em($i) ranvar [new RandomVariable/Uniform]
            $em($i) drop-target [new Agent/Null]
            $ns lossmodel $em($i) $btnk_($i) $btnk_([expr $i+1]) 
            set rem($i) [new ErrorModel]
            $rem($i) unit pkt
            $rem($i) set rate_ [$graph_ set error_rate_]
            $rem($i) ranvar [new RandomVariable/Uniform]
            $rem($i) drop-target [new Agent/Null]
            $ns lossmodel $rem($i) $btnk_([expr $i+1]) $btnk_($i)
        }
    }
}

# add static error in the path
Create_topology instproc btnk_add_error {} {
    $self instvar graph_ btnk_ num_btnk_
    set ns [Simulator instance]
    for { set i 0 } { $i < $num_btnk_ } { incr i } {
        set em($i) [new ErrorModel]
        $em($i) unit pkt
        $em($i) set rate_ [$graph_ set error_rate_]
        $em($i) ranvar [new RandomVariable/Uniform]
        $em($i) drop-target [new Agent/Null]
        $ns lossmodel $em($i) $btnk_($i) $btnk_([expr $i+1]) 
        set rem($i) [new ErrorModel]
        $rem($i) unit pkt
        $rem($i) set rate_ [$graph_ set error_rate_]
        $rem($i) ranvar [new RandomVariable/Uniform]
        $rem($i) drop-target [new Agent/Null]
        $ns lossmodel $rem($i) $btnk_([expr $i+1]) $btnk_($i)
    }
}

# tmix support implementation -common.
Create_topology instproc btnk_traffic_tmix {} {
    $self instvar btnk_ num_btnk_ btnk_bw_ btnk_buf_ QUEUE OTHERQUEUE
    $self instvar traffic_ sim_time_ graph_ 
    $self instvar edge_delay_ edge_bw_ core_delay_ buffer_length_ tmix_s tmix_d tracefd_;# basic 

    set ns [Simulator instance]
    set scheme [$traffic_ set scheme_] 
    $self get_tcp_params $scheme
    if { $QUEUE == "RED"} {
        $self set_red_params $btnk_buf_
    }
    
    # write data trace. It is not a good way since it generates large size file.
    global tmp_directory_
    if { ![info exists tmp_directory_] } {
        set tmp_directory_ [create-tmp-directory]
    }    
    set tracefd_ [open $tmp_directory_/data/tmix.tr w]
    set num_tmix_flow [$traffic_ set num_tmix_flow_]
    $ns trace-all $tracefd_

    # bottleneck links
    for { set i 0 } { $i <= $num_btnk_ } { incr i } {
        set btnk_($i) [$ns node]
    }
    for { set i 0 } { $i < $num_btnk_ } { incr i } {
        $ns duplex-link $btnk_($i) $btnk_([expr $i+1]) [expr $btnk_bw_]Mb  [expr $core_delay_]ms $QUEUE
        $ns queue-limit $btnk_($i) $btnk_([expr $i+1]) [expr $btnk_buf_]
        $ns queue-limit $btnk_([expr $i+1]) $btnk_($i) [expr $btnk_buf_]
    }


    # non bottleneck inbound links
    for { set i 0 } { $i < $num_tmix_flow } { incr i } {
	  set tmix_s($i) [$ns node]
    }
    for { set i 0 } { $i < $num_tmix_flow } { incr i } {
	  set tmix_d($i) [$ns node]
    }
    
    set cv_name [$traffic_ set tmix_cv_name_]
    set tmix_tcp_scheme [$traffic_ set tmix_tcp_scheme_]
    if {$num_btnk_==1} {
        for { set i 0 } { $i < $num_tmix_flow } { incr i } {
	        set j [expr $i * 2]
            $ns simplex-link $tmix_s($i) $btnk_(0) [lindex $edge_bw_ $j]Mb [lindex $edge_delay_ $j]ms $OTHERQUEUE
	        $ns simplex-link $btnk_(0) $tmix_s($i) [lindex $edge_bw_ [expr $j+1] ]Mb [lindex $edge_delay_ [expr $j+1] ]ms $OTHERQUEUE
	        $ns queue-limit $tmix_s($i) $btnk_(0) [expr [lindex $edge_bw_ $j] * $buffer_length_ /8.0]
            $ns queue-limit $btnk_(0) $tmix_s($i) [expr [lindex $edge_bw_ [expr $j+1] ] * $buffer_length_ /8.0] 
	
	        set j [expr ($i + $num_tmix_flow) * 2]
	        $ns simplex-link $tmix_d($i) $btnk_(1) [lindex $edge_bw_ $j]Mb [lindex $edge_delay_ $j]ms $OTHERQUEUE
	        $ns simplex-link $btnk_(1) $tmix_d($i) [lindex $edge_bw_ [expr $j+1] ]Mb [lindex $edge_delay_ [expr $j+1] ]ms $OTHERQUEUE
	        $ns queue-limit $tmix_d($i) $btnk_(1) [expr [lindex $edge_bw_ $j] * $buffer_length_ /8.0]
	        $ns queue-limit $btnk_(1) $tmix_d($i) [expr [lindex $edge_bw_ [expr $j+1]] * $buffer_length_ /8.0]
	
	        # tmix traffic setup
	        set INBOUND($i) [lindex $cv_name $i]
	        set tmix($i) [new Tmix]
	        $tmix($i) set-init $tmix_s($i);                 # tmix_s as initiator
	        $tmix($i) set-acc $tmix_d($i);                  # tmix_d as acceptor
	        $tmix($i) set-ID [expr $i+7]
	        $tmix($i) set-cvfile "$INBOUND($i)"
	        $tmix($i) set-TCP [lindex $tmix_tcp_scheme $i]
	        $ns at 0.0 "$tmix($i) start"
	        $ns at $sim_time_ "$tmix($i) stop"
        }
    } else {
        # multiple bottleneck
            set i 0
	        set j [expr $i * 2]
            $ns simplex-link $tmix_s($i) $btnk_($i) [lindex $edge_bw_ $j]Mb [lindex $edge_delay_ $j]ms $OTHERQUEUE
	        $ns simplex-link $btnk_($i) $tmix_s($i) [lindex $edge_bw_ [expr $j+1] ]Mb [lindex $edge_delay_ [expr $j+1] ]ms $OTHERQUEUE
	        $ns queue-limit $tmix_s($i) $btnk_($i) [expr [lindex $edge_bw_ $j] * $buffer_length_ /8.0]
            $ns queue-limit $btnk_($i) $tmix_s($i) [expr [lindex $edge_bw_ [expr $j+1] ] * $buffer_length_ /8.0] 
	
	        set j [expr ($i + $num_tmix_flow) * 2]
	        $ns simplex-link $tmix_d($i) $btnk_($num_btnk_) [lindex $edge_bw_ $j]Mb [lindex $edge_delay_ $j]ms $OTHERQUEUE
	        $ns simplex-link $btnk_($num_btnk_) $tmix_d($i) [lindex $edge_bw_ [expr $j+1] ]Mb [lindex $edge_delay_ [expr $j+1] ]ms $OTHERQUEUE
	        $ns queue-limit $tmix_d($i) $btnk_($num_btnk_) [expr [lindex $edge_bw_ $j] * $buffer_length_ /8.0]
	        $ns queue-limit $btnk_($num_btnk_) $tmix_d($i) [expr [lindex $edge_bw_ [expr $j+1]] * $buffer_length_ /8.0]
	
	        # tmix traffic setup
	        set INBOUND($i) [lindex $cv_name $i]
	        set tmix($i) [new Tmix]
	        $tmix($i) set-init $tmix_s($i);                 # tmix_s as initiator
	        $tmix($i) set-acc $tmix_d($i);                  # tmix_d as acceptor
	        $tmix($i) set-ID [expr $i+7]
	        $tmix($i) set-cvfile "$INBOUND($i)"
	        $tmix($i) set-TCP [lindex $tmix_tcp_scheme $i]
	        $ns at 0.0 "$tmix($i) start"
        
        for { set btnk_i 0 } { $btnk_i < $num_btnk_ } { incr btnk_i } {
            set i [expr $btnk_i + 1]
	        set j [expr $i * 2]
            $ns simplex-link $tmix_s($i) $btnk_($btnk_i) [lindex $edge_bw_ $j]Mb [lindex $edge_delay_ $j]ms $OTHERQUEUE
	        $ns simplex-link $btnk_($btnk_i) $tmix_s($i) [lindex $edge_bw_ [expr $j+1] ]Mb [lindex $edge_delay_ [expr $j+1] ]ms $OTHERQUEUE
	        $ns queue-limit $tmix_s($i) $btnk_($btnk_i) [expr [lindex $edge_bw_ $j] * $buffer_length_ /8.0]
            $ns queue-limit $btnk_($btnk_i) $tmix_s($i) [expr [lindex $edge_bw_ [expr $j+1] ] * $buffer_length_ /8.0] 
	
	        set j [expr ($i + $num_tmix_flow) * 2]
	        $ns simplex-link $tmix_d($i) $btnk_($i) [lindex $edge_bw_ $j]Mb [lindex $edge_delay_ $j]ms $OTHERQUEUE
	        $ns simplex-link $btnk_($i) $tmix_d($i) [lindex $edge_bw_ [expr $j+1] ]Mb [lindex $edge_delay_ [expr $j+1] ]ms $OTHERQUEUE
	        $ns queue-limit $tmix_d($i) $btnk_($i) [expr [lindex $edge_bw_ $j] * $buffer_length_ /8.0]
	        $ns queue-limit $btnk_($i) $tmix_d($i) [expr [lindex $edge_bw_ [expr $j+1]] * $buffer_length_ /8.0]
	
	        # tmix traffic setup
	        set INBOUND($i) [lindex $cv_name $i]
	        set tmix($i) [new Tmix]
	        $tmix($i) set-init $tmix_s($i);                 # tmix_s as initiator
	        $tmix($i) set-acc $tmix_d($i);                  # tmix_d as acceptor
	        $tmix($i) set-ID [expr $i+7]
	        $tmix($i) set-cvfile "$INBOUND($i)"
	        $tmix($i) set-TCP [lindex $tmix_tcp_scheme $i]
	        $ns at 0.0 "$tmix($i) start"
        
    }
}
    # add static error in the path
    if { [$graph_ set show_graph_response_function_]==1 } {
        eval $self btnk_add_error
    }
}

# Tmix support implementation section D in the paper -wg.
Create_topology instproc btnk_traffic_tmix_secD {} {
    $self instvar btnk_ num_btnk_ btnk_bw_ btnk_buf_ QUEUE OTHERQUEUE
    $self instvar traffic_ sim_time_ graph_ 
    $self instvar edge_delay_ edge_bw_ core_delay_ buffer_length_ tmix_s tmix_d tracefd_;# basic 
    $self instvar tcp_ cbr_

    set ns [Simulator instance]
    set scheme [$traffic_ set scheme_] 
    $self get_tcp_params $scheme
    
    global tmp_directory_
    if { ![info exists tmp_directory_] } {
        set tmp_directory_ [create-tmp-directory]
    }    
    set tracefd_ [open $tmp_directory_/data/tmix.tr w]
    set num_tmix_flow [$traffic_ set num_tmix_flow_]

    $ns trace-all $tracefd_
    if { $QUEUE == "RED"} {
        $self set_red_params $btnk_buf_
    }

    # bottleneck links
    for { set i 0 } { $i <= $num_btnk_ } { incr i } {
        set btnk_($i) [$ns node]
    }
    for { set i 0 } { $i < $num_btnk_ } { incr i } {
        $ns duplex-link $btnk_($i) $btnk_([expr $i+1]) [expr $btnk_bw_]Mb  [expr $core_delay_]ms $QUEUE
        $ns queue-limit $btnk_($i) $btnk_([expr $i+1]) [expr $btnk_buf_]
        $ns queue-limit $btnk_([expr $i+1]) $btnk_($i) [expr $btnk_buf_]
    }

    # non bottleneck inbound links
    for { set i 0 } { $i < $num_tmix_flow } { incr i } {
	    set tmix_s($i) [$ns node]
    }
    for { set i 0 } { $i < $num_tmix_flow } { incr i } {
	    set tmix_d($i) [$ns node]
    }
    
    for { set i 0 } { $i < $num_tmix_flow } { incr i } {
	  set j [expr $i * 2]
	  $ns simplex-link $tmix_s($i) $btnk_(0) [lindex $edge_bw_ $j]Mb [lindex $edge_delay_ $j]ms $OTHERQUEUE
	  $ns simplex-link $btnk_(0) $tmix_s($i) [lindex $edge_bw_ [expr $j+1] ]Mb [lindex $edge_delay_ [expr $j+1] ]ms $OTHERQUEUE
	  $ns queue-limit $tmix_s($i) $btnk_(0) [expr [lindex $edge_bw_ $j] * $buffer_length_ /8.0]
      $ns queue-limit $btnk_(0) $tmix_s($i) [expr [lindex $edge_bw_ [expr $j+1] ] * $buffer_length_ /8.0] 
	
	  set j [expr ($i + $num_tmix_flow) * 2]
	  $ns simplex-link $tmix_d($i) $btnk_(1) [lindex $edge_bw_ $j]Mb [lindex $edge_delay_ $j]ms $OTHERQUEUE
	  $ns simplex-link $btnk_(1) $tmix_d($i) [lindex $edge_bw_ [expr $j+1] ]Mb [lindex $edge_delay_ [expr $j+1] ]ms $OTHERQUEUE
	  $ns queue-limit $tmix_d($i) $btnk_(1) [expr [lindex $edge_bw_ $j] * $buffer_length_ /8.0]
	  $ns queue-limit $btnk_(1) $tmix_d($i) [expr [lindex $edge_bw_ [expr $j+1]] * $buffer_length_ /8.0]
	
      # tmix traffic setup
      # because tmix has no cwnd stats available, 
      # we use standard FTP+FullTCP instead. When 
      # the code is ready, it will be replaced here.
      set tcp_($i) [new Agent/TCP/FullTcp]
      $tcp_($i) set class_ 2
      set sink_($i) [new Agent/TCP/FullTcp]
      $ns attach-agent $tmix_s($i) $tcp_($i)
      $ns attach-agent $tmix_d($i) $sink_($i)
      $sink_($i) listen
      $ns connect $tcp_($i) $sink_($i)
      set ftp($i) [new Application/FTP]
      $ftp($i) attach-agent $tcp_($i)
      set ftp1($i) [new Application/FTP]
      $ftp1($i) attach-agent $sink_($i)
	  $ns at 0.0 "$ftp($i) start"
	  $ns at 0.0 "$ftp1($i) start"
	  $ns at $sim_time_ "$ftp($i) stop"
	  $ns at $sim_time_ "$ftp1($i) stop"
    }
    
	  set udp_s(0) [$ns node]
	  set udp_d(0) [$ns node]
	  set i 0
      set j [expr $i * 2]
      $ns simplex-link $udp_s($i) $btnk_(0) [lindex $edge_bw_ $j]Mb [lindex $edge_delay_ $j]ms $OTHERQUEUE
      $ns simplex-link $btnk_(0) $udp_s($i) [lindex $edge_bw_ [expr $j+1] ]Mb [lindex $edge_delay_ [expr $j+1] ]ms $OTHERQUEUE
      $ns queue-limit $udp_s($i) $btnk_(0) [expr [lindex $edge_bw_ $j] * $buffer_length_ /8.0]
      $ns queue-limit $btnk_(0) $udp_s($i) [expr [lindex $edge_bw_ [expr $j+1] ] * $buffer_length_ /8.0] 
	
      set j [expr ($i + $num_tmix_flow) * 2]
      $ns simplex-link $udp_d($i) $btnk_(1) [lindex $edge_bw_ $j]Mb [lindex $edge_delay_ $j]ms $OTHERQUEUE
      $ns simplex-link $btnk_(1) $udp_d($i) [lindex $edge_bw_ [expr $j+1] ]Mb [lindex $edge_delay_ [expr $j+1] ]ms $OTHERQUEUE
      $ns queue-limit $udp_d($i) $btnk_(1) [expr [lindex $edge_bw_ $j] * $buffer_length_ /8.0]
      $ns queue-limit $btnk_(1) $udp_d($i) [expr [lindex $edge_bw_ [expr $j+1]] * $buffer_length_ /8.0]
	
	  # UDP traffic setup
      set udp_($i) [new Agent/UDP]
      set sink_($i) [new Agent/Null]
      $ns attach-agent $udp_s($i) $udp_($i)
      $ns attach-agent $udp_d($i) $sink_($i)
      $ns connect $udp_($i) $sink_($i)
      set cbr_($i) [new Application/Traffic/CBR]
      $cbr_($i) attach-agent $udp_($i)

      if {[$traffic_ set cross_case_]==1} {
          $cbr_($i) set rate_ 75000000  
      }
      if {[$traffic_ set cross_case_]==2} {
          $cbr_($i) set rate_ 0.05  
      }
      if {[$traffic_ set cross_case_]==3} {
          $cbr_($i) set rate_ 2500000  
      }
      $ns at 0.0 "$cbr_($i) start"
      $ns at $sim_time_ "$cbr_($i) stop"
    # add static error in the path
    if { [$graph_ set show_graph_response_function_]==1 } {
        eval $self btnk_add_error
    }
}
# Create ftp traffic                                                                                            
Create_topology instproc btnk_traffic_ftp {} {
    $self instvar btnk_ num_btnk_
    $self instvar non_btnk_bw_ non_btnk_buf_ non_btnk_delay_ delay_diff_ ; # non bottleneck parameters
    $self instvar traffic_ sim_time_ start_time_rnd_ neglect_time_
    $self instvar tcp_ rtcp_ ;# for statistics use 
    $self instvar start_time_ftp_fwd_ stop_time_ftp_fwd_ start_time_ftp_rev_ stop_time_ftp_rev_
    $self instvar crs_btnk_delay_ ctcp_
    $self instvar SRC SINK QUEUE OTHERQUEUE
    $self instvar graph_
    
    set ns [Simulator instance]
    set scheme [$traffic_ set scheme_]
    $self get_tcp_params $scheme
    
    # non bottleneck ftp links
    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_fwd_] } { incr i } {
	set ftp_s($i) [$ns node]
	set ftp_d($i) [$ns node]
	
	$ns duplex-link $ftp_s($i) $btnk_(0) [expr $non_btnk_bw_]Mb [expr $non_btnk_delay_ + $i*$delay_diff_]ms $OTHERQUEUE
	$ns queue-limit $ftp_s($i) $btnk_(0) [expr $non_btnk_buf_]
	$ns queue-limit $btnk_(0)  $ftp_s($i) [expr $non_btnk_buf_]
	if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $ftp_s($i) $btnk_(0)]
	    set rlink [$ns link $btnk_(0) $ftp_s($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
	
	$ns duplex-link $ftp_d($i) $btnk_($num_btnk_) [expr $non_btnk_bw_]Mb [expr $non_btnk_delay_ + $i*$delay_diff_]ms $OTHERQUEUE
	$ns queue-limit $ftp_d($i) $btnk_($num_btnk_) [expr $non_btnk_buf_]
	$ns queue-limit $btnk_($num_btnk_)  $ftp_d($i) [expr $non_btnk_buf_]
	if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $ftp_d($i) $btnk_($num_btnk_)]
	    set rlink [$ns link $btnk_($num_btnk_) $ftp_d($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	    }
	}
    
    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_rev_] } { incr i } {
	set rftp_s($i) [$ns node]
	set rftp_d($i) [$ns node]
	
	$ns duplex-link $rftp_d($i) $btnk_(0) [expr $non_btnk_bw_]Mb [expr $non_btnk_delay_ + $i*$delay_diff_]ms $OTHERQUEUE
	$ns queue-limit $rftp_d($i) $btnk_(0) [expr $non_btnk_buf_]
	$ns queue-limit $btnk_(0)  $rftp_d($i) [expr $non_btnk_buf_]
	if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $rftp_d($i) $btnk_(0)]
	    set rlink [$ns link $btnk_(0) $rftp_d($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
	
	$ns duplex-link $rftp_s($i) $btnk_($num_btnk_) [expr $non_btnk_bw_]Mb [expr $non_btnk_delay_ + $i*$delay_diff_]ms $OTHERQUEUE
	$ns queue-limit $rftp_s($i) $btnk_($num_btnk_) [expr $non_btnk_buf_]
	$ns queue-limit $btnk_($num_btnk_)  $rftp_s($i) [expr $non_btnk_buf_]
	if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $rftp_s($i) $btnk_($num_btnk_)]
	    set rlink [$ns link $btnk_($num_btnk_) $rftp_s($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
    	    }
       }
   
    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_fwd_] } { incr i } {
        if { [catch { set tcp_($i) [$ns create-connection $SRC $ftp_s($i) $SINK $ftp_d($i) $i] } ] !=0 } {
	    puts "-- Create-connection forward failed. Please check btnk_traffic_ftp {} in create_topology.tcl --" 
	    puts "-- Possible reasons: there is no such TCP installed in ns2 --" 
	    exit
	} else {  
	    set ftp($i) [$tcp_($i) attach-source FTP]
	    set stop_time_ftp_fwd_($i) $sim_time_
	    
	    # show fwd convergence time, flows start every 200s, can changed with other desired value.
	    if { [ $graph_ set show_convergence_time_] == 1 } {
		set start_time_ftp_fwd_($i) [expr $i * 200 ]
	    } else {
		# random start time
	        set start_time_ftp_fwd_($i) [expr [$start_time_rnd_ value] / 1000.0]
	        $ns at [expr $start_time_ftp_fwd_($i) + $neglect_time_] "$tcp_($i) init-stats"
	    }
	    $ns at $start_time_ftp_fwd_($i) "$ftp($i) start"
	    $ns at $stop_time_ftp_fwd_($i) "$ftp($i) stop"
	    $tcp_($i) init-stats 
	}
    }
    
    # Setup reverse path connections and FTP sources
    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_rev_] } { incr i } {
        if { [catch { set rtcp_($i) [$ns create-connection $SRC $rftp_s($i) $SINK $rftp_d($i) [expr 40000+$i] ] } ] !=0 } {
	    puts "-- Create-connection reverse failed. Please check btnk_traffic_ftp {} in create_topology.tcl --" 
	    puts "-- Possible reasons: there is no such TCP installed in ns2 --" 
	    exit
            } else {
        	set rftp($i) [$rtcp_($i) attach-source FTP]
	        set start_time_ftp_rev_($i) [expr [$start_time_rnd_ value] / 1000.0]
	        set stop_time_ftp_rev_($i) $sim_time_
	        $ns at $start_time_ftp_rev_($i) "$rftp($i) start"
	        $ns at $stop_time_ftp_rev_($i) "$rftp($i) stop"
		$rtcp_($i) init-stats 
		$ns at [expr $start_time_ftp_rev_($i) + $neglect_time_] "$rtcp_($i) init-stats"
	    }
    }

    # Setup cross links and traffic
    if { $num_btnk_ >1 } { 
        for { set k 0 } { $k < $num_btnk_ } { incr k } {
            for { set j 0 } { $j < [$traffic_ set num_ftp_flow_cross_] } { incr j } {
                set i [expr $k * [$traffic_ set num_ftp_flow_cross_] + $j]
                set cs($i) [$ns node]
                set cd($i) [$ns node]
                $ns duplex-link $cs($i) $btnk_($k)    [expr $non_btnk_bw_]Mb [expr $crs_btnk_delay_]ms $OTHERQUEUE
                $ns queue-limit $cs($i) $btnk_($k)    [expr $non_btnk_buf_]
                $ns queue-limit $btnk_($k) $cs($i)    [expr $non_btnk_buf_]
            if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
		set flink [$ns link $cs($i) $btnk_($k)]
		set rlink [$ns link $btnk_($k) $cs($i)] 
		set fq [$flink queue]
		set rq [$rlink queue]
		$fq set-link-capacity [[$flink set link_] set bandwidth_]
		$rq set-link-capacity [[$rlink set link_] set bandwidth_]
	    }
                set ii [expr $k + 1]
                $ns duplex-link $cd($i) $btnk_($ii)   [expr $non_btnk_bw_]Mb [expr $crs_btnk_delay_]ms $OTHERQUEUE
                $ns queue-limit $cd($i) $btnk_($ii)   [expr $non_btnk_buf_]
                $ns queue-limit $btnk_($ii) $cd($i)   [expr $non_btnk_buf_]
            if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
		set flink [$ns link $cd($i) $btnk_($ii)]
		set rlink [$ns link $btnk_($ii) $cd($i)] 
		set fq [$flink queue]
		set rq [$rlink queue]
		$fq set-link-capacity [[$flink set link_] set bandwidth_]
		$rq set-link-capacity [[$rlink set link_] set bandwidth_]
	    }
		if { [catch { set ctcp_($i) [$ns create-connection $SRC $cs($i) $SINK $cd($i) [expr 30000+$i]] } ] !=0 } {
		    puts "-- Create-connection cross failed. Please check btnk_traffic_ftp {} in create_topology.tcl --" 
		    puts "-- Possible reasons: there is no such TCP installed in ns2 --" 
		    exit
		} else {
		    set cftp_($i) [$ctcp_($i) attach-source FTP]
		    set start_time [expr [$start_time_rnd_ value] / 1000.0]
		    set stop_time  $sim_time_
                
		    $ns at $start_time "$cftp_($i) start"
		    $ns at $stop_time "$cftp_($i) stop"
        
		    $ctcp_($i) init-stats
		    $ns at [expr $start_time + $neglect_time_] "$ctcp_($i) init-stats"
		}
	    }
	}
    }   
}

# Create basic.
Create_topology/Dumb_bell/Basic instproc btnk_topology_basic {} {
    $self instvar btnk_             ;# bottleneck nodes
    $self instvar btnk_bw_ num_btnk_ btnk_buf_ btnk_delay_ ; # bottleneck parameters
    $self instvar graph_ traffic_ 
    $self instvar SRC SINK QUEUE OTHERQUEUE
    $self instvar edge_delay_ edge_bw_ core_delay_ buffer_length_ ;# basic
    set scheme [$traffic_ set scheme_] 
    $self get_tcp_params $scheme
    
    set btnk_buf_ [expr $btnk_bw_ * $buffer_length_ / 8.0]  ;# in 1KB pkt
    
    if { $QUEUE == "RED"} {
        $self set_red_params $btnk_buf_
    }
    
    # bottleneck links
    set ns [Simulator instance]
    for { set i 0 } { $i <= $num_btnk_ } { incr i } {
        set btnk_($i) [$ns node]
    }
    for { set i 0 } { $i < $num_btnk_ } { incr i } {
        $ns duplex-link $btnk_($i) $btnk_([expr $i+1]) [expr $btnk_bw_]Mb  [expr $core_delay_]ms $QUEUE
        $ns queue-limit $btnk_($i) $btnk_([expr $i+1]) [expr $btnk_buf_]
        $ns queue-limit $btnk_([expr $i+1]) $btnk_($i) [expr $btnk_buf_]
    }

    # Add static error in the path
    if { [$graph_ set show_graph_response_function_]==1 } {
        for { set i 0 } { $i < $num_btnk_ } { incr i } {
            set em($i) [new ErrorModel]
            $em($i) unit pkt
            $em($i) set rate_ [$graph_ set error_rate_]
            $em($i) ranvar [new RandomVariable/Uniform]
            $em($i) drop-target [new Agent/Null]
            $ns lossmodel $em($i) $btnk_($i) $btnk_([expr $i+1]) 
            set rem($i) [new ErrorModel]
            $rem($i) unit pkt
            $rem($i) set rate_ [$graph_ set error_rate_]
            $rem($i) ranvar [new RandomVariable/Uniform]
            $rem($i) drop-target [new Agent/Null]
            $ns lossmodel $rem($i) $btnk_([expr $i+1]) $btnk_($i)
            }
        }
}

# Create ftp traffic                                                                                            

# create basic wireless.
Create_topology/Dumb_bell/Basic instproc btnk_wireless_basic {} {

    $self instvar btnk_ num_btnk_ btnk_bw_ btnk_buf_ QUEUE OTHERQUEUE
    $self instvar traffic_ sim_time_ graph_ 
    $self instvar edge_delay_ edge_bw_ core_delay_ buffer_length_ tmix_s tmix_d tracefd_;# basic 
    
    set ns [Simulator instance]
    set scheme [$traffic_ set scheme_] 
    $self get_tcp_params $scheme
    if { $QUEUE == "RED"} {
        $self set_red_params $btnk_buf_
    }
    
    global tmp_directory_ 
    if { ![info exists tmp_directory_] } {
        set tmp_directory_ [create-tmp-directory]
    }    
    set tracefd_ [open $tmp_directory_/data/tmix.tr w]
    $ns trace-all $tracefd_
    
    set num_tmix_flow [$traffic_ set num_tmix_flow_]
    
   
    # wireless start, part from ~/tcl/ex/wired-cum-wireless.tcl
    set opt(chan)       Channel/WirelessChannel
    set opt(prop)       Propagation/TwoRayGround
    set opt(netif)      Phy/WirelessPhy
    set opt(mac)        Mac/802_11
    set opt(ifq)        Queue/DropTail/PriQueue
    set opt(ll)         LL
    set opt(ant)        Antenna/OmniAntenna
    set opt(x)          670   
    set opt(y)          670   
    set opt(ifqlen)     50   
    set opt(nn_left)    $num_tmix_flow ;# 3 wired nodes
    set opt(nn_right)   $num_tmix_flow ;# 3 wireless nodes 
    set opt(adhocRouting)  DSDV                      
    Mac/802_11 set basicRate_ 1Mb
    Mac/802_11 set dataRate_ 11Mb

    # set up for hierarchical routing
    $ns node-config -addressType hierarchical
    AddrParams set domain_num_ 2          
    lappend cluster_num 4 1               
    AddrParams set cluster_num_ $cluster_num
    lappend eilastlevel 1 1 1 1 4 
    AddrParams set nodes_num_ $eilastlevel 
  
    set topo   [new Topography]
    $topo load_flatgrid $opt(x) $opt(y)
    create-god [expr  4]
     
    # create wired nodes
    set btnk_(0) [$ns node 0.0.0]
    
    # create left side node
    set temp_left {0.1.0 0.2.0 0.3.0}   
    for { set i 0 } { $i < $num_tmix_flow } { incr i } {
	      set tmix_s($i) [$ns node [lindex $temp_left $i]]
    }
                     
    $ns node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propInstance [new $opt(prop)] \
                 -phyType $opt(netif) \
                 -channel [new $opt(chan)] \
                 -topoInstance $topo \
                 -wiredRouting ON \
                 -agentTrace OFF \
                 -routerTrace OFF \
                 -macTrace ON

    set btnk_(1) [$ns node 1.0.0]
    $btnk_(1) random-motion 0 ; # AP setting 
    $btnk_(1) set X_ 1.0
    $btnk_(1) set Y_ 2.0
    $btnk_(1) set Z_ 0.0
    for { set i 0 } { $i < $num_btnk_ } { incr i } {
        $ns duplex-link $btnk_($i) $btnk_([expr $i+1]) [expr $btnk_bw_]Mb  [expr $core_delay_]ms $QUEUE
        $ns queue-limit $btnk_($i) $btnk_([expr $i+1]) [expr $btnk_buf_]
        $ns queue-limit $btnk_([expr $i+1]) $btnk_($i) [expr $btnk_buf_]
    }

    #configure for mobilenodes
    # non bottleneck inbound links
     $ns node-config -wiredRouting OFF
     set temp_right {1.0.1 1.0.2 1.0.3}   
     for { set i 0 } { $i < $num_tmix_flow } { incr i } {
	      set tmix_d($i) [$ns node [lindex $temp_right $i]]
	      $tmix_d($i) base-station [AddrParams addr2id [$btnk_(1) node-addr]]
          $ns initial_node_pos $tmix_d($i) 20
    }

     set cv_name [$traffic_ set tmix_cv_name_]
     set tmix_tcp_scheme [$traffic_ set tmix_tcp_scheme_]
     for { set i 0 } { $i < $num_tmix_flow } { incr i } {
	      set j [expr $i * 2]
	      $ns simplex-link $tmix_s($i) $btnk_(0) [lindex $edge_bw_ $j]Mb [lindex $edge_delay_ $j]ms $OTHERQUEUE
	      $ns simplex-link $btnk_(0) $tmix_s($i) [lindex $edge_bw_ [expr $j+1] ]Mb [lindex $edge_delay_ [expr $j+1] ]ms $OTHERQUEUE
	  #$ns queue-limit $tmix_s($i) $btnk_(0) [expr [lindex $edge_bw_ $j] * [lindex $edge_delay_ $j]/8.0]
	      $ns queue-limit $tmix_s($i) $btnk_(0) [expr [lindex $edge_bw_ $j] * $buffer_length_ /8.0]
          $ns queue-limit $btnk_(0) $tmix_s($i) [expr [lindex $edge_bw_ [expr $j+1] ] * $buffer_length_ /8.0] 
	
	      set INBOUND($i) [lindex $cv_name $i]
	      set tmix($i) [new Tmix]
	      $tmix($i) set-init $tmix_s($i);                 # tmix_s as initiator
	      $tmix($i) set-acc $tmix_d($i);                  # tmix_d as acceptor
	      $tmix($i) set-ID [expr $i+7]
	      $tmix($i) set-cvfile "$INBOUND($i)"
	      $tmix($i) set-TCP [lindex $tmix_tcp_scheme $i]
	      $ns at 0.0 "$tmix($i) start"
	      $ns at $sim_time_ "$tmix($i) stop"
    
    }
}


# Create http traffic
Create_topology instproc btnk_traffic_http {} {
    $self instvar btnk_ num_btnk_
    $self instvar non_btnk_bw_ non_btnk_buf_ non_btnk_delay_ delay_diff_ ; # non bottleneck parameters
    $self instvar traffic_ sim_time_ start_time_rnd_ 
    $self instvar SRC SINK QUEUE OTHERQUEUE
    set SRC_http TCP
    set SINK_http TCPSink
    set ns [Simulator instance]
    set scheme [$traffic_ set scheme_]
    $self get_tcp_params $scheme
    global tmp_directory_
    if { ![info exists tmp_directory_] } {
        set tmp_directory_ [create-tmp-directory]
    }
    
    # Create forward http links
	set webs(0) [$ns node]
	set webd(0) [$ns node]
        
	$ns duplex-link $webs(0) $btnk_(0) [expr $non_btnk_bw_]Mb [expr $non_btnk_delay_ + $delay_diff_]ms $OTHERQUEUE
	$ns queue-limit $webs(0) $btnk_(0) [expr $non_btnk_buf_]
	$ns queue-limit $btnk_(0) $webs(0) [expr $non_btnk_buf_]
	if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $webs(0) $btnk_(0)]
	    set rlink [$ns link $btnk_(0) $webs(0)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
	
	$ns duplex-link $webd(0) $btnk_($num_btnk_) [expr $non_btnk_bw_]Mb [expr $non_btnk_delay_ + $delay_diff_]ms $OTHERQUEUE
	$ns queue-limit $webd(0) $btnk_($num_btnk_) [expr $non_btnk_buf_]
	$ns queue-limit $btnk_($num_btnk_)  $webd(0) [expr $non_btnk_buf_]
	if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $webd(0) $btnk_($num_btnk_)]
	    set rlink [$ns link $btnk_($num_btnk_) $webd(0)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
        
    # Create forward http traffic
    set rate_ [$traffic_ set rate_http_flow_]  ;# generation rates per second forward
    set CLIENT 0    ;# constant
    set SERVER 1    ;# constant
	set pm(0) [new PackMimeHTTP]
	$pm(0) set-client $webs(0)              ;# name $webs(0) as client
	$pm(0) set-server $webd(0)              ;# name $n(1) as server
	$pm(0) set-rate $rate_                  ;# new connections per second
	$pm(0) set-http-1.1                     ;# use HTTP/1.1
	# create RNGs (appropriate RNG seeds are assigned automatically)
	set flowRNG(0) [new RNG]
	set reqsizeRNG(0) [new RNG]
	set rspsizeRNG(0) [new RNG]
	
	# create RandomVariables
	set flow_arrive(0) [new RandomVariable/PackMimeHTTPFlowArrive $rate_]
	set req_size(0) [new RandomVariable/PackMimeHTTPFileSize $rate_ $CLIENT]
	set rsp_size(0) [new RandomVariable/PackMimeHTTPFileSize $rate_ $SERVER]
            
	# assign RNGs to RandomVariables
	$flow_arrive(0) use-rng $flowRNG(0)  
	$req_size(0) use-rng $reqsizeRNG(0)  
	$rsp_size(0) use-rng $rspsizeRNG(0)  
            
	# set PackMime variables
	$pm(0) set-flow_arrive $flow_arrive(0)  
	$pm(0) set-req_size $req_size(0)  
	$pm(0) set-rsp_size $rsp_size(0)  
            
	# record HTTP statistics
	$pm(0) set-outfile "$tmp_directory_/data/pm.dat"
	set start_time_ [expr [$start_time_rnd_ value] / 1000.0]
	$ns at $start_time_ "$pm(0) start"
}

# Create voice traffic
Create_topology instproc btnk_traffic_voice {} {
    $self instvar btnk_ num_btnk_
    $self instvar non_btnk_bw_ non_btnk_buf_ non_btnk_delay_ delay_diff_ ; # non bottleneck parameters
    $self instvar traffic_ sim_time_ start_time_rnd_ neglect_time_
    $self instvar SRC SINK QUEUE OTHERQUEUE
    set ns [Simulator instance]
    set scheme [$traffic_ set scheme_]
    $self get_tcp_params $scheme
    
    # Create 2-way voice topology
    for { set i 0 } { $i< [$traffic_ set num_voice_flow_] } { incr i } {
	$self instvar voice_s voice_d voice_app_fwd
	set voice_s($i) [$ns node]
	set voice_d($i) [$ns node]
        
	$ns duplex-link $voice_s($i) $btnk_(0) [expr $non_btnk_bw_]Mb [expr $non_btnk_delay_ + $i*$delay_diff_]ms $OTHERQUEUE
	$ns queue-limit $voice_s($i) $btnk_(0) [expr $non_btnk_buf_]
	$ns queue-limit $btnk_(0) $voice_s($i) [expr $non_btnk_buf_]
	if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $voice_s($i) $btnk_(0)]
	    set rlink [$ns link $btnk_(0) $voice_s($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
	
	$ns duplex-link $voice_d($i) $btnk_($num_btnk_) [expr $non_btnk_bw_]Mb [expr $non_btnk_delay_ + $i*$delay_diff_]ms $OTHERQUEUE
	$ns queue-limit $voice_d($i) $btnk_($num_btnk_) [expr $non_btnk_buf_]
	$ns queue-limit $btnk_($num_btnk_)  $voice_d($i) [expr $non_btnk_buf_]
	if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $voice_d($i) $btnk_($num_btnk_)]
	    set rlink [$ns link $btnk_($num_btnk_) $voice_d($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
    }

    set ifCBR 1 ;# If we use cbr or on/off model 
    # Create 2-way vocie traffic.
    # Now the traffic is generated according to 2-state on/off model, in which on and off states are exponentially distributed.
    # The mean on time: 1s; mean off time: 1.35s in accordance with ITU-T Artificial Conversational Speech. 
    # And it may be changed to other models.
    # packet size: 200 Bytes, including voice packet 160bytes (codec G711, 64kbps rate and 20ms duration), IP header 20 bytes,
    # UDP header 8bytes, RTP header 12 bytes.
    if { $ifCBR == 1 } {
        for { set i 0 } { $i< [$traffic_ set num_voice_flow_] } { incr i } {
	    # set one way traffic
	    set voice_src_fwd($i) [new Agent/UDP]
	    set voice_sink_fwd($i) [new Agent/Null]
	    $ns attach-agent $voice_s($i) $voice_src_fwd($i)
	    $ns attach-agent $voice_d($i) $voice_sink_fwd($i)
	    $ns connect $voice_src_fwd($i) $voice_sink_fwd($i)
	    set voice_app_fwd($i) [new Application/Traffic/CBR]
	    $voice_app_fwd($i) attach-agent $voice_src_fwd($i)
	    $voice_app_fwd($i) set packetSize_ 200
	    $voice_app_fwd($i) set rate_ 64k
	    $voice_app_fwd($i) set random_ 1
	    set start_time_f_ [expr [$start_time_rnd_ value] / 1000.0]
	    $ns at $start_time_f_ "$voice_app_fwd($i) start"
	
	    # set another way traffic
	    set voice_src_rev($i) [new Agent/UDP]
	    set voice_sink_rev($i) [new Agent/Null]
	    $ns attach-agent $voice_d($i) $voice_src_rev($i)
	    $ns attach-agent $voice_s($i) $voice_sink_rev($i)
	    $ns connect $voice_src_rev($i) $voice_sink_rev($i)
	    set voice_app_rev($i) [new Application/Traffic/CBR]
	    $voice_app_rev($i) attach-agent $voice_src_rev($i)
	    $voice_app_rev($i) set packetSize_ 200
	    $voice_app_rev($i) set rate_ 64k
	    $voice_app_rev($i) set random_ 1
	    set start_time_r_ [expr [$start_time_rnd_ value] / 1000.0]
	    $ns at $start_time_r_ "$voice_app_rev($i) start"
	}
    } else {
	# on/off model
	for { set i 0 } { $i< [$traffic_ set num_voice_flow_] } { incr i } {
            # set one way traffic
            set voice_src_fwd($i) [new Agent/UDP]
            set voice_sink_fwd($i) [new Agent/Null]
            $ns attach-agent $voice_s($i) $voice_src_fwd($i)
            $ns attach-agent $voice_d($i) $voice_sink_fwd($i)
            $ns connect $voice_src_fwd($i) $voice_sink_fwd($i)
            set voice_app_fwd($i) [new Application/Traffic/Exponential]
            $voice_app_fwd($i) attach-agent $voice_src_fwd($i)
            $voice_app_fwd($i) set packetSize_ 200
            $voice_app_fwd($i) set bust_time_ 1000ms
            $voice_app_fwd($i) set idle_time_ 1350ms
            $voice_app_fwd($i) set rate_ 64k
            set start_time_f_ [expr [$start_time_rnd_ value] / 1000.0]
            $ns at $start_time_f_ "$voice_app_fwd($i) start"
            
            # set another way traffic
            set voice_src_rev($i) [new Agent/UDP]
            set voice_sink_rev($i) [new Agent/Null]
            $ns attach-agent $voice_d($i) $voice_src_rev($i)
            $ns attach-agent $voice_s($i) $voice_sink_rev($i)
            $ns connect $voice_src_rev($i) $voice_sink_rev($i)
            set voice_app_rev($i) [new Application/Traffic/Exponential]
            $voice_app_rev($i) attach-agent $voice_src_rev($i)
            $voice_app_rev($i) set packetSize_ 200
            $voice_app_rev($i) set bust_time_ 1000ms
            $voice_app_rev($i) set idle_time_ 1350ms
            $voice_app_rev($i) set rate_ 64k
            set start_time_r_ [expr [$start_time_rnd_ value] / 1000.0]
            $ns at $start_time_r_ "$voice_app_rev($i) start"
        }
    }
}

# Create streaming traffic using CBR.
Create_topology instproc btnk_traffic_streaming {} {
    $self instvar btnk_ num_btnk_
    $self instvar non_btnk_bw_ non_btnk_buf_ non_btnk_delay_ delay_diff_ ; # non bottleneck parameters
    $self instvar traffic_ sim_time_ start_time_rnd_ neglect_time
    $self instvar streaming_s streaming_d rstreaming_s rstreaming_d
    $self instvar SRC SINK QUEUE OTHERQUEUE
    set ns [Simulator instance]
    set scheme [$traffic_ set scheme_]
    $self get_tcp_params $scheme
    
    # Forward    
    for { set i 0 } { $i< [$traffic_ set num_streaming_flow_fwd_] } { incr i } {
	set streaming_s($i) [$ns node]
	set streaming_d($i) [$ns node]
        
	$ns duplex-link $streaming_s($i) $btnk_(0) [expr $non_btnk_bw_]Mb [expr $non_btnk_delay_ + $i*$delay_diff_]ms $OTHERQUEUE
	$ns queue-limit $streaming_s($i) $btnk_(0) [expr $non_btnk_buf_]
	$ns queue-limit $btnk_(0) $streaming_s($i) [expr $non_btnk_buf_]
	if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $streaming_s($i) $btnk_(0)]
	    set rlink [$ns link $btnk_(0) $streaming_s($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}	
	$ns duplex-link $streaming_d($i) $btnk_($num_btnk_) [expr $non_btnk_bw_]Mb [expr $non_btnk_delay_ + $i*$delay_diff_]ms $OTHERQUEUE
	$ns queue-limit $streaming_d($i) $btnk_($num_btnk_) [expr $non_btnk_buf_]
	$ns queue-limit $btnk_($num_btnk_)  $streaming_d($i) [expr $non_btnk_buf_]
	if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $streaming_d($i) $btnk_($num_btnk_)]
	    set rlink [$ns link $btnk_($num_btnk_) $streaming_d($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
    }
    
    for { set i 0 } { $i< [$traffic_ set num_streaming_flow_fwd_] } { incr i } {
	set streaming_src_fwd($i) [new Agent/UDP]
	set streaming_sink_fwd($i) [new Agent/Null]
	$ns attach-agent $streaming_s($i) $streaming_src_fwd($i)
	$ns attach-agent $streaming_d($i) $streaming_sink_fwd($i)
	$ns connect $streaming_src_fwd($i) $streaming_sink_fwd($i)
	set streaming_app_fwd($i) [new Application/Traffic/CBR]
	$streaming_app_fwd($i) attach-agent $streaming_src_fwd($i)
	$streaming_app_fwd($i) set packetSize_ [$traffic_ set packetsize_streaming_]
	$streaming_app_fwd($i) set rate_ [$traffic_ set rate_streaming_]
	$streaming_app_fwd($i) set random_ 1
	set start_time_s_ [expr [$start_time_rnd_ value] / 1000.0]
	$ns at $start_time_s_ "$streaming_app_fwd($i) start"
        }
    
    # Reverse   
    for { set i 0 } { $i< [$traffic_ set num_streaming_flow_rev_] } { incr i } {
	set rstreaming_s($i) [$ns node]
	set rstreaming_d($i) [$ns node]
        
	$ns duplex-link $rstreaming_d($i) $btnk_(0) [expr $non_btnk_bw_]Mb [expr $non_btnk_delay_ + $i*$delay_diff_]ms $OTHERQUEUE
	$ns queue-limit $rstreaming_d($i) $btnk_(0) [expr $non_btnk_buf_]
	$ns queue-limit $btnk_(0) $rstreaming_d($i) [expr $non_btnk_buf_]
	if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $rstreaming_d($i) $btnk_(0)]
	    set rlink [$ns link $btnk_(0) $rstreaming_d($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
	
	$ns duplex-link $rstreaming_s($i) $btnk_($num_btnk_) [expr $non_btnk_bw_]Mb [expr $non_btnk_delay_ + $i*$delay_diff_]ms $OTHERQUEUE
	$ns queue-limit $rstreaming_s($i) $btnk_($num_btnk_) [expr $non_btnk_buf_]
	$ns queue-limit $btnk_($num_btnk_)  $rstreaming_s($i) [expr $non_btnk_buf_]
	if { $OTHERQUEUE == "XCP" || $OTHERQUEUE == "DropTail2/VcpQueue" } {
	    set flink [$ns link $rstreaming_s($i) $btnk_($num_btnk_)]
	    set rlink [$ns link $btnk_($num_btnk_) $rstreaming_s($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
    }
    
    for { set i 0 } { $i< [$traffic_ set num_streaming_flow_rev_] } { incr i } {
	set streaming_src_rev($i) [new Agent/UDP]
	set streaming_sink_rev($i) [new Agent/Null]
	$ns attach-agent $rstreaming_s($i) $streaming_src_rev($i)
	$ns attach-agent $rstreaming_d($i) $streaming_sink_rev($i)
	$ns connect $streaming_src_rev($i) $streaming_sink_rev($i)
	set streaming_app_rev($i) [new Application/Traffic/CBR]
	$streaming_app_rev($i) attach-agent $streaming_src_rev($i)
	$streaming_app_rev($i) set packetSize_ [$traffic_ set packetsize_streaming_]
	$streaming_app_rev($i) set rate_ [$traffic_ set rate_streaming_]
	$streaming_app_rev($i) set random_ 1
	set start_time_r_ [expr [$start_time_rnd_ value] / 1000.0]
	$ns at $start_time_r_ "$streaming_app_rev($i) start"
        }
}

# End setting topology and traffic
# -----------------------------------------------

# Show bottleneck link statistics
Create_topology instproc btnk_show_link {} {
    $self instvar btnk_ num_btnk_
    $self instvar neglect_time_ btnk_buf_
    $self instvar graph_ traffic_
    set percentile [$graph_ set percentile_]
    set scheme [$traffic_ set scheme_]
    if { $scheme == "XCP" } {
      set buf_tmp [expr $btnk_buf_ * 3] 
       } else {
              set buf_tmp $btnk_buf_
       }

    for { set i 0 } { $i < $num_btnk_ } { incr i } {
	$graph_ create_bottleneck_stats_fwd $btnk_($i) $btnk_([expr $i+1]) $neglect_time_ $buf_tmp $i
	$graph_ create_bottleneck_stats_rev $btnk_([expr $i+1]) $btnk_($i) $neglect_time_ $buf_tmp $i
    }
    
    if {[$graph_ set show_graph_fwd_]==1} {

    # -utilization
	if {[$graph_ set show_graph_util_]==1} {
	    for { set i 0 } { $i < $num_btnk_ } { incr i } {
		$graph_ create_util_fwd $btnk_($i) $btnk_([expr $i +1]) $i "Forward Bottleneck No.[expr $i+1] Utilization vs Time"        
	    }
	}
	# -queue size percentile
	if {[$graph_ set show_graph_percentile_]==1} {
	    for { set i 0 } { $i < $num_btnk_ } { incr i } {
	        $graph_ create_percentile_fwd $btnk_($i) $btnk_([expr $i +1]) $i $percentile "Forward Bottleneck No.[expr $i+1] Queue Length $percentile% Percentile"
	    }
	}
    # -queue length
	if {[$graph_ set show_graph_qlen_]==1} {
	    for { set i 0 } { $i < $num_btnk_ } { incr i } {
	        $graph_ create_qlen_fwd $btnk_($i) $btnk_([expr $i +1]) $i "Forward Bottleneck No.[expr $i+1] Queue Length"
	    }
	}
    }
   
    # Reverse direction.
    if {[$graph_ set show_graph_rev_]==1} {
	if {[$graph_ set show_graph_util_]==1} {
	    for { set i 0 } { $i < $num_btnk_ } { incr i } {
	        $graph_ create_util_rev  $btnk_($i) $btnk_([expr $i +1]) $i "Reverse Bottleneck No.[expr $i+1] Utilization vs Time"
	    }
	}
	
	if {[$graph_ set show_graph_percentile_]==1} {
	    for { set i 0 } { $i < $num_btnk_ } { incr i } {
	        $graph_ create_percentile_rev  $btnk_([expr $i +1]) $btnk_($i) $i $percentile "Reverse Bottleneck No.[expr $i+1] Queue Length $percentile% Percentile"
	    }
	}
	
	if {[$graph_ set show_graph_qlen_]==1} {
	    for { set i 0 } { $i < $num_btnk_ } { incr i } {
	        $graph_ create_qlen_rev  $btnk_([expr $i +1]) $btnk_($i) $i "Reverse Bottleneck No.[expr $i+1] Queue Length"
	    }
	}
    }
}

# Show FTP throughput statistics
Create_topology instproc btnk_show_ftp {} {
    $self instvar btnk_ num_btnk_ num_ftp_flow_cross_
    $self instvar tcp_ rtcp_ ctcp_
    $self instvar graph_ traffic_
    $self instvar start_time_ftp_fwd_ stop_time_ftp_fwd_ start_time_ftp_rev_ stop_time_ftp_rev_ sim_time_ neglect_time_
    # forward tcp goodput in text
    if {[$graph_ set show_tcp_throughput_]==1} {
	for { set i 0 } { $i < [$traffic_ set num_ftp_flow_fwd_] } { incr i } {
	    $graph_ create_tcp_throughput $tcp_($i) $i
	}
    }
    
    if {[$graph_ set show_graph_fwd_]==1 && [$traffic_ set num_ftp_flow_fwd_] > 0} {
        # forward tcp cwnd   	
        if {[$graph_ set show_graph_cwnd_]==1} {
	    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_fwd_] } { incr i } {
		$graph_ create_cwnd_fwd $tcp_($i) $i
	    }
	}
        # forward ftp goodput in graph
	if {[$graph_ set show_graph_throughput_]==1} {
	    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_fwd_] } { incr i } {
		$graph_ create_throughput_fwd [$traffic_ set scheme_] $tcp_($i) $i 
	    }
	}
	
	if { $num_btnk_ > 1 } {
	    # cross ftp goodput and cwnd
	    if {[$graph_ set show_graph_cross_]==1} {
	    	for { set k 0 } { $k < $num_btnk_ } { incr k } {
		    for { set j 0 } { $j < [$traffic_ set num_ftp_flow_cross_] } { incr j } {
			set i [expr $k * [$traffic_ set num_ftp_flow_cross_] + $j]
			$graph_ create_throughput_cross $ctcp_($i) $i $k $j
			$graph_ create_cwnd_cross $ctcp_($i) $i
		    }
		}
	    }
	}
	
	if {[$graph_ set show_graph_srtt_]==1} {
	    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_fwd_] } { incr i } {
		$graph_ create_srtt_fwd $tcp_($i) $i
	    }
	}
	
	if {[$graph_ set show_graph_rtt_]==1} {
	    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_fwd_] } { incr i } {
		$graph_ create_rtt_fwd $tcp_($i) $i
	    }
	}
	
	if {[$graph_ set show_graph_seqno_]==1} {
	    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_fwd_] } { incr i } {
		$graph_ create_seqno_fwd $s($i) $btnk_0 $i
	    }
	}
	
    }
    # Reverse direction.
    if {[$graph_ set show_graph_rev_]==1 && [$traffic_ set num_ftp_flow_rev_] > 0} {
	
	if {[$graph_ set show_graph_cwnd_]==1} {
	    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_rev_] } { incr i } {
		$graph_ create_cwnd_rev $rtcp_($i) $i
	    }
	}
	
	if {[$graph_ set show_graph_throughput_]==1} {
	    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_rev_] } { incr i } {
		$graph_ create_throughput_rev [$traffic_ set scheme_] $rtcp_($i) $i 
	    }
	}
	
	if {[$graph_ set show_graph_srtt_]==1} {
	    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_rev_] } { incr i } {
		$graph_ create_srtt_rev $rtcp_($i) $i
	    }
	}
	
	if {[$graph_ set show_graph_rtt_]==1} {
	    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_rev_] } { incr i } {
		$graph_ create_rtt_rev $rtcp_($i) $i
	    }
	}

	if {[$graph_ set show_graph_seqno_]==1} {
	    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_rev_] } { incr i } {
		$graph_ create_seqno_rev $rs($i) $btnk_1 $i
	    }
	}	
    }
}

# HTTP automatically collected by PackMime.

# Show voice statistics
Create_topology instproc btnk_show_voice {} {
    $self instvar graph_ traffic_
    $self instvar btnk_ num_btnk_
    $self instvar voice_s voice_d voice_app_fwd
        if {[$traffic_ set num_voice_flow_] >0 } {
	    set num_voice [$traffic_ set num_voice_flow_]
	    set tmp_num [eval $self show_subset $num_voice]
	    foreach i $tmp_num {
		$graph_ create_voice_stats $voice_s($i) $btnk_(0) $btnk_($num_btnk_) $voice_d($i) $i [$voice_app_fwd($i) set packetSize_] $tmp_num
	    }
    }
}

# Show streaming statistics
Create_topology instproc btnk_show_streaming {} {
    $self instvar graph_ traffic_
    $self instvar btnk_ num_btnk_
    $self instvar streaming_s streaming_d rstreaming_s rstreaming_d
    if {[$graph_ set show_graph_fwd_]==1} {
        if {[$graph_ set show_graph_streaming_]==1 && [$traffic_ set num_streaming_flow_fwd_]>0} {
	    set num_streaming_fwd [$traffic_ set num_streaming_flow_fwd_]
	    set tmp_num [eval $self show_subset $num_streaming_fwd]
	    foreach i $tmp_num {
                $graph_ create_streaming_stats_fwd $streaming_s($i) $btnk_(0) $btnk_($num_btnk_) $streaming_d($i) $i [$traffic_ set packetsize_streaming_] $tmp_num
            }
	}
    }
    # Reverse direction.    
    if {[$graph_ set show_graph_rev_]==1} {
        if {[$graph_ set show_graph_streaming_]==1 && [$traffic_ set num_streaming_flow_rev_]>0} {
	    set num_streaming_rev [$traffic_ set num_streaming_flow_rev_]
	    set tmp_num [eval $self show_subset $num_streaming_rev]
	    foreach i $tmp_num {
                $graph_ create_streaming_stats_rev $rstreaming_s($i) $btnk_($num_btnk_) $btnk_(0) $rstreaming_d($i) $i [$traffic_ set packetsize_streaming_] $tmp_num
            }
	}
    }    
}

# Show tmix statistics
Create_topology instproc btnk_show_tmix {} {
    $self instvar graph_ traffic_ sim_time_ btnk_buf_bdp_ 
    $graph_ create_tmix_stats [$traffic_ set num_tmix_flow_] "tmix_qdelay_forward" "tmix_qdelay_reverse" "tmix_flow" $sim_time_ $btnk_buf_bdp_
}

# paper:section D statistics
Create_topology instproc btnk_show_tmix_secD {} {
    $self instvar graph_ traffic_ tcp_ cbr_ btnk_buf_ tmix_s tmix_d btnk_
    $graph_ create_secD_stats [$traffic_ set cross_case_] $tcp_(0) $cbr_(0) $btnk_buf_ $tmix_s(0) $tmix_d(0) $btnk_(0) $btnk_(1)
}

Create_topology/Dumb_bell instproc init args {
    eval $self next $args
}

Create_topology/Dumb_bell instproc create {} {             
    $self instvar num_btnk_
    set num_btnk_ 1
    eval $self set_parameters "Dumb_bell" $num_btnk_
    eval $self create_dumb_bell
}

# Create one bottleneck Dumb-Bell scenario
Create_topology/Dumb_bell instproc create_dumb_bell {} {
    $self instvar traffic_ graph_
    $self instvar sim_time_ neglect_time_
    set neglect_time_ [expr $sim_time_ * 0.2 ]
    
    # Start setting topology and traffic
    
    eval $self btnk_topology
    
    # Set traffic

    if { [ $traffic_ set num_ftp_flow_fwd_] > 0 || [  $traffic_ set num_ftp_flow_rev_ ] > 0  } {
        eval $self btnk_traffic_ftp
    }
    
    if { [$traffic_ set rate_http_flow_ ] > 0 } {
        eval $self btnk_traffic_http
    }
    
    if { [$traffic_ set num_voice_flow_] > 0 } {
        eval $self btnk_traffic_voice
    }
    
    if { [$traffic_ set num_streaming_flow_fwd_] > 0 || [$traffic_ set num_streaming_flow_rev_] > 0 } {
        eval $self btnk_traffic_streaming
    }
    
    # Set statistics
    if {[$graph_ set show_bottleneck_stats_]==1} {
        eval $self btnk_show_link
    }
    
    if {[$graph_ set show_graph_ftp_]==1} {
        eval $self btnk_show_ftp
    }
    
    
    if {[$graph_ set show_graph_voice_]==1} {
        eval $self btnk_show_voice
    }
    
    if {[$graph_ set show_graph_streaming_]==1} {
        eval $self btnk_show_streaming
    }
}

Create_topology/Dumb_bell/Basic instproc init args {
    eval $self next $args
}

Create_topology/Dumb_bell/Basic instproc create {} {             
    $self instvar num_btnk_ tmix_enabled_
    set tmix_enabled_ 1
    eval $self set_parameters "Dumb_bell" $num_btnk_
    eval $self create_dumb_bell
}

# Create basic scenario
Create_topology/Dumb_bell/Basic instproc create_dumb_bell {} {
    $self instvar traffic_ graph_
    $self instvar sim_time_ neglect_time_
    $self instvar if_wireless_
    set neglect_time_ [expr $sim_time_ * 0.2 ]
    
    if { $if_wireless_ == 1 } {
        # tmix wireless part
        eval $self btnk_wireless_basic 
    } else {
        # tmix wired part
        if { [$traffic_ set cross_case_] != 0 } {
            # section D in the paper
            eval $self btnk_traffic_tmix_secD
        } else {
            eval $self btnk_traffic_tmix
        }
    }
    # Set statistics
    if {[$graph_ set show_bottleneck_stats_]==1} {
        eval $self btnk_show_link
    }
    
    if {[$graph_ set show_graph_tmix_]==1} {
        eval $self btnk_show_tmix
    }
    
    if {[$traffic_ set cross_case_]!=0} {
        eval $self btnk_show_tmix_secD
    }
}


# Create Parking-Lot scenario.
Create_topology/Parking_lot instproc init args {
    eval $self next $args
}

Create_topology/Parking_lot instproc create {} {
    $self instvar num_btnk_
    eval $self set_parameters "Parking_lot" $num_btnk_
    eval $self create_parking_lot
}

Create_topology/Parking_lot instproc create_parking_lot {} {
    $self instvar traffic_ graph_
    $self instvar sim_time_ neglect_time_
    set neglect_time_ [expr $sim_time_ * 0.2 ]
    # Parking lot topology
    eval $self btnk_topology
    
    # Other scenarios
    if { [ $traffic_ set num_ftp_flow_fwd_] > 0 || [  $traffic_ set num_ftp_flow_rev_ ] > 0  } {
        eval $self btnk_traffic_ftp
    }
    
    if { [$traffic_ set rate_http_flow_] > 0  } {
        eval $self btnk_traffic_http
    }
    
    if { [$traffic_ set num_voice_flow_] > 0 } {
        eval $self btnk_traffic_voice
    }
    
    if { [$traffic_ set num_streaming_flow_fwd_] > 0 || [$traffic_ set num_streaming_flow_rev_] > 0 } {
        eval $self btnk_traffic_streaming
    }
    
    # Show statistics
    if {[$graph_ set show_bottleneck_stats_]==1} {
        eval $self btnk_show_link
    }
    
    if {[$graph_ set show_graph_ftp_]==1} {
	    eval $self btnk_show_ftp
   }
    
    
    if {[$graph_ set show_graph_voice_]==1} {
	    eval $self btnk_show_voice
   }
    
    if {[$graph_ set show_graph_streaming_]==1} {
        eval $self btnk_show_streaming
    }
}

# Create a network scenario. Similar processes as in Dumb-Bell.
# We name it Network_1 since more network topologies will likely be added.
Create_topology/Network_1 instproc init args {
    $self instvar num_transit_ delay_core_ delay_transit_ delay_stub_
    $self instvar bw_core_ bw_transit_ bw_stub_
    $self instvar queue_core_ queue_transit_ queue_stub_
    eval $self next $args
}

Create_topology/Network_1 instproc num_transit {val} {
    $self set num_transit_  $val
}

Create_topology/Network_1 instproc delay_core {val} {
    $self set delay_core_  $val
}

Create_topology/Network_1 instproc delay_transit {val} {
    $self set delay_transit_  $val
}

Create_topology/Network_1 instproc delay_stub {val} {
    $self set delay_stub_  $val
}

Create_topology/Network_1 instproc bw_core {val} {
    $self set bw_core_  $val
}

Create_topology/Network_1 instproc bw_transit {val} {
    $self set bw_transit_  $val
}

Create_topology/Network_1 instproc bw_stub {val} {
    $self set bw_stub_  $val
}

Create_topology/Network_1 instproc queue_core {val} {
    $self set queue_core_  $val
}

Create_topology/Network_1 instproc queue_transit {val} {
    $self set queue_transit_  $val
}

Create_topology/Network_1 instproc queue_stub {val} {
    $self set queue_stub_  $val
}

Create_topology/Network_1 instproc set_parameters {} {
    $self instvar num_transit_ delay_core_ delay_transit_ delay_stub_
    $self instvar bw_core_ bw_transit_ bw_stub_ 
    $self instvar graph_ traffic_
    $self instvar buf_core_ buf_transit_ buf_stub_
    $self instvar sim_time_ verbose_ if_html_ html_index_
    
    # Initialize parameters
    set scheme [$traffic_ set scheme_]
    set scheme [$traffic_ set scheme_] 
    set num_ftp [$traffic_ set num_ftp_flow_]
    set rate_http [$traffic_ set rate_http_flow_]
    set num_voice [$traffic_ set num_voice_flow_]
    set num_streaming [$traffic_ set num_streaming_flow_]
    set buf_bdp_ 1.0 ;# measured in bdp
    set buf_core_ [expr $buf_bdp_ * $bw_core_ * $delay_core_ / 8.0]          ;# in 1KB pkt
    set buf_transit_ [expr $buf_bdp_ * $bw_transit_ * $delay_transit_ / 8.0] ;# in 1KB pkt
    set buf_stub_ [expr $buf_bdp_ * $bw_stub_ * $delay_stub_ / 8.0]          ;# in 1KB pkt
    set rate_streaming [$traffic_ set rate_streaming_]
    set packet_streaming [$traffic_ set packetsize_streaming_]

    global tmp_directory_
    if { ![info exists tmp_directory_] } {
        set tmp_directory_ [create-tmp-directory]
    }
    
    if { $verbose_==1 } {
	if { $if_html_ == "1" } { 
	    #; print to html
	    set html_file [open "/tmp/index$html_index_.html" "a"]
	    puts $html_file "<p><font size=5 color=0066ff>Scenario Settings</font></p>"
	    puts $html_file "<table border=1>"
	    puts $html_file "<tr>"
	    puts $html_file "<th align=center>Name</th>"
	    puts $html_file "<th align=center>Sim Time</th>"
	    puts $html_file "<th align=center>Output</th>"
	    puts $html_file "<th align=center>Disp. Bottleneck</th>"
	    puts $html_file "<th align=center>Disp. FTP</th>"
	    puts $html_file "<th align=center>Disp. HTTP</th>"
	    puts $html_file "<th align=center>Disp. Voice</th>"
	    puts $html_file "<th align=center>Disp. Streaming</th>"
	    puts $html_file "</tr>"
	    puts $html_file "<tr>"
	    puts $html_file "<th align=center>Value</th>"
	    puts $html_file "<td align=center>$sim_time_ s</td>"
	    puts $html_file "<td align=center>index$html_index_.html</td>"
	    set show_btnk_stat [$graph_ set show_bottleneck_stats_]
	    set show_ftp       [$graph_ set show_graph_ftp_]
	    set show_http      [$graph_ set show_graph_http_]
	    set show_voice     [$graph_ set show_graph_voice_]
	    set show_streaming [$graph_ set show_graph_streaming_]
	    
	    puts $html_file "<td align=center>$show_btnk_stat</td>"
	    puts $html_file "<td align=center>$show_ftp</td>"
	    puts $html_file "<td align=center>$show_http</td>"
	    puts $html_file "<td align=center>$show_voice</td>"
	    puts $html_file "<td align=center>$show_streaming</td>"
	    puts $html_file "</tr>"
	    puts $html_file "</table>"
	    puts $html_file "<p><font size=5 color=0066ff>Topology Settings</font></p>"
	    puts $html_file "<table border=1>"
	    puts $html_file "<tr>"
	    puts $html_file "<th align=center>Name</th>"
	    puts $html_file "<th align=center>Topology</th>"
	    puts $html_file "<th align=center>NUM.Transit</th>"
	    puts $html_file "<th align=center>Core Bandwidth</th>"
	    puts $html_file "<th align=center>Core Delay</th>"
	    puts $html_file "<th align=center>Core Buffer</th>"
	    puts $html_file "<th align=center>Transit Bandwidth</th>"
	    puts $html_file "<th align=center>Transit Delay</th>"
	    puts $html_file "<th align=center>Transit Buffer</th>"
	    puts $html_file "<th align=center>Stub Bandwidth</th>"
	    puts $html_file "<th align=center>Stub Delay</th>"
	    puts $html_file "<th align=center>Stub Buffer</th>"
	    puts $html_file "<th align=center>Packet Error Rate</th>"
	    puts $html_file "<th align=center>Use AQM</th>"
	    puts $html_file "</tr>"
	    puts $html_file "<tr>"
	    puts $html_file "<th align=center>Value</th>"
	    puts $html_file "<td align=center>Network</td>"
	    puts $html_file "<td align=center>$num_transit_ </td>"
	    puts $html_file "<td align=center>$bw_core_ Mbps</td>"
	    puts $html_file "<td align=center>$delay_core_ ms</td>"
	    puts $html_file "<td align=center>$buf_core_ </td>"
	    puts $html_file "<td align=center>$bw_transit_ Mbps</td>"
	    puts $html_file "<td align=center>$delay_transit_ ms</td>"
	    puts $html_file "<td align=center>$buf_transit_ </td>"
	    puts $html_file "<td align=center>$bw_stub_ Mbps</td>"
	    puts $html_file "<td align=center>$delay_stub_ ms</td>"
	    puts $html_file "<td align=center>$buf_stub_ </td>"
	    set error_rate [$graph_ set error_rate_]
	    puts $html_file "<td align=center>$error_rate</td>"
	    set useAQM [$traffic_ set useAQM_]
	    puts $html_file "<td align=center>$useAQM </td>"
	    puts $html_file "</tr>"
	    puts $html_file "</table>"
	    
	    puts $html_file "<p><font size=5 color=0066ff>Traffic Settings</font></p>"
	    puts $html_file "<table border=1>"
	    puts $html_file "<tr>"
	    puts $html_file "<th align=center rowspan=2>Name</th>"
	    puts $html_file "<th align=center colspan=2>FTP</th>"
	    puts $html_file "<th align=center colspan=1>HTTP</th>"
	    puts $html_file "<th align=center colspan=1>Voice</th>"
	    puts $html_file "<th align=center colspan=3>Streaming</th>"
	    puts $html_file "</tr>"
	    puts $html_file "<tr>"
	    puts $html_file "<td align=center>Num.</td>"
	    puts $html_file "<td align=center>TCP</td>"
	    puts $html_file "<td align=center>Rate</td>"
	    puts $html_file "<td align=center>Num.</td>"
	    puts $html_file "<td align=center>Num.</td>"
	    puts $html_file "<td align=center>Rate</td>"
	    puts $html_file "<td align=center>Packet Size</td>"
	    puts $html_file "</tr>"
	    puts $html_file "<tr>"
	    puts $html_file "<th align=center>Value</th>"
	    puts $html_file "<td align=center>$num_ftp</td>"
	    puts $html_file "<td align=center>$scheme</td>"
	    puts $html_file "<td align=center>$rate_http /s</td>"
	    puts $html_file "<td align=center>$num_voice</td>"
	    puts $html_file "<td align=center>$num_streaming</td>"
	    puts $html_file "<td align=center>$rate_streaming</td>"
	    puts $html_file "<td align=center>$packet_streaming B</td>"
	    puts $html_file "</tr>"
	    puts $html_file "</table>"
	    puts $html_file "<br>"
	    puts $html_file "The simulation DATA results will be stored in $tmp_directory_/data<br>"
	    puts $html_file "The simulation GRAPH results will be stored in $tmp_directory_/figure<br>"
	    puts $html_file "</body>"
	    puts $html_file "</html>"
	    close $html_file
	} else {
	    
	    puts "********************************************************"
	    puts "simulation results for Network"
	    puts "********************************************************"
	    puts ""
	    puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	    puts "fixed parameter settings:"
	    puts "+++++++++++++++++++++++++++++++++"
	    puts "  TCP :     	     $scheme"
	    puts "  transit num:     $num_transit_"
	    puts "  core bw:         $bw_core_ Mbps"
	    puts "  core delay:      $delay_core_ ms"
	    puts "  core buf:        $buf_core_ KB"
	    puts "  transit bw:      $bw_transit_ Mbps"
	    puts "  transit delay:   $delay_transit_ ms"
	    puts "  transit buf:     $buf_transit_ KB"
	    puts "  stub bw:         $bw_stub_ Mbps"
	    puts "  stub delay:      $delay_stub_ ms"
	    puts "  stub buf:        $buf_stub_ KB"
	    puts "  ftp num:         $num_ftp"
	    puts "  http rate:       $rate_http /s"
	    puts "  voice num:       $num_voice"
	    puts "  streaming num:   $num_streaming"
	    puts "  simulation time: $sim_time_ s"
	    puts "+++++++++++++++++++++++++++++++++"
	    puts ""
	    puts "The simulation DATA results will be stored in $tmp_directory_/data"
	    puts "The simulation GRAPH results will be stored in $tmp_directory_/figure"
	}
    } else {
	    puts -nonewline [format "%s %2d %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %4d %4d %4d %4d " $scheme $num_transit_ $bw_core_ $delay_core_ $bw_transit_ $delay_transit_ $bw_stub_ $delay_stub_ $num_ftp $rate_http $num_voice $num_streaming]
 }
}

Create_topology/Network_1 instproc create {} {
    $self instvar traffic_ graph_
    $self instvar sim_time_ neglect_time_
    set neglect_time_ [expr $sim_time_ * 0.2]
    eval $self set_parameters 
    
    # Set backbone
    eval $self network_backbone
    
    # Set user nodes and links
    if { [$traffic_ set num_ftp_flow_] > 0   } {
        eval $self network_traffic_ftp
    }
    if { [$traffic_ set rate_http_flow_ ] > 0 } {
        eval $self network_traffic_http
    }
    
    if { [$traffic_ set num_voice_flow_] > 0 } {
        eval $self network_traffic_voice
    }
    
    if { [$traffic_ set num_streaming_flow_] > 0 } {
        eval $self network_traffic_streaming
    }
    
    # Set statistics
    if {[$graph_ set show_bottleneck_stats_]==1} {
        eval $self network_show_link
    }
    
    if {[$graph_ set show_graph_ftp_]==1} {
        eval $self network_show_ftp
    }
    
    
    if {[$graph_ set show_graph_voice_]==1} {
        eval $self network_show_voice
    }
    
    if {[$graph_ set show_graph_streaming_]==1} {
        eval $self network_show_streaming
    }
}

# Set backbone nodes and links
Create_topology/Network_1 instproc network_backbone {} {
    $self instvar num_transit_ delay_core_ delay_transit_ 
    $self instvar bw_core_ bw_transit_ 
    $self instvar queue_core_ queue_transit_ 
    $self instvar buf_core_ buf_transit_
    $self instvar core_ transit_ ;# backbone nodes
    $self instvar traffic_ graph_
    
    set ns [Simulator instance]
    set scheme [$traffic_ set scheme_] 
    $self get_tcp_params $scheme
    set useAQM [$traffic_ set useAQM_]
    if { $useAQM == "1" } {
        $self set_red_params $buf_core_
    }
    
    for { set i 0 } { $i < $num_transit_ } { incr i } {
	set core_($i) [$ns node]
	set transit_($i) [$ns node]
    }
    
    for { set i 0 } { $i < $num_transit_ } { incr i } {
	set j [expr $i+1]
	if { $j == $num_transit_ } {
	    set j 0
	}

	$ns duplex-link $core_($i) $core_($j) [expr $bw_core_]Mb [expr $delay_core_]ms $queue_core_
	if { $queue_core_ == "XCP" } {
	    $ns queue-limit $core_($i) $core_($j) [expr $buf_core_]
	    $ns queue-limit $core_($j) $core_($i) [expr $buf_core_]
	} else {
	    $ns queue-limit $core_($i) $core_($j) [expr $buf_core_]
	    $ns queue-limit $core_($j)  $core_($i) [expr $buf_core_]
	}
        
	if { $queue_core_ == "XCP" || $queue_core_ == "DropTail2/VcpQueue" } {
	    set flink [$ns link $core_($i) $core_($j)]
	    set rlink [$ns link $core_($j)  $core_($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
        }
	# add static error in the core route
	if { [$graph_ set show_graph_response_function_]==1 } {
            set em($i) [new ErrorModel]
            $em($i) unit pkt
            $em($i) set rate_ [$graph_ set error_rate_]
            $em($i) ranvar [new RandomVariable/Uniform]
            $em($i) drop-target [new Agent/Null]
            $ns lossmodel $em($i) $core_($i) $core_($j) 
            set rem($i) [new ErrorModel]
            $rem($i) unit pkt
            $rem($i) set rate_ [$graph_ set error_rate_]
            $rem($i) ranvar [new RandomVariable/Uniform]
            $rem($i) drop-target [new Agent/Null]
            $ns lossmodel $rem($i) $core_($j) $core_($i)
	}
	
	$ns duplex-link $transit_($i) $core_($i) [expr $bw_transit_]Mb [expr $delay_transit_]ms $queue_transit_
	if { $queue_transit_ == "XCP" } {
	    $ns queue-limit $transit_($i) $core_($i) [expr $buf_transit_]
	    $ns queue-limit $core_($i) $transit_($i) [expr $buf_transit_]
	} else {
	    $ns queue-limit $transit_($i) $core_($i) [expr $buf_transit_]
	    $ns queue-limit $core_($i)  $transit_($i) [expr $buf_transit_]
	}
        
	if { $queue_transit_ == "XCP" || $queue_transit_ == "DropTail2/VcpQueue" } {
	    set flink [$ns link $core_($i) $transit_($i)]
	    set rlink [$ns link $transit_($i)  $core_($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
	
	# Add static error in the transit core path
	if { [$graph_ set show_graph_response_function_]==1 } {
            set tem($i) [new ErrorModel]
            $tem($i) unit pkt
            $tem($i) set rate_ [$graph_ set error_rate_]
            $tem($i) ranvar [new RandomVariable/Uniform]
            $tem($i) drop-target [new Agent/Null]
            $ns lossmodel $tem($i) $transit_($i) $core_($i) 
            set rtem($i) [new ErrorModel]
            $rtem($i) unit pkt
            $rtem($i) set rate_ [$graph_ set error_rate_]
            $rtem($i) ranvar [new RandomVariable/Uniform]
            $rtem($i) drop-target [new Agent/Null]
            $ns lossmodel $rtem($i) $core_($i) $transit_($i)
        }
    }
}

# Random select a transit node
Create_topology/Network_1 instproc select_transit {} {
    $self instvar num_transit_
    set  rng  [new RNG]
    $rng  seed 0
    set  r3  [new RandomVariable/Uniform]
    $r3  use-rng $rng
    $r3  set  min_ 0
    $r3  set  max_ [expr $num_transit_ -1]
    return [expr round([$r3 value])]                                                                                       
}

# Create http traffic
Create_topology/Network_1 instproc network_traffic_ftp {} {
    $self instvar traffic_ sim_time_ start_time_rnd_ neglect_time_
    $self instvar delay_stub_ bw_stub_ queue_stub_ buf_stub_
    $self instvar transit_ SRC SINK
    $self instvar tcp_ rtcp_ start_time_ftp_ stop_time_ftp_
    # set num_users [expr [$traffic_ set num_ftp_flow_] + [$traffic_ set num_http_flow_fwd_] + [$traffic_ set num_voice_flow_] + [$traffic_ set num_streaming_flow_fwd_] ]
    set ns [Simulator instance]    
    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_] } { incr i } {
	set ftp_s($i) [$ns node]
	set ftp_d($i) [$ns node]
	# random select 
	set transit_source [$self select_transit]
	set transit_dest [$self select_transit]
	# set transit_source 0
	# set transit_dest 2
	$ns duplex-link $ftp_s($i) $transit_($transit_source) [expr $bw_stub_]Mb [expr $delay_stub_]ms $queue_stub_
	if { $queue_stub_ == "XCP" } {
	    $ns queue-limit $ftp_s($i) $transit_($transit_source) [expr $buf_stub_]
	    $ns queue-limit $transit_($transit_source) $ftp_s($i) [expr $buf_stub_]
	} else {
	    $ns queue-limit $ftp_s($i) $transit_($transit_source) [expr $buf_stub_]
	    $ns queue-limit $transit_($transit_source)  $ftp_s($i) [expr $buf_stub_]
	}
        
	if { $queue_stub_ == "XCP" || $queue_stub_ == "DropTail2/VcpQueue" } {
	    set flink [$ns link $ftp_s($i) $transit_($transit_source)]
	    set rlink [$ns link $transit_($transit_source) $ftp_s($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
	
	$ns duplex-link $ftp_d($i) $transit_($transit_dest) [expr $bw_stub_]Mb [expr $delay_stub_]ms $queue_stub_
	if { $queue_stub_ == "XCP" } {
	    $ns queue-limit $ftp_d($i) $transit_($transit_dest) [expr $buf_stub_]
	    $ns queue-limit $transit_($transit_dest) $ftp_d($i) [expr $buf_stub_]
	} else {
	    $ns queue-limit $ftp_d($i) $transit_($transit_dest) [expr $buf_stub_]
	    $ns queue-limit $transit_($transit_dest) $ftp_d($i) [expr $buf_stub_]
	}
        
	if { $queue_stub_ == "XCP" || $queue_stub_ == "DropTail2/VcpQueue" } {
	    set flink [$ns link $ftp_d($i) $transit_($transit_dest)]
	    set rlink [$ns link $transit_($transit_dest) $ftp_d($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
    }
    
    for { set i 0 } { $i < [$traffic_ set num_ftp_flow_] } { incr i } {
        if { [catch { set tcp_($i) [$ns create-connection $SRC $ftp_s($i) $SINK $ftp_d($i) $i] }] !=0 } {
	    puts "-- Create-connection failed. Please check network_traffic_ftp {} in create_topology.tcl --" 
	    puts "-- Possible reasons: there is no such TCP installed in ns2 --" 
	    exit
	} else {
	    set ftp($i) [$tcp_($i) attach-source FTP]
	    set start_time_ftp_($i) [expr [$start_time_rnd_ value] / 1000.0]
	    set stop_time_ftp_($i) $sim_time_
	    $ns at $start_time_ftp_($i) "$ftp($i) start"
	    $ns at $stop_time_ftp_($i) "$ftp($i) stop"
	    $tcp_($i) init-stats 
	    $ns at [expr $start_time_ftp_($i) + $neglect_time_] "$tcp_($i) init-stats"
	}
    }
}

# Create http traffic
Create_topology/Network_1 instproc network_traffic_http {} {
    $self instvar traffic_ sim_time_ start_time_rnd_ neglect_time_
    $self instvar delay_stub_ bw_stub_ queue_stub_ buf_stub_
    $self instvar transit_
    
    set ns [Simulator instance]
    # Create http links
    set webs(0) [$ns node]
    set webd(0) [$ns node]
    set transit_source [$self select_transit]
    set transit_dest [$self select_transit]
    
    # Debug use.
    # set transit_source 3
    # set transit_dest 1
    $ns duplex-link $webs(0) $transit_($transit_source) [expr $bw_stub_]Mb [expr $delay_stub_]ms $queue_stub_
    if { $queue_stub_ == "XCP" } {
	$ns queue-limit $webs(0) $transit_($transit_source) [expr $buf_stub_]
	$ns queue-limit $transit_($transit_source) $webs(0) [expr $buf_stub_]
    } else {
	$ns queue-limit $webs(0) $transit_($transit_source) [expr $buf_stub_]
	$ns queue-limit $transit_($transit_source) $webs(0) [expr $buf_stub_]
    }
    
    if { $queue_stub_ == "XCP" || $queue_stub_ == "DropTail2/VcpQueue" } {
	set flink [$ns link $webs(0) $transit_($transit_source)]
	set rlink [$ns link $transit_($transit_source) $webs(0)] 
	set fq [$flink queue]
	set rq [$rlink queue]
	$fq set-link-capacity [[$flink set link_] set bandwidth_]
	$rq set-link-capacity [[$rlink set link_] set bandwidth_]
    }
	
    $ns duplex-link $webd(0) $transit_($transit_dest) [expr $bw_stub_]Mb [expr $delay_stub_]ms $queue_stub_
    if { $queue_stub_ == "XCP" } {
	$ns queue-limit $webd(0) $transit_($transit_dest) [expr $buf_stub_]
	$ns queue-limit $transit_($transit_dest)  $webd(0) [expr $buf_stub_]
    } else {
	$ns queue-limit $webd(0) $transit_($transit_dest) [expr $buf_stub_]
	$ns queue-limit $transit_($transit_dest)  $webd(0) [expr $buf_stub_]
    }
        
    if { $queue_stub_ == "XCP" || $queue_stub_ == "DropTail2/VcpQueue" } {
	set flink [$ns link $webd(0) $transit_($transit_dest)]
	set rlink [$ns link $transit_($transit_dest) $webd(0)] 
	set fq [$flink queue]
	set rq [$rlink queue]
	$fq set-link-capacity [[$flink set link_] set bandwidth_]
	$rq set-link-capacity [[$rlink set link_] set bandwidth_]
    }
    
    # Create http traffic
    global tmp_directory_
    if { ![info exists tmp_directory_] } {
        set tmp_directory_ [create-tmp-directory]
    }
    
    set rate_ [$traffic_ set rate_http_flow_]  ;# generation rates per second forward
    set CLIENT 0    ;# constant
    set SERVER 1    ;# constant
    set pm(0) [new PackMimeHTTP]
    $pm(0) set-client $webs(0)              ;# name $webs(0) as client
    $pm(0) set-server $webd(0)              ;# name $n(1) as server
    $pm(0) set-rate $rate_                  ;# new connections per second
    $pm(0) set-http-1.1                     ;# use HTTP/1.1
    
    # create RNGs (appropriate RNG seeds are assigned automatically)
    set flowRNG(0) [new RNG]
    set reqsizeRNG(0) [new RNG]
    set rspsizeRNG(0) [new RNG]
	
    # create RandomVariables
    set flow_arrive(0) [new RandomVariable/PackMimeHTTPFlowArrive $rate_]
    set req_size(0) [new RandomVariable/PackMimeHTTPFileSize $rate_ $CLIENT]
    set rsp_size(0) [new RandomVariable/PackMimeHTTPFileSize $rate_ $SERVER]
    
    # assign RNGs to RandomVariables
    $flow_arrive(0) use-rng $flowRNG(0)  
    $req_size(0) use-rng $reqsizeRNG(0)  
    $rsp_size(0) use-rng $rspsizeRNG(0)  
    
    # set PackMime variables
    $pm(0) set-flow_arrive $flow_arrive(0)  
    $pm(0) set-req_size $req_size(0)  
    $pm(0) set-rsp_size $rsp_size(0)  
    
    # record HTTP statistics
    $pm(0) set-outfile "$tmp_directory_/data/pm.dat"
    
    set start_time_ [expr [$start_time_rnd_ value] / 1000.0]
    $ns at $start_time_ "$pm(0) start"
}

# Network_1 voice traffic
Create_topology/Network_1 instproc network_traffic_voice {} {
    $self instvar traffic_ sim_time_ start_time_rnd_ neglect_time_
    $self instvar delay_stub_ bw_stub_ queue_stub_ buf_stub_
    $self instvar transit_
    $self instvar voice_source_ voice_dest_ ;# source and dest transit of voice
    $self instvar voice_s voice_d voice_app_fwd
    
    set ns [Simulator instance]
    # Create 2-way voice topology
    for { set i 0 } { $i< [$traffic_ set num_voice_flow_] } { incr i } {
	set voice_s($i) [$ns node]
	set voice_d($i) [$ns node]
	set voice_source_($i) [$self select_transit]
	set voice_dest_($i) [$self select_transit]
	
	$ns duplex-link $voice_s($i) $transit_($voice_source_($i)) [expr $bw_stub_]Mb [expr $delay_stub_]ms $queue_stub_
	if { $queue_stub_ == "XCP" } {
	    $ns queue-limit $voice_s($i) $transit_($voice_source_($i)) [expr $buf_stub_]
	    $ns queue-limit $transit_($voice_source_($i)) $voice_s($i) [expr $buf_stub_]
	} else {
	    $ns queue-limit $voice_s($i) $transit_($voice_source_($i)) [expr $buf_stub_]
	    $ns queue-limit $transit_($voice_source_($i)) $voice_s($i) [expr $buf_stub_]
	}
        
	if { $queue_stub_ == "XCP" || $queue_stub_ == "DropTail2/VcpQueue" } {
	    set flink [$ns link $voice_s($i) $transit_($voice_source_($i))]
	    set rlink [$ns link $transit_($voice_source_($i)) $voice_s($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
	
	$ns duplex-link $voice_d($i) $transit_($voice_dest_($i)) [expr $bw_stub_]Mb [expr $delay_stub_]ms $queue_stub_
	if { $queue_stub_ == "XCP" } {
	    $ns queue-limit $voice_d($i) $transit_($voice_dest_($i)) [expr $buf_stub_]
	    $ns queue-limit $transit_($voice_dest_($i))  $voice_d($i) [expr $buf_stub_]
	} else {
	    $ns queue-limit $voice_d($i) $transit_($voice_dest_($i)) [expr $buf_stub_]
	    $ns queue-limit $transit_($voice_dest_($i))  $voice_d($i) [expr $buf_stub_]
	}
        
	if { $queue_stub_ == "XCP" || $queue_stub_ == "DropTail2/VcpQueue" } {
	    set flink [$ns link $voice_d($i) $transit_($voice_dest_($i))]
	    set rlink [$ns link $transit_($voice_dest_($i)) $voice_d($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
    }

    set ifCBR 1 ;# If we use cbr or on/off model 
    # Create 2-way vocie traffic.
    # Now the traffic is generated according to 2-state on/off model, in which on and off states are exponentially distributed.
    # Its mean on time: 1s; mean off time: 1.35s in accordance with ITU-T Artificial conversational speech. And it may be 
    # changed to other models.
    # Packet size: 200 Bytes, including voice packet 160bytes (codec G711, 64kbps rate and 20ms duration), IP header 20 bytes,
    # UDP header 8bytes, RTP header 12 bytes.
    if { $ifCBR == 1 } {
        for { set i 0 } { $i< [$traffic_ set num_voice_flow_] } { incr i } {
	    # Set one way traffic
	    set voice_src_fwd($i) [new Agent/UDP]
	    set voice_sink_fwd($i) [new Agent/Null]
	    $ns attach-agent $voice_s($i) $voice_src_fwd($i)
	    $ns attach-agent $voice_d($i) $voice_sink_fwd($i)
	    $ns connect $voice_src_fwd($i) $voice_sink_fwd($i)
	    set voice_app_fwd($i) [new Application/Traffic/CBR]
	    $voice_app_fwd($i) attach-agent $voice_src_fwd($i)
	    $voice_app_fwd($i) set packetSize_ 200
	    $voice_app_fwd($i) set rate_ 64k
	    $voice_app_fwd($i) set random_ 1
	    set start_time_f_ [expr [$start_time_rnd_ value] / 1000.0]
	    $ns at $start_time_f_ "$voice_app_fwd($i) start"
	
	    # Set another way traffic
	    set voice_src_rev($i) [new Agent/UDP]
	    set voice_sink_rev($i) [new Agent/Null]
	    $ns attach-agent $voice_d($i) $voice_src_rev($i)
	    $ns attach-agent $voice_s($i) $voice_sink_rev($i)
	    $ns connect $voice_src_rev($i) $voice_sink_rev($i)
	    set voice_app_rev($i) [new Application/Traffic/CBR]
	    $voice_app_rev($i) attach-agent $voice_src_rev($i)
	    $voice_app_rev($i) set packetSize_ 200
	    $voice_app_rev($i) set rate_ 64k
	    $voice_app_rev($i) set random_ 1
	    set start_time_r_ [expr [$start_time_rnd_ value] / 1000.0]
	    $ns at $start_time_r_ "$voice_app_rev($i) start"
	}
    } else {    
	for { set i 0 } { $i< [$traffic_ set num_voice_flow_] } { incr i } {
	    # Set one way traffic
	    set voice_src_fwd($i) [new Agent/UDP]
	    set voice_sink_fwd($i) [new Agent/Null]
	    $ns attach-agent $voice_s($i) $voice_src_fwd($i)
	    $ns attach-agent $voice_d($i) $voice_sink_fwd($i)
	    $ns connect $voice_src_fwd($i) $voice_sink_fwd($i)
	    set voice_app_fwd($i) [new Application/Traffic/Exponential]
	    $voice_app_fwd($i) attach-agent $voice_src_fwd($i)
	    $voice_app_fwd($i) set packetSize_ 200
	    $voice_app_fwd($i) set bust_time_ 1000ms
	    $voice_app_fwd($i) set idle_time_ 1350ms
	    $voice_app_fwd($i) set rate_ 64k
	    set start_time_f_ [expr [$start_time_rnd_ value] / 1000.0]
	    $ns at $start_time_f_ "$voice_app_fwd($i) start"
	
	    # Set another way traffic
	    set voice_src_rev($i) [new Agent/UDP]
	    set voice_sink_rev($i) [new Agent/Null]
	    $ns attach-agent $voice_d($i) $voice_src_rev($i)
	    $ns attach-agent $voice_s($i) $voice_sink_rev($i)
	    $ns connect $voice_src_rev($i) $voice_sink_rev($i)
	    set voice_app_rev($i) [new Application/Traffic/Exponential]
	    $voice_app_rev($i) attach-agent $voice_src_rev($i)
	    $voice_app_rev($i) set packetSize_ 200
	    $voice_app_rev($i) set bust_time_ 1000ms
	    $voice_app_rev($i) set idle_time_ 1350ms
	    $voice_app_rev($i) set rate_ 64k
	    set start_time_r_ [expr [$start_time_rnd_ value] / 1000.0]
	    $ns at $start_time_r_ "$voice_app_rev($i) start"
	}
    }
}

# Network streaming traffic using CBR.
Create_topology/Network_1 instproc network_traffic_streaming {} {
    $self instvar traffic_ sim_time_ start_time_rnd_ neglect_time_
    $self instvar delay_stub_ bw_stub_ queue_stub_ buf_stub_
    $self instvar transit_
    $self instvar streaming_s streaming_d rstreaming_s rstreaming_d
    $self instvar streaming_source_ streaming_dest_ ;# source and dest transit of streaming
    
    set ns [Simulator instance]
    for { set i 0 } { $i< [$traffic_ set num_streaming_flow_] } { incr i } {
	set streaming_s($i) [$ns node]
	set streaming_d($i) [$ns node]
	set streaming_source_($i) [$self select_transit]
	set streaming_dest_($i) [$self select_transit]
	
	$ns duplex-link $streaming_s($i) $transit_($streaming_source_($i)) [expr $bw_stub_]Mb [expr $delay_stub_]ms $queue_stub_
	if { $queue_stub_ == "XCP" } {
    	$ns queue-limit $streaming_s($i) $transit_($streaming_source_($i)) [expr $buf_stub_]
	    $ns queue-limit $transit_($streaming_source_($i)) $streaming_s($i) [expr $buf_stub_]
        } else {
	    $ns queue-limit $streaming_s($i) $transit_($streaming_source_($i)) [expr $buf_stub_]
	    $ns queue-limit $transit_($streaming_source_($i)) $streaming_s($i) [expr $buf_stub_]
        }
	if { $queue_stub_ == "XCP" || $queue_stub_ == "DropTail2/VcpQueue" } {
        set flink [$ns link $streaming_s($i) $transit_($streaming_source_($i))]
        set rlink [$ns link $transit_($streaming_source_($i)) $streaming_s($i)] 
        set fq [$flink queue]
        set rq [$rlink queue]
        $fq set-link-capacity [[$flink set link_] set bandwidth_]
        $rq set-link-capacity [[$rlink set link_] set bandwidth_]
        }
	
	$ns duplex-link $streaming_d($i) $transit_($streaming_dest_($i)) [expr $bw_stub_]Mb [expr $delay_stub_]ms $queue_stub_
	if { $queue_stub_ == "XCP" } {
	    $ns queue-limit $streaming_d($i) $transit_($streaming_dest_($i)) [expr $buf_stub_]
	    $ns queue-limit $transit_($streaming_dest_($i)) $streaming_d($i) [expr $buf_stub_]
	} else {
	    $ns queue-limit $streaming_d($i) $transit_($streaming_dest_($i)) [expr $buf_stub_]
	    $ns queue-limit $transit_($streaming_dest_($i)) $streaming_d($i) [expr $buf_stub_]
	}
        
	if { $queue_stub_ == "XCP" || $queue_stub_ == "DropTail2/VcpQueue" } {
	    set flink [$ns link $streaming_d($i) $transit_($streaming_dest_($i))]
	    set rlink [$ns link $transit_($streaming_dest_($i)) $streaming_d($i)] 
	    set fq [$flink queue]
	    set rq [$rlink queue]
	    $fq set-link-capacity [[$flink set link_] set bandwidth_]
	    $rq set-link-capacity [[$rlink set link_] set bandwidth_]
	}
    }
    
    for { set i 0 } { $i< [$traffic_ set num_streaming_flow_] } { incr i } {
	set streaming_src_fwd($i) [new Agent/UDP]
	set streaming_sink_fwd($i) [new Agent/Null]
	$ns attach-agent $streaming_s($i) $streaming_src_fwd($i)
	$ns attach-agent $streaming_d($i) $streaming_sink_fwd($i)
	$ns connect $streaming_src_fwd($i) $streaming_sink_fwd($i)
	set streaming_app_fwd($i) [new Application/Traffic/CBR]
	$streaming_app_fwd($i) attach-agent $streaming_src_fwd($i)
	$streaming_app_fwd($i) set packetSize_ [$traffic_ set packetsize_streaming_]
	$streaming_app_fwd($i) set rate_ [$traffic_ set rate_streaming_]
	$streaming_app_fwd($i) set random_ 1
	set start_time_s_ [expr [$start_time_rnd_ value] / 1000.0]
	$ns at $start_time_s_ "$streaming_app_fwd($i) start"
    }
}

# Collect statistics
# Show bottleneck link stats
Create_topology/Network_1 instproc network_show_link {} {
    $self instvar num_transit_  
    $self instvar core_ transit_ buf_core_ buf_transit_ ;# backbone nodes
    $self instvar neglect_time_
    $self instvar graph_ traffic_
    set percentile [$graph_ set percentile_]
    
    set scheme [$traffic_ set scheme_]
    if { $scheme == "XCP" } {
      set buf_core_tmp [expr $buf_core_ * 3] 
      set buf_transit_tmp [expr $buf_transit_ * 3] 
    } else {
      set buf_core_tmp  $buf_core_  
      set buf_transit_tmp $buf_transit_  
    }
    for { set i 0 } { $i < $num_transit_ } { incr i } {
        set j [expr $i+1]
        if { $j == $num_transit_ } {
            set j 0
        }
	
	$graph_ create_bottleneck_stats_fwd_core $core_($i) $core_($j) $neglect_time_ $buf_core_tmp $i
	$graph_ create_bottleneck_stats_rev_core $core_($j) $core_($i) $neglect_time_ $buf_core_tmp $i
	$graph_ create_bottleneck_stats_fwd_transit $transit_($i) $core_($i) $neglect_time_ $buf_transit_tmp $i
	$graph_ create_bottleneck_stats_rev_transit $core_($i) $transit_($i) $neglect_time_ $buf_transit_tmp $i
    }
    
    if {[$graph_ set show_graph_fwd_]==1} {
	
	if {[$graph_ set show_graph_util_]==1} {
	    for { set i 0 } { $i < $num_transit_ } { incr i } {
		set j [expr $i+1]
		if { $j == $num_transit_ } {
		    set j 0
		}
	        $graph_ create_util_fwd $core_($i) $core_($j) $i "Forword Core Link No.$i Utilization vs Time"
	        $graph_ create_util_fwd $transit_($i) $core_($i) [expr $i+$num_transit_] "Forward Transit Link No.$i Utilization vs Time"
	    }
	}
	
	if {[$graph_ set show_graph_percentile_]==1} {
	    for { set i 0 } { $i < $num_transit_ } { incr i } {
		set j [expr $i+1]
		if { $j == $num_transit_ } {
		    set j 0
		}
	        $graph_ create_percentile_fwd $core_($i) $core_($j) $i $percentile "Forward Core Link No.$i Queue Length $percentile% Percentile"
	        $graph_ create_percentile_fwd $transit_($i) $core_($i) [expr $i+$num_transit_] $percentile "Forward Transit Link No.$i Queue Length $percentile% Percentile"
	    }
	}
	
	if {[$graph_ set show_graph_qlen_]==1} {
	    for { set i 0 } { $i < $num_transit_ } { incr i } {
		set j [expr $i+1]
		if { $j == $num_transit_ } {
		    set j 0
		}
	        $graph_ create_qlen_fwd $core_($i) $core_($j) $i "Forward Core Link No.$i Queue Length"
	        $graph_ create_qlen_fwd $transit_($i) $core_($i)  [expr $i+$num_transit_] "Forward Transit Link No.$i Queue Length"
		
	    }
	}
    }
    
    if {[$graph_ set show_graph_rev_]==1} {
	if {[$graph_ set show_graph_util_]==1} {
	    for { set i 0 } { $i < $num_transit_ } { incr i } {
		set j [expr $i+1]
		if { $j == $num_transit_ } {
		    set j 0
		}
	        $graph_ create_util_rev $core_($j) $core_($i) $i "Reverse Core Link No.$i Utilization vs Time"
	        $graph_ create_util_rev $core_($i) $transit_($i) [expr $i+$num_transit_] "Reverse Transit Link No.$i Utilization vs Time"
	    }
	}
	
	if {[$graph_ set show_graph_percentile_]==1} {
	    for { set i 0 } { $i < $num_transit_ } { incr i } {
		set j [expr $i+1]
		if { $j == $num_transit_ } {
		    set j 0
		}
	        $graph_ create_percentile_rev $core_($j) $core_($i) $i $percentile "Reverse Core Link No.$i Queue Length $percentile% Percentile"
	        $graph_ create_percentile_rev $core_($i) $transit_($i) [expr $i+$num_transit_] $percentile "Reverse Transit Link No.$i Queue Length $percentile% Percentile"
	    }
	}
	
	if {[$graph_ set show_graph_qlen_]==1} {
	    for { set i 0 } { $i < $num_transit_ } { incr i } {
		set j [expr $i+1]
            if { $j == $num_transit_ } {
                set j 0
            }
		$graph_ create_qlen_rev $core_($j) $core_($i) $i "Reverse Core Link No.$i Queue Length"
		$graph_ create_qlen_rev $core_($i) $transit_($i) [expr $i+$num_transit_] "Reverse Transit Link No.$i Queue Length"
	    }
	}
    }
}

# Show FTP throughput statistics
Create_topology/Network_1 instproc network_show_ftp {} {
    $self instvar tcp_ ctcp_
    $self instvar graph_ traffic_ 
    $self instvar start_time_ftp_ stop_time_ftp_ sim_time_
    set scheme [$traffic_ set scheme_]
    
    # Show tcp throughput output. disabled now.
    if {[$graph_ set show_tcp_throughput_]==1} {
	for { set i 0 } { $i < [$traffic_ set num_ftp_flow_] } { incr i } {
	    $graph_ create_tcp_throughput $tcp_($i) $i
	}
    }
    
    if {[$graph_ set show_graph_throughput_]==1} {
	for { set i 0 } { $i < [$traffic_ set num_ftp_flow_] } { incr i } {
	    $graph_ create_throughput_fwd $scheme $tcp_($i) $i 
	}
    }
    
}

# HTTP automatically collected by PackMime.

# Show voice  statistics
Create_topology instproc network_show_voice {} {
    $self instvar graph_ traffic_
    $self instvar voice_s voice_d voice_app_fwd
    $self instvar voice_source_ voice_dest_ transit_
    if {[$traffic_ set num_voice_flow_] >0 } {
        set num_voice [$traffic_ set num_voice_flow_]
        set tmp_num [eval $self show_subset $num_voice]
        foreach i $tmp_num {
            $graph_ create_voice_stats $voice_s($i) $transit_($voice_source_($i)) $transit_($voice_dest_($i)) $voice_d($i) $i [$voice_app_fwd($i) set packetSize_] $tmp_num
	}
    }
}

# Show streaming statistics
Create_topology instproc network_show_streaming {} {
    $self instvar graph_ traffic_ transit_
    $self instvar streaming_s streaming_d rstreaming_s rstreaming_d
    $self instvar streaming_source_ streaming_dest_
    if {[$traffic_ set num_streaming_flow_] >0 } {
        set num_streaming_fwd [$traffic_ set num_streaming_flow_]
        set tmp_num [eval $self show_subset $num_streaming_fwd]
        foreach i $tmp_num {
	    $graph_ create_streaming_stats_fwd $streaming_s($i) $transit_($streaming_source_($i)) $transit_($streaming_dest_($i)) $streaming_d($i) $i [$traffic_ set packetsize_streaming_] $tmp_num
        }
    }
}

# The finish routine
Create_topology instproc finish {} {
    $self instvar traffic_ tracefd_ if_wireless_ num_btnk_ 
    
    global tmp_directory_ env
    if { ![info exists tmp_directory_] } {
        set tmp_directory_ [create-tmp-directory]
    }    
    
    set num_tmix_flow [$traffic_ set num_tmix_flow_]
    set pp_dir $env(TCPEVAL)/tmix-tool/pp
    set num_nth_packets [$traffic_ set num_nth_packets_]
    if { $num_tmix_flow > 0 && $if_wireless_ == 0} {
        $self instvar btnk_ tmix_s tmix_d
        set ns [Simulator instance]
        $ns flush-trace
        close $tracefd_
        for { set i 0} { $i < $num_tmix_flow } { incr i } {
            exec $pp_dir $tmp_directory_/data/tmix.tr 0 $tmp_directory_/data/tmix_stats_$i 0 $tmp_directory_/data/tmix_rtr [$tmix_s($i) id] [$tmix_d($i) id] 1000 100 [$btnk_(0) id] [$btnk_(1) id] 0 $num_nth_packets $tmp_directory_/data/tmix_nth_time_$i
            
            # throughput stats
            exec awk { BEGIN {init_sent_packet=0;
                              init_recv_packet=0;
                              acc_sent_packet=0;
                              acc_recv_packet=0;
                             } 
                       { 
                        if ($7>0) {
                                   if ($14>0) init_sent_packet=init_sent_packet + $7 * $14;
                                   if ($15>0) init_recv_packet=init_recv_packet + $7 * $15;
                                   if ($16>0) acc_sent_packet=acc_sent_packet + $7 * $16; 
                                   if ($17>0) acc_recv_packet=acc_recv_packet + $7 * $17; 
                                  }
                       }
                       END {
                            print init_sent_packet, init_recv_packet, acc_sent_packet, acc_recv_packet; 
                        }
                      } $tmp_directory_/data/tmix_stats_$i >>$tmp_directory_/data/tmix_flow
             }
        
        # queueing delay stats
        set tmix_qdelay_awk_forward "\{\n \{\n if ((FNR%2)==1) print \$1,\$9 \n\} \n \}"
        set tmix_qdelay_awk_reverse "\{\n \{\n if ((FNR%2)==0) print \$1,\$9 \n\} \n \}"
        exec awk $tmix_qdelay_awk_forward $tmp_directory_/data/tmix_rtr > $tmp_directory_/data/tmix_qdelay_forward          
        exec awk $tmix_qdelay_awk_reverse $tmp_directory_/data/tmix_rtr > $tmp_directory_/data/tmix_qdelay_reverse          
    }
    if { $num_tmix_flow > 0 } {
        # rm trace file since its large size
        exec rm -rf $tmp_directory_/data/tmix.tr  
    }
# puts "Simulation ends..."
}
