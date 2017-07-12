#End simulation time ($end_sim_time) 
# this file contain the variable end_sim_time
#source last_time.tcl 
 
set ns [new Simulator] 
set end_sim_time 10.0
 
#Open the nam trace file 
set nf [open final.nam w] 
set tf [open final.tr w] 
 
$ns namtrace-all $nf 
$ns trace-all $tf 
  
#Define a 'finish' procedure 
proc finish {} { 
        global ns nf tf 
        $ns flush-trace 
        #Close the trace file 
        close $nf 
        close $tf 
        #Execute nam on the trace file 
        exec nam final.nam & 
        exit 0 
} 
  
set node_(s1) [$ns node] 
set node_(s2) [$ns node] 
set node_(r1) [$ns node] 
 
$ns duplex-link $node_(s1) $node_(r1) 10Mb 5ms DropTail 
$ns duplex-link $node_(s2) $node_(r1) 10Mb 5ms DropTail 
 
set trace_file [new Tracefile] 
$trace_file filename starwars.nsformat 
 
set RTP_s [new Agent/RTP_v2] 
set RTCP_r [new Agent/RTCP_v2] 
 
set self [new Session/RTP] 
 
$ns attach-agent $node_(s1) $RTP_s 
$ns attach-agent $node_(s2) $RTCP_r 
$ns connect $RTP_s $RTCP_r 
 
set video [new Application/Traffic/Trace] 
$video attach-tracefile $trace_file 
$video attach-agent $RTP_s 
 
$RTCP_r session $self 
$RTP_s session $self 
 
$RTCP_r set interval_ 100ms 
$RTCP_r set seqno_ 0

 
$RTP_s set packetSize_ 1064 
  
$ns at 0.0 "$video start" 
$ns at 0.0 "$RTCP_r start" 
$ns at $end_sim_time    { 
                        $video stop 
                        $RTCP_r stop 
                        #$RTP_s stop 
                        finish 
                        } 
 
$ns run 
