#
# Copyright (c) 2011
#  Swinburne University of Technology, Melbourne, Australia
#  All rights reserved.
#
#
# Released under the GNU General Public License version 2.
#
# Author
#  - David Hayes (dahayes@swin.edu.au or david.hayes@ieee.org)
#
# Note that inital work on this suite was done by:
# - Gang Wang (wanggang@research.nec.com.cn)
# - Yong Xia   (xiayong@research.nec.com.cn)
#
#
# (see http://tools.ietf.org/html/draft-irtf-tmrg-tests-03>)
#
#              T_n2                        T_n4
#               |                           |
#               |                           |
#         T_n1  |                           |  T_n3
#            \  |                           | /
#             \ |                           |/
#      B_n1--- R1--------------------------R2--- B_n4
#             / |                           |\
#            /  |                           | \
#        B_n2   |                           |  B_n5
#               |                           |
#              B_n3                        B_n6
#
#               Figure: Dumbbell test topology
# 
# Where Test TCP source 1 is connected T_n1 to T_n3
# and test TCP soiurce 2 is connected T_n2 to T_n3
#
# environment setting
# [include external source code]
source $env(TCPEVAL)/tcl/create_topology.tcl
source $env(TCPEVAL)/tcl/create_traffic.tcl
set if_wireless 0               ;# default to not wireless
#initialise target state
set closest_high_scale 0.0
set closest_low_scale 0.0
set closest_low_val 0.0
set closest_high_val 0.0
#
# defaults for this scenario
#
### Tmix
set num_tmix_flow 9		;# number of tmix flows
set num_tmix_node 3		;# number of tmix nodes
set tmix_pkt_size 1460          ;# default packet size. overriden by m record in cv files
#
#
# debug output files
set tmix_debug_output [list "flow1" "flow2" "flow3" "flow4" "flow5" "flow6" "flow7" "flow8" "flow9"]
#
# include parameter files
#
source ./tcl_base_setup
source ./defaults.tcl
set closest_low_pcntbps $closest_low_val
set closest_high_pcntbps $closest_high_val

proc outputresults { n bytes src} {
    global resultfd_ starttime ns TIME
    set measuretime [expr [$ns now] - $TIME]
    puts $resultfd_ [format "%d,%d, %d, %f" $src $n $bytes $measuretime]
    flush $resultfd_
}
#Receive function for nbytes
Class Application/FTPrecv -superclass Application
Application/FTPrecv instproc init { } {
    $self instvar totalreceived
    $self instvar recvBlkCnt
    $self instvar recvBlkThresh
    $self instvar start_counting
    
    set start_counting 0
    set totalreceived 0
    set recvBlkCnt 1
    set recvBlkThresh [expr 1500*10**$recvBlkCnt]
    $self next
}

Application/FTPrecv instproc recv {nbytes} {
    $self instvar totalreceived
    $self instvar recvBlkThresh
    $self instvar recvBlkCnt
    $self instvar test_source
    $self instvar start_counting

    if { $start_counting } {
	set totalreceived [expr $totalreceived + $nbytes]
	while { $totalreceived >= $recvBlkThresh } {
	    outputresults $recvBlkCnt $totalreceived $test_source
	    incr recvBlkCnt
	    set recvBlkThresh [expr 1500*10**$recvBlkCnt]
	}
    }
}
Application/FTPrecv instproc StartCounting { } {
    $self instvar start_counting
    set start_counting 1
}
Application/FTPrecv instproc label { src } {
    $self instvar test_source
    set test_source $src
}
# finish process
proc finish { fmonF fmonR } {
    global ns TIME
    global scale targetpcntbps findtarget TargetDirection
    global Btopo Btraffic
    global fmonFsize fmonRsize fmonFdelay fmonRdelay
    global prevstat 
    global resultfd_ nsoutfd_ SaveTraceFile tracefd_

    if { [$ns get-ns-traceall] != "" && $SaveTraceFile > 0} {
	$ns flush-trace
	close $tracefd_
    }

    set measuretime [expr [$ns now] - $TIME]
    set numFsamples [$fmonFdelay cnt]
    set numRsamples [$fmonRdelay cnt]
    set avlossF [expr 100.0 * $prevstat(total,pkt,drop,F)/$prevstat(total,pkt,arr,F) ]
    set avlossR [expr 100.0 * $prevstat(total,pkt,drop,R)/$prevstat(total,pkt,arr,R) ]
    if { $numFsamples > 0 && $numRsamples > 0} {
	set avQsizeBF [expr [$fmonFsize set sum_]/ $measuretime]
	set avQsizeBR [expr [$fmonRsize set sum_]/ $measuretime]
	set avQwaitF [$fmonFdelay mean]
	set avQwaitR [$fmonRdelay mean]
    } else {
	set avQsizeBF inf
	set avQsizeBR inf
	set avQwaitF  inf
	set avQwaitR  inf
    }
    foreach tf { t1 t2} {
	if { $prevstat($tf,pkt,arr,$TargetDirection) > 0 } {
	    set droprate($tf) [expr 100.0*$prevstat($tf,pkt,drop,$TargetDirection)/$prevstat($tf,pkt,arr,$TargetDirection)]
	} else {
	    set droprate($tf) 0
	}
    }
    puts $nsoutfd_ [format "Traffic Summary : Total F/R(Mbps) %6.3g / %6.3g, Bkg F/R(Mbps) %6.3g / %6.3g, Test flows %s Arr(Mbps)/Drop: T1 %6.3g / %5.2f %%, T2 %6.3g / %5.2f %%" \
			[expr $prevstat(total,byte,arr,F)*8.0/1e6/$measuretime] \
			[expr $prevstat(total,byte,arr,R)*8.0/1e6/$measuretime] \
			[expr $prevstat(background,byte,arr,F)*8.0/1e6/$measuretime] \
			[expr $prevstat(background,byte,arr,R)*8.0/1e6/$measuretime] \
			$TargetDirection \
			[expr $prevstat(t1,byte,arr,$TargetDirection)*8.0/1e6/$measuretime] \
			$droprate(t1) \
			[expr $prevstat(t2,byte,arr,$TargetDirection)*8.0/1e6/$measuretime] \
			$droprate(t2) ]
    if {$findtarget} {
	puts $nsoutfd_ [format "Summary (F/R): Av Q Dly %6.3g s / %6.3g s, Av Q Sz %6.3g B / %6.3g B, Av Loss %6.3f %% / %6.3f %%, Target %6.3f %%, scale %8.6f" \
			    $avQwaitF $avQwaitR $avQsizeBF $avQsizeBR $avlossF $avlossR \
			    $targetpcntbps $scale ]
    } else {
	puts $nsoutfd_ [format "Summary (F/R): Av Q Dly %6.3g s / %6.3g s, Av Q Sz %6.3g B / %6.3g B, Av Loss %6.3f %% / %6.3f %%, scale %8.6f" \
			    $avQwaitF $avQwaitR $avQsizeBF $avQsizeBR $avlossF $avlossR \
			    $scale ]
    }

    flush $nsoutfd_
    flush $resultfd_

    $Btopo finish
    $Btraffic finish
	
    $ns halt
}

proc monitorcntlnkflows {fmonF fmonR} {
    global ns Incremental_display_interval display_counter TIME
    global prevstat tmix_R tmix_L TNsrc TNsnk
    global cntlnk_bw num_tmix_node
    global scale findtarget targetpcntbps TargetDirection nsoutfd_ test_time

    set measuretime [expr [$ns now] - $TIME]

    set fcF [$fmonF classifier]
    set fcR [$fmonR classifier]
    ####################### collect background traffic stats ###################
    # need to aggrigate for each background flow
    #
    foreach tp { pkt byte } pre { p b } {
	foreach act { arr dep drop } var { arrivals_ departures_ drops_ } {
	    set currstat(background,$tp,$act,F) 0
	    set currstat(background,$tp,$act,R) 0
	    for { set l 0 } { $l < $num_tmix_node } { incr l } {
		for { set r 0 }  { $r < $num_tmix_node } { incr r } {
		    set bflF [$fcF lookup auto [$tmix_L(T,$l) id] [$tmix_R(T,$r) id] 0]
		    set bflR [$fcR lookup auto [$tmix_R(T,$r) id] [$tmix_L(T,$l) id] 0]
		    if { $bflF != "" } {
			set currstat(background,$tp,$act,F) \
			    [expr $currstat(background,$tp,$act,F) + [ $bflF set $pre$var ] ]
		    }
		    if { $bflR != "" } {
			set currstat(background,$tp,$act,R) \
			    [expr $currstat(background,$tp,$act,R) + [ $bflR set $pre$var ] ]
		    }
		}
	    }
	    set incrstat(background,$tp,$act,F) \
		[expr $currstat(background,$tp,$act,F) - $prevstat(background,$tp,$act,F)]
	    set incrstat(background,$tp,$act,R) \
		[expr $currstat(background,$tp,$act,R) - $prevstat(background,$tp,$act,R)]
	}
    }
    ####################### collect test flow statistics #######################
    if { $TargetDirection == "R" } {
	set FC $fcR
    } else {
	set FC $fcF
    }
    set tmon(t1) [$FC lookup auto [$TNsrc(1) id] [$TNsnk(1) id] 0]
    set tmon(t2) [$FC lookup auto [$TNsrc(2) id] [$TNsnk(2) id] 0]
    
    foreach fl { t1 t2 } {
	foreach tp { pkt byte } pre { p b } {
	    foreach act { arr dep drop } var { arrivals_ departures_ drops_ } {
		    if { $tmon($fl) != "" } {
			set currstat($fl,$tp,$act,$TargetDirection) [ $tmon($fl) set $pre$var ]
		    } else {
			set currstat($fl,$tp,$act,$TargetDirection) 0
		    }
		set incrstat($fl,$tp,$act,$TargetDirection) \
		    [expr $currstat($fl,$tp,$act,$TargetDirection) - $prevstat($fl,$tp,$act,$TargetDirection)]
	    }
	}
    }
    ####################### collect total statistics ###########################
    foreach tp { pkt byte } pre { p b } {
	foreach act { arr dep drop } var { arrivals_ departures_ drops_ } {
	    set currstat(total,$tp,$act,F) [ $fmonF set $pre$var ]
	    set currstat(total,$tp,$act,R) [ $fmonR set $pre$var ]
	    set incrstat(total,$tp,$act,F) \
		[expr $currstat(total,$tp,$act,F) - $prevstat(total,$tp,$act,F) ]
	    set incrstat(total,$tp,$act,R) \
		[expr $currstat(total,$tp,$act,R) - $prevstat(total,$tp,$act,R) ]
	}
    }
    #################### print progress statistics ##############################
    foreach dir { F R } {
	if { $incrstat(total,byte,arr,$dir) > 0 } {
	    set pcntbacktraff($dir) [expr 100.0*$incrstat(background,byte,arr,$dir)/$incrstat(total,byte,arr,$dir)]
	} else {
	    set pcntbacktraff($dir) 0
	}
    }
    foreach tf { t1 t2} {
	if { $incrstat($tf,pkt,arr,$TargetDirection) > 0 } {
	    set droprate($tf) [expr 100.0*$incrstat($tf,pkt,drop,$TargetDirection)/$incrstat($tf,pkt,arr,$TargetDirection)]
	} else {
	    set droprate($tf) 0
	}
    }

    puts $nsoutfd_ [format "Time %4.1f Incremental Stats Mbps (F/R): Total %6.3g / %6.3g, Bkg %6.3g / %6.3g, %% Bg Traff %5.2f %% / %5.2f %%" \
			[expr $TIME+$display_counter*$Incremental_display_interval] \
			[expr $incrstat(total,byte,arr,F) *8.0/1e6/$Incremental_display_interval] \
			[expr $incrstat(total,byte,arr,R) *8.0/1e6/$Incremental_display_interval] \
			[expr $incrstat(background,byte,arr,F) *8.0/1e6/$Incremental_display_interval] \
			[expr $incrstat(background,byte,arr,R) *8.0/1e6/$Incremental_display_interval] \
			$pcntbacktraff(F) $pcntbacktraff(R) ]
    puts $nsoutfd_ [format "    Test flow incr stats (%s): T1 (Mbps) Arr %6.3g, T2 (Mbps) %6.3g, DropRate (T1/T2) %5.2f %% / %5.2f %%" \
			$TargetDirection \
			[expr $incrstat(t1,byte,arr,$TargetDirection) *8.0/1e6/$Incremental_display_interval] \
			[expr $incrstat(t2,byte,arr,$TargetDirection) *8.0/1e6/$Incremental_display_interval] \
			$droprate(t1) $droprate(t2) ]
    flush $nsoutfd_

    ################# save currstats as prevstats ###########################
    foreach fl { total background } {
	foreach tp { pkt byte } {
	    foreach act { arr dep drop } {
		foreach dir { F R } {
		    set prevstat($fl,$tp,$act,$dir) $currstat($fl,$tp,$act,$dir)
		}
	    }
	}
    }
    foreach fl { t1 t2 } {
	foreach tp { pkt byte } {
	    foreach act { arr dep drop } {
		set prevstat($fl,$tp,$act,$TargetDirection) $currstat($fl,$tp,$act,$TargetDirection)
	    }
	}
    }

    ################# target bps calculations ################################
    #After we have run 20% of the time, check if we are in the right ballpark
    if {$findtarget && $measuretime/$test_time > 0.3 } {
	set pcntbkgtraff \
	    [ expr 100.0* $currstat(background,byte,arr,$TargetDirection) / $currstat(total,byte,arr,$TargetDirection) ]
	if { $pcntbkgtraff > [expr 10.0 * $targetpcntbps] } {
	    finish $fmonF $fmonR
	    return
	}
    }
    
    ############## set up for next call
    set display_counter [ expr $display_counter + 1 ]
    $ns at [ expr $TIME+$display_counter * $Incremental_display_interval ] "monitorcntlnkflows $fmonF $fmonR"
}


# reset flow monitors
proc resetmonitors {fmonF fmonR} {
    global ns cntlnk
    $ns attach-fmon [ $ns link $cntlnk(0) $cntlnk(1) ] $fmonF
    $ns attach-fmon [ $ns link $cntlnk(1) $cntlnk(0) ] $fmonR
    $fmonF reset
    $fmonR reset
}


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Simulation setup
#
set skipexperiment 0
if {$ExperimentIteration > $NumExperiments} {
    set $NewExperimentIteration -1 
    puts stdout [format "tcpevaliterations,%d" \
		     $NewExperimentIteration]
    exit
} else {
    if {$findtarget == 0 || $TargetIter == 1} {
	set scale  $Scale($ExperimentNames($ExperimentIteration))
    }
    if { $findtarget } {
	if { ![info exists targetpcntbps] } {
	    puts stderr "Warning findtarget=1, but no targetpcntbps specified" 
	    puts stderr "---> Skipping this test"
	    set skipexperiment 1
	}
    }
	
    set result_filename ${result_basename}_$ExperimentNames($ExperimentIteration)
    if { [ file exists $tmp_directory_/result_$result_filename ] && $TargetIter == 1} {
	#skip already experiments we have already done
	puts stderr "$tmp_directory_/result_$result_filename exists, so skipping"
	set skipexperiment 1
    }

    if { $skipexperiment == 1 } {
	incr ExperimentIteration
	if {$ExperimentIteration > $NumExperiments} {
	    set NewExperimentIteration -1 
	} else {
	    set NewExperimentIteration $ExperimentIteration
	}
	set scale -1.0
	puts stdout [format "tcpevaliterations,%d,%f,%f,%f,%f,%f" \
			 $NewExperimentIteration \
			 $closest_low_scale $closest_high_pcntbps \
			 $closest_high_scale $closest_low_pcntbps $scale]
	exit
    }
}

array set T_delay  $TestDelays($ExperimentNames($ExperimentIteration))
set cntlnk_bw  $CntlnkBws($ExperimentNames($ExperimentIteration))
##################### set up result file ####################################
set resultfd_ [open $tmp_directory_/result_$result_filename w]
puts $resultfd_ "src,n,bytes,time"
#AQM experiments?
if { [array exists AQMtarget] } {
    set aqm_target $AQMtarget($ExperimentNames($ExperimentIteration))
} else {
    set aqm_target 0
}

if {$findtarget} {
    set nsoutfd_ [open $tmp_directory_/bpstarget_$result_filename a]
} else {
    set nsoutfd_ [open $tmp_directory_/nsout_$result_filename a]
}
set error 0.05
set avlossF 0
set avlossR 0
set scale_incr 0.0
set Qstatsampleinterval 0.1
set Incremental_display_interval [expr $test_time/50.0]
set finishplus 0.001

#################### set up simulation #####################################
set ns [new Simulator]
remove-all-packet-headers       ; # removes all except common
add-packet-header Flags IP TCP  ; # headers required by TCP

if {$SaveTraceFile > 0} {
    file mkdir $tmp_directory_/trace_data
    set tracefd_ [open $tmp_directory_/trace_data/$result_filename.tr w]
    $ns trace-all $tracefd_
}

########## Initialise per iteration variables ######################
set display_counter 1
foreach fl { total background t1 t2 } {
    foreach tp { pkt byte } {
	foreach act { arr dep drop } {
	    foreach dir { F R } {
		set prevstat($fl,$tp,$act,$dir) 0
	    }
	}
    }
}
#####################################################################
set warmup $prefill_t
set ftpstarttime(1) [expr $prefill_t+$warmup]
set TI [expr $prefill_t+$warmup]; # start ftp 1 after warmup+prefill_t
set TIME [expr $ftpstarttime(1) * 2.0]; # collect results after 
set ftpstarttime(2) $TIME
puts stderr [format "Start time: %f" $TIME]
set sim_time [expr $test_time + $TIME]

######### Set up Flow monitors and classifiers ##########################
# note that the Dest hash classifier doesn't work properly, so using SrcDest
set fmonF [ $ns makeflowmon SrcDest ]
set fmonR [ $ns makeflowmon SrcDest ]
# attach in resetmonitors, otherwise perflow statistics aren't reset
#$ns attach-fmon [ $ns link $cntlnk(0) $cntlnk(1) ] $fmonF
#$ns attach-fmon [ $ns link $cntlnk(1) $cntlnk(0) ] $fmonR
######### Aggregate Monitors for central link ###############################
$fmonF set sampleInterval_ $Qstatsampleinterval
# makeflowmon does not set up the bytes integrator, so do it here
set FbytesInt [new Integrator]
$fmonF set-bytes-integrator $FbytesInt
set fmonFsize [$fmonF get-bytes-integrator]
set delaysamplesF [new Samples]
$fmonF set-delay-samples $delaysamplesF
set fmonFdelay [$fmonF get-delay-samples]
$fmonR set sampleInterval_ $Qstatsampleinterval
set RbytesInt [new Integrator]
$fmonR set-bytes-integrator $RbytesInt
set fmonRsize [$fmonR get-bytes-integrator]
set delaysamplesR [new Samples]
$fmonR set-delay-samples $delaysamplesR
set fmonRdelay [$fmonR get-delay-samples]
#
puts $nsoutfd_ "Scale = $scale"
flush $nsoutfd_
set Btraffic [new Create_traffic]
set Btopo [new Create_topology/Dumb_bell/Basic]

############## Set up Background tmix traffic ##############################
if { $tmix_agent_type == "one-way" } {
    $Btraffic config_tmix -num_tmix_flow $num_tmix_flow \
	-num_tmix_node $num_tmix_node \
	-tmix_cv_name $tmix_cv_name \
	-tmix_agent_type $tmix_agent_type \
	-tmix_pkt_size $tmix_pkt_size \
	-test_tcp $Test_TCP \
	-useAQM $useAQM \
	-tmix_debug_output $tmix_debug_output
} else {
    $Btraffic config_tmix -num_tmix_flow $num_tmix_flow \
	-num_tmix_node $num_tmix_node \
	-tmix_cv_name $tmix_cv_name \
	-tmix_agent_type $tmix_agent_type \
	-tmix_debug_output $tmix_debug_output \
	-test_tcp $Test_TCP \
	-useAQM $useAQM \
	-tmix_pkt_size $tmix_pkt_size
    }

############ Configure Background traffic topology #########################
$Btopo config -cntlnk_bw $cntlnk_bw \
    -num_cntlnk 1 \
    -rttp $core_delay \
    -rtt_diff 0 \
    -edge_delay $edge_delay \
    -edge_bw $edge_bw \
    -core_delay $core_delay \
    -buffer_length $buffer_length \
    -traffic $Btraffic \
    -sim_time $sim_time \
    -scale $scale \
    -end $sim_time \
    -prefill_t $prefill_t \
    -prefill_si $prefill_si \
    -if_wireless $if_wireless \
    -nsoutfd $nsoutfd_

$Btopo create

##################  Setup Test Traffic ##################################
array set cntlnk [$Btopo array get cntlnk_]
set SRC [$Btopo set SRC(T)]
set SINK [$Btopo set SINK(T)]
# for 1.5kBpacket
set Tbuffer [lindex $buffer_length 0]
set bufflen [expr 1000.0 * $Tbuffer / 8.0 / 1.5]
for { set tn 1 } { $tn <= 2 } { incr tn } {
    # Set up test source and sink nodes and links
    if { $TargetDirection == "R" } {
	set cnsrc 1
 	set cnsnk 0
   } else {
	set cnsrc 0
	set cnsnk 1
    }
    set TNsrc($tn) [$ns node]
    $ns duplex-link $TNsrc($tn) $cntlnk($cnsrc) 1000Mb $T_delay($tn)ms DropTail
    $ns queue-limit $TNsrc($tn) $cntlnk($cnsrc) $bufflen
    $ns queue-limit $cntlnk($cnsrc) $TNsrc($tn) $bufflen
    set TNsnk($tn) [$ns node] 
    $ns duplex-link $TNsnk($tn) $cntlnk($cnsnk) 1000Mb $T_delay([expr $tn + 2])ms DropTail
    $ns queue-limit $TNsnk($tn) $cntlnk($cnsnk) $bufflen
    $ns queue-limit $cntlnk($cnsnk) $TNsnk($tn) $bufflen
    #
    # Set up TCP source and sink agents
    set TCPsrc($tn) [new Agent/TCP/$SRC]
    set TCPsnk($tn) [new Agent/TCPSink/$SINK]
    $ns attach-agent $TNsrc($tn) $TCPsrc($tn)
    $ns attach-agent $TNsnk($tn) $TCPsnk($tn)
    # ftp for a long lived flow
    set Ftp($tn) [$TCPsrc($tn) attach-app FTP]
    set FtpRecv($tn) [$TCPsnk($tn) attach-app FTPrecv ]
    # set up variables for receive callback
    $FtpRecv($tn) start
    $FtpRecv($tn) label $tn
    # glue it all together
    $ns connect $TCPsrc($tn) $TCPsnk($tn)
    $ns at $ftpstarttime($tn)  "$Ftp($tn) start"
    $ns at $ftpstarttime(2) "$FtpRecv($tn) StartCounting"
    $ns at [expr $sim_time + $finishplus] "$Ftp($tn) stop"
}
#tmix_L left-hand side nodes, tmix_R right-hand side nodes
array set tmix_L [ $Btopo array get tmix_L ]
array set tmix_R [ $Btopo array get tmix_R ]
#
#########################################################################
########### Start Simulation ############################################
#########################################################################
$ns at [expr $TIME] "resetmonitors $fmonF $fmonR"
$ns at  [expr $TIME + $display_counter * $Incremental_display_interval] "monitorcntlnkflows $fmonF $fmonR" 
$ns at [expr $sim_time + $finishplus] "finish $fmonF $fmonR"
$ns run

################## clean up #############################################
#delete $delaysamplesF
#delete $delaysamplesR
#delete $ns
#delete $Btraffic
#delete $Btopo
################################################################## 
############ Simulation Finished #################################
close $resultfd_
set measuretime [expr [$ns now] - $TIME - $finishplus]
############## Calculation of next scale factor ##################
# This code was used to determine the scale factor that will
# yield the targetpcntbps for NewReno.
# It was used to determine the scale parameter outlined in the 
# irtf draft.
if { $prevstat(total,byte,arr,$TargetDirection) < 0 } {
    puts stderr "ERROR - no traffic"
    exit
}
set pcntbkgtraff \
    [ expr 100.0* $prevstat(background,byte,arr,$TargetDirection) / $prevstat(total,byte,arr,$TargetDirection) ]
if {$findtarget && ([expr abs($pcntbkgtraff - $targetpcntbps) ] >= [expr $error*$targetpcntbps])} {
    # estimate a scale that will achieve this
     if { $pcntbkgtraff < $targetpcntbps} {
	set closest_high_scale $scale
	set closest_low_pcntbps $pcntbkgtraff
	set scale_incr \
	    [expr ($pcntbkgtraff - $targetpcntbps) / \
		 $targetpcntbps * ($closest_high_scale - $closest_low_scale)]
    } else {
	set closest_low_scale $scale
	set closest_high_pcntbps $pcntbkgtraff
	set scale_incr \
	    [expr ($pcntbkgtraff - $targetpcntbps) / \
		 $pcntbkgtraff *  abs($closest_high_scale - $closest_low_scale)]
    }
    set scale [expr $scale + $scale_incr]
    puts $nsoutfd_ [format "Av Pcnt Bkg Traff %f, low_scale %f, high Bkg Traff %f, high scale %f low Bkg Traff %f" $pcntbkgtraff $closest_low_scale $closest_high_pcntbps $closest_high_scale $closest_low_pcntbps]
}

if { $findtarget } {
    if { ([expr abs($pcntbkgtraff - $targetpcntbps)] < [expr $error*$targetpcntbps]) } {
	set scale -1.0
	incr ExperimentIteration
    }
} else {
    incr ExperimentIteration
}
if {$ExperimentIteration > $NumExperiments} {
    set NewExperimentIteration -1 
} else {
    set NewExperimentIteration $ExperimentIteration
}

# Some ns code prints debug messages to stdout,
# so to identify this message it is prefixed with tcpevalscales.
puts stdout [format "tcpevaliterations,%d,%f,%f,%f,%f,%f" \
		 $NewExperimentIteration \
		 $closest_low_scale $closest_high_pcntbps \
		 $closest_high_scale $closest_low_pcntbps $scale]
close $nsoutfd_
exit 0



