#
# A wireless lan scenario with video/cbr traffic over udp
#
#

# defaults
set num_nodes          13	        ;#Number of nodes in the scenario
set endtime            20.0             ;#End of the simulation
set beacon_period      0.500            ;#Period of the beacon frames
set hcca_duration      0.49             ;# 0.49 to test almost completely FHCF or the Standard HCF
                                         # 0.001 to test EDCF
set std 0                               ;# 1 to use the Standard HCF scheme (draft 802.11e)

                                         # 0 to use FHCF (default)

#Audio flows - priority 6
set a 6                                 ;#Number of audio flows
set pktaudio    160   
set startaudio  2.9                     ;#Starting time of the audio flows

   #EDCF parameters
PHY_MIB set CWMin_6		7
PHY_MIB set CWMax_6		15
PHY_MIB set CWOffset_6		2

   #QoS requirements for the audio flows
TSPEC set MaxSI_6 50000
TSPEC set MSDUSize_6 $pktaudio
TSPEC set DataRate_6 64000


#Poisson flows - priority 4
set b 6                                 ;#Number of poisson flows
set pktpoisson	  380                   ;#Pkt size of the Poisson flows
set period	  2                     ;#Mean interarrival time in ms
set startpoisson  2.9                   ;#Starting time of the poisson flows

   #EDCF parameters   
PHY_MIB set CWMin_4		15
PHY_MIB set CWMax_4		31
PHY_MIB set CWOffset_4		2

   #QoS requirements for the poisson flows
TSPEC set MaxSI_4 100000
TSPEC set MSDUSize_4 $pktpoisson
TSPEC set DataRate_4 [expr $pktpoisson * 8 *1000 / $period]


#Background traffic in each node - priority 1
set pktbackground   256       ;#Pkt size of the background flwos
set periodback      6         ;#Period in ms for the background flows
set startback       2.9       ;#Starting time of the background flows

   #EDCF parameters   
PHY_MIB set CWMin_4		31
PHY_MIB set CWMax_4		1023
PHY_MIB set CWOffset_4		2

   #QoS requirements for the background flows
TSPEC set MaxSI_1 300000
TSPEC set MSDUSize_1 $pktpoisson
TSPEC set DataRate_1 [expr $pktbackground * 8 * 1000 / $periodback]



proc create_scenario { } {
    global ns_ node_ AP_ title_
    global pktaudio pktpoisson pktbackground
    global period periodback
    global a b
    global startaudio startpoisson startback
   

    #Audio flows
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
    
#Poisson flows
    for {set i 1} {$i <= $b} {set i [expr $i + 1]} {
 	set V([expr $a + $i])       [new Application/Traffic/Exponential]
	set V_src([expr $a + $i])	[new Agent/UDP]
	set V_sink([expr $a + $i])	[new Agent/UDP]

	$V([expr $a + $i]) attach-agent $V_src([expr $a + $i])
	$V([expr $a + $i]) set	packetSize_  $pktpoisson
        $V([expr $a + $i]) set      burst_time_ 0ms
        $V([expr $a + $i]) set      idle_time_ [expr $period]ms
	$V([expr $a + $i]) set	rate_ 6400000k

	$V_src([expr $a + $i]) set	packetSize_ $pktpoisson
	$V_src([expr $a + $i]) set	class_ [expr 10 + $i]
	$V_src([expr $a + $i]) set	prio_ 4

	$ns_ attach-agent $AP_ $V_sink([expr $a + $i])
	$ns_ attach-agent $node_([expr $a + $i]) $V_src([expr $a + $i])
	$ns_ connect $V_src([expr $a + $i]) $V_sink([expr $a + $i])

	puts "Poisson flow $i from Node [expr $i+$a] to AP"

    }

#Background flows
    for {set i 1} {$i <= $a+$b} {set i [expr $i + 1]} {
	set V([expr $a + $b + $i])		[new Application/Traffic/CBR]
	set V_src([expr $a + $b + $i])	[new Agent/UDP]
	set V_sink([expr $a + $b + $i])	[new Agent/UDP]
	
	$V([expr $a + $b + $i]) set		random_ 0
	$V([expr $a + $b + $i]) set		packetSize_ $pktbackground
	$V([expr $a + $b + $i]) set		interval_ [expr $periodback]ms
	$V_src([expr $a + $b + $i]) set	        packetSize_ $pktbackground
	$V_src([expr $a + $b + $i]) set	        class_ [expr 20 + $i]
	$V_src([expr $a + $b + $i]) set	        prio_ 1
	$ns_ attach-agent $node_($i) $V_src([expr $a + $b + $i])
	$ns_ attach-agent $AP_ $V_sink([expr $a + $b + $i])
	$ns_ connect $V_src([expr $a + $b + $i]) $V_sink([expr $a + $b + $i])
	$V([expr $a + $b + $i]) attach-agent $V_src([expr $a + $b + $i])
	puts "Background flows"
	
    }


    ##########################################################
    # Start time, nature of simulation
    
    for {set j 1} {$j <= $a} {set j [expr $j + 1]} {
	$ns_ at $startaudio	"$V($j) start"
	$ns_ at $startback      "$V([expr $a + $b + $j]) start"
    }
    for {set j 1} {$j <= $b} {set j [expr $j + 1]} {
	$ns_ at $startpoisson	"$V([expr $j + $a]) start"	
	$ns_ at $startback      "$V([expr $a + $b + $a + $j]) start"
    }	
        
    set phy_bw [Mac/802_11 set bandwidth_]
    set retries [MAC_MIB set ShortRetryLimit_]
    set pqlim [Queue/DropTail set pqlim_]
    set title_ "set title \"Various kinds of flows : Audio, Poisson and background\""
}
