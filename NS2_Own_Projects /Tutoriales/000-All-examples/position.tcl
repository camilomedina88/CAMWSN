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

Simulator instproc position { args } {
    # To enable/disable the position module:
    # $ns_ node-config -position on/off
    foreach s $args {
        set s [string tolower $s]
        if { $s == "on" && [Node find-module "Module/Position"]=="" } {
            # enable module
            Node enable-module "Module/Position"
        } elseif { $s == "off" } {
            # disable module
            Node disable-module "Module/Position"
            Node disable-module "Module/Mobility" ;# requires position module
        } else {
            puts stderr "Simulator::position: Error -\
                         Use on/off to enable/disable the position module."
            exit 1
        }
    }
}

#
# Module/Position class
#

Module/Position instproc reset { } {
    # do nothing
}

# Attach the position module to the specified node
# Called by Node::register-module (ns-node.tcl)
Module/Position instproc register { node } {
    $self cmd register $node
    [Simulator instance] at-now "$self cmd is-set"
}

#
# Node class extensions
#

# Positioning instproc set-x/y/z/position are defined at the node level and 
# only forward the call to the Module/Position commands with the same name
# The reason of the definition of these commands at the Node level is purely
# practical to avoid the need of an explicit reference to the position module 
# in scenario scripts.

Node instproc set-x { val } {
    set module [eval $self cmd position-module]
    if {$module==""} {
        puts stderr "Node::set-x: Error -\
                     Cannot set node position. No position module." 
        exit 1
    }
    $module cmd set-x $val
}

Node instproc set-y { val } {
    set module [eval $self cmd position-module]
    if {$module==""} {
        puts stderr "Node::set-y: Error - \
                     Cannot set node position. No position module." 
        exit 1
    }
    $module cmd set-y $val
}

Node instproc set-z { val } {
    set module [eval $self cmd position-module]
    if {$module==""} {
        puts stderr "Node::set-z: Error -\
                     Cannot set node position. No position module." 
        exit 1
    }
    $module cmd set-z $val
}

Node instproc set-position { x y { z 0.0 } } {
    set module [eval $self cmd position-module]
    if {$module==""} {
        puts stderr "Node::set-position: Error -\
                     Cannot set node position. No position module." 
        exit 1
    }
    $module cmd set-position $x $y $z
}

Node instproc set-position-logger { logger } {
    set module [eval $self cmd position-module]
    if {$module==""} {
        puts stderr "Node::set-position-logger: Error - No position module." 
        exit 1
    }
    $module cmd set-logger $logger
}

