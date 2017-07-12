# Copyright(c)2001 David Harrison.
# Copyright(c)2004 David Harrison 
# Copyright(c)2005 David Harrison
# Licensed according to the terms of the GNU Public License.
#
# Functions for creating ftp sources, udp cbr sources, modifying links, etc.
#
#  arr2lst                 shorthand for get-array-elements
#  bw2bps                  convert bandwidth unit (K,M,G,T) to bps.
#  create-ftp-over-reno    creates a persistant, infinite file download
#                          between n0 and n1.
#  create-ftp-over-full-sack    
#                          creates a persistant, infinite file download
#                          between n0 and n1 over the full TCP Sack impl.
#  create-ftp-over-vegas   same but using Vegas rather than Reno.
#  create-ftp-over-full-reno 
#                          create ftp over full TCP Reno implementation.
#  create-cbr              creates a constant-bit-rate data stream 
#                          between n0 and n1.  
#  create-pareto           creates a Pareto on/off source.
#  create-exponential      creates an exponential on/off source.
#  create-mice-over-sth    creates a source that periodically sends a 
#                          file with exponential interrequest times
#                          and exponential file sizes.
#                          (This is a REALLY simple model. Better model
#                          exist. See $NS/web-traffic)
#  get-array-elements      returns a list containing the elements 
#                          in a passed array.
#  list-cov                coefficient of variation of samples in the passed
#                          list. (Do not confuse C.O.V. with covariance!)
#  list-max                maximum sample in the passed list.
#  list-mean               mean of samples in the passed list
#  list-square-sum         sum of the square of samples in the passed list
#  list-jain-fairness-index jain's fairness index of the elements in the passed list
#  list-min                minimum sample in the passed list.
#  list-stddev             standard deviation of samples in the passed list.
#  list-variance           variance of samples in the passed list 
#  run-nam                 executes nam.
#  set-bw                  sets the bandwidth of a link.
#  t2sec                   convert time with unit (ms,ns,etc.) to seconds.
#  use-nam                 sets up nam.
#
# Author: David Harrison
#         Josh Hort        added create-pareto
#         Yong Xia         added Jain's fairness index

source $env(NS)/tcl/rpi/file-tools.tcl

# Sets up nam by creating a temp directory (name stored in tmp_directory_)
# if one hasn't already been created, opens a trace file, and
# tells the simulator object to output all events to the trace file.
#
# Note that using nam will seriously slow down ns and will create
# a very large nam file in the tmp_directory_. Do not use nam 
# with large simulations.
proc use-nam {} {
  global tmp_directory_ nam_file_ nam_app_path_

  if { ![info exists nam_app_path_] || $nam_app_path_ == "" } {
    puts "
You requested to use nam, but this script does not know where nam resides 
in your file system.  If nam is installed on your computer then run
the configure script:
  > cd \$NS/tcl/rpi
  > ns configure.tcl 

IGNORING NAM.
" 
    return
  }

  set ns [Simulator instance]
  
  # create temp directory (if not already created)
  if { ![info exists tmp_directory_] } {
    set tmp_directory_ [create-tmp-directory]
  } 

  # open trace file.
  set nam_file_ [open $tmp_directory_/out.nam w]
  $ns namtrace-all $nam_file_
}

# Executes nam. This is usually called at the end of a simulation.
# Before executing nam, this proc flushes all events to the trace file
# and closes the trace file.
proc run-nam {} {
  global nam_file_ tmp_directory_ nam_app_path_

  if { ![info exists nam_app_path_] || $nam_app_path_ == "" } {
    puts "
You requested to run nam, but this script does not know where nam resides 
in your file system.  If nam is installed on your computer then run
the configure script:
  > cd \$NS/tcl/rpi
  > ns configure.tcl 

IGNORING NAM.
" 
    return
  }

  set ns [Simulator instance]
  $ns flush-trace
  close $nam_file_  
  exec $nam_app_path_ $tmp_directory_/out.nam &
}

# set the bandwidth of the link from n0 to n1 to the specified capacity.
# This does not set the bw of the link from n1 to n0.
# Call it again with n1 n0 as the first two agruments if you
# wish to set the bandwidth in both directions.
#
#  bw = bandwidth in bps.
proc set-bw { n0 n1 bw } {
  set ns [Simulator instance]
  set link [$ns link $n0 $n1]
  set datalink [$link set link_]
  $datalink set bandwidth_ $bw
  puts "set-bw: datalink's new bw is [$datalink set bandwidth_]"
}

# Returns bandwidth in bps for the link spanning n0 to n1.
proc get-bw { n0 n1 } {
  set ns [Simulator instance]
  set link [$ns link $n0 $n1]
  set datalink [$link set link_]
  return [$datalink set bandwidth_]
}

# set the propogation delay of the link from n0 to n1.
# This does not set the delay of the link from n1 to n0.
# Call it again with n1 n0 as first two arguments if you 
# wish to set the delay in both directions.
#
# delay = delay in seconds.
proc set-delay { n0 n1 delay } {
  set ns [Simulator instance]
  set link [$ns link $n0 $n1]
  set datalink [$link set link_]
  $datalink set delay_ $delay 
}

# Returns the propagation delay for the link spanning n0 to n1.
proc get-delay { n0 n1 } {
  set ns [Simulator instance]
  set link [$ns link $n0 $n1]
  set datalink [$link set link_]
  return [$datalink set delay_]
}

Agent/TCP set window_ 1000000   ;# sooo high so it will never hit it!
                                ;# This is very dangerous if you are using
                                ;# Vegas. TCP/Vegas uses window_ to
                                ;# size an array send times for outstanding
                                ;# acks. A large window yields a huge
                                ;# waste of memory.
Agent/TCP set ecn_ true

# creates an infinite ftp source over TCP/Reno and returns the TCP/Reno
# and ftp agents.  If the start time is negative then this creates
# a TCP reno connection that does not send (i.e., not infinite). The
# caller then takes over responsibility for starting or stopping
# TCP/Reno.
proc create-ftp-over-reno { n0 n1 { start_time 0.0 } { fid 0 } } {
  set ns [Simulator instance]
  set tcp [$ns create-connection TCP/Reno $n0 TCPSink $n1 $fid]
  set ftp [new Application/FTP]
  $ftp attach-agent $tcp
  if { $start_time >= 0.0 } {
    $ns at $start_time "$ftp start"
  }
  return "$tcp $ftp"
}

# create an infinite ftp source over TCP/Vegas and return the TCP/Vegas
# and ftp agents.
proc create-ftp-over-vegas { n0 n1 { start_time 0.0 } { fid 0 } } {
  set ns [Simulator instance]
  set tcp [$ns create-connection TCP/Vegas $n0 TCPSink $n1 $fid]
  set ftp [new Application/FTP]
  $ftp attach-agent $tcp
  if { $start_time >= 0.0 } {
    $ns at $start_time "$ftp start"
  }
  return "$tcp $ftp"
}

# create UDP source with on and off times drawn from a Pareto
# distribution. The shape parameter is shared between the two
# distributions. "ontime" is the mean duration of the Pareto distributed
# on period, "bw" is the rate during the on period, and "idletime" is the
# mean duration of the Pareto distributed off period.
#
# Enough multiplexed Pareto sources exhibit long-range dependence.
#
# This returns the pair "$udp $pareto" where "$udp" is a reference to the
# UDP agent and "$pareto" is a reference to the Pareto application object.
#
# If the passed start_time is negative then the sender takes responsibility
# for starting the pareto agent, e.g.,
#   $pareto start
#
proc create-pareto { n0 n1 ontime idletime bw shape packetsize { start_time 0.0 } {fid 0 } } {
  set ns [Simulator instance]

  set udp [$ns create-connection UDP $n0 UDP $n1 $fid]
  set pareto [new Application/Traffic/Pareto]
  $pareto attach-agent $udp
  $pareto set burst_time_ $ontime
  $pareto set idle_time_ $idletime  
  $pareto set rate_ $bw  
  $pareto set shape_ $shape
  $pareto set packet_size_ $packetsize
  $pareto set fid_ $fid # May not be needed
  if { $start_time >= 0.0 } {
    $ns at $start_time "$pareto start"
  }
  return "$udp $pareto"
}

# create UDP source with on and off times drawn from an exponential 
# distribution. This returns "$udp $expo" where "$udp" is a reference to
# the udp agent and $expo is a reference to the exponential on/off traffic
# application.
#
# If the passed start time is negative then the caller takes repsonsibility
# for starting the traffic, e.g.,
#   $expo start
#
proc create-exponential \
  { n0 n1 ontime idletime bw packetsize { start_time 0.0 } { fid 0 } } \
{
  set ns [Simulator instance]

  set udp [$ns create-connection UDP $n0 UDP $n1 $fid]
  set expo [new Application/Traffic/Exponential]
  $expo attach-agent $udp
  $expo attach-agent $udp
  $expo set burst_time_ $ontime
  $expo set idle_time_ $idletime  
  $expo set rate_ $bw  
  $expo set packet_size_ $packetsize
  $expo set fid_ $fid # May not be needed
  if { $start_time >= 0.0 } {
    $ns at $start_time "$expo start"
  }

  return "$udp $expo"
}

# Creates an FTP transfer over the FULL implementation of TCP Reno.
# If start time is > 0.0 then at start_time, the FTP begins transferring
# an infinitely long file.  If the start_time is negative then caller
# takes responsbility for starting the connection sending traffic, e.g.,
#    $ftp start
#
# Returns: $tcp $ftp $sink
proc create-ftp-over-full-reno { source dest { start_time 0.0 } { fid 0 } } {
  set ns [Simulator instance]

  set tcp [new Agent/TCP/FullTcp]
  set sink [new Agent/TCP/FullTcp]
  $tcp set fid_ $fid
  $sink set fid_ $fid
  $ns attach-agent $source $tcp
  $ns attach-agent $dest $sink 
  $ns connect $tcp $sink 
  $sink listen

  set ftp [new Application/FTP]
  $ftp attach-agent $tcp
  if { $start_time >= 0.0 } {
    $ns at $start_time "$ftp start"
  }
  return "$tcp $ftp $sink"
}


# Creates a TCP Sack connection between $source and $dest and performs
# a download of an infinitely long file. If start_time is negative
# then the caller takes responsibility for starting the connection
# sending, e.g.,
#   $ftp start
#
proc create-ftp-over-full-sack { source dest { start_time 0.0 } { fid 0 } } {
  set ns [Simulator instance]

  set tcp [new Agent/TCP/FullTcp/Sack]
  set sink [new Agent/TCP/FullTcp/Sack]
  $tcp set fid_ $fid
  $sink set fid_ $fid
  $ns attach-agent $source $tcp
  $ns attach-agent $dest $sink 
  $ns connect $tcp $sink 
  $sink listen

  set ftp [new Application/FTP]
  $ftp attach-agent $tcp
  if { $start_time >= 0.0 } {
    $ns at $start_time "$ftp start"
  }
  return "$tcp $ftp"
}

# Creates a Constant-Bit-Rate source over UDP and returns both the UDP
# and CBR agents.  If the start_time is negative then the caller
# takes responsibility for starting traffic, e.g.,
#   $cbr start
#
# bandwidth should be in units of Mbps.
proc create-cbr { n0 n1 bw packet_size { start_time 0.0 } { fid 0 } } {
  set ns [Simulator instance]
  set udp [$ns create-connection UDP $n0 UDP $n1 $fid]
  set cbr [new Application/Traffic/CBR]
  $cbr attach-agent $udp
  $cbr set packet_size_ $packet_size
  $cbr set interval_ [expr $packet_size * 8.0 / ($bw * 1000000 )]
  $cbr set fid_ $fid
  if { $start_time >= 0.0 } {
    $ns at $start_time "$cbr start"
  }
  return "$udp $cbr"
}



# Creates an ftp agent that sends files of specified size
# and with specified interrequest time (see note). This calls mice-callback
# to perform ftp transfers and schedule additional transfers.
# The nsrcs argument specifies how many sources to create.
# Each source will use the same interrequest and size arguments. 
# Therefore the send rate should be nsrcs*size/interrequest when
# averaged over a sufficiently long period of time.
#
# Note: the interrequest time is between the beginnings of transfers
# NOT from the end of one transfer to the beginning of the next. This
# means that sends can be called before the previous send completes
# causing a continuous file transfer. 
#
# (I currently use an exponential R.V. both for interrequest time
# and file size.)
proc create-mice-over-sth { src n0 sink n1 { interrequest 5 } \
                             { size 10240} { nsrcs 1 } { fid 0 } } {
  global interrequest_rvar size_rvar

  set ns [Simulator instance]
  for { set i 0 } { $i < $nsrcs } { incr i } {
      set tcp [$ns create-connection $src $n0 $sink $n1 $fid]
      set ftp [new Application/FTP]
      $ftp attach-agent $tcp

      set interrequest_rvar [new RandomVariable/Exponential]
      $interrequest_rvar set avg_ $interrequest
      #$interrequest_rvar set val_ $interrequest

      set size_rvar [new RandomVariable/Exponential]
      $size_rvar set avg_ $size
      #$size_rvar set val_ $size
      $ns at [expr [$ns now] + [$interrequest_rvar value]] \
	      "mice-callback $ftp $interrequest_rvar $size_rvar"
  }
}

# Called each time to send a file.
proc mice-callback { ftp interrequest_rvar size_rvar } {
#puts "mice-callback at time [[Simulator instance] now]"
  set file_sz [expr [$size_rvar value] * 1.0]
  $ftp send $file_sz
  set ns [Simulator instance]
  $ns at [expr [$ns now] + [expr [$interrequest_rvar value] * 1.0]] \
    "mice-callback $ftp $interrequest_rvar $size_rvar"
}

# Set bitrate. Passed bw is in Mbps.
# This extends the CBR Traffic class provided by ns which only
# allows the sender to specify the packet intertransmission time
# (i.e., time between the starts of each packet).
Application/Traffic/CBR instproc set-rate { bw } {
  $self instvar packet_size_ 
  $self set interval_ [expr $packet_size_ * 8.0 / ($bw * 1000000 )]
}


proc min { a b } {
  if { $a > $b } {
    return $b
  } else { 
    return $a
  }
}

proc max { a b } {
  if { $a > $b } {
    return $a
  } else {
    return $b
  }
}

proc list-min { l } {
  set min [lindex $l 0]
  for { set i 1 } { $i < [llength $l] } { incr i } {
    if { [lindex $l $i] < $min } {
      set min [lindex $l $i]
    }
  }
  return $min
}

proc list-max { l } {
  set max [lindex $l 0]
  for { set i 1 } { $i < [llength $l] } { incr i } {
    if { [lindex $l $i] > $max } {
      set max [lindex $l $i]
    }
  }
  return $max
}


# This takes an array name and returns all of the elements in this
# array in a list. The indices of the array elements are not included
# in the returned list. The elements are ordered lexicographically on index.
# This works with multi-dimensional arrays.
proc get-array-elements { arrname } {
  upvar 1 $arrname arr
  set list1 [array get arr]
  set list2 ""
  for { set i 1} { $i < [llength $list1] } { set i [expr $i + 2 ] } {
    lappend list2 [lindex $list1 $i]
  }
  return $list2
}

# shorthand for get-array-elements
proc arr2lst { arrname } {
  upvar 1 $arrname arr
  return [get-array-elements $arr]
}


# returns true iff there exists an instvar with name $name for $obj.
# The advantage of this function is that it does not use instvar
# in the global scope (which causes ns-2.1b5 to core dump). 
proc instvar-exists { obj name } {
  $obj instvar $name
  return [info exists $name]
}

# performs the passed unary proc on all member of the list and
# returns a list containing the results of each call in the
# order that elements appeared in the original list. 
# (A unary proc accepts one argument.)
proc for-all { lst unary_proc } {
  puts "llength \$lst = [llength $lst]"
  for { set i 0 } { $i < [llength $lst] } { incr i } {
    set x [$unary_proc [lindex $lst $i]] 
    lappend output $x
  }
  return $output
}


# return mean of the elements in the passed list.
proc list-mean { lst } {
  set sum 0.0  
  set length [llength $lst]

  for { set i 0 } { $i < $length } { incr i } {
    set sum [expr $sum + [lindex $lst $i]]
  }
  return [expr $sum / $length]
}

# return sum of the sqaures of the elements in the passed list.
proc list-square-sum { lst } {
  set sqsum 0.0  
  set length [llength $lst]

  for { set i 0 } { $i < $length } { incr i } {
    set sample [lindex $lst $i]
    set sqsum [expr $sqsum + $sample * $sample]
  }
  return [expr $sqsum]
}

# return jain's fairness index of the elements in the passed list.
proc list-jain-fairness-index { lst } {
  set n [llength $lst]
  set mean [list-mean $lst]
  set sqsum [list-square-sum $lst]
  return [expr $n * $mean * $mean / $sqsum]
}

# returns variance of the elements in the passed list.
#
# When dealing with entire population: Var[X] = E[X^2]-E[X]^2
# When dealing with samples, an unbiased estimator of variance
# is give by
#
#   v = 1/(n-1) Sum( (x_i - m)^2 )
#
# let m = sample mean
# let v = sample variance
# let n = number of samples
#
# v = 1/(n-1) [ x0^2 - 2 x0 m + m^2 + ... + xn^2 - 2 xn m + m^2 ]
#   = 1/(n-1) [ sumsq - 2 m sum(xi) + n m^2 ]
#   = 1/(n-1) [ sumsq - 2 sum(xi)^2 / n + sum(xi)^2 / n ]
# v = 1/(n-1) ( sumsq - sum * sum / n )
proc list-variance { lst } {
  set sqsum 0.0
  set mean [list-mean $lst]
  set n [llength $lst]  ;# number of samples.

  for { set i 0 } { $i < $n } { incr i } {
    set sample [lindex $lst $i] 
    set mean_diff [expr $sample - $mean]
    set sqsum [expr $sqsum + $mean_diff * $mean_diff]
  }
  return [expr $sqsum / ($n-1)]
}

# returns standard deviation for the elements in the passed list.
proc list-stddev { lst } {
  return [expr sqrt([list-variance $lst])]
}

# returns C.O.V. (Coefficient of Variation) of the elements in the passed
# list.  Note: do not confuse C.O.V. with Cov or CoV which is usually taken
# to mean covariance!
proc list-cov { lst } {
 return [expr ([list-stddev $lst] / [list-mean $lst])]
}

# converts a time value with a specific unit to a time in seconds. Valid times
# are a number followed by a unit without any whitespace between the number
# and the unit.
#
# m = milliseconds
# s = seconds
# u = microseconds
# n = nanoseconds
# p = picoseconds
# h != hours.  h means nothing.
# d != days.   d means nohting.
# y != years
#
# Units must begin with one of the above characters, but the remaining 
# characters in the unit string can be any letter. For example, all of the
# strings below map onto nanosecond:
#   n
#   ns
#   nsec
#   nanosecond
#   nnnnsdnsf
#
# Proper strings are 
proc t2sec { t } {

  # step 1: trim leading and trailing whitespace from t.
  set s [string trim $t]

  set ln [string length $s]
  if { [string length $s] == 0 } {
    error "t2sec was passed a string that contained no time."
  }

  # step 2: obtain the last chacter in the trimmed string.
  #  - find the beginning of the unit substring in the $t.
  for { set i [expr $ln-1]; set ch [string index $s [expr $ln-1]] } \
      { $i >= 0 && $ch < "0" || $ch > "9" } \
      { set i [expr $i-1]; set ch [string index $s $i] } \
  {
  }
  if { $i == -1 } {
    error "t2sec was passed a string that contains characters but no numbers."
  }

  #  - extract the first charater of the unit substring.
  if { $i < [expr $ln-1] } {
      set ch [string tolower [string index $s [expr $i+1]]]
  }

  set time [string range $s 0 $i]
  
  switch $ch {
    # milliseconds
    "m" {
	set time [expr $time / 1000.0]
    }

    # seconds
    "s" {
	# do nothing. Just return $time.
    }

    # microseconds
    "u" {
	set time [expr $time * 1.e-6]
    }

    # nanoseconds
    "n" {
	set time [expr $time * 1.e-9]
    }

    # picoseconds
    "p" {
	set time [expr $time * 1.e-12]
    }

    - {
     set time $s
    }
  }
  return $time
}

# converts from a bandwidth specification that includes a 
# unit to bits per second (bps).  
# 
# For example:
#   K,k    kilobit per second, 1000 bits per second.
#   M,m    megabit per second, 1.e6 bits per second.
#   G,g    gigabit per second, 1.e9 bits per second.
#   T,t    terabit per second, 1e12 bits per second.
proc bw2bps { t } {

  # step 1: trim leading and trailing whitespace from t.
  set s [string trim $t]

  set ln [string length $s]
  if { [string length $s] == 0 } {
    error "bw2bps was passed a string that contained no time."
  }

  # step 2: obtain the last chacter in the trimmed string.
  #  - find the beginning of the unit substring in the $t.
  for { set i [expr $ln-1]; set ch [string index $s [expr $ln-1]] } \
      { $i >= 0 && $ch < "0" || $ch > "9" } \
      { set i [expr $i-1]; set ch [string index $s $i] } \
  {
  }

  if { $i == -1 } {
    error "bw2bps was passed a string that contains characters but no numbers."
  }

  #  - extract the first charater of the unit substring.
  if { $i < [expr $ln-1] } {
      set ch [string tolower [string index $s [expr $i+1]]]
  }  

  set bw [string range $s 0 $i]

  switch $ch {
      "k" {   ;# K,k    kilobit per second, 1000 bits per second.
	  set bw [expr $bw * 1000.0]
      }
      "m" {   ;# M,m    megabit per second, 1.e6 bits per second.
          set bw [expr $bw * 1.0e6]
      }
      "g" {   ;# G,g    gigabit per second, 1.e9 bits per second.
          set bw [expr $bw * 1.0e9]
      }
      "t" {   ;# T,t    terabit per second, 1e12
          set bw [expr $bw * 1.0e12]
      }
  }

  return $bw
    
}
