 
			
			Class BlackHole
global ns god_ XX_ YY_ node NumberCluster arr_index_CH arr_index_CN arr_multi_CN arr_multi_CH AllCluster ClusterNode ComNode NodeNumber val(nn) sink_nod CH
proc RandomInteger4 {min max} {
    return [expr {int(rand()*($max-$min+1)+$min)}]
}
#===================distance calculate========================
BlackHole instproc calcDist {node_a node_b } {
	
	
	set x1 [$node_a set X_]
	set y1 [$node_a set Y_]
	
	set x2 [$node_b set X_]
	set y2 [$node_b set Y_]
	
	set distance [expr "sqrt(($x2-$x1)*($x2-$x1)+($y2-$y1)*($y2-$y1))"]
	
	return $distance
	
}
#=====================end distance calculate===================
# make all defualt class gnerator
BlackHole instproc create {n g XX YY} {
	global ns god_ XX_ YY_ ComNode
	set ns $n 
	set god_ $g
	set XX_ $XX
	set YY_ $YY
	set ComNode 0
}
#================== wireless node configure============
BlackHole instproc NodeConfig {topo number_node } {
	global ns 
	set val(chan)           Channel/WirelessChannel    ;# channel type
	set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
	set val(netif)          Phy/WirelessPhy            ;# network interface type
	set val(mac)            Mac/802_11                 ;# MAC type
	set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
	set val(ll)             LL                         ;# link layer type
	set val(ant)            Antenna/OmniAntenna        ;# antenna model
	set val(ifqlen)         50                      ;# max packet in ifq
	set val(nn)             $number_node                          ;# number of mobilenodes
	set val(rp)             DumbAgent
       
			set chan_1_ [new $val(chan)]
			    
			    $ns node-config -adhocRouting $val(rp) \
			    -llType $val(ll) \
			    -macType $val(mac) \
			    -ifqType $val(ifq) \
			    -ifqLen $val(ifqlen) \
			    -antType $val(ant) \
			    -propType $val(prop) \
			    -phyType $val(netif) \
			    -channelType $val(chan) \
			    -topoInstance $topo \
			    -agentTrace ON \
			    -routerTrace ON \
			    -macTrace OFF \
			    -movementTrace ON 
#		set val(chan)           Channel/WirelessChannel    ;# channel type
#		set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
#		set val(netif)          Phy/WirelessPhy            ;# network interface type
#		set val(mac)            Mac/802_11                 ;# MAC type
#		set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
#		set val(ll)             LL                         ;# link layer type
#		set val(ant)            Antenna/OmniAntenna        ;# antenna model
#		set val(ifqlen)         50                      ;# max packet in ifq
#		set val(nn)             $number_node                          ;# number of mobilenodes
#		set val(rp)            AODV  
#	       
#				    set chan_1_ [new $val(chan)]
#				    Node/MobileNode/SensorNode set sensingPower_ 0.015
#				    Node/MobileNode/SensorNode set processingPower 0.024
#				    Node/MobileNode/SensorNode set instructionsPerSecond_ 8000000		   
#				    Antenna/OmniAntenna set X_ 0 ;
#				    Antenna/OmniAntenna set Y_ 0 ;
#				    Antenna/OmniAntenna set Z_ 1.5 ;
#				    Antenna/OmniAntenna set Gt_ 1.0 ;
#				    Antenna/OmniAntenna set Gr_ 1.0 ;		    
#				    ####  Setting The Distance Variables
#					set val(port) 0
#					
#					Agent/RCAgent set sport_           $val(port)
#					Agent/RCAgent set dport_           $val(port)
#					Agent/RCAgent set packetMsg_       0
#					Agent/RCAgent set distEst_         0
#					Agent/RCAgent set packetSize_      0
#																 
#					RCALinkLayer set delay_            25us
#					RCALinkLayer set bandwidth_        [Phy/WirelessPhy set bandwidth_]
#					RCALinkLayer set off_prune_        0
#					RCALinkLayer set off_CtrMcast_     0
#					RCALinkLayer set macDA_            0
#					RCALinkLayer set debug_            0	
				    
				    # For model 'TwoRayGround'
				    set dist(5m)  7.69113e-06
				    set dist(9m)  2.37381e-06
				    set dist(10m) 1.92278e-06
				    set dist(11m) 1.58908e-06
				    set dist(12m) 1.33527e-06
				    set dist(13m) 1.13774e-06
				    set dist(14m) 9.81011e-07
				    set dist(15m) 8.54570e-07
				    set dist(16m) 7.51087e-07
				    set dist(20m) 4.80696e-07
				    set dist(25m) 3.07645e-07
				    set dist(30m) 2.13643e-07
				    set dist(35m) 1.56962e-07
				    set dist(40m) 1.56962e-10
				    set dist(45m) 1.56962e-11
				    set dist(50m) 1.20174e-13
#				    Phy/WirelessPhy set CSThresh_ $dist(50m)
#				    Phy/WirelessPhy set RXThresh_ $dist(50m)
				    #  Defining Node Configuration
#					  
#				    $ns node-config -adhocRouting $val(rp) \
#				     -llType $val(ll) \
#				     -macType $val(mac) \
#				     -ifqType $val(ifq) \
#				     -ifqLen $val(ifqlen) \
#				     -antType $val(ant) \
#				     -propType $val(prop) \
#				     -phyType $val(netif) \
#				     -topoInstance $topo \
#				     -agentTrace ON \
#				     -routerTrace ON \
#				     -macTrace ON \
#				     -movementTrace ON \
#				     -channel $chan_1_	
	$ns node-config  -energyModel EnergyModel/Battery \
	-initialEnergy 10.0 \
	-rxPower 0.124 \
	-txPower 0.136 

	
}
#===================end node configure========================
#===========================================================
 BlackHole instproc CreatedCommonNode {X Y rng NodeNumber} {
	global n ns node NumberCluster god_ XX_ sink_nod 
	
	set ring {}
	set  Allringnode {} 

	
	for {set i 0} {$i < $NodeNumber} {incr i} {
		
	      set node($i) [$ns node]
		
		#$node($i) random-motion 0
	
		$node($i) set X_ [$rng uniform 0.0 $X]
		$node($i) set Y_ [$rng uniform 0.0 $Y]
		
		$node($i) set Z_ 0.0 ;#flat ground

		$ns initial_node_pos $node($i) 25
		
	
		 
	  }

		  
	 
	
	
}
#======================create sink node and connection ========
BlackHole instproc Sink_Node {start stop loop} {
	global ns god_ XX_ node sink_nod XX_ NumberCluster
	

# close the file, ensuring the data is written out before you continue
#  with processing.

if {$loop == true } {
	set sink_nod [$ns node]
	
			
		
		$god_ new_node $sink_nod
		#$god_ set-dist 1 2 2
		$sink_nod set X_ [expr $XX_+30 ]
		$sink_nod set Y_ 0.0
		$sink_nod set Z_ 0.0
		
		
		$ns at $start "[$ns initial_node_pos $sink_nod [expr int ($XX_ / 9)]]"
		
		$ns at $start "$sink_nod label Sink"
		$ns at $start "$sink_nod add-mark MARK red hexagon"
		$sink_nod color #FFFFFF
		$ns at $start "$sink_nod color #FFFFFF"
}
	 
#	#puts "1"
#set node_count [array size NumberCluster]
#	#puts "....................$node_count"
#	for {set i 0 } {$i < $node_count } {incr i } {
#		set udp($i) [$ns create-connection UDP $sink_nod LossMonitor $node($NumberCluster($i)) 0]
#		$udp($i) set fid_ 1
#		$udp($i) set interval_ 5
#		#Setup a CBR over UDP connection
#		set cbr($i) [$udp($i) attach-app Traffic/CBR]
#		
#		
#		$cbr($i) set packet_size_ 1000
#		$cbr($i) set interval_ 5
#		$cbr($i) set type_ CBR
#		
#		$cbr($i) set rate_ 1mb
#		$cbr($i) set random_ false
#		$ns at $start "$cbr($i) start"
#		$ns at $start "$cbr($i) stop"
#		
#	
#	}
	#array set array_clusterheads $number_clusterheads
	#array set array_nodes $arr_nodes
#set count_array_CH [array size array_clusterheads]

	
}
#===========================end of sink node =======================================

BlackHole instproc ClusterHead { NodeNumber  } {
       global n NumberCluster node sink_nod Allringnode alldist ns
    set count_all_ring [llength $Allringnode]
	set ringing {}
	set disting {}
	for {set i 0 } {$i < $count_all_ring } {incr i } {
		set ringing [lindex $Allringnode $i]
		set disting [lindex $alldist $i]
		set ringing_backup $ringing
		puts $ringing_backup
		set rand_cluster [RandomInteger4 0 9]
		
		set fbh [lindex $disting $rand_cluster]
		set cluster_head [lindex $ringing $rand_cluster]
		set CX [$node($cluster_head) set X_]
		set CY [$node($cluster_head) set Y_]
		#$ns at 0.0 "$node([lindex $ringing $rand_cluster]) add-mark MARK red hexagon"
		lappend NumberCluster [lindex $ringing $rand_cluster]
		set id [lsearch  $ringing [lindex $ringing $rand_cluster]]
		
		set ringing [lreplace $ringing $id $id]
		
		set id [lsearch  $disting $fbh]
		
		set disting [lreplace $disting $id $id]
		puts $disting
		puts $ringing
		set ring_count [llength $ringing]
		set Zfi 0
		for {set j 0 } {$j< $ring_count } {incr j } {
		set Zfi [expr $Zfi + [lindex $disting $j]]
			set nodeX [$node([lindex $ringing $j]) set X_]
			set nodeY [$node([lindex $ringing $j]) set Y_]
			puts $Zfi
			set r [expr ($fbh/$Zfi)*5]
			set R 150
	    if {$nodeX > $CX && $nodeY > $CY} {
		set newX [RandomInteger4 [expr $CX+$r] [expr $CX + $R]]
		    set newY [RandomInteger4 [expr $CY+$r] [expr $CY + $R]]
	    }
	    if {$nodeX > $CX && $nodeY < $CY} {
		set newX [RandomInteger4 [expr $CX+$r] [expr $CX + $R]]
		set newY [RandomInteger4 [expr $CY-$r] [expr $CY - $R]]
	    }
	    if {$nodeX < $CX && $nodeY > $CY} {
		set newX [RandomInteger4 [expr $CX-$r] [expr $CX - $R]]
		set newY [RandomInteger4 [expr $CY+$r] [expr $CY + $R]]
	    }
	    if {$nodeX < $CX && $nodeY < $CY} {
		set newX [RandomInteger4 [expr $CX-$r] [expr $CX - $R]]
		set newY [RandomInteger4 [expr $CY-$r] [expr $CY - $R]]
	    }
			
			if {$newX < 0 } {set newX [expr $newX *(-1)]}
			if {$newY <0 } {set newY [expr $newY *(-1)]}
			$ns at 0.0 "$node([lindex $ringing $j]) setdest $newX $newY 1000"
			
		}
		for {set j 0 } {$j< $ring_count } {incr j } {
						
					}
		
		
	}
	
}
#=============end select cluster head===================
#===============make a ring distance for select node array in ring==============
BlackHole instproc MakeRinge {NodeNumber } {
	global ns node sink_nod Allringnode alldist
	set dist {}
	set alldist {}
	for { set j 0 } {$j < $NodeNumber } { incr j } {
#		set dist_of_cluster [$self calcDist $node($j) $sink_nod]  
#		$ns at 0.0 "$node($j) label $dist_of_cluster"
	    set dist_of_cluster [$self calcDist $node($j) $sink_nod]
		lappend dist $dist_of_cluster
	    if { $dist_of_cluster < 400  } {
		lappend ring   $j
	    }
    
	}
	
	for { set j 0 } {$j < $NodeNumber } { incr j } {
	    set dist_of_cluster [$self calcDist $node($j) $sink_nod]
	    if { $dist_of_cluster >= 400 && $dist_of_cluster <= 500 } {
		lappend ring   $j
	    }
    
	}
	
	for { set j 0 } {$j < $NodeNumber } { incr j } {
	    set dist_of_cluster [$self calcDist $node($j) $sink_nod]
	    if { $dist_of_cluster >= 501 && $dist_of_cluster <= 600 } {
		lappend ring   $j
	    }
    
	}
	
	for { set j 0 } {$j < $NodeNumber } { incr j } {
	    set dist_of_cluster [$self calcDist $node($j) $sink_nod]
	    if { $dist_of_cluster >= 600 && $dist_of_cluster <= 700 } {
		lappend ring   $j
	    }
    
	}
	
	for { set j 0 } {$j < $NodeNumber } { incr j } {
	    set dist_of_cluster [$self calcDist $node($j) $sink_nod]
	    if { $dist_of_cluster >= 700 && $dist_of_cluster <= 800 } {
		lappend ring   $j
	    }
    
	}
	
	for { set j 0 } {$j < $NodeNumber } { incr j } {
	    set dist_of_cluster [$self calcDist $node($j) $sink_nod]
	    if { $dist_of_cluster >=800 && $dist_of_cluster <= 900 } {
		lappend ring   $j
	    }
    
	}
	
	for { set j 0 } {$j < $NodeNumber } { incr j } {
	    set dist_of_cluster [$self calcDist $node($j) $sink_nod]
	    if { $dist_of_cluster >= 900 && $dist_of_cluster <= 1000 } {
		lappend ring   $j
	    }
    
	}
	
	     for { set j 0 } {$j < $NodeNumber } { incr j } {
		 set dist_of_cluster [$self calcDist $node($j) $sink_nod]
		 if { $dist_of_cluster >= 1000 && $dist_of_cluster <= 1100 } {
		     lappend ring   $j
		 }
	 
	     }
	     
	     for { set j 0 } {$j < $NodeNumber } { incr j } {
			 set dist_of_cluster [$self calcDist $node($j) $sink_nod]
			 if {  $dist_of_cluster >= 1100  && $dist_of_cluster <= 1200} {
			     lappend ring   $j
			 }
		 
		     }
		   
	for { set j 0 } {$j < $NodeNumber } { incr j } {
			       set dist_of_cluster [$self calcDist $node($j) $sink_nod]
			       if {  $dist_of_cluster > 1200 } {
				   lappend ring   $j
			       }
		       
			   }
			  
			    
				      
	set ring_backup $ring
	set ring_isolated {}
	set dist_ta {}
	set jj 0
	for {set i 0 } {$i< 10 } {incr i } {
		
	for {set j $jj } { $j <[expr $jj+10] } {incr j } {
		
		lappend  ring_isolated [lindex $ring $j]
		lappend dist_ta [lindex $dist $j]
	}
		set jj [expr $jj +10]
		lappend Allringnode $ring_isolated 
		lappend alldist $dist_ta
		set dist_ta {}
		set ring_isolated {}
	
	}
	puts "$Allringnode"
	puts $alldist
}
#===============end of make rings==========================
#================start connection==========================
BlackHole instproc Connection {start stop} {
	global n NumberCluster node sink_nod Allringnode alldist ns
	set count_all_ring [llength $Allringnode]
	set ringing {}
	for {set i 0 } {$i < $count_all_ring } {incr i } {
		set ringing [lindex $Allringnode $i]
		set sink($i) [new Agent/TCPSink]
		 $ns attach-agent $node([lindex $NumberCluster $i]) $sink($i)
		set tcpaccesspoint [new Agent/TCP/Newreno]
		$tcpaccesspoint  set class_ 2
		$ns attach-agent  $sink_nod $tcpaccesspoint
		$ns connect $tcpaccesspoint $sink($i)
		set ftp1 [new Application/FTP]
		$ftp1 attach-agent $tcpaccesspoint
		$ns at $start "$ftp1 start"
		$ns at $stop "$ftp1 stop" 
		set ring_count [llength $ringing]
		for {set j 0 } {$j< $ring_count } {incr j } {
			set tcp($j) [new Agent/TCP/Newreno]
			$tcp($j) set class_ 2	
			$ns attach-agent $node([lindex $ringing $j]) $tcp($j)
			$ns connect $tcp($j) $sink($i)
			set ftp($j) [new Application/FTP]
			$ftp($j) attach-agent $tcp($j)
			$ns at $start "$ftp($j) start"
			$ns at $stop "$ftp($j) stop" 
		}
	}
	
}
#===================end connection=========================
#===================Changing Cluster Head==================
BlackHole instproc ChangingClusterHead {} {
	global n NumberCluster node sink_nod Allringnode alldist ns
	
	set count_NumberCluster [llength $NumberCluster]
	set blackh [new Agent/blackhole]
	$blackh all-cluster "$Allringnode"
	$blackh cluster-head "$NumberCluster"
	
	
	
	
}
#==================End changing cluster head===========	

