# Basic Mobile IPv6 example without using ns-topoman
# Needs proc defined in file proc-mipv6-config.tcl

Agent/MIPv6/MN set bs_forwarding_     0       ; # 1 if forwarding from previous BS
################################################################
proc log-mn-movement_no_topo { } {
  global logtimer ns
  Class LogTimer -superclass Timer
  LogTimer instproc timeout {} {
	global mobile1_ mobile2_
	$mobile1_ log-movement
	$mobile2_ log-movement
        $self sched 1
  }
  set logtimer [new LogTimer]
  $logtimer sched 1
}

################################################################
# Create Topology
################################################################
proc create-my-topo {} {
  global ns opt topo mobile1_ mobile2_ cn_ mnn_nodes_

  # Create and define topography
  set topo        [new Topography]
  #   set prop        [new $opt(prop)]
  #   $prop topography $topo
  $topo load_flatgrid 800 800 

  # god is a necessary object when wireless is used
  # set to a value equal to the number of mobile nodes
  create-god 6

  # Call node-config
  $ns node-config \
        -addressType hierarchical \
 	-agentTrace ON \
 	-routerTrace ON 

  # Set NS Addressing
  AddrParams set domain_num_ 2 
  AddrParams set cluster_num_ {1 5}
  AddrParams set nodes_num_ {1 1 2 1 2 1}

  # Create Nodes
  set cn_ [create-router 0.0.0]
  set router_ [create-router 1.0.0]
  set bs1_ [create-base-station 1.1.0 1.0.0 200 200 0]
  set bs2_ [create-base-station 1.2.0 1.0.0 200 600 0]
  set bs3_ [create-base-station 1.3.0 1.0.0 600 200 0]
  set bs4_ [create-base-station 1.4.0 1.0.0 600 600 0]
	set mobile1_ [create-mobile 1.1.1 1.1.0 190 190 0 0 0.01]
	set mobile2_ [create-mobile 1.3.1 1.3.0 590 590 0 0 0.01]

	$mobile1_ setdest 210 610 4
	$mobile2_ setdest 610 610 0.28


  # Create Links
  $ns duplex-link $cn_ $router_ 100Mb 1.80ms DropTail
  $ns duplex-link $router_ $bs1_ 100Mb 1.80ms DropTail
  $ns duplex-link $router_ $bs2_ 100Mb 1.80ms DropTail

  display_ns_addr_domain
}

################################################################
# End of Simulation
################################################################
proc finish { } {
  global tracef ns namf opt mobile1_ mobile2_ cn_
  
  puts "Simulation finished" 
  # Dump the Binding Update List of MN and Binding Cache of HA
	[[$mobile1_ set ha_] set regagent_] dump
	[[$mobile2_ set ha_] set regagent_] dump
	[$cn_ set regagent_] dump
	[$mobile1_ set regagent_] dump
	[$mobile2_ set regagent_] dump

  $ns flush-trace
  flush $tracef
  close $tracef
  close $namf
  #puts "running nam with $opt(namfile) ... "
  #exec nam $opt(namfile) &
  exit 0
}


################################################################
# Main 
################################################################
proc main { } {
   global opt ns TOPOM namf n tracef mobile1_ mobile2_ cn_ 
   # Source Files
   # source set-def-options.tcl 
   # set BASEDIR to your own correct path
   set BASEDIR ../..
   source $BASEDIR/tcl/lib/proc-mipv6-config.tcl
   source $BASEDIR/tcl/lib/proc-tools.tcl
   source $BASEDIR/tcl/lib/proc-topo.tcl
   source $BASEDIR/tcl/lib/ns-topoman.tcl
   source $BASEDIR/tcl/lib/proc-mobi-global.tcl
   source $BASEDIR/tcl/lib/proc-mobi-config.tcl
   source $BASEDIR/tcl/mobility/timer.tcl

   set NAMF out.nam
   set TRACEF out.tr
   set INFOF out.info

   set opt(mactrace) ON
   set opt(NAM) 1 
   set opt(namfile) $NAMF
   set opt(stop) 100
   set opt(tracefile) $TRACEF
   
   #>--------------- Extract options from command line ---------------<
   #Getopt	; # Get option from the command line	
   #DisplayCommandLine
   
   #>---------------------- Simulator Settings ----------------------<
   set ns [new Simulator]
   #>------------------------ Open trace files ----------------------<
   exec rm -f $opt(tracefile)
   set tracef [open $opt(tracefile) w]
   #... dump the file
   $ns trace-all $tracef
    
   set namf [open $opt(namfile) w]
   $ns namtrace-all $namf

   #>------------- Protocol and Topology Settings -------------------<
   create-my-topo
   log-mn-movement_no_topo
   
   set-cbr
   # set-ping-int 0.1 $cn_ $mobile_ 10 $opt(stop)


   #>----------------------- Run Simulation -------------------------<
   $ns at $opt(stop) "finish"
   $ns run

   $ns dump-topology $namf
   close $namf
   #puts "running nam with $opt(namfile) ... "
   #exec nam $opt(namfile) &
}

proc set-cbr { } {
	global ns mobile1_ mobile2_
	set udp1 [new Agent/UDP]
	set udp2 [new Agent/UDP]
	$ns attach-agent $mobile1_ $udp1
	$ns attach-agent $mobile2_ $udp2

	set dst1 [new Agent/Null]
	set dst2 [new Agent/Null]
	$ns attach-agent $mobile2_ $dst1
	$ns attach-agent $mobile1_ $dst2
	$ns connect $udp1 $dst1
	$ns connect $udp2 $dst2

	set src1 [new Application/Traffic/CBR]
	set src2 [new Application/Traffic/CBR]
	$src1 set packetSize_ 500
	$src1 set rate_ 100k
	$src1 set interval_ 0.1
	$src1 attach-agent $udp1
	$src2 set packetSize_ 500
	$src2 set rate_ 50k
	$src2 set interval_ 0.1
	$src2 attach-agent $udp2
	$ns at 20.0 "$src1 start"
	$ns at 30.0 "$src2 start"
}

main
