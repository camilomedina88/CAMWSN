#
# This software comprises contributed code made by Motorola, as a 
# Contributor, to Network Simulator NS-2 software provided by the 
# Regents of the University of California.
# (Copyright; Regents of the University of California, 1994)
# The contributed code was made as a result of a partnership between 
# Motorola and INRIA Rhone-Alpes. 
#
# Copyright in the contributed code belongs to Motorola Inc. 2001
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
# ALL ADVERTISING MATERIALS MENTIONING FEATURES OR USE OF THIS SOFTWARE MUST 
# DISPLAY AN ACKNOWLEDGEMENT TO THE COPYRIGHT OWNERS. 
# ANY REDISTRIBUTION OF THIS SOFTWARE MUST CONTAIN THE ABOVE COPYRIGHT NOTICES, 
# CONDITIONS AND DISCLAIMER.
#
#
# ############################################################################
# This code was developed by Thierry Ernst (1998-2001)
# MOTOROLA Labs Paris FRANCE - INRIA Rhone-Alpes Grenoble (PLANETE) FRANCE 
# NS-2.1b6 enhancements for Wide-Area mobility simulations
#
# This file contains the Topoman Library (ns-topoman.tcl) and contains: 
# - SCEN_PROC: procedures to configure the simulation scenario.
# - LOAD_PROC: procedures to read simulation scenario from a file or 
#   or altenatively passed as argument on the shell command line  
# ############################################################################

# ##############################################################
# Misc
# ##############################################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Proc to display info about the simulation scenario 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc display {flag} {
   global display_
   set display_ $flag
}

proc display? { } {
   global display_
   if { ![info exists display_] } {
      return 0
   }
  return $display_
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Proc to display instruction read from file or command line 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc dinput {flag} {
   global dinput_
   set dinput_ $flag
}

proc dinput? { } {
   global dinput_
   if { ![info exists dinput_] } {
      return 0
   }
  return $dinput_
}

# ##############################################################
# LOAD_PROCS 
# helpers methods to read the simulation scenario passed as 
# arguments on the shell command line or from a file
# ##############################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generic proc to load a SCEN_PROC
# Call should either be load-config <scen_proc> <4> <file> 
# or <option_name>
# XXX Not ready for use - to replace all the other proc.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc load-config { args } {
   global opt

puts "Not ready"
exit 
# if length = 3     
# set scen_proc [lindex $args 0]
# set nn [lindex $args 1]
# set file [lindex $args 2]
# else
# set option [lindex $args 0]
   if { $file != "NONE" } { 
	# Read config file for nn set-mobile records
	read-function $scen_proc $nn $file
   } else {
	# Read instruction from option
	if { [dinput?] } {
	   puts "$opt($option)"
   	}
	if { $opt($option) != "NONE" } {
	   eval  $opt($option)
	}
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load Site configuration  
# If your topology is generated by GT-ITM and you want one
# stub to look rather different from the other 
# XXX: does it still work ? 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc load-config-site { file } {
   global opt

   if { $opt(site_file) != "NONE" } {
      source $opt(site_file)
   }

   if { $file != "NONE" } { 
	# Read config file for nn set-site records
	read-function set-site 1 $file
   } else {
	# Read instruction from option or command line 
	if { [dinput?] } {
	   puts "$opt(site_config)"
   	}
	if { $opt(site_config) != "NONE" } {
     	   eval  $opt(site_config)
	}
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load Base Stations configuration  
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc load-config-bs { nn file } {
   global opt

   if { $file != "NONE" } { 
	# Read config file for nn set-mobile records
	read-function set-bs $nn $file
   } else {
	# Read instruction from option or command line 
	if { [dinput?] } {
	   puts "$opt(bs_config)"
   	}
	if { $opt(bs_config) != "NONE" } {
	   eval  $opt(bs_config)
	}
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load Mobile Nodes configuration
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc load-config-mn { nn file} {
 global opt

 if { $nn > 0 } {

   if { $file != "NONE" } {  
	# Read config file for nn set-mobile records
	read-function set-mobile $nn $file
   } else {
	# Read instruction from option or command line 
	if { [dinput?] } {
	   puts "$opt(mn_config)"
   	}
	if { $opt(mn_config) != "NONE" } {
	   eval  $opt(mn_config)
	}
   }
 # } else {
 #   puts "load-config-mn: variable mn_nn not set (number of mobiles)"
 #   exit
 }

}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load selection of Correspondend Nodes 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc load-config-cn { nn file } {
   global opt

   if { $nn > 0 } {

      if { $file != "NONE" } {  
	# Read from file
	read-function select-cn $nn $file	 
      } else {
	   # Read instruction from option or command line 
	   if { [dinput?] } {
	      puts "$opt(cn_config)"
   	   }
	   if { $opt(cn_config) != "NONE" } {
	      eval  $opt(cn_config)
	   }
      }
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load Simulation Scenario
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc load-scen { file } {

   global opt
   if { $file != "NONE" } { 
        # Read Mobility scenario from file 
         read-scen $file 
   } else {
	# Read instruction from option or command line 
	if { [dinput?] } {
	   puts "$opt(scen_config)"
   	}
	if { $opt(scen_config) != "NONE" } {
     	   eval $opt(scen_config)
	}
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generic Proc that reads a file for a specific instruction 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc read-function { function nn file } {
  # nn = total number of records to be read from file 
  set f [open $file r]
  set i 0

  while {[gets $f line] >= 0 && $i < $nn } {
	if { [lindex $line 0] == $function} {
	     if { [dinput?] } {
                        puts "Read $line"
             }
	     eval $line
             incr i
        }
  }
  if { $i < $nn } {
        puts "Wrong $function $i definition in file $file"
        exit 0
  }
  close $f
  return $i
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Read list of mobile node's CN in configuration file
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc read-cns { file } {
   # file = file containing list of CNs 
   set f [open $file r]
   set i 0

   while {[gets $f line] >= 0 } {
        if { [lindex $line 0] == "add-cn"} {
	   if { [dinput?] } {
                puts "Read new CN: $line"
           }
           eval $line
	   incr i
	   continue
        } 
        if { [lindex $line 0] == "select-cn"} {
	   if { [dinput?] } {
                puts "Read new CN: $line"
           }
           eval $line
	   incr i
	   continue
        } 
        if { [lindex $line 0] == "select-random-cn"} {
	   if { [dinput?] } {
                puts "Read Select Random CN: $line"
           }
           eval $line
	   incr i
        }
   }
   close $f

   # Return nb records read from file  
   return $i	  
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Read mobility scenario in mobile node's configuration file
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc read-scen { file } {
   # file = file containing mobility scenario 
   # lines in file look like:
   #    set-stub mob_num stub time
   #    set-stub 0 7 50
   set f [open $file r]

   while {[gets $f line] >= 0 } {

	switch -exact [lindex $line 0] {
	   set-stub { 
		if { [dinput?] } {
           	#   puts "Read $line" 
		}
		eval $line
	   }
	   set-mn-to-bs {
		if { [dinput?] } {
           	   puts "Read $line" 
		}
		eval $line
	   }
	}
   }
   close $f
}

# ##############################################################
# SCEN_PROC
# procedures to configure the simulation scenario
# ##############################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 23/04/01
# Select Randomly nn distinct Site Routers and make them
# correspondent nodes (CN) of the mobile node 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc add-nn-auto-cn { mob_num nn seed time lftm cn_deltat} {
   global ns TOPOM

   if { $seed != -1 } {
      expr int(srand($seed))      
   }
   set i 0
   set temp ""
   while { $i < $nn } { 
      set cn_addr [$TOPOM get_random_sr_addr ] 

      # Do not select same CN twice
      while { [lsearch $temp $cn_addr] != -1 } {
         set cn_addr [$TOPOM get_random_sr_addr] 
      }
      lappend temp $cn_addr
      incr i 
      add-auto-cn $mob_num $cn_addr $time [expr $time + $lftm]
      set time [expr int($time) + $cn_deltat]
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Select Randomly nn distinct Correspondent Nodes
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc select-random-cn { mob_num nn time} {
   # select-random-cn <MN_index> <Number of CNs> <Time>
   # select-random-cn 0 10 0.02
   global ns opt

   set mob_id [[get_mobile_by_index $mob_num] id]
   set i 0
   set cn_list ""
   while { $i < $nn } { 
	set rand_id [expr int(rand()*[Node set nn_])]

	if { $rand_id == $mob_id } {
   	   # Avoid CN = MN
	   continue
	}
	if { [lsearch $cn_list $rand_id] != -1 } {     
	   # Avoid Duplicate CNs 
	   continue
	}
	lappend cn_list $rand_id
	incr i
	set id [[Simulator instance] get-node-by-id $rand_id]
	set addr [$id set address_]
	add-cn $mob_num $addr $time $opt(stop)
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add Correspondent Node to Mobile Node's Binding List for a 
# specified amount of time (remove it when over) 
# CN will receive BUs even if there is no traffic 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc add-cn { mob_num cn_addr time stop} {
   # file = file containing list of CNs 
   # lines in file look like:
   #    add-cn mob_num cn_addr 
   global ns opt
   
   set cn [$ns get-node-by-addr $cn_addr]
   set mob [get_mobile_by_index $mob_num]

   # Switch LBM on at CNs in case some nodes only are LBM-enabled
   if { [$cn lbmcast?] && [info exists opt(lbm_cn_only_)] && $opt(lbm_cn_only_) == 1 } {
      $ns at $time.01 "[$cn set lbmclassifier_] set lbm_flag_ 1"
      $ns at $stop "[$cn set lbmclassifier_] set lbm_flag_ 0" 
   }

   if { $opt(protocol) == "MBU"} {
      global bu_group 
      $ns at $time.01 "$cn join-group [$cn set regagent_] $bu_group($mob)"
      $ns at $stop "$cn leave-group [$cn set regagent_] $bu_group($mob)"
   } else {
      $ns at $time.01 "$mob add-cn $cn_addr"
      $ns at $stop "$mob remove-cn $cn_addr"
   }
   if { [dinput?] } {
      global infof
      puts $infof "set CN [tm_node_info [$cn id]] ($time/$stop) $opt(cn_traffic)"
      $ns at $opt(stop) "[$cn set regagent_] dump"
   }
  if { $opt(cn_traffic) != "NONE" } {
     eval $opt(cn_traffic) $cn $mob $time $stop
  } 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 23/04/01
# Setup traffic between a CN and a MN for a specified amount 
# of time (remove it when over) 
# If cn_traffic = NONE, CN won't be detected by MN
# CN only receives BUs if MN receives traffic since less than the
# last BU's lifetime.   
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc add-auto-cn { mob_num cn_addr time stop } {
   global ns opt
   
   set cn [$ns get-node-by-addr $cn_addr]
   set mob [get_mobile_by_index $mob_num]

   if { $opt(protocol) == "MBU"} {
      global bu_group 
      $ns at $time.01 "$cn join-group [$cn set regagent_] $bu_group($mob)"
      $ns at $stop "$cn leave-group [$cn set regagent_] $bu_group($mob)"
   }
   if { [dinput?] } {
      global infof
      puts $infof "set CN AUTO [tm_node_info [$cn id]] ($time/$stop) $opt(cn_traffic)"
      $ns at $opt(stop) "[$cn set regagent_] dump"
   }
  if { $opt(cn_traffic) != "NONE" } {
     eval $opt(cn_traffic) $cn $mob $time $stop
  } 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Select Correspondent Node for a Mobile Node
# select-cn <selector> <mob_index> <arrival_time> <arg1> [<option> <>]
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc select-cn { selector mob_num time arg1 args } {
   global ns opt TOPOM

   switch $selector {
     NN_SR_RAN {
	# select-cn <NN_SR_RAN> <mob_num> <start_arrival_time> ... 
	# ... <delta_arrival_time> <nb_CN> <rand_seed>
	# 1st CN arrives at <start_arrival_time>
	# A new CN arrives every <delta_arrival_time>	
	# and stays until end of simulation

	set cn_deltat $arg1
	set nn [lindex $args 0] 
	set seed [lindex $args 1] 
	if { $seed != -1 } {
	    expr int(srand($seed))	
	}
 	set i 0
	set temp ""
        while { $i < $nn } { 
	   set cn_addr [$TOPOM get_random_sr_addr ] 

	   # Do not select same CN twice
	   while { [lsearch $temp $cn_addr] != -1 } {
		set cn_addr [$TOPOM get_random_sr_addr] 
	   }
	   lappend temp $cn_addr
	   incr i 
   	   add-cn $mob_num $cn_addr $time $opt(stop)
	   set time [expr int($time) + $cn_deltat]
	}
     }
     IN_OUT_SR {
	# select-cn <IN_OUT_SR> <mob_num> <start_arrival_time> ... 
	# ... <delta_arrival_time> <lifetime> <nb_CN> <rand_seed>
	# 1st CN arrives at <start_arrival_time>
	# A new CN arrives every <delta_arrival_time> and leave after <lifetime>

	set cn_deltat $arg1
	set lftm [lindex $args 0] 
	set nn [lindex $args 1] 
	set seed [lindex $args 2] 
	if { $seed != -1 } {
	    expr int(srand($seed))	
	}
 	set i 0
	set temp ""
        while { $i < $nn } { 
	   set cn_addr [$TOPOM get_random_sr_addr ] 

	   # Do not select same CN twice
	   while { [lsearch $temp $cn_addr] != -1 } {
		set cn_addr [$TOPOM get_random_sr_addr] 
	   }
	   lappend temp $cn_addr
	   incr i 
   	   add-cn $mob_num $cn_addr $time [expr $time + $lftm]
	   set time [expr int($time) + $cn_deltat]
	}
     }
     SR-AUTO {
	# select-cn <SR_AUTO> <mob_num> <start_arrival_time> ... 
	# ... <delta_arrival_time> <lifetime> <nb_CN> <rand_seed>
	# 1st CN arrives at <start_arrival_time>
	# A new CN arrives every <delta_arrival_time>	
	# and leave after <lifetime>	

	set cn_deltat $arg1
	set lftm [lindex $args 0] 
	set nn [lindex $args 1] 
	set seed [lindex $args 2] 
	add-nn-auto-cn $mob_num $nn $seed $time $lftm $cn_deltat
     }
     SITE_LAST {
	# Last created node in Site
	puts "select-cn: SITE_LAST not yet implemented"
	exit 1	
	set site_prefix [$TOPOM get_site_prefix_by_num $arg1] 
	set id [$TOPOM get_last_router $site_prefix
	set cn_addr [$TOPOM get_addr_by_id $id]
	add-cn $mob_num $cn_addr $time $opt(stop)
     }
     SITE_ROUTER {
puts "select-cn SIRE_ROUTER not tested"
exit
	# Attach CN to some site router 
	# select-cn SR mob_num time site_num node_rank_within_site stop
	set site_prefix [$TOPOM get_site_prefix_by_num $arg1] 
	set rank [lindex $args 0]
	set stop [lindex $args 1]
        set id [$TOPOM get_site_router_by_index $site_prefix $rank]
	set cn_addr [$TOPOM get_addr_by_id $id]
   	add-cn $mob_num $cn_addr $time $stop 
     }
     ID {
	# Attach CN to node id
	# select_cn IN mob_num time node_id stop 
 	set cn_addr [$TOPOM get_addr_by_id $arg1]
	set stop [lindex $args 0]
   	add-cn $mob_num $cn_addr $time $stop 
     }	
     ADDR {
	# Attach CN to node with given addr 
	# select_cn ADDR mob_num time node_addr stop 
	set stop [lindex $args 0]
	if {[$TOPOM is_valid_addr $arg1] == "TRUE" } {
	   	add-cn $mob_num $arg1 $time $stop
	} else {
		puts "select-cn: $arg1 not valid address"
	        exit 1
	}
     }	
     BR {
puts "select-cn BR not tested"
exit
	# Attach CN to site Border Router (select first one) 
	# select-cn BR mob_num time site_num

	set site_prefix [$TOPOM get_site_prefix_by_num $arg1] 
	set rank [lindex $args 0]
        set id [lindex [$TOPOM get_br_by_site $site_prefix] 0]
	set cn_addr [$TOPOM get_addr_by_id $id]
	add-cn $mob_num $cn_addr $time $opt(stop)
     }
     RANDOM {
	# XXX: copy proc select-random-cn HERE
	puts "select-cn: RANDOM not yet implemented"
        exit 1
	
     }
     default {
   	puts "select-cn: undefined intruction $selector"
	exit 1
      }
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Global mobility scerario configuration
# XXX: should specify stop time as an argument
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc set-scen { selector site_list mob_num interval args } {
   global opt ns TOPOM
  
   switch $selector  {
     AL {	
	# Alternate between sites
   	if { [llength $site_list] == 0 } {
	   set site_list [$TOPOM get_all_sites]
        }
	global scen_time
	set scen_time 0 
	eval schedule-movement $mob_num $interval $opt(stop) $site_list
     }

     NN_RAND {
	# Alternate between sites randomly selected
	set nn $site_list
	set nb_site [$TOPOM get_nb_sites]
	set seed [lindex $args 0] 
	if { $seed != -1 } {
	    expr int(srand($seed))	
	}
	set i 0
	set site_list ""
	while { $i < $nn } { 
           set rand_site [expr int(rand()*$nb_site) + 1]
	   if { [lsearch $site_list $rand_site] == -1} {
	      lappend site_list $rand_site
	      incr i 
	   }	
	}
	if { [dinput?] } {
	   puts "Random sites are $site_list"
	}
	global scen_time
	set scen_time 0 
	eval schedule-movement $mob_num $interval $opt(stop) $site_list
     }
	
     default {
        puts "set-scen: undefined intruction $attach_pt"
        exit 1
     }
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc schedule-movement {mob_num interval stop args} {
   global ns scen_time
   if { $scen_time < $stop } { 
      # $ns at $scen_time "eval schedule-movement $mob_num $interval $stop $args"
      foreach site $args {
         set-stub $mob_num $site $scen_time 
         set scen_time [expr $scen_time + $interval] 
      }
      $ns at [expr $scen_time - $interval]  "eval schedule-movement $mob_num $interval $stop $args"
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Make the MN enter in a site  
# set-stub <MN_index> <Site_Num> <Time>
# To specifies mobility between sites (global mobility) 
# XXX: make the check:   
# XXX  If BS in distinct site/stub than current site/stub:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc set-stub { mob_num site_num time } {
   global ns opt 
   if { $time < $opt(stop) } {
      $ns at $time "enter-site $mob_num $site_num $time"
   } 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# set-mn-to-bs <MN_index> <Base_Station_address> <Time>
# XXX: do not remember it it's still working 
# XXX: make the check:   
# XXX  If BS in distinct site/stub than current site/stub:
# XXX  do this before $ns at $time "$mob enter_stub BS_prefix"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc set-mn-to-bs { mob_num bs time } {
   global ns
   set mob [get_mobile_by_index $mob_num]
   $ns at $time "$mob enter_bs $bs"
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Configuration for the mobile node
# set-mobile <selector> <arg1> <X> <Y> <Z> <random 1|0> [<start> <stop>]  
# o set-mobile SITE <site_num> <X> <Y> <Z> <random 1|0> [<start> <stop>]
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc set-mobile { selector arg1 args }   {
   global ns TOPOM
   switch $selector {
      SITE { 
   	if { $arg1 == -1 } {
      	   # Select first site in list of sites
      	   set site_prefix [lindex [$TOPOM get_all_sites] 0]
   	} else {
   	   set site_prefix [$TOPOM get_site_prefix_by_num $arg1]
	} 

   	# If several BSs in site, take the first one in site 
   	set bss [$TOPOM get_bs_by_site $site_prefix]
   	set ha [lindex $bss 0]
      }
      SITE_PREFIX {
	set site_prefix $arg1
   	# If several BSs in site, take the first one in site 
   	set bss [$TOPOM get_bs_by_site $site_prefix]
   	set ha [lindex $bss 0]
      }
      BS_ID {
	set ha $arg1
      }
      default {
	   puts "set-mobile: undefined selector $selector"
	   exit 1
	}
   }

   if { [dinput?] } { 
	 global infof 
	 puts $infof "add MN to [tm_node_info $ha]" 
   }
   eval $TOPOM tm_add_mn_to_bs $ha $args 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Configure Site 
# Attach a site network to a specified site_prefix   
# set site_config="set-site BR { 1 }"
# set site_config="set-site BR { $site_list }"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc set-site { attach_pt_type site_list } {
   global ns TOPOM site_net
 
   # Definition of global variable site_net HERE (at first call)
   # Needed at time of effective link creation
   
   if { [llength $site_list] == 0 } {
	set site_list [$TOPOM get_all_sites]
   }

   switch $attach_pt_type  {
     BR {	
	global site_net_size
	foreach site $site_list {
   	   set sp [$TOPOM get_site_prefix_by_num $site]
	   set site_net($sp) [$TOPOM tm_add_site_network $site_net_size $sp]
 
	   # attach to 1st border node (likely the only one)
	   set brid [lindex [$TOPOM get_br_by_site $sp] 0]
	   lappend site_net($sp) $brid

	   if { [dinput?] } {
		 global infof 
		 puts $infof "add Site to [tm_node_info $brid]" 
	   }
	}
      }
      default {
         puts "set-bs: undefined intruction $attach_pt"
         exit 1
      }
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Configuration of a set of Base Stations
# Specifies where BSs should be attached and what are their coordinates
# set-bs <selector> <site_index_list> <X> <Y> <Z>
# o set-bs RAND <site_list> <X> <Y> <Z>
# o set-bs RAND <> <X> <Y> <Z>
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc set-bs { selector site_num_list args }   {
   global ns TOPOM

   # By default, init site_num_list to all site num 
   if { [llength $site_num_list] == 0 } {
	#set site_list [$TOPOM get_all_sites]
	set nb [$TOPOM get_nb_sites]
	set site_num_list ""
 	for { set i 1 } { $i <= $nb } {incr i} {
		lappend site_num_list $i
	}
   }

   foreach site $site_num_list {
      set site_prefix [$TOPOM get_site_prefix_by_num $site]
  
      switch $selector  {
        BR {					
	# Attach BS to site Border Router 
	# attach to 1st border node (likely the only one)
	# XXX: what if there is no BR ?
	   set attach_pt_id [lindex [$TOPOM get_br_by_site $site_prefix] 0]
        }
        RAND {
	# attach BS to a random wired node in site 
	# XXX: what if there is no node in site ?
	   set site_routers [$TOPOM get_routers_by_site $site_prefix]
	   set nb_node [llength $site_routers] 
	   set rand_id [expr int(rand()*$nb_node)]
	   set attach_pt_id [lindex $site_routers $rand_id]
	}
	INDEX {
        # attach BS to specified ith node in site (SR, BR, ...) 
        # XXX: what if there is no SR ?
           set attach_pt_id [$TOPOM get_site_router_by_index $site_prefix [lindex $args 0]
        }
	default {
	   puts "set-bs: undefined intruction $attach_pt"
	   exit 1
	}
      }
      if { [dinput?] } {
	 global infof 
	 puts $infof "add BS to [tm_node_info $attach_pt_id]" 
      }

   # XXX: do not modify arg list in loop !!! 
   eval $TOPOM tm_add_bs_to_node $attach_pt_id $args
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Configuration of one Base Station
# Specifies where a BS should be attached and what are its coordinates
# set-bs <selector> <arg1> <X> <Y> <Z>
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc set-one-bs { selector arg1 args }   {
   global ns TOPOM
   
   switch $selector  {
	ADDR {
	   # attach BS to a particular addr
	   puts "set-bs: ADDR not yet implemented"
	   exit 1
	}
        ID {
	# attach BS to specified node id in site (SR, BR, ...) 
	# XXX: what if there is no corresponding node ?
	   set attach_pt_id $arg1 
	}
	default {
	   puts "set-one-bs: undefined intruction $attach_pt"
	   exit 1
	}
   }
   eval $TOPOM tm_add_bs_to_node $attach_pt_id $args
}
