#
# hwmp.tcl
# Copyright (C) 2008 by the Institute for Information Transmission Problems
# Originally written by Kirill V. Andreev <kirillano@yandex.ru> and Andrey I. Mazo <ahippo@yandex.ru>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# version 2, as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
#
#
# The copyright of this module includes the following
# linking-with-specific-other-licenses addition:
#
# In addition, as a special exception, the copyright holders of
# this module give you permission to combine (via static or
# dynamic linking) this module with free software programs or
# libraries that are released under the GNU LGPL and with code
# included in the standard release of ns-2 under the Apache 2.0
# license or under otherwise-compatible licenses with advertising
# requirements (or modified versions of such code, with unchanged
# license).  You may copy and distribute such a system following the
# terms of the GNU GPL for this module and the licenses of the
# other code concerned, provided that you include the source code of
# that other code when and as the GNU GPL requires distribution of
# source code.
#
# Note that people who make modified versions of this module
# are not obligated to grant this special exception for their
# modified versions; it is their choice whether to do so.  The GNU
# General Public License gives permission to release a modified
# version without this exception; this exception also makes it
# possible to release a modified version which carries forward this
# exception.
#
#

#
# $Id$
#



# ======================================================================
# Default Script Options
# ======================================================================

set opt(ragent)		Agent/rtProto/HWMP
#set opt(pos)		NONE

#if { $opt(pos) != "NONE" } {
#	puts "*** WARNING: HWMP using $opt(pos) position configuration..."
#}

# ======================================================================
Agent instproc init args {
        $self next $args
}       
Agent/rtProto instproc init args {
        $self next $args
}       
Agent/rtProto/HWMP instproc init args {
        $self next $args
}       

#Agent/rtProto/HWMP set sport_	0
#Agent/rtProto/HWMP set dport_	0

# ======================================================================

proc create-routing-agent { node id } {
	global ns_ ragent_ tracefd opt

	#
	#  Create the Routing Agent and attach it to port 255.
	#
	set ragent_($id) [new $opt(ragent) $id]
	set ragent $ragent_($id)
	$node attach $ragent 255

	$ragent if-queue [$node set ifq_(0)]	;# ifq between LL and MAC
	$ns_ at 0.$id "$ragent_($id) start"	;# start BEACON/HELLO Messages

	#
	# Drop Target (always on regardless of other tracing)
	#
	set drpT [cmu-trace Drop "RTR" $node]
	$ragent drop-target $drpT
	
	#
	# Log Target
	#
	set T [new Trace/Generic]
	$T target [$ns_ set nullAgent_]
	$T attach $tracefd
	$T set src_ $id
	$ragent log-target $T
}


proc create-mobile-node { id } {
	global ns_ chan prop topo tracefd opt node_
	global chan prop tracefd topo opt

	set node_($id) [new MobileNode]

	set node $node_($id)
	$node random-motion 0		;# disable random motion
	$node topography $topo

	#
	# This Trace Target is used to log changes in direction
	# and velocity for the mobile node.
	#
	set T [new Trace/Generic]
	$T target [$ns_ set nullAgent_]
	$T attach $tracefd
	$T set src_ $id
	$node log-target $T

	$node add-interface $chan $prop $opt(ll) $opt(mac)	\
		$opt(ifq) $opt(ifqlen) $opt(netif) $opt(ant)

	#
	# Create a Routing Agent for the Node
	#
	create-routing-agent $node $id

	# ============================================================

	if { $opt(pos) == "Box" } {

		set spacing 200
		set maxrow 3
		set col [expr ($id - 1) % $maxrow]
		set row [expr ($id - 1) / $maxrow]
		$node set X_ [expr $col * $spacing]
		$node set Y_ [expr $row * $spacing]
		$node set Z_ 0.0
		$node set speed_ 0.0

		$ns_ at 0.0 "$node_($id) start"

	} elseif { $opt(pos) == "Random" } {

		$node random-motion 1

		$ns_ at 0.0 "$node_($id) start"

	}
}

