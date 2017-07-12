############################################################################
#
# Protocol PEGASIS
# 25.4.2012
# Tomas Takacs - FIIT STUBA
#
############################################################################

# Message Constants
set DATA           3
set MAC_BROADCAST  0xffffffff
set LINK_BROADCAST 0xffffffff
set BYTES_ID       2
set INFO           4
set BS_CH_INFO     5

############################################################################
#
# Pegasis Application
#
############################################################################

# New application Pegasis
Class Application/PEGASIS -superclass Application

# Init
Application/PEGASIS instproc init args {

  global opt
# global scheduling for sending data
  global gnewsch1

  $self instvar rng_ isch_ hasbeench_ next_change_time_ round_
  $self instvar clusterChoices_ clusterDist_ clusterNodes_ currentCH_ 
  $self instvar xmitTime_  dist_ code_
  $self instvar now_ alive_ frame_time_ end_frm_time_
  $self instvar begin_idle_ begin_sleep_
  $self instvar myADVnum_ receivedFrom_ dataReceived_
  $self instvar next_hop_ hasNextHop_ TDMAschedule_ 

  set rng_ [new RNG] 
  $rng_ seed 0
  set isch_ 0
  set hasbeench_ 0
  set next_change_time_ 0
  set round_ 0
  set clusterChoices_ ""
  set clusterDist_ ""
  set clusterNodes_ ""
  set currentCH_ ""
  set xmitTime_ ""
  set TDMAschedule_ ""
  set dist_ 0
  set code_ 0
  set now_ 0
  set alive_ 1
  set frame_time_ $opt(frame_time)
  set end_frm_time_ 0
  set begin_idle_ 0
  set begin_sleep_ 0
  set myADVnum_ 0
  set receivedFrom_ ""
  set dataReceived_ ""
  set next_hop_ ""  
  set hasNextHop_ 0
  set gnewsch1 ""
  $self next $args
}

# Start
Application/PEGASIS instproc start {} {
  global gnewsch1 time1 

  set time1 0  
  [$self mac] set node_num_ [$self nodeID]  
  $self advertiseInfo
  $self checkAlive
}

# Delete TDMA schedule every once for a ch_time (20 seconds)
proc deleteTdma {} {
  global gnewsch1 time1 ns_
  if {[$ns_ now] != $time1} {
    set gnewsch1 ""
    set time1 [$ns_ now]
  }
  return 
}

############################################################################
#
# Set-up Functions
#
############################################################################

Application/PEGASIS instproc advertiseInfo {} {

  global ns_ chan opt bs INFO MAC_BROADCAST LINK_BROADCAST BYTES_ID
  $self instvar code_ beginningE_ now_ alive_

  # Check the alive status of the node.  If the node has run out of
  # energy, it no longer functions in the network.
  set ISalive [[[$self node] set netif_(0)] set alive_]
  if {$alive_ == 1 && $ISalive == 0} {
    puts "Node [$self nodeID] is DEAD!!!! Energy = [[$self getER] query] - ns-pegasis.tcl"
    $chan removeif [[$self node] set netif_(0)]
    set alive_ 0
    set opt(nn_) [expr $opt(nn_) - 1]
  }
  if {$alive_ == 0} {return}

  # Send (X,Y)-coordinates and current energy information to BS.
  $self setCode $opt(bsCode)
  $self WakeUp
  set now_ [$ns_ now]
  set nodeID [$self nodeID]
  set X [$self getX]
  set Y [$self getY]
  set E [[$self getER] query]
  set mac_dst $MAC_BROADCAST
  set link_dst $LINK_BROADCAST
  set msg [list [list [list $X $Y $E]]]
  set datasize [expr $BYTES_ID * [llength [list $X $Y $E]]] 
  set dist [nodeToBSDist [$self node] $bs] 
  set beginningE_ $E

  # Each node transmits to the base station in a given time slot.
  set xmitat [expr [$ns_ now] + [expr $nodeID * $opt(adv_info_time)]]

  $ns_ at $xmitat "$self send $mac_dst $link_dst $INFO $msg \
                         $datasize $dist $code_"
  $self GoToSleep
  # Must wake up to hear cluster information from the base station. 
  set wakeUpTime [expr [$ns_ now] + $opt(finish_adv)]
  $ns_ at $wakeUpTime "$self WakeUp"
}


Application/PEGASIS instproc checkAlive {} {

  global ns_ chan opt node_
  $self instvar alive_ TDMAschedule_ begin_idle_ begin_sleep_
  
  # Check the alive status of the node.  If the node has run out of
  # energy, it no longer functions in the network.
  set ISalive [[[$self node] set netif_(0)] set alive_]
  if {$alive_ == 1} {
    if {$ISalive == 0} {
      puts "Node [$self nodeID] is DEAD!!!! - ns-pegasis.tcl"
      $chan removeif [[$self node] set netif_(0)]
      set alive_ 0
      set opt(nn_) [expr $opt(nn_) - 1]
    } else {
      $ns_ at [expr [$ns_ now] + 0.1] "$self checkAlive"      
    }
  }
  if {$opt(nn_) < $opt(num_clusters)} "sens_finish"
}

############################################################################
#
# Helper Functions from ns-leach
#
############################################################################

Application/PEGASIS instproc node {} {
  return [[$self agent] set node_]
}

Application/PEGASIS instproc nodeID {} {
  return [[$self node] id]
}

Application/PEGASIS instproc mac {} {
  return [[$self node] set mac_(0)]
}

Application/PEGASIS instproc getX {} {
  return [[$self node] set X_]
}

Application/PEGASIS instproc getY {} {
  return [[$self node] set Y_]
}

Application/PEGASIS instproc getER {} {
  set er [[$self node] getER]
  return $er
}

Application/PEGASIS instproc setCode code {
  $self instvar code_
  set code_ $code
  [$self mac] set code_ $code
}

Application/PEGASIS instproc GoToSleep {} {
  global opt ns_
  $self instvar begin_idle_ begin_sleep_
  set nodeID [$self nodeID]
   
  [[$self node] set netif_(0)] set sleep_ 1

  # If node has been awake, remove idle energy (e.g., the amount of energy
  # dissipated while the node is in the idle state).  Otherwise, the node
  # has been asleep and must remove sleep energy (e.g., the amount of
  # energy dissipated while the node is in the sleep state).
  if {$begin_idle_ > $begin_sleep_} {
    set idle_energy [expr $opt(Pidle) * [expr [$ns_ now] - $begin_idle_]]    
    [$self getER] remove $idle_energy
  } else {
    set sleep_energy [expr $opt(Psleep) * [expr [$ns_ now] - $begin_sleep_]]    
    [$self getER] remove $sleep_energy
  }
  set begin_sleep_ [$ns_ now]
  set begin_idle_ 0
}

Application/PEGASIS instproc WakeUp {} {
  global opt ns_ node_
  $self instvar begin_idle_ begin_sleep_
  $self instvar hasNextHop_ next_hop_
  set nodeID [$self nodeID]
  
# Wake up sender and receiver
  [[$self node] set netif_(0)] set sleep_ 0
  if {$hasNextHop_ == 1} {
      [$node_($next_hop_) set netif_(0)] set sleep_ 0
  }
  
  # If node has been asleep, remove sleep energy (e.g., the amount of energy
  # dissipated while the node is in the sleep state).  Otherwise, the node
  # has been idling and must remove idle energy (e.g., the amount of
  # energy dissipated while the node is in the idle state).
  if {$begin_sleep_ > $begin_idle_} {
    set sleep_energy [expr $opt(Psleep) * [expr [$ns_ now] - $begin_sleep_]]    
    [$self getER] remove $sleep_energy
  } else {
    set idle_energy [expr $opt(Pidle) * [expr [$ns_ now] - $begin_idle_]]  
    [$self getER] remove $idle_energy
  }
  set begin_idle_ [$ns_ now]
  set begin_sleep_ 0
}

############################################################################
#
# Cluster Head Functions - from LEACH
#
############################################################################

Application/PEGASIS instproc setClusterHead {} {
  $self instvar isch_ hasbeench_
  set isch_ 1
  set hasbeench_ 1
  return 
}

Application/PEGASIS instproc unsetClusterHead {} {
  $self instvar isch_
  set isch_ 0
  return 
}

############################################################################
#
# Receiving Functions
#
############################################################################

Application/PEGASIS instproc recv {args} {

  global BS_CH_INFO DATA 

  set msg_type [[$self agent] set packetMsg_]
  set receiver [lindex $args 0]  
  set sender [lindex $args 1]
  set data_size [lindex $args 2]
  set msg [lrange $args 3 end]
  set nodeID [$self nodeID]
  
  if {$msg_type == $BS_CH_INFO} {
    $self recvBS_CH_INFO $msg
  } elseif {$msg_type == $DATA} {
    if {$nodeID != $receiver} {
#  	puts "Bad receive nodeID $nodeID != receiver $receiver"
  } 
    if {$nodeID == $receiver} {
# 	puts "Good receive nodeID $nodeID == receiver $receiver"
	$self recvDATA $msg
    }                           
  } 
}


Application/PEGASIS instproc recvBS_CH_INFO {msg} {

    global opt ns_ node_
    global gnewsch1

    $self instvar currentCH_ clusterNodes_ 
    $self instvar now_ next_change_time_ dist_ code_
    $self instvar beginningE_ frame_time_ end_frm_time_ xmitTime_
    $self instvar TDMAschedule_ next_hop_ hasNextHop_    

    set nodesAbove_ ""
    set nodesAboveSorted_ ""
    set nodesUnder_ ""
    set nodesUnderSorted_ ""
    set nodesY_ ""
    set nodesUp ""
    set nodesDown ""
    set next_hop_ ""    
    set next_change_time_ [expr $now_ + $opt(ch_change)]
    set clusters [lindex [lindex [lindex $msg 0] 0] 0]   
    set id [$self nodeID]
    set my_ch [lindex $clusters $id]
    set currentCH_ $my_ch
    set CHnodes ""

# VYSVETLIVKY
# clusters = zoznam CH kazdeho uzla => pole [100] ale len 5 hodnot, ktore sa opakuju
# lindex => podla indexu najde v poli hodnotu. 
# 	    vid set my_ch [lindex $clusters $id]. Nastavi CH podla indexu id z pola clusters
# lsearch => vrati poziciu prveho umiestnenie elementu v poli (ak nie je all alebo inline).
#     	     Ak nenajne tak vrati -1
# 	    vid if {[lsearch $CHnodes $element] == -1} 
# 

    # Determine code for each cluster from BS information.
    foreach element $clusters {
      if {[lsearch $CHnodes $element] == -1} {
        set CHnodes [lappend CHnodes $element]
      }
    }
    $self setCode [expr [lsearch $CHnodes $my_ch] + 1]

    set outf [open $opt(dirname)/startup.energy a]
    puts $outf "[$ns_ now]\t$id\t[expr $beginningE_ - [[$self getER] query]] ns-pegasis.tcl"
    close $outf

    # Determine slot in  schedule from BS information.
    set i 0
    set clusterNodes_ ""

#   Vytvori TDMA schedule. Uzly v ramci klastra idu za sebou v poradi.
    foreach element $clusters {
      if {$element == $my_ch} {lappend clusterNodes_ $i}
      incr i
    }

    puts "Node $id's CH is $my_ch, code is $code_ at time [$ns_ now] - ns-pegasis.tcl" 

##START START START START START START START START START START START START START START 
##START START START START START START START START START START START START START START 

# Now there is not a global schedule
  if {$gnewsch1 ==""} {
  
      set sch1 ""      
      # Nodes are divided to nodes under and above CH node
      set head_Y 0
      set head_Y [getY $node_($my_ch)]
      foreach element $clusterNodes_ {
	  if {$element != $my_ch} {
	      set element_Y 0
	      set element_Y [getY $node_($element)]	      
#  	      puts "I am a node $element and my Y is $element_Y"
	      if {$element_Y >= $head_Y} {
		  lappend nodesAbove_ $element_Y
	      }	elseif {$element_Y < $head_Y} {
  		  lappend nodesUnder_ $element_Y
 	      }
	  }
      }
#       puts "Nodes above are $nodesAbove_ "

      set nodesAboveSorted_ [lsort -decreasing -real $nodesAbove_]                  
      append nodesY_ $nodesAboveSorted_
#       puts "Sorted nodes above are $nodesAboveSorted_"
      foreach element1 $nodesAboveSorted_ {
	  foreach element2 $clusterNodes_ {
	      if {[getY $node_($element2)] == $element1} {
		  if {[lsearch $sch1 $element2] == -1} {
		      if {$element2 != $my_ch} {
			  lappend sch1 $element2
			  lappend nodesUp $element2
		      }
		  }
	      }
	  }
      }
      lappend sch1 $my_ch
      lappend nodesY_ $head_Y
      append  nodesY_ " "

#       puts "Uzly pod $nodesUnder_ "
      set nodesUnderSorted_ [lsort -increasing -real $nodesUnder_]
      append nodesY_ $nodesUnderSorted_
#       puts "Sorted nodes under are $nodesAboveSorted_"
      foreach element1 $nodesUnderSorted_ {
	  foreach element2 $clusterNodes_ {
	      if {[getY $node_($element2)] == $element1} {
		  if {[lsearch $sch1 $element2] == -1} {
		      lappend sch1 $element2
		      lappend nodesDown $element2
		  }
	      }
	  }
      }

      set newsch1 ""
      set lup [llength $nodesUp]
      set ldown [llength $nodesDown]    

      # Add nodes above
      set firstNode [lindex $nodesUp 0]
      set delindex [lsearch $nodesUp $firstNode]
      # puts "delindex is $delindex"
      lappend newsch1 $firstNode
    
      set x 1
      while {$x < $lup} {
	  set min_dist_ $opt(max_dist)
	  # Delete node with delindex from nodesUp
	  set nodesUp [lreplace $nodesUp $delindex $delindex ]	
	  set nearest_neighbor_ $firstNode
	  foreach element $nodesUp {
	      if {$element != $firstNode} {
		  set distance_ 0	  
		  set distance_ [nodeDist $node_($firstNode) $node_($element)]
		  if {$distance_ < $min_dist_ } {
		      set min_dist_ $distance_
		      set nearest_neighbor_ $element
		  }		  
	      }    
	  }
	  #  puts "Nearest neighbor is  $nearest_neighbor_ with distance $min_dist_ "
	  #  Add nearest neighbor TDMAschedule 
	  lappend newsch1 $nearest_neighbor_
	  set lnewsch1 [llength $newsch1]
	  #     puts "newsch1 je $newsch1 a dlzka je $lnewsch1"
	  set firstNode $nearest_neighbor_
	  set delindex [lsearch $nodesUp $firstNode]
	  incr x
      }

      # Add CH node
      lappend newsch1 $my_ch

      # Add nodes under
      set firstNode [lindex $nodesDown 0]
      set delindex [lsearch $nodesDown $firstNode]      
      lappend newsch1 $firstNode
    
      set x 1
      while {$x < $ldown} {
	  set min_dist_ $opt(max_dist)
	  set nodesDown [lreplace $nodesDown $delindex $delindex ]	  
	  set nearest_neighbor_ $firstNode
	  foreach element $nodesDown {
	      if {$element != $firstNode} {
		  set distance_ 0	  
		  set distance_ [nodeDist $node_($firstNode) $node_($element)]
		  if {$distance_ < $min_dist_ } {
		      set min_dist_ $distance_
		      set nearest_neighbor_ $element
		  }		  
	      }    
	   }
	   #  puts "Nearest neighbor is  $nearest_neighbor_ with distance $min_dist_ "
	   lappend newsch1 $nearest_neighbor_
	   set gnewsch1 [join $newsch1]  
	   set lnewsch1 [llength $newsch1]
	   # puts "newsch1 je $newsch1 a dlzka je $lnewsch1"
	   set firstNode $nearest_neighbor_
	   set delindex [lsearch $nodesDown $firstNode]
	   incr x
      } 

      set lnewsch1 [llength $newsch1]
      set loldsch1 [llength $sch1]
# koniec

   } elseif {$gnewsch1 != ""} {
	set newsch1 [join $gnewsch1] 
 }

##KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC 
##KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC KONIEC 
      
      set TDMAschedule_ [join $newsch1]    
      set frame_time_ [expr [expr 5 + [llength $TDMAschedule_]] * \
                          $opt(ss_slot_time)]    


    if {$my_ch == $id} {
      # Node is a CH for this round.  Record TDMA schedule.
      puts "CH $id: TDMAschedule is $TDMAschedule_ - ns-pegasis.tcl"
      puts "******************************************* - ns-pegasis.tcl"
      set hasNextHop_ 0
      $self WakeUp 
      $self setClusterHead
      set dist_ $opt(max_dist)
      set outf [open $opt(dirname)/TDMAschedule.[expr round($now_)].txt a] 
      puts $outf "$my_ch\t$TDMAschedule_ - ns-pegasis.tcl"      
      close $outf
      if {[llength $TDMAschedule_] == 1} {
        puts "Warning!  There are no nodes in this cluster ($id)! - ns-pegasis.tcl"
        $self SendMyDataToBS	
      }      
    $self GoToSleep

    } elseif {$my_ch > -1} {
      # Node is a cluster member for this round.  Schedule a data
      # transmission to the cluster-head during TDMA slot.
      $self unsetClusterHead
      set position [lsearch $TDMAschedule_ $id]      
      set next_hop_ -1      
      set next_hop_ [lindex $TDMAschedule_ [expr $position + 1]]      
      
      if {$next_hop_ < 0} {set next_hop_ $my_ch}
      set dist_ [nodeDist [$self node] $node_($next_hop_)]
      puts "I'm a node $id , Y = [$self getY] , position = $position ,next hop =  $next_hop_ , next hop distance = $dist_ ns-pegasis.tcl"
      set outf [open $opt(dirname)/Distance.[expr round($now_)].txt a] 
      puts $outf "$id\t$next_hop_\t$dist_"      
      close $outf
       if {$position < 0} {
         puts "ERROR!!!!  $id does not have a transmit time!"
         exit 0
       }    
      set xmitTime_ [expr $opt(ss_slot_time) * $position]
      set end_frm_time_ [expr $frame_time_ - $xmitTime_]
      set xmitat [expr [$ns_ now] + $xmitTime_]
      if {[expr $xmitat + $end_frm_time_] < \
          [expr $next_change_time_ - 10 * $opt(ss_slot_time)]} {
        $ns_ at $xmitat "$self sendData"
      }      
      $self GoToSleep
    }
    $ns_ at $next_change_time_ "$self advertiseInfo"
    $ns_ at $next_change_time_ "deleteTdma"    
}

# receive data function
Application/PEGASIS instproc recvDATA {msg} {

  global ns_ opt node_

  $self instvar dataReceived_ TDMAschedule_ currentCH_
  $node_($currentCH_) instvar receivedFrom_

  set chID $currentCH_
  set receiver [$self nodeID] 
  set nodeID [lindex $msg 0]

  pp "Receiver $receiver received data ($msg) from $nodeID at [$ns_ now] and CH is $currentCH_ - ns-pegasis.tcl"  
  set receivedFrom_ [lappend receivedFrom_ $nodeID]

  set last_node [expr [llength $TDMAschedule_] - 1]
  if {$currentCH_ == [lindex $TDMAschedule_ $last_node]} {
    set last_node [expr $last_node - 1]
  }
  if {$nodeID == [lindex $TDMAschedule_ $last_node]} {
    # After an entire frame of data has been received, the chain-head
    # must perform data aggregation functions and transmit the aggregate
    # signal to the base station.
    pp "CH $currentCH_ must now perform comp and xmit to BS. - ns-pegasis.tcl"
    set num_sigs [llength $TDMAschedule_]
    set compute_energy [bf $opt(sig_size) $num_sigs]
    pp "\tcompute_energy = $compute_energy - ns-pegasis.tcl"
    puts "Energy before [[$self getER] query]"
    [$self getER] remove $compute_energy
    puts "Energy after [[$self getER] query]"
    set receivedFrom_ [lappend receivedFrom_ $chID]
    set dataReceived_ $receivedFrom_
    set receivedFrom_ ""    
    $self SendDataToBS    
  }
}

############################################################################
#
# Sending Functions
#
############################################################################

Application/PEGASIS instproc sendData {} {

  global ns_ opt DATA MAC_BROADCAST BYTES_ID node_

  $self instvar next_change_time_ frame_time_ end_frm_time_
  $self instvar currentCH_ dist_ code_ alive_ 
  $self instvar next_hop_ hasNextHop_

  set nodeID [$self nodeID]
  set msg [list [list $nodeID , [$ns_ now]]]
  # Use DS-SS to send data messages to avoid inter-cluster interference.
  set spreading_factor $opt(spreading)
  set datasize [expr $spreading_factor * \
               [expr [expr $BYTES_ID * [llength $msg]] + $opt(sig_size)]]
#   puts "$spreading_factor * $BYTES_ID * [llength $msg] + $opt(sig_size)"
  set hasNextHop_ 1
  $self WakeUp
  pp "$nodeID sending data $msg to $next_hop_ at [$ns_ now] (dist = $dist_) - ns-pegasis.tcl"
  set mac_dst $MAC_BROADCAST
  set link_dst $next_hop_
  $self send $mac_dst $link_dst $DATA $msg $datasize $dist_ $code_

  # Must transmit data again during slot in next TDMA frame.
  set xmitat [expr [$ns_ now] + $frame_time_]
  if {$alive_ && [expr $xmitat + $end_frm_time_] < \
                 [expr $next_change_time_ - 10 * $opt(ss_slot_time)]} {
    $ns_ at $xmitat "$self sendData"
  } 
  set sense_energy [expr $opt(Esense) * $opt(sig_size) * 8]
#   pp "Node $nodeID removing sensing energy = $sense_energy J. - ns-pegasis.tcl"
  [$self getER] remove $sense_energy
  $self GoToSleep     
}

Application/PEGASIS instproc send {mac_dst link_dst type msg
                                      data_size dist code} {
  global ns_
  $self instvar rng_
  $ns_ at [$ns_ now]  "$self send_now $mac_dst \
      $link_dst $type $msg $data_size $dist $code"
}

Application/PEGASIS instproc send_now {mac_dst link_dst type msg \
                                          data_size dist code} {
    [$self agent] set packetMsg_ $type
    [$self agent] set dst_addr_ $mac_dst
    [$self agent] sendmsg $data_size $msg $mac_dst $link_dst $dist $code    
}

Application/PEGASIS instproc SendDataToBS {} {

      global ns_ opt bs MAC_BROADCAST DATA BYTES_ID
      $self instvar code_ rng_ now_ 

      # Data must be sent directly to the basestation.
      set nodeID [$self nodeID]
      set msg [list [list [list $nodeID , [$ns_ now]]]]
      # Use DS-SS to send data messages to avoid inter-cluster interference.
      set spreading_factor $opt(spreading)
      set datasize [expr $spreading_factor * \
                         [expr $BYTES_ID * [llength $msg] + $opt(sig_size)]]
      set dist [nodeToBSDist [$self node] $bs] 

      set mac_dst $MAC_BROADCAST
      set link_dst $opt(bsID)
      set random_delay [expr [$ns_ now] + [$rng_ uniform 0 0.01]]
      pp "Node $nodeID sending $msg to BS at time $random_delay - ns-pegasis.tcl"
      $ns_ at $random_delay "$self send $mac_dst $link_dst $DATA \
                             $msg $datasize $dist $opt(bsCode)"
}


Application/PEGASIS instproc SendMyDataToBS {} {

      global ns_ opt
      $self instvar next_change_time_ alive_

      puts "Data being sent to the Base Station - ns-pegasis.tcl"
      $self SendDataToBS
      puts "Data was sent to the base station - ns-pegasis.tcl"
      set xmitat [expr [$ns_ now] + $opt(frame_time)]
      if {$alive_ && [expr $xmitat + $opt(frame_time)] < \
                 [expr $next_change_time_ - $opt(frame_time)]} {
        $ns_ at $xmitat "$self SendMyDataToBS"
      } 
}
