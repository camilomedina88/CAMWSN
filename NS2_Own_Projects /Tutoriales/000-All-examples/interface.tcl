# Copyright (c) 2008 Q2S NTNU, Trondheim, Norway
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation;
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
# Author: Laurent Paquereau <laurent.paquereau@q2s.ntnu.no>
#

#
# Simulator class extensions
#

# interface-config is the API to configure network interface stacks 
# (at network layer and below)
# <Simulator instance> interface-config <option> <value>
# available options are :
#        -phy
#        -mac
#        -ifq
#        -ifq-length
#        -ll
#        -antenna
#        -channel
#        -propagation
#        -net-trace
#        -mac-trace
#        -phy-trace
#        -ifq-trace
#        -eot-trace
#        -in-error
#        -out-error
# Default values are defined in q2s_tcl/default.tcl
Simulator instproc interface-config args {
    eval NetworkInterface2 init-vars $args
}

#
# NetworkInterface2 class
#

# Called by Simulator::interface-config (see above)
# Reads <option,value> tuples and call the corresponding static proc.
NetworkInterface2 proc init-vars { args } {
    set flag 0
    for {} {$args != ""} {set args [lrange $args 2 end]} {
        set key [lindex $args 0]
        set val [lindex $args 1]
        if ![string match {-[A-z]*} $key] {
            puts stderr "NetworkInterface2::init-vars: Error -\
                         Invalid option ($key)."
            set flag 1
            continue
        }
        set opt [string range $key 1 end]
        if {$val == ""} {
            puts stderr "NetworkInterface2::init-vars: Error -\
                         Option '$opt' ignored (no value supplied)."
            continue
        }
        if { [NetworkInterface2/FullStack info commands $opt] != "" } {
          NetworkInterface2/FullStack $opt $val
          continue
        }
        if { [NetworkInterface2 info commands $opt] != "" } {
          NetworkInterface2 $opt $val
          continue
        }
        puts stderr "NetworkInterface2::init-vars: Error -\
                     Invalid option (-$opt)."
        set flag 1
    }
    if $flag {
        exit 1
    }

}

NetworkInterface2 proc net-trace { val } {
    set val [string tolower $val]
    if { $val=="on" || $val=="off" } {
        NetworkInterface2 set config_(net-trace) $val
    } else {
        puts stderr "NetworkInterface2::net-trace: Error -\
                     Invalid value for -net-trace ($val)."
        exit 1
    }
}


# returns class name corresponding to the given interface type
# type should be a NetworkInterface2 or a NetworkInterface2/FullStack
NetworkInterface2 proc get-classname { type } {
    if { [catch {NetworkInterface2/$type info heritage}]==0 } {
        return NetworkInterface2/$type
    } elseif { [catch {NetworkInterface2/FullStack/$type info heritage}]==0 } {
        return NetworkInterface2/FullStack/$type
    }
	puts stderr "Error: Invalid network interface type ($type)."
	exit 1
}

NetworkInterface2 instproc add-net-tracer { } {
    set ns [Simulator instance]
    set nam [$ns get-nam-traceall]
    set net_trace [NetworkInterface2 set config_(net-trace)]
    if {$net_trace=="on"} {
	# create tracer objects
        set sendtarget [$self add-tracer Net Send]
        set recvtarget [$self add-tracer Net Recv]
        # insert tracer objects in the stack
        $recvtarget target [$self up-target]
        $self up-target $recvtarget
        $sendtarget target [$self down-target]
        $self down-target $sendtarget
    }
    if {$net_trace=="on" || $nam!=""} {
        # create tracer object
        set droptarget [$self add-tracer Net Drop $net_trace $nam]
        # set drop target
        $self drop-target $droptarget
    }
}

NetworkInterface2/PointToPoint instproc add-net-tracer { } {
    set ns [Simulator instance]
    set nam [$ns get-nam-traceall]
    set net_trace [NetworkInterface2 set config_(net-trace)]
    if {[$self down-target]==""} {
        if {$net_trace=="on"} {
            # create tracer object
            set recvtarget [$self add-tracer Net Recv]
            # insert tracer object in the stack
            $recvtarget target [$self up-target]
            $self up-target $recvtarget
        }
        if {$net_trace=="on" || $nam!=""} {
            # create tracer object
            set droptarget [$self add-tracer Net Drop $net_trace $nam]
            # set drop target
            $self drop-target $droptarget
        }
    } elseif {$net_trace=="on"} {
        set sendtarget [$self add-tracer Net Send]
        $sendtarget target [$self down-target]
        $self down-target $sendtarget
    }
}

# Create and returns a tracer object of the specified type (level,type)
# Extra parameters are needed if the tracer may also be used for nam-tracing
# (mac level or/and drop type):
#     cfg: is the trace explicitely turn on
#     nam: ns get-namtrace-all
NetworkInterface2 instproc add-tracer { level 
  type {cfg "on"}  {nam ""}} {
    set ns [Simulator instance]
    set tracefd [$ns get-ns-traceall]
    if { $tracefd == ""  && $cfg=="on" } {
        puts stderr "NetworkInterface2/FullStack::add-tracer: Error -\
                     Cannot add tracer. No trace file."
        exit 1
    }
    set T [new Tracer/$level/$type $self]
    if { $cfg == "on" } {
        # a trace is to be written, attach the trace file to the tracer object
        $T attach $tracefd
    }
    if { $nam != "" } {
        # a NAM-trace is to be written, attach the nam file 
        $T namattach $nam
    }
    $ns add-trace $T
    return $T
}

#
# NetworkInterface2/FullStack class
#

NetworkInterface2/FullStack proc phy { val } {
    NetworkInterface2/FullStack set config_(phy) $val
}

NetworkInterface2/FullStack proc mac { val } {
    NetworkInterface2/FullStack set config_(mac) $val
}

NetworkInterface2/FullStack proc ifq { val } {
    NetworkInterface2/FullStack set config_(ifq) $val
}

NetworkInterface2/FullStack proc ifq-length { val } {
    NetworkInterface2/FullStack set config_(ifq-length) $val
}

NetworkInterface2/FullStack proc ll { val } {
    NetworkInterface2/FullStack set config_(ll) $val
}

NetworkInterface2/FullStack proc antenna { val } {
    NetworkInterface2/FullStack set config_(antenna) $val
}

NetworkInterface2/FullStack proc channel { val } {
    if { ![isObject? $val] || ![$val info class Channel] } {
	puts stderr "Error - interface-config -channel value should be a\
                     Channel object"
	exit 1
    }
    NetworkInterface2/FullStack set config_(channel) $val
}

NetworkInterface2/FullStack proc propagation { val } {
    if { ![isObject? $val] || ![$val info class Propagation] } {
	puts stderr "Error - interface-config -propagation value should be a\
                     Propagation object"
	exit 1
    }
    NetworkInterface2/FullStack set config_(propagation) $val
}

NetworkInterface2/FullStack proc mac-trace { val } {
    set val [string tolower $val]
    if { $val=="on" || $val=="off" } {
        NetworkInterface2/FullStack set config_(mac-trace) $val
    } else {
        puts stderr "NetworkInterface2/FullStack::mac-trace: Error -\
                     Invalid value for -mac-trace ($val)."
        exit 1
    }
}


NetworkInterface2/FullStack proc phy-trace { val } {
    set val [string tolower $val]
    if { $val=="on" || $val=="off" } {
        NetworkInterface2/FullStack set config_(phy-trace) $val
    } else {
        puts stderr "NetworkInterface2/FullStack::phy-trace: Error -\
                     Invalid value for -phy-trace ($val)."
        exit 1
    }
}

NetworkInterface2/FullStack proc ifq-trace { val } { 
    set val [string tolower $val]
    if { $val=="on" || $val=="off" } {
        NetworkInterface2/FullStack set config_(ifq-trace) $val
    } else {
        puts stderr "NetworkInterface2/FullStack::ifq-trace: Error -\
                     Invalid value for -ifq-trace ($val)."
        exit 1
    }
}

NetworkInterface2/FullStack proc eot-trace { val } { 
    set val [string tolower $val]
    if { $val=="on" || $val=="off" } {
        NetworkInterface2/FullStack set config_(eot-trace) $
    } else {
        puts stderr "NetworkInterface2/FullStack::eot-trace: Error -\
                     Invalid value for -eot-trace ($val)."
        exit 1
    }
}

NetworkInterface2/FullStack proc in-error { val } {
    if { ![isObject? $val] || ![$val info class ErrorModel] } {
        puts stderr "Error - interface-config -in-error value should be an\
                     ErrorModel object"
        exit 1
    }
    NetworkInterface2/FullStack set config_(in-error) $val
}

NetworkInterface2/FullStack proc out-error { val } {
    if { ![isObject? $val] || ![$val info class ErrorModel] } {
        puts stderr "Error - interface-config -out-error value should be an\
                     ErrorModel object"
        exit 1
    }
    NetworkInterface2/FullStack set config_(out-error) $val
}

NetworkInterface2/FullStack instproc check-config { } {
     if {[NetworkInterface2/FullStack set config_(phy)]==""} {
        puts stderr "NetworkInterface2/FullStack::check-config: Error -\
                     No physical layer type specified with interface-config."
        exit 1
    }
    if {[NetworkInterface2/FullStack set config_(mac)]==""} {
        puts stderr "NetworkInterface2/FullStack::check-config: Error -\
                     No mac layer type specified with interface-config."
        exit 1
    }
    if {[NetworkInterface2/FullStack set config_(ifq)]==""} {
        puts stderr "NetworkInterface2/FullStack::check-config: Error -\
                     No interface queue type specified with interface-config."
        exit 1
    }
    if {[NetworkInterface2/FullStack set config_(ll)]==""} {
        puts stderr "NetworkInterface2/FullStack::check-config: Error -\
                     No link layer type specified with interface-config."
        exit 1
    }
    if {[NetworkInterface2/FullStack set config_(channel)]==""} {
        puts stderr "NetworkInterface2/FullStack::check-config: Error -\
                     No channel object specified with interface-config."
        exit 1
    }
}

NetworkInterface2/FullStack instproc init { node } {
    # check the interface configuration
    $self check-config

    # pass call
    $self next $node

    # create stack objects
    # channel
    set channel [NetworkInterface2/FullStack set config_(channel)]
    # physical layer
    $self instvar phy_
    set phy_ [new [NetworkInterface2/FullStack set config_(phy)]]
    # mac layer
    set mac [new [NetworkInterface2/FullStack set config_(mac)]]
    # interface queue
    set ifq [new [NetworkInterface2/FullStack set config_(ifq)]]
    $ifq set limit_ [NetworkInterface2/FullStack set config_(ifq-length)]
    # ARP Table
    set arp_table [new ARPTable]
    # link layer
    set ll [new [NetworkInterface2/FullStack set config_(ll)]]
    # incoming error process
    set in_error [NetworkInterface2/FullStack set config_(in-error)]
    # outgoing error process
    set out_error [NetworkInterface2/FullStack set config_(out-error)]

    # build the stack
    $phy_ down-target $channel
    if {$in_error!=""} {
        $phy_ up-target $in_error
        $in_error target $mac
    } else {
        $phy_ up-target $mac
    }
    if {$out_error!=""} {
        $mac down-target $out_error
        $out_error target $phy_
    } else {
        $mac down-target $phy_
    }
    $mac up-target $ll
    $ifq target $mac
    $ll up-target $self    
    $ll down-target $ifq
    $self down-target $ll
    
    # set objects for the C++ shadow
    $self cmd set-channel $channel
    $self cmd set-phy $phy_
    $self cmd set-mac $mac
    $self cmd set-queue $ifq
    $self cmd set-ll $ll
    $self cmd set-arp-table $arp_table
    if {$in_error!=""} {
        $self cmd set-in-error $in_error
    }
    if {$out_error!=""} {
        $self cmd set-out-error $out_error
    }

    # add trace objects
    set ns [Simulator instance]
    set nam [$ns get-nam-traceall]
    set ifq_trace [NetworkInterface2/FullStack set config_(ifq-trace)]
    set mac_trace [NetworkInterface2/FullStack set config_(mac-trace)]
    set eot_trace [NetworkInterface2/FullStack set config_(eot-trace)]
    set phy_trace [NetworkInterface2/FullStack set config_(phy-trace)]
    if {$ifq_trace=="on" || $nam!=""} {
        # create tracer object
        set droptarget [$self add-tracer Ifq Drop $ifq_trace $nam]
        # set drop targets
        $ifq drop-target $droptarget
        $arp_table drop-target $droptarget
    }
    if {$mac_trace=="on" || $nam!=""} {
        # create tracer object for rts/cts/ack packets
        set recvtarget [$self add-tracer Mac Recv $mac_trace $nam]
        # set log-target
        $mac log-target $recvtarget
        # create tracer objects 
        set sendtarget [$self add-tracer Mac Send $mac_trace $nam]
        set recvtarget [$self add-tracer Mac Recv $mac_trace $nam]
        # insert tracer objects in stack
        $sendtarget target [$mac down-target]
        $mac down-target $sendtarget
        $recvtarget target [$mac up-target]
        $mac up-target $recvtarget
        # create tracer for dropped packets
        set droptarget [$self add-tracer Mac Drop $mac_trace $nam]
        # set drop target
        $mac drop-target $droptarget
    } else { ;# no trace
        $mac log-target [$ns nullagent]
        $mac drop-target [$ns nullagent]
    }
    if {$eot_trace=="on"} {
        # create tracer object
        set eottarget [$self add-tracer Mac Eot]
        # set eot target
        $mac eot-target $eottarget
    }
    if {$phy_trace=="on"} {
        # create tracer object
        set sendtarget [$self add-tracer Phy Send]
        # insert tracer object in the stack
        $sendtarget target [$phy_ down-target]
        $phy_ down-target $sendtarget
    }
    if {$phy_trace=="on" || $nam!=""} {
        # create tracer object
        set droptarget [$self add-tracer Phy Drop $phy_trace $nam]
        # set drop target
        $phy_ drop-target $droptarget
    }
}

#
# NetworkInterface2/FullStack/Wireless class
#

NetworkInterface2/FullStack/Wireless instproc init { node } {
    $self next $node
    $self instvar phy_
    $phy_ propagation [NetworkInterface2/FullStack set config_(propagation)]
    $phy_ antenna [new [NetworkInterface2/FullStack set config_(antenna)]]
}

NetworkInterface2/FullStack/Wireless instproc check-channel { } {
    set val [NetworkInterface2/FullStack set config_(channel)]
    # ensure that val is a Channel/Wireless object
    if [isObject? $val] {
	# $val is not an object
	puts stderr "Error - $val is not an object"
	exit 1
    }
    if {![$val info class Channel/Wireless]} {
	# $val is not an instance of Channel/Wireless:
	puts stderr "Error - $val is not a Channel/Wireless object"
	exit 1
    }
}
    
NetworkInterface2/FullStack/Wireless instproc check-config { } {
    $self next
    if {[NetworkInterface2/FullStack set config_(antenna)]==""} {
        puts stderr "NetworkInterface2/FullStack/Wireless::check-config: Error\
                     - No antenna type specified with interface-config."
        exit 1
    }
    if {[NetworkInterface2/FullStack set config_(propagation)]==""} {
        puts stderr "NetworkInterface2/FullStack/Wireless::check-config: Error\
                     - No propagation object specified with interface-config."
        exit 1
    }
    set channel [NetworkInterface2/FullStack set config_(channel)]
    if {$channel==""} {
        puts stderr "NetworkInterface2/FullStack/Wireless::check-config: Error\
                     - No channel object specified with interface-config."
        exit 1
    }
    if {![$channel info class Channel/Wireless]} {
	puts stderr "NetworkInterface2/FullStack/Wireless::check-config: Error\
                     - The channel specified with interface-config ($channel)\
                     is not a Channel/Wireless object."
	exit 1
    }
}
