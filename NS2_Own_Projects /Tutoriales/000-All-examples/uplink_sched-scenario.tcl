#
# A wireless lan scenario with video/cbr traffic over udp
#
#

# defaults
set num_nodes            19	       ;#Number of nodes in the scenario
set endtime              20.0          ;#End of the simulation
set beacon_period        0.500         ;#Period of the beacon frames
set hcca_duration        0.49          ;# 0.49 to test almost completely FHCF or the Standard HCF
                                        # 0.001 to test EDCF
set std                  0             ;# 1 to use the Standard HCF scheme (draft 802.11e)
                                        # 0 to use FHCF (default)

#Audio flows - priority 6
set a 6                                ;#Number of audio flows
set pktaudio 160                       ;#Packet size of the audio flows
set startaudio 0.0                     ;#Starting time of the audio flows

   #EDCF parameters
PHY_MIB set CWMin_6		7
PHY_MIB set CWMax_6		15
PHY_MIB set CWOffset_6		2

   #QoS requirements for the audio flows
TSPEC set MaxSI_6 50000                ;#Max required SI
TSPEC set MSDUSize_6 $pktaudio         ;#Packet size
TSPEC set DataRate_6 64000             ;#Sending rate of the audio encoder (max sending rate)

#VBR H.261 video traffic - priority 5
set b 6                                ;#Number of VBR flows
set pktvideoVIC 660                    ;#Mean packet size of the VBR flows
set startVBR  0.0                      ;#Starting time of the VBR flows

   #EDCF parameters   
PHY_MIB set CWMin_5		15
PHY_MIB set CWMax_5		31
PHY_MIB set CWOffset_5		2

    #QoS requirements for the VBR flwos
TSPEC set MaxSI_5 100000
TSPEC set MSDUSize_5 $pktvideoVIC      ;#Mean packet size obtained by analysing the trace files
TSPEC set DataRate_5 200000            ;#Mean data rate obtained by analysing the trace files

#CBR MPEG4 traffic - priority 4
set c 6                                ;#Number of CBR flows
set pktvideoCBR 800                    ;#Packet size of the CBR flows
set periodCBR  2                       ;#Period of the CBR MPEG4 flows (in ms)
set startCBR   0.0                     ;#Starting time of the CBR flows

   #EDCF parameters   
PHY_MIB set CWMin_4		15
PHY_MIB set CWMax_4		31
PHY_MIB set CWOffset_4		2

    #QoS requirements for the CBR flows
TSPEC set MaxSI_4 50000
TSPEC set MSDUSize_4 $pktvideoCBR
TSPEC set DataRate_4 3200000

proc create_scenario { } {
    global ns_ node_ AP_ title_
    global endtime
    global pktaudio pktvideoCBR pktvideoVIC
    global a b c
    global startaudio startVBR startCBR
    global periodCBR

#Audio traffic
    for {set i 1} {$i <= $a} {set i [expr $i + 1]} {
	set V($i)       [new Application/Traffic/Exponential]
	set V_src($i)	[new Agent/UDP]
	set V_sink($i)	[new Agent/UDP]
	
	$V($i) attach-agent $V_src($i)
	$V($i) set	packetSize_  $pktaudio
        $V($i) set      burst_time_ 400ms
        $V($i) set      idle_time_ 600ms
	$V($i) set	rate_ [expr ($pktaudio*8)/20]k

	$V_src($i) set	packetSize_ $pktaudio
	$V_src($i) set	class_ $i
	$V_src($i) set	prio_ 6

	$ns_ attach-agent $AP_ $V_sink($i)
	$ns_ attach-agent $node_($i) $V_src($i)
	$ns_ connect $V_src($i) $V_sink($i)

	puts "Audio flow $i from Node $i to AP"
    } 



#VBR H.261 video traffic
    for {set i 1} {$i <= $b} {set i [expr $i + 1]} {

	set V_src([expr 10 + $i])	[new Agent/UDP]
	set V_sink([expr 10 + $i])	[new Agent/UDP]

        $V_src([expr 10 + $i]) set fid_ 1
        $V_sink([expr 10 + $i]) set fid_ 1
    
	$V_src([expr 10 + $i]) set	class_ [expr 10 + $i]
	$V_src([expr 10 + $i]) set	prio_ 5

	$ns_ attach-agent $AP_ $V_sink([expr 10 + $i])
	$ns_ attach-agent $node_([expr $a + $i]) $V_src([expr 10 + $i])
	$ns_ connect $V_src([expr 10 + $i]) $V_sink([expr 10 + $i])


	set original_file_name($i) vic.QCIF.30fps.[expr 7 - $i]
	set trace_file_name($i) video$i.dat
	set original_file_id($i) [open $original_file_name($i) r]
	set trace_file_id($i) [open $trace_file_name($i) w]
	set last_time 0
	
	while {[eof $original_file_id($i)] == 0} {
	    gets $original_file_id($i) current_line
	    
	    if {[string length $current_line] == 0 ||
		[string compare [string index $current_line 0] "#"] == 0} {
		continue  
	    }
	    
	    scan $current_line "%d%s%d" next_time type length
	    set time [expr 1000*($next_time-$last_time)]
	    set last_time $next_time
	    puts -nonewline $trace_file_id($i) [binary format "II" $time $length]
	}
	
	close $original_file_id($i)
	close $trace_file_id($i)
	
	# read the video trace file:
	
	set trace_file($i) [new Tracefile]
	$trace_file($i) filename $trace_file_name($i)
	
	set V([expr 10 + $i]) [new Application/Traffic/Trace]
	$V([expr 10 + $i]) attach-agent $V_src([expr 10 + $i])
	$V([expr 10 + $i]) attach-tracefile $trace_file($i)
	puts "VBR H.261 video flow [expr 10 + $i] from Node [expr $i+$a] to AP"

    }

#CBR MPEG4 traffic
    for {set i 1} {$i <= $c} {set i [expr $i + 1]} {

	set V([expr 20+$i])		[new Application/Traffic/CBR]
	set V_src([expr 20 + $i])	[new Agent/UDP]
	set V_sink([expr 20+$i])	[new Agent/UDP]

	$V([expr 20+$i]) set		random_ 0
        $V([expr 20 + $i]) set		packetSize_ $pktvideoCBR
        $V([expr 20 + $i]) set		interval_ [expr $periodCBR]ms
        $V_src([expr 20 + $i]) set	        packetSize_ $pktvideoCBR
	$V_src([expr 20 + $i]) set	        class_ [expr 20 + $i]
	$V_src([expr 20 + $i]) set	        prio_ 4
	$ns_ attach-agent $node_([expr $a + $b + $i]) $V_src([expr 20 + $i])
	$ns_ attach-agent $AP_ $V_sink([expr 20 + $i])
	$ns_ connect $V_src([expr 20 + $i]) $V_sink([expr 20 + $i])
	$V([expr 20 + $i]) attach-agent $V_src([expr 20 + $i]) 	
	puts "CBR MPEG 4 video flow [expr 20+$i] from Node [expr $i+$a+$b] to AP"

    }



    ##########################################################
    # Start time, nature of simulation
    
    
    for {set j 1} {$j <= $b} {set j [expr $j + 1]} {
	$ns_ at $startVBR	"$V([expr $j +10]) start"
    }

    for {set j 1} {$j <= $c} {set j [expr $j + 1]} {
	$ns_ at $startCBR	"$V([expr $j +20]) start"
    }	    

    for {set j 1} {$j <= $a} {set j [expr $j + 1]} {
	$ns_ at $startaudio	"$V($j) start"
    }
    
    
    set phy_bw [Mac/802_11 set bandwidth_]
    set retries [MAC_MIB set ShortRetryLimit_]
    set pqlim [Queue/DropTail set pqlim_]
    set title_ "set title \"VBR, CBR and audio flows - one flow per station\""
}
