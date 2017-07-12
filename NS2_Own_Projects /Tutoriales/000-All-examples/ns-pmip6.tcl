Agent/PMIPv6 set debug_ 0
Agent/PMIPv6/MAG set debug_ 0
Agent/PMIPv6/LMA set debug_ 0

Agent/PMIPv6 set binding_lifetime_ 500
Agent/PMIPv6/MAG set binding_lifetime_ 500
Agent/PMIPv6/LMA set binding_lifetime_ 500

Agent/PMIPv6 set max_retry_count_ 5
Agent/PMIPv6/MAG set max_retry_count_ 5
Agent/PMIPv6/LMA set max_retry_count_ 5

Agent/PMIPv6 set default_port_ 250
Agent/PMIPv6/MAG set default_port_ 250
Agent/PMIPv6/LMA set default_port_ 250

PMIPv6Encapsulator set addr_ -1
PMIPv6Encapsulator set port_ -1
PMIPv6Encapsulator set dest_addr_ -1
PMIPv6Encapsulator set dest_port_ -1
PMIPv6Encapsulator set ttl_ 32
PMIPv6Encapsulator set debug_ 0

Mac/802_11 set use_pmip6_ext_ 0

WimaxScheduler/BS set use_pmip6_ext_ 0

Simulator set PMIPv6_TUNNEL_PORT	1

Node instproc install-mag {} {
		$self instvar classifier_ dmux_ agents_ ll_

    $self instvar pmip6_agent_ 
		$self instvar src_classifier_ old_classifier_
		$self instvar decap_
   
    set mag [new Agent/PMIPv6/MAG]
    $self attach $mag [$mag set default_port_]
    set pmip6_agent_ $mag
    
    #attach src classifier
		set old_classifier_ $classifier_
		
		set src_classifier_ [new Classifier/Addr/PMIPv6Src]
		$src_classifier_ set mask_ 0xffffffff
		$src_classifier_ set shift_ 0
		$src_classifier_ defaulttarget $old_classifier_
		
		set nodetype [[Simulator instance] get-nodetype]
		
		$self insert-entry [$self get-module $nodetype] $src_classifier_
		$src_classifier_ install-by-src 0 $old_classifier_
    
    #attach decap_
		set decap_ [new Classifier/Addr/PMIPv6Decapsulator]
		$decap_ set mask_ 0xffffffff
		$decap_ set shift_ 0
		
		lappend $agents_ $decap_
		$dmux_ install [Simulator set PMIPv6_TUNNEL_PORT] $decap_

		# LL points previous hier_classifier as up-target
		# we should change this to our classifier
		if {[info exists ll_(0)] && $ll_(0) != ""} {
			$ll_(0) up-target $src_classifier_
		}

    return $mag
}

Node instproc install-lma {} {
    $self instvar classifier_ decap_ dmux_ agents_
    $self instvar pmip6_agent_
		$self instvar dst_classifier_ old_classifier_
    
    #attach pmip6 agent
    set lma [new Agent/PMIPv6/LMA]
    $self attach $lma [$lma set default_port_]
    set pmip6_agent_ $lma
    
    #attach dest classifier
		set old_classifier_ $classifier_
		
		set dst_classifier_ [new Classifier/Addr/PMIPv6Dest]
		$dst_classifier_ set mask_ 0xffffffff
		$dst_classifier_ set shift_ 0
		$dst_classifier_ defaulttarget $old_classifier_

		set nodetype [[Simulator instance] get-nodetype]
		
		$self insert-entry [$self get-module $nodetype] $dst_classifier_
		$dst_classifier_ install-by-dest 0 $old_classifier_

    #attach decapsulator
    set decap_ [new Classifier/Addr/PMIPv6Decapsulator]
		$decap_ set mask_ 0xffffffff
		$decap_ set shift_ 0
    $decap_ defaulttarget $dst_classifier_
     
    lappend $agents_ $decap_
    $dmux_ install [Simulator set PMIPv6_TUNNEL_PORT] $decap_
   
    return $lma
}

Node instproc get-pmip6-agent {} {
		$self instvar pmip6_agent_
    if {[info exists pmip6_agent_]} {
			return $pmip6_agent_
    }
    return ""
}

## PMIP encap management
Node instproc get-pmip6-encap { te } {
		$self instvar address_ Encaps_
		
		if {[info exists Encaps_($te)] && $Encaps_($te) != ""} {
			return $Encaps_($te)
		}
		
		set Encaps_($te) [new PMIPv6Encapsulator]
		
		$Encaps_($te) set addr_ [AddrParams addr2id $address_]
		$Encaps_($te) set port_ [Simulator set PMIPv6_TUNNEL_PORT]
		
		$Encaps_($te) set dest_addr_ $te
		$Encaps_($te) set dest_port_ [Simulator set PMIPv6_TUNNEL_PORT]
		
		$Encaps_($te) target [$self entry]
		$Encaps_($te) set node_ $self
		
		return $Encaps_($te)
}

Node instproc clear-pmip6-encap { te } {
		$self instvar Encaps_
		
		if {[info exists Encaps_($te)] && $Encaps_($te) != ""} {
			delete $Encaps_($te)
			unset Encaps_($te)
		}
}

############## Source Classifier ##############
Classifier/Addr/PMIPv6Src instproc defaulttarget { classifier } {
		$self instvar classifier_
		
		set classifier_ $classifier
		
		$self cmd defaulttarget $classifier
}

Classifier/Addr/PMIPv6Src instproc install { dst target } {
		$self classifier_

		$classifier_ install $dst $target
}

Classifier/Addr/PMIPv6Src instproc clear { dst } {
		$self instvar classifier_
		
		$classifier_ clear $dst
}

Classifier/Addr/PMIPv6Src instproc install-by-src { addr target } {
		$self cmd install $addr $target
}

Classifier/Addr/PMIPv6Src instproc clear-by-src { addr } {
		$self cmd clear $addr
}

############## Dest Classifier ##############
Classifier/Addr/PMIPv6Dest instproc defaulttarget { classifier } {
		$self instvar classifier_
		
		set classifier_ $classifier
		
		$self cmd defaulttarget $classifier
}

Classifier/Addr/PMIPv6Dest instproc install {dst target} {
		$self instvar classifier_

		$classifier_ install $dst $target
}

Classifier/Addr/PMIPv6Dest instproc clear { dst } {
		$self instvar classifier_
		
		$classifier_ clear $dst
}

Classifier/Addr/PMIPv6Dest instproc install-by-dest { addr target } {
		$self cmd install $addr $target
}

Classifier/Addr/PMIPv6Dest instproc clear-by-dest { addr } {
		$self cmd clear $addr
}

####################### MAG ##########################
Agent/PMIPv6/MAG instproc setup-route { mnaddr te} {
		$self instvar node_
		
		set ns [Simulator instance]
		
		#decap settings
		set decap_ [$node_ set decap_]
		
		if {[$node_ info class] == "MobileNode/MIPBS" || [$node_ info class] =="Node/MobileNode" } {
			set target [$node_ set ragent_]
		} else {
			set target [[$ns link $node_ [$ns get-node-by-addr $mnaddr]] head]
			
			if {$target==""} {
				puts "cannot find target"
			}
		}
		
		$decap_ install $mnaddr $target
		
		#encap settings
		set clsfr_src [$node_ set src_classifier_]
		set encap [$node_ get-pmip6-encap $te]
		
		$clsfr_src install-by-src $mnaddr $encap
}

Agent/PMIPv6/MAG instproc clear-route { mnaddr } {
		$self instvar node_
		
		set ns [Simulator instance]
		
		set clsfr_src [$node_ set src_classifier_]
		set decap_ [$node_ set decap_]
		
		$clsfr_src clear-by-src $mnaddr
		$decap_ clear $mnaddr
}		

####################### LMA ###########################

Agent/PMIPv6/LMA instproc setup-route { mnaddr te } {
		$self instvar node_
		
		set ns [Simulator instance]

		#encap settings
		set clsfr_dst [$node_ set dst_classifier_]
		set encap [$node_ get-pmip6-encap $te]
		
		$clsfr_dst install-by-dest $mnaddr $encap
}

Agent/PMIPv6/LMA instproc clear-route { mnaddr } {
		$self instvar node_
		
		set clsfr_dst [$node_ set dst_classifier_]
		
		$clsfr_dst clear-by-dst $mnaddr
}
