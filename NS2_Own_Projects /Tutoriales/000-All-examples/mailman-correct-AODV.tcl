# ======================================================================
# Default Script Options
# ======================================================================

set opt(ragent)		Agent/AODV
set opt(pos)		NONE

if { $opt(pos) != "NONE" } {
	puts "*** WARNING: AODV using $opt(pos) position configuration..."
}

# ======================================================================
Agent instproc init args {
        $self next $args
}
Agent/rtProto instproc init args {
        $self next $args
}

Agent/AODV instproc init args {
        $self next $args
}

Agent/AODV set sport_	0
Agent/AODV set dport_	0

# ======================================================================

proc create-routing-agent { node id } {
	global ns_ ragent_ tracefd opt RouterTrace

	#
	#  Create the Routing Agent and attach it to port 255.
	#
	set ragent_($id) [new $opt(ragent) $id]
	set ragent $ragent_($id)
	$node attach $ragent 255


	$ragent if-queue [$node set ifq_(0)]	;# ifq between LL and MAC
	$ns_ at 0.$id "$ragent_($id) start"	;# start BEACON/HELLO Messages

	set dmux_ [$node demux]
	set classifier_ [$node entry]

        if { $RouterTrace == "ON" } {
	    # Recv Target
	    # puts "router trace on"
	    set rcvT [cmu-trace Recv "RTR" $node]
	    set entry_point_ $rcvT
	    $rcvT target $ragent
	    $classifier_ defaulttarget $rcvT
	    $dmux_ install 255 $rcvT
	} else {
	    # Recv Target
	    # puts "router trace off"
	    set entry_point_ $ragent
	}
	#
	# Drop Target (always on regardless of other tracing)
	#
	set drpT [cmu-trace Drop "RTR" $node]
	$ragent drop-target $drpT

	if { $RouterTrace == "ON" } {
	    # Send Target
	    set sndT [cmu-trace Send "RTR" $node]
	    $sndT target [$node set ll_(0)]
	    $ragent target $sndT
	} else {
	    # Send Target
	    $ragent target [$node set ll_(0)]
	    #$ragent add-ll [$node set ll_(0)] [$node set ifq_(0)]
	}

	#
	# Log Target
	#
	set T [new Trace/Generic]
	$T target [$ns_ set nullAgent_]
	$T attach $tracefd
	$T set src_ $id
	$ragent log-target $T
}


proc create-mobile-node { id } {
	global ns_ chan prop topo tracefd opt node_
	global chan prop tracefd topo opt

	set node_($id) [new Node/MobileNode]

	set node $node_($id)
	$node random-motion 0		;# disable random motion
	$node topography $topo

	#
	# This Trace Target is used to log changes in direction
	# and velocity for the mobile node.
	#
	set T [new Trace/Generic]
	$T target [$ns_ set nullAgent_]
	$T attach $tracefd
	$T set src_ $id
	$node log-target $T
        if ![info exist opt(err)] {
		set opt(err) ""
	}
	if ![info exist opt(fec)] {
		set opt(fec) ""
	}
	$node add-interface $chan $prop $opt(ll) $opt(mac)	\
		$opt(ifq) $opt(ifqlen) $opt(netif) $opt(ant) $opt(err) \
		$opt(fec)

	#
	# Create a Routing Agent for the Node
	#
	create-routing-agent $node $id

	# ============================================================

	if { $opt(pos) == "Box" } {

            set spacing 200
            set maxrow 3
            set col [expr ($id - 1) % $maxrow]
            set row [expr ($id - 1) / $maxrow]
            $node set X_ [expr $col * $spacing]
            $node set Y_ [expr $row * $spacing]
            $node set Z_ 0.0
            $node set speed_ 0.0

            $ns_ at 0.0 "$node_($id) start"

	} elseif { $opt(pos) == "Random" } {

            $node random-motion 1

            $ns_ at 0.0 "$node_($id) start"
        }

}

