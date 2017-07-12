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
# $Id: create_traffic.tcl,v 1.4 2008/11/03 06:22:49 wanggang Exp $
#
# This code creates the traffic settings with settable parameters.
#


Class Create_traffic

Create_traffic instproc init args {
    $self instvar num_tmix_flow_           ;# num of tmix flows, basic scenarion
    $self instvar tmix_cv_name_            ;# tmix connection vector name, basic scenario
    $self instvar num_nth_packets_         ;# nth received packets for sectionC only
    $self instvar tmix_tcp_scheme_         ;# tmix TCP scheme, sectionD only
    $self instvar cross_case_              ;# the UDP traffic case in section D of the paper
    $self instvar num_ftp_flow_            ;# num of long-lived flows, for network use
    $self instvar num_ftp_flow_fwd_        ;# num of long-lived flows, forward path
    $self instvar num_ftp_flow_rev_        ;# num of long-lived flows, reverse path
    $self instvar num_ftp_flow_cross_      ;# num of long-lived flows, cross link
    $self instvar rate_http_flow_          ;# arrival rate of http flow, network use
    $self instvar http_model_              ;# http model, now include PackMime_HTTP and Harrison
    $self instvar num_voice_flow_          ;# number of 2-way voice flow
    $self instvar num_streaming_flow_      ;# number of streaming flow, network use
    $self instvar num_streaming_flow_fwd_  ;# number of forward streaming flow
    $self instvar num_streaming_flow_rev_  ;# number of reverse streaming flow
    $self instvar rate_streaming_          ;# streaming generation rate
    $self instvar packetsize_streaming_    ;# streaming packet size
    $self instvar scheme_                  ;# the transport scheme
    $self instvar useAQM_                  ;# if use AQM

    # Initialize parameters
    set num_ftp_flow_ 0
    set num_ftp_flow_fwd_ 0
    set rate_http_flow_ 0
    set num_ftp_flow_rev_ 0
    set num_ftp_flow_cross_ 0
    set num_voice_flow_ 0
    set num_streaming_flow_ 0
    set num_streaming_flow_fwd_ 0
    set num_streaming_flow_rev_ 0
    set rate_streaming_ 0
    set packetsize_streaming_ 0
    set usaAQM_ 0
    set num_tmix_flow_ 0
    set tmix_cv_name_ [list]
    set tmix_tcp_scheme_ [list]
    set num_nth_packets_ 0
    set cross_case_ 0
    eval $self next $args
}

# Config procedures
# tmix traffic
Create_traffic instproc num_tmix_flow {val} {
    $self set num_tmix_flow_ $val
}

Create_traffic instproc tmix_cv_name {val} {
    $self instvar tmix_cv_name_
    lappend tmix_cv_name_ $val 
}


Create_traffic instproc num_nth_packets {val} {
    $self set num_nth_packets_ $val
}

Create_traffic instproc tmix_tcp_scheme {val} {
    $self instvar tmix_tcp_scheme_
    lappend tmix_tcp_scheme_ $val
}


Create_traffic instproc cross_case {val} {
    $self set cross_case_ $val
}

Create_traffic instproc num_ftp_flow_fwd {val} {
    $self set num_ftp_flow_fwd_ $val
}

Create_traffic instproc num_ftp_flow {val} {
    $self set num_ftp_flow_ $val
}


Create_traffic instproc rate_http_flow {val} {
    $self set rate_http_flow_ $val
}

Create_traffic instproc http_model {val} {
    $self set http_model_ $val
}

Create_traffic instproc num_ftp_flow_rev {val} {
    $self set num_ftp_flow_rev_ $val
}

Create_traffic instproc num_ftp_flow_cross {val} {
    $self set num_ftp_flow_cross_ $val
}

Create_traffic instproc num_voice_flow {val} {
    $self set num_voice_flow_ $val
}

Create_traffic instproc num_streaming_flow {val} {
    $self set num_streaming_flow_ $val
}

Create_traffic instproc num_streaming_flow_fwd {val} {
    $self set num_streaming_flow_fwd_ $val
}

Create_traffic instproc num_streaming_flow_rev {val} {
    $self set num_streaming_flow_rev_ $val
}

Create_traffic instproc rate_streaming {val} {
    $self set rate_streaming_ $val
}

Create_traffic instproc packetsize_streaming {val} {
    $self set packetsize_streaming_ $val
}

Create_traffic instproc scheme {val} {
    $self set scheme_ $val
}

Create_traffic instproc useAQM {val} {
    $self set useAQM_ $val
}

# Dispatch args
Create_traffic instproc init_var args {
    set shadow_args ""
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

# Config parameters

# tmix traffic
Create_traffic instproc config_tmix args {
    set args [eval $self init_var $args]
}

Create_traffic instproc config_ftp args {
    set args [eval $self init_var $args]
}

Create_traffic instproc config_http args {
    set args [eval $self init_var $args]
}

Create_traffic instproc config_voice args {
    set args [eval $self init_var $args]
}

Create_traffic instproc config_streaming args {
    set args [eval $self init_var $args]
}


# Finish routine
Create_traffic instproc finish {} {
}
