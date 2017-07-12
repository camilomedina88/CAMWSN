
Class costQueue

Simulator instproc changed-cost-at { at c args } {
	set lcost ""
	$self instvar linkCost_
		
	set lcost [eval new linkCost $self]
	eval $lcost set-elements $args
	eval $lcost set-parms 0 $at $c 

	if [info exists linkCost_] {
		lappend linkCost_ $lcost
	} else {
		set linkCost_ $lcost
	}
	
	return $lcost
}

Simulator instproc changed-cost-at-mt { at c mtid args } {
	set lcost ""
	$self instvar linkCost_
	set nMtIds_ [$class set numMtIds]
	if {$mtid<=$nMtIds_} {
		set lcost [eval new linkCost $self]
		eval $lcost set-elements $args
		eval $lcost set-parms $mtid $at $c 

	if [info exists linkCost_] {
		lappend linkCost_ $lcost
	} else {
		set linkCost_ $lcost
	}
	
	return $lcost
	}
	#else
	 puts "WARNING: changed-cost-at-mt"
	 puts "Cost not modified. The mtid=$mtid is not defined"
	 puts "Number of mtids defined is $nMtIds_." 
	 return
}

Simulator instproc cost-configure {} {
    $self instvar cq_ linkCost_
    if [info exists linkCost_] {
	set cq_ [new costQueue $self]
	foreach m $linkCost_ {
	    $m configure
	 }
    }
}

costQueue instproc init ns {
    $self next
    $self instvar ns_
    set ns_ $ns
}


costQueue instproc insq { at obj iproc args } {
    $self instvar cq_ ns_
    if {[$ns_ now] >= $at} {
	puts stderr "$proc: Cannot set event in the past"
	set at ""
    } else {
	if ![info exists cq_($at)] {
	    $ns_ at $at "$self runq $at"
	    
	}
	lappend cq_($at) "$obj $iproc $args"
    }
    return $at
}


costQueue instproc runq { time } {
    $self instvar cq_
    set objects ""
    foreach event $cq_($time) {
	set obj   [lindex $event 0]
	set iproc [lindex $event 1]
	set args  [lrange $event 2 end]
	eval $obj $iproc $args 
	lappend objects $obj
    }
    foreach obj $objects {
	$obj notify-cost
    }
    unset cq_($time)
}

#
Class linkCost

linkCost set cq_ ""

linkCost instproc init ns {
    $self next
    $self instvar ns_ 
    set ns_ $ns
    
}

linkCost instproc set-elements args {
    $self instvar ns_ links_ nodes_
    if { [llength $args] == 2 } {
	set n0 [lindex $args 0]
	set n1 [lindex $args 1]
	set n0id [$n0 id]
	set n1id [$n1 id]
	
	set nodes_($n0id) $n0
	set nodes_($n1id) $n1
	set links_($n0id:$n1id) [$ns_ link $n0 $n1]
	
    } else {
	puts stderr "changed-cost-at: It's must be indicated two nodes"
	
	}
    	
    
}

linkCost instproc set-parms {mtid at c} {
    $self instvar mt_ at_ c_
    set mt_ $mtid
    set at_ $at
    set c_ $c	   
}

linkCost instproc configure {} {
    $self instvar ns_ links_ mt_ at_ c_
  
    if { [linkCost set cq_] == "" } {
	linkCost set cq_ [$ns_ set cq_]	
    }
    $self set-event $at_ $mt_ $c_
}

linkCost instproc set-event {fireTime mtid c} {
    $self instvar ns_ 
    [linkCost set cq_] insq $fireTime $self cost $mtid $c
    
}

linkCost instproc cost {mtid c} {
    $self instvar links_ ns_
    
    foreach l [array names links_] {
	set L [split $l :]
	set src [lindex $L 0]
	set dest  [lindex $L 1]
	puts "src: $src"
	puts "dest: $dest"
	puts "coste: $c"
	set nsrc [$ns_ get-node-by-id $src]
	set ndest [$ns_ get-node-by-id $dest]
	$ns_ trace-annotate "Enlace $src:$dest: COSTE MODIFICADO antiguo:[$links_($l) cost?] nuevo:$c"
	if {$mtid==0} {
		$ns_ cost-mt $nsrc $ndest $c $mtid
		$ns_ cost $nsrc $ndest $c 
		continue
	}
    
	$ns_ cost-mt $nsrc $ndest $c $mtid
   }	
}


linkCost instproc notify-cost {} {
    $self instvar ns_ links_ nodes_
	puts "notify cost node"
	foreach l [array names links_] {
	set L [split $l :]
	set src [lindex $L 0]
	#notify only to the source node
	set nsrc [$ns_ get-node-by-id $src]
	puts "NOTIFY COST NODE: $src"
	$nodes_($src) cost-changed
	continue
    }
    	
    [$ns_ get-routelogic] notify
    	
}
