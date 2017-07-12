
#===================================
#     Simulation parameters setup
#===================================

# Simulation end time
set val(stop)   10.0
# CBR Bit Rate                       
set val(rate)	400kb/s
# Initial RTCP report interval (ms)
set val(report_interval) 500ms

#===================================
#        Initialization        
#===================================

# Create a new ns simulator instance (multicast scenario)
set ns [new Simulator -multicast on]

# Open the NS trace file
set f [open rtp_scenario.tr w]
$ns trace-all $f

# Open the NAM trace file
$ns namtrace-all [open rtp_scenario.nam w]

# Open additional trace files (bandwidth and jitter)
set rtp_bw [open rtp-bw.tr w]
set j1 [open jitter1.tr w]

# Define colors for different data flows
$ns color 1 red
$ns color 2 purple
$ns color 3 pink
$ns color 4 orange
$ns color 5 green
$ns color 6 blue
$ns color 7 yellow
$ns color 8 bisque
$ns color 9 brown
$ns color 10 black

#===================================
# Nodes Definition and Configuration      
#===================================

# RTP Source
set sender_node [$ns node]
$sender_node color red
$sender_node shape "box"

# RTP Receiver node 1
set receiver_node1 [$ns node]
$receiver_node1 color red
$receiver_node1 shape "box"

# RTP Receiver node 2
set receiver_node2 [$ns node]
$receiver_node2 color red
$receiver_node2 shape "box"

# RTP Receiver node 3
set receiver_node3 [$ns node]
$receiver_node3 color red
$receiver_node3 shape "box"

# Topology routers
set router1 [$ns node]
set router2 [$ns node]
set router3 [$ns node]

#===================================
#        Links Definition        
#===================================

# Create links between the network components
# Queue type: DropTail, RED, CBQ, FQ, SFQ, DRR
$ns duplex-link $sender_node $router1 10Mb 10ms DropTail
#$ns queue-limit $sender_node $router1 50
$ns duplex-link $router1 $router2 10Mb 10ms DropTail
$ns duplex-link $router1 $router3 10Mb 10ms DropTail
$ns duplex-link $receiver_node1 $router1 10Mb 10ms DropTail
$ns duplex-link $router2 $receiver_node2 10Mb 10ms DropTail
$ns duplex-link $router3 $receiver_node3 10Mb 10ms DropTail

$ns duplex-link-op $sender_node $router1 orient right-up
$ns duplex-link-op $router1 $router2 orient right-up
$ns duplex-link-op $router1 $router3 orient right-down
$ns duplex-link-op $receiver_node1 $router1 orient right-down
$ns duplex-link-op $router2 $receiver_node2 orient right-up
$ns duplex-link-op $router3 $receiver_node3 orient right-down

#==========================================
# Routing Configuration        
#==========================================

#Routing Unicast Protocol
#$ns rtproto <Static, Session, DV>

### Multicast protocol configuration: <type> CtrMcast, DM, ST, BST
set mproto CtrMcast

# allocate a multicast addresses;
set group0 [Node allocaddr]
set group1 [Node allocaddr]

# all nodes will contain multicast protocol agents;
set mrthandle [$ns mrtproto $mproto {}]

#BST set RP_($group0) $router4
### Uncomment following lines to change default
#DM set PruneTimeout 0.3               ;# default 0.5 (sec)

$mrthandle set_c_rp $router1
#if {$mproto == "CtrMcast"} {
#    $mrthandle set_c_rp [list $n2 $n3]
#}

### End of multicast configuration

#==========================================
# Traffic Definition (Agents+Applications)        
#==========================================

# RTP Maximum Segmemt Size (MSS), bytes
set packetSize	1000

#==========================================
# RTP Sender Node Configuration
#==========================================

# RTP Agent
set rtp0 [new Agent/RTP_gs]
$rtp0 set packetSize_ $packetSize
$rtp0 set seqno_ 0
$ns attach-agent $sender_node $rtp0
# Output trace file for RTP source packets registering
$rtp0 tx_tracefile trace_rtpsender0
$rtp0 set dst_addr_ $group0
$rtp0 set dst_port_ 0
$rtp0 set class_ 1
$rtp0 set fid_ 1	     ;#red color

# RTCP Agent
set RTCP_s [new Agent/RTCP_gs] 
$ns attach-agent $sender_node $RTCP_s
$RTCP_s set dst_addr_ $group1
$RTCP_s set dst_port_ 0
#$RTP_s set class_ 2
$RTCP_s set fid_ 2	;#purple color
$RTCP_s set interval_ $val(report_interval) 
$RTCP_s set random_ 1 

# RTP Session
set s0 [new Session/RTP_gs]
$s0 attach-node $sender_node
# Output trace file for incoming RTCP RR registering. Each column represents: SSRC of Receiving Node, SSRC of Source Being Reported, SSRC of Sending Node,CNAME of Sending Node,Reception Time,Round Trip Time, Jitter, Fraction Lost (flost),Cumulative Number of Packet Lost since the beginning of the session
$s0 set_trace_rr rtcp_rr_s0

$s0 session_bw $val(rate)
$rtp0 session $s0
$RTCP_s session $s0

# Assign a numeric cname to a participant as follows: XY --> X refers to the role of the participant: 1=sender; 2=receiver; 3=sender&receiver; Y refers to the participant id: Y=1,2, ....
$s0 cname 11

# CBR Application Traffic Pattern
set cbr0 [new Application/Traffic/CBR]
# The CBR Application (Traffic patter) is attached to the RTP Sender Agent
$cbr0 attach-agent $rtp0
$cbr0 set type_ CBR
$cbr0 set packetsize_ $packetSize
$cbr0 set rate_ $val(rate)
$cbr0 set random_ true

#==========================================
# RTP Receiver Nodes Configuration
#==========================================

# Receiver 1
#==========================================

#RTP Agent
set rtp1 [new Agent/RTP_gs]
$ns attach-agent $receiver_node1 $rtp1
# This trace file records the RTP packets received by the RTP Agent. Each column represents: receiving time, sequence number, packet size
$rtp1 rec_tracefile trace_rtp_r1 
# This trace file records the RTP lost packets that have not been received by the RTP Agent
$rtp1 lost_tracefile rtp_lost_r1

#RTCP Agent
set RTCP_r1 [new Agent/RTCP_gs] 
$ns attach-agent $receiver_node1 $RTCP_r1
$RTCP_r1 set dst_addr_ $group1
$RTCP_r1 set dst_port_ 0

$RTCP_r1 set fid_ 3	;#green color
$RTCP_r1 set interval_ $val(report_interval) 
$RTCP_r1 set random_ 1 

# RTP Session
set s1 [new Session/RTP_gs]
$s1 attach-node $receiver_node1
# This trace file records the RTP packets received by the RTP Session. Each column represents: SSRC of Receiving Node, SSRC of Sending Node, Sequence Number, Network Delay, Jitter, Cumulative Number of Packets Lost since the beginning of the session
$s1 set_trace_rtp trace_rtp_s1
# Output trace file for incoming RTCP SR registering. Each column represents: SSRC of Receiving Node, SSRC of Sending Node, CNAME of Sending Node, Reception Time, Total Packets Sent, Total Octets Sent
$s1 set_trace_sr rtcp_sr_s1
$rtp1 session $s1
$RTCP_r1 session $s1
$s1 session_bw $val(rate)

# Assign a numeric cname to a participant as follows: XY --> X refers to the role of the participant: 1=sender; 2=receiver; 3=sender&receiver; Y refers to the participant id: Y=1,2, ....
$s1 cname 21

# Receiver 2
#==========================================

#RTP Agent
set rtp2 [new Agent/RTP_gs]
$ns attach-agent $receiver_node2 $rtp2
# This trace file records the RTP packets received by the RTP Agent. Each column represents: receiving time, sequence number, packet size
$rtp2 rec_tracefile trace_rtp_r2
# This trace file records the RTP lost packets that have not been received by the RTP Agent 
$rtp2 lost_tracefile rtp_lost_r2

#RTCP Agent
set RTCP_r2 [new Agent/RTCP_gs] 
$ns attach-agent $receiver_node2 $RTCP_r2
$RTCP_r2 set dst_addr_ $group1
$RTCP_r2 set dst_port_ 0
#$RTP_s set class_ 3
$RTCP_r2 set fid_ 3	;#pink color
$RTCP_r2 set interval_ $val(report_interval) 
$RTCP_r2 set random_ 1 

# RTP Session
set s2 [new Session/RTP_gs]
$s2 attach-node $receiver_node2
# This trace file records the RTP packets received by the RTP Session. Each column represents: SSRC of Receiving Node, SSRC of Sending Node, Sequence Number, Network Delay, Jitter, Cumulative Number of Packets Lost since the beginning of the session
$s2 set_trace_rtp trace_rtp_s2
# Output trace file for incoming RTCP SR registering. Each column represents: SSRC of Receiving Node, SSRC of Sending Node, CNAME of Sending Node, Reception Time, Total Packets Sent, Total Octets Sent
$s2 set_trace_sr rtcp_sr_s2
$rtp2 session $s2
$RTCP_r2 session $s2
$s2 session_bw $val(rate)

# Assign a numeric cname to a participant as follows: XY --> X refers to the role of the participant: 1=sender; 2=receiver; 3=sender&receiver; Y refers to the participant id: Y=1,2, ....
$s2 cname 22

# Receiver 3
#==========================================

#RTP Agent
set rtp3 [new Agent/RTP_gs]
$ns attach-agent $receiver_node3 $rtp3
# This trace file records the RTP packets received by the RTP Agent. Each column represents: receiving time, sequence number, packet size
$rtp3 rec_tracefile trace_rtp_r3
# This trace file records the RTP lost packets that have not been received by the RTP Agent 
$rtp3 lost_tracefile rtp_lost_r3

#RTCP Agent
set RTCP_r3 [new Agent/RTCP_gs] 
$ns attach-agent $receiver_node3 $RTCP_r3
$RTCP_r3 set dst_addr_ $group1
$RTCP_r3 set dst_port_ 0
#$RTP_s set class_ 3
$RTCP_r3 set fid_ 4	;#pink color
$RTCP_r3 set interval_ $val(report_interval) 
$RTCP_r3 set random_ 1 

# RTP Session
set s3 [new Session/RTP_gs]
$s2 attach-node $receiver_node3
# This trace file records the RTP packets received by the RTP Session. Each column represents: SSRC of Receiving Node, SSRC of Sending Node, Sequence Number, Network Delay, Jitter, Cumulative Number of Packets Lost since the beginning of the session
$s3 set_trace_rtp trace_rtp_s3
# Output trace file for incoming RTCP SR registering. Each column represents: SSRC of Receiving Node, SSRC of Sending Node, CNAME of Sending Node, Reception Time, Total Packets Sent, Total Octets Sent
$s3 set_trace_sr rtcp_sr_s3
$rtp3 session $s3
$RTCP_r3 session $s3
$s3 session_bw $val(rate)

# Assign a numeric cname to a participant as follows: XY --> X refers to the role of the participant: 1=sender; 2=receiver; 3=sender&receiver; Y refers to the participant id: Y=1,2, ....
$s3 cname 23

#==========================================
# Background Traffic Configuration
#==========================================



#==========================================
# Events Configuration
#==========================================

$ns at 0 "$sender_node label \"RTP Sender\""
$ns at 0 "$receiver_node1 label \"RTP Receiver 1\""
$ns at 0 "$receiver_node2 label \"RTP Receiver 2\""
$ns at 0 "$receiver_node3 label \"RTP Receiver 3\""
$ns at 0 "$router1 label \"Router 1\""
$ns at 0 "$router2 label \"Router 2\""
$ns at 0 "$router3 label \"Router 3\""
#===========================================
# Multicast RTP Session Join/Leave Processes
#===========================================

$ns at 0.0 "$sender_node join-group $RTCP_s $group1"
$ns at 0.0 "$RTCP_s start"

$ns at 0.0 "$receiver_node1 join-group $rtp1 $group0"
$ns at 0.0 "$receiver_node1 join-group $RTCP_r1 $group1"
$ns at 0.0 "$RTCP_r1 start"

$ns at 0.0 "$receiver_node2 join-group $rtp2 $group0"
$ns at 0.0 "$receiver_node2 join-group $RTCP_r2 $group1"
$ns at 0.0 "$RTCP_r2 start"

$ns at 0.0 "$receiver_node3 join-group $rtp3 $group0"
$ns at 0.0 "$receiver_node3 join-group $RTCP_r3 $group1"
$ns at 0.0 "$RTCP_r3 start"

$ns at 1.0 "$cbr0 start"

$ns at 2.0 "$RTCP_r1 bye"
$ns at 2.0 "$receiver_node1 leave-group $rtp1 $group0"
$ns at 2.0 "$receiver_node1 leave-group $RTCP_r1 $group1"

$ns at 3.0 "$receiver_node1 join-group $rtp1 $group0"
$ns at 3.0 "$receiver_node1 join-group $RTCP_r1 $group1"
$ns at 3.0 "$RTCP_r1 start"

#===================================
#        Recording
#===================================

$ns at 1.0 "record-rtp-bw"
$ns at 1.0 "record-jitter"

# Record RTP Sender transmission rate
proc record-rtp-bw {} {
      global s0 rtp_bw
        set ns [Simulator instance]
        set time  1
	set bw  [$s0 set txBW_]
	set now [$ns now]
        puts $rtp_bw "$now $bw"
        $ns at [expr $now+$time] "record-rtp-bw"
}

# Record RTP Receiver jitter
proc record-jitter {} {
      global s1 j1
        set ns [Simulator instance]
        set time 0.04
	set j  [$s1 set jitter_]
	set now [$ns now]
        puts $j1 "$now $j"
        $ns at [expr $now+$time] "record-jitter"
}

$ns at $val(stop) "finish"

proc finish {} {
	global ns rtp_bw
	$ns flush-trace
	close $rtp_bw
	puts "running nam..."
	#your nam path ...
	exec /usr/local/ns-allinone-2.34/nam-1.14/nam rtp_scenario.nam &
	#Call xgraph to display the results
    	#exec /usr/local/ns-allinone-2.34/xgraph rtp-bw.tr -geometry 800x400  &
	exit 0
}

$ns run
