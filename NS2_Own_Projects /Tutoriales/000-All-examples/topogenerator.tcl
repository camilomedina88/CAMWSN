# 
###### topogenerator.tcl
#      random generate nodes & calculate the transmission range
#      Input: 	Parameters from topomain.tcl
#      Output:	networks/*.in
#               networks/netlist.txt
###################################################################################
#============================= PROCEDURE DEFINATION ==============================#
###################################################################################
#
###### Random Generate network topologies
#        Input:  netRange   = network area limitation
#                nodeNumber = total node number
#        Output: x = nodes' x-coordinate
#	         y = nodes' y-coordinate
proc NODE_GENERATION {netRange nodeNumber} {
  upvar x x 
  upvar y y
  for {set i 0} {$i < $nodeNumber} {incr i 1} {
     set x($i) [expr rand() * $netRange]
     set y($i) [expr rand() * $netRange]
  }
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#
###### Clculate the distance between any two nodes
##       Input:  node1ID  node2ID
##       Output: distance between two nodes
proc NODE_DISTANCE {node1ID node2ID} {
  upvar x x
  upvar y y

  set x_distance_ [expr $x($node1ID) - $x($node2ID)]
  set y_distance_ [expr $y($node1ID) - $y($node2ID)]
  return [expr sqrt($x_distance_ * $x_distance_ + $y_distance_ * $y_distance_)]
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#
###### Calculate transmission range
#        Input:  nodeDegree = node degree 
#                nodeNumber = total node number
#        Output: transRange = transmission radius
proc TRANSMISSION_RANGE {nodeDegree nodeNumber} {
  upvar x x 
  upvar y y
# base on the degree to calculate the node Tranmission Radius
  for {set i 0} {$i < $nodeNumber} {incr i 1} {
       for {set j [expr $i+1]} {$j < $nodeNumber} {incr j 1} {
	 set dis_each_  [NODE_DISTANCE $i $j]
         lappend distance_ $dis_each_
       }
  }       
  set distance_ [lsort -real $distance_]
  set threshold_ [expr $nodeNumber*$nodeDegree/2-1]
  set transRange   [lindex $distance_ $threshold_]
  return $transRange
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
###### SEARCH ONE-HOP neighbor
##       Input:  nodeID
##		 transRange = transmission radius
##		 nodeNumber = total node number
##       Output: oneHopNeighbor =  the list of neighbor
proc NODE_FIND_ONEHOP_NEIGHBOR {nodeID transRange nodeNumber} {
  upvar x x
  upvar y y 
  
  set oneHopNeighbor [list]
  for {set i 0} {$i < $nodeNumber} {incr i 1} {
    if {$i != $nodeID && [NODE_DISTANCE $nodeID $i] <= $transRange} {
      lappend oneHopNeighbor $i
    }
  }
  return $oneHopNeighbor
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#
###### Check connectivity of the netwrok 
##       Input:  transRange = transmission radius
##		 nodeNumber = total node number
##       output: 0 - connected
##		 1 - disconnected 
proc NET_CONNECTIVITY_CHECK {transRange nodeNumber} {
  upvar x x
  upvar y y
  
  set start_node [expr int(rand()*$nodeNumber)]
  set connected_node [list $start_node]  
  set checking_ [NODE_FIND_ONEHOP_NEIGHBOR $start_node $transRange $nodeNumber]
  set checked_node $start_node
  lappend checked_node $checking_
  set checked_node [join $checked_node]

  while {[llength $checking_] != 0} {
     set future_checking [list]
     for {set i 0} {$i < [llength $checking_]} {incr i 1} {
        set checking_node [lindex $checking_ $i]
        if {[lsearch $connected_node $checking_node] == -1} {
           lappend connected_node $checking_node
	} 
        set next_round [NODE_FIND_ONEHOP_NEIGHBOR $checking_node $transRange $nodeNumber]
        for {set j 0} {$j < [llength $next_round]} {incr j 1} {    
           set next_round_node [lindex $next_round $j]
	   if {[lsearch $checked_node $next_round_node] == -1\
	    && [lsearch $future_checking $next_round_node] == -1 } {
	      lappend future_checking $next_round_node
	   }
	}
     }
     set checking_ $future_checking
     lappend checked_node $future_checking
     set checked_node [join $checked_node]
  }
         
# result of the connectivity: ture-0/ false-1
  set ret 0
  if {[llength $connected_node] < $nodeNumber} {
      set ret 1
  }  
  return $ret
}

###################################################################################
#=============================== INPUT parameters ================================#
###################################################################################
# Accept parameters from topomain.tcl
if {$argc != 4} {
  puts "tclsh node_gene.tcl <fileName> <nodeNumber> <nodeDegree> <netRange>"
  exit 0
}
set fileName     [lindex $argv 0]
set nodeNumber   [lindex $argv 1]
set nodeDegree   [lindex $argv 2]
set netRange     [lindex $argv 3]
###################################################################################
#================================= MAIN EXECUTION ================================#
###################################################################################
# Generate random nodes and check network connectivity
NODE_GENERATION $netRange $nodeNumber
set transRange 20
#set transRange [TRANSMISSION_RANGE $nodeDegree $nodeNumber]
while {[NET_CONNECTIVITY_CHECK $transRange $nodeNumber] != 0} {
  puts "not connected"
  NODE_GENERATION $netRange $nodeNumber
  #set transRange [TRANSMISSION_RANGE $nodeDegree $nodeNumber]
}
puts "connected"
###################################################################################
#================================ OUTPUT documents ===============================#
###################################################################################
#output nodes' x/y coordinate
set fout [open "networks/$fileName\.in" w]
for {set i 0} {$i < $nodeNumber} {incr i 1} {
   puts $fout "$i $x($i) $y($i)"
}
close $fout

#add new parameter into .txt file
set sumf [open "networks/netlist.txt" a]
puts $sumf " $transRange"
close $sumf
