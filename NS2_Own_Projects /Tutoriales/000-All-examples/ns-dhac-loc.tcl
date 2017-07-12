############################################################################
# ZCJ DHAC with LOCATION information (2007)
#    Developed as part of the WSNs project at Carleton University
############################################################################

# Message Constants
set MAC_BROADCAST    0xffffffff
set LINK_BROADCAST   0xffffffff
set BYTES_ID         2

set HELLO            0
set INVITE           2
set DATA             3
set POSITIVE_CONFIRM 4
set NEGATIVE_CONFIRM 5
set MERGE_REQ        6
set SCH_BROADCAST    7


Class Application/DHAC-LOC -superclass Application

############################################################################
# Start/End: DHAC-LOC algorithm Application
############################################################################
Application/DHAC-LOC instproc init args {

  global opt

  $self instvar rng_ dist_ code_
  $self instvar now_ now__ myADVnum_ merge_times_
  $self instvar alive_ begin_idle_ begin_sleep_
  $self instvar xmitTime_ frame_time_ end_frm_time_
  $self instvar receivedFrom_ dataReceived_
  $self instvar next_change_time_ ch_energy_level_
  
  set rng_ 		  [new RNG]
  $rng_ seed 		  0
  set dist_               0
  set now_ 		  0
  set now__               0
  set code_ 	 	  0
  set myADVnum_ 	  0
  set merge_times_        0
  set alive_ 		  1
  set begin_idle_ 	  0
  set begin_sleep_ 	  0
  set xmitTime_           ""
  set frame_time_         $opt(frame_time)
  set end_frm_time_       0
  set receivedFrom_       ""
  set dataReceived_       ""
  set next_change_time_   0
  set ch_energy_level_    0

  $self next $args
}

#===========================================================================
##### trigger the DHAC-LOC algorithm
Application/DHAC-LOC instproc start {} {

  global ns_ opt node_ neighbor totalDATA isChanged

  $self instvar now_

  set now_               [$ns_ now]
  set nodeID             [$self nodeID]
  set neighbor($nodeID)  [list]
  set totalDATA($nodeID) 0
  set isChanged($nodeID) 0
  set opt(frame_time)    [expr [expr $opt(ch_change) - 10 * $opt(ss_slot_time)]/5]

  [$self mac] set node_num_ [$self nodeID]
  $self setClusterHead $nodeID

  $self setupRESEMBLANCETABLE

  set next_phase_time [expr $now_ + $opt(step_span) * $opt(nn)] 
  $ns_ at $next_phase_time "$self executeDHAC"
}


############################################################################
# * 1 * SETUP PHASE: set up Resemblance table
############################################################################
##### the main function of  setting Resemblance table
Application/DHAC-LOC instproc setupRESEMBLANCETABLE {} {

  global chan ns_ opt node_
  
  $self instvar now__ beginningE_ alive_
  $self instvar myADVnum_ CHheard_

  set CHheard_ 0
  [$self mac] set CHheard_ $CHheard_
  set myADVnum_ 0
  [$self mac] set myADVnum_ $myADVnum_

  # Check the alive status of the node.  If the node has run out of
  # energy, it no longer functions in the network.
  set ISalive [[[$self node] set netif_(0)] set alive_]
  if {$alive_ == 1} {
    if {$ISalive == 0} {
      puts "Node [$self nodeID] is DEAD!!!! Energy = [[$self getER] query]"
      $chan removeif [[$self node] set netif_(0)]
      set alive_ 0
      set opt(nn_) [expr $opt(nn_) - 1]
      set opt(nn_alive) [expr $opt(nn_alive) - 1]
    } else {
      pp "SETUP PHASE: Node [$self nodeID] is ALIVE!!!! Energy = [[$self getER] query]"
    }
  }
  if {$alive_ == 0} {return}

  set now__ [$ns_ now]
  set nodeID [$self nodeID]
  set beginningE_ [[$self getER] query]

  $self setCode 0
  if {[$self isClusterHead? $nodeID]} { $self WakeUp } 

  $self exchangeHELLOMESSAGE

  set setup_table_time [expr $now__ + $opt(step_span) * $opt(nn_)] 
  $ns_ at $setup_table_time "$self TABLEPRINTING"
}

#===========================================================================
##### exchange the HELLO message
Application/DHAC-LOC instproc exchangeHELLOMESSAGE {} {
  global chan ns_ opt
  
  $self instvar now__
  
  #Calculate the distance between two nodes
  set distance $opt(trans_range)

  ##Send message closest_dis_ meters so the closest neighbor nodes can hear.
  set random_access [$self getRandomNumber 0 [expr $opt(ra_hello)*$opt(nn)]]
  $ns_ at [expr $now__ + $random_access] "$self sendHELLO $distance"
}

#===========================================================================
##### broadcast the HELLO message
Application/DHAC-LOC instproc sendHELLO {distance} {
  global ns_ opt node_
  global HELLO MAC_BROADCAST LINK_BROADCAST BYTES_ID

  $self instvar code_
  
  set chID [$self nodeID]

  set mac_dst $MAC_BROADCAST
  set link_dst $chID
  set msg $chID
  set datasize [expr $BYTES_ID * [llength $msg]]

  $self send $mac_dst $link_dst $HELLO $msg $datasize $distance $code_
  pp -file "msg" "NA\t[$ns_ now]\tsendHELLO\t$chID\tNA\t$HELLO\t$msg\t$datasize\t$distance\t$mac_dst\t$link_dst"

}

#====================================================================
# recieved the HELLO message
Application/DHAC-LOC instproc recvHELLO {sender} {

  global ns_ opt node_
  global neighbor
  
  set nodeID [$self nodeID]
  set distance [nodeDist $nodeID $sender]

  if {$distance <= $opt(trans_range)} {
     if {[lsearch $neighbor($nodeID) $sender] == -1} {
        lappend neighbor($nodeID) $sender
     } elseif {[lsearch $neighbor($sender) $nodeID] == -1} {
        lappend neighbor($sender) $nodeID
     }
  }
}

#===========================================================================
##### Print out Resemblance table
Application/DHAC-LOC instproc TABLEPRINTING {} {
  global chan ns_ opt
  global cluster neighbor matrix

  set nodeID [$self nodeID]
  
  set neighbor($nodeID) [lsort -integer $neighbor($nodeID)]
  set neighborf [open $opt(dirname)/$opt(filename).neighbor a]
  puts $neighborf "$nodeID\t$neighbor($nodeID)"
  close $neighborf

  set cluster($nodeID) $nodeID

  BUILD_MATRIX $nodeID
  set matrixf [open $opt(dirname)/$opt(filename).matrix a]
  puts $matrixf "$nodeID\t$matrix($nodeID)"
  close $matrixf

}

############################################################################

############################################################################
# * 2 * SETUP PHASE: DHAC-LOC Clustering phase
############################################################################
##### The main function of executing the DHAC-LOC algorithm
Application/DHAC-LOC instproc executeDHAC {} {

  global chan ns_ opt node_
  global cluster neighbor matrix CHsign

  $self instvar now__ alive_
  $self instvar closest_dis_ closest_id_ 
  $self instvar next_step_time_ next_adjust_time_ 
  $self instvar merge_times_

  # Check the alive status of the node.  If the node has run out of
  # energy, it no longer functions in the network.
  set ISalive [[[$self node] set netif_(0)] set alive_]
  if {$alive_ == 1} {
    if {$ISalive == 0} {
      puts "Node [$self nodeID] is DEAD!!!! Energy = [[$self getER] query]"
      $chan removeif [[$self node] set netif_(0)]
      set alive_ 0
      set opt(nn_) [expr $opt(nn_) - 1]
      set opt(nn_alive) [expr $opt(nn_alive) - 1]
    } else {
      pp "SETUP PHASE: Node [$self nodeID] is ALIVE!!!! Energy = [[$self getER] query]"
    }
  }
  if {$alive_ == 0} {return}
  
  set now__ [$ns_ now]
  set nodeID [$self nodeID]
  puts "$nodeID: *******************************************"
  puts "isClusterHead? [$self isClusterHead? $nodeID]\tcurrentCH is [$self getCurrentCH $nodeID]"
  puts "cluster is $cluster($nodeID)"
  puts "neighbor is $neighbor($nodeID)" 
  pp -file "matrix" "$opt(merge_steps)\t$nodeID\t$matrix($nodeID)"

  set clusterf [open $opt(dirname)/$opt(filename).cluster a]
  puts $clusterf "$opt(merge_steps)\t$nodeID\t$CHsign($nodeID)\t$cluster($nodeID)"
  close $clusterf
  puts "****************************************************"

  

  ##SETUP PHASE (2-1): execute DHAC-LOC algorithm
  if {$opt(merge_steps) < [expr [expr $opt(nn) -1] - $opt(num_clusters)] } { 

     set closest [FIND_CLOSEST_NEIGHBOR $nodeID]
     set closest_dis_ [lindex $closest 0]
     set closest_id_  [lindex $closest 1]
     pp -file "neighbor" "$opt(merge_steps)\t$nodeID\t[format %4f $closest_dis_]\t $closest_id_\t$neighbor($nodeID)"

     if {[$self isClusterHead? $nodeID]} { $self InvitePartner }

     set next_step_time_ [expr $now__ + [expr $opt(step_span) * $opt(nn_)]]
     $ns_ at $next_step_time_ "$self executeDHAC"
   
  }  else {
  ##SETUP PHASE (2-2): merge minimum size cluster
     set ifmergeMinimumCluster 0
     for {set id 0} {$id < [expr $opt(nn) -1] } {incr id} {
        if {[$self isClusterHead? $id] \
	    && [llength $cluster($id)] < $opt(minimum_cluster_size)} {
	    set ifmergeMinimumCluster  1
        }
     }
     if { $ifmergeMinimumCluster } {

       if {[$self isClusterHead? $nodeID]} { $self mergeMinimumCluster }

       set next_adjust_time_ [expr $now__ + $opt(step_span) * $opt(nn_)] 
       $ns_ at $next_adjust_time_ "$self executeDHAC"
 
     } else {
   ## Change to STEADY PHASE
       $self WakeUp
       $self checkAlive
       $ns_ at [expr $now__ + 0.000001] "$self ClusterMaintain"
     }
  }   
}
############################################################################


############################################################################
# * 3 * SETUP PHASE: execute DHAC-LOC algorithm
############################################################################
#===========================================================================
###### SEARCH the neighbor with SMALLEST COEFFICIENT and send INVITE message
Application/DHAC-LOC instproc InvitePartner {} {
  global chan ns_ opt node_

  $self instvar now__ 
  $self instvar closest_dis_ closest_id_

  set nodeID [$self nodeID]
  if {$closest_id_ != -2 && $nodeID < $closest_id_} {  
     #Calculate the distance between two nodes
     set distance [expr [nodeDist $nodeID $closest_id_] * 2]
     if {$distance > $opt(max_dist)} { set distance $opt(max_dist)}

     ##Send message closest_dis_ meters so the closest neighbor nodes can hear.
     set random_access [$self getRandomNumber 0 [expr $opt(ra_invite)*$opt(nn_)]]
     $ns_ at [expr $now__ + $random_access] "$self sendINVITE $distance"
  }
}

#===========================================================================
##### send out the INVITE message to the closest node
Application/DHAC-LOC instproc sendINVITE {distance} {
  global chan ns_ opt node_
  global INVITE MAC_BROADCAST LINK_BROADCAST BYTES_ID
  global cluster neighbor

  $self instvar code_ 
  $self instvar closest_dis_ closest_id_
  
  set chID [$self nodeID]
  set closestneighbor [list $closest_dis_ $closest_id_]
  set mac_dst $MAC_BROADCAST
  set link_dst $chID
  set msg [list [list $chID $closestneighbor $neighbor($chID)]]
  set datasize [expr $BYTES_ID * [join [llength $msg]]]

  $self send $mac_dst $link_dst $INVITE $msg $datasize $distance $code_
  pp -file "msg" "$opt(merge_steps)\t[$ns_ now]\tsendINVITE\t[$self getCurrentCH $chID]\t$closest_id_\t$INVITE\t$msg\t$datasize\t$distance\t$mac_dst\t$link_dst"
}

#====================================================================
##### recieved INVITE message from other node
Application/DHAC-LOC instproc recvINVITE {msg sender} {

  global ns_
  
  $self instvar closest_id_
  
  set nodeID [$self nodeID]
  if {$sender == $closest_id_} { 
     $self ComfirmInvitation "yes" $nodeID $sender
  } else { 
     $self ComfirmInvitation "no"  $nodeID $sender
  }

}
#===========================================================================
###### Choose appropriate CH and send CONFIRM message
Application/DHAC-LOC instproc ComfirmInvitation {isCorresponding INVITEreceiver INVITEsender} {
  global chan ns_ opt node_ bs
  global neighbor distancetoBS

  set nodeID [$self nodeID]

  if {$isCorresponding == "yes"} {
     if {$opt(ch_method) == "DisToBS"} {
        set distancetoBS($INVITEreceiver) [nodeToBSDist $INVITEreceiver $bs]
        set distancetoBS($INVITEsender)   [nodeToBSDist $INVITEsender $bs]
     }
     set mergeparts [CH_CHOSEN_METHOD $INVITEreceiver $INVITEsender $opt(ch_method)]
     set mergePart1 [lindex $mergeparts 0]
     set mergePart2 [lindex $mergeparts 1]
     
     incr opt(merge_steps) ;#count down cluster number
     set opt(nn_) [expr $opt(nn_) - 1] ;#set nn_ as number of CH
     
     set mergef [open $opt(dirname)/$opt(filename).merge a]
     puts $mergef "$nodeID\t$opt(merge_steps)\tmergePart1 $mergePart1\tmergePart2 $mergePart2\tnn_ $opt(nn_)"
     close $mergef
     
     #the INVITEsender is the matched merge partner
     $self unsetClusterHead $mergePart2 $mergePart1

     UPDATE_MATRIX $mergePart1 $mergePart2 $mergePart1
     UPDATE_MATRIX $mergePart1 $mergePart2 $mergePart2
     for {set idnei 0} {$idnei <[llength $neighbor($mergePart1)]} {incr idnei} {
        set neighbor_ [lindex $neighbor($mergePart1) $idnei]
        UPDATE_MATRIX $mergePart1 $mergePart2 $neighbor_
     }
     
     #remove computation energy
     pp "Node $nodeID perform Resemblance Matrix update."
     set num_sigs [llength $neighbor($mergePart1)]
     set compute_energy [bf $opt(hdr_size) $num_sigs]
     [$self getER] remove $compute_energy
     
     #send opt(max_dist) meters so all nodes can hear.
     set distance $opt(max_dist)

  } else {
     set mergePart1 "NA"
     set mergePart2 "NA"
     #the INVITEsender is not the matched merge partner 
     #send beacon the distance between two nodes
     set distance [expr [nodeDist $INVITEsender $INVITEreceiver] *2]
     if {$distance > $opt(max_dist)} { set distance $opt(max_dist)}
  }
  
  ##Send/Broadcast CONFIRM message back.
  set random_access [$self getRandomNumber 0 [expr $opt(ra_confirm)*$opt(nn_)]]
  $ns_ at [expr [$ns_ now] + $opt(ra_invite) + $random_access] "$self sendCONFIRM $INVITEsender $mergePart1 $mergePart2 $distance"
}

#===========================================================================
##### send/broadcast the CONFIRM message
Application/DHAC-LOC instproc sendCONFIRM {INVITEsender mergePart1 mergePart2 distance} {
  global chan ns_ opt node_
  global POSITIVE_CONFIRM NEGATIVE_CONFIRM MAC_BROADCAST LINK_BROADCAST BYTES_ID
  global cluster neighbor updateData

  $self instvar code_ 
  
  set chID [$self nodeID]
  set mergeparts [list $mergePart1 $mergePart2]
  set mac_dst $MAC_BROADCAST
  set link_dst $chID

  if {$mergePart1 != "NA"} {
     set msg [list [list $chID $INVITEsender $mergeparts]]
  } else { 
     set msg [list [list $chID $INVITEsender $mergeparts]]
  }
  set datasize [expr [expr $BYTES_ID * [join [llength $msg]]] + $opt(hdr_size)]
  
  if {$mergePart1 != "NA"} {
     $self send $mac_dst $link_dst $POSITIVE_CONFIRM $msg $datasize $distance $code_
     if {$chID == $mergePart2} { 
	$self GoToSleep
     }
     set CONFIRM $POSITIVE_CONFIRM
     set reciever $neighbor($chID)
  } else {
     $self send $mac_dst $link_dst $NEGATIVE_CONFIRM $msg $datasize $distance $code_
     set CONFIRM $NEGATIVE_CONFIRM
     set reciever $INVITEsender
  }
  pp -file "msg" "$opt(merge_steps)\t[$ns_ now]\tsendCONFIRM\t$chID\t$reciever\t$CONFIRM\t$msg\t$datasize\t$distance\t$mac_dst\t$link_dst"
}

#====================================================================
##### received the the POSITIVE CONFIRM message from closest node
Application/DHAC-LOC instproc recvPOSITIVECONFIRM {msg} {
  global ns_ opt


  set nodeID [$self nodeID]
  
  set mergePart1 [lindex [lindex $msg 2] 0]
  set mergePart2 [lindex [lindex $msg 2] 1]
  if {$nodeID == $mergePart1} {
     $self setClusterHead $mergePart1
  } elseif {$nodeID == $mergePart2} {
     $self unsetClusterHead $mergePart2 $mergePart1
     $self GoToSleep
  }

}

#====================================================================
##### received the the NEGATIVE CONFIRM message from closest node
Application/DHAC-LOC instproc recvNEGATIVECONFIRM {msg} {
  #do nothing about it
}

############################################################################


############################################################################
# * 4 * SETUP PHASE: merger minimum size cluster
############################################################################
#===========================================================================
# Merge small cluster into chose cluster
Application/DHAC-LOC instproc mergeMinimumCluster {} {

  global ns_ opt bs cluster 
 
  $self instvar now__ chose_cluster_

  set nodeID [$self nodeID]

  if {[llength $cluster($nodeID)] < $opt(minimum_cluster_size) } {
     
     set chose_cluster_ [CHOSE_MERGE_CLUSTER $nodeID]
     set distance [expr [nodeDist $nodeID $chose_cluster_] * 2]
     if {$distance > $opt(max_dist)} { set distance $opt(max_dist)}
     ##Send message so the chose neighbor cluster can hear.
     set random_access [$self getRandomNumber 0 [expr $opt(ra_invite)*$opt(nn_)]]
     $ns_ at [expr $now__ + $random_access] "$self sendMERGE_REQ $distance"
  }
}

#===========================================================================
##### send out the MERGE_REQ message to the chose cluster
Application/DHAC-LOC instproc sendMERGE_REQ {distance} {
  global chan ns_ opt node_
  global MERGE_REQ MAC_BROADCAST LINK_BROADCAST BYTES_ID
  global cluster neighbor

  $self instvar code_ chose_cluster_ merge_times_
  
  set chID [$self nodeID]
  set mac_dst $MAC_BROADCAST
  set link_dst $chID
  set msg [list [list $chID $chose_cluster_ $neighbor($chID)]]
  set datasize [expr $BYTES_ID * [join [llength $msg]]]

  $self send $mac_dst $link_dst $MERGE_REQ $msg $datasize $distance $code_
  pp -file "msg" "$merge_times_\t[$ns_ now]\tsendMERGE_REQ\t[$self getCurrentCH $chID]\
                  \t$chose_cluster_\t$MERGE_REQ\t$msg\t$datasize\t$distance\t$mac_dst\t$link_dst"
}

#====================================================================
##### received the MERGE_REQ message from minimum size cluster
Application/DHAC-LOC instproc recvMERGE_REQ {msg sender} {
  global ns_ cluster

  set nodeID [$self nodeID]
  if {[$self isClusterHead? $nodeID] &&[llength $cluster($sender)] != 0 } { 
     $self ComfirmInvitation "yes" $nodeID $sender
  }
}
############################################################################




############################################################################
# * 5 * STEADY PHASE: Assign tramission schedule/Aggregate data/Send data to BS
############################################################################

##### The main function of cluster maintainance
Application/DHAC-LOC instproc ClusterMaintain {} {

  global chan ns_ opt node_

  $self instvar now_ next_change_time_
  
  set nodeID [$self nodeID]
  set next_change_time_ [expr $now_ + $opt(ch_change)]

  if {[$self isClusterHead? $nodeID]} { $self createSchedule }

  $ns_ at $next_change_time_ "$self StartBackupCH"

}

############################################################################



############################################################################
# * 6 * STEADY PHASE: setup the transmission schedule within cluster
############################################################################
#===========================================================================
##### broadcast the TDMA slot schedule to cluster members
Application/DHAC-LOC instproc createSchedule {} {

  global ns_ opt cluster bs
 
  $self instvar now_ now__ dist_ TDMAschedule_ beginningE_

  set now__ [$ns_ now]
  set nodeID [$self nodeID]

  # Set the TDMA schedule 
  set TDMAschedule_ $cluster($nodeID)

  #send it to all nodes in the cluster.
  set dist_ [FIND_FARTHEST_MEMBER $TDMAschedule_]
  # Send message so the chose neighbor member can hear.
  set schedule_broadcast [expr $opt(ra_shedule) * $nodeID] 
  $ns_ at [expr $now__ + $schedule_broadcast] "$self sendSCHEDULE $dist_"

  #print out the TDMA schedule
  set outf [open $opt(dirname)/TDMAschedule.$now_\.txt a]
  puts $outf "$nodeID\t[lrange $TDMAschedule_ 1 end]"
  close $outf

}

#===========================================================================
##### broadcast the SCHEDULE message
Application/DHAC-LOC instproc sendSCHEDULE {distance} {
  global ns_ opt node_
  global SCH_BROADCAST MAC_BROADCAST LINK_BROADCAST BYTES_ID

  $self instvar code_ beginningE_ TDMAschedule_
  
  set chID [$self nodeID]

  set mac_dst $MAC_BROADCAST
  set link_dst $chID
  set msg [list $TDMAschedule_]
  set datasize [expr $BYTES_ID * [llength [join $TDMAschedule_]]]

  $self send $mac_dst $link_dst $SCH_BROADCAST $msg $datasize $distance $code_
  pp -file "msg" "NA\t[$ns_ now]\tsendSCHEDULE\t$chID\tNA\t$SCH_BROADCAST\t$msg\
                  \t$datasize\t$distance\t$mac_dst\t$link_dst"

  $self setCode $chID
		  
  set outf [open $opt(dirname)/$opt(filename).startup a]
  puts $outf "[$ns_ now]\t$chID\t[expr $beginningE_ - [[$self getER] query]] "
  close $outf

  set beginningE_ [[$self getER] query]

}

#====================================================================
##### received the SCHEDULE message from CHs
Application/DHAC-LOC instproc recvSCHEDULE {order sender} {
  global ns_ opt

  $self instvar dist_
  $self instvar beginningE_ TDMAschedule_
  
  set nodeID [$self nodeID]

  $self setCode $sender
  $self ChangeCH $nodeID $sender
  set dist_ [nodeDist $nodeID $sender]
  set TDMAschedule_ [join $order]

  set outf [open $opt(dirname)/$opt(filename).startup a]
  puts $outf "[$ns_ now]\t$nodeID\t[expr $beginningE_ - [[$self getER] query]]"
  close $outf
  
  set beginningE_ [[$self getER] query]

  $self collectionDATA $order
}

############################################################################


############################################################################
# * 7 * STEADY PHASE: change CH to the backup CH
############################################################################
#===========================================================================
# Control the CH rotate
Application/DHAC-LOC instproc StartBackupCH {} {
  global chan ns_ opt node_ cluster isChanged

  $self instvar alive_ now_ dist_ TDMAschedule_ 
  $self instvar beginningE_ next_change_time_
  $self instvar ch_energy_level_
  
  $self WakeUp

  set now_ [$ns_ now]
  set nodeID [$self nodeID]

  set outf [open $opt(dirname)/$opt(filename).maintain a]
  puts $outf "[$ns_ now]\t$nodeID\t[expr $beginningE_ - [[$self getER] query]]"
  close $outf
  set beginningE_ [[$self getER] query]

  set currentCH [$self getCurrentCH $nodeID]
  set TDMAschedule_ $cluster($currentCH)
  
  #rotate the CH to backup CH
  if {$alive_ && [llength $TDMAschedule_] > 1} {
     set ch_energy_level_ [$self CHECK_ENERGY_LEVEL $currentCH]

     if {$ch_energy_level_ || $isChanged($currentCH)} {
       $self ReAssign $currentCH $nodeID
     } else {
       $self AutoChange $currentCH $nodeID
     }

  } elseif {$alive_} {

     $self setClusterHead $nodeID 
     $ns_ at [expr $now_ + 0.001] "$self SendMyDataToBS $nodeID"
    
     # Set the TDMA schedule
     set outf [open $opt(dirname)/TDMAschedule.$now_\.txt a]
     puts $outf "$nodeID\t[lrange $TDMAschedule_ 1 end]"
     close $outf
  }  
}

#===========================================================================
# reassign the schedule
Application/DHAC-LOC instproc ReAssign {currentCH nodeID} {
  global chan ns_ opt node_ cluster

  $self instvar now_ TDMAschedule_

  #choose an appropriate member to be New CH
  set TDMAschedule_ [RESORT_SCHEDULE "ResidualEnergy" $currentCH [list $TDMAschedule_]]
  set backup [lindex $TDMAschedule_ 0]

  if {$nodeID == $backup} {
    pp -file "temp" "$nodeID into rescheduling at [$ns_ now]"
    $self setClusterHead $nodeID 
    set cluster($nodeID) $TDMAschedule_
  } elseif {$nodeID == $currentCH} { 
    $self unsetClusterHead $nodeID $backup
  } else {
    $self ChangeCH $nodeID $backup
    set cluster($nodeID) [list]
  }
  
  $ns_ at [expr $now_ + 0.000001] "$self ClusterMaintain"

}

#===========================================================================
# automatic change the CH
Application/DHAC-LOC instproc AutoChange {currentCH nodeID} {
  global chan ns_ opt node_ cluster

  $self instvar now_ dist_ TDMAschedule_ 
  $self instvar next_change_time_

  if {$currentCH == [lindex $TDMAschedule_ 0]} {
    set backup [lindex $TDMAschedule_ 1]
    set TDMAschedule_ [lrange $TDMAschedule_ 1 end]
    lappend TDMAschedule_ $currentCH
  } else {
    set backup [lindex $TDMAschedule_ 0]
  }

  if {$nodeID == $backup} {
    pp -file "temp" "$nodeID into autoCHchange at [$ns_ now]"
    $self setClusterHead $nodeID 
    set cluster($nodeID) $TDMAschedule_
     
    set dist_ [FIND_FARTHEST_MEMBER $TDMAschedule_]

    # Set the TDMA schedule
    set outf [open $opt(dirname)/TDMAschedule.$now_\.txt a]
    puts $outf "$nodeID\t[lrange $TDMAschedule_ 1 end]"
    close $outf

  } else {
    if {$nodeID == $currentCH} { 
      $self unsetClusterHead $nodeID $backup
    } else {
      $self ChangeCH $nodeID $backup
      set cluster($nodeID) [list]
    }

    set dist_ [nodeDist $nodeID $backup]
    $ns_ at [expr $now_ + 0.001] "$self collectionDATA [list $TDMAschedule_]"
  }
  set next_change_time_ [expr $now_ + $opt(ch_change)]
  $ns_ at $next_change_time_ "$self StartBackupCH"

}


#===================================================================
#Check the energy level of CH node
Application/DHAC-LOC instproc CHECK_ENERGY_LEVEL {currentCH} {

   global opt nodeEnergy cluster

   set energy_level_ 0
   set energy_ [lindex $nodeEnergy($currentCH) 2]

   for {set idmem 0} {$idmem < [llength $cluster($currentCH)]} {incr idmem} {
       set member_ [lindex $cluster($currentCH) $idmem]
       set energy_level_ [expr $energy_level_ + [lindex $nodeEnergy($member_) 2]]
   }
   set average_energy [expr $energy_level_/[llength $cluster($currentCH)]]
    
   if {$energy_ >= [expr $average_energy * $opt(energy_level)]} { 
      set lower_energy 0
   } else {
      set lower_energy 1
   }
   return $lower_energy
}


############################################################################



############################################################################
# * 8 * STEADY PHASE: collect and send data to CH/BS within the assigned time slot
############################################################################
#====================================================================
##### send data to the corresponding CH
Application/DHAC-LOC instproc collectionDATA {order} {
  global ns_ opt node_ isChanged

  $self instvar alive_ xmitTime_ frame_time_ end_frm_time_
  $self instvar next_change_time_

  $self GoToSleep

  set nodeID [$self nodeID]
  set isChanged([$self getCurrentCH $nodeID]) 0 

  set timeSlot [expr [lsearch [join $order] $nodeID] - 1]
  if {$timeSlot >= 0} {
  # Determine time for a single TDMA frame.  Each node sends data once 
  # per frame in the specified slot.
  set frame_time_   [expr [expr 5 + [llength [join $order]]] * $opt(ss_slot_time)]
  if {$frame_time_ < $opt(frame_time)} {set frame_time_ $opt(frame_time)}
  set xmitTime_     [expr $opt(ss_slot_time) * $timeSlot]
  set end_frm_time_ [expr $frame_time_ - $xmitTime_]
  set xmitat        [expr [$ns_ now] + $xmitTime_]

  pp "$nodeID scheduled to transmit at $xmitat. It is now [$ns_ now]."
  if {$alive_ && [expr $xmitat + $end_frm_time_] < \
      [expr $next_change_time_ - 10 * $opt(ss_slot_time)]} {
     $ns_ at $xmitat "$self sendDATA"
  }
  }
}
#===========================================================================
##### cluster members send data to CHs
Application/DHAC-LOC instproc sendDATA {} {

  global ns_ opt DATA MAC_BROADCAST BYTES_ID

  $self instvar dist_ code_ alive_
  $self instvar frame_time_ end_frm_time_
  $self instvar next_change_time_ 

  set nodeID [$self nodeID]
  set msg [list [list $nodeID , [$ns_ now] [[$self getER] query]]]
  # Use DS-SS to send data messages to avoid inter-cluster interference.
  set datasize [expr $opt(num_clusters) * \
               [expr [expr $BYTES_ID * [llength $msg]] + $opt(sig_size)]]


  $self WakeUp
  set mac_dst $MAC_BROADCAST
  set link_dst [$self getCurrentCH $nodeID]
  $self send $mac_dst $link_dst $DATA $msg $datasize $dist_ $code_
  pp -file "msg" "NA\t[$ns_ now]\tsendDATA\t$nodeID\tNA\t$DATA\t$msg\t$datasize\t$dist_\t$mac_dst\t$link_dst"

  # Must transmit data again during slot in next TDMA frame.
  set xmitat [expr [$ns_ now] + $frame_time_]
  if {$alive_ && [expr $xmitat + $end_frm_time_] < \
                 [expr $next_change_time_ - 10 * $opt(ss_slot_time)]} {
    $ns_ at $xmitat "$self sendDATA"
  }

  # remove the sensing energy
  set sense_energy [expr $opt(Esense) * $opt(sig_size) * 8]
  pp "Node $nodeID removing sensing energy = $sense_energy J."
  [$self getER] remove $sense_energy

  $self GoToSleep

}

#====================================================================
##### CHs received data from their cluster members
Application/DHAC-LOC instproc recvDATA {msg} {

  global ns_ opt cluster totalDATA nodeEnergy

  $self instvar alive_ TDMAschedule_ receivedFrom_ dataReceived_ 

  set chID [$self nodeID]
  set nodeID [lindex $msg 0]
  set receivedFrom_ [lappend receivedFrom_ $nodeID]
  set nodeEnergy($nodeID) [list $chID $nodeID [lindex $msg end]]

  set last_node [expr [llength $cluster($chID)] - 1]
  if {$chID == [lindex $cluster($chID) $last_node]} {
    set last_node [expr $last_node - 1]
  }

  if {$alive_ && $nodeID == [lindex $cluster($chID) $last_node]} {
    for {set id 0} {$id <[llength $cluster($chID)]} {incr id} {
       set member_ [lindex $cluster($chID) $id]
       incr totalDATA($member_)
    }
    # After an entire frame of data has been received, the cluster-head
    # must perform data aggregation functions and transmit the aggregate
    # signal to the base station.
    set num_sigs [llength $cluster($chID)]
    set compute_energy [bf $opt(sig_size) $num_sigs]
    pp "\tcompute_energy = $compute_energy"
    [$self getER] remove $compute_energy
    set receivedFrom_ [lappend receivedFrom_ $chID]
    set dataReceived_ $receivedFrom_
    set receivedFrom_ ""

    pp -file "msg" "NA\t[$ns_ now]\tBSDATA\t$nodeID\t$chID\t6\t$msg\tNA\tNA\tNA\t$chID"
    $self SendDataToBS

    # remove the sensing energy
    set sense_energy [expr $opt(Esense) * $opt(sig_size) * 8]
    pp "Node $nodeID removing sensing energy = $sense_energy J."
    [$self getER] remove $sense_energy
  }

}

#====================================================================
##### CHs send aggregated data to BS
Application/DHAC-LOC instproc SendDataToBS {} {

  global ns_ opt bs MAC_BROADCAST DATA BYTES_ID nodeEnergy

  $self instvar rng_ 

  # Data must be sent directly to the basestation.
  set nodeID [$self nodeID]
  set msg [list [list [list $nodeID , [$ns_ now]]]]
  # Use DS-SS to send data messages to avoid inter-cluster interference.
  set datasize [expr $opt(num_clusters) * \
               [expr $BYTES_ID * [llength $msg] + $opt(sig_size)]]

  set dist [nodeToBSDist [$self node] $bs] 

  set mac_dst $MAC_BROADCAST
  set link_dst $opt(bsID)
  set random_delay [expr [$ns_ now] + [$rng_ uniform 0 0.01]]
  $ns_ at $random_delay "$self send $mac_dst $link_dst $DATA \
                         $msg $datasize $dist $opt(bsCode)"
 
  set nodeEnergy($nodeID) [list $nodeID $nodeID [[$self getER] query]]

}


#====================================================================
##### CHs without member send its own data to BS
Application/DHAC-LOC instproc SendMyDataToBS {nodeID} {
      global ns_ opt totalDATA nodeEnergy

      $self instvar next_change_time_ alive_

      puts "Data being sent to the Base Station"
      $self SendDataToBS
      puts "Data was sent to the base station"
      set xmitat [expr [$ns_ now] + $opt(frame_time)]
      if {$alive_ && [expr $xmitat + $opt(frame_time)] < \
                 [expr $next_change_time_ - $opt(frame_time)]} {
        $ns_ at $xmitat "$self SendMyDataToBS $nodeID"
      } 
      incr totalDATA($nodeID)
      set nodeEnergy($nodeID) [list $nodeID $nodeID [[$self getER] query]]

}
############################################################################



############################################################################
# Receiving Functions
############################################################################
Application/DHAC-LOC instproc recv {args} {

  global ns_ opt
  global HELLO INVITE 
  global POSITIVE_CONFIRM NEGATIVE_CONFIRM 
  global MERGE_REQ SCH_BROADCAST DATA

  $self instvar alive_ merge_times_

  set nodeID    [$self nodeID]
  set msg_type  [[$self agent] set packetMsg_]

  set chID      [lindex $args 0]
  set sender    [lindex $args 1]
  set data_size [lindex $args 2]
  set msg       [lrange $args 3 end]

  switch $msg_type {
     0 {;#HELLO
         $self recvHELLO $msg
         pp -file "msg" "NA\t[$ns_ now]\trecvHELLO\t$sender\
                         \t$nodeID\t$msg_type\t$msg\t$data_size\tNA\tNA\t$chID"
     }
     2 { ;#INVITE
       if {$nodeID == [lindex [lindex $msg 1] 1] && [$self isClusterHead? $nodeID]} {
         $self recvINVITE $msg $sender
         pp -file "msg" "$opt(merge_steps)\t[$ns_ now]\trecvINVITE\t$sender\
	                 \t$nodeID\t$msg_type\t$msg\t$data_size\tNA\tNA\t$chID"
       }
     }
     3 { ;#DATA
       if {$alive_ && $nodeID == $chID} {
         $self recvDATA $msg
         pp -file "msg" "NA\t[$ns_ now]\trecvDATA\t$sender\
	                 \t$nodeID\t$msg_type\t$msg\t$data_size\tNA\tNA\t$chID"
       }
     }
     4 { ;#POSITIVE_CONFIRM
       if {[lsearch [lindex $msg 3] $nodeID] != -1} {
         $self recvPOSITIVECONFIRM $msg
         pp -file "msg" "$opt(merge_steps)\t[$ns_ now]\trecvPOSITIVECONFIRM\t$sender\
	                 \t$nodeID\t$msg_type\t$msg\t$data_size\tNA\tNA\t$chID"
       }
     }
     5 { ;#NEGATIVE_CONFIRM
       if {$nodeID == [lindex $msg 1] } {
         $self recvNEGATIVECONFIRM $msg
         pp -file "msg" "$opt(merge_steps)\t[$ns_ now]\trecvNEGATIVECONFIRM\t$sender\
	                 \t$nodeID\t$msg_type\t$msg\t$data_size\tNA\tNA\t$chID"
       }
     }
     6 { ;#MERGE_REQ
       if {$nodeID == [lindex $msg 1]} {
         $self recvMERGE_REQ $msg $sender
         pp -file "msg" "$merge_times_\t[$ns_ now]\trecvMERGE_REQ\t$sender\
	                 \t$nodeID\t$msg_type\t$msg\t$data_size\tNA\tNA\t$chID"
       }
     }
     7 { ;#SCH_BROADCAST
       if {$alive_ && [lsearch $msg $nodeID] != -1} {
         $self recvSCHEDULE $msg $sender
         pp -file "msg" "NA\t[$ns_ now]\trecvSCHEDULE\t$sender\
                         \t$nodeID\t$msg_type\t$msg\t$data_size\tNA\tNA\t$chID"
       }
     }
  };#end of switch
}
############################################################################



############################################################################
# Sending Functions
############################################################################
Application/DHAC-LOC instproc send {mac_dst link_dst type msg
                                      data_size dist code} {
  global ns_
  $self instvar rng_

  #set random_delay [expr 0.005 + [$rng_ uniform 0 0.005]]
  #$ns_ at [expr [$ns_ now] + $random_delay] "$self send_now $mac_dst \
  #  $link_dst $type $msg $data_size $dist"
  $ns_ at [$ns_ now]  "$self send_now $mac_dst \
      $link_dst $type $msg $data_size $dist $code"
}

Application/DHAC-LOC instproc send_now {mac_dst link_dst type msg \
                                          data_size dist code} {
    [$self agent] set packetMsg_ $type
    [$self agent] set dst_ $mac_dst
    [$self agent] sendmsg $data_size $msg $mac_dst $link_dst $dist $code
}
############################################################################


############################################################################
# Helper Functions
############################################################################

Application/DHAC-LOC instproc getRandomNumber {llim ulim} {
  $self instvar rng_
  return [$rng_ uniform $llim $ulim]
}

Application/DHAC-LOC instproc node {} {
  return [[$self agent] set node_]
}

Application/DHAC-LOC instproc nodeID {} {
  return [[$self node] id]
}

Application/DHAC-LOC instproc mac {} {
  return [[$self node] set mac_(0)]
}

Application/DHAC-LOC instproc getX {} {
  return [[$self node] set X_]
}

Application/DHAC-LOC instproc getY {} {
  return [[$self node] set Y_]
}

Application/DHAC-LOC instproc getER {} {
  set er [[$self node] getER]
  return $er
}

Application/DHAC-LOC instproc setCode code {
  $self instvar code_
  set code_ $code
  [$self mac] set code_ $code
}

Application/DHAC-LOC instproc GoToSleep {} {
  global opt ns_
  $self instvar begin_idle_ begin_sleep_

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

Application/DHAC-LOC instproc WakeUp {} {
  global opt ns_
  $self instvar begin_idle_ begin_sleep_

  [[$self node] set netif_(0)] set sleep_ 0
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




#===========================================================================
##### check node status and decide the simulation ending
Application/DHAC-LOC instproc checkAlive {} {

  global ns_ chan opt node_ cluster isChanged totalDATA

  $self instvar alive_ begin_idle_ begin_sleep_

  # Check the alive status of the node.  If the node has run out of
  # energy, it no longer functions in the network.
  set nodeID [$self nodeID]
  set ISalive [[[$self node] set netif_(0)] set alive_]
  if {$alive_ == 1} {
    if {$ISalive == 0} {
      puts "Node [$self nodeID] is DEAD!!!! Energy = [[$self getER] query]"
      $chan removeif [[$self node] set netif_(0)]
      set alive_ 0
      set opt(nn_alive) [expr $opt(nn_alive) - 1]

      set currentCH [$self getCurrentCH $nodeID]
      set isChanged($currentCH) 1
      
      pp -file "temp" "[$ns_ now]\tbefore \t$nodeID\t remove $currentCH\t$cluster($currentCH)"
      set cluster($currentCH) [$self RemoveMember [list $cluster($currentCH)] $nodeID]
      pp -file "temp" "[$ns_ now]\tafter  \t$nodeID\t remove $currentCH\t$cluster($currentCH)"
      #output the current send out data number
      set total_data 0
      for {set id 0} {$id < [expr $opt(nn)-1]} {incr id} {
        set total_data [expr $total_data + $totalDATA($id)]
      }
      set dataf [open $opt(dirname)/$opt(filename).datanode a]  
      puts $dataf "[$ns_ now]\t$total_data"
      close $dataf

    } else {
      $ns_ at [expr [$ns_ now] + 0.1] "$self checkAlive"
      if {$begin_idle_ >= $begin_sleep_} {
        set idle_energy [expr $opt(Pidle) * [expr [$ns_ now] - $begin_idle_]]
        [$self getER] remove $idle_energy
        set begin_idle_ [$ns_ now]
      } else {
        set sleep_energy [expr $opt(Psleep) * [expr [$ns_ now] - $begin_sleep_]]
        [$self getER] remove $sleep_energy
        set begin_sleep_ [$ns_ now]
      }
    }
  }
  if {$opt(nn_alive) < 1} "sens_finish"
} ;#end of checkAlive

############################################################################


############################################################################
# Cluster Head Functions
############################################################################

Application/DHAC-LOC instproc isClusterHead? {nodeID} {
  global CHsign

  return [lindex $CHsign($nodeID) 0]
}

Application/DHAC-LOC instproc getCurrentCH {nodeID} {
  global CHsign

  return [lindex $CHsign($nodeID) 1]
}

Application/DHAC-LOC instproc setClusterHead {nodeID} {
  global CHsign

  set CHsign($nodeID) [list 1 $nodeID]
}

Application/DHAC-LOC instproc unsetClusterHead {nodeID currentCH} {
  global CHsign

  set CHsign($nodeID) [list 0 $currentCH]

}

Application/DHAC-LOC instproc ChangeCH {nodeID currentCH} {
  global CHsign

  set CHsign($nodeID) [list 0 $currentCH]
}

Application/DHAC-LOC instproc RemoveMember {memberlist nodeID} {
  global CHsign cluster

  set memberlist [join $memberlist]

  if {[lsearch $memberlist $nodeID] != -1} {
    set removeNode_position [lsearch $memberlist $nodeID]
    if {$removeNode_position == [expr [llength $memberlist] - 1]} {
      set memberlist [lreplace $memberlist end end]
    } else {
      set memberlist [lreplace $memberlist \
          $removeNode_position end [lrange $memberlist \
          [expr $removeNode_position+1] end]]
      set memberlist [join $memberlist]
    }
  }
  return $memberlist
}


############################################################################





