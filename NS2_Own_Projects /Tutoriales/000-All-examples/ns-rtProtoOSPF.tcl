
Agent/rtProto/OSPF set UNREACHABLE  [rtObject set unreach_]
Agent/rtProto/OSPF set preference_        120
Agent/rtProto/OSPF set INFINITY           [Agent set ttl_]


Agent/rtProto/OSPF proc init-all args {
	if { [llength $args] == 0 } {
		set nodeslist [[Simulator instance] all-nodes-list]
	} else { 
		eval "set nodeslist $args"
	}
	Agent set-maxttl Agent/rtProto/OSPF INFINITY
	eval rtObject init-all $nodeslist
	foreach node $nodeslist {
		set proto($node) [[$node rtObject?] add-proto OSPF $node]
		$node add-mark "agent OSPF" black
		
		
	}
	foreach node $nodeslist {
		
		foreach nbr [$node neighbors] {
			set rtobj [$nbr rtObject?]
			if { $rtobj == "" } {
				continue
			}
			set rtproto [$rtobj rtProto? OSPF]
			if { $rtproto == "" } {
				continue
			}
			$proto($node) add-peer $nbr \
					[$rtproto set agent_addr_] \
					[$rtproto set agent_port_]
		}
	}

	# -- OSPF stuffs --
	set first_node [lindex $nodeslist 0 ]
	foreach node $nodeslist {
		set rtobj [$node rtObject?]
		if { $rtobj == "" } {
			continue
		}
		set rtproto [$rtobj rtProto? OSPF]
		if { $rtproto == "" } {
			continue
		}
		$rtproto cmd initialize
		if { $node == $first_node } {
			$rtproto cmd setNodeNumber \
				[[Simulator instance] get-number-of-nodes]
		}
	}

}

Agent/rtProto/OSPF instproc init node {
	global rtglibRNG
	
	$self next $node
	$self instvar ns_ rtObject_ ifsUp_ rtsChanged_ rtpref_ nextHop_ \
		nextHopPeer_ metric_ multiPath_ 
	$self instvar mtRouting_ nextHopMt_ numMtIds_ metricMt_
	Agent/rtProto/OSPF instvar preference_ 
		
	set numMtIds_ [$self get-num-mtids]

	;# -- OSPF stuffs -- 
	$self instvar OSPF_ready
	set OSPF_ready 0
	set rtsChanged_ 1
	
	
	set UNREACHABLE [$class set UNREACHABLE]
	foreach dest [$ns_ all-nodes-list] {
		set rtpref_($dest) $preference_
		set nextHop_($dest) ""
		set nextHopPeer_($dest) ""
		set metric_($dest)  $UNREACHABLE
		
	}

	foreach dest [$ns_ all-nodes-list] {
		for {set mtId 0} { $mtId <= $numMtIds_ } {incr mtId} {
		set nextHopMt_([$dest id]:$mtId) ""
		set metricMt_([$dest id]:$mtId) $UNREACHABLE	
		}
	}
	

	set ifsUp_ ""
	set multiPath_ [[$rtObject_ set node_] set multiPath_]
	set mtRouting_ [[$rtObject_ set node_] set mtRouting_]
	
	set HelloTime [$rtglibRNG uniform 0.0 0.5]
	$ns_ at $HelloTime "$self send-periodic-hello"
}

Agent/rtProto/OSPF instproc add-peer {nbr agentAddr agentPort} {
	$self instvar peers_
	$self set peers_($nbr) [new rtPeer $agentAddr $agentPort $class]
}

Agent/rtProto/OSPF instproc send-periodic-hello {} {
	global rtglibRNG 
	$self instvar ns_ node_
	# -- OSPF stuffs --
	$self cmd sendHellos
	set helloTime [expr [$ns_ now] + ([$class set helloInterval])]
	puts "Nodo: [$node_ id]"
	puts "HelloTime: $helloTime"
	$ns_ at $helloTime "$self send-periodic-hello"
}


Agent/rtProto/OSPF instproc get-node-id {} {
	$self instvar node_
	return [$node_ id]
}


Agent/rtProto/OSPF instproc get-peers {} {
	$self instvar peers_ ifs_
	set peers ""
	foreach nbr [lsort -dictionary [array names peers_]] {

	  if {[$ifs_($nbr) up?] == "up"} {
		
		lappend peers [$nbr id]
		lappend peers [$peers_($nbr) addr?]
		lappend peers [$peers_($nbr) port?]
	  }
	} 
	set peers
}



# needed to calculate the appropriate timeout value for retransmission 
# of unack'ed Update,DD, or Request messages
Agent/rtProto/OSPF instproc get-delay-estimates {} {
	$self instvar ifs_ ifstat_ 
	set total_delays ""
	set packet_size 8000.0 ;# bits
	foreach nbr [array names ifs_] {
		set intf $ifs_($nbr)
		set q_limit [ [$intf queue ] set limit_]
		set bw [bw_parse [ [$intf link ] set bandwidth_ ] ]
		set p_delay [time_parse [ [$intf link ] set delay_] ]
		set total_delay [expr $q_limit * $packet_size / $bw + $p_delay]
		$self cmd setDelay [$nbr id] $total_delay
	}
}

Agent/rtProto/OSPF instproc intf-changed {} {

 $self instvar rtsChanged_ 	
 set rtsChanged_ 0
 puts "estado modificado"
 $self cmd interfaceChanged
	
}

Agent/rtProto/OSPF instproc compute-routes {} {
	$self instvar node_ rtsChanged_
	puts "Agent OSPF [$node_ id]: compute-routes"
	if $rtsChanged_ {	
	puts "rtsChanged activo"
	$self cmd computeRoutes
	$self install-routes
	}
}


Agent/rtProto/OSPF instproc compute-routes-cost {} {
	$self instvar node_ rtsChanged_
	puts "Agent OSPF [$node_ id]: compute-routes-cost"
	$self cmd computeRoutes
	$self install-routes
	
}

Agent/rtProto/OSPF instproc cost-changed {} {
	$self instvar rtsChanged_
	set rtsChanged_ 1
	# -- OSPF stuffs --
	puts "coste modificado"
	$self cmd intfChanged
	$self route-changed
 
}

Agent/rtProto/OSPF instproc route-changed {} {
	$self instvar node_ 
	$self instvar rtObject_  rtsChanged_ 
	set rtsChanged_ 1
	$self install-routes
	puts "route-changed"
	$rtObject_ compute-routes
    
}

# put the routes computed in C++ into tcl space
Agent/rtProto/OSPF instproc install-routes {} {

$self instvar ns_ ifs_ rtpref_ metric_ nextHop_ nextHopPeer_
$self instvar peers_ rtsChanged_ multiPath_ mtRouting_
$self instvar node_  preference_ 
$self instvar numMtIds_ nextHopMt_ metricMt_

    
	set INFINITY [$class set INFINITY]
	set MAXPREF  [rtObject set maxpref_]
	set UNREACH  [rtObject set unreach_]
	set rtsChanged_ 1 
	
	
	    foreach dst [$ns_ all-nodes-list] {
		puts "installing routes for [$dst id]"

		if { $dst == $node_ } {
			set metric_($dst) 32  ;# the magic number
			continue
		}

		if {!$mtRouting_} {	
	
		puts " [$node_ id] looking for route to [$dst id]"	
		
		set path [$self cmd lookup [$dst id] 0]
		 puts "PATH: $path" ;# debug
		if { [llength $path ] == 0 } {
			puts "no path found in OSPF"
			set rtpref_($dst) $MAXPREF
			set metric_($dst) $UNREACH
			set nextHop_($dst) ""
			continue
		}
		
		set cost [lindex $path 0]
		set rtpref_($dst) $preference_
		set metric_($dst) $cost
		
		if { ! $multiPath_ } {
			puts "NO MULTIPATH"
			set nhNode [$ns_ get-node-by-id [lindex $path 1]]
			puts "NO MULTIPATH NEXT HOP: [$nhNode id]"
			set nextHop_($dst) $ifs_($nhNode)
			continue
		}
		
		#if multiPath
		set nextHop_($dst) ""
		set nh ""
		set count [llength $path]
		puts "COUNT: $count"
		
		foreach nbr [lsort -dictionary [array names peers_]] {
			puts " PEER: [$nbr id]"
			foreach nhId [lrange $path 1 $count ] {
				puts "NEIGHBOURID PATH: $nhId"
				if { [$nbr id] == $nhId } {
					lappend nextHop_($dst) $ifs_($nbr)
					break
				}
			}
		}

	     	continue
		}

		#if mtrouting
		puts "MTROUTING"
		puts " [$node_ id] looking for route to [$dst id]"
		for {set mtId 0} { $mtId <= $numMtIds_ } {incr mtId} {
			set path [$self cmd lookup [$dst id] $mtId]
			puts "MTROUTING PATH MTID $mtId: $path" ;# debug
			
			if { [llength $path ] == 0 } {
			# no path found in LS
				set nextHopMt_([$dst id]:$mtId) ""				
				set metricMt_([$dst id]:$mtId) $UNREACH	
				if {$mtId==0} {
					set nextHop_($dst) ""
					set metric_($dst) $UNREACH
					set rtpref_($dst) $MAXPREF
				}
				continue
			}

			set cost [lindex $path 0]
			set metricMt_([$dst id]:$mtId) $cost						
                     	
			if {$mtId==0} {
			
			# we only consider the default topology cost to compare to the rest
			# of routing protocols 
			set cost [lindex $path 0]
			set rtpref_($dst) $preference_
			set metric_($dst) $cost						
                     	}
			
			
			if { ! $multiPath_ } {
				set nhNode [$ns_ get-node-by-id [lindex $path 1]]
				puts "!MULTIPATH MTID: $mtId [$nhNode id]"
				set nextHopMt_([$dst id]:$mtId) $ifs_($nhNode)
				
				if {$mtId==0} {
					set nextHop_($dst) $ifs_($nhNode)
				}
				continue
			}
		
			#if multiPath
			set nextHopMt_([$dst id]:$mtId) ""
			set nh ""
			if {$mtId==0} {
			   set nextHop_($dst) ""
			}
			set count [llength $path]
			foreach nbr [lsort -dictionary [array names peers_]] {
			puts " MTROUTING PEER: [$nbr id]"
			   foreach nhId [lrange $path 1 $count ] {
				puts " nhId: $nhId"
				if { [$nbr id] == $nhId } {
					puts "MTROUTING NEIGHBOURID PATH: $nhId"
					lappend nextHopMt_([$dst id]:$mtId) $ifs_($nbr)
						
					if {$mtId==0} {
					   lappend nextHop_($dst) $ifs_($nbr)
					}
					
					break
				}
			}
		}
		
 	   }		
	
     }

}

Agent/rtProto/OSPF proc compute-all {} {
	# Because proc methods are not inherited from the parent class.
}

# get the number of MtIds configured
Agent/rtProto/OSPF instproc get-num-mtids {} {
	$self instvar ns_
	$ns_ get-num-mtids
}

Agent/rtProto/OSPF instproc  get-links-status {} {

	$self instvar ifs_ 
	$self instvar mtRouting_ node_
	set linksStatus ""
	set numMtids [$self get-num-mtids]	
	
	foreach nbr [array names ifs_] {
		lappend linksStatus [$nbr id]
		lappend linksStatus 1 ;# point to point type
		lappend linksStatus $numMtids
		
		for {set i 0} { $i <= $numMtids } {incr i} {
			lappend linksStatus $i
			set coste  [$ifs_($nbr) cost-mt? $i]
			lappend linksStatus $coste
		}
	
	}
	
	
	set linksStatus
      
}

Agent/rtProto/OSPF instproc  hello-colour {} {
	$self set fid_ 991
}

Agent/rtProto/OSPF instproc  dd-colour {} {
	$self set fid_ 992
}

Agent/rtProto/OSPF instproc  update-colour {} {
	$self set fid_ 993
}

Agent/rtProto/OSPF instproc  request-colour {} {
	$self set fid_ 994
}

Agent/rtProto/OSPF instproc  ack-colour {} {
	$self set fid_ 995
}


Simulator instproc get-num-mtids {} {

	set numMtids ""
	set numMtids [$class set numMtIds]
	set numMtids
	
}

Simulator instproc setup-ospf-colors {} {
	
	$self ospf-hello-color  blue
	$self ospf-dd-color  red
	$self ospf-update-color  green
	$self ospf-request-color  violet
	$self ospf-ack-color  yellow
}

Simulator instproc ospf-hello-color {color} {
	$self color 991 $color
}

Simulator instproc ospf-dd-color {color} {
	$self color 992 $color
}

Simulator instproc ospf-update-color {color} {
	$self color 993 $color
}

Simulator instproc ospf-request-color {color} {
	$self color 994 $color
}

Simulator instproc ospf-ack-color {color} {
	$self color 995 $color
}

Simulator instproc cost-mt {n1 n2 c mtid} {
	$self instvar link_ 
	set nMtIds_ [$class set numMtIds]
	#for {set i 0} { $i <= $nMtIds_ } {incr i} {
	#$link_([$n1 id]:[$n2 id]) cost-mt $i $cost
	#set cost [expr $cost + 1]
	#}
	#if {[$n1 set mtRouting_]&& [$n2 set mtRouting_]}  {
	#puts "WARNING: mtRouting active. Cost set for default topology"
	# $link_([$n1 id]:[$n2 id]) cost-mt $mtid $c 
	# return	 
	#}
	#puts "WARNING: mtRouting is not active."
	#$link_([$n1 id]:[$n2 id]) cost $c

	  if {$mtid <= $nMtIds_} {
	    $link_([$n1 id]:[$n2 id]) cost-mt $mtid $c
	    return
	  }  
	  #else
	 puts "WARNING: Simulator instproc cost-mt."
	 puts "Cost not assigned [$n1 id]-->[$n2 id]. The mtid=$mtid is not defined"
	 puts "Number of topologies defined: $nMtIds_"  
		
}

Simulator instproc duplex-cost-mt {n1 n2 c mtid} {

	$self cost-mt $n1 $n2 $c $mtid
	$self cost-mt $n2 $n1 $c $mtid
}

Simulator instproc configure-mtid {agent mtid} {
	
	set nMtIds_ [$class set numMtIds]
	
	  if {$mtid <= $nMtIds_} {
		$agent set mtid_ $mtid
		return
	  } 
	  #	else 
	puts "WARNING:Simulator instproc configure-mtid."
	puts "mtid=$mtid is not valid. Number of topologies defined is $nMtIds_" 
	  
}

Simulator instproc init-links-cost {} {
    $self instvar link_
    	
    set nMtIds_ [$class set numMtIds]
    	
    foreach l [array names link_] {
	set cost_ 1
	set L [split $l :]
	set src [lindex $L 0]
	set dest  [lindex $L 1]
	puts "SRC: $src"
	puts "DEST: $dest"
	set nsrc [$self get-node-by-id $src]
	set ndest [$self get-node-by-id $src]
	#if {[$nsrc set mtRouting_]&& [$ndest set mtRouting_]}  {
	
		for {set i 0} { $i <= $nMtIds_ } {incr i} {
			$link_($src:$dest) cost-mt $i $cost_
			puts "COSTE $cost_"
			set cost_ [expr $cost_ + 1]	
		}
	 #continue	
	#}
	#else	
		
	#	$link_($src:$dest) cost $cost_
			
	#	continue
    }

}


