#
#
# Copyright (c) 2007  NEC Laboratories China.
# All rights reserved.
#
# Copyright (c) 2010-2011
#  Swinburne University of Technology, Melbourne, Australia
#  All rights reserved.
#
# Released under the GNU General Public License version 2.
#
# Original authors:
# - Gang Wang (wanggang@research.nec.com.cn)
# - Yong Xia   (xiayong@research.nec.com.cn)
#
# Revised, enhanced and updated
# - David Hayes (dahayes@swin.edu.au or david.hayes@ieee.org)
#
##################################################################
#
# This is where parameters for new TCP schemes should be added
#
##################################################################
#
# Each Test scheme (or special settings) should be a class so that tmix can
# handle it properly
#
Class Agent/TCP/Linux/Eval_CUBIC -superclass Agent/TCP/Linux
# Sink
Class Agent/TCPSink/Sack1/Eval_L_SINK -superclass Agent/TCPSink/Sack1/DelAck

Agent/TCP/Sack1/IW_Sack1 instproc init args {
    set ns [Simulator instance]
    set st [$ns now] 
    $ns at $st "$self set windowInit_ 10"
    $ns at $st "$self set windowInitOption_ 1"
    eval $self next $args
}
#
#
# Linux based congestion control
#
Agent/TCP/Linux/Eval_CUBIC instproc init args {
    set ns [Simulator instance]
    set st [$ns now] 
    $ns at $st "$self set timestamps_ true"
    $ns at $st "$self set partial_ack_ true"
    $ns at $st "$self select_ca cubic"
    eval $self next $args
}
#
Agent/TCPSink/Sack1/Eval_L_SINK instproc init args {
    set ns [Simulator instance]
    set st [$ns now] 
    $ns at $st "$self set generateDSacks_ false"
    $ns at $st "$self set ts_echo_rfc1323_ true"
    eval $self next $args
}
#
# Choose approate TCP src, TCP sink and Queue.
Create_topology instproc get_tcp_params { scheme group} {
    $self instvar SRC SINK QUEUE OTHERQUEUE SRC_INIT
    $self instvar queue_core_ queue_transit_ queue_stub_ 
    $self instvar btnk_buf_ traffic_
    
    set AQM [$traffic_ set useAQM_]
    set QUEUE DropTail
    set OTHERQUEUE DropTail
    set queue_core_ DropTail
    set queue_transit_ DropTail
    set queue_stub_ DropTail
    set SRC_INIT($group) ""
    
    Agent/TCP set packetSize_ 1460; # packet size for one-way TCP
    Agent/TCP/FullTcp set segsize_ 1460; # packet size for full-TCP

    Agent/TCP         set window_ 100000
    Agent/TCP/FullTcp set window_ 100000
    Agent/TCP/Sack1   set window_ 100000
    
    Agent/TCP         set ssthresh_ 100000
    Agent/TCP/FullTcp set ssthresh_ 100000
    Agent/TCP/Sack1   set ssthresh_ 100000
    
    

    if { $AQM == "RED" } {
	set QUEUE RED
	set queue_core_ RED
	set queue_transit_ RED
	Agent/TCP set ecn_ 1 ;
    }
    if { $AQM == "REM" } {
	set QUEUE REM
	set queue_core_ REM
	set queue_transit_ REM
	Agent/TCP set ecn_ 1 ;
    }

    if { $scheme == "Reno" } {
        set SRC($group)   Reno
        set SINK($group)  DelAck
    }
    
    if { $scheme == "Newreno" } {
        set SRC($group)   Newreno
        set SINK($group)  DelAck
    }
        
    if { $scheme == "Sack1" } {
	    set SRC($group)   Sack1
	    set SINK($group)  Sack1/DelAck
    }
    
    if { $scheme == "Cubic" } {
        set SRC($group)   Linux/Eval_CUBIC
	set SINK($group)  Sack1/Eval_L_SINK
    }

}

