# Basic Mobile IPv6 example without using ns-topoman
# Needs proc defined in file proc-mipv6-config.tcl

Agent/MIPv6/MR set bs_forwarding_     0       ; # 1 if forwarding from previous BS
################################################################
proc log-mn-movement_no_topo { } {
  global logtimer ns
  Class LogTimer -superclass Timer
  LogTimer instproc timeout {} {
 	global mr1_ mr2_
        $mr1_ log-movement
	$mr2_ log-movement
        $self sched 1
  }
  set logtimer [new LogTimer]
  $logtimer sched 1  
}

################################################################
# Create Topology
################################################################
proc create-my-topo {} {
	global ns opt topo mr1_ cn_ lfn1_ lfn2_ mr2_ lfn3_ lfn4_ mnn_nodes_

	# Create and define topography
	set topo        [new Topography]
	#   set prop        [new $opt(prop)]
	#   $prop topography $topo
	$topo load_flatgrid 1600 800 

	# god is a necessary object when wireless is used
	# set to a value equal to the number of mobile nodes
	create-god 8

	# Call node-config
	$ns node-config \
		-addressType hierarchical \
		-agentTrace ON \
		-routerTrace ON 

	# Set NS Addressing
	AddrParams set domain_num_ 2
	AddrParams set cluster_num_ {1 5}
	AddrParams set nodes_num_ {1 1 1 1 1 1}

	# Create Nodes
	set cn_ [create-router 0.0.0]
	set router_ [create-router 1.0.0]
	set bs1_ [create-base-station 1.1.0 1.0.0 200 200 0 24]
	set bs2_ [create-base-station 1.2.0 1.0.0 200 600 0]
	set bs3_ [create-base-station 1.3.0 1.0.0 600 200 0]
	set bs4_ [create-base-station 1.4.0 1.0.0 600 600 0]

	# Create Links
	$ns duplex-link $cn_ $router_ 100Mb 1.80ms DropTail
	$ns duplex-link $router_ $bs1_ 100Mb 1.80ms DropTail
	$ns duplex-link $router_ $bs2_ 100Mb 1.80ms DropTail

	$ns at 0 "add-nemo-to-topo"

	display_ns_addr_domain
}

proc add-nemo-to-topo {} {
	global mr1_ lfn1_ lfn2_ mr2_ lfn3_ lfn4_

	clear_config

	set lfn1_ [create-router 1.1.258]
	set lfn2_ [create-router 1.1.259]
	set lfn3_ [create-router 1.4.258]
	set lfn4_ [create-router 1.4.259]

	set mr1_ [create-mobile-router 1.1.256 1.1.0 190 190 0 0 0.01]
	set mr2_ [create-mobile-router 1.4.256 1.4.0 610 200 0 0 0.01]

	lappend nodelist1 $lfn1_
	lappend nodelist1 $lfn2_
	create-mobile-network $mr1_ 1400 200 0 24 26 100Mb 1ms $nodelist1

	lappend nodelist2 $lfn3_
	lappend nodelist2 $lfn4_
	create-mobile-network $mr2_ 1590 790 0 24 26 100Mb 2ms $nodelist2

	$mr1_ setdest 210 610 4
	$mr2_ setdest 1410 200 4

}

################################################################
# End of Simulation
################################################################
proc finish { } {
	global tracef ns namf opt mr1_ mr2_ cn_

	puts "Simulation finished" 
	# Dump the Binding Update List of MN and Binding Cache of HA
	[[$mr1_ set ha_] set regagent_] dump
	[[$mr2_ set ha_] set regagent_] dump
	[$cn_ set regagent_] dump
	[$mr1_ set regagent_] dump
	[$mr2_ set regagent_] dump

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
   global opt ns TOPOM namf n tracef mr1_ cn_ mr2_
   # Source Files
   # source set-def-options.tcl 
   # set BASEDIR to your own correct path
   source /home/ns2/ns-2.28/tcl/lib/proc-mipv6-config.tcl
   source /home/ns2/ns-2.28/tcl/lib/proc-tools.tcl
   source /home/ns2/ns-2.28/tcl/lib/proc-topo.tcl
   source /home/ns2/ns-2.28/tcl/lib/ns-topoman.tcl
   source /home/ns2/ns-2.28/tcl/lib/proc-mobi-global.tcl
   source /home/ns2/ns-2.28/tcl/lib/proc-mobi-config.tcl
   source /home/ns2/ns-2.28/tcl/mobility/timer.tcl

   set NAMF out.nam
   set TRACEF out.tr
   set INFOF out.info

   set opt(mactrace) ON
   set opt(NAM) 1 
   set opt(namfile) $NAMF
   set opt(stop) 200
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

   $ns at 0.0001 "log-mn-movement_no_topo"
   $ns at 0.0001 "set-cbr"


   #>----------------------- Run Simulation -------------------------<
   $ns at $opt(stop) "finish"
   $ns run

   $ns dump-topology $namf
   close $namf
   #puts "running nam with $opt(namfile) ... "
   #exec nam $opt(namfile) &
}

proc set-cbr { } {
	global ns lfn3_ lfn4_ cn_

	set udp1 [new Agent/UDP]
	$ns attach-agent $lfn3_ $udp1
	set dst1 [new Agent/Null]
	$ns attach-agent $cn_ $dst1
	$ns connect $udp1 $dst1
	set src1 [new Application/Traffic/CBR]
	$src1 set packetSize_ 1000
	$src1 set rate_ 100k
	$src1 set interval_ 0.05
	$src1 attach-agent $udp1
	$ns at 20.0 "$src1 start"

	set udp2 [new Agent/UDP]
	$ns attach-agent $cn_ $udp2
	set dst2 [new Agent/Null]
	$ns attach-agent $lfn4_ $dst2
	$ns connect $udp2 $dst2
	set src2 [new Application/Traffic/CBR]
	$src2 set packetSize_ 1000
	$src2 set rate_ 100k
	$src2 set interval_ 0.05
	$src2 attach-agent $udp2
	$ns at 20.03 "$src2 start"
}

main
