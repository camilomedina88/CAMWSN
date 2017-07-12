#
# This software comprises contributed code made by Motorola, as a 
# Contributor, to Network Simulator NS-2 software provided by the 
# Regents of the University of California.
# (Copyright; Regents of the University of California, 1994)
# The contributed code was made as a result of a partnership between 
# Motorola and INRIA Rhone-Alpes. 
#
# Copyright in the contributed code belongs to Motorola Inc. 2001
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
# ALL ADVERTISING MATERIALS MENTIONING FEATURES OR USE OF THIS SOFTWARE MUST 
# DISPLAY AN ACKNOWLEDGEMENT TO THE COPYRIGHT OWNERS. 
# ANY REDISTRIBUTION OF THIS SOFTWARE MUST CONTAIN THE ABOVE COPYRIGHT NOTICES, 
# CONDITIONS AND DISCLAIMER.
#
#
# ############################################################################
# This code was developed by Thierry Ernst (1998-2001)
# MOTOROLA Labs Paris FRANCE - INRIA Rhone-Alpes Grenoble (PLANETE) FRANCE 
# NS-2.1b6 enhancements for Wide-Area mobility simulations
# ############################################################################
#
# Modified for Mobiwan in ns-2.26 by WMC(mobiwan@ti-wmc.nl) -11/04
#
###############################################################################


#Class Agent/MIPv6 -superclass Agent
#Class Agent/MN -superclass Agent/MIPv6
#Class Agent/MIPv6/BS -superclass Agent/MIPv6
#Class Agent/CN -superclass Agent/MIPv6


# ############################################################################
# Defaults settings
# ############################################################################
Simulator set MIPv6_PORT	0	
Simulator set DECAP_PORT	1	
Simulator set RT_HDR_PORT	2

Agent/MIPv6 set print_info_	0	;# output display
Agent/MIPv6/MN set print_info_  0	;# output display
Agent/MIPv6/BS set print_info_	0	;# output display
Agent/MIPv6/CN set print_info_	0	;# output display

Agent/MIPv6/BS set ad_lifetime_   	1	;# Lifetime of Router Advertisement
Agent/MIPv6/MN set reg_lifetime_	10	;# BU Lifetime	
Agent/MIPv6/MN set max_rate_		1 	;# BU interval when new CoA
Agent/MIPv6/MN set slow_rate_		10	;# BU interval for refreshment 
Agent/MIPv6/MN set rt_opti_		1	; # 1 if routing optimization ON 
Agent/MIPv6/MN set bs_forwarding_	1	; # 1 if forwarding from previous BS 

Agent/Network/NetworkBS set dport_              0
Agent/Network/NetworkBS set print_info_ 0       ;# output display

Agent/Network/NetworkMN set dport_              0
Agent/Network/NetworkMN set print_info_ 0       ;# output display

# ##########################################################################
# General procedures to configure Mobile Nodes 
# ##########################################################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Why this proc didn't exist ? this was not a hard work to write it !)
# Class HierNode and node_factory will not be longer supported
# from ns-2.1b7. Then, we want to get rid of this, but ...
# 1. Simulator instproc set-hieraddress uses node_factory_ = HierNode
# 2. proc entry-NewHier is missing
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc entry-NewHier {} {

    return [$self entry-NewBase]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# We need get-node-by-** to return the Mobile Node
# but MNs id are not recorded in array Node_ as wired nodes
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Simulator instproc is-mobile? id {
    $self instvar MNode_
    if [info exists MNode_($id)] {
	return 1
    }
    return 0
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# We need get-node-by-** to return the Mobile Node
# List of ALL nodes, Wired, Wired/Wireless and Wireless
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Simulator instproc ww-nodes {} {
    $self instvar Node_ MNode_
    set nodes ""
    foreach n [array names Node_] {
	lappend nodes $Node_($n)
    }
    foreach n [array names MNode_] {
	lappend nodes $MNode_($n)
    }
    set nodes
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Is this particular node LBM-enabled ?
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc lbmcast? {} {
    $self instvar lbmcast_
    if { ![info exists lbmcast_] } {
	return 0
    }
    return $lbmcast_
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Is Simulator LBM-enabled ?
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Simulator instproc lbmcast? {} {
    $self instvar lbmcast_
    if { ![info exists lbmcast_] } {
	return 0
    }
    return $lbmcast_
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Needed by Mobile IPv6 (particularly MN) to decapsulated packtes
# Based on Node/MobileNode instproc attach-decap
# o Currently, only MN needs a decapsulator
# (XXX: This may be wrong if we use HMIP)
# o All agent including MIPDecapsulator's default target is
# MIPv6 Agent 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc attach-decapsulator {} {
    $self instvar decap_ dmux_ agents_ regagent_
    
    set decap_ [new Classifier/Addr/MIPDecapsulator]
    lappend agents_ $decap_
    
    # Do I need this ???
    # set mask 0x7fffffff
    # set shift 0
    # if {[expr [llength $agents_] - 1] > $mask} {
    #    error "\# of agents attached to node $self exceeds port-field length of $m ask bits\n"
    # }
    
    $dmux_ install [Simulator set DECAP_PORT] $decap_
    $decap_ defaulttarget  [$self entry]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Depending on option, this proc allow MN with one or two interfaces
# The DUAL one is used for global mobility
# If ALL: we use the standard Node/Mobile node stack  
# If DUAL: just have two MAC / LL / IFq - NetworkMN Agent points to the one
# currently in use.
# XXXX If LIGHT: We don't need MAC / LL / ARP / etc.  But we need Phy.
# XXX We remove the full network interface stack in oder to avoid a 
# XXX persistent bug when we change from one channel to another.
# XXX Bug is due to MAC because CTS (Clear to Send) are sent by the
# XXX MN to the new channel though it was meant to the previous one
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Simulator instproc net-iface-type {val} {
 $self instvar iface_

   if { $val == "LIGHT" } {
   # XXX We don't need this anymore - to be removed 
      $self set iface_ LIGHT 
   } elseif { $val == "DUAL" } {
      $self set iface_ DUAL 
   } else {
      $self set iface_ ALL 
   } 
}

# ##########################################################################
# Routing Header Extensions
# ##########################################################################
SrcRouting set port_ [Simulator set RT_HDR_PORT]
SrcRouting set addr_ 0

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Return the care-of address corresponding to the home address
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SrcRouting instproc lookup-binding-cache mhaddr {
    $self instvar node_
    return [[$node_ set regagent_] set TunnelExit_($mhaddr)]
}


# ##########################################################################
# Mobile IPv6 nodes configuration 
# ##########################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Needed by node-config if mipv6 argument is used. 
# If set, means we are using Mobile IPv6 Agent, and that we may
# set encap and decap. 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Simulator instproc mipv6 {val} {
    $self instvar mipv6_
    if { $val == "ON" } {
	$self set mipv6_ 1 
    } else {
	$self set mipv6_ 0
    } 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Simulator instproc mipagent {val} {
    $self instvar mipagent_ 
    set mipagent_ $val
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Is simulator mipv6-enabled ? 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Simulator instproc mipv6? {} {
    $self instvar mipv6_
    if { ![info exists mipv6_] } {
	return 0 
    }
    return $mipv6_ 
}

# ##########################################################################
# Node BS
# ##########################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Base Stations and HA are able to encapsulate
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc makemip-NewBS {} {
    
    $self instvar regagent_ encap_ agents_ address_ dmux_ id_ classifier_hier_
    $self instvar bcache_classifier_
    set mipagent_ [[Simulator instance] set mipagent_]
    
    $self test-mcast
    
    set bcache_classifier_ [new Classifier/Hash/Dest 8]
    $bcache_classifier_ set mask_ 0xffffffff
    $bcache_classifier_ set shift_ 0
    
    $self insert-entry [$self get-module Hier] $bcache_classifier_ 0
    $bcache_classifier_ defaulttarget $classifier_hier_
    
    if { $dmux_ == "" } {
	set dmux_ [new Classifier/Port/Reserve]
	$dmux_ set mask_ 0x7fffffff
	$dmux_ set shift_ 0
	
	if [Simulator set EnableHierRt_] {  
	    $classifier_hier_ install $address_ $dmux_
	    #$self add-hroute $address_ $dmux_
	} else {
	    $self add-route $address_ $dmux_
	}
    } 
    $self attach-redirect
    set regagent_ [new Agent/MIPv6/$mipagent_ $self]
    $self attach $regagent_ [Simulator set MIPv6_PORT]

}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc set-node-addressBS { args } {
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc mk-default-classifierBS {} {
    $self mk-default-classifierBase
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc entry-NewBS {} {
    return [$self entry-NewBase]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc install-defaulttarget-NewBS {rcvT} {
    $self install-defaulttarget-NewBase $rcvT
}    

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc do-resetBS {} {
    $self do-resetBase
}

# ##########################################################################
# Node MN
# ##########################################################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MN is able to decapsulate (encap not necessarily needed) 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc makemip-NewMN {} {
   
    $self instvar regagent_ decap_ dmux_ address_ classifier_hier_ 
    $self instvar bcache_classifier_
    
    set mipagent_ [[Simulator instance] set mipagent_]

    $self test-mcast

    set bcache_classifier_ [new Classifier/Hash/Dest 8]
    $bcache_classifier_ set mask_ 0xffffffff
    $bcache_classifier_ set shift_ 0
    
    $self insert-entry [$self get-module Hier] $bcache_classifier_ 0
    $bcache_classifier_ defaulttarget $classifier_hier_    
    
    if { $dmux_ == "" } {
        set dmux_ [new Classifier/Port/Reserve]
        $dmux_ set mask_ 0x7fffffff
        $dmux_ set shift_ 0
        
        if [Simulator set EnableHierRt_] {  
	    $classifier_hier_ install $address_ $dmux_
            #$self add-hroute $address_ $dmux_
        } else {
            $self add-route $address_ $dmux_
        }
    } 
    $self attach-redirect
    
    set regagent_ [new Agent/MIPv6/$mipagent_ $self]
    $self attach $regagent_ [Simulator set MIPv6_PORT]
    $regagent_ node $self

    # $self attach-decap
    $self attach-decapsulator
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc set-node-addressMN { args } {
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc mk-default-classifierMN {} {
    $self mk-default-classifierBase
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc entry-NewMN {} {
    return [$self entry-NewBase]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc install-defaulttarget-NewMN {rcvT} {
    $self install-defaulttarget-NewBase $rcvT
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc do-resetMN {} {
    $self do-resetBase
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set the home agent of the mobile node
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc set-ha { ha_addr } {
    $self instvar regagent_ ha_
    $self set ha_ [[Simulator instance] get-node-by-addr $ha_addr]
    $regagent_ set-ha [AddrParams set-hieraddr $ha_addr]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Return the address of the Home Agent of the mobile node
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc get-ha-addr {} {
    $self instvar regagent_ ha_
    return [[$self set ha_] node-addr]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Return the address of the Home Agent of the mobile node
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc get-ha {} {
    $self instvar regagent_ ha_
    return [$self set ha_]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add a new correspondent node to which a BU should be sent
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc add-cn { cn_addr } {
    $self instvar regagent_
    $regagent_ add-cn [AddrParams set-hieraddr $cn_addr]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc remove-cn { cn_addr } {
    $self instvar regagent_
    $regagent_ remove-cn [AddrParams set-hieraddr $cn_addr]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc add-group { group } {
    $self instvar regagent_
    $regagent_ add-group $group
}

# ##########################################################################
# Other IPv6 Nodes 
# ##########################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Nodes created after node-config is called with arg mipv6 
# are mobile IPv6-enable and able to encapsulate 
# XXX: makemip-NewBS and MN should call makemip-NewHier directly
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc makemip-NewHier {} {
    
    $self instvar regagent_ encap_ agents_ address_ dmux_ id_ classifier_hier_
    $self instvar bcache_classifier_
    set mipagent_ [[Simulator instance] set mipagent_]
    $self test-mcast
    
    set bcache_classifier_ [new Classifier/Hash/Dest 8]
    $bcache_classifier_ set mask_ 0xffffffff
    $bcache_classifier_ set shift_ 0
    
    $self insert-entry [$self get-module Hier] $bcache_classifier_ 0
    $bcache_classifier_ defaulttarget $classifier_hier_
    
    if { $dmux_ == "" } {
	set dmux_ [new Classifier/Port/Reserve]
	$dmux_ set mask_ 0x7fffffff
	$dmux_ set shift_ 0

	if [Simulator set EnableHierRt_] {
	    $classifier_hier_ install $address_ $dmux_
	    #$self add-hroute $address_ $dmux_
	} else {
	    $self add-route $address_ $dmux_
	}
    }
    $self attach-redirect
    set regagent_ [new Agent/MIPv6/$mipagent_ $self]
    $self attach $regagent_ [Simulator set MIPv6_PORT]
    
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This procedure allows the node to redirect packets.
# (Source routing or tunneling)
# NodeMobileNode and Node both call this proc. 
# XXX: originally Node instproc attach-encap
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node instproc attach-redirect {} {
    
    $self instvar encap_ address_ classifiers_ bcache_classifier_
    $self instvar src_routing_ src_classifier_ classifier_ classifier_hier_
    
    
    if [Simulator set EnableHierRt_] {
        set nodeaddr [AddrParams addr2id $address_]
    } else {
        set nodeaddr [expr ( $address_ &                        \
				 [AddrParams set NodeMask 1] ) <<      \
			  [AddrParams set NodeShift 1]]
    }
    
    # For Routing header insertion
    set src_routing_ [new SrcRouting]
    $src_routing_ set port_ [Simulator set RT_HDR_PORT] 
    $src_routing_ set node_ $self
    $self attach $src_routing_ [Simulator set RT_HDR_PORT]
    $src_routing_ node $self
    
    # For Encapsulation
    set encap_ [new MIPEncapsulator]
    $encap_ set addr_ $nodeaddr
    $encap_ set port_ 1
    #$encap_ target $classifiers_(1)
    $encap_ target $classifier_hier_ 
    $encap_ set node_ $self
    
    # To decide (in case we have an entry in the binding cache)
    # if packet should be sent using a routing header 
    # (source = local node) or using tunneling 
    set src_classifier_ [new Classifier/Hash/Src 2]
    $src_classifier_ set mask_ 0xffffffff
    $src_classifier_ set shift_ 0 
    $src_classifier_ defaulttarget $encap_
    $src_classifier_ install $nodeaddr $src_routing_
    
    
    set ns_ [Simulator instance]
    if { [$self lbmcast?] || [$ns_ multicast?] } {
        $self instvar switch_

    	# Link switch to bcache_classifier instead of classifier_
    	$switch_ install 0 $bcache_classifier_
    }

}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Agent/MIPv6 instproc init args {
    eval $self next $args
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Agent/MIPv6 instproc getid { } {
    $self instvar node_  
    return [$node_ id]
}

# ##########################################################################
# Agent BS (Base Station and HA)
# ##########################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set Router Advertisement interval to some specified value
# This also starts the emission of Router Advertisements 
# RA may be stopped and restarted at anytime using start-beacon/
# stop-beacon 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Agent/MIPv6/BS instproc init args {
    set args [eval $self init-vars $args]	
    eval $self next $args
    $self set-beacon-period 1.0; # default value
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Agent/MIPv6/BS instproc encap-route { mhaddr coa lifetime } {
    $self instvar node_ TunnelExit_ RegTimer_
    
    set ns [Simulator instance]
    set bcache [$node_ set bcache_classifier_]
    set target [$node_ set src_classifier_]
    
    # Make slot points to src_classifier if packet ought to be redirected 
    $bcache install $mhaddr $target
    
    set TunnelExit_($mhaddr) $coa
    if { [info exists RegTimer_($mhaddr)] && $RegTimer_($mhaddr) != "" } {
	$ns cancel $RegTimer_($mhaddr)
    }
    set RegTimer_($mhaddr) [$ns at [expr [$ns now] + $lifetime] \
				"$self clear-reg $mhaddr"]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Agent/MIPv6/BS instproc clear-reg mhaddr {
    $self instvar node_ RegTimer_
    
    set bcache [$node_ set bcache_classifier_]
    set target [$node_ set classifier_hier_]
     
    $bcache install $mhaddr $target 
    
    if { [info exists RegTimer_($mhaddr)] && $RegTimer_($mhaddr) != "" } {
	[Simulator instance] cancel $RegTimer_($mhaddr)
	set RegTimer_($mhaddr) ""
    }
}

# ##########################################################################
# Agent MN (Mobile Node)
# ##########################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Agent/MIPv6/MN instproc init args {
    
    eval $self next $args

    # Set beacon period and starts the beacon timer.
    # Allow one beacon to be lost before deciding we have lost contact
    $self check-beacon 2.3     ;# default value
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Return the careof address = prefix of base station + node id % 128.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Agent/MIPv6/MN instproc get-coa { bs_addr } {
    $self instvar node_
    set prefix [get_subnet_prefix $bs_addr]
    set suffix [expr [$node_ set id_] % 128]
    return [AddrParams set-hieraddr $prefix.$suffix]
}

# ##########################################################################
# Agent CN (Correspondent Node)
# ##########################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Agent/MIPv6/CN instproc init args {	
    eval $self next $args
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Agent/MIPv6/CN instproc encap-route { mhaddr coa lifetime } {
    $self instvar node_ TunnelExit_ RegTimer_
    
    set ns [Simulator instance]
    set bcache [$node_ set bcache_classifier_]
    set target [$node_ set src_classifier_]
    
    # Make slot points to src_classifier if packet ought to be redirected 
    $bcache install $mhaddr $target
    
    set TunnelExit_($mhaddr) $coa
    if { [info exists RegTimer_($mhaddr)] && $RegTimer_($mhaddr) != "" } {
        $ns cancel $RegTimer_($mhaddr)
    }
    set RegTimer_($mhaddr) [$ns at [expr [$ns now] + $lifetime] \
				"$self clear-reg $mhaddr"]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clear Binding between MN's home address and MN's COA.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Agent/MIPv6/CN instproc clear-reg mhaddr {
    $self instvar node_ RegTimer_
    
    set bcache [$node_ set bcache_classifier_]
    set target [$node_ set classifier_hier_]
    
    $bcache install $mhaddr $target
    
    if { [info exists RegTimer_($mhaddr)] && $RegTimer_($mhaddr) != "" } {
        [Simulator instance] cancel $RegTimer_($mhaddr)
        set RegTimer_($mhaddr) ""
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Method to remove an entry from the hier classifiers
# Exactly same as Node/MobileNode instproc clear-hroute args
# But did not exist until now.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Node instproc clear-hroute args
#    $self instvar classifiers_
#    set a [split $args]
#    set l [llength $a]
#    $classifiers_($l) clear [lindex $a [expr $l-1]]


# ##########################################################################
# Network agent that replaces Ad-hoc routing agent
# Particularly needed by the MN:
# - to forward packet to the Base Station by setting the next_hop field
# - to monitor what are the active Correspondent Nodes 
# XXX: Router Advertisement and Solicitations should also be processed
# here, but still in the Mobile IPv6 agent until now.
# ##########################################################################
Simulator instproc create-network-agent { node } {
    
    set nodetype_ [$self get-nodetype]
    if { $nodetype_ == "BS" } {
    	set ragent [new Agent/Network/NetworkBS]
    } else {
	if { $nodetype_ == "MN" } {
	    set ragent [new Agent/Network/NetworkMN]
	    $ragent mip-agent [$node set regagent_]
	    $ragent decap-port [Simulator set DECAP_PORT]
	} else {
	    puts "Wrong Routing Agent"
	}
    }
    
    ## setup address (supports hier-addr) for site agent
    ## and mobilenode
    set addr [$node node-addr]
    $ragent addr $addr
    $ragent node $node
    
    if [Simulator set mobile_ip_] {
        $ragent port-dmux [$node set dmux_]
    }
    $node addr $addr
    $node set ragent_ $ragent
    
    #delay till after add interface
    #   $node attach $ragent 255
    
    # start-site is useless, unless we want to move Router Advertisement here
    # $self at 0.0 "$ragent start-site"    ;# start 
    
    return $ragent
}



