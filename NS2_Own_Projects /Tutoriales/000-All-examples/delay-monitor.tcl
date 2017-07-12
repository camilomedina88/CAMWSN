# Copyright(c)2001 David Harrison. 
# Licensed according to the terms of the GNU Public License.

#
# delay-monitor.tcl
#
# Author: D. Harrison
#
# The delay monitor measures the delay for packets that enter 
# through link (enter_n0,enter_n1) and leave through link 
# (exit_n0,exit_n1). Thus one can measure edge-to-edge delay, end-to-end
# delay, and bottleneck delay all on the same packet without interference
# between the measurements. Note that the DelayMonitor is installed at the
# head of the entering link and at the tail (after the ttl object) on the
# exiting link, thus the delay in the exiting link is included in the delay. 
# 
#
# Gang Wang and Yong Xia added the following:
# get-interval-loss:          trace packet loss during specified intervals
# get-interval-std-deviation: trace packet delay standard deviation during intervals
# get-total-loss:             return overall packet loss 
# set-delay-threshold:        set delay thresholds. When packet delay is lower than delay_threshold_low, it is considered successuflly received. When higher than delay_threshold, it is considered lost. Between them will be judged using a uniform probability distribution.

DelayMonitorIn set debug_ false
DelayMonitorOut set debug_ false
DelayMonitorIn set garbage_collection_interval_ 10s
DelayMonitorIn set delay_threshold_low 0.12s
DelayMonitorIn set delay_threshold_high 0.20s

Class DelayMonitor 

# Installs monitors in the entry and exit links. 
DelayMonitor instproc init { enter_n0 enter_n1 exit_n0 exit_n1 } \
{
  $self instvar delay_monitor_out_ delay_monitor_in_

  set ns [Simulator instance]
  set enter_link [$ns link $enter_n0 $enter_n1]
  if { $enter_link == "" } {
    error "DelayMonitor::init: the link from enter_n0=$enter_n0 and \
           enter_n1=$enter_n1 was not found."
  }
  set exit_link [$ns link $exit_n0 $exit_n1]
  if { $exit_link == "" } {
    error "DelayMonitor::init: the link from exit_n0=$exit_n0 and \
           exit_n1=$exit_n1 was not found."
  }

  # install DelayMonitorIn in enter link.
  set delay_monitor_in_ [new DelayMonitorIn]
  $enter_link instvar head_
  $delay_monitor_in_ target $head_
  set head_ $delay_monitor_in_

  # install DelayMonitorOut in exit link.
  set delay_monitor_out_ [new DelayMonitorOut]
  set ttl [$exit_link set ttl_]
  $delay_monitor_out_ target [$ttl target]
  $ttl target $delay_monitor_out_

  # connect DelayMonitorIn to DelayMonitorOut so DelayMonitorOut can
  # retrieve timestamps.
  $delay_monitor_out_ attach $delay_monitor_in_  
}

# sets the trace file used by the exit end of the delay monitor.
# You can call set-trace with a TCL channel at any time to start
# tracing to a file and call set-no-trace or "set-trace 0"
# at any time to stop tracing to a file. The output file
# has format:
#    <time> <delay>
# where "time" is the arrival time of the packet at the
# "out" end of the delay monitor and "delay" is the difference
# between "time" and the timestamp in the sampled packet.
# Both time and delay are in seconds. E.g.,
#    0.0056 0.02
#    0.0061 0.023
#
DelayMonitor instproc set-trace { trace_file } {
  $self instvar delay_monitor_out_
  $delay_monitor_out_ trace $trace_file
}
DelayMonitor instproc set-no-trace {} {
  $self set-trace 0
}

# Returns the number of entries currently in the time-map.  In other words
# this displays the number of packets that have been seen by the
# DelayMonitorIn object but not yet by the DelayMonitorOut object.  This
# reflects packets in transit or packets that have been lost.
DelayMonitor instproc get-time-map-size {} {
  $self instvar delay_monitor_in_
  return [$delay_monitor_in_ get-time-map-size]
}

DelayMonitor instproc get-interval-loss {} {
  $self instvar delay_monitor_in_
  return [$delay_monitor_in_ get-interval-loss]
}

DelayMonitor instproc get-total-loss {} {
  $self instvar delay_monitor_in_
  return [$delay_monitor_in_ get-total-loss]
}

DelayMonitor instproc get-total-loss-packet {} {
  $self instvar delay_monitor_in_
  return [$delay_monitor_in_ get-total-loss-packet]
}

DelayMonitor instproc set-delay-threshold {t_low t_high} {
  $self instvar delay_monitor_in_
  $delay_monitor_in_ set delay_threshold_low $t_low
  $delay_monitor_in_ set delay_threshold_high $t_high
}


DelayMonitor instproc get-mean-delay {} {
  $self instvar delay_monitor_out_
  return [$delay_monitor_out_ get-mean-delay]
}

DelayMonitor instproc get-delay-variance {} {
  $self instvar delay_monitor_out_
  return [$delay_monitor_out_ get-delay-variance]
}

DelayMonitor instproc get-second-moment {} {
  $self instvar delay_monitor_out_
  return [$delay_monitor_out_ get-second-moment]
}

DelayMonitor instproc get-standard-deviation {} {
  $self instvar delay_monitor_out_
  return [expr sqrt( [$delay_monitor_out_ get-delay-variance] ) ]
}

DelayMonitor instproc get-coefficient-of-variation {} {
  $self instvar delay_monitor_out_
  set variance [$delay_monitor_out_ get-delay-variance]
  return [expr 1.0 * sqrt($variance) / [$self get-mean-delay]] 
}

DelayMonitor instproc get-min-delay {} {
  $self instvar delay_monitor_out_
  return [$delay_monitor_out_ get-min-delay]
}

DelayMonitor instproc get-max-delay {} {
  $self instvar delay_monitor_out_
  return [$delay_monitor_out_ get-max-delay]
}

DelayMonitor instproc get-n-samples {} {
  $self instvar delay_monitor_out_
  return [$delay_monitor_out_ get-n-samples]
}

DelayMonitor instproc reset {} {
  $self instvar delay_monitor_out_
  return [$delay_monitor_out_ reset]
}


proc get-n-delay-samples { monitor_list } {
  set n 0
  set length [llength $monitor_list]
  for { set i 0 } { $i < $length } { incr i } {
    set dmon [lindex $monitor_list $i]
    set nsamples [$dmon get-n-samples]
    set n [expr $n + $nsamples]
  }
  return $n
}

# Determine the mean of the mean delays across a list of
# delay monitors.
proc get-mean-delay { monitor_list } {
  set sum 0.0
  set n 0
  set length [llength $monitor_list]
  for { set i 0 } { $i < $length } { incr i } {
    set dmon [lindex $monitor_list $i]
    set nsamples [$dmon get-n-samples]
    if { $nsamples > 0 } {
      set sum [expr $nsamples * [$dmon get-mean-delay] + $sum] 
      set n [expr $n + $nsamples]
    }
  } 
  return [expr $sum / $n] 
}

proc get-min-delay { monitor_list } {
  set min_set false
  set min 0.0
  set length [llength $monitor_list]
  for { set i 0 } { $i < $length } { incr i } {
    set dmon [lindex $monitor_list $i]
    set nsamples [$dmon get-n-samples]
    if { $nsamples > 0 } {
      if { $min_set } {
        if { $min > [$dmon get-min-delay] } {
          set min [$dmon get-min-delay]
        }
      } else {
        set min [$dmon get-min-delay]
        set min_set true
      }
    }
  }
  return $min
}

proc get-max-delay { monitor_list } {
  set max 0.0
  set length [llength $monitor_list]
  for { set i 0 } { $i < $length } { incr i } {
    set dmon [lindex $monitor_list $i]
    set nsamples [$dmon get-n-samples]
    if { $nsamples > 0 } {
      if { $max < [$dmon get-max-delay] } {
        set max [$dmon get-max-delay]
      }
    }
  }
  return $max
}

# Determines the variance across all delays measured in the
# delay monitors.
proc get-delay-variance { monitor_list } {
  set sum 0.0
  set n 0
  set length [llength $monitor_list]

  # obtain sum of second moments weighted by each monitor's sample size.
  for { set i 0 } { $i < $length } { incr i } {
    set dmon  [lindex $monitor_list $i]
    set nsamples [$dmon get-n-samples]
    if { $nsamples > 0 } {
      set sum [expr $nsamples * [$dmon get-second-moment] + $sum]
      set n [expr $n + $nsamples]
    }
  }

  # divide weighted sum of second moments by sum of the weights to
  # obtain the second moment across all delay monitors. 
  set second_moment [expr $sum / $n]

  # subtract mean squared from the second moment
  set mean_delay [get-mean-delay $monitor_list]
  set delay_variance [expr $second_moment - $mean_delay * $mean_delay]
}

# Returns the stddev across all delays measured in the passed
# delay monitors.
proc get-delay-stddev { monitor_list } {
  # Note: we can sum the variances, but one cannot sum the stddev's.
  # One must first sum the variances then take the sqrt of the sum.
  set var [get-delay-variance $monitor_list]
  return [expr sqrt($var)]
}

