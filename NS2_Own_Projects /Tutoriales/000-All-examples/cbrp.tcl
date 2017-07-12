# dsr.tcl
# $Id: dsr.tcl,v 1.10 1998/08/11 14:46:54 dmaltz Exp $

# ======================================================================
# Default Script Options
# ======================================================================

set opt(rt_port) 255
set opt(cc)      "off"            ;# have god check the caches for bad links?

Agent/CBRP set sport_ 255
Agent/CBRP set dport_ 255

Agent/CBRP set no_of_clusters_ 0
#Agent/CBRP set sport_        0
#Agent/CBRP set dport_        0
#Agent/CBRP set wst0_         6        ; As specified by Pravin
#Agent/CBRP set perup_       15        ; As given in the paper (update period)
Agent/CBRP set use_mac_      0        ;# Performance suffers with this on
Agent/CBRP set be_random_    1        ;# Flavor the performance numbers :)
#Agent/CBRP set alpha_        0.875    ; 7/8, as in RIP(?)
#Agent/CBRP set min_update_periods_  1  ; #Missing perups before linkbreak
Agent/CBRP set myaddr_       0        ;# My address
Agent/CBRP set verbose_      1        ;#
Agent/CBRP set trace_wst_    0        ;#

# ======================================================================
# god cache monitoring

source tcl/ex/timer.tcl
Class CacheTimer -superclass Timer
CacheTimer instproc timeout {} {
    global opt node_;
    $self instvar agent;
    $agent check-cache
    $self sched 1.0
}

proc checkcache {a} {
    global cachetimer ns_ ns

    set ns $ns_
    set cachetimer [new CacheTimer]
    $cachetimer set agent $a
    $cachetimer sched 1.0
}

# ======================================================================
Class SRNode -superclass MobileNode

SRNode instproc init {args} {
    global opt ns_ tracefd RouterTrace
    $self instvar cbrp_agent_ dmux_ entry_point_

    eval $self next $args	;# parent class constructor

    set cbrp_agent_ [new Agent/CBRP]
    $cbrp_agent_ ip-addr [$self id]
    $cbrp_agent_ set myaddr_ [$self id]

    puts "Creating node [$self id]";

    if { $RouterTrace == "ON" } {
	# Recv Target
	set rcvT [cmu-trace Recv "RTR" $self]
	$rcvT target $cbrp_agent_
	set entry_point_ $rcvT	
    } else {
	# Recv Target
	set entry_point_ $cbrp_agent_
    }

    #
    # Drop Target (always on regardless of other tracing)
    #
    set drpT [cmu-trace Drop "RTR" $self]
    $cbrp_agent_ drop-target $drpT

    #
    # Log Target
    #
    set T [new Trace/Generic]
    $T target [$ns_ set nullAgent_]
    $T attach $tracefd
    $T set src_ [$self id]
    $cbrp_agent_ log-target $T

    $cbrp_agent_ target $dmux_

    # packets to the DSR port should be dropped, since we've
    # already handled them in the DSRAgent at the entry.
    set nullAgent_ [$ns_ set nullAgent_]
    $dmux_ install $opt(rt_port) $nullAgent_
    #$dmux_ install $opt(rt_port) $cbrp_agent_

    # SRNodes don't use the IP addr classifier.  The DSRAgent should
    # be the entry point
    $self instvar classifier_
    set classifier_ "srnode made illegal use of classifier_"

}

SRNode instproc start-cbrp {} {
    $self instvar cbrp_agent_
    global opt;

    $cbrp_agent_ startcbrp
    if {$opt(cc) == "on"} {checkcache $cbrp_agent_}
}

SRNode instproc entry {} {
        $self instvar entry_point_
        return $entry_point_
}



SRNode instproc add-interface {args} {
# args are expected to be of the form
# $chan $prop $tracefd $opt(ll) $opt(mac)
    global ns_ opt RouterTrace

    eval $self next $args

    $self instvar cbrp_agent_ ll_ mac_ ifq_

    $cbrp_agent_ mac-addr [$mac_(0) id]

    if { $RouterTrace == "ON" } {
	# Send Target
	set sndT [cmu-trace Send "RTR" $self]
	$sndT target $ll_(0)
	$cbrp_agent_ add-ll $sndT $ifq_(0)
    } else {
	# Send Target
	$cbrp_agent_ add-ll $ll_(0) $ifq_(0)
    }
    
    # setup promiscuous tap into mac layer
    #$cbrp_agent_ install-tap $mac_(0)

}

SRNode instproc reset args {
    $self instvar cbrp_agent_
    eval $self next $args

    $cbrp_agent_ reset
}

# ======================================================================

proc create-mobile-node { id } {
	global ns_ chan prop topo tracefd opt node_
	global chan prop tracefd topo opt

	set node_($id) [new SRNode]

	set node $node_($id)
	$node random-motion 0		;# disable random motion
	$node topography $topo

        # connect up the channel
        $node add-interface $chan $prop $opt(ll) $opt(mac)	\
	     $opt(ifq) $opt(ifqlen) $opt(netif) $opt(ant)

	#
	# This Trace Target is used to log changes in direction
	# and velocity for the mobile node and log actions of the DSR agent
	#
	set T [new Trace/Generic]
	$T target [$ns_ set nullAgent_]
	$T attach $tracefd
	$T set src_ $id
	$node log-target $T

        $ns_ at 0.0 "$node start-cbrp"
}

