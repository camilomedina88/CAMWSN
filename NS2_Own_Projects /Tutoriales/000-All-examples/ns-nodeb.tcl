# -*-	Mode:C++; c-basic-offset:8; tab-width:8; indent-tabs-mode:t -*- */

# By Pablo Martin and Paula Ballester,
# * Strathclyde University, Glasgow.
# * June, 2003.

# Copyright (c) 2003 Strathclyde University of Glasgow, Scotland.
# * All rights reserved.
# *
# * Redistribution and use in source and binary forms, with or without
# * modification, are permitted provided that the following conditions
# * are met:
# *
# * 1. Redistributions of source code and binary code must contain
# * the above copyright notice, this list of conditions and the following
# * disclaimer.
# *
# * 2. All advertising materials mentioning features or use of this software
# * must display the following acknowledgement:
# * This product includes software developed at Strathclyde University of
# * Glasgow, Scotland.
# *
# * 3. The name of the University may not be used to endorse or promote
# * products derived from this software without specific prior written
# * permission.
# * STRATHCLYDE UNIVERSITY OF GLASGOW, MAKES NO REPRESENTATIONS
# * CONCERNING EITHER THE MERCHANTABILITY OF THIS SOFTWARE OR THE
# * SUITABILITY OF THIS SOFTWARE FOR ANY PARTICULAR PURPOSE.  The software
# * is provided "as is" without express or implied warranty of any kind.
#
#
# Special NodeB node for UMTS simulations, for communicating between wired and
# wireless topologies in ns.

#
# The Node/MobileNode/NodeB class
#
# ======================================================================
Class Node/MobileNode/NodeB -superclass Node/MobileNode

Node/MobileNode/NodeB instproc init args {
	eval $self next $args
}

Node/MobileNode/NodeB instproc reset {} {
	$self instvar arptable_ nifs_ netif_ phy_ mac_ ifq_ ll_ imep_ rlc_
        for {set i 0} {$i < $nifs_} {incr i} {
		$netif_($i) reset
		$mac_($i) reset
		$ll_($i) reset
		$rlc_($i) reset
		$phy_($i) reset
		$ifq_($i) reset
		if { [info exists opt(imep)] && $opt(imep) == "ON" } {
			$imep_($i) reset
		}
	}
	if { $arptable_ != "" } {
		$arptable_ reset
	}
}

Node/MobileNode/NodeB instproc nodetype {} {
	return 2	;# 2 means "NodeB"
}

# The following setups up link layer, rlc layer, mac layer, network interface
# and physical layer structures for the mobile node.
#
Node/MobileNode/NodeB instproc add-interface { channel pmodel lltype rlctype mactype \
		phylayer qtype qlen iftype anttype inerrproc outerrproc fecproc} {
	$self instvar arptable_ nifs_ netif_ phy_ mac_ ifq_ rlc_ ll_ imep_ inerr_ outerr_ fec_

	set ns [Simulator instance]
	set imepflag [$ns imep-support]
	set t $nifs_
	incr nifs_

	set netif_($t)	[new $iftype]		;# interface
	set phy_($t)	[new $phylayer]		;# phy layer
	set mac_($t)	[new $mactype]		;# mac layer
	set ifq_($t)	[new $qtype]		;# interface queue
	set ll_($t)	[new $lltype]		;# link layer
	set rlc_($t)   [new $rlctype]		;# rlc layer

	set ant_($t)    [new $anttype]

	set inerr_($t) ""
	if {$inerrproc != ""} {
		set inerr_($t) [$inerrproc]
	}
	set outerr_($t) ""
	if {$outerrproc != ""} {
		set outerr_($t) [$outerrproc]
	}
	set fec_($t) ""
	if {$fecproc != ""} {
		set fec_($t) [$fecproc]
	}

	set namfp [$ns get-nam-traceall]
        if {$imepflag == "ON" } {
		# IMEP layer
		set imep_($t) [new Agent/IMEP [$self id]]
		set imep $imep_($t)
		set drpT [$self mobility-trace Drop "RTR"]
		if { $namfp != "" } {
			$drpT namattach $namfp
		}
		$imep drop-target $drpT
		$ns at 0.[$self id] "$imep_($t) start"   ;# start beacon timer
        }
	#
	# Local Variables
	#
	set nullAgent_ [$ns set nullAgent_]
	set netif $netif_($t)
	set phy $phy_($t)
	set mac $mac_($t)
	set ifq $ifq_($t)
	set ll $ll_($t)
	set rlc $rlc_($t)

	set inerr $inerr_($t)
	set outerr $outerr_($t)
	set fec $fec_($t)

	#
	# Initialize ARP table only once.
	#
	if { $arptable_ == "" } {
		set arptable_ [new ARPTable $self $mac]
		# FOR backward compatibility sake, hack only
		if {$imepflag != ""} {
			set drpT [$self mobility-trace Drop "IFQ"]
		} else {
			set drpT [cmu-trace Drop "IFQ" $self]
		}
		$arptable_ drop-target $drpT
		if { $namfp != "" } {
			$drpT namattach $namfp
		}
        }
	#
	# Link Layer
	#
	$ll arptable $arptable_
	$ll rlc $rlc
 	$ll ifq $ifq
	$ll mac $mac
	$ll phy $phy
	$ll down-target $ifq

	if {$imepflag == "ON" } {
		$imep recvtarget [$self entry]
		$imep sendtarget $ll
		$ll up-target $imep
        } else {
		$ll up-target [$self entry]
	}

	#
	# Interface Queue
	#
	$ifq target $rlc
	$ifq callback [$self entry]
	$ifq set limit_ $qlen
	if {$imepflag != ""} {
		set drpT [$self mobility-trace Drop "IFQ"]
	} else {
		set drpT [cmu-trace Drop "IFQ" $self]
        }
	$ifq drop-target $drpT
	if { $namfp != "" } {
		$drpT namattach $namfp
	}

	#
	# RLC
	#
	$rlc up-target $ll
	$rlc down-target $mac

	#
	# Mac Layer
	#
	$mac phy $phy
	$mac up-target $rlc
	$mac down-target $phy

	set god_ [God instance]
        if {$mactype == "Mac/802_11"} {
		$mac nodes [$god_ num_nodes]
	}

	#
	# Physical Layer
	#
	$phy netif $netif
	$phy ll $ll
	$phy mac $mac
	$phy up-target $mac
	$phy down-target $netif

	if {$outerr == "" && $fec == ""} {
		$phy down-target $netif
	} elseif {$outerr != "" && $fec == ""} {
		$phy down-target $outerr
		$outerr target $netif
	} elseif {$outerr == "" && $fec != ""} {
		$phy down-target $fec
		$fec down-target $netif
	} else {
		$phy down-target $fec
		$fec down-target $outerr
		$err target $netif
	}

	#
	# Network Interface
	#
	$netif channel $channel

	if {$inerr == "" && $fec == ""} {
		$netif up-target $phy
	} elseif {$inerr != "" && $fec == ""} {
		$netif up-target $inerr
		$inerr target $phy
	} elseif {$err == "" && $fec != ""} {
		$netif up-target $fec
		$fec up-target $phy
	} else {
		$netif up-target $inerr
		$inerr target $fec
		$fec up-target $phy
	}

	$netif propagation $pmodel	;# Propagation Model
	$netif node $self		;# Bind node <---> interface
	$netif antenna $ant_($t)

	$self ll $ll
	#
	# Physical Channel
	#
	$channel addif $netif

	# ============================================================

#	if { [Simulator set MacTrace_] == "ON" } {
#		#
#		# Trace RTS/CTS/ACK Packets
#		#
#		if {$imepflag != ""} {
#			set rcvT [$self mobility-trace Recv "MAC"]
#		} else {
#			set rcvT [cmu-trace Recv "MAC" $self]
#		}
#		$mac log-target $rcvT
#		if { $namfp != "" } {
#			$rcvT namattach $namfp
#		}
#		#
#		# Trace Sent Packets
#		#
#		if {$imepflag != ""} {
#			set sndT [$self mobility-trace Send "MAC"]
#		} else {
#			set sndT [cmu-trace Send "MAC" $self]
#		}
##		$sndT target [$mac down-target]
#		$mac down-target $sndT
#		if { $namfp != "" } {
#			$sndT namattach $namfp
#		}
#		#
#		# Trace Received Packets
#		#
#		if {$imepflag != ""} {
#			set rcvT [$self mobility-trace Recv "MAC"]
#		} else {
#			set rcvT [cmu-trace Recv "MAC" $self]
##		}
#		$rcvT target [$mac up-target]
#		$mac up-target $rcvT
#		if { $namfp != "" } {
#			$rcvT namattach $namfp
##		}
#		#
#		# Trace Dropped Packets
#		#
#		if {$imepflag != ""} {
#			set drpT [$self mobility-trace Drop "MAC"]
#		} else {
#			set drpT [cmu-trace Drop "MAC" $self]
#		}
##		$mac drop-target $drpT
#		if { $namfp != "" } {
#			$drpT namattach $namfp
#		}
#	} else {
#		$mac log-target [$ns set nullAgent_]
#		$mac drop-target [$ns set nullAgent_]
#	}
##
	# ============================================================

	if { [Simulator set PhyTrace_] == "ON" } {
		#
		# Trace RTS/CTS/ACK Packets
		#
		if {$imepflag != ""} {
			set rcvT [$self mobility-trace Recv "PHY"]
		} else {
			set rcvT [cmu-trace Recv "PHY" $self]
		}
		$phy log-target $rcvT
		if { $namfp != "" } {
			$rcvT namattach $namfp
		}
		#
		# Trace Sent Packets
		#
		if {$imepflag != ""} {
			set sndT [$self mobility-trace Send "PHY"]
		} else {
			set sndT [cmu-trace Send "PHY" $self]
		}
		$sndT target [$phy down-target]
		$phy down-target $sndT
		if { $namfp != "" } {
			$sndT namattach $namfp
		}
		#
		# Trace Received Packets
		#
		if {$imepflag != ""} {
			set rcvT [$self mobility-trace Recv "PHY"]
		} else {
			set rcvT [cmu-trace Recv "PHY" $self]
		}
		$rcvT target [$netif up-target]
		$netif up-target $rcvT
		if { $namfp != "" } {
			$rcvT namattach $namfp
		}
		#
		# Trace Dropped Packets
		#
		if {$imepflag != ""} {
			set drpT [$self mobility-trace Drop "PHY"]
		} else {
			set drpT [cmu-trace Drop "PHY" $self]
		}
		$phy drop-target $drpT
		if { $namfp != "" } {
			$drpT namattach $namfp
		}
	} else {
		$phy log-target [$ns set nullAgent_]
		$phy drop-target [$ns set nullAgent_]
	}

	# ============================================================

	$self addif $netif
	$ll on	;#
}
