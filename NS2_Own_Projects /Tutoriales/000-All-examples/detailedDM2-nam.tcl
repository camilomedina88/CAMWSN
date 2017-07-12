 #
 # tcl/ex/newmcast/detailedDM2-nam.tcl
 #
 # Copyright (C) 1997 by USC/ISI
 # All rights reserved.                                            
 #                                                                
 # Redistribution and use in source and binary forms are permitted
 # provided that the above copyright notice and this paragraph are
 # duplicated in all such forms and that any documentation, advertising
 # materials, and other materials related to such distribution and use
 # acknowledge that the software was developed by the University of
 # Southern California, Information Sciences Institute.  The name of the
 # University may not be used to endorse or promote products derived from
 # this software without specific prior written permission.
 # 
 # THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
 # WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
 # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 # 
 #

proc nam_config {net} {
        $net node 0 circle
        $net node 1 circle
        $net node 2 circle
        $net node 3 circle
        $net node 4 circle
	$net node 5 circle
	$net node 6 circle
	$net node 7 circle

	mklink $net 3 2 1.5Mb 10ms down
	mklink $net 2 5 1.5Mb 10ms left
	mklink $net 5 6 1.5Mb 10ms up
	mklink $net 6 3 1.5Mb 10ms right
	mklink $net 3 5 1.5Mb 10ms down-left
	mklink $net 6 2 1.5Mb 10ms down-right
	mklink $net 4 6 1.5Mb 10ms down
	mklink $net 4 7 1.5Mb 10ms right
	mklink $net 3 7 1.5Mb 10ms up
	mklink $net 2 1 1.5Mb 10ms down
	mklink $net 5 0 1.5Mb 10ms down

        $net color 1 blue
        $net color 2 yellow

	# prune, graft, graft-ack, join, assert
        $net color 30 purple
        $net color 31 green
        $net color 32 black
	$net color 33 red
	$net color 34 orange
}

proc link-up {src dst} {
        global sim_annotation
        set sim_annotation "link-up $src $dst"
        ecolor $src $dst green
}

proc link-down {src dst} {
        global sim_annotation
        set sim_annotation "link-down $src $dst"
        ecolor $src $dst red
}

proc node-up src {
        ncolor $src green
}

proc node-down src {
        ncolor $src red
}
