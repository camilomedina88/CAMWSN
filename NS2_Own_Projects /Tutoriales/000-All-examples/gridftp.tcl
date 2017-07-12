# gridftp application
Class Application/GridFTP -superclass Application

Application/GridFTP instproc init {args} {
  $self instvar parallel
  $self instvar ratio
  $self instvar bandwith
  set parallel 4
#$self setParallel $parallel
  set bandwith 1.0
  set ratio 1:1:1:1
#  $self setRatio $ratio
  eval $self next $args
}

Application/GridFTP instproc setParallel {args} {
    $self instvar parallel
    set parallel $args
    for {set i 0} {$i < $parallel} {incr i} {
        $self set tcp($i) [new Agent/TCP]
        [$self set tcp($i)] set fid_ [expr $i + 1]
        [$self set tcp($i)] set class_ [expr $i + 1]
        $self set ftp($i) [new Application/FTP]
        [$self set ftp($i)] attach-agent [$self set tcp($i)]
    }
}

Application/GridFTP instproc setBandwith {args} {
    $self instvar parallel
    $self instvar bandwith
    set bandwith $args
    for {set i 0} {$i < $parallel} {incr i} {
        set temp [expr [$self set rates($i)] * $bandwith]
        [$self set ftp($i)] set rate_ [append $temp "Mb"]
    }
}

Application/GridFTP instproc setRatio {args} {
    $self instvar parallel
    set r [split $args {:}]
        set t 0;
    for {set i 0} {$i < $parallel} {incr i} {
        incr t [lindex $r $i]
    }
    for {set i 0} {$i < $parallel} {incr i} {
        set numRate [expr [lindex $r $i] * 0.1 * 10 /$t]
        $self set rates($i) $numRate
    }
}

Application/GridFTP instproc getRatio {} {
    $self instvar parallel
    for {set i 0} {$i < $parallel} {incr i} {
        set x [$self set ftp($i)]
    }
}


Application/GridFTP instproc setPacketSize {args} {
    $self instvar parallel
    for {set i 0} {$i < $parallel} {incr i} {
        [$self set tcp($i)] set packetSize_ $args
    }
}

Application/GridFTP instproc setWindows {args} {
    $self instvar parallel
    for {set i 0} {$i < $parallel} {incr i} {
        [$self set tcp($i)] set windows_ $args
    }
}

Application/GridFTP instproc start {} {
    $self instvar parallel
    for {set i 0} {$i < $parallel} {incr i} {
        [$self set ftp($i)] start 
    }
}

Application/GridFTP instproc stop {} {
    $self instvar parallel
    for {set i 0} {$i < $parallel} {incr i} {
        [$self set ftp($i)] stop
    }
}

Application/GridFTP instproc send {nbytes} {
    $self instvar parallel
    for {set i 0} {$i < $parallel} {incr i} {
        set temp [expr [$self set rates($i)] * $nbytes]
        [$self set ftp($i)] send $temp
    }
}

# For sending packets.  Sends $pktcnt packets.
Application/GridFTP instproc produce { pktcnt } {
    $self instvar parallel
    for {set i 0} {$i < $parallel} {incr i} {
        set temp [expr [$self set rates($i)] * $pktcnt]
        [$self set ftp($i)] produce $temp
    }
}

# For sending packets.  Sends $pktcnt more packets.
Application/FTP instproc producemore { pktcnt } {
    $self instvar parallel
    for {set i 0} {$i < $parallel} {incr i} {
        set temp [expr [$self set rates($i)] * $pktcnt]
        [$self set ftp($i)] producemore $temp
    }
}

# gridftp sink agent
Class Agent/GridFTPSink -superclass Agent/TCPSink

Agent/GridFTPSink instproc init {args} {
  $self instvar parallel
  set parallel 4  
  $self setParallel $parallel
  eval $self next $args
}

Agent/GridFTPSink instproc setParallel {args} {
    $self instvar parallel
    set parallel $args
    for {set i 0} {$i < $args} {incr i} {
        $self set tcpsink($i) [new Agent/TCPSink]
    }
}

Agent/GridFTPSink instproc setPacketSize {args} {
    $self instvar parallel
    for {set i 0} {$i < $parallel} {incr i} {
        [$self set tcpsink($i)] set packetSize_ $args
    }
}

Agent/GridFTPSink instproc getPacketSize {} {
    $self instvar parallel
        puts $parallel
    for {set i 0} {$i < $parallel} {incr i} {
        puts [[$self set tcpsink($i)] set packetSize_]
    }
}

# override the method Simulator attach-agent
Simulator instproc attach-agent { node agent } {
    if {[$agent info class] == "Application/GridFTP"} then {
        set para [$agent set parallel]
        for {set i 0} {$i < $para} {incr i} {
            $node attach [$agent set tcp($i)]
        }
        return
    }

    if {[$agent info class] == "Agent/GridFTPSink"} then {
        set para [$agent set parallel]
        for {set i 0} {$i < $para} {incr i} {
            $node attach [$agent set tcpsink($i)]
        }
        return
    }
	$node attach $agent
	# $agent set nodeid_ [$node id]

        # Armando L. Caro Jr. <acaro@@cis,udel,edu> 10/22/2001 
	#
	# list of tuples (addr, port)
	# This is NEEDED so that single homed agents can play with multihomed
	# ones!
	# multihoming only for SCTP agents -Padma H.
	if {[lindex [split [$agent info class] "/"] 1] == "SCTP"} {
		$agent instvar multihome_bindings_
		set binding_ {}
		set addr [$agent set agent_addr_]
		set port [$agent set agent_port_]
		lappend binding_ $addr
		lappend binding_ $port
		lappend multihome_bindings_ $binding_
	}
}

# override the method Simulator connect
Simulator instproc connect {src dst} {
    if {[$src info class] == "Application/GridFTP" && [$dst info class] == "Agent/GridFTPSink"} then {
        set para1 [$src set parallel]
        set para2 [$dst set parallel]
        if { $para1 != $para2 } {
            puts "[Error]The src's parallel must equel the dst's parallel."
        }
        for {set i 0} {$i < $para1} {incr i} {
            set src1 [$src set tcp($i)]
            set dst1 [$dst set tcpsink($i)]
    	    $self instvar conn_ nconn_ sflows_ nsflows_ useasim_
	        $self simplex-connect $src1 $dst1
        	$self simplex-connect $dst1 $src1
 
	        # Debo
        	if {$useasim_ == 1} {
	        	set sid [$src nodeid]
	        	set sport [$src set agent_port_]
		        set did [$dst nodeid]
		        set dport [$dst set agent_port_]
		
		        if {[lindex [split [$src info class] "/"] 1] == "TCP"} {
			        lappend conn_ $sid:$did:$sport:$dport
			        incr nconn_
		        }
	        }
       }
        return
    }


	$self instvar conn_ nconn_ sflows_ nsflows_ useasim_

        # Armando L. Caro Jr. <acaro@@cis,udel,edu>
	# does the agent type support multihoming??
	# @@@ do we need to worry about $useasim_ below?? (wasn't in 2.1b8)
    	if {[lindex [split [$src info class] "/"] 1] == "SCTP"} {
    		$self multihome-connect $src $dst
    	}

	$self simplex-connect $src $dst
	$self simplex-connect $dst $src


	# Debo

	if {$useasim_ == 1} {
		set sid [$src nodeid]
		set sport [$src set agent_port_]
		set did [$dst nodeid]
		set dport [$dst set agent_port_]
		
		if {[lindex [split [$src info class] "/"] 1] == "TCP"} {
			lappend conn_ $sid:$did:$sport:$dport
			incr nconn_
			# set $nconn_ [expr $nconn_ + 1]
			# puts "Set a connection with id $nconn_ between $sid and $did"
		}
	}

	return $src
}
