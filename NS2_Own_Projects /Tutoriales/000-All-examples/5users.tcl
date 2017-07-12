#  TCL file for 5 users (5 streaming servers streaming to 5 User Equipments)




set ns [new Simulator]



set f [open out.tr w]

#$ns trace-all $f



proc finish {} {

    global ns

    global f

#    $ns flush-trace

    close $f

    puts " Simulation ended."

    exit 0

}



set max_fragmented_size   1024

set packetSize  1052



$ns node-config -UmtsNodeType rnc



# Node address is 0.

set rnc [$ns create-Umtsnode]



$ns node-config -UmtsNodeType bs \

                     -downlinkBW 32kbs \

                     -downlinkTTI 10ms \

                     -uplinkBW 32kbs \

                     -uplinkTTI 10ms \

             -hs_downlinkTTI 2ms \

                     -hs_downlinkBW 64kbs \



# Node address is 1.

set bs [$ns create-Umtsnode]



# Interface between RNC and BS

$ns setup-Iub $bs $rnc 622Mbit 622Mbit 15ms 15ms DummyDropTail 2000



$ns node-config -UmtsNodeType ue \

                     -baseStation $bs \

                     -radioNetworkController $rnc



set ue1 [$ns create-Umtsnode]

set ue2 [$ns create-Umtsnode]

set ue3 [$ns create-Umtsnode]

set ue4 [$ns create-Umtsnode]

set ue5 [$ns create-Umtsnode]

set ue6 [$ns create-Umtsnode]



# Node address for sgsn0 and ggsn0 is 6 and 7, respectively.

set sgsn0 [$ns node]

set ggsn0 [$ns node]



set node1 [$ns node]

set node2 [$ns node]

set node3 [$ns node]

set node4 [$ns node]

set node5 [$ns node]

set node6 [$ns node]



# Connections between fixed network nodes

$ns duplex-link $rnc $sgsn0 622Mbit 0.4ms DropTail 1000

$ns duplex-link $sgsn0 $ggsn0 622MBit 10ms DropTail 1000

$ns duplex-link $ggsn0 $node1 622MBit 15ms DropTail 1000

$ns duplex-link $node1 $node2 100MBit 35ms DropTail 1000

$ns duplex-link $node1 $node3 100MBit 35ms DropTail 1000

$ns duplex-link $node1 $node4 100MBit 35ms DropTail 1000

$ns duplex-link $node1 $node5 100MBit 35ms DropTail 1000

$ns duplex-link $node1 $node6 100MBit 35ms DropTail 1000



# Routing gateway

$rnc add-gateway $sgsn0



# Agent set-up for ue1

set myUDP0 [new Agent/myUDP]

$myUDP0 set fid_ 0

$myUDP0 set packetSize_ $packetSize

$myUDP0 set_filename sd_a00



# Agent set-up for ue2

set myUDP1 [new Agent/myUDP]

$myUDP1 set fid_ 1

$myUDP1 set packetSize_ $packetSize

$myUDP1 set_filename sd_a01



# Agent set-up for ue3

set myUDP2 [new Agent/myUDP]

$myUDP2 set fid_ 2

$myUDP2 set packetSize_ $packetSize

$myUDP2 set_filename sd_a02



# Agent set-up for ue4

set myUDP3 [new Agent/myUDP]

$myUDP3 set fid_ 3

$myUDP3 set packetSize_ $packetSize

$myUDP3 set_filename sd_a03



# Agent set-up for ue5

set myUDP4 [new Agent/myUDP]

$myUDP4 set fid_ 4

$myUDP4 set packetSize_ $packetSize

$myUDP4 set_filename sd_a04



# Attach agents to a common fixed node

$ns attach-agent $node2 $myUDP0

$ns attach-agent $node3 $myUDP1

$ns attach-agent $node4 $myUDP2

$ns attach-agent $node5 $myUDP3

$ns attach-agent $node6 $myUDP4



# Create and attach NULLs

set myUdpSink20 [new Agent/myUdpSink2]

$myUdpSink20 set fid_ 0

$ns attach-agent $ue1 $myUdpSink20

$myUdpSink20 set_trace_filename rd_a00



set myUdpSink21 [new Agent/myUdpSink2]

$myUdpSink21 set fid_ 1

$ns attach-agent $ue2 $myUdpSink21

$myUdpSink21 set_trace_filename rd_a01



set myUdpSink22 [new Agent/myUdpSink2]

$myUdpSink22 set fid_ 2

$ns attach-agent $ue3 $myUdpSink22

$myUdpSink22 set_trace_filename rd_a02



set myUdpSink23 [new Agent/myUdpSink2]

$myUdpSink23 set fid_ 3

$ns attach-agent $ue4 $myUdpSink23

$myUdpSink23 set_trace_filename rd_a03



set myUdpSink24 [new Agent/myUdpSink2]

$myUdpSink24 set fid_ 4

$ns attach-agent $ue5 $myUdpSink24

$myUdpSink24 set_trace_filename rd_a04



# Connect NULLs to rtp agents

$ns connect $myUDP0 $myUdpSink20

$ns connect $myUDP1 $myUdpSink21

$ns connect $myUDP2 $myUdpSink22

$ns connect $myUDP3 $myUdpSink23

$ns connect $myUDP4 $myUdpSink24



#############MPEG#####################

set original_file_name0 st_a00

set original_file_name1 st_a01

set original_file_name2 st_a02

set original_file_name3 st_a03

set original_file_name4 st_a04



set trace_file_name0 video1.dat

set trace_file_name1 video2.dat

set trace_file_name2 video3.dat

set trace_file_name3 video4.dat

set trace_file_name4 video5.dat



set original_file_id0 [open $original_file_name0 r]

set original_file_id1 [open $original_file_name1 r]

set original_file_id2 [open $original_file_name2 r]

set original_file_id3 [open $original_file_name3 r]

set original_file_id4 [open $original_file_name4 r]



set trace_file_id0 [open $trace_file_name0 w]

set trace_file_id1 [open $trace_file_name1 w]

set trace_file_id2 [open $trace_file_name2 w]

set trace_file_id3 [open $trace_file_name3 w]

set trace_file_id4 [open $trace_file_name4 w]



set frame_count0 0

set frame_count1 0

set frame_count2 0

set frame_count3 0

set frame_count4 0



while {[eof $original_file_id0] == 0} {

    gets $original_file_id0 current_line

    scan $current_line "%d%s%d%s%s%s%d%s" no_ frametype_ length_ tmp1_ tmp2_
tmp3_ tmp4_ tmp5_

    #puts "$no_ $frametype_ $length_ $tmp1_ $tmp2_ $tmp3_ $tmp4_ $tmp5_"



    # 30 frames/sec. if one want to generate 25 frames/sec, one can use set
time [expr 1000*1000/25]

    set time [expr 1000 * 1000/30]



    if { $frametype_ == "I" } {

            set type_v 1

    }



    if { $frametype_ == "P" } {

            set type_v 2

    }



    if { $frametype_ == "B" } {

            set type_v 3

    }



    if { $frametype_ == "H" } {

            set type_v 1

    }



    puts  $trace_file_id0 "$time $length_ $type_v $max_fragmented_size"

    incr frame_count0

}



while {[eof $original_file_id1] == 0} {

    gets $original_file_id1 current_line

    scan $current_line "%d%s%d%s%s%s%d%s" no_ frametype_ length_ tmp1_ tmp2_
tmp3_ tmp4_ tmp5_

    #puts "$no_ $frametype_ $length_ $tmp1_ $tmp2_ $tmp3_ $tmp4_ $tmp5_"



    # 30 frames/sec. if one want to generate 25 frames/sec, one can use set
time [expr 1000*1000/25]

    set time [expr 1000 * 1000/30]



    if { $frametype_ == "I" } {

            set type_v 1

    }



    if { $frametype_ == "P" } {

            set type_v 2

    }



    if { $frametype_ == "B" } {

            set type_v 3

    }



    if { $frametype_ == "H" } {

            set type_v 1

    }



    puts  $trace_file_id1 "$time $length_ $type_v $max_fragmented_size"

    incr frame_count1

}



while {[eof $original_file_id2] == 0} {

    gets $original_file_id2 current_line

    scan $current_line "%d%s%d%s%s%s%d%s" no_ frametype_ length_ tmp1_ tmp2_
tmp3_ tmp4_ tmp5_

    #puts "$no_ $frametype_ $length_ $tmp1_ $tmp2_ $tmp3_ $tmp4_ $tmp5_"



    # 30 frames/sec. if one want to generate 25 frames/sec, one can use set
time [expr 1000*1000/25]

    set time [expr 1000 * 1000/30]



    if { $frametype_ == "I" } {

            set type_v 1

    }



    if { $frametype_ == "P" } {

            set type_v 2

    }



    if { $frametype_ == "B" } {

            set type_v 3

    }



    if { $frametype_ == "H" } {

            set type_v 1

    }



    puts  $trace_file_id2 "$time $length_ $type_v $max_fragmented_size"

    incr frame_count2

}



while {[eof $original_file_id3] == 0} {

    gets $original_file_id3 current_line

    scan $current_line "%d%s%d%s%s%s%d%s" no_ frametype_ length_ tmp1_ tmp2_
tmp3_ tmp4_ tmp5_

    #puts "$no_ $frametype_ $length_ $tmp1_ $tmp2_ $tmp3_ $tmp4_ $tmp5_"



    # 30 frames/sec. if one want to generate 25 frames/sec, one can use set
time [expr 1000*1000/25]

    set time [expr 1000 * 1000/30]



    if { $frametype_ == "I" } {

            set type_v 1

    }



    if { $frametype_ == "P" } {

            set type_v 2

    }



    if { $frametype_ == "B" } {

            set type_v 3

    }



    if { $frametype_ == "H" } {

            set type_v 1

    }



    puts  $trace_file_id3 "$time $length_ $type_v $max_fragmented_size"

    incr frame_count3

}

while {[eof $original_file_id4] == 0} {

    gets $original_file_id4 current_line

    scan $current_line "%d%s%d%s%s%s%d%s" no_ frametype_ length_ tmp1_ tmp2_
tmp3_ tmp4_ tmp5_

    #puts "$no_ $frametype_ $length_ $tmp1_ $tmp2_ $tmp3_ $tmp4_ $tmp5_"



    # 30 frames/sec. if one want to generate 25 frames/sec, one can use set
time [expr 1000*1000/25]

    set time [expr 1000 * 1000/30]



    if { $frametype_ == "I" } {

            set type_v 1

    }



    if { $frametype_ == "P" } {

            set type_v 2

    }



    if { $frametype_ == "B" } {

            set type_v 3

    }



    if { $frametype_ == "H" } {

            set type_v 1

    }



    puts  $trace_file_id4 "$time $length_ $type_v $max_fragmented_size"

    incr frame_count4

}



close $original_file_id0

close $original_file_id1

close $original_file_id2

close $original_file_id3

close $original_file_id4



close $trace_file_id0

close $trace_file_id1

close $trace_file_id2

close $trace_file_id3

close $trace_file_id4



set end_sim_time0 [expr 1.0 * 1000/30 * ($frame_count0 + 1)  / 1000]

set end_sim_time1 [expr 1.0 * 1000/30 * ($frame_count1 + 1)  / 1000]

set end_sim_time2 [expr 1.0 * 1000/30 * ($frame_count2 + 1)  / 1000]

set end_sim_time3 [expr 1.0 * 1000/30 * ($frame_count3 + 1)  / 1000]

set end_sim_time4 [expr 1.0 * 1000/30 * ($frame_count4 + 1)  / 1000]



puts "$end_sim_time0"

puts "$end_sim_time1"

puts "$end_sim_time2"

puts "$end_sim_time3"

puts "$end_sim_time4"

#############MPEG#####################



set trace_file0 [new Tracefile]

$trace_file0 filename $trace_file_name0

set trace_file1 [new Tracefile]

$trace_file1 filename $trace_file_name1

set trace_file2 [new Tracefile]

$trace_file2 filename $trace_file_name2

set trace_file3 [new Tracefile]

$trace_file3 filename $trace_file_name3

set trace_file4 [new Tracefile]

$trace_file4 filename $trace_file_name4

set trace_file5 [new Tracefile]



# Create and connect four applications to their agent

set video0 [new Application/Traffic/myTrace2]

$video0 attach-agent $myUDP0

$video0 attach-tracefile $trace_file0



set video1 [new Application/Traffic/myTrace2]

$video1 attach-agent $myUDP1

$video1 attach-tracefile $trace_file1



set video2 [new Application/Traffic/myTrace2]

$video2 attach-agent $myUDP2

$video2 attach-tracefile $trace_file2



set video3 [new Application/Traffic/myTrace2]

$video3 attach-agent $myUDP3

$video3 attach-tracefile $trace_file3



set video4 [new Application/Traffic/myTrace2]

$video4 attach-agent $myUDP4

$video4 attach-tracefile $trace_file4



$ns node-config -llType UMTS/RLC/UM \

                      -downlinkBW 64kbs \

                      -uplinkBW 64kbs \

                      -downlinkTTI 20ms \

                      -uplinkTTI 20ms \

                      -hs_downlinkTTI 2ms \

                      -hs_downlinkBW 64kbs



UMTS/RLC/UMHS set macDA_                                           -1

UMTS/RLC/UMHS set win_
1024

UMTS/RLC/UMHS set temp_pdu_timeout_time                                2ms

UMTS/RLC/UMHS set credit_allocation_interval_                 30ms

UMTS/RLC/UMHS set flow_max_
20

UMTS/RLC/UMHS set priority_max_
5

UMTS/RLC/UMHS set buffer_level_max_
500

UMTS/RLC/UMHS set payload_
40

UMTS/RLC/UMHS set TTI_
2ms

UMTS/RLC/UMHS set length_indicator_
7

UMTS/RLC/UMHS set min_concat_data_
3





Mac/Hsdpa set delay_
10us

Mac/Hsdpa set TTI_
2ms

Mac/Hsdpa set flow_max_
20

Mac/Hsdpa set priority_max_
5

Mac/Hsdpa set reord_buf_size_                                             64

Mac/Hsdpa set stall_timer_delay_                               25ms

Mac/Hsdpa set credit_allocation_interval_       15

Mac/Hsdpa set flow_control_mode_                           1

Mac/Hsdpa set flow_control_rtt_
30ms

Mac/Hsdpa set mac_mac_hs_buffer_level                   250

Mac/Hsdpa set scheduler_type_                                             3

Mac/Hsdpa set alpha_
1

Mac/Hsdpa set mac_hs_headersize_                           21



# Configure HARQ Parameters

Mac/Hsdpa set nr_harq_rtx_
3

Mac/Hsdpa set nr_harq_processes_                           6

Mac/Hsdpa set ack_process_delay_                           15us



# Create HS-DSCH and attach null agent for ue1

$ns create-hsdsch $ue1 $myUdpSink20



# Attach rtp agents for ue2 ue3 and ue4 to existing HS-DSCH

$ns attach-hsdsch $ue2 $myUdpSink21

$ns attach-hsdsch $ue3 $myUdpSink22

$ns attach-hsdsch $ue4 $myUdpSink23

$ns attach-hsdsch $ue5 $myUdpSink24



#Loads input tracefiles for each UE, identified by its fid_

$bs setErrorTrace 0 "Ray_corr-3kmh-200m-850s-UEnr1"

$bs setErrorTrace 1 "Ray_corr-3kmh-200m-850s-UEnr2"

$bs setErrorTrace 2 "Ray_corr-3kmh-200m-850s-UEnr3"

$bs setErrorTrace 3 "Ray_corr-3kmh-200m-850s-UEnr4"

$bs setErrorTrace 4 "Ray_corr-3kmh-200m-850s-UEnr5"



# Load BLER lookup table from file SNRBLERMatrix

$bs loadSnrBlerMatrix "SNRBLERMatrix"



# Tracing for all HSDPA traffic in downtarget

$rnc trace-inlink $f 0

$bs trace-outlink $f 2



#  UE1 Tracing

$ue1 trace-inlink $f 2

$ue1 trace-outlink $f 3

$bs trace-inlink $f 3



# UE2 Tracing

$ue2 trace-inlink $f 2

$ue2 trace-outlink $f 3

$bs trace-inlink $f 4



#  UE3 Tracing

$ue3 trace-inlink $f 2

$ue3 trace-outlink $f 3

$bs trace-inlink $f 5



#  UE4 Tracing

$ue4 trace-inlink $f 2

$ue4 trace-outlink $f 3

$bs trace-inlink $f 6



#  UE5 Tracing

$ue5 trace-inlink $f 2

$ue5 trace-outlink $f 3

$bs trace-inlink $f 7



$ns at 0.0 "$video0 start"

$ns at 0.0 "$video1 start"

$ns at 0.0 "$video2 start"

$ns at 0.0 "$video3 start"

$ns at 0.0 "$video4 start"



$ns at $end_sim_time0 "$video0 stop"

$ns at $end_sim_time1 "$video1 stop"

$ns at $end_sim_time2 "$video2 stop"

$ns at $end_sim_time3 "$video3 stop"

$ns at $end_sim_time4 "$video4 stop"



$ns at [expr $end_sim_time0 + 1.0] "$myUdpSink20 closefile"

$ns at [expr $end_sim_time1 + 1.0] "$myUdpSink21 closefile"

$ns at [expr $end_sim_time2 + 1.0] "$myUdpSink22 closefile"

$ns at [expr $end_sim_time3 + 1.0] "$myUdpSink23 closefile"

$ns at [expr $end_sim_time4 + 1.0] "$myUdpSink24 closefile"



$ns at [expr $end_sim_time0 + 1.0] "finish"



puts " Simulation is running ... please wait ..."

$ns run

