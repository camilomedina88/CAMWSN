  
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
  global ns opt topo mobile_ cn_ mn_nodes_

  # Create and define topography
  set topo        [new Topography]
     #set prop        [new $opt(prop)]
     #$prop topography $topo
  $topo load_flatgrid 800 800

  # god is a necessary object when wireless is used
  # set to a value equal to the number of mobile nodes
  create-god 1 

  # Call node-config
  $ns node-config \
        -addressType hierarchical \
     -agentTrace ON \
    -macTrace ON \
     -routerTrace ON \

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
  $ns duplex-link $router_ $bs3_ 100Mb 1.80ms DropTail
  $ns duplex-link $router_ $bs4_ 100Mb 1.80ms DropTail
#giving orientation
#$ns duplex-link-op $cn_ $router_ orient right-down
#$ns duplex-link-op $router_ $bs1_ orient left-down
#$ns duplex-link-op $router_ $bs2_ orient down
#$ns duplex-link-op $router_ $bs3_ orient right-down
#$ns duplex-link-op $bs3_ $bs4_ orient right


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
  puts "running nam with $opt(namfile) ... "
  exec nam $opt(namfile) &
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
   source /home/sibs/ns233/ns-allinone-2.33/ns-2.33/tcl/lib/proc-mipv6-config.tcl
   source /home/sibs/ns233/ns-allinone-2.33/ns-2.33/tcl/lib/proc-tools.tcl
   source /home/sibs/ns233/ns-allinone-2.33/ns-2.33/tcl/lib/proc-topo.tcl
   source /home/sibs/ns233/ns-allinone-2.33/ns-2.33/tcl/lib/ns-topoman.tcl
   source /home/sibs/ns233/ns-allinone-2.33/ns-2.33/tcl/lib/proc-mobi-global.tcl
   source /home/sibs/ns233/ns-allinone-2.33/ns-2.33/tcl/lib/proc-mobi-config.tcl
   source /home/sibs/ns233/ns-allinone-2.33/ns-2.33/tcl/mobility/timer.tcl

   set NAMF mip2.nam
   set TRACEF mip2.tr
   set INFOF mip2.info

   set opt(mactrace) ON
   set opt(NAM) 1 
   set opt(namfile) $NAMF
   set opt(stop) 100
   set opt(tracefile) $TRACEF
   
   #>--------------- Extract options from command line ---------------<
   #Getopt    ; # Get option from the command line    
   #DisplayCommandLine
   
   #>---------------------- Simulator Settings ----------------------<
   set ns [new Simulator]
   #>------------------------ Open trace files ----------------------<
   exec rm -f $opt(tracefile)
   set tracef [open $opt(tracefile) w]
   #... dump the file
   $ns trace-all $tracef
    
   set namf [open $opt(namfile) w]
   $ns namtrace-all-wireless $namf 800 800

   #>------------- Protocol and Topology Settings -------------------<
   create-my-topo
   log-mn-movement_no_topo
   
   set-cbr
# set-ping-int 0.1 $cn_ $mobile_ 10 $opt(stop)


   # set-ping-int 0.1 $cn_ $mobile_ 10 $opt(stop)
   #start movement to pos(x,y) with velocity v
   $ns at 5.0 "$mobile_ setdest 700 200 10"
   #MN move again to BS2#####
   $ns at 15.0 "$mobile_ setdest 700 300 10"
   $ns at 25.0 "$mobile_ setdest 700 400 10"
   $ns at 35.0 "$mobile_ setdest 600 500 10"
   $ns at 45.0 "$mobile_ setdest 700 600 10"
   $ns at 55.0 "$mobile_ setdest 600 500 10"
   $ns at 65.0 "$mobile_ setdest 400 400 10"
   $ns at 75.0 "$mobile_ setdest 300 300 10"
   $ns at 85.0 "$mobile_ setdest 500 250 10"
   $ns at 95.0 "$mobile_ setdest 600 175 10"
   $ns at 105.0 "$mobile_ setdest 700 200 10"


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
   $src set interval_ 0.05
   $src attach-agent $udp
   $ns at 01.0 "$src start"
} 

main
