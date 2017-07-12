# Copyright(c)2001 David Harrison. 
# Licensed according to the terms of the GNU Public License.
#
# This module contains the functionality for obtaining link statistics.
# The functionality is provided via the LinkStats object. We also
# provide FlowStats object that provides the same statistics as LinkStats
# but on a per-flow basis. 
#
# The LinkStats or FlowStats object can be attached to any link. In fact more 
# than one LinkStats or FlowStats object can be attached to a link 
# (e.g., if one particular LinkStats or FlowStats object resets the counters 
# frequently in order to obtain short-term averages, another LinkStats
# or FlowStats object on the same link can continue counting unmolested. In 
# another scenario, you might want one LinkStats object that starts after 
# some initial transients meanwhile another provides simulation-long 
# statistics).
#
# Unfortunatley some interference can exist between LinkStats objects
# used to obtain queue-delay information since queue delay
# is measured by timestamping packets. One object can overwrite the
# timestamp of another. Luckily, none of these functions will
# interfere with the DelayMonitor class (see delay-monitor.tcl)
# which does not use the timestamp field in each packet.
#
# LinkStats currently contains the following methods:
#
# get-utilization
# get-packet-utilization
# get-throughput
# get-power
# get-packet-arrivals
# get-byte-arrivals
# get-packet-drops
# get-byte-drops
# get-packet-departures
# get-byte-departures
# get-mean-queue-delay
# get-queue-delay-variance
# get-queue-delay-stddev
# get-mean-packet-queue-length
# get-mean-byte-queue-length
# get-max-packet-queue-length
# get max-byte-queue-length
# get-min-packet-queue-length
# get-min-byte-queue-length
# get-packets-above-thresh
# get-bytes-above-thresh
# get-convergence-time-on-queue-length
# get-percentile-packet-queue-length 
# get-percentile-byte-queue-length 
#
# Flow statistics:
# get-flow-packet-arrivals
# get-flow-byte-arrivals
# get-flow-packet-drops
# get-flow-byte-drops
# get-flow-packet-departures
# get-flow-byte-departures
# get-flow-mean-queue-delay
# get-flow-queue-delay-variance
# get-flow-queue-delay-stddev
# get-flow-mean-packet-queue-length
# get-flow-mean-byte-queue-length
# get-flow-max-packet-queue-length
# get-flow-max-byte-queue-length
# get-flow-min-packet-queue-length
# get-flow-min-byte-queue-length
#
# Convergence Times on Target Throughput:
#
# We use a separate tool (i.e., not the LinkStats class) for measuring 
# convergence times (i.e., time until throughput enters and stays within 
# a bounded region).  
#
# Our method returns the last time that the average aggregate
# throughput on a link passes outside a specified range.  This tool 
# requires the user to specify three parameters: upper throughput bound, 
# lower throughput bound, and an interval over which to average the 
# throughput.  This method is often difficult to parameterize
# and quite sensitive to oscillations.  We have yet to find a really
# good metric for convergence time.
#
# Look at the following procs:
#  init-convergence-time  initialize link.
#  get-convergence-time   obtain convergence time on the specified rate.
#   
#
# author: David Harrison

source $env(NS)/tcl/rpi/monitor.tcl
source $env(NS)/tcl/rpi/rpi-queue-monitor.tcl
source $env(NS)/tcl/rpi/rpi-flowmon.tcl
source $env(NS)/tcl/rpi/rate-monitor.tcl
source $env(NS)/tcl/rpi/file-tools.tcl

Class LinkStats

# initializes the counters for measuring number of bytes,
# number of packets, number of drops, link utilization, and queuing delay. 
LinkStats instproc init { n1 n2 { qmon "" } } {
  $self instvar qmon_ begin_recording_stats_ link_

  set ns [Simulator instance]
  set link_ [$ns link $n1 $n2]
  if { $qmon == "" } {
    set qmon_ [new QueueMonitor/ED/RPI]
  } else {
    set qmon_ $qmon
  }

  set qmon_ [install-monitor-with-integrators $n1 $n2 $qmon_]

  # sample queueing delays as well.
  set dsamp [new Samples]
  $qmon_ set-delay-samples $dsamp

  set begin_recording_stats_ [$ns now]
}


# Tells this LinkStats object that is should trace every kth sample to 
# a file.  This is needed for statistics that require access to 
# raw samples or a subset of raw samples from which to estimate
# statistics.  This is currently required for the following calls:
#
#   get-percentile-byte-queue-length
#   get-percentile-byte-packet-length
LinkStats instproc trace-every-kth { { k -1 } { trace_file_name "" } } {
  $self instvar trace_file_name_ channel_ qmon_
  global tmp_directory_

  if { ![info exists tmp_directory_] } {
    set tmp_directory_ [create-tmp-directory]
  }

  # create trace file
 
 if { $trace_file_name == "" } {
    set trace_file_name_ "$tmp_directory_/link_stats_$self.trace"
  } else {
    set trace_file_name_ $trace_file_name
  }
  set channel_ [open $trace_file_name_ "w"]

  $qmon_ trace $channel_
  $qmon_ set every_kth_ $k
}

# Same as trace-every-kth when trace-every-kth is passed no argument or passed
# -1.
LinkStats instproc trace {} {
  $self trace-every-kth
}

# Every interval t, a flag is set.  When this flag is set, the next arrival
# triggers an output of the queue length and the flag is unset.  This generates
# roughly one sample per interval so long as there is traffic.
LinkStats instproc trace-every-interval { t } {
  $self instvar qmon_ trace_file_name_ channel_
  global tmp_directory_

  if { ![info exists tmp_directory_] } {
    set tmp_directory_ [create-tmp-directory]
  }

  set trace_file_name_ "$tmp_directory_/link_stats_$self.trace"
  set channel_ [open $trace_file_name_ "w" ]

  $qmon_ trace $channel_
  $qmon_ set every_kth_ 0  ;# disables sampling every kth.
  $qmon_ set every_interval_ $t
  $qmon_ start   ;# starts the sample timer.
}


# Resets the link counters to zero. You can call this at any time in the 
# simulation. This is useful if you wish to record statistics over
# a sample interval or starting from a certain simulation time.
LinkStats instproc reset {} {
  $self instvar qmon_ begin_recording_stats_

  # reset queue monitor statistics
  $qmon_ set parrivals_ 0
  $qmon_ set barrivals_ 0
  $qmon_ set pdepartures_ 0
  $qmon_ set bdepartures_ 0
  $qmon_ set pdrops_ 0
  $qmon_ set bdrops_ 0
  $qmon_ set pmin_qlen_ 0   ;# minimum queue length so far.
  $qmon_ set pmax_qlen_ -1  ;# maximum queue length so far.
  $qmon_ set bmin_qlen_ 0   ;# minimum queue length in bytes so far.
  $qmon_ set bmax_qlen_ -1  ;# maximum queue length in bytes so far.

  # reset samples and integrators.
  set dsamp [$qmon_ get-delay-samples]
  $dsamp reset
  set integrator [$qmon_ get-bytes-integrator]
  $integrator reset
  set integrator [$qmon_ get-pkts-integrator]
  $integrator reset

  set begin_recording_stats_ [[Simulator instance] now]
}

# This returns the link utilization for the given link based on the
# accumulated number of byte departures from the queue. We use
# the bandwidth provided by the data link layer to the network layer
# (i.e., using the bandwidth retrieved from the link_ data member of
# SimpleLink). This does not take into account overhead in the 
# data link layer which would of course further lower the uhtilization
# of the capacity available to the datalink layer.
#
# If you call this functoin after a zero simulation time elapses
# after "new LinkStats," LinkStats reset, init-link-stats or
# reset-link-stats then an error is thrown.
#
LinkStats instproc get-utilization {} {
  $self instvar qmon_ link_ begin_recording_stats_
  set ns [Simulator instance]
  set datalink [$link_ link]

  # calculate the link utilization from the bandwidth of link_
  set bandwidth [$datalink set bandwidth_]
  set bdepartures [$qmon_ set bdepartures_]
  set interval [expr [$ns now] - $begin_recording_stats_]
  if { $interval == 0 } {
    error "
      The interval used for measuring utilization is zero. This occurs
      if you call get-utilization immediately after \[new LinkStats\],
      LinkStats reset, init-link-stats, or reset-link-stats without
      any simulation time passing."    
  } 
  set avg_rate [expr 8.0 * $bdepartures / $interval]
  set utilization [expr $avg_rate / $bandwidth]
  return $utilization
}

# get-utilization uses the number of bytes transmitted through
# a counter through the course of the simulation. This can easily overrun.
# As an alternative, one can periodically use reset-stats before
# an overrun is likely to occur and then average the utilizations
# over each interval.  Or one can estimate the utilization based
# on the number of packets. This function, get-packet-utilization,
# does the latter.
#
# If you call this function after a zero simulation time elapses
# after "new LinkStats," LinkStats reset, init-link-stats or
# reset-link-stats then an error is thrown.
#
LinkStats instproc get-packet-utilization {  mean_packet_size } {
  $self instvar qmon_ link_ begin_recording_stats_
  set ns [Simulator instance]

  # calculate the link utilization from the bandwidth of link_
  set datalink [$link_ link]
  set bandwidth [$datalink set bandwidth_]
  set pdepartures [$qmon_ set pdepartures_]
  set interval [expr [$ns now] - $begin_recording_stats_]
  if { $interval == 0 } {
    error "
      The interval used for measuring utilization is zero. This occurs
      if you call get-utilization immediately after \[new LinkStats\],
      LinkStats reset, init-link-stats, or reset-link-stats without
      any simulation time passing."    
  } 
  set avg_rate [expr 8.0 * $pdepartures * $mean_packet_size / $interval]
  set utilization [expr $avg_rate / $bandwidth]
  return $utilization
}

# Calculate throughput. (byte departures * 8 / time)
# If the elapsed time since the LinkStats object was last created,
# reset or initialized is zero then get-throughput throws an exception.
LinkStats instproc get-throughput { } {
  $self instvar begin_recording_stats_
  set elapsed_time [expr [[Simulator instance] now] - $begin_recording_stats_]
  if { $elapsed_time == 0 } {
    error "
      The interval used for measuring throughput is zero. This occurs
      if you call get-throughput immediately after \[new LinkStats\],
      LinkStats reset, init-link-stats, or reset-link-stats without
      any simulation time passing." 
  }
  set thruput [expr [$self get-byte-departures] * 8.0 / $elapsed_time]
  return $thruput
}

# returns network power = throughput / mean delay
# If no time elapsed since the LinkStats object was instantiated
# or last reset then this proc throws an error.
# If there were no packets then mean queueing delay is undefined and
# this function returns NaN meaning "Not a Number."
#
LinkStats instproc get-power { } {
  set thruput [$self get-throughput]
  set qdelay [$self get-mean-queue-delay]
  if { [string compare $qdelay "NaN"] == 0 || $qdelay == 0 } { 
    return "NaN"
  }
  return [expr $thruput / $qdelay]
}

# Returns the number of packets that have arrived at the head of the
# link where the LinkStats object has been installed.  This includes
# packets that are eventually dropped by a queue or other component in
# the link.  
LinkStats instproc get-packet-arrivals {  } {
  $self instvar qmon_
  return [$qmon_ set parrivals_]
}

# Returns the number of bytes that have arrived at the head of the
# link where the LinkStats object has been installed.  This includes
# bytes from packets that are eventually dropped by a queue or other
# component in the link.  
LinkStats instproc get-byte-arrivals {  } {
  $self instvar qmon_
  return [$qmon_ set barrivals_]
}

# Return the number of drops on the link from nodes n1 to n2.
LinkStats instproc get-packet-drops {  } {
  $self instvar qmon_
  return [$qmon_ set pdrops_] 
}

LinkStats instproc get-byte-drops {  } {
  $self instvar qmon_
  return [$qmon_ set bdrops_] 
}


# Returns the number of packet departures from the link's queue.
# This does not refer to the number of departures from the
# link itself.
LinkStats instproc get-packet-departures {  } {
  $self instvar qmon_
  return [$qmon_ set pdepartures_]
}

# Returns the number of byte departures from the link's queue.
# This does not refer to the number of departures from the
# link itself.
LinkStats instproc get-byte-departures {  } {
  $self instvar qmon_
  return [$qmon_ set bdepartures_]
}


# Returns the mean queueing delay experienced by packets on a given link.
# If no packets have been received then mean queueing delay 
# returns 0.
LinkStats instproc get-mean-queue-delay {  } {
  $self instvar qmon_

  set dsamp [$qmon_ get-delay-samples]
  if { $dsamp == "" } { 
    puts "ERROR! LinkStats get-mean-queue-delay: dsamp is NULL."
  }
  if { [$dsamp cnt] > 0 } {
    return [$dsamp mean]
  } else {
    return NaN
  }
}

# Returns the variance in the queueing delay experienced by packets
# on a given link.
LinkStats instproc get-queue-delay-variance {  } {
  $self instvar qmon_

  set dsamp [$qmon_ get-delay-samples]
  if { [$dsamp cnt] > 0 } {
    set variance [$dsamp variance]

    # The variance can be slightly negative due to round-off error.
    # Since we know that variance cannot be negative, I simply set it to zero.
    # This also prevents get-queue-delay-stddev forom generating a exception
    # resulting from trying to take the square root of a negative number.
    if { $variance < 0.0 } {
      set variance 0.0
    }
    return $variance
  } else {
    return NaN
  }
}
   
# Convenience function for returning the standard deviation
# by taking the square root of the variance returned from
# get-queue-delay-variance.
LinkStats instproc get-queue-delay-stddev {  } {
  set variance [$self get-queue-delay-variance]
  if { [string compare $variance NaN] == 0 } {
    return NaN
  } else {
    return [expr sqrt($variance)]
  }
}

# Returns the mean queue length in packets. The
# mean is time-based in the sense that the sum
# reflects not only each queue length but the time
# that each queue length was maintained. The mean
# is then the sum divided by the time elapsed since
# the simulation began recording stats.
#
# Uses integrators to obtain the mean queue length 
LinkStats instproc get-mean-packet-queue-length {} {
  $self instvar qmon_ begin_recording_stats_
  set now [[Simulator instance] now]
  set qPktsMonitor_ [$qmon_ get-pkts-integrator]

  $qPktsMonitor_ newpoint $now [$qPktsMonitor_ set lasty_]
  set psum [$qPktsMonitor_ set sum_]

  set dur [expr $now - $begin_recording_stats_]
  if { $dur != 0 } {
    return [expr $psum / $dur]
  } else {
    return 0
  }
}

# Returns the mean queue length in bytes. As with
# get-mean-packet-queue-length, get-mean-byte-queue-length
# is time-based in the sense that the sum reflects
# not only each queue length but also the time that
# each queue length was maintained. The mean is then
# the sum divided by the time elapsed since the
# simulation began recording stats.
#
# Note: get-mean-queue-delay is not simply 
# get-mean-queue-length divided by the capacity.
# Queueing delay is only affected by the number
# of bytes in the queue when a packet arrives.
# Idle periods will not affect the mean queueing delay.
# One would expect that get-mean-byte-queue-length
# and get-mean-queue-delay would be significantly 
# different when traffic is bursty.
LinkStats instproc get-mean-byte-queue-length {} {
  $self instvar qmon_ begin_recording_stats_
  set now [[Simulator instance] now]
  set qBytesMonitor_ [$qmon_ get-bytes-integrator]

  $qBytesMonitor_ newpoint $now [$qBytesMonitor_ set lasty_]
  set bsum [$qBytesMonitor_ set sum_]

  set dur [expr $now - $begin_recording_stats_]
  if { $dur != 0 } {
    return [expr $bsum / $dur]
  } else {
    return 0
  }
}

# Return sthe maximum instantaneous queue length in packets seen since
# the LinkStats object was instantiated or last reset. If no packets
# have traversed the link during this time then this proc returns 0.
LinkStats instproc get-max-packet-queue-length {} {
  $self instvar qmon_
  if { [$qmon_ set pmax_qlen_] < 0 } {
    return 0
  }
  return [$qmon_ set pmax_qlen_]
}

# Return the maximum queue length in bytes seen since the LinkStats
# object was instantiated or last reset. If no packets have traversed
# the link during this time then this proc returns 0.
LinkStats instproc get-max-byte-queue-length {} {
  $self instvar qmon_
  if { [$qmon_ set bmax_qlen_] < 0 } {
    return 0
  }
  return [$qmon_ set bmax_qlen_]
}

# Returns the minimum queue length in packets seen since the LinkStats
# object was instantiated or last reset. If no packets have traversed
# the link during this time then this proc returns 0. 
LinkStats instproc get-min-packet-queue-length {} {
  $self instvar qmon_
  if { [$qmon_ set pmin_qlen_] < 0 } {
    return 0
  }
  return [$qmon_ set pmin_qlen_]
}

# Returns the minimum queue length in bytes seen since the LinkStats
# object was instantiated or last reset. If no packets have traversed
# the link during this time then this proc returns 0. 
LinkStats instproc get-min-byte-queue-length {} {
  $self instvar qmon_
  if { [$qmon_ set bmin_qlen_] < 0 } {
    return 0
  }
  return [$qmon_ set bmin_qlen_]
}

# returns the number of packets that arrive at a queue with length
# greater than bmax_qlen_thresh_.
LinkStats instproc get-packets-above-thresh {} {
  $self instvar qmon_
  return [$qmon_ set pabove_thresh_]
}

# returns the number of bytes that arrive at a queue with length
# greater than bmax_qlen_thresh_.
LinkStats instproc get-bytes-above-thresh {} {
  $self instvar qmon_
  return [$qmon_ set babove_thresh_]
}

# Finds the queue length such that percentile p \in [0.0,100.0]
# packets arrive at a queue less than length q measured in packets,
# where p is the percentile argument and q is returned.
LinkStats instproc get-percentile-packet-queue-length { p } {
  $self instvar qmon_ channel_ trace_file_name_
  
  if { ![info exists channel_] } { 
    error "To use get-percentile-packet-queue-length you must call 
      LinkStats instproc trace-every-kth { { k -1 } }
      at the beginning of the simulation. If k is omitted then 
      every sample is dumped to the passed TCL channel.  If no 
      channel is passed then a TCL channel is created for the purpose."
  }
  flush $channel_

  return [$qmon_ percentile-in-packets $p $trace_file_name_]
}

# Finds the queue length such that percentile p \in [0.0,100.0]
# packets arrive at a queue less than length q measured in bytes,
# where p is the percentile argument and q is returned.
LinkStats instproc get-percentile-byte-queue-length { p } {
  $self instvar qmon_ channel_ trace_file_name_
  
  if { ![info exists channel_] } { 
    error "To use get-percentile-byte-queue-length you must call 
      LinkStats instproc trace-every-kth { { k -1 } }
      at the beginning of the simulation. If k is omitted then 
      every sample is dumped to the passed TCL channel.  If no 
      channel is passed then a TCL channel is created for the purpose."
  }
  flush $channel_

  return [$qmon_ percentile-in-bytes $p $trace_file_name_]
}


# sets the threshold use in determining the convergence time
# on low queues. The thresh is specified in bytes. 
# 
# Convergence time for queue lengths is measured as the 
# last time that the instantaneous queue length exceeds a threshold.
# This convergence time metric is sensitive to burstiness.
LinkStats instproc init-convergence-time-on-queue-length { thresh } {
  $self instvar qmon_ start_time_
  $qmon_ set bmax_qlen_thresh_ $thresh
  set start_time_ [[Simulator instance] now]
}

# Returns the last time that the instantaneous queue length exceeded
# the threshold passed to init-convergence-time-on-queue-length.
# The returned time is relative to the time that 
# init-convergence-time-on-queue-length was called.
LinkStats instproc get-convergence-time-on-queue-length {} {
  $self instvar qmon_ start_time_
  set convergence_time [max 0.0 \
    [expr [$qmon_ set time_qlen_exceeded_thresh_] - $start_time_]]
  return $convergence_time
}

# CONVENIENCE FUNCTIONS 
# I included these mainly to allow me to easily port older code.
# Do not use them on a link where you want to install more than
# one LinkStats object.

proc init-link-stats { n1 n2 } {
  global link_stats
  if { ![info exists link_stats($n1:$n2)] } {
    set link_stats($n1:$n2) [new LinkStats $n1 $n2]
  }
}

# return the LinkStats object between n1 and n2. This only 
# returns the LinkStats object created with a call to init-link-stats.
# It will not return any other LinkStats objects you might have attached
# to the link spanning from n1 to n2.
proc get-link-stats { n1 n2 } {
  global link_stats
  if { ![info exists link_stats($n1:$n2)] } {
    error "Link stats for link from node $n1 to node $n2 does not exist. \
Did you forget to call init-link-stats on this link?"
  }
  return $link_stats($n1:$n2)
}
proc reset-link-stats { n1 n2 } {

  [get-link-stats $n1 $n2] reset
}
proc get-link-utilization { n1 n2 } {

  return [[get-link-stats $n1 $n2] get-utilization]
}
proc get-link-packet-utilization { n1 n2 mean_packet_size } {

  return [[get-link-stats $n1 $n2] get-packet-utilization $mean_packet_size]
}
proc get-link-throughput { n1 n2 } {

  return [[get-link-stats $n1 $n2] get-throughput]
}
proc get-link-power { n1 n2 } {

  return [[get-link-stats $n1 $n2] get-power]
}
proc get-link-packet-arrivals { n1 n2 } {

  return [[get-link-stats $n1 $n2] get-packet-arrivals]
}
proc get-link-byte-arrivals { n1 n2 } {

  return [[get-link-stats $n1 $n2] get-byte-arrivals]
}
proc get-link-packet-drops { n1 n2 } {

  return [[get-link-stats $n1 $n2] get-packet-drops]
}
proc get-link-byte-drops { n1 n2 } {

  return [[get-link-stats $n1 $n2] get-byte-drops]
}
proc get-link-packet-departures { n1 n2 } {
  return [[get-link-stats $n1 $n2] get-packet-departures]
}
proc get-link-byte-departures { n1 n2 } {
  return [[get-link-stats $n1 $n2] get-byte-departures]
}
proc get-mean-queue-delay { n1 n2 } {
  return [[get-link-stats $n1 $n2] get-mean-queue-delay]
}
proc get-queue-delay-variance { n1 n2 } {
  return [[get-link-stats $n1 $n2] get-mean-queue-delay-variance]
}
proc get-queue-delay-stddev { n1 n2 } {
  return [[get-link-stats $n1 $n2] get-queue-delay-stddev]
}
proc get-mean-packet-queue-length { n1 n2 } {
  return [[get-link-stats $n1 $n2] get-mean-packet-queue-length]
}
proc get-mean-byte-queue-length { n1 n2 } {
  return [[get-link-stats $n1 $n2] get-mean-byte-queue-length]
}
proc get-max-packet-queue-length { n1 n2 } {
  return [[get-link-stats $n1 $n2] get-max-packet-queue-length]
}
proc get-max-byte-queue-length { n1 n2 } {
  return [[get-link-stats $n1 $n2] get-max-byte-queue-length]
}
proc get-min-packet-queue-length { n1 n2 } {
  return [[get-link-stats $n1 $n2] get-min-packet-queue-length]
}
proc get-min-byte-queue-length { n1 n2 } {
  return [[get-link-stats $n1 $n2] get-min-byte-queue-length]
}


# FlowStats class not only performs link (i.e., aggregate) statistics but
# also gathers per-flow statistics.
Class FlowStats -superclass LinkStats
FlowStats instproc init { n1 n2 } {
  set ns [Simulator instance]
  set flowmon [$ns make-rpi-flowmon Fid]
  $self next $n1 $n2 $flowmon
}

# Reset all per-flow and aggregate statistics.
FlowStats instproc reset {} {
  $self next

  # reset all flows.
  set flowlist [$self get-flows]

  for { set i 0 } { $i < [llength $flowlist] } { incr i } {
    set flow [lindex $flowlist $i]

puts "FlowStats reset: resetting flow $i"

    # reset flow monitor statistics
    $flow set parrivals_ 0
    $flow set barrivals_ 0
    $flow set pdepartures_ 0
    $flow set bdepartures_ 0
    $flow set pdrops_ 0
    $flow set bdrops_ 0
    $flow set pmin_qlen_ 0     ;# minimum queue length so far.
    $flow set pmax_qlen_ -1    ;# maximum queue length so far.
    $flow set bmin_qlen_ 0     ;# minimum queue length in bytes so far.
    $flow set bmax_qlen_ -1    ;# maximum queue length in bytes so far.
    $flow set pabove_thresh_ 0 ;# num pkts arrive to q > bmax_qlen_thresh_
    $flow set babove_thresh_ 0 ;# num bytes arrive to q > bmax_qlen_thresh_

    # reset samples and integrators.
    set dsamp [$flow get-delay-samples]
    $dsamp reset
    set integrator [$flow get-bytes-integrator]
    $integrator reset
    set integrator [$flow get-pkts-integrator]
    $integrator reset
  }
}

# Retrieve the list of flow objects for this link.
FlowStats instproc get-flows {} {
  $self instvar qmon_
  return [$qmon_ flows]
}

# Retrieve the FlowStats object for the specified fid.
FlowStats instproc get-flow { fid } {
  $self instvar qmon_
  set flow_list [$qmon_ flows]
  set len [llength $flow_list]
  for { set i 0 } { $i < $len } { incr i } {
    set flow [lindex $flow_list $i]
    if { [$flow set flowid_] == $fid } {
      return $flow
    }
  }
  return ""
}

# Obtains the throughput in bps for the flow passing through
# the FlowStats object. If the FlowStats object has not seen
# such a flow this member function returns NaN.
FlowStats instproc get-flow-throughput { fid } {
  $self instvar begin_recording_stats_

  set elapsed_time [expr [[Simulator instance] now] - $begin_recording_stats_]
  set arrivals [$self get-flow-byte-departures $fid]
    if { $arrivals == NaN } {
    return NaN
    }
  set thruput [expr $arrivals * 8.0 / $elapsed_time]
  return $thruput
}

# get-flow-packet-arrivals returns the number of packet arrivals for
# the flow with the given fid. If no such flow has passed through the
# bottleneck then this function returns NaN.
FlowStats instproc get-flow-packet-arrivals { fid } {
  set flow [$self get-flow $fid]
  if { $flow != "" } {
    return [$flow set parrivals_]
  } 
  return NaN
}

# get-flow-byte-arrivals returns the number of byte arrivals for the
# flow with the given fid. If no such flow has passed through the
# bottleneck then this function returns NaN.
FlowStats instproc get-flow-byte-arrivals { fid } {
  set flow [$self get-flow $fid]
  if { $flow != "" } {
    return [$flow set barrivals_]
  } 
  return NaN
}


# Returns the number of packet drops experienced by the specified
# flow.  If no such flow has been seen by the FlowStats object,
# get-flow-packet-drops returns NaN.
FlowStats instproc get-flow-packet-drops { fid } {
  set flow [$self get-flow $fid]
  if { $flow != "" } {
    return [$flow set pdrops_]
  } 
  return NaN
}

# Returns the number of byte drops experienced by the specified flow.
# If no such flow has been seen by the FlowStats object,
# get-flow-byte-drops returns NaN.
FlowStats instproc get-flow-byte-drops { fid } {
  set flow [$self get-flow $fid]
  if { $flow != "" } {
    return [$flow set bdrops_]
  } 
  return NaN
}

# Returns this flow's packet departures from the link monitored
# by the FlowStats object. 
FlowStats instproc get-flow-packet-departures { fid } {
  set flow [$self get-flow $fid]
  if { $flow != "" } {
    return [$flow set pdepartures_]
  } 
  return NaN
}


FlowStats instproc get-flow-byte-departures { fid } {
  set flow [$self get-flow $fid]
  if { $flow != "" } {
    return [$flow set bdepartures_]
  } 
  return NaN
}


FlowStats instproc get-flow-mean-queue-delay { fid } {
  set flow [$self get-flow $fid]
  if { $flow == "" } {
    put "ERROR! get-flow-queue-delay-variance: unknown flow $fid"
  }
  set dsamp [$flow get-delay-samples]
  if { $dsamp == "" } { 
    puts "ERROR! get-flow-mean-queue-delay: dsamp is NULL."
  }
  if { [$dsamp cnt] > 0 } {
    return [$dsamp mean]
  } else {
    return NaN
  }
}


FlowStats instproc get-flow-queue-delay-variance { fid } {
  set flow [$self get-flow $fid]
  if { $flow == "" } {
    put "ERROR! get-flow-queue-delay-variance: unknown flow $fid"
  }
  set dsamp [$flow get-delay-samples]
  if { $dsamp == "" } { 
    puts "ERROR! get-flow-queue-delay-variance: dsamp is NULL."
  }
  if { [$dsamp cnt] > 0 } {
    return [$dsamp variance]
  } else {
    return NaN
  }
}

# get-queue-delay-stddev
FlowStats instproc get-flow-queue-delay-stddev { fid } {
  set variance [$self get-flow-queue-delay-variance $fid]
  if { $variance == NaN } {
    return NaN
  } else {
    return [expr sqrt($variance)]
  }
}

# Returns specified flow's mean contribution to the queue length
# on this link. If there is per-flow queueing then this is
# literally the mean queue length in packets for the
# the per-flow queue. If there is no flow entry for fid (i.e.,
# the flow never sent a packet) then this returns NaN.
FlowStats instproc get-flow-mean-packet-queue-length { fid } {
  $self instvar begin_recording_stats_
  set flow [$self get-flow $fid]
  if { $flow == "" } {
    return NaN 
  }
  set now [[Simulator instance] now]
  set qPktsMonitor_ [$flow get-pkts-integrator]

  $qPktsMonitor_ newpoint $now [$qPktsMonitor_ set lasty_]
  set psum [$qPktsMonitor_ set sum_]

  set dur [expr $now - $begin_recording_stats_]
  if { $dur != 0 } {
    return [expr $psum / $dur]
  } else {
    return 0
  }
}

# Returns specified flow's mean contribution to the queue length
# on this link. If there is per-flow queueing then this is
# literally the mean queue length in bytes for the
# the per-flow queue. If there is no flow entry for fid (i.e.,
# the flow never sent a packet) then this returns NaN.
FlowStats instproc get-flow-mean-byte-queue-length { fid } {
  $self instvar begin_recording_stats_
  set flow [$self get-flow $fid]
  if { $flow == "" } {
    return NaN 
  }
  set now [[Simulator instance] now]
  set qBytesMonitor_ [$flow get-bytes-integrator]

  $qBytesMonitor_ newpoint $now [$qBytesMonitor_ set lasty_]
  set bsum [$qBytesMonitor_ set sum_]

  set dur [expr $now - $begin_recording_stats_]
  if { $dur != 0 } {
    return [expr $bsum / $dur]
  } else {
    return 0
  }
}

# Returns specified flow's max contribution to the queue length
# on this link. If there is per-flow queueing then this is
# literally the maximum queue length in packets for the
# the per-flow queue. If there is no flow entry for fid (i.e.,
# the flow never sent a packet) then this returns NaN.
FlowStats instproc get-flow-max-packet-queue-length { fid } {
  set flow [$self get-flow $fid]
  if { $flow == "" } {
    return NaN 
  }
  return [$flow set pmax_qlen_]
}

# Returns specified flow's max contribution to the queue length
# on this link. If there is per-flow queueing then this is
# literally the maximum queue length in bytes for the
# the per-flow queue. If there is no flow entry for fid (i.e.,
# the flow never sent a packet) then this returns NaN.
FlowStats instproc get-flow-max-byte-queue-length { fid } {
  set flow [$self get-flow $fid]
  if { $flow == "" } {
    return NaN 
  }
  return [$flow set bmax_qlen_]
}

# Returns specified flow's min contribution to the queue length
# on this link. If there is per-flow queueing then this is
# literally the minimum queue length in packets for the
# the per-flow queue. If there is no flow entry for fid (i.e.,
# the flow never sent a packet) then this returns NaN.
FlowStats instproc get-flow-min-packet-queue-length { fid } {
  set flow [$self get-flow $fid]
  if { $flow == "" } {
    return NaN 
  }
  return [$flow set pmin_qlen_]
}

# Returns specified flow's min contribution to the queue length
# on this link. If there is per-flow queueing then this is
# literally the minimum queue length in bytes for the
# the per-flow queue. If there is no flow entry for fid (i.e.,
# the flow never sent a packet) then this returns NaN.
FlowStats instproc get-flow-min-byte-queue-length { fid } {
  set flow [$self get-flow $fid]
  if { $flow == "" } {
    return NaN 
  }
  return [$flow set bmin_qlen_]
}

###
# CONVENIENCE FUNCTIONS FOR FLOW STATISTICS
#
# Use these only if you want to install 1 FlowStats object on a link.
###

# Call this if you wish to record per-flow statistics as well as link
# statistics. You can call both init-link-stats and init-flow-stats
# but you will end up installing both a LinkStats and FlowStats object.
# The only result is that the simulation will run slightly slower and 
# you will be keeping the same link statistics in two objects rather than one.
proc init-flow-stats { n1 n2 } {
  global flow_mon link_stats
  if { ![info exists flow_mon($n1:$n2)] } {
    set flow_stats [new FlowStats $n1 $n2]
    if { ![info exists link_stats($n1:$n2)] } {
      set link_stats($n1:$n2) $flow_stats
    }
    set flow_mon($n1:$n2) $flow_stats
  }
}

# initialize per-flow statistics gathering on the specified link.
# Flows are identified by fid.
#proc init-flow-stats {n1 n2} {
# global flow_mon
#  set ns [Simulator instance]
#  set slink [$ns link $n1 $n2]
#  set flow_mon($n1:$n2) [$ns make-rpi-flowmon Fid]
#  $ns attach-fmon $slink $flow_mon($n1:$n2)
#}

proc reset-flow-stats { n1 n2 } {
  global flow_mon
  $flow_mon($n1:$n2) reset
}

proc get-flows { n1 n2 } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flows]
}

# Returns a Flow object for the specified flow-id. 
# If no such flow object exists then it returns ""
proc get-flow { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow $fid]
}

proc get-flow-throughput { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-throughput $fid]
}

proc get-flow-packet-arrivals { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-packet-arrivals $fid]
}

proc get-flow-byte-arrivals { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-byte-arrivals $fid]
}  

proc get-flow-packet-drops { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-byte-drops $fid]
}

proc get-flow-byte-drops { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-byte-drops $fid]
}

proc get-flow-packet-departures { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-packet-depatures $fid]
}

proc get-flow-byte-departures { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-byte-depatures $fid]
}

proc get-flow-mean-queue-delay { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-mean-queue-delay $fid]
}

proc get-flow-queue-delay-variance { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-delay-variance $fid]
}

# get-mean-byte-queue-length
proc get-flow-mean-byte-queue-length { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-mean-byte-queue-length $fid]
}

# get-max-packet-queue-length
proc get-flow-max-packet-queue-length { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-max-packet-queue-length $fid]
}

# get max-byte-queue-length
proc get-flow-max-byte-queue-length { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-max-byte-queue-length $fid]
}

# get-min-packet-queue-length. 
proc get-flow-min-packet-queue-length { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-min-packet-queue-length $fid]
}

# get-min-byte-queue-length
proc get-flow-min-byte-queue-length { n1 n2 fid } {
  global flow_mon
  return [$flow_mon($n1:$n2) get-flow-min-byte-queue-length $fid]
}


# Convergence on full utilization is measured as the
# last time t that the utilization measured in interval
# [t-tau,t] is below a lower bound. This metric has two
# parameters: a lower bound and tau="interval length."
#
# Installs a LinkStats object on the link. The link stats object
# is periodically queried to determine the number of bytes that
# have departed from the link. The utilization is computed
# as the number of bytes that departed over the last averaging
# interval divided by the link's capacity.
#
proc init-convergence-time-on-utilization \
  { n1 n2 lower_bound { interval 0.25 } } \
{
  global convergence_lstats 
  set ns [Simulator instance]

  if { ![info exists convergence_lstats($n1:$n2)] } {
    set convergence_lstats($n1:$n2) [new LinkStats $n1 $n2]

    #puts "Scheduling call for \"convergence-on-utilization\" for \
    #  [expr [$ns now] + $interval]"

    $ns at [expr [$ns now] + $interval] \
      "convergence-on-utilization-monitor $n1 $n2"
  } 
  $convergence_lstats($n1:$n2) set last_time_ 0.0
  $convergence_lstats($n1:$n2) set lower_bound_ $lower_bound
  $convergence_lstats($n1:$n2) set interval_ $interval
}

proc convergence-on-utilization-monitor { n1 n2 } {
  global convergence_lstats
  $convergence_lstats($n1:$n2) instvar last_time_ lower_bound_ interval_

  set ns [Simulator instance]

  #puts "convergence-on-utilization-monitor called at [$ns now]"

  set util [$convergence_lstats($n1:$n2) get-utilization]
  $convergence_lstats($n1:$n2) reset

  if { $util < $lower_bound_ } {
    set last_time_ [$ns now]
  }

  $ns at [expr [$ns now] + $interval_] \
    "convergence-on-utilization-monitor $n1 $n2"
}

proc get-convergence-time-on-utilization { n1 n2 } {
  global convergence_lstats
  return [$convergence_lstats($n1:$n2) set last_time_]
}

# Remember the time when the rate measured over the specified interval 
# length moves within bounds and stays there. This is approximated by
# measuring the last time the rate was out of bounds. If called on a link
# more than one time, the second and all subsequent times simply
# reconfigure the already installed rate monitor to use the newly
# specified lower bound, upper bound, and interval.
#
# USAGE NOTE: If you are going to use this function then it is important
# that you call it before the simulation begins. If you want to 
# to change the bounds one or more times during the simulation
# then you can call init-convergence-time again after the simulation 
# begins so long as it's first call occurs before the simulation. This
# requirement arises because I had trouble getting the rate monitor
# to install correctly after the simulation had begun. For some
# reason rate monitor receives no packets unless it is installed
# before calling [$ns run]. 
#
# n1 n2          monitor arrival rate at head of the link spanning n1 and n2
# lower_bound upper_bound   bounds of the range defining convergence (in bps).
# interval       time between rate measurements.
proc init-convergence-time { n1 n2 lower_bound \
                             { upper_bound -1 } { interval 0.01 } } {
  set ns [Simulator instance]

  # access the head of the link between n1 and n2.
  set link [$ns link $n1 $n2]
  $link instvar head_  
  $link instvar rate_monitor_

  if { ![info exists rate_monitor_] } {

    # create and configure rate monitor.
    # note that rate_monitor_ is a member of the link object.
    set rate_monitor_ [new RateMonitor]
    $rate_monitor_ set interval_ $interval

    # insert rate monitor in link.
    $rate_monitor_ target $head_
    set head_ $rate_monitor_
  }

  # configure the rate monitor object.
  $rate_monitor_ set lower_bound_ $lower_bound
  $rate_monitor_ set upper_bound_ $upper_bound
  $rate_monitor_ reset
  $rate_monitor_ set start_time_ [$ns now]
}

# Returns the convergence time measured on data passing through the link
# relative to the time that init-convergence-time was called.
proc get-convergence-time { n1 n2 } {

  # access the link.
  set ns [Simulator instance]
  set link [$ns link $n1 $n2]

  # access the rate monitor.
  set rate_monitor [$link set rate_monitor_]
  #puts "proc get-convergence-time: [$rate_monitor set convergence_time_]"

  # determine the convergence time relative to the start time.
  set convergence_time [max 0.0 [expr [$rate_monitor set convergence_time_] - \
    [$rate_monitor set start_time_]]]

  # extract the convergence time from the rate monitor and return it.
  return $convergence_time
}

# First call init-link-stats. This function tells the LinkStats
# object associated with link $n1 $n2 to remember the last time that
# the queue length exceeded the specified threshold. "thresh"
# is specified in units of bytes.
proc init-convergence-time-on-queue-length { n1 n2 thresh } {
  [get-link-stats $n1 $n2] init-convergence-time-on-queue-length $thresh
}

# Returns the last time that the queue length exceeded the threshold
# specified in the call to init-convergence-time-queue-length
# The returned time is with respect to the time that 
# init-convergence-time-on-queue-length is called.
proc get-convergence-time-on-queue-length { n1 n2 } {
  return [[get-link-stats $n1 $n2] get-convergence-time-on-queue-length]
}



