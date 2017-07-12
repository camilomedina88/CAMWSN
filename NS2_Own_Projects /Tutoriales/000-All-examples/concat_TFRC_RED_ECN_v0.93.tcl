###########################################################
## concat_TFRC_RED_ECN_v0.93.tcl 11-02-2006              ##
##                                                       ##
## Example tcl script for ns-2 that includes             ##
## possibilities to select trace file input as well as   ##
## CBR-RA/TFRC, RA-SVBR/TFRC and FTP/TCP traffic.        ##
## The trace file input                                  ##
## runs the Evalvid-RA engine.                           ##
##                                                       ##
###########################################################
## THIS VERSION HAS FOUR BOTTLENECKS WITH CROSS-TRAFFIC  ##
## (parking lot). See header for usage                   ##
###########################################################
# Version for interfaceing to Evalvid_RA @ both frame     #
# and GOP level. Uses TFRC CC and RED routers w/ ECN      #
###########################################################
set ns [new Simulator]
set simtime 64       ;# Simulation time in seconds

# Source maximum rates
set vbr_rate 1.0e6  ;# Evalvid-RA video: select base rate on VBR sources (includes IP overhead)
set cbr_rate 2.5e6  ;# Rate adaptiv CBR sources max rate

# Link capacities
set access_cap 30Mb       ;# access link capacities
set bottleneck_cap 40.0e6 ;# between r0 and r1
set bottleneck_cap2 50e6  ;# between all other routers

# Link propagation delays
set access_del 0.005
set bottleneck_del [expr 0.010 / 4]

# Number of sources
set numb_ftp 0        ;# Number of FTP over TCP flows
set numb_vbr 64       ;# Number of VBR over UDP flows                       (r0-r1-r2-r3-r4)
set numb_vbr_off 0    ;# This is how many flows of numb_vbr that goes only (r0-r1)
set numb_nonCC_cbr 0  ;# This is misbehaving flows traversing all network (r0-r1-r2-r3-r4)
set numb_nonCC_cbr1 0 ;# This is for x-traffic, i.e. via r1 and r2          (r1-r2)
set numb_nonCC_cbr2 0 ;# This is for x-traffic, i.e. via r2 and r3             (r2-r3)
set numb_nonCC_cbr3 0 ;# This is for x-traffic, i.e. via r3 and r4                (r3-r4)
#                      
#              numb_nonCC_cbr1(src)
#                            |  ..cbr2(src)
#                            |      |  ..cbr3(src)
# numb_ftp(src) --\          V      V     V            / ---->numb_ftp(dst)
#                  --(r0)---(r1)--(r2)--(r3)--(r4)----
# numb_vbr(src) --/      |           |     |      |    \---->numb_vbr(dst)
#                /       |           |     V  ..cbr3(dst)
# numb_nonCC_cbr/        |           V  ..cbr2(dst)
#                        V    numb_nonCC_cbr1(dst)
#                   numb_vbr_off(dst)
#
#

set q_variants 30 ;# Evalvid-RA, number of quantiser scale range
set max_fragmented_size   1000 ;# Evalvid-RA, MTU
set frames_per_second 30       ;# Evalvid-RA, All video is treated with equal fps
#add udp header(8 bytes) and IP header (20bytes):
#set packetSize	[expr $max_fragmented_size + 28]
#add DCCP/TFRC header(12+4=16 bytes) and IP header (20bytes):
set packetSize	[expr $max_fragmented_size + 36]

set p_aqm_true 2 ;# 0 = droptail, 1=P-AQM, 2=RED
set poisson_true 0 ;# 0 = VBR, 1 = poisson for the long-distance traffic r(0)-r(4)
set cbr_true 0     ;# 0 = RA-VBR, 1 = CBR_RA
set poisson_xt_true 0 ;# same as above, but for all the x-traffic
set xt_nonCC 0 ;# define if x-traffic is ECF aware (=0) or not (=1)
set mean_psize $packetSize
set count_bytes 1 ;# 1 = true (qib_ true), 0 = false (count packets)
#
#
set queueSize [expr 4*250] ;# This is the size of both the TCP and the UDP queue (was 800)
set NstarSet  [expr 4*125] ;# This is the size of the N* in TCP queue

set targetD [expr $NstarSet * $packetSize * 8 / $bottleneck_cap]
# The time granularity of inner loop (both UDP and TCP):
set updT [expr 100 * $packetSize * 8 / $bottleneck_cap ] 
#puts "updT=$updT"

$ns color 0 blue
$ns color 1 red
$ns color 2 green
$ns color 4 yellow
$ns color 3 chocolate

# SETTING GLOBAL TFRC DEFAULTS:
Agent/TFRC set ss_changes_ 1 ; 	# Added on 10/21/2004
Agent/TFRC set slow_increase_ 1 ; 	# Added on 10/20/2004
Agent/TFRC set rate_init_ 2 ;
Agent/TFRC set rate_init_option_ 2 ;    # Added on 10/20/2004

Agent/TFRC set SndrType_ 1 
Agent/TFRC set oldCode_ false
Agent/TFRC set packetSize_ $packetSize
Agent/TFRC set maxqueue_ 500
Agent/TFRC set printStatus_ true
Agent/TFRC set ecn_ 1 ;# Enable ECN
Agent/TFRC set useHeaders_ false
#Agent/TFRC set voip_ 1
#Agent/TFRC set voip_max_pkt_rate_ 1000 ; # In packets per second
#Agent/TCP set packetSize_ 500
#Application/Traffic/CBR set packetSize_ 500
#Agent/TCP set window_ 1000
#Agent/TCP set partial_ack_ 1

#Open the files for nam trace
set f [open out.tr w]
$ns trace-all $f
#set nf [open out.nam w]
#$ns namtrace-all $nf

#Open the output files for xgraph
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]


##
## Create the nodes, links and queue types for the Bottleneck of the Dumbbell
##
set r(0) [$ns node]
set r(1) [$ns node]
set r(2) [$ns node]
set r(3) [$ns node]
set r(4) [$ns node]
#$ns trace-queue $r(1) $r(2) $f
if {$p_aqm_true == 2} {
    $ns simplex-link $r(0) $r(1) $bottleneck_cap $bottleneck_del RED
    $ns simplex-link $r(1) $r(2) $bottleneck_cap2 $bottleneck_del RED
    $ns simplex-link $r(2) $r(3) $bottleneck_cap2 $bottleneck_del RED
    $ns simplex-link $r(3) $r(4) $bottleneck_cap2 $bottleneck_del RED
} else {
    $ns simplex-link $r(0) $r(1) $bottleneck_cap $bottleneck_del DropTail
    $ns simplex-link $r(1) $r(2) $bottleneck_cap2 $bottleneck_del DropTail
    $ns simplex-link $r(2) $r(3) $bottleneck_cap2 $bottleneck_del DropTail
    $ns simplex-link $r(3) $r(4) $bottleneck_cap2 $bottleneck_del DropTail
}
$ns simplex-link $r(1) $r(0) $bottleneck_cap $bottleneck_del DropTail
$ns simplex-link $r(2) $r(1) $bottleneck_cap2 $bottleneck_del DropTail
$ns simplex-link $r(3) $r(2) $bottleneck_cap2 $bottleneck_del DropTail
$ns simplex-link $r(4) $r(3) $bottleneck_cap2 $bottleneck_del DropTail

## Access Nodes and Links for TCP
for {set i 0} {$i <  [expr $numb_ftp+$numb_vbr+$numb_nonCC_cbr]} {incr i} { # Added one extra for the ill-behaving source
    set n([expr $i*2+0]) [$ns node]
    set n([expr $i*2+1]) [$ns node]
    if {$i < 0.5*$numb_vbr} {
	$ns duplex-link $n([expr $i*2+0]) $r(0)  $access_cap [expr $access_del+0.000002*$i] DropTail
    } else {
	$ns duplex-link $n([expr $i*2+0]) $r(0)  $access_cap [expr $access_del+0.000005*$i] DropTail
    }
    if {($i >= ($numb_vbr - $numb_vbr_off)) && ($i < $numb_vbr)} {
	$ns duplex-link $r(1) $n([expr $i*2+1])  $access_cap [expr 0.010+0.000001*$i] DropTail
    } else {
	$ns duplex-link $r(4) $n([expr $i*2+1])  $access_cap [expr $access_del+0.000001*$i] DropTail
    }
}
for {set i 0} {$i <  $numb_nonCC_cbr1} {incr i} { # Added one extra for the ill-behaving source
    set cr([expr $i*2]) [$ns node]
    set cr([expr $i*2+1]) [$ns node]
    $ns duplex-link $cr([expr $i*2]) $r(1)  $access_cap [expr $access_del+0.000001*$i] DropTail
    $ns duplex-link $r(2) $cr([expr $i*2+1])  $access_cap [expr 0.010+0.000] DropTail
}
for {set i 0} {$i <  $numb_nonCC_cbr2} {incr i} { # Added one extra for the ill-behaving source
    set cr2([expr $i*2]) [$ns node]
    set cr2([expr $i*2+1]) [$ns node]
    $ns duplex-link $cr2([expr $i*2]) $r(2)  $access_cap [expr $access_del+0.000001*$i] DropTail
    $ns duplex-link $r(3) $cr2([expr $i*2+1])  $access_cap [expr 0.010+0.000] DropTail
}
for {set i 0} {$i <  $numb_nonCC_cbr3} {incr i} { # Added one extra for the ill-behaving source
    set cr3([expr $i*2]) [$ns node]
    set cr3([expr $i*2+1]) [$ns node]
    $ns duplex-link $cr3([expr $i*2]) $r(3)  $access_cap [expr $access_del+0.000001*$i] DropTail
    $ns duplex-link $r(4) $cr3([expr $i*2+1])  $access_cap [expr 0.010+0.000] DropTail
}



#$ns trace-queue $n(0) $r(0) $f
#$ns trace-queue $r(4) $n(1) $f




##
## Configure Paqm queue parameters here
##
if {$p_aqm_true == 1} {
    puts "This TCL only supports Droptail or RED, set to 0 or 2"

} elseif {$p_aqm_true == 2} {
    ##
    ## Configure RED aqm queue parameters here
    ##
    set red_aqm [[$ns link $r(0) $r(1)] queue]
    $red_aqm set setbit_ true
    $red_aqm set bytes_ true
    $red_aqm set queue_in_bytes_ true
    $red_aqm set thresh_ 0
    $red_aqm set maxthresh_ 0
    $red_aqm set mean_pktsize_ 1036
    $red_aqm set q_weight_ -1
    $red_aqm set linterm_ 40
    $red_aqm set wait_ true
    $red_aqm set gentle_ true
    $red_aqm set adaptive_ true
    $red_aqm set drop_tail_ true 
    $red_aqm set targetdelay_ $targetD

    #set the queue-limit between n(0) and n(1)
    $ns queue-limit $r(0) $r(1) $queueSize
    
    ## This queue tracing stores all changes to selected parameters in file all.q:
    puts "Make RED trace variables"
    $red_aqm trace curq_        ;# trace current queue size
    $red_aqm trace prob1_       ;# trace probability of drop/mark
    $red_aqm trace ave_         ;# trace average queue in RED
    set tchan_ [open all.q w]
    $red_aqm attach $tchan_
} else {
    set droptail_q [[$ns link $r(0) $r(1)] queue]
    #$droptail_q trace curq_        ;# trace current queue size
    #$droptail_q trace prob_        ;# trace probability of drop/mark
    #set tchan_ [open all.q w]
    #$droptail_q attach $tchan_
   $ns queue-limit $r(0) $r(1) $queueSize
}

set f4 [open outqm.tr w]
set qmon [$ns monitor-queue $r(0) $r(1) $f4 0.01] 
#set qmon [$ns monitor-queue $r(0) $r(1) ""] 
[$ns link $r(0) $r(1)] queue-sample-timeout
$qmon set pdrops_

#set f7 [open outqm2.tr w]
#set qmon [$ns monitor-queue $r(1) $r(2) $f7 0.01] 
#set qmon [$ns monitor-queue $n(0) $n(1) ""] 
#[$ns link $r(1) $r(2)] queue-sample-timeout
#$qmon set pdrops_

#set f8 [open outqm3.tr w]
#set qmon [$ns monitor-queue $r(2) $r(3) $f8 0.01] 
#set qmon [$ns monitor-queue $n(0) $n(1) ""] 
#[$ns link $r(2) $r(3)] queue-sample-timeout
#$qmon set pdrops_

#set f9 [open outqm4.tr w]
#set qmon [$ns monitor-queue $r(3) $r(4) $f9 0.01] 
#set qmon [$ns monitor-queue $n(0) $n(1) ""] 
#[$ns link $r(3) $r(4)] queue-sample-timeout
#$qmon set pdrops_


##
## The last procedure to run
##
proc finish {} {
    global ns f nf f0 f1 f2 f3 f4 qfile tchan2_ qmon bottleneck_cap simtime outfile
    $qmon instvar bdrops_ bdepartures_

    set utlzn [expr ($bdepartures_ * 8.0)/($bottleneck_cap * $simtime)]
    set d [expr 1.0*$bdrops_ / ($bdrops_ + $bdepartures_)]

    puts "\n#################statistics######################"
    puts "#Bytes of drops     : $bdrops_ "
    puts "#Bytes of departures: $bdepartures_ "
    puts "drops stats         : $d "
    puts "utilization         : $utlzn "

    # awkCode is for making plot of queue at bottleneck
    set awkCode {
	{
	    if ($1 == "Q" && NF>2) {
		print $2, $3 >> "temp.q";
		set end $2
	    }
	    if ($1 == "3" && NF>2) {
	    	print $2, $3 >> "tempUDP.q";
	    	set end $2
	    }
	    else if ($1 == "p" && NF>2)
	    print $2, $3 >> "temp.p";
	    else if ($1 == "a" && NF>2)
	    print $2, $3 >> "temp.a";
	    else if ($1 == "2" && NF>2)
	    print $2, $3 >> "tempUDP.p";
	}
    }

    # awkCode2 is for plotting cwnd of selected TCP source
    set awkCode2 {
	BEGIN {
	    # simple awk script to generate plot file for congestion window
	    # in a form suitable for plotting with xgraph.
	    # Lloyd Wood, July 1999.
	    # http://www.ee.surrey.ac.uk/Personal/L.Wood/ns/
	    # Arne Lie: added some modifications Sept 2004
	    # INPUT PARAMS: source must be given as s=4 in the command line, destination as d=5
	    
	    n = 0;
	}
	{
	    time = $2;
	    source = $4;
	    dest = $8;
	    cwnd = $18;

	    if (( source == s ) && (dest == d)) {
		cwnd_time[n] = time;
		cwnd_arr[n++] = cwnd;
	    }
	}
							  
	END {
	    for ( i = 0; i < n; i++ ) {
                 printf("%f %d\n", cwnd_time[i], cwnd_arr[i]);
                 #print cwnd_time[i], cwnd_arr[i] >> "cwnd_res.tr" 
				   }
	}	
    }
    # 
    # Prepare files for Queue plot
    #
    set f5 [open temp.queue w]
    puts $f5 "TitleText: Queue dynamics at selected RED ECN node"
    puts $f5 "Device: Postscript"
    
    if { [info exists qfile] } {
	close $qfile
    }
    exec rm -f temp.a temp.p temp.q tempUDP.q tempUDP.p ;# deletes old files without asking (f=force)
    exec touch temp.a temp.p temp.q tempUDP.q tempUDP.p ;# creates new empty files with correct time stamp
    exec awk $awkCode all.q          ;# all.q has been monitoring the selected RED queue
    puts $f5 \"RED_queue\"
    exec cat temp.q >@ $f5 
    puts $f5 \n\"UDP_queue\"
    exec cat tempUDP.q >@ $f5 
    puts $f5 \n\"RED_drop_probability\"
    exec cat temp.p >@ $f5
    puts $f5 \n\"UDP_drop_probability\"
    exec cat tempUDP.p >@ $f5
    puts $f5 \n\"RED_averageQueue\"
    exec cat temp.a >@ $f5
    close $f5
# Displays queue instantaneous together with prob. of drop and ECF value (averaged drop)
    exec xgraph -bb -tk -x time -y queue -nl -m temp.queue -ly 0,1.1 & 
    exec xgraph -bb -x time -y queue  temp.queue & 

    #
    # Prepare file for TCP cwnd plot
    #
    #exec awk $awkCode2 s=42 d=43 t_cwnd.tr > cwnd_res.tr
    # Displays the TCP source congestion window
    #exec xgraph -t "TCP Congestion window" cwnd_res.tr &   

    # Plot for TCP throughput
    #exec awk -f tcp-throughput.awk st=1.00 dn=3 sn=2 out.tr | xgraph -t "TCP0 throughput" &

    $ns flush-trace
    close $f
#    close $nf
    close $f0
    close $f1
    close $f2
#    close $f3
#    close $f4

#### The following will make a xgraph showing the aggregate packet throughput and drops at first bottleneck link
#    global PERL 
#    set NS_HOME /home/alie/ns-allinone-2.28/ns-2.28
#    exec $PERL $NS_HOME/bin/getrc -s 0 -d 1 out.tr | \
#        $PERL $NS_HOME/bin/raw2xg -s 0.01 -m 90 -t "VBRoverTFRC, enqueue & dequeue @ bottleneck" > temp2.rands
#    exec echo $simtime 0 >> temp2.rands 
#    exec xgraph -bb -tk -nl -m -x time -y packets temp2.rands &


    #puts "running nam..."
    #exec nam out.nam &

#    close $tchan2_

    exit 0
}
###########################################################
# The interface between TFRC Receive (of ACKS)            #
# and the adaptive rate controller of the VBR application #
###########################################################
Agent/TFRC instproc tfrc_ra {bytes_per_sec backlog} {
    global vbr ns numb_vbr
    #    $self instvar ns_ 
    $self instvar node_

    set now [$ns now]
    set node_id [$node_ id]
    #puts "In TFRC instproc. rate = $bytes_per_sec (B/s), node_id = $node_id"

    #    $ns at [expr $now] "$cbr1 set interval_ $interval"
    for {set i 0} {$i < $numb_vbr} {incr i} {
    	if {[$node_ id] == [expr $i*2+5]} {
	    if {[$node_ id] == 0} {
		puts "TCL: before vbr($i) TFRC_rateadapt rate=$bytes_per_sec node=$node_id"
	    }
	    $ns at [expr $now] "$vbr($i) TFRC_rateadapt $bytes_per_sec $node_id $backlog"
	    #puts "TCL: after vbr($i) TFRC_rateadapt rate=$bytes_per_sec node=$node_id"
    	} 
    }
}

######################################
# Create traffic sources             #
######################################

set rng2 [new RNG]
$rng2 seed 20
set xRate [new RandomVariable/Uniform]
$xRate use-rng $rng2
$xRate set min_ 0
$xRate set max_ 2.5e3
##
## VBR0 as VBR rate adaptiv traffic
##
# The followong file is used as ns-2 adapted (by Chih-Heng, Ke from Taiwan) version of 
# the Evalvid (J. Klaue) generated file above
# Sender trace file from mp4.exe containing frame type and size
puts "Start making GOP and Frame trace files for $q_variants Rate variants"
for {set i 1} {$i <= $q_variants} {incr i} {
    set original_file_name($i) st_concatenated.yuv_Q[expr $i + 1].txt 
    set original_file_id($i) [open $original_file_name($i) r]
}
set trace_file_name video2.dat
set trace_file_id [open $trace_file_name w]
set trace_file [new vbrTracefile2]
$trace_file filename $trace_file_name
set frame_count 0
set last_time 0

# AL: toggle between multiple input files!
#set original_file_id $original_file_id(1)
set source_select 1


set frame_size_file frame_size.dat
set frame_size_file_id [open $frame_size_file w]
for {set i 1} {$i <= $q_variants} {incr i} {
    set frame_size($i) 0
}
set gop_size_file gop_size.dat
set gop_size_file_id [open $gop_size_file w]
for {set i 1} {$i <= $q_variants} {incr i} {
    set gop_size($i) 0
}
set gop_numb 0
# Convert ASCII sender file on frame size granularity to ns-2 adapted internal format
while {[eof $original_file_id(1)] == 0} {
    for {set i 1} {$i <= $q_variants} {incr i} {
	gets $original_file_id($i) current_line($i)
    }
    
    scan $current_line(1) "%d%s%d%s%s%s%d%s" no_ frametype_ length_ tmp1_ tmp2_ tmp3_ tmp4_ tmp5_

    #puts "$no_ $frametype_ $length_ $tmp1_ $tmp2_ $tmp3_ $tmp4_ $tmp5_"
        
    # 30 frames/sec. if one want to generate 25 frames/sec, one can use set time [expr 1000*1000/25]
    set time [expr 1000 * 1000/$frames_per_second] ;# Note that this is time between frames in number of us
    

    if { $frametype_ == "I" } {
  	set type_v 1
	set time 0
    }	

    if { $frametype_ == "P" } {
  	set type_v 2
    }	

    if { $frametype_ == "B" } {
  	set type_v 3
    }	
    
    # Write to GOP size file after each H-frame found:
    if { $frametype_ == "H" } {
	set puts_string "$gop_numb"
	for {set i 1} {$i <= $q_variants} {incr i} {
	    set puts_string "$puts_string $gop_size($i)" 
	}
	puts $gop_size_file_id $puts_string
	set gop_numb [expr $gop_numb + 1]
  	set type_v 0 ;# Must have different type than I-frame so that the LB(r,b) algorithm finds it!
    }	
# Write to frame_size.dat:
    set puts_string "$no_"
    for {set i 1} {$i <= $q_variants} {incr i} {
	set puts_string "$puts_string $gop_size($i)" 
    }
    puts $frame_size_file_id $puts_string

    for {set i 1} {$i <= $q_variants} {incr i} {
	scan $current_line($i) "%d%s%d%s%s%s%d%s" no_ frametype_ length($i) tmp1_ tmp2_ tmp3_ tmp4_ tmp5_
	set gop_size($i) [expr $gop_size($i) + $length($i) ]
    }

# Write to video2.dat:
    set puts_string "$time $length_ $type_v $max_fragmented_size"
    for {set i 2} {$i <= $q_variants} {incr i} {
	set puts_string "$puts_string $length($i)"
    }
    puts  $trace_file_id $puts_string
    incr frame_count
 
}
puts "#of frames written to GOP and Frame trace files: $frame_count"
#close $original_file_id
close $trace_file_id  ;# Note that this new trace file is closed for writing and 
# opened below for reading through being a new Tracefile in eraTraceFile2::setup()

#######################################################################
# Add Evalvid-RA RA-SVBR sources                                      #
#######################################################################
for {set i 0} {$i < $numb_vbr} {incr i} {
    puts "In SVBR TFRC loop, i=$i" 
    set tfrc($i) [new Agent/TFRC]
    $ns attach-agent $n([expr $i*2+0]) $tfrc($i)
    if {$cbr_true == 0} {
	set vbr($i) [new Application/Traffic/eraVbrTrace]
    } else {
	set vbr($i) [new Application/Traffic/CBR_RA]
	$vbr($i) set size 1500
    }
    $vbr($i) attach-agent $tfrc($i)
    
    $tfrc($i) set packetSize_ $packetSize ;# this is the MSS for the TFRC
    $tfrc($i) set TOS_field_ 1     ;# New 120905: tag ECF enabled sources! 0 is default.
#    if {$i == 0 || $i == 1} 
    if {$i < 15} {
	$tfrc($i) set_filename sd_be_$i ;# Connect a file name to TFRC source to write transmit trace data
    }

    $vbr($i) set running_ 0 
    set offRate [$xRate value]
    if {$cbr_true == 0} {
	$vbr($i) set r_ [expr $vbr_rate + $offRate]   ;# Set the rate instead of packet interval, 
	#$vbr($i) set r_ [expr $vbr_rate + 0.0]   ;# Set the rate instead of packet interval, 
	
	#$vbr($i) set r_ [expr $vbr_rate + $i*0.5e3]   ;# Set the rate instead of packet interval, 
	;# eraVbrTrace will calculate the interval.
	$vbr($i) attach-tracefile $trace_file
	#    $vbr($i) set b_ [expr $vbr_rate * 1.5] 
	$vbr($i) set b_ 1.5 
	$vbr($i) set q_ 8
	$vbr($i) set GoP_ 12
	$vbr($i) set fps_ $frames_per_second
    } else {
	$vbr($i) set rate_ [expr $cbr_rate + 0]   ;# Set the max rate instead of 
    }

    if {($i >= ($numb_vbr - $numb_vbr_off))} {    
	$tfrc($i) set class_ 4
    }

    set sink($i) [new Agent/TFRCSink] 
    
    $ns attach-agent $n([expr $i*2+1])  $sink($i)
    $ns connect $tfrc($i) $sink($i)
    if {$i == 0} {
	$sink($i) set_trace_filename rd_be_$i ;# Connect a file name to TFRC sink to 
	# write receivce trace data
    }
	
}


## EXTA VBRs that is NOT rate adaptive and is routed from r(0) to r(last)
for {set i 0} {$i < $numb_nonCC_cbr} {incr i} {
    puts "In nonCC-VBR loop, i=$i" 
    set nonCC_udp($i) [new Agent/UDP]
    $ns attach-agent $n([expr $i*2+0+2*$numb_vbr]) $nonCC_udp($i)
    set nonCC_cbr($i) [new Application/Traffic/CBR]
    $nonCC_cbr($i) attach-agent $nonCC_udp($i)

    $nonCC_udp($i) set packetSize_ 1500 ;# this is the MSS for the UDP
    $nonCC_cbr($i) set packetSize_ 1500 ;# this defines the VBR bit rate together with interval
    $nonCC_cbr($i) set running_ 0 
    $nonCC_cbr($i) set rate_ [expr $cbr_rate + $i*1.0e3]   ;# Set the rate instead of packet interval, 
    #;# eraVbrTrace will calculate the interval.
    set nonCC_sink($i) [new Agent/LossMonitor]
    $ns attach-agent $n([expr $i*2+1+2*$numb_vbr])  $nonCC_sink($i)
    $ns connect $nonCC_udp($i) $nonCC_sink($i)
}

## EXTA CBRs that MAY NOT be rate adaptive (x-traffic 1)
for {set i 0} {$i < $numb_nonCC_cbr1} {incr i} {
    puts "In nonCC-CBR2 loop, i=$i" 
    set nonCC_udp1($i) [new Agent/UDP]
    $ns attach-agent $cr([expr $i*2]) $nonCC_udp1($i)
#    if {($xt_nonCC == 1) && ($i >= 0.5*$numb_nonCC_cbr1)} 
    if {$xt_nonCC == 1} {
	if {$poisson_xt_true == 0} {
	    set nonCC_cbr1($i) [new Application/Traffic/CBR] ;# Use this for nonCC
	    $nonCC_cbr1($i) set packetSize_ 1500 ;# this defines the CBR bit rate together with interval
	} else {
	    set nonCC_cbr1($i) [new Application/Traffic/Poisson]
	    $nonCC_cbr1($i) set size 1500
	}
	$nonCC_udp1($i) set TOS_field_ 0     ;# New 120905: tag ECF enabled sources! 0 is default.
    } else {
	if {$poisson_xt_true == 0} {
	    set nonCC_cbr1($i) [new Application/Traffic/eraVbrTrace]
	    $nonCC_cbr1($i) set packetSize_ 1500 ;# this defines the CBR bit rate together with interval
	} else {
	    set nonCC_cbr1($i) [new Application/Traffic/Poisson_RA]
	    $nonCC_cbr1($i) set size 1500
	}
	$nonCC_udp1($i) set TOS_field_ 1     ;# New 120905: tag ECF enabled sources! 0 is default.
    }
    $nonCC_udp1($i) set class_ 1
    $nonCC_cbr1($i) attach-agent $nonCC_udp1($i)

    $nonCC_udp1($i) set packetSize_ 1500 ;# this is the MSS for the UDP
    $nonCC_cbr1($i) set packetSize_ 1500 ;# this defines the CBR bit rate together with interval
    $nonCC_cbr1($i) set running_ 0 
    set offRate [$xRate value]
    $nonCC_cbr1($i) set rate_ [expr $cbr_rate + $offRate]   ;# Set the rate instead of packet interval, 
    set nonCC_sink1($i) [new Agent/LossMonitor]
    $ns attach-agent $cr([expr $i*2+1])  $nonCC_sink1($i)
    $ns connect $nonCC_udp1($i) $nonCC_sink1($i)

}

## EXTA CBRs that MAY NOT be rate adaptive (x-traffic 2)
for {set i 0} {$i < $numb_nonCC_cbr2} {incr i} {
    puts "In nonCC-CBR3 loop, i=$i" 
    set nonCC_udp2($i) [new Agent/UDP]
    $ns attach-agent $cr2([expr $i*2]) $nonCC_udp2($i)

    if {$xt_nonCC == 1} {
	if {$poisson_xt_true == 0} {
	    set nonCC_cbr2($i) [new Application/Traffic/CBR] ;# Use this for nonCC
	    $nonCC_cbr2($i) set packetSize_ 1500 ;# this defines the CBR bit rate together with interval
	} else {
	    set nonCC_cbr2($i) [new Application/Traffic/Poisson]
	    $nonCC_cbr2($i) set size 1500
	}
	$nonCC_udp2($i) set TOS_field_ 0     ;# New 120905: tag ECF enabled sources! 0 is default.
    } else {
	if {$poisson_xt_true == 0} {
	    set nonCC_cbr2($i) [new Application/Traffic/eraVbrTrace]
	    $nonCC_cbr2($i) set packetSize_ 1500 ;# this defines the CBR bit rate together with interval
	} else {
	    set nonCC_cbr2($i) [new Application/Traffic/Poisson_RA]
	    $nonCC_cbr2($i) set size 1500
	}
	$nonCC_udp2($i) set TOS_field_ 1     ;# New 120905: tag ECF enabled sources! 0 is default.
    }


    $nonCC_udp2($i) set class_ 2
    $nonCC_cbr2($i) attach-agent $nonCC_udp2($i)

    $nonCC_udp2($i) set packetSize_ 1500 ;# this is the MSS for the UDP
    $nonCC_cbr2($i) set packetSize_ 1500 ;# this defines the CBR bit rate together with interval
    $nonCC_cbr2($i) set running_ 0 
    #$nonCC_cbr2($i) set rate_ [expr $cbr_rate + $i*12.0e6]   ;# Set the rate instead of packet interval, 
    #$nonCC_cbr2($i) set rate_ [expr 5.0e6 + $i*10.0e6]   ;# Set the rate instead of packet interval, 
    #$nonCC_cbr2($i) set rate_ 2.0e6   ;# Set the rate instead of packet interval, 
    set offRate [$xRate value]
    $nonCC_cbr2($i) set rate_ [expr $cbr_rate + $offRate]   ;# Set the rate instead of packet interval, 
    #$nonCC_cbr2($i) set rate_ $cbr_rate   ;# Set the rate instead of packet interval, 
    #;# eraVbrTrace will calculate the interval.
    set nonCC_sink2($i) [new Agent/LossMonitor]
    $ns attach-agent $cr2([expr $i*2+1])  $nonCC_sink2($i)
    $ns connect $nonCC_udp2($i) $nonCC_sink2($i)

}

## EXTA CBRs that MAY NOT be rate adaptive (x-traffic 3)
for {set i 0} {$i < $numb_nonCC_cbr3} {incr i} {
    puts "In nonCC-CBR4 loop, i=$i" 
    set nonCC_udp3($i) [new Agent/UDP]
    $ns attach-agent $cr3([expr $i*2]) $nonCC_udp3($i)


#    if {$i < 0} {
#	set nonCC_cbr3($i) [new Application/Traffic/CBR] ;# Use this for nonCC
#	$nonCC_udp3($i) set TOS_field_ 0     ;# New 120905: tag ECF enabled sources! 0 is default.
#    } else {
#	set nonCC_cbr3($i) [new Application/Traffic/eraVbrTrace] ;# Use thsi for CC
#	$nonCC_udp3($i) set TOS_field_ 1     ;# New 120905: tag ECF enabled sources! 0 is default.
#    }

    if {$xt_nonCC == 1} {
	if {$poisson_xt_true == 0} {
	    set nonCC_cbr3($i) [new Application/Traffic/CBR] ;# Use this for nonCC
	    $nonCC_cbr3($i) set packetSize_ 1500 ;# this defines the CBR bit rate together with interval
	} else {
	    set nonCC_cbr3($i) [new Application/Traffic/Poisson]
	    $nonCC_cbr3($i) set size 1500
	}
	$nonCC_udp3($i) set TOS_field_ 0     ;# New 120905: tag ECF enabled sources! 0 is default.
    } else {
	if {$poisson_xt_true == 0} {
	    set nonCC_cbr3($i) [new Application/Traffic/eraVbrTrace]
	    $nonCC_cbr3($i) set packetSize_ 1500 ;# this defines the CBR bit rate together with interval
	} else {
	    set nonCC_cbr3($i) [new Application/Traffic/Poisson_RA]
	    $nonCC_cbr3($i) set size 1500
	}
	$nonCC_udp3($i) set TOS_field_ 1     ;# New 120905: tag ECF enabled sources! 0 is default.
    }



    $nonCC_udp3($i) set class_ 3
    $nonCC_cbr3($i) attach-agent $nonCC_udp3($i)

    $nonCC_udp3($i) set packetSize_ 1500 ;# this is the MSS for the UDP
    $nonCC_cbr3($i) set packetSize_ 1500 ;# this defines the CBR bit rate together with interval
    $nonCC_cbr3($i) set running_ 0 
    #$nonCC_cbr3($i) set rate_ [expr $cbr_rate + $i*12.0e6]   ;# Set the rate instead of packet interval, 
    #$nonCC_cbr3($i) set rate_ [expr 5.0e6 + $i*10.0e6]   ;# Set the rate instead of packet interval, 
    #$nonCC_cbr3($i) set rate_ 2.0e6   ;# Set the rate instead of packet interval,
    set offRate [$xRate value]
    $nonCC_cbr3($i) set rate_ [expr $cbr_rate + $offRate]   ;# Set the rate instead of packet interval, 
    #;# eraVbrTrace will calculate the interval.
    set nonCC_sink3($i) [new Agent/LossMonitor]
    $ns attach-agent $cr3([expr $i*2+1])  $nonCC_sink3($i)
    $ns connect $nonCC_udp3($i) $nonCC_sink3($i)

}

##
## TCP sources
##
for {set i 0} {$i < $numb_ftp} {incr i} {
    #set tcp [new Agent/TCP/Sack1]
    puts "In TCP loop, i=$i" 
    set tcp($i) [new Agent/TCP/Newreno]
    $tcp($i) set class_ 2
    $tcp($i) set window_ 1000            ;# default is 20
    $tcp($i) set maxcwnd_ 1000
    $tcp($i) set packetSize_ 1460
    $tcp($i) set minrto_ 0.005
    $tcp($i) set maxrto_ 2
    $tcp($i) set backoff_ 0

    ### ECN ON/OFF ###
    $tcp($i) set ecn_ true

    #set sink [new Agent/TCPSink/Sack1]
    set sinktcp($i) [new Agent/TCPSink]
    $sinktcp($i) set window_ 64            ;# advertized window (?) default is 20
    $ns attach-agent $n([expr $i*2+0+2*($numb_cbr+$numb_nonCC_cbr)]) $tcp($i)
    $ns attach-agent $n([expr $i*2+1+2*($numb_cbr+$numb_nonCC_cbr)]) $sinktcp($i)
    $ns connect $tcp($i) $sinktcp($i)
    
    set ftp($i) [new Application/FTP]
    $ftp($i) attach-agent $tcp($i)
    $ftp($i) set packetSize_ 1420
}

##
## Trace of cwnd of selected TCP source
##
if {$numb_ftp > 2} {
    set tchan2_ [open t_cwnd.tr w]
    $tcp(0) trace cwnd_
    $tcp(0) attach $tchan2_ 
    $tcp(0) set trace_all_oneline_ 1
    $tcp(0) set tracevar_ 1

    set tchan3_ [open t_cwnd3.tr w]
    #$tcp trace cwnd_ || $tcp tracevar cwnd_
    $tcp(1) trace cwnd_
    $tcp(1) attach $tchan3_ 
    $tcp(1) set trace_all_oneline_ 1
    $tcp(1) set tracevar_ 1

    set tchan4_ [open t_cwnd4.tr w]
    #$tcp trace cwnd_ || $tcp tracevar cwnd_
    $tcp([expr $i-2]) trace cwnd_
    $tcp([expr $i-2]) attach $tchan4_ 
    $tcp([expr $i-2]) set trace_all_oneline_ 1
    $tcp([expr $i-2]) set tracevar_ 1
}
##
## Create ns-2 scheduler
##
#Start logging the received bandwidth at nodes in LossMonitor
set rng [new RNG]
$rng seed 20
set ftpStart [new RandomVariable/Uniform]
$ftpStart use-rng $rng
$ftpStart set min_ 0.01
$ftpStart set max_ 0.2

for {set i 0} {$i < $numb_ftp} {incr i} {
    set startTime [$ftpStart value]
    puts "startTime=$startTime"
    $ns at [expr $startTime] "$ftp($i) start"
    $ns at [expr $simtime - 20.0] "$ftp($i) stop"
}
#$ns at 10 "$ftp(0) start"

#$ns at 20 "$ftp(1) start"
#$ns at 20 "$ftp(2) start"
#$ns at 20 "$ftp(3) start"

#$ns at 30 "$ftp(1) stop"
#$ns at 30 "$ftp(2) stop"
#$ns at 30 "$ftp(3) stop"

#$ns at 40 "$ftp(1) start"
#$ns at 40 "$ftp(2) start"
#$ns at 40 "$ftp(3) start"
#$ns at 40 "$ftp(4) start"
#$ns at 40 "$ftp(5) start"
#$ns at 40 "$ftp(6) start"
#$ns at 40 "$ftp(7) start"
#$ns at 40 "$ftp(8) start"
#$ns at 40 "$ftp(9) start"
#$ns at 40 "$ftp(10) start"
#$ns at 40 "$ftp(11) start"

#$ns at 60 "$ftp(0) stop"
#$ns at 60 "$ftp(1) stop"
#$ns at 60 "$ftp(2) stop"
#$ns at 60 "$ftp(3) stop"
#$ns at 60 "$ftp(4) stop"
#$ns at 60 "$ftp(5) stop"
#$ns at 60 "$ftp(6) stop"
#$ns at 60 "$ftp(7) stop"
#$ns at 60 "$ftp(8) stop"
#$ns at 60 "$ftp(9) stop"
#$ns at 60 "$ftp(10) stop"
#$ns at 60 "$ftp(11) stop"

set rng3 [new RNG]
$rng3 seed 30
set vbrStart [new RandomVariable/Uniform]
$vbrStart use-rng $rng3
$vbrStart set min_ 0.040
$vbrStart set max_ 16.000
for {set i 0} {$i < $numb_vbr} {incr i} {
    set startTime [$vbrStart value]
    # The follow test starts OUR trace file first, so that it is recognized as main trace
    # and will thus start from beginning of file and stop simulation when finished!
    if {$i < ($numb_vbr * 1.5)} {
	if {$i == 0} {
	    $ns at 0.010 "$vbr($i) start"
	} else {
	    $ns at $startTime "$vbr($i) start"
	}	
	$ns at $simtime   "$vbr($i) stop"
    } else {
	$ns at [expr 25.0+$i*0.001] "$vbr($i) start"
	$ns at 35.0 "$vbr($i) stop"
    }
}

## Ill-behaving source:
for {set i 0} {$i < $numb_nonCC_cbr} {incr i} {
    set startTime [$vbrStart value]
    $ns at $startTime "$nonCC_cbr($i) start"
    $ns at [expr $simtime] "$nonCC_cbr($i) stop"
}

## Ill-behaving source (x-traffic)
for {set i 0} {$i < $numb_nonCC_cbr1} {incr i} {
    set startTime [$vbrStart value]
    if {$i<0.5*$numb_nonCC_cbr1} {
	$ns at $startTime "$nonCC_cbr1($i) start"
	$ns at [expr $simtime] "$nonCC_cbr1($i) stop"
    } else {
	$ns at [expr $startTime + 10.0] "$nonCC_cbr1($i) start"
	$ns at [expr $simtime - 10.0] "$nonCC_cbr1($i) stop"
    }
}

for {set i 0} {$i < $numb_nonCC_cbr2} {incr i} {
    set startTime [$vbrStart value]
    $ns at $startTime "$nonCC_cbr2($i) start"
    $ns at [expr $simtime] "$nonCC_cbr2($i) stop"
}

for {set i 0} {$i < $numb_nonCC_cbr3} {incr i} {
    set startTime [$vbrStart value]
    $ns at $startTime "$nonCC_cbr3($i) start"
    $ns at [expr $simtime] "$nonCC_cbr3($i) stop"
}


$ns at $simtime "finish"


$ns run
