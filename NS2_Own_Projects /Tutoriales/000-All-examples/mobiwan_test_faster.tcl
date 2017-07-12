# Basic Mobile IPv6 example without using ns-topoman
# Needs proc defined in file proc-mipv6-config.tcl

Agent/MIPv6/MN set bs_forwarding_     0       ; # 1 if forwarding from previous BS
################################################################
proc log-mn-movement_no_topo { } {
  global logtimer ns
  Class LogTimer -superclass Timer
  LogTimer instproc timeout {} {
 	global mobile_
        $mobile_ log-movement 
        $self sched 1 
  }
  set logtimer [new LogTimer]
  $logtimer sched 1  
}

################################################################
# Create Topology
################################################################
proc create-my-topo {} {
  global ns opt topo mobile_ cn_ mnn_nodes_

  # Create and define topography
  set topo        [new Topography]
  #   set prop        [new $opt(prop)]
  #   $prop topography $topo
  $topo load_flatgrid 800 800 

  # god is a necessary object when wireless is used
  # set to a value equal to the number of mobile nodes
  create-god 5 

  # Call node-config
  $ns node-config \
        -addressType hierarchical \
 	-agentTrace ON \
 	-routerTrace ON 

  # Set NS Addressing
  AddrParams set domain_num_ 2 
  AddrParams set cluster_num_ {1 5}
  AddrParams set nodes_num_ {1 1 3 1 1 1}

  # Create Nodes
  set cn_ [create-router 0.0.0]
  set router_ [create-router 1.0.0]
  set bs1_ [create-base-station 1.1.0 1.0.0 200 200 0]
  set bs2_ [create-base-station 1.2.0 1.0.0 200 600 0]
  set bs3_ [create-base-station 1.3.0 1.0.0 600 200 0]
  set bs4_ [create-base-station 1.4.0 1.0.0 600 600 0]
  set mobile_ [create-mobile 1.1.1 1.1.0 190 190 0 1 0.01]


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
  global tracef ns namf opt mobile_ cn_
  
  puts "Simulation finished" 
  # Dump the Binding Update List of MN and Binding Cache of HA
  [[$mobile_ set ha_] set regagent_] dump
  [$cn_ set regagent_] dump
  [$mobile_ set regagent_] dump

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
   global opt ns TOPOM namf n tracef mobile_ cn_ 
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
   global ns cn_ mobile_
   set udp [new Agent/UDP]
   $ns attach-agent $cn_ $udp
   
   set dst [new Agent/Null]
   $ns attach-agent $mobile_ $dst
   $ns connect $udp $dst

   set src [new Application/Traffic/CBR]
   $src set packetSize_ 1000
   $src set rate_ 100k
   $src set interval_ 0.01
   $src attach-agent $udp
   $ns at 20.0 "$src start"
} 

main
