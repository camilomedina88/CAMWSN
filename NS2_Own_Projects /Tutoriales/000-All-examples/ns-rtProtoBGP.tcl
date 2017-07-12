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

Agent/rtProto/BGP instproc init node {
	$self next $node 
	$self instvar connretry_interval_ masoi_ cluster_num bgp_id_ \
		cluster_num as_num_
}

##
#  set the bgp id 
##
Agent/rtProto/BGP instproc bgp-id { bi } {	
	$self instvar node_ bgp_id_ 
	$self set bgp_id_ [$node_ strtoaddr $bi]
}

##
#  network command, 
#  which will cause the bgp agent to advertise the prefix of ipa
##
Agent/rtProto/BGP instproc network { ipa } {
	$self cmd network $ipa
}

##
#  set the cluster id 
##
Agent/rtProto/BGP instproc cluster-id { c_id } {
	$self instvar cluster_num
	$self set cluster_num $c_id
}

##
#  set the connect retry interval
##
Agent/rtProto/BGP instproc connretry_time { connretry_time } {
	$self instvar connretry_interval_
	$self set connretry_interval_ $connretry_time
}

##
#  set the min_as_orig_time
##
Agent/rtProto/BGP instproc min_as_orig_time { masoi } {
	$self instvar masoi_
	$self set masoi_ $masoi
}

##
#  enable auto-config
##
Agent/rtProto/BGP instproc set-auto-config { } {
	$self instvar auto_config_
	$self set auto_config_ true
} 

##
#  neighbor command
##

Agent/rtProto/BGP instproc neighbor {ipaddress command {value ""}} {
	$self instvar nbs_ as_num_ node_

	set a [split $ipaddress "."]
 if { [lindex $a 1] == "" } {
	 	## ipaddress is int value
		set ipaddr $ipaddress
	} else {
		## ipaddress is in Dotted-Quad format
		set ipaddr [$node_ strtoaddr $ipaddress]
	}
 
	if {![info exists nbs_($ipaddr)]} {
		#new peer-entry
		set return_ipaddr [$node_ set address_]
		set peer [new Agent/PeerEntry $ipaddr $return_ipaddr]
		set nbs_($ipaddr) $peer
		$self cmd new-peer $peer
	} else {
		set peer $nbs_($ipaddr)
	}

	switch $command {
		remote-as {
			$peer set as_num_ $value
			if { [$peer set as_num_] == [$node_ set as_num_] } {
        			$peer set-internal
      			} else {
        			$peer set-external
      			}
			#reture the peer to this command
			set peer
		}
		route-reflector-client {
			$self set-reflector       			
       			$peer set-client			
		}
		hold-time {
			$peer set hold_time_ $value
		}
		keep-alive-time {
			$peer set keep_alive_interval_ $value
		}
		mrai {
			$peer set mrai_ $value
		}
    		route-reflector-client {
      			$peer set-client
    		}  
		default {
			puts "Unknown sub-command $command for bgp-agent neighbor"
			exit 1
		}
	}
}

##
#  create a new peer entry
##     
Agent/rtProto/BGP instproc new-peer { ipaddr return_ipaddr } {
	new Agent/PeerEntry $ipaddr $return_ipaddr
}

