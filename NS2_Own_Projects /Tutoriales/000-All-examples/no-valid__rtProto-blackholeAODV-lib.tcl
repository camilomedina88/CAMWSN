# Ns-2 integration of blackholeAODV routing agent by a Tcl source file

Agent/rtProto/blackholeAODV set preference_ 120
Agent/rtProto/blackholeAODV set UNREACHABLE [rtObject set unreach_]
Agent/rtProto/blackholeAODV set INFINITY [Agent set ttl_]
# set default value for bound time variable (real value = seconds,
# m = milli-seconds, n = nano-seconds, p = pico-seconds)
Agent/rtProto/blackholeAODV set probingInterval 1000m

# Initialize blackholeAODV on all nodes
Agent/rtProto/blackholeAODV proc init-all args {
	set nodelist [[Simulator instance] all-nodes-list]

	eval rtObject init-all $nodelist

	foreach node $nodelist {
		set proto($node) [[$node rtObject?] add-proto blackholeAODV $node]
	}
	foreach node $nodelist {
foreach nbr [$node neighbors] {
		set rtobj [$nbr rtObject?]
		if { $rtobj != "" } {
			set rtproto [$rtobj rtProto? blackholeAODV]
			if { $rtproto != "" } {
				$proto($node) add-peer $nbr [$rtproto
					set agent_addr_] [$rtproto set
					agent_port_]
				}
			}
		}
	}

	foreach node $nodelist {
		set rtobj [$node rtObject?]
		if {$rtobj != ""} {
			set rtproto [$rtobj rtProto? blackholeAODV]
			if {$rtproto != ""} {
				$rtproto initialize
			}
		}
	}
}

# Initialize blackholeAODV on node
Agent/rtProto/blackholeAODV instproc init node {
	# call the init procedure of the superclass
$self next $node
	$self instvar ns_ rtObject_ ifsUp_ rtsChanged_ rtpref_ nextHop_ \
		nextHopPeer_ metric_ multiPath_
	Agent/rtProto/blackholeAODV instvar preference_

	set ns_ [Simulator instance]
	set UNREACHABLE [$class set UNREACHABLE]
	foreach dst [$ns_ all-nodes-list] {
		set rtpref_($dst) $preference_
		set metric_($dst) $UNREACHABLE
		set nextHop_($dst) ""
		set nextHopPeer_($dst) ""
	}
	set ifsUp_ ""
	set multiPath_ [[$rtObject_ set node_] set multiPath_]

	$self startProbing
}

Agent/rtProto/blackholeAODV instproc compute-routes {} {
	$self computeRoutes
	$self install-routes
}

Agent/rtProto/blackholeAODV instproc install-routes {} {
	$self instvar ns_ ifs_ rtpref_ metric_ nextHop_
	$self instvar peers_ rtsChanged_
	$self instvar node_ preference_

	set MAXPREF [rtObject set maxpref_]
	set UNREACHABLE [rtObject set unreach_]
	set rtsChanged_ 1

	foreach dst [$ns_ all-nodes-list] {
		if { $dst == $node_ } {
			set metric_($dst) 32
			continue
		}
		set path [$self lookup [$dst id]]
		if { [llength $path ] == 0 } {
			# no path found in blackholeAODV
			set rtpref_($dst) $MAXPREF
			set metric_($dst) $UNREACHABLE
			set nextHop_($dst) ""
			continue
	}
	set cost [lindex $path 0]
	set rtpref_($dst) $preference_
	set metric_($dst) $cost
	set nhNode [$ns_ get-node-by-id [lindex $path 1]]
	set nextHop_($dst) $ifs_($nhNode)
	}
}

Agent/rtProto/blackholeAODV proc compute-all {} {
	# Proc methods are not inherited from the parent class.
}

Agent/rtProto/blackholeAODV instproc get-node-id {} {
	$self instvar node_
	return [$node_ id]
}

Agent/rtProto/blackholeAODV instproc get-node-addr {} {
	$self instvar node_
	return [$node_ addr]
}

Agent/rtProto/blackholeAODV instproc add-peer {neighbor agentAddr
	agentPort} {
		$self instvar peers_
		$self set peers_($neighbor) [new rtPeer $agentAddr
			$agentPort $class]
}

Agent/rtProto/blackholeAODV instproc get-peers {} {
	$self instvar peers_
	set peers ""
	foreach nbr [lsort -dictionary [array names peers_]] {
		lappend peers [$nbr id]
		lappend peers [$peers_($nbr) addr?]
		lappend peers [$peers_($nbr) port?]
	}
set peers
}

Agent/rtProto/blackholeAODV instproc startProbing {} {
	set random [new RNG]
	set probingStartTime [$random uniform 0 2]
	[Simulator instance] at $probingStartTime "$self probe-neighbors"

}

