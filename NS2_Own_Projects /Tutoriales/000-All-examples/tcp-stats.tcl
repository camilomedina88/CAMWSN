# Copyright(c)2001 David Harrison. 
# Licensed according to the terms of the GNU Public License.
#
# This module contains fucntions for obtaining TCP statistics.
# I could easily have provided more functions to compute totals, means,
# etc. This just includes those functions that I implemented because
# I happened to need them.
#
# init-stats         initializes stats for the given TCP agent.
# get-useful-packets returns number of packets transmitted containing new data
# get-useful-bytes   returns number of bytes transmitted containnig new data
# get-goodput-bps    returns goodput for specified agent in terms of bps.
# get-goodput        returns goodput as a ratio of useful bps to
#                    bottleneck capacity
# get-total-goodput  sum of the goodputs in bps across a  list of tcp sources.
# get-mean-goodput   mean goodput in bps across a list of tcp sources.
# get-goodput-variance variance in bps^2 across a list of tcp sources.
# get-goodput-stddev   stddev in bps across a list of tcp sources.
#Addition By Shri
#get-goodput-cov	coeff of variation in goodput across a list of tcps.
#End Addition By Shri
# get-total-data-packets
# get-total-retransmitted-packets
# get-total-retransmission-timeouts
#
# On high bandwidth networks, you must worry about long integers overflowing
# (i.e., wrapping around). This is important for get-useful-packets.
#
# Many other TCP statistics can be obtained by accessing
# data members of the TCP agent class:
#   ndatapack_       number of data packets transmitted (including
#                    retransmits; therefore >= useful packets transmitted)
#   ndatabytes_      number of bytes transmitted (incl. retransmits...)
#   nackpack_        number of acks received. multiple acks for the same
#                    seqno can arrive; therefore >= number of useful packets
#                    received
#   nrexmit_         number of retransmission timeouts.          
#   nrexmitpack_     number of retransmitted packets.
#   nrexmitbytes_    number of retransmitted bytes.
#
# Note about TCP full implementations:
# For Agent/TCP/FullTcp:
#   ndatapack_       does not include SYNs. Does not include FINs or ACKs
#                    unless they bear data. This is not relevant to 
#                    TcpAgent or RenoTcpAgent because they do not perform
#                    SYN or FIN exchanges and only send data in one direction.
#   ndatabytes_      same as ndatapack_ except in units of bytes. Unlike
#                    ndatabytes_ for the Agent/TCP/Reno, FullTcp excludes
#                    the header size from ndatabytes_. 
#   nackpack_        Counts ack packets SENT rather than acks received
#                    (as with Agent/TCP/Reno). Also it only counts packets 
#                    without data in it regardless of whether the
#                    TH_ACK bit is set. This includes
#                    the initial SYN in a three-way handshake
#                    which would not have the ACK bit set.
#
# These statistics are reset when you call init-stats.
#
# @author David Harrison
# @author Shrikrishna Karandikar 
# @author Yong Xiao


# sets the starting sequence number and starting time.
# You must call this before calling other instproc's in this
# file or else the returned results of these instproc's is
# undefined.

Agent/TCP instproc init-stats {} {
  set ns [Simulator instance]
  #$self instvar tcp_monitor_begin_time_ tcp_monitor_begin_ack_ ack_
  $self instvar tcp_monitor_begin_time_ 
  $self instvar ndatapack_ ndatabytes_ 
  $self instvar nackpack_ nrexmit_ nrexmitpack_ nrexmitbytes_

  set tcp_monitor_begin_time_ [$ns now]
  #set tcp_monitor_begin_ack_ $ack_

  set ndatapack_ 0
  set ndatabytes_ 0
  set nackpack_ 0
  set nrexmit_ 0
  set nrexmitbytes_ 0
  set nrexmitpack_ 0

}

#Returns the rate (throughput) of a TCP flow.
# It computes rate from time elapsed from the call to init-tcp-stats.
# Provided by Yong Xia
Agent/TCP instproc get-throughput-bps {} {
 $self instvar tcp_monitor_begin_time_ ndatabytes_
 set ns [Simulator instance]

 if { [ info exists tcp_monitor_begin_time_] } {
   set begin $tcp_monitor_begin_time_
 } else {
   set begin 0.0
 }

 set duration [expr [$ns now] - $begin]
 if { $duration == 0.0 } {
   return 0.0
 } else {
   return [expr $ndatabytes_ * 8.0 / $duration]
 }
}

# Returns the number of data packets trasmitted minus the number
# of retransmitted packets.
#
# OLD METHOD:
# Returns number of packets successfully acknowledged.
# This is computed by subtracting the acknowledgement 
# sequence number from the beginning acknowledgement sequence
# number and adding one. This works because sequence numbers
# in ns-2 are in units of packets rather than bytes.
Agent/TCP instproc get-useful-packets {} {

  $self instvar ndatapack_ nrexmitpack_ 

  return [expr $ndatapack_ - $nrexmitpack_]
  
  # OLD METHOD:
  #$self instvar ack_ tcp_monitor_begin_ack_
  #if { [ info exists tcp_monitor_begin_ack_ ] } {
  #  return [expr $ack_ - $tcp_monitor_begin_ack_ + 1]
  #} else {
  #  return [expr $ack_ + 1 ]
  #}  
}

# Return the number of data bytes transmitted minus the number
# of retranmitted bytes. Works even if TCP uses varying sizes of packets.
# This takes into account header overhead using
# "Agent/TCP set tcpip_base_hdr_size_" times the number of transmitted packets.
# tcpip_base_hdr_size_ is defined in ns-default.tcl and currently
# defaults to 40. This size is equal to the IPv4 header plus the TCP header.
# Thus we take into account both network and transport layer overhead
# due to headers. 
#
# OLD METHOD:
# Returns the number of bytes successfully acknowledged.
# Useful bytes in each packet is packet size minus header_size. By defualt 
# the header_size is 40 bytes. This does not take into account data-link 
# layer headers. The returned value is not an integer in order
# to deal with integer overflow on longer simulations. This also assumes
# that the agent used a constant packet size.
Agent/TCP instproc get-useful-bytes {} {
  $self instvar ndatabytes_ nrexmitbytes_

  return [expr ( $ndatabytes_ - $nrexmitbytes_ - \
    [$self get-useful-packets] * [Agent/TCP set tcpip_base_hdr_size_] )]

  # OLD METHOD:
  #$self instvar packetSize_ 
  #set n_packets [$self get-useful-packets]
  #expr $n_packets * ( $packetSize_ - [Agent/TCP set tcpip_base_hdr_size_] )
}


# Returns the rate of useful bits transmitted by the network.
# Uses get-useful-bytes to determine the total number of useful bits.
# The computes rate from time elapsed from the call to init-tcp-stats.
Agent/TCP instproc get-goodput-bps {} {
  $self instvar tcp_monitor_begin_time_
  set ns [Simulator instance]

  if { [ info exists tcp_monitor_begin_time_] } {
    set begin $tcp_monitor_begin_time_
  } else {
    set begin 0.0
  }

  set duration [expr [$ns now] - $begin]
  if { $duration == 0.0 } {
    return 0.0
  } else {
    return [expr [$self get-useful-bytes] * 8.0 / $duration]
  }
}

# Determines the goodput as a ratio of the number of unique bits transmitted
# per time over the bottleneck capacity. Bottleneck capacity must be in bps.
# It uses get-goodput-bps.
#
# Side note: goodput is usually defined
# as the number of useful bits that passed through the bottleneck
# over the bottleneck capacity. "acknolwedged bits" does not take into
# account any unacknowledged packets that have already passed through
# the bottleneck. This difference is negligible for any long simulation.
#
Agent/TCP instproc get-goodput { bw } {
  return [expr [$self get-goodput-bps] * 1.0 / $bw]
}

# Same as Agent/TCP except that we do not subtract the size of the TCP
# and IP headers from each packet. Why? Because the full TCP implementation
# already excludes the size of the headers form ndatabytes and nrexmitbytes.
Agent/TCP/FullTcp instproc get-useful-bytes {} {
  $self instvar ndatabytes_ nrexmitbytes_

  return [expr $ndatabytes_ - $nrexmitbytes_]
}

# calculates sum of the goodputs in bps across all TCP connections in the
# passed list.  
proc get-total-goodput { tcp } {
  set sum 0.0
  set length [llength $tcp]

  for { set i 0 } { $i < $length } { incr i } {
    set sum [expr $sum + [[lindex $tcp $i] get-goodput-bps]]
  }
  return $sum
}

# calculates mean goodput in bps across all TCP connections in the
# passed list.  
proc get-mean-goodput { tcp } {
  return [expr [get-total-goodput $tcp] / [llength $tcp]]
}

# calculates variance in goodput for the tcp sources in the passed list.
# Returned value is in units of bps^2
proc get-goodput-variance { tcp } {

  set sqsum 0.0
  set mean [get-mean-goodput $tcp]
  set length [llength $tcp]

  for { set i 0 } { $i < $length } { incr i } {
    set gput [[lindex $tcp $i] get-goodput-bps]
    set mean_diff [expr $gput - $mean]
    set sqsum [expr $sqsum + $mean_diff * $mean_diff]
  }
  return [expr $sqsum / $length]
}

# compute standard deviation for the tcp sources in the passed list.
# Returned value is in units of bps.
proc get-goodput-stddev { tcp } {
  return [expr sqrt([get-goodput-variance $tcp])]
}

#Added by Shri

#comput coeff. of variation std-dev/mean for the tcp sources in the passed list.# it  has no units
proc get-goodput-cov { tcp } {
  return [expr ([get-goodput-stddev $tcp] / [get-mean-goodput $tcp])]
}
#End Added by Shri


# compute sum number of data packets transmitted across all
# TCP sources in passed list. If the passed list is empty, this
# function generates a warning and returns NaN.
proc get-total-data-packets { tcp } {
  if { [llength $tcp] == 0 } {
    puts "WARNING! tcp-stats.tcl: get-total-data-packets passed an \
          empty list of tcp's"
    return NaN
  }
  set sum 0.0

  # number of data packets.
  for { set i 0 } { $i < [llength $tcp] } { incr i } {
    set sum [expr $sum + [[lindex $tcp $i] set ndatapack_]]
  }
  return $sum
}

# compute sum number of retransmitted packets across all TCP 
# sources in the passed list.
proc get-total-retransmitted-packets { tcp } {
  if { [llength $tcp] == 0 } {
    puts "WARNING! tcp-stats.tcl: get-total-retransmitted-packets passed an \
          empty list of tcp's"
    return NaN
  }
  set sum 0.0
  
  for { set i 0 } { $i < [llength $tcp] } { incr i } {
    set sum [expr $sum + [[lindex $tcp $i] set nrexmitpack_]]
  }
  return $sum
}

# compute sum number of retransmission timeouts across all TCP 
# sources in the passed list.
proc get-total-retransmission-timeouts { tcp } {
  if { [llength $tcp] == 0 } {
    puts "WARNING! tcp-stats.tcl: get-total-retransmission-timeouts passed an \
          empty list of tcp's"
    return NaN
  }
  set sum 0.0

  for { set i 0 } { $i < [llength $tcp] } { incr i } {
    set sum [expr $sum + [[lindex $tcp $i] set nrexmit_]]
  }
  return $sum
}
