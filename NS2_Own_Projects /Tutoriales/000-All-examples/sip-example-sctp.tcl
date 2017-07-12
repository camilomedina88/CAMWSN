##--M.Fasciana
#--University of Palermo (Italy)
#-----------------------------------------------------------

set simtime 3600
set call_time_min 90 #sec
set call_time_max 120 #sec

set sip_rate [expr (577 * 8 * $N)]
set interarrivo [expr (1.0 / $N)]
set sip_packet_size 577

set voice_packet_size 160
set voice_burst_time 1.0
set voice_idle_time 1.3
set voice_rate 64000
set tidle 1
set ttotal 2.3
set tmedio [expr (${tidle} / ${ttotal})]
set call_time [lindex $argv 1]

set from 1
set to 2

set ns [new Simulator]
$ns use-scheduler Heap

Trace set show_sctphdr_ 1
Trace set show_tcphdr_ 0

puts "Start simulation with $N Call/sec"

# initializations
remove-packet-header NV LDP MPLS rtProtoLS Ping RAP AODV SR TORA IMEP Encap HttpInval MFTP SRMEXT
#set nf [open /dev/null w]
set nt [open out_sctp_$I.tr w]

$defaultRNG seed 0

#topology
# nodes
set LO1 [$ns node]
set LO2 [$ns node]
set TO1 [$ns node]
set TO2 [$ns node]

#node of SIP proxy server
set PR1 [$ns node]
set PR2 [$ns node]

set n_voice_($to) [$ns node]
set n_null_($to) [$ns node]

set n_voice_($from) [$ns node]
set n_null_($from) [$ns node]

#node of voicetest
set n_test_1 [$ns node]
set n_test_2 [$ns node]

#link
$ns duplex-link $TO1 $TO2 155Mb 5ms DropTail

$ns duplex-link $LO1 $TO1 155Mb 5ms DropTail
$ns duplex-link $TO2 $LO2 155Mb 5ms DropTail

$ns duplex-link $LO1 $n_voice_(1) 155Mb 20ms DropTail
$ns duplex-link $LO1 $n_null_(1) 155Mb 20ms DropTail

$ns duplex-link $LO2 $n_voice_(2) 155Mb 20ms DropTail
$ns duplex-link $LO2 $n_null_(2) 155Mb 20ms DropTail

$ns duplex-link $n_voice_(1) $n_test_1 155Mb 0ms DropTail
$ns duplex-link $n_null_(2) $n_test_2 155Mb 0ms DropTail

#-------------------------------------------------------------------
#agent test for voice sources
set udp_test [new Agent/UDP]
$udp_test set class_ 2
$ns attach-agent $n_test_1 $udp_test
$ns trace-queue $n_test_1 $n_voice_(1) $nt

#agentTestSink
set udp_test_sink [new Agent/Null]
$ns attach-agent $n_test_2 $udp_test_sink
$ns trace-queue $n_null_(2) $n_test_2 $nt

#proxy
#proxy
set sctp_1 [new Agent/SCTP]
$ns attach-agent $PR1 $sctp_1
$sctp_1 set fid_ 0
$sctp_1 set numOutStreams_ 1
$sctp_1 set useMaxBurst_ 0
$sctp_1 set debugMask_ -1  ;##0x00303000   # u can use -1 to turn oneverything
$sctp_1 set debugFileIndex_ 1
$sctp_1 set mtu_ 650
$sctp_1 set dataChunkSize_ 577
$sctp_1 set initialRwnd_ 131072
$sctp_1 set useDelayedSacks_ 1
$sctp_1 set initialCwndMultiplier_ 1
$ns trace-queue $PR1 $LO1 $nt
$ns trace-queue $LO1 $PR1 $nt

set sctp_2 [new Agent/SCTP]
$ns attach-agent $PR2 $sctp_2
$sctp_2 set fid_ 0
$sctp_2 set numOutStreams_ 1
$sctp_2 set useMaxBurst_ 0
$sctp_2 set debugMask_ -1  ;##0x00303000   # u can use -1 to turn on everything
$sctp_2 set debugFileIndex_ 1
$sctp_2 set mtu_ 650
$sctp_2 set dataChunkSize_ 577
$sctp_2 set initialRwnd_ 131072
$sctp_2 set useDelayedSacks_ 1
$sctp_2 set initialCwndMultiplier_ 1
$ns trace-queue $LO2 $PR2 $nt


$ns connect $sctp_1 $sctp_2
$ns connect $udp_test $udp_test_sink

#-------------------------------------------------------------------
#applications: 2 Proxy servers
set sip_1 [new Application/Traffic/SipSctp]
$sip_1 set packetSize_ ${sip_packet_size}
$sip_1 set burst_time_ 0
$sip_1 set idle_time_ $interarrivo
$sip_1 set rate_ 2.5Mb
$sip_1 set print_ 0
$sip_1 set minSS7delay_ 0.025
$sip_1 set maxSS7delay_ 0.05
$sip_1 set end_call_mmanagment_ 1
$sip_1 set call_min ${call_time_min}
$sip_1 set call_max ${call_time_max}
$sip_1 set from_ $from
$sip_1 set to_ $to
$sip_1 set numStreams_ 1
$sip_1 set numUnreliable_ 1
$sip_1 set reliability_ 0
$sip_1 attach-agent $sctp_1

set sip_2 [new Application/Traffic/SipSctp]
$sip_2 set packetSize_ ${sip_packet_size}
$sip_2 set burst_time_ 0
$sip_2 set idle_time_ $interarrivo
$sip_2 set rate_ 2.5Mb
$sip_2 set print_ 0
$sip_2 set minSS7delay_ 0.025
$sip_2 set maxSS7delay_ 0.05
$sip_2 set end_call_mmanagment_ 1
$sip_2 set call_min ${call_time_min}
$sip_2 set call_max ${call_time_max}
$sip_2 set call_ ${call_time}
$sip_2 set from_ $to
$sip_2 set to_ $from
$sip_2 set numStreams_ 1
$sip_2 set numUnreliable_ 1
$sip_2 set reliability_ 0
$sip_2 attach-agent $sctp_2

#Test voice source
set voice_test [new Application/Traffic/Exponential]
$voice_test set packetSize_ $voice_packet_size            ;#132
$voice_test set burst_time_ $voice_burst_time             ;#1000ms
$voice_test set idle_time_ $voice_idle_time              ;#1300ms
$voice_test set rate_ $voice_rate                ;#16k
$voice_test attach-agent $udp_test

#---------------------------------------------------------
source sctp_utils.tcl

# finish procedure
proc finish {} {
   global ns nt nf
   $ns flush-trace
   close $nf
   close $nt

  #exec nam out_sip.nam &

    exit 0
}

#---------------------------------------------------------
#scheduler
set fintime [expr $simtime + $call_time]

$ns at 0.0 "$sip_1 start"
$ns at 0.0 "$sip_2 start"

puts "start_sip"

$ns at 0.0 "$voice_test start"
$ns at $fintime "$voice_test stop"

$ns at $simtime "$sip_1 stop"
$ns at $simtime "$sip_2 stop"

$ns at $fintime "finish"
 
$ns run 
