#    https://groups.google.com/forum/?fromgroups#!topic/ns-users/vO9ylcltsp4
set ns [new Simulator]

set mynam [open tcpDrop.nam w]
$ns namtrace-all $mynam

set mytrace [open tcpDrop.tr w]
$ns trace-all $mytrace

set winfile [open tcpDropWinFile.xg w]

set f0 [open bw_tcpDrop.tr w]

proc finish {} {
 global ns mynam mytrace
 $ns flush-trace
 close $mynam
 close $mytrace
 #exec nam d1.nam &
 exit 0
}

set n0 [$ns node]
set n1 [$ns node]


#Queue/RED set thresh_ 60
#Queue/RED set maxthresh_ 80
#Queue/RED set q_weight_ 0.002



set flink [$ns duplex-link $n0 $n1 1Mb 10ms CoDel]
                                          #$ns queue-limit $n0 $n1 10



set qmon [$ns monitor-queue $n0 $n1 [open qmtcpDrop.out w] 0.1];
[$ns link $n0 $n1] queue-sample-timeout;

#set redq [[$ns link $n0 $n1] queue]
#set traceq [open tcpred-queue.tr w]
#$redq trace curq_
#$redq trace ave_
#$redq attach $traceq


#set monfile [open mon.tr w]
#set fmon [$ns makeflowmon Fid]
#$ns attach-fmon $flink $fmon
#$fmon attach $monfile








set tcp0 [new Agent/TCP/Linux]
#$tcp0 set packetSize_ 2000

# $tcp0 set ssthresh_ 50



$ns attach-agent $n0 $tcp0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
#$cbr0 set packetSize_ 500
#$cbr0 set interval_ 0.005


set sink0 [new Agent/TCPSink]

$ns attach-agent $n1 $sink0

$ns connect $tcp0 $sink0

$ns at 0.5 "$ftp0 start"
$ns at 50.0 "$ftp0 stop"

proc plotWindow {tcpSource file} {
global ns 
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
set wnd [$tcpSource set window_]
set ssthresh [$tcpSource set ssthresh_]
puts $file "$now $cwnd \t \t \t \t \t \t $wnd \t \t \t \t \t $ssthresh"
$ns at [expr $now+$time] "plotWindow $tcpSource $file"

}


proc sinkNodeRecord {} {
                    global  sink0 f0 ns
                    #Set the time after which the procedure should be called again
                    set time 0.5
                    #How many bytes have been received by the traffic sinks?
                      set bw0 [$sink0 set bytes_]
                    #Get the current time
                    set now [$ns now]
                    #Calculate the bandwidth (in MBit/s) and write it to the files
                    puts $f0 "$now [expr $bw0/$time*8/1000000]"
                    #Reset the bytes_ valuesqueue-limit $n0 $n5 10 on the traffic sinks
                     $sink0 set bytes_ 0
                    #Re-schedule the procedure
                    $ns at [expr $now+$time] "sinkNodeRecord"
}


$ns at 0.5 "sinkNodeRecord"

$ns at 0.5 "plotWindow $tcp0 $winfile"
# $ns at [expr 5.0-0.01] "$fmon dump"

$ns at 50.0 finish


$ns run

 
