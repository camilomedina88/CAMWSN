

set escenario [lindex $argv 0]

set opt(chan) Channel/WirelessChannel

set opt(prop) Propagation/TwoRayGround

set opt(netif) Phy/WirelessPhy

set opt(mac) Mac/802_11e

set opt(ifq) Queue/DTail/PriQ

#set opt(mac) Mac/802_11

set opt(ifq) CMUPriQueue

set opt(ll) LL

set opt(ant) Antenna/OmniAntenna

set opt(CBRpsize) 1500

set opt(CBRrate) 1000000

set NumofSources 1

set opt(ifqlen) 50

#Queue set limit_ 1000

set num_nodes 50

set opt(NumOfMN) $num_nodes

set opt(RoutingProtocol) DSR

#DSR has 4 different physical queues: queue size set in dsr-priqueue.h

set opt(X) 520

set opt(Y) 520

set opt(MNcoverage) 120

set opt(speed) 2

set opt(start) 0

set opt(stop) 100

#Mac/802.11e set dataRate_ 11.0e6 ;# 11Mbps

#Mac/802.11e set basicRate_ 11.0e6 ;# (1Mbps)

#Mac/802.11e set bandwidth_ 11.0e6 ;# (1Mbps)

proc SetPt { coverage } {

set Gt [Antenna/OmniAntenna set Gt_]

set Gr [Antenna/OmniAntenna set Gr_]

set ht [Antenna/OmniAntenna set Z_]

set hr [Antenna/OmniAntenna set Z_]

set RXThresh [Phy/WirelessPhy set RXThresh_]

set d4 [expr pow($coverage,4)]

set Pt [expr ($RXThresh*$d4)/($Gt*$Gr*$ht*$ht*$hr*$hr)]

return $Pt

}

Phy/WirelessPhy set L_ 1.0

Phy/WirelessPhy set freq_ 2.472e9

Phy/WirelessPhy set bandwidth_ 11Mb

Phy/WirelessPhy set Pt_ 0.031622777

Phy/WirelessPhy set CPThresh_ 10.0

Phy/WirelessPhy set CSThresh_ 5.011872e-12

Phy/WirelessPhy set RXThresh_ 5.82587e-09

Phy/WirelessPhy set Pt_ [SetPt $opt(MNcoverage)]

puts "Pt_ ========== $[SetPt $opt(MNcoverage)]"

Antenna/OmniAntenna set X_ 0

Antenna/OmniAntenna set Y_ 0

Antenna/OmniAntenna set Z_ 1.5

Antenna/OmniAntenna set Gt_ 1

Antenna/OmniAntenna set Gr_ 1

set ns_ [new Simulator]

set trace [open "trace.tr" w]

$ns_ trace-all $trace

$ns_ use-newtrace

set namtrace [open animation.nam w]

$ns_ namtrace-all-wireless $namtrace $opt(X) $opt(Y)

set topo [new Topography]

$topo load_flatgrid $opt(X) $opt(Y)

set god [create-god $opt(NumOfMN)]

set chan_1_ [new $opt(chan)]

$ns_ node-config \

-mobileIP OFF \

-adhocRouting $opt(RoutingProtocol) \

-llType $opt(ll) \

-macType $opt(mac) \

-ifqType $opt(ifq) \

-ifqLen $opt(ifqlen) \

-antType $opt(ant) \

-propType $opt(prop) \

-phyType $opt(netif) \

-channel $chan_1_ \

-topoInstance $topo \

-agentTrace ON \

-routerTrace ON \

-macTrace OFF \

-movementTrace ON \

-wiredRouting OFF

Agent/Null set sport_ 0

Agent/Null set dport_ 0

Agent/CBR set sport_ 0

Agent/CBR set dport_ 0

set opt(CBRperiod) [expr 8.0 * double($opt(CBRpsize)+20) / double($opt(CBRrate))]

$ns_ color 1 Blue

$ns_ color 2 Green

$ns_ color 3 Red

$ns_ color 4 Yellow

Agent/RTP_v2 set sport_ 0

Agent/RTP_v2 set dport_ 0

Agent/RTCP_v2 set sport_ 0

Agent/RTCP_v2 set dport_ 0

set rng [new RNG]

set opt(seed) 0.1

$rng seed $opt(seed)

for {set i 0} {$i < $opt(NumOfMN)} {incr i} {

set node_($i) [$ns_ node]

}

puts "Loading scenario file..."

set opt(sc) $escenario

source $opt(sc)

puts "Load complete..."

for {set i 0} {$i < $opt(NumOfMN)} {incr i} {

$node_($i) set RTPsource_ 0

$node_($i) set RTPdestination_ 0

}

set tmp 0.011

set start_tx_time 4

set selfs 0

for {set i 0} {$i < $NumofSources} {incr i} {

set n [expr {$i + 20}]

$node_($i) set RTPsource_ 1

$node_($n) set RTPdestination_ 1

$node_($i) set MMDSRfreq_ 14

# average speed of the nodes

$node_($i) set mu_ 5

puts "RTPsource $i"

puts "RTPdestination $n"

set trace_file_($i) [new MpegDataFile_v2]

$trace_file_($i) metafile /home/vico/ns2/adhoc/e/blade2.mdipbf4444

$trace_file_($i) datafile /home/vico/ns2/adhoc/e/blade.m2v

set rtp_($i) [new Agent/RTP_v2]

$ns_ attach-agent $node_($i) $rtp_($i)

$rtp_($i) set class_ 2

$rtp_($i) set seqno_ 0

$rtp_($i) set packetSize_ 1500

$rtp_($i) set multipath_ 3

$rtp_($i) set flow_id_ $i

$rtp_($i) set prio_ 0

$rtp_($i) set ptype_ 1

set rtcp_($n) [new Agent/RTCP_v2]

$ns_ attach-agent $node_($n) $rtcp_($n)

$rtcp_($n) set class_ 3

$rtcp_($n) set interval_ 1000ms

$rtcp_($n) set seqno_ 0

$rtcp_($n) set flow_id_ $n

set rtp_($n) [new Agent/RTP_v2]

$ns_ attach-agent $node_($n) $rtp_($n)

$rtp_($n) set class_ 2

$rtp_($n) set seqno_ 0

$rtp_($n) set packetSize_ 1500

$rtp_($n) set flow_id_ $n

# Variable for RTCP: 0-> not in use, 1-> in use

$rtp_($i) set rtcp_in_use_ 1

$ns_ connect $rtp_($i) $rtcp_($n)

$ns_ attach-agent $node_($n) $rtcp_($n)

set MPEG2_($i) [new Application/Traffic/Mpeg2Gen2]

$MPEG2_($i) attach-mpegdatasrc $trace_file_($i)

$MPEG2_($i) attach-agent $rtp_($i)

#0: without codification

#1: all data through the same path

#2: I+B path 1, P path 2

#3: Even I, P, B frames by path 1, odd B frames by path 2

#4: I / P / B, each one through a different path (Multipath of 3) */

$MPEG2_($i) set codification_ 4

$rtp_($i) set codification_ 4

set sinkmpeg_($n) [new Application/Mpeg2RX2]

$sinkmpeg_($n) attach-agent $rtcp_($n)

$sinkmpeg_($n) attach-agent $rtp_($n)

$sinkmpeg_($n) dumpfile "$i.multipath_video.m2v"

set self_($i) [new Session/RTP]

$rtcp_($n) session $self_($i)

$rtp_($i) session $self_($i)

$rtp_($n) session $self_($i)

set udp_($i) [new Agent/UDP]

$ns_ attach-agent $node_($i) $udp_($i)

set null_($n) [new Agent/LossMonitor]

$ns_ attach-agent $node_($n) $null_($n)

set cbr_($i) [new Application/Traffic/CBR]

$cbr_($i) set packetSize_ $opt(CBRpsize)

$cbr_($i) set interval_ $opt(CBRperiod)

$cbr_($i) set random_ 1

$udp_($i) set prio_ 3

$udp_($i) set ptype_ 2

$cbr_($i) set CBRrate $opt(CBRrate)

$cbr_($i) attach-agent $udp_($i)

$ns_ connect $udp_($i) $null_($n)

$udp_($i) set fid_ 4

$ns_ at $start_tx_time "$cbr_($i) start"

$ns_ at 4.0 "$cbr_($i) stop"

$ns_ at $start_tx_time "$MPEG2_($i) start"

$ns_ at $start_tx_time "$rtcp_($n) start"

incr start_tx_time

incr selfs

}

set udp_(1) [new Agent/UDP]

$ns_ attach-agent $node_(1) $udp_(1)

set null_(21) [new Agent/LossMonitor]

$ns_ attach-agent $node_(21) $null_(21)

set cbr_(1) [new Application/Traffic/CBR]

$cbr_(1) set packetSize_ $opt(CBRpsize)

$cbr_(1) set interval_ $opt(CBRperiod)

$cbr_(1) set random_ 1

$cbr_(1) set CBRrate $opt(CBRrate)

$cbr_(1) attach-agent $udp_(1)

$ns_ connect $udp_(1) $null_(21)

$udp_(1) set fid_ 4

$ns at 0.0 "$cbr_(1) start"

$ns at 4.0 "$cbr_(1) stop"

$ns_ at $opt(stop) {finish}

for {set i 0} {$i < $opt(NumOfMN)} {incr i} {

$ns_ initial_node_pos $node_($i) 15

}

proc finish {} {

global ns node_ null_ nn2 opt trace namtrace namtrace_s sinkmpeg

puts "Finishing ns at time [$ns_ now]."

$ns_ flush-trace

close $trace

exit 0

}

puts "Starting Simulation..."

puts "Numero de nodos:$num_nodes"

$ns_ run
