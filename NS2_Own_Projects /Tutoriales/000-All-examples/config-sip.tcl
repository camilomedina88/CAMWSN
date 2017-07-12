proc record {} {
global null4 tf
#Get an instance of the simulator
set ns [Simulator instance]
#Set the time after which the procedure should be called again
set time 0.1
#How many bytes have been received by the traffic sinks?
set bw0 [$null4 set bytes_]
#Get the current time
set now [$ns now]
#Calculate the bandwidth (in MBit/s) and write it to the files
puts $tf "$now [expr $bw0/$time*8/1000000]"
#Reset the bytes_ values on the traffic sinks
$null4 set bytes_ 0
#Re-schedule the procedure
$ns at [expr $now+$time] "record"
}
proc Record2 {} {
global null0 tf

#Get an instance of the simulator
set ns_ [Simulator instance]
#Set the time after which the procedure should be called again
set time 0.01
#How many bytes have been received by the traffic sinks?
set DP [$null0 set nlost_]
#Get the current time
set now [$ns_ now]
#Calculate the bandwidth (in MBit/s) and write it to the files
puts $f0 "$now [expr $bw0/$time*8/1000000]"
puts $tf "$now $DP"
$null0 set nlost_ 0
#Reset the bytes_ values on the traffic sinks
$sink1 set bytes_ 0
#Re-schedule the procedure
$ns_ at [expr $now+$time] "Record2"
} 
