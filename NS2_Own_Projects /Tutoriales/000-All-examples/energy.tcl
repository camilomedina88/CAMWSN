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

Simulator instproc energy { args } {
    # To enable/disable the mobility module:
    # $ns_ node-config -mobility on/off
    foreach s $args {
	set s [string tolower $s]
	if { $s == "on" && [Node find-module "Module/Energy"]=="" } {
	    # enable module
	    Node enable-module "Module/Energy"
	} elseif { $s == "off" } {
	    # disable module
	    Node disable-module "Module/Energy"
	} else {
            puts stderr "Simulator::energy: Error -\
                         Use on/off to enable/disable the mobility module."
            exit 1
        }
    }
    # The energy module is not fully implemented yet 
    # so cannot be use as it for now.
    # Remove the 2 lines below to enable the energy-module is functional
    puts stderr "Simulator::energy: Error -\
                 Energy module is not implemented."
    exit
}

# energy-config is the API to configure energy modules in scenario scripts 
# usage: <Simulator instance> energy-config <option> <value>
# available options are :
#        -energy-model
#        -initial-energy
#        -level1
#        -level2
#        -rx-power
#        -tx-power
#        -idle-power
#        -sleep-power
#        -sleep-time
#        -transition-power
#        -transition-time
#        -trace
# Default values are defined in q2s_tcl/default.tcl
Simulator instproc energy-config args {
    eval Module/Energy init-vars $args
}

#
# Module/Energy class
#

# Called by Simulator::mobility-config (see above)
# Reads <option,value> tuples and call the corresponding static proc.
Module/Energy proc init-vars { args } {
    set flag 0
    for {} {$args != ""} {set args [lrange $args 2 end]} {
        set key [lindex $args 0]
        set val [lindex $args 1]
        if ![string match {-[A-z]*} $key] {
            puts stderr "Module/Energy::init-vars: Error -\
                         Invalid option ($key)."
            set flag 1
            continue
        }
        set opt [string range $key 1 end]
        if {$val == ""} {
            puts stderr "Module/Energy::init-vars: Error -\
                         Option '$opt' ignored (no value supplied)."
            continue
        }
        if { [Module/Energy info commands $opt] != "" } {
            Module/Energy $opt $val
            continue
        }
        puts stderr "Module/Energy::init-vars: Error -\ 
                     Invalid option (-$opt)."
        set flag 1
    }
    if $flag {
        exit 1
    }
}

Module/Energy proc energy-model { val } { 
    Module/Energy set config_(energy-model) $val
}

Module/Energy proc initial-energy { val } { 
    Module/Energy set config_(initial-energy) $val
}

Module/Energy proc level1 { val } { 
    Module/Energy set config_(level1) $val
}

Module/Energy proc level2 { val } { 
    Module/Energy set config_(level2) $val
}

Module/Energy proc rx-power { val } { 
    Module/Energy set config_(rx-power) $val
}

Module/Energy proc tx-power { val } { 
    Module/Energy set config_(tx-power) $val
}

Module/Energy proc idle-power { val } { 
    Module/Energy set config_(idle-power) $val
}

Module/Energy proc sleep-power { val } { 
    Module/Energy set config_(sleep-power) $val
}

Module/Energy proc sleep-time { val } { 
    Module/Energy set config_(sleep-time) $val
}

Module/Energy proc transition-power { val } { 
    Module/Energy set config_(transition-power) $val
}

Module/Energy proc transition-time { val } { 
    Module/Energy set config_(transition-time) $val
}

Module/Energy proc trace { val } {
    set val [string tolower $val]
    if { $val=="on" || $val=="off" } {
        Module/Energy set config_(trace) $val
    } else {
        puts stderr "Module/Energy::trace: Error -\
                     Invalid value for -trace ($val)."
       exit 1
    }
}

# Set WirelessPhy energy parameters
Module/Energy proc set-energy-parameters { phy } {
    if {[Module/Energy set config_(tx-power)]!=""} { 
        $phy setTxPower [Module/Energy set config_(tx-power)]
    }
    if {[Module/Energy set config_(rx-power)]!=""} {
        $phy setRxPower [Module/Energy set config_(rx-power)]
    }
    if {[Module/Energy set config_(idle-power)]!=""} {
        $phy setIdlePower [Module/Energy set energy-param(idle-power)]
    }
    if {[Module/Energy set config_(sleep-power)]!=""} {
        $phy setSleepPower [Module/Energy set energy-param(sleep-power)]
    }
    if {[Module/Energy set config_(sleep-time)]!=""} {
        $phy setSleepTime [Module/Energy set energy-param(sleep-time)]
    }
    if {[Module/Energy set config_(transition-power)]!=""} {
        $phy setTransitionPower \
            [Module/Energy set config_(transition-power)]
    }
    if {[Module/Energy set config_(transition-time)]!=""} {
        $phy setTransitionTime \
            [Module/Energy set config_(transition-time)]
    }
}

# Constructor
# Called by Node::mk-default-classifier (ns-node.tcl) at the creation of a node
Module/Energy instproc init {} {
    if {[Module/Energy set config_(initial-energy)]==""} {
        puts stderr "Module/Energy::init: Error -\
                     Cannot be initialized (initial energy must be provided)."
        exit 1
    }
    $self next
    if {[Module/Energy set config_(energy-trace)]=="on"} {
        $self add-trace
        $ns at-now "$self cmd trace-energy"
    }
}

Module/Energy instproc reset { } {
    # do nothing
}

# Attach the energy module to the specified node
# Called by Node::register-module (ns-node.tcl)
Module/Energy instproc register { node } {
    $self cmd register $args
    $self cmd add-energy-model [new \
        [Module/Energy set config_(energy-model)] \
        [$self node] \
        [Module/Energy set config_(initial-energy)] \
        [Module/Energy set config_(level1)] \
        [Module/Energy set config_(level2)]
}

# Creates a BaseTrace object for node energy tracing ('E' lines).
# A reference to this object si kept in C++ (trace_ attribute in 
# EnergyModule)
Module/Energy instproc add-trace { } {
    set ns [Simulator instance]
    set tracefd [$ns get-ns-traceall]
    if { $tracefd == "" } {
        puts stderr "Module/Energy::trace-energy: Error -\
                     Cannot trace energy. No trace file."
        return 
    }
    set T [new BaseTrace]
    $T attach $tracefd
    $ns add-trace $T
    $self set-trace $T
}

# set energy logger, if rate is given, the position of the node and energy
# will be logged at every rate seconds
Node instproc set-energy-logger { logger {rate ""} } {
    set module [eval $self cmd energy-module]
    if {$module==""} {
        puts stderr "Node::set-energy-logger: Error - No energy module." 
        exit 1
    }
    if { $rate != "" } {
        $module cmd set-energy-logger $logger $rate
    } else {
        $module cmd set-energy-logger $logger
    }
}
