#
#  Copyright (c) 2003 Communication Networks Lab, Simon Fraser University.
#  All rights reserved.
# 
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  Authors: Tony Dongliang Feng <tdfeng@cs.sfu.ca>.
# 
  

RtModule/BGP instproc register { node } {
	$self next $node
	$self instvar classifier_ bgp_agent_ tcp_master_

 ## create a new IPv4 Classifier and connect it to the entry_
 	set classifier_ [new Classifier/IPv4]
 	$node install-entry $self $classifier_ 0

	## create the dmux_ if necessary
 	set dmux_ [$node demux]
	if { $dmux_ == "" } {
		# please refer to ns-node.tcl attach{}
		set dmux_ [new Classifier/Port]
		$node set dmux_ $dmux_ 
		$classifier_ addroute [$node set address_] $dmux_		
	}
	
	## create the tcp master	
	set tcp_master_ [new Agent/TcpMaster]
	$tcp_master_ set node_ $node

	## create the bgp agent for this node
 	set bgp_agent_ [new Agent/rtProto/BGP $node] 
	$bgp_agent_ set node_ $node
 	$bgp_agent_ set tcp_master_ $tcp_master_

  ## propergate member variables of the bgp agent to c++
	$bgp_agent_ bind-tcp-master $tcp_master_   
  	$bgp_agent_ bind-classifier $classifier_
        $bgp_agent_ bind-node $node
	$bgp_agent_ set as_num_ [$node set as_num_]

	## schedule the bgp agent to configure itself 
  ## at the beginning of simulation
 	[Simulator instance] at 0.0 "$bgp_agent_ conf"
}

##
#  return the bgp agent of this node
##
RtModule/BGP instproc get-bgp-agent { } {
	$self instvar bgp_agent_
	set bgp_agent_
}

##
#  add the specified route to the IPv4 classifier
##
RtModule/BGP instproc add-route { dst target } {
  $self instvar classifier_

  set a [split $dst "/"]
  set net [lindex $a 0]
  set mask [lindex $a 1]
  if { $mask == "" } {
  	# no mask, dst should be int value instead of ipv4 dot-quad format,
  	# it's called by rtObject or routeLogic
	  $classifier_ addroute $net $target
  } else {
	  # with mask, dst should be dot-quad format
  	$classifier_ addroute $net $mask $target
  }
}

RtModule/BGP instproc route-notify { module } {
}

##
#  parse a string in the format of AS:IPv4_addr 
##
Node instproc parse-addr { str } {
  $self instvar as_num_ address_
  set a [split $str ":"]
  $self set as_num_ [lindex $a 0]
  $self cmd as $as_num_  # Propagate as_num_ into C++ space
  set address_ [$self strtoaddr [lindex $a 1]]
}

##
# convert a IPv4 address to a int value
##
Node instproc strtoaddr { str } {
  set a [split $str "."]
  set value 0
  for {set i 0} {$i < 4 } {incr i} {
	set value [expr [expr $value * 256] + [lindex $a $i]]
  } 
  return $value
}

##
#  return the bgp agent of this node
##
Node instproc get-bgp-agent { } {
        [$self get-module BGP] get-bgp-agent
}
