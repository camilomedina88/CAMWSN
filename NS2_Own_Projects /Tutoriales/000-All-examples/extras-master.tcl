############################################################################
# ZCJ 2007 DHAC with extra functions
#    This code is based on the code of LEACH. (June, 2000)
#    Developed as part of the WSNs project at Carleton University
############################################################################


############################################################################
#
# Functions to calculate distances.
#
############################################################################

proc nodeDist {node1 node2} {
  global node_
  #zcj changed 
  return [dist [$node_($node1) set X_] [$node_($node1)  set Y_] [$node_($node2)  set X_] [$node_($node2)  set Y_]]
}

proc nodeToBSDist {node1 bs} {
  global node_
  return [dist [$node_($node1) set X_] [$node_($node1) set Y_] [lindex $bs 0] [lindex $bs 1]]
}

proc dist {x1 y1 x2 y2} {
  set d [expr sqrt([expr pow([expr $x1-$x2],2) + pow([expr $y1-$y2],2)])]
  return $d
}


############################################################################
#
# Computational energy dissipation model for beamforming num signals 
# of size bytes/signal.
#
############################################################################

proc bf {size num} {
  global opt

  set bits_size [expr $size * 8]
  set energy 0
  if {$num > 1} {
    set energy [expr $opt(e_bf) * $bits_size * $num];
  }
  return $energy
}

############################################################################
#
# Miscellaneous printing (output) functions.
#
############################################################################

proc nround {val digits} {
  global tcl_precision
  set old_tcl_precision $tcl_precision
  set tcl_precision $digits
  set newval [expr $val * 1]
  puts $newval
  set tcl_precision $old_tcl_precision
  return $newval
}

proc nroundf {file val digits} {
  global tcl_precision
  set old_tcl_precision $tcl_precision
  set tcl_precision $digits
  set newval [expr $val * 1]
  puts $file $newval
  set tcl_precision $old_tcl_precision
  return $newval
}

proc pputs {str val} {
  puts -nonewline $str
  nround $val 6
}

proc pp args {
  global opt

  set options [lindex $args 0]
  if {$opt(quiet) == 0} {
    if {$options == "-nonewline" } {
       puts -nonewline [lindex $args 1]
    } elseif {$options == "-file"} {
       set sens_file [open "$opt(dirname)/$opt(filename)\.[lindex $args 1]" a]
          puts $sens_file [lindex $args 2]
       close $sens_file
    } else {
       puts [lindex $args 0]
    }
  }
  return
}


############################################################################
# ZCJ added DHAC algorithm related Functions
############################################################################
proc BUILD_MATRIX {nodeID} {
  global opt node_
  global neighbor matrix

  if {$opt(rp) == "dhac-loc"} {
     set matrix($nodeID) [EUCLIDEAN_TABLE $nodeID $opt(trans_range) $opt(nn_)]
  } elseif {$opt(rp) == "dhac-rss"} {
  } else {
    ##build the ONE-HOP BINARY table
    for {set id 0} {$id < $opt(nn_)} {incr id 1} {
      if {$id == $nodeID} { 
         lappend BINARY($nodeID) 1
      } else {
         if { [lsearch $neighbor($nodeID) $id] == -1 } {
            lappend BINARY($nodeID) 0
         } else { lappend BINARY($nodeID) 1 }
      }
    }
  }
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
###### Calculate the node's Distance Table
##       Input:  nodeID
##		 transRange = transmission Radius
##		 nodeNumber = total node number
##       Output: neighborDistanceL = the table of Distance
proc EUCLIDEAN_TABLE {nodeID transRange nodeNumber} {
  upvar x x
  upvar y y
  upvar neighbor neighbor
  
  set neighborDistanceL [list]
  for {set i 0} {$i < $nodeNumber} {incr i 1} {
    if {$i == $nodeID } { 
       lappend neighborDistanceL 0
    } elseif {[lsearch $neighbor($nodeID) $i] != -1} {
       lappend neighborDistanceL [nodeDist $nodeID $i]
    } else {
       lappend neighborDistanceL -1
    }	   
  }
  return $neighborDistanceL
}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
proc FIND_CLOSEST_NEIGHBOR {nodeID} {
  global opt cluster neighbor matrix 

  set closest_dis -2
  set closest_id  -2
  set inter_ 0

  for {set idnei 0} {$idnei < [llength $neighbor($nodeID)]} {incr idnei 1} {
     set neigh_ [lindex $neighbor($nodeID) $idnei]
     set coeff_ [lindex $matrix($nodeID) $neigh_]
     if {[lindex $cluster($nodeID) 0] == $nodeID\
        && [lindex $matrix($nodeID) $neigh_] > 0} {
        if {$closest_dis == -2 || [lindex $matrix($nodeID) $neigh_] < $inter_} {
           set closest_dis [lindex $matrix($nodeID) $neigh_]
           set closest_id  $neigh_
  	   set inter_ $closest_dis
  	}
     }
  }
  set closest [list $closest_dis $closest_id]
  return $closest 
}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
###### Choose appropricate CH base on different parameters
#        Input : mergePart1
#                mergePart2
#		 CHMethod: ClusterSize / DisToBS
#        Output: mergeParts = dealed the mergeparts 
proc CH_CHOSEN_METHOD {mergePart1 mergePart2 CHMethod} {
     global cluster distancetoBS

     switch $CHMethod {
        ClusterSize {  ;# choose the Larger_size cluster as the Leader merge part
                    if {[llength $cluster($mergePart1)] < [llength $cluster($mergePart2)]} {
                       set swap_      $mergePart1 
		       set mergePart1 $mergePart2
                       set mergePart2 $swap_
                    }
        }
        DisToBS {  ;# choose the closer_to_BS cluster as the Leader merge part
         	set mergePart1toBS $distancetoBS($mergePart1)
		set mergePart2toBS $distancetoBS($mergePart2)
		if {$mergePart2toBS < $mergePart1toBS} {
                   set swap_      $mergePart1 
                   set mergePart1 $mergePart2
                   set mergePart2 $swap_
	        }
       }
    } 
    set mergeparts [list $mergePart1 $mergePart2]
    return $mergeparts
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
###### UPDATE Resemblance Matrix with DHAC algorithm method
#        Output:
#        change matrix table:   mergePart1 - updated mergePart1
#                               mergePart2 - reset mergePart2 with -1
#                               neighbors  - updated
#        change Neighbor table: mergePart1 - add mergePart2's neighbor
#                               mergePart2 - empty
#                               neighbors  - remove mergePart2, add mergePart1
proc UPDATE_MATRIX {mergePart1 mergePart2 updateNode} {
     global opt 
     global cluster neighbor matrix updateData

     if {$updateNode == $mergePart1} {

        #DEAL with mergePart2 ================================
        #STEP-1-: update neighbor
        PASS_NEIGHBOR $mergePart1 $mergePart2   ;#pass mergePart2's neighbor list to mergePart1
	REMOVE_NEIGHBOR $mergePart1 $mergePart2 ;#remove mergePart2 from neighbor list

	#STEP-2-: update matrix
        UPDATE_METHOD $mergePart1 $mergePart2
	#STEP-3-: update cluster
	lappend cluster($mergePart1) $cluster($mergePart2)
	set cluster($mergePart1) [join $cluster($mergePart1)]

     } elseif {$updateNode == $mergePart2} {
     
        #DEAL with mergePart2 ================================
	#STEP-1-: update neighbor
        set neighbor($mergePart2) [list]
	#STEP-2-: update matrix
	set matrix($mergePart2)   [list]
	#STEP-3-: update cluster
	set cluster($mergePart2)  [list]
	       
     } elseif {[lsearch $neighbor($mergePart1) $updateNode] != -1} {

	#STEP-1-: update neighbor
        ADD_NEIGHBOR    $updateNode $mergePart1
        REMOVE_NEIGHBOR $updateNode $mergePart2

	#STEP-2-: update matrix
	set position [lsearch $updateData($mergePart1) $updateNode]
	if { $position != -1 && [llength $matrix($updateNode)] != 0} {
	   set newDistance [lindex $updateData($mergePart1) [expr $position + 1]]
	   set matrix($updateNode) [lreplace $matrix($updateNode) $mergePart1 $mergePart1 $newDistance]
	   set matrix($updateNode) [lreplace $matrix($updateNode) $mergePart2 $mergePart2 -1]
        }
        #STEP-3-: update cluster
	#do nothing about it
     }
}

#===================================================================
#serve UPDATE_MATRIX to update matrix to aother neighbor list
# input: NodeID       = The node whose matrix need be dealed
#        mergePart1
#	 mergePart2
proc UPDATE_METHOD {mergePart1 mergePart2} {
     global opt node_ 
     global cluster neighbor matrix updateData

     #deal the mergePart2 in matrix($mergePart1)
     set updateData($mergePart1) [list $mergePart2 [lindex $matrix($mergePart1) $mergePart2]]
     set matrix($mergePart1) [lreplace $matrix($mergePart1) $mergePart2 $mergePart2 -1]
     #deal the neighbors in matrix($mergePart1)
     for {set idnei 0} {$idnei <[llength $neighbor($mergePart1)]} {incr idnei} {
        set neighbor_ [lindex $neighbor($mergePart1) $idnei]
	if {[llength $cluster($neighbor_)] != 0} {
           set distance1toNeighbor [lindex $matrix($mergePart1) $neighbor_]
           set distance2toNeighbor [lindex $matrix($mergePart2) $neighbor_]
           switch $opt(hac_method) {
             UPGMA { 	  
	       set totalnumber 0
   	       set newdistance 0
	       for {set m 0} {$m < [llength $cluster($neighbor_)]} {incr m 1} {
                  set clustermemberother [lindex $cluster($neighbor_) $m]
                  for {set n 0} {$n < [llength $cluster($mergePart1)]} {incr n 1} {
                     set clustermember1 [lindex $cluster($mergePart1) $n]
	             incr totalnumber 1
	  	     set distance_ [nodeDist $clustermemberother $clustermember1]
	             set newdistance [expr $newdistance + $distance_]
                  } 
	          for {set n 0} {$n < [llength $cluster($mergePart2)]} {incr n 1} {
                     set clustermember2 [lindex $cluster($mergePart2) $n]
	             incr totalnumber 1
	  	     set distance_ [nodeDist $clustermemberother $clustermember2]
	             set newdistance [expr $newdistance + $distance_]
	          } 
               }
	       set newdistance [expr $newdistance/$totalnumber]
             }
	     WPGMA  {
               set totaldistance_ 0
	       if {$distance1toNeighbor == -1} { ;#ESTIMATED
                  for {set m 0} {$m < [llength $cluster($mergePart1)]} {incr m 1} {
	             set clustermember1 [lindex $cluster($mergePart1) $m]
	 	     set distance_ [nodeDist $neighbor_ $clustermember1]
	             set totaldistance_ [expr $totaldistance_ + $distance_]
	          }
	          set distance1toNeighbor [expr $totaldistance_/[llength $cluster($mergePart1)]]
	       }	  
	       if {$distance2toNeighbor == -1} { ;#ESTIMATED
                  for {set m 0} {$m < [llength $cluster($mergePart2)]} {incr m 1} {
  	             set clustermember2 [lindex $cluster($mergePart2) $m]
		     set distance_ [nodeDist $neighbor_ $clustermember2]
	             set totaldistance_ [expr $totaldistance_ + $distance_]
	          }
	          set distance2toNeighbor [expr $totaldistance_/[llength $cluster($mergePart2)]]
               }	
               set newdistance [expr [expr $distance1toNeighbor+$distance2toNeighbor]/2] 
             }
  	     SLINK { 
	       if {$distance1toNeighbor == -1} { ;#ESTIMATED
                  for {set m 0} {$m < [llength $cluster($mergePart1)]} {incr m 1} {
	             set clustermember1 [lindex $cluster($mergePart1) $m]
	             set distance_ [nodeDist $neighbor_ $clustermember1]
	             if {$distance1toNeighbor == -1 || $distance_ < $distance1toNeighbor} {
	                set distance1toNeighbor $distance_
	             }
	          }
               }	
	       if {$distance2toNeighbor == -1} { ;#ESTIMATED
                  for {set m 0} {$m < [llength $cluster($mergePart2)]} {incr m 1} {
	             set clustermember2 [lindex $cluster($mergePart2) $m]
	             set distance_ [nodeDist $neighbor_ $clustermember2]
	             if {$distance2toNeighbor == -1 || $distance_ < $distance2toNeighbor} {
	                set distance2toNeighbor $distance_
	             }
	          }
               }	
	       if {$distance1toNeighbor <= $distance2toNeighbor} {
	          set newdistance $distance1toNeighbor 
               } else {set newdistance $distance2toNeighbor}
            }    
            CLINK { 
              if {$distance1toNeighbor == -1} { ;#ESTIMATED
                 for {set m 0} {$m < [llength $cluster($mergePart1)]} {incr m 1} {
                    set clustermember1 [lindex $cluster($mergePart1) $m]
                    set distance_ [nodeDist $neighbor_ $clustermember1]
                    if {$distance1toNeighbor == -1 || $distance_ > $distance1toNeighbor} {
                       set distance1toNeighbor $distance_
                    }
                 }
              }	
              if {$distance2toNeighbor == -1} { ;#ESTIMATED
                 for {set m 0} {$m < [llength $cluster($mergePart2)]} {incr m 1} {
                    set clustermember2 [lindex $cluster($mergePart2) $m]
                    set distance_ [nodeDist $neighbor_ $clustermember2]
                    if {$distance2toNeighbor == -1 || $distance_ > $distance2toNeighbor} {
                       set distance2toNeighbor $distance_
                    }
                 }
              }	
	      if {$distance1toNeighbor >= $distance2toNeighbor} {
	         set newdistance $distance1toNeighbor 
              } else { set newdistance $distance2toNeighbor }
            }
         }
      } else {set newdistance -1}
      ##update the matrix($mergePart1)
      set matrix($mergePart1) [lreplace $matrix($mergePart1) $neighbor_ $neighbor_ $newdistance]
      ##set the updateData table
      lappend updateData($mergePart1) $neighbor_ 
      lappend updateData($mergePart1) $newdistance
   };#end of the neighbor_
}


#===================================================================
#serve UPDATE_MATRIX to add a node into a nodes' neighbor list
# input: NodeID  = The node whose neighbor list need be dealed
#        addNode = the node which need be added
proc ADD_NEIGHBOR {NodeID addNode} {
     global neighbor
   
     if {[lsearch $neighbor($NodeID) $addNode] == -1} {
        lappend neighbor($NodeID) $addNode
        set neighbor($NodeID) [lsort -integer $neighbor($NodeID)]
     }
}

#===================================================================
#serve UPDATE_MATRIX to remove a node from other nodes' neighbor list
# input: NodeID     = The node whose neighbor list need be dealed
#        removeNode = the node which need be removed
proc REMOVE_NEIGHBOR {NodeID removeNode} {
     global neighbor
     
     if {[lsearch $neighbor($NodeID) $removeNode] != -1} {
        set removeNode_position [lsearch $neighbor($NodeID) $removeNode]
        if {$removeNode_position == [expr [llength $neighbor($NodeID)] - 1]} {
           set neighbor($NodeID) [lreplace $neighbor($NodeID) end end]
        } else {
          set neighbor($NodeID) [lreplace $neighbor($NodeID) \
                 $removeNode_position end [lrange $neighbor($NodeID) \
                 [expr $removeNode_position+1] end]]
          set neighbor($NodeID) [join $neighbor($NodeID)]
        }
     }
}

#===================================================================
#serve UPDATE_MATRIX to add a neighbor list to aother neighbor list
# input: receptor = The node whose neighbor list need be dealed
#        giver    = the node which need be removed
proc PASS_NEIGHBOR {receptor giver} {
     global neighbor
     
     for {set idnei 0} {$idnei < [llength $neighbor($giver)]} {incr idnei 1} {
        set neighbor_ [lindex $neighbor($giver) $idnei]
        if {$neighbor_ != $receptor \
         && $neighbor_ != -1 \
         && [lsearch $neighbor($receptor) $neighbor_] == -1} {
            lappend neighbor($receptor) $neighbor_
        }
     }
     set neighbor($receptor) [lsort -integer $neighbor($receptor)]
}

#===================================================================
#chose a cluster to merge small cluster
proc CHOSE_MERGE_CLUSTER {nodeID} {
     global opt bs cluster

     for {set ch_ 0} {$ch_ < [expr $opt(nn)-1]} {incr ch_ 1} {
	if {$ch_ != $nodeID && [llength $cluster($ch_)] != 0} {
	   switch $opt(merge_method) {
              closestCH {
                 set distance_ [nodeDist $nodeID $ch_]
                 lappend close_ch_ [list $ch_ $distance_]
	      }
              DisToBS {
                 if {[nodeToBSDist $id $bs] <= [nodeToBSDist $nodeID $bs]} {
 	            set distance_ [nodeDist $nodeID $ch_]
	            lappend close_ch_ [list $ch_ $distance_]
	         }
	      }
	   }
	}
     }
     set close_ch_ [lsort -real -index 1 $close_ch_]
     set ch_ [lindex [lindex $close_ch_ 0] 0]
     return $ch_      
}

#===================================================================
#calculate the maximum distance between CH and member within a cluster
proc FIND_FARTHEST_MEMBER {nodeID} {
     global cluster
     
     set distanceList [list]
     for {set idclu 0} {$idclu < [llength $cluster($nodeID)]} {incr idclu 1} {
        set member_ [lindex $cluster($nodeID) $idclu]
	if {$member_ != $nodeID} {
	   set distance_ [nodeDist $member_ $nodeID]
           lappend distanceList $distance_
	}
     }
     set distanceList [lsort -real $distanceList]
     set farthest [lindex $distanceList end]
     return $farthest
}



