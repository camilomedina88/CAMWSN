puts "Sourcing data setup script now"
puts "We currently think that there are $opt(nn) nodes in the net"

# This file will set up disjoint keys
# for a layout of num_nodes

set metadatatype KeyMetaData

# This is the global wants list
# We'll lengthen or shorten it, depending upon how many nodes
# are in the simulation.

set baselength 26
set baselist [list A B C D E F G H I J K L M N O P Q R S T U V W X Y Z]

if {$opt(nn) == $baselength} {
    
    set wantslist $baselist

} elseif {$opt(nn) < $baselength} {

    set wantslist [lreplace $baselist $opt(nn) end]

} else {

    set wantslist ""
    for {set i 1} {$i <= $opt(nn)} {incr i} {

	set block [expr $i / $baselength]
	set el [lindex $baselist [expr $i % $baselength]]
	
	set newel "$el$block"
	
	set wantslist [concat $wantslist $newel]
    }
}
	
puts "wantslist is now $wantslist"

proc find_haslist {id} {
    global wantslist opt

    set haslist ""
    
    for {set j 0} {$j < $opt(overlap)} {incr j} {

		set index [expr ($id + $j) % [llength $wantslist]]

		set haslist [concat $haslist [lindex $wantslist $index]]
    }

    return $haslist
}



