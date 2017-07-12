#version 0.5, Nov 04, 2004

Agent/SP set sport_        0
Agent/SP set dport_        0

set opt(ragent)		Agent/SP

puts "Ke Liu Shortest Path Routing configuration file"
# ======================================================================

proc create-sp-routing-agent { node } {
    global ns_ ragent_ tracefd opt

    set addr [$node node-addr]

    set ragent_($addr) [new $opt(ragent) $addr]
    set ragent $ragent_($addr)

    if [Simulator set mobile_ip_] {
	$ragent port-dmux [$node set dmux_]
    }

    $node set ragent_ $ragent
    $node attach $ragent [Node set rtagent_port_]

    set drpT [cmu-trace Drop "RTR" $node]
    $ragent drop-target $drpT
    
}


proc sp-create-mobile-node { id args } {
    global ns ns_ chan prop topo tracefd opt node_
    global chan prop tracefd topo opt
    
    set ns_ [Simulator instance]
    set node_($id) [new Node/MobileNode]
    
    
    set node $node_($id)
    $node random-motion 0		;# disable random motion
    $node topography $topo
    
    # XXX Activate energy model so that we can use sleep, etc. But put on 
    # a very large initial energy so it'll never run out of it.
    if [info exists opt(energy)] {
	$node addenergymodel [new $opt(energy) $node 1000 0.5 0.2]
    }
    
    #
    # This Trace Target is used to log changes in direction
    # and velocity for the mobile node.
    #
    set T [new Trace/Generic]
    $T target [$ns_ set nullAgent_]
    $T attach $tracefd
    $T set src_ $id
    #	$node log-target $T
    
    if ![info exist inerrProc_] {
	set inerrProc_ ""
    }
    if ![info exist outerrProc_] {
	set outerrProc_ ""
    }
    if ![info exist FECProc_] {
	set FECProc_ ""
    }
    
    $node add-interface $chan $prop $opt(ll) $opt(mac) \
	$opt(ifq) $opt(ifqlen) $opt(netif) $opt(ant) \
	$topo $inerrProc_ $outerrProc_ $FECProc_ 
    
    #
    # Create a Routing Agent for the Node
    #
    create-sp-routing-agent $node
    
    $ns_ at 0.0 "$node_($id) start"
    
    return $node
}

