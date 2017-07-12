# span.tcl
# ======================================================================
# Default Script Options
# ======================================================================

set opt(rt_port) 255
set opt(srcsink) 0

Agent/SpanAgent set sport_ 255
Agent/SpanAgent set dport_ 255

# ======================================================================
Class SpanNode -superclass Node/MobileNode

SpanNode instproc init {args} {
    global opt ns_ tracefd RouterTrace
    $self instvar span_agent_ dmux_ entry_point_

    eval $self next $args	;# parent class constructor

    if {$dmux_ == "" } {
         # Use the default mash and shift
         set dmux_ [new Classifier/Port]
         $dmux_ set mask_ 0xff
         $dmux_ set shift_ 0
         $self add-route [$self id] $dmux_
    }

    # puts "making SpanAgent for node [$self id]"
    set span_agent_ [new Agent/SpanAgent]
    $span_agent_ ip-addr [$self id]
    $span_agent_ mobile-node $self

    if { $RouterTrace == "ON" } {
	# Recv Target
	set rcvT [cmu-trace Recv "RTR" $self]
	$rcvT target $span_agent_
	set entry_point_ $rcvT	
    } else {
	# Recv Target
	set entry_point_ $span_agent_
    }

    #
    # Drop Target (always on regardless of other tracing)
    #
    set drpT [cmu-trace Drop "RTR" $self]
    $span_agent_ drop-target $drpT

    #
    # Log Target
    #
    set T [new Trace/Generic]
    $T target [$ns_ set nullAgent_]
    $T attach $tracefd
    $T set src_ [$self id]
    # $span_agent_ log-target $T

    $span_agent_ target $dmux_

    # packets to the Span port should be dropped, since we've
    # already handled them in the SpanAgent at the entry.
    set nullAgent_ [$ns_ set nullAgent_]
    $dmux_ install $opt(rt_port) $nullAgent_

    # SpanNodes don't use the IP addr classifier. The SpanAgent should be the
    # entry point

    $self instvar classifier_
    set classifier_ "srnode made illegal use of classifier_"

}

SpanNode instproc start-span {} {
    $self instvar span_agent_
    global opt
    $span_agent_ start-span
}

SpanNode instproc srcsink {val} {
    $self instvar span_agent_
    $span_agent_ srcsink $val
}

SpanNode instproc dump-tables {} {
    $self instvar span_agent_
    global opt
    $span_agent_ dump-tables
}

SpanNode instproc usepsm {val} {
    $self instvar span_agent_
    $span_agent_ usepsm $val
}

SpanNode instproc usespan {val} {
    $self instvar span_agent_
    $span_agent_ usespan $val
}

SpanNode instproc entry {} { 
    $self instvar entry_point_ 
    return $entry_point_ 
}

SpanNode instproc add-interface {args} {
# args are expected to be of the form
# $chan $prop $tracefd $opt(ll) $opt(mac)

    global ns_ opt RouterTrace

    eval $self next $args

    $self instvar span_agent_ ll_ mac_ ifq_

    if { $RouterTrace == "ON" } {
        # Send Target
        set sndT [cmu-trace Send "RTR" $self]
        # $sndT target $ll_(0)
	# $span_agent_ add-ll $sndT $ifq_(0)
        $sndT target $ifq_(0)
	$span_agent_ add-mac $sndT $ifq_(0) $mac_(0)
    } else {
        # Send Target
        # $span_agent_ add-ll $ll_(0) $ifq_(0)
        $span_agent_ add-mac $ifq_(0) $mac_(0)
    }
}

# ======================================================================

proc create-mobile-node { id } {
    global ns_ chan prop topo tracefd opt node_
    global chan prop tracefd topo opt
    
    set node_($id) [new SpanNode]

    set node $node_($id)
    $node usespan $opt(usespan)
    $node usepsm $opt(usepsm)
    $node srcsink $opt(srcsink)
    $node random-motion 0		;# disable random motion
    $node topography $topo
        
    # this is where we set the inital energy levels for the nodes
    # the first parameter is for the inital energy (J)
    set energy [new EnergyModel $node 1000.0 0.5 0.2]
    $node addenergymodel $energy

    if ![info exist inerrProc_] {
        set inerrProc_ ""
    }
        if ![info exist outerrProc_] {
        set outerrProc_ ""
    }
    if ![info exist FECProc_] {
        set FECProc_ ""
    }

    # connect up the channel
    $node add-interface $chan $prop $opt(ll) $opt(mac)	\
	    $opt(ifq) $opt(ifqlen) $opt(netif) $opt(ant) \
	    $topo $inerrProc_ $outerrProc_ $FECProc_ 

    #
    # This Trace Target is used to log changes in direction
    # and velocity for the mobile node and log actions of the DSR agent
    #
    set T [new Trace/Generic]
    $T target [$ns_ set nullAgent_]
    $T attach $tracefd
    $T set src_ $id
    $node log-target $T

    $ns_ at 0.0 "$node start-span"
}

