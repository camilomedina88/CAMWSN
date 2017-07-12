# This tcl script defines the command functions that would be used
# in most of WiMAX simulations.  If we wanna execute simulation and
# record the performance, we will the following steps in our tcl scripts:
#  1) include the functions.tcl, for example: " source functions.tcl ".
#  2) add the scirpt: " $ns at $start_time_ "record_xxx" ".  $start_time_
#     is the start time that we would start to record.  "record_xxx" is
#     tcl functions defined in here would used for record performance.

proc record_throughput {} {
  global ns nb_mn sink_ throughput_rv_
  set interval_ 0.1
  set now_ [$ns now]

  set thput_ "$now_"
  for {set i 0} {$i < $nb_mn} {incr i} {
    set rx_bytes_($i) [$sink_($i) set bytes_]
    set thput_buf($i) [expr $rx_bytes_($i)*8/$interval_/1000]
    $sink_($i) set bytes_ 0

    append thput_ "\t$thput_buf($i)"
  }
  # put the record to the file or screen
  puts $throughput_rv_ $thput_

  $ns at [expr $now_ + $interval_] "record_throughput"
}


# Defines function for flushing and closing files
proc finish {} {
  global ns output_dir nb_mn tf
  $ns flush-trace
  close $tf
  puts "Simulation done."
  exit 0
}
