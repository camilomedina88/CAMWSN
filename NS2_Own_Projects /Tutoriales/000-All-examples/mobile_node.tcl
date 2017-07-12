# ======================================================================
#
# The ARPTable class
#
# ======================================================================
ARPTable instproc init args {
	eval $self next $args		;# parent class constructor
}

ARPTable set bandwidth_         0
ARPTable set delay_             5us
ARPTable set off_prune_         0
ARPTable set off_CtrMcast_      0

# ======================================================================
#
# The MobileNode class
#
# ======================================================================
MobileNode instproc init args {
	eval $self next $args		;# parent class constructor

	$self instvar nifs_ nports_ arptable_ classifier_ dmux_
	$self instvar netif_ mac_ ifq_ ll_ agents_
	$self instvar X_ Y_ Z_

	set X_ 0.0
	set Y_ 0.0
	set Z_ 0.0

#	set netif_	""		;# network interfaces
#	set mac_	""		;# MAC layers
#	set ifq_	""		;# interface queues
#	set ll_		""		;# link layers
	set agents_ ""			;# list of attached agents
        set arptable_ ""                ;# no ARP table yet

	set nifs_	0		;# number of network interfaces
	set nports_	0		;# number of active ports

	set classifier_ [new Classifier/Addr]
	$classifier_ set mask_ 0xffffff
	$classifier_ set shift_ 8

	set dmux_ [new Classifier/Addr]
	$dmux_ set mask_ 0xff
	$dmux_ set shift_ 0
	$self add-route [$self id] $dmux_
}

MobileNode instproc reset {} {
	$self instvar arptable_ nifs_ agents_
	$self instvar netif_ mac_ ifq_ ll_ imep_
        global opt

        for {set i 0} {$i < $nifs_} {incr i} {
	    $netif_($i) reset
	    $mac_($i) reset
	    $ll_($i) reset
	    $ifq_($i) reset
	    if { $opt(imep) == "ON" } { $imep_($i) reset }
	}

	if { $arptable_ != "" } {
	    $arptable_ reset 
	}

	for {set i 0} {$i < [llength $agents_] } {incr i} {
	    [lindex $agents_ $i] reset
	}
}

#
# The following functions are used to allocate routes for
# a MobileNode.
#
MobileNode instproc add-route { dst target } {
	$self instvar classifier_
	$classifier_ install $dst $target
} 

MobileNode instproc alloc-port {} {
	$self instvar nports_ 
	set p $nports_
	incr nports_ 
	return $p
} 

MobileNode instproc entry {} {
        $self instvar classifier_
        return $classifier_
}


#
# Attach an agent to a node.  Pick a port and
# bind the agent to the port number.
#
MobileNode instproc attach { agent { port "" } } {

	global RouterTrace AgentTrace opt

	$self instvar agents_ dmux_ imep_ ll_

	set id_ [$self id]

	#
	# assign port number (i.e., this agent receives
	# traffic addressed to this host and port)
	#

	lappend agents_ $agent
	if { $port == "" } {
		set port [$self alloc-port]
	}

	$agent set portID_ $port
	$agent set node_ $self
	$agent set addr_ $id_
	$agent set sport_ $port

	if { $port == 255 } {	              ;# routing agents
		if { $RouterTrace == "ON" } {
			#
			# Send Target
			#
			set sndT [cmu-trace Send "RTR" $self]
		        if { $opt(imep) == "ON" } {
			    $agent target $imep_(0)
			    $imep_(0) sendtarget $sndT 

			    # need a second tracer to see the actual
			    # types of tora packets before imep packs them
			    if { $opt(debug) == "ON" } {
				set sndT2 [cmu-trace Send "TRP" $self]
				$sndT2 target $imep_(0)
				$agent target $sndT2
			    }
  		        } else {  ;#  no IMEP
			    $agent target $sndT
			}
			$sndT target $ll_(0)

			#
			# Recv Target
			#
			set rcvT [cmu-trace Recv "RTR" $self]
			if { $opt(imep) == "ON" } {
			    puts "Hacked for tora20 runs!! No RTR revc trace"
			    $ll_(0) recvtarget $imep_(0)
			    [$self set classifier_] defaulttarget $agent

			    # need a second tracer to see the actual
			    # types of tora packets after imep unpacks them
			    if { $opt(debug) == "ON" } {
				set rcvT2 [cmu-trace Recv "TRP" $self]
				$rcvT2 target $agent
				[$self set classifier_] defaulttarget $rcvT2
			    }

  		        } else {  
			    $rcvT target $agent
			    [$self set classifier_] defaulttarget $rcvT
			    $dmux_ install $port $rcvT
			}
		    } else {
			#
			# Send Target
			#
		        if { $opt(imep) == "ON" } {
			     $agent target [$self set imep_(0)]
  		        } else {  
			     $agent target [$self set ll_(0)]
			}

			#
			# Recv Target
			#
			[$self set classifier_] defaulttarget $agent
			$dmux_ install $port $agent
		}
	} else {      ;# non-routing agents
		if { $AgentTrace == "ON" } {
			#
			# Send Target
			#
			set sndT [cmu-trace Send AGT $self]
			$sndT target [$self entry]
			$agent target $sndT

			#
			# Recv Target
			#
			set rcvT [cmu-trace Recv AGT $self]
			$rcvT target $agent
			$dmux_ install $port $rcvT

		} else {
			#
			# Send Target
			#
			$agent target [$self entry]

			#
			# Recv Target
			#
		        $dmux_ install $port $agent
		}
	}
}


#
#  The following setups up link layer, mac layer, network interface
#  and physical layer structures for the mobile node.
#
MobileNode instproc add-interface { channel pmodel \
	lltype mactype qtype qlen iftype anttype} {
			     
        $self instvar arptable_ nifs_
        $self instvar netif_ mac_ ifq_ ll_ imep_
    
	global ns_ MacTrace opt
			     
	set t $nifs_
	incr nifs_
			     
	set netif_($t)	[new $iftype]		;# interface
	set mac_($t)	[new $mactype]		;# mac layer
	set ifq_($t)	[new $qtype]		;# interface queue
	set ll_($t)	[new $lltype]		;# link layer
        set ant_($t)    [new $anttype]
       
    if {$opt(errmodel) == "ON"} {
	puts "create errmodel!\n"
#	set errmodel_($t)  [new $opt(emtype)]
	set errmodel_($t) [create-errmodel $opt(emtype)]
    }

        if {$opt(imep) == "ON" } {		;# IMEP layer
	    set imep_($t) [new Agent/IMEP [$self id]]
	    set imep $imep_($t)

            set drpT [cmu-trace Drop "RTR" $self]
            $imep drop-target $drpT

	    $ns_ at 0.[$self id] "$imep_($t) start"	;# start beacon timer
	}

	#
	# Local Variables
	#
	set nullAgent_ [$ns_ set nullAgent_]
	set netif $netif_($t)
	set mac $mac_($t)
	set ifq $ifq_($t)
	set ll $ll_($t)

	if {$opt(errmodel) == "ON"} {
	    set em $errmodel_($t)
	}

	#
	# Initialize ARP table only once.
	#
	if { $arptable_ == "" } {
            set arptable_ [new ARPTable $self $mac]
            set drpT [cmu-trace Drop "IFQ" $self]
            $arptable_ drop-target $drpT
        }

	#
	# Link/IMEP Layer
	#
	$ll arptable $arptable_
	$ll mac $mac
	$ll sendtarget $ifq
	if { $opt(imep) == "ON" } {
	    $imep recvtarget [$self entry]
	    $imep sendtarget $ll
	    $ll recvtarget $imep
	} else {
	    $ll recvtarget [$self entry]
	}

	#
	# Interface Queue
	#
	$ifq target $mac
	$ifq set qlim_ $qlen
	set drpT [cmu-trace Drop "IFQ" $self]
	$ifq drop-target $drpT
	$ifq ipaddr [$self id]	;# for logging purposes only
	$ifq logtarget $drpT		;# for logging purposes only

	#
	# Mac Layer
	#
	$mac netif $netif
	$mac recvtarget $ll
	$mac sendtarget $netif
	$mac nodes $opt(nn)

	#
	# Network Interface
	#
	$netif channel $channel
	
	if { $opt(errmodel) == "ON" } {
	    $em target $mac
	    $em netif $netif
	    $netif recvtarget $em
	} else {
	    $netif recvtarget $mac
	}
	$netif propagation $pmodel	;# Propagation Model
	$netif node $self		;# Bind node <---> interface
	$netif antenna $ant_($t)

	#
	# Physical Channel
	#
	$channel addif $netif

	# ============================================================

	if { $MacTrace == "ON" } {
		#
		# Trace RTS/CTS/ACK Packets
		#
		set rcvT [cmu-trace Recv "MAC" $self]
		$mac log-target $rcvT


		#
		# Trace Sent Packets
		#
		set sndT [cmu-trace Send "MAC" $self]
		$sndT target [$mac sendtarget]
		$mac sendtarget $sndT

		#
		# Trace Received Packets
		#
		set rcvT [cmu-trace Recv "MAC" $self]
		$rcvT target [$mac recvtarget]
		$mac recvtarget $rcvT

		#
		# Trace Dropped Packets
		#
		set drpT [cmu-trace Drop "MAC" $self]
		$mac drop-target $drpT
	} else {
		$mac log-target [$ns_ set nullAgent_]
		$mac drop-target [$ns_ set nullAgent_]
	}

	# ============================================================

	$mac initialize
	$self addif $netif
}

#
# Global Defaults - avoids those annoying warnings generated by bind()
#
MobileNode set X_				0
MobileNode set Y_				0
MobileNode set Z_				0
MobileNode set speed_				0
MobileNode set position_update_interval_	0
MobileNode set bandwidth_			0	;# not used
MobileNode set delay_				0	;# not used
MobileNode set off_prune_			0	;# not used
MobileNode set off_CtrMcast_			0	;# not used

