#
### topomain.tcl
#   Configuration file for network topology and generate networks
#   invoke: topogenerator.tcl -random generate network topologies
#   input:  None
#   output: netList.txt
###################################################################################
#============================= PARAMETER CONFIGURATION ===========================#
###################################################################################
set nodeNumberL [list 175];# total node number
set nodeDegreeL [list 10];# Network degree
set netRangeL   [list 100];# Field Range of network area
set topoNumber 10 ;# Number of topologies with same configuration
###################################################################################
#================================ INITIALIZATION =================================#
###################################################################################
puts "\nGenerate Nework topologies"
puts -nonewline "Initialing......"
flush stdout
#catch "eval exec rm [glob -nocomplain networks/*.txt]"
#catch "eval exec rm [glob -nocomplain networks/*.in]"
puts "Done"
###################################################################################
#================================ NETWORK GENERATION =============================#
###################################################################################
###### Generate network:NODE NUMBER
for {set i 0} {$i < [llength $nodeNumberL]} {incr i 1} {
  set nodeNumber [lindex $nodeNumberL $i];# Node numeber
###### DEGREE
  for {set j 0} {$j < [llength $nodeDegreeL]} {incr j 1} {
    set nodeDegree [lindex $nodeDegreeL $j];# Networks degree
###### AREA RANGE
    for {set m 0} {$m < [llength $netRangeL]} {incr m 1} {
      set netRange [lindex $netRangeL $m] ;# Network area
###### Number of TOPOLOGIES    
      for {set topology 0} {$topology < $topoNumber} {incr topology 1} {  
          
	  set fileName [format %03d-%03d-%03d-%02d\
                       $nodeNumber $nodeDegree $netRange $topology]
###################################################################################
#================================= OUTPUT DOCUMENTS ==============================#
###################################################################################
          set inf [open "networks/netlist.txt" a]
	      puts -nonewline $inf "$fileName $nodeNumber \
	                      $nodeDegree $netRange $topology"
          close $inf
          # execute the topgenerator.tcl $filename $node_num $degree $range
          puts -nonewline "Network: $fileName......"
	  flush stdout
          exec tclsh topogenerator.tcl $fileName $nodeNumber $nodeDegree $netRange
	  puts "done"
      } 
    }	
  }
}
