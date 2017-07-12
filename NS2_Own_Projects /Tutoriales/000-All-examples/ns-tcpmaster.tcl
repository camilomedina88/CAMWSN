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
 
Agent/TcpMaster instproc init {} {
	$self next
  	$self instvar node_ 
}

##
# create the listening tcp agent and other necessary components.
##
Agent/TcpMaster instproc  Open-Server {s_port} {
  	$self instvar node_ 

	## create a new listening tcp agent.
   	set listen_tcp [new Agent/TCP/FullTcp]
	$listen_tcp set agent_addr_ [$node_ set address_]
	$listen_tcp set agent_port_ $s_port
  	
	## create a new source classifier and install the listening 
        ## tcp agent to slot corresponding to 0/32.  	
	set src_clr [new Classifier/IPv4/Src]
	set net 0
	set prefix 32
	$src_clr addroute $net $prefix $listen_tcp

	## install the source classifier into the dmux_.
 	set dmux_ [$node_ demux]
	$dmux_ install $s_port $src_clr

  	return $listen_tcp
}

##
# create a new out-going tcp agent.
##
Agent/TcpMaster instproc  New-OutGoing {d_port d_ip} {
	$self instvar node_ 
	
	## initialize a new tcp agent
	set new_tcp [new Agent/TCP/FullTcp]
	$new_tcp set node_ $node_
	$new_tcp set agent_addr_ [$node_ set address_]
	$new_tcp set dst_addr_ $d_ip
	$new_tcp set dst_port_ $d_port

	## install the new agent to dmux_ and hook it up to the entry_
	set dmux_ [$node_ demux]
	set slot [$dmux_ installNext $new_tcp]
	$new_tcp set agent_port_ $slot
	$new_tcp target [$node_ entry]

	return $new_tcp 
}

##
# create a new in-coming tcp agent.
##
Agent/TcpMaster instproc  New-InComing {s_port s_ip d_port} {
	$self instvar node_ inComing_

	## initialize a new tcp agent
	set new_tcp [new Agent/TCP/FullTcp]
	$new_tcp set node_ $node_
	$new_tcp set agent_addr_ [$node_ set address_]
	$new_tcp set agent_port_ $d_port
	$new_tcp set dst_addr_ $s_ip
	$new_tcp set dst_port_ $s_port
	$new_tcp target [$node_ entry]

	## get the dmux_ and src_clr
	set dmux_ [$node_ demux]
	set src_clr [$dmux_ set slots_($d_port)]

	## install the new agent into the source classifier
  	set net $s_ip
  	$src_clr addroute $net $new_tcp

  	return $new_tcp
}

##
# remove a already exited in-coming tcp agent 
##
Agent/TcpMaster instproc  Remove-InComing {s_ip d_port} {
	$self instvar node_ 
	set dmux_ [$node_ demux]
	set src_clr [$dmux_ set slots_($d_port)]
  	set net $s_ip  	
	set pref 32
  	$src_clr cmd delroute $net
}


