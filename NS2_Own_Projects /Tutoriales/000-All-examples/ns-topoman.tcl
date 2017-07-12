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
# First version coded by Vera Mickael 1999 - Motorola CRM Paris
# Enhancements by Thierry Ernst 2000-2001 - Motorola / INRIA
# ############################################################################


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Indexes     
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SITE_NUM:	1...nb_site
# DOM_NUM:	0...nb_dom-1
# NODE_NUM:	0...nb_node-1
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Lists and Arrays
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Proc display_ns_XXX:  display after NS object creation
# tm_all_nodes: array containing ns_object corresponding to node number
# all_info(node_num)		info of all nodes indexed by node number
#	1st elem: address
#	2nd elem: nodetype
#	3rd elem: other args depending on node type 
# tn_prefix[DOM_NUM] -> tn_prefix[0...nb_dom-1] (0.0 ; 0.1 ; ... ; 3.3 ...
# nb_node			total number of nodes in the topology. 
# all_mobiles			list of all mobile nodes in simulation
# tn_sites[NODE_NUM]		site prefixes attached to transit node id
# all_site_prefix[SITE_NUM]	site prefixes corresponding to a site number 
# all_dom_prefix[DOMAIN_NUM]	domain prefixes for each admin. domain
# tn_prefix[DOM_NUM]		prefix of transit nodes in domain
# transit_nodes[DOM_NUM]	transit nodes id in each domain
# s_borders[SITE_PREFIX]	border nodes in site
# s_nodes[SITE_PREFIX]		normal nodes in site
# s_anchors[SITE_PREFIX]	base stations in site
# New April 01:
# nsaddr_		array containing nb of subprefixes for each prefix 
# addrlevel_		after computation, contains the number of NS
#			domains / cluster / node / last for each level
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# To do list 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Proc <is_valid_addr> should be used in more places
# All <get_proc> should check id, addr, prefix, etc.

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Note about addressing:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# IP hierarchy: domain / site / subnet / node
# IP addresses look like W.X.Y.Z:
# Each TN has its own NS domain
# Each site has its own NS cluster under TN NS domain
# BR / SR / BS are subnets
# MAX_DOM: we need more NS domains, because the last level is used
# for Mobile Nodes attached to the Base Stations.  With 3 levels for
# NS addresses, size of routing table is growing rapidly and therefore 
# the time and memory to compute routes.
# - each Transit Node and each Site has its own NS Domain
# - BRs, SRs and BSs in a same site are in the same NS domain and 
#   have their own NS cluster
# - MNs are in the same NS cluster as the BS serving as their HA
# MIN_DOM: we need less NS domains, because we have 4 levels for NS 
# addresses or we don't need one level for Mobile Nodes specifically.
# - each Transit Node has its own NS Domain
# - each Site has a NS cluster in the NS Domain of the TN it is attached to
# - BRs, SRs (and BSs) in the same site have the same NS Cluster.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

################################################################
# Class definition
################################################################
Class Topoman

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# args: actually one arg only
# - specifies how NS addressing will look like
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc init { args } {
   $self instvar nb_node all_info all_mobiles

   # set nb_dom	0	; # index start 0	  	
   # set nb_site  0	; # index start 1 !!!
   set nb_node  0	; # index start 0 
   set all_mobiles ""

   # NS hierarchical addressing
   $self instvar nsaddr_ nblevel_ addrtype_ 

   set nsaddr_()	0	; # No NS domain for now	

   if { [info exists args] != 0 } {
	switch [lindex $args 0] {
	  WIREDONLY { 
		set addrtype_ MIN_DOM 
		set nblevel_ 3 
	  }
	  ALL { 
		set addrtype_ MAX_DOM 
		set nblevel_ 3 
	  }	
	  ENHANCED { 
		set addrtype_ MIN_DOM 
		set nblevel_ 4 
	  } 

	  default {
		puts "Topoman: option [lindex $args 0] not supported"
		exit  
	  }
	}
   } else {
     set addrtype_ MAX_DOM 
     set nblevel_ 3
   }
}

################################################################
# Methods to build the topology
################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 10/2000
# Add a set of administrative domains
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_add_nb_domains {nb_domain} {
 
   for { set i 0 } { $i < $nb_domain } {incr i} { 
	$self tm_add_domain
   } 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 02/01
# Add a new administrative domain in the topology  
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_add_domain { } {
   $self instvar all_dom_prefix transit_nodes

   # Because of NS addressing, several prefixes may belong to the 
   # same administrative domain.
   # Init list of domains attached to this administrative domain 

   set nb_dom [$self get_nb_admin_domains]
   set all_dom_prefix($nb_dom) ""

   # Init list of Transit Nodes attached to this administrative domain
   set transit_nodes($nb_dom) ""
   # incr nb_dom
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 01/01
# Add a set of sites to a transit node
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_add_nb_sites_to_tn_id {tn_id nb_sites} {
 
   for { set i 0 } { $i < $nb_sites } {incr i} { 
	$self tm_add_site_to_tn_id $tn_id 
   } 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 01/01 
# Add a new site to a transit node given its node id 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_add_site_to_tn_id { tn_id args} {
   $self instvar tn_sites s_borders s_nodes s_anchors 
   $self instvar all_site_prefix addrtype_

   set addr [$self get_addr_by_id $tn_id]
   if { [$self is_tn $addr] != "TRUE" } {
      puts "tm_add_site_to_tn: $tn_id is not a valid Transit Node"
      exit 1
   } 
   set dom_prefix [$self get_domain_prefix $addr]

   if { $addrtype_ == "MAX_DOM" } {
	# Each site has its own NS domain 
	# Prefix is the NS domain itself 
   	set site_prefix [$self new_prefix ""] 
   } else {
	# Each site has its own NS cluster in the NS domain of the TN 
	# Prefix is the first NS cluster available in this NS domain
	 set site_prefix [$self new_prefix $dom_prefix] 
   }
   lappend tn_sites($tn_id) $site_prefix  

   # Init list of nodes in this site. 
   set s_borders($site_prefix)		""
   set s_nodes($site_prefix)		""
   set s_anchors($site_prefix)		""
   set all_site_prefix([expr [$self get_nb_sites] + 1]) 	$site_prefix
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 05/01 
# Add a transit node to an administrative domain 
# dom_num is the administrative domain to which belongs the transit node.
# ID is kept to ensure nodes are created in the right order
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_add_tn_to_domain {id dom_num args} {
   $self instvar transit_nodes tn_sites all_info tn_prefix
   $self instvar tn_prefix  all_dom_prefix addrtype_
   
   # Check if a corresponding administrative domain already exists 
   if { [$self is_admin_domain $dom_num]  != "TRUE" } {
      puts "tm_add_tn_to_domain $dom_num out of scope"
      exit 1
   }

   if { [$self check_next_node $id] != "TRUE" } {
      puts "tm_add_tn_to_domain: Try to id a node with a wrong id ($id)" 
      exit 1
   }

   set dom_prefix [$self new_prefix ""]

   if { $addrtype_ == "MAX_DOM" } {
	# Each transit node has its own NS domain 
	# Prefix is the next available NS domain 
	# (i.e. dom_num - 1 digit)
   	set tn_prefix($dom_prefix) $dom_prefix 
   } else {
	# Each transit node has its own NS domain
	# Prefix is the next available NS cluster for this NS domain 
	# (i.e. dom_num.0 - 2 digits)
	set tn_prefix($dom_prefix) [$self new_prefix $dom_prefix] 
   }

   # We now create a new address with this prefix:
   set nid [$self new_router_addr $tn_prefix($dom_prefix)]

   lappend all_info($nid) "TRANSIT_NODE"
   lappend transit_nodes($dom_num) $nid 
   lappend all_dom_prefix($dom_num) $dom_prefix

   # Init list of sites attached to this transit node
   set tn_sites($nid) ""

   return $all_info($nid)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 10/2000
# Add a border node to the IP site
# ID is kept to ensure nodes are created with the same ID used
# to create links. 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_add_border_to_site {id site_num args} {
   $self instvar s_borders all_info

   if { [$self check_next_node $id] != "TRUE" } {
      puts "tm_add_border_node: Try to add a node with a wrong id ($id)" 
   }
   set site_prefix [$self get_site_prefix_by_num $site_num]
   
   set nid [$self new_router_addr $site_prefix]
   lappend all_info($nid) "BORDER_NODE"
   lappend s_borders($site_prefix) $nid
   return $all_info($nid)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 10/2000
# Add a normal node to the IP site
# ID is kept to ensure nodes are created in the right order
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_add_node_to_site {id site_num args} {
   $self instvar s_nodes all_info
  
   if { [$self check_next_node $id] != "TRUE" } {
      puts "tm_add_node: Try to id a node with a wrong id ($id)" 
   }

   set site_prefix [$self get_site_prefix_by_num $site_num]
   
   set nid [$self new_router_addr $site_prefix]
   lappend all_info($nid) "SITE_ROUTER"
   lappend s_nodes($site_prefix) $nid
   return $all_info($nid) 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 10/2000
# Add a base station to the IP site
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_add_bs_to_node { attach_pt args } {
   $self instvar all_info s_anchors

   set attach_addr [$self get_addr_by_id $attach_pt]
   set site_prefix [get_site_prefix $attach_addr] 
   set nid [$self new_router_addr $site_prefix]
   lappend all_info($nid) "BASE_STATION"
   lappend all_info($nid) $attach_addr 
   set all_info($nid) [concat $all_info($nid) $args]
   lappend s_anchors($site_prefix) $nid
   return $all_info($nid) 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add a set of nodes within a site.  Links are added after effective
# NS node creation.
# Return nb nodes in the whole topology before site network is added
# Needed during effective link creation (site can be attached to any
# network topology, link are therefore not bound to some node id) 
# 
# nn: number of nodes to add in site
# site_prefix: site to which nodes gonna be added
# args: unspecified arguments 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_add_site_network { nn site_prefix args } {
   set nb [$self get_nb_nodes]
   set max [expr $nb + $nn]

   for {set i $nb} {$i < $max} {incr i} {
     	eval $self tm_add_node $i $site_prefix $args
   }
   return $nb
}
 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 10/2000
# Add a mobile node to the Base Station given its ID  
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_add_mn_to_bs { attach_pt args} {
   $self instvar all_mobiles all_info
  
   set ha_addr [$self get_addr_by_id $attach_pt]
 
   if { [$self is_bs $ha_addr] == "FALSE" } {
      puts "tm_add_mn : Wrong base station"
      exit 1
   }

   # Mobile addr has same prefix as its HA.
   set subnet_prefix [get_subnet_prefix $ha_addr]
   set nid [$self new_host_addr $subnet_prefix]
    
   lappend all_info($nid) "MOBILE"
   lappend all_info($nid) $ha_addr
   set all_info($nid) [concat $all_info($nid) $args] 
   lappend all_mobiles $nid 
   return $all_info($nid) 
}
  

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Test 10/2000
# Add a host to a default router 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_add_host { attach_pt args} {
   $self instvar all_info
  
   set dr_addr [$self get_addr_by_id $attach_pt]
 
   # Host has same prefix as its Default Router.
   set subnet_prefix [get_subnet_prefix $dr_addr]
   set nid [$self new_host_addr $subnet_prefix]
    
   lappend all_info($nid) "HOST"
   lappend all_info($nid) $dr_addr
   set all_info($nid) [concat $all_info($nid) $args] 
   return $all_info($nid) 
}

################################################################
# NS addressing
################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Test 04/01 
# Create a new NS address prefix  
# prefix = "" / "X" / "X.Y" / "X.Y.Z"
# 1st level - corresponds to NS domain_num (domain)
# 2nd level - corresponds to NS cluster_num (site)
# 3rd level - corresponds to NS nodes_num (subnet)
# 4rd level - corresponds to NS last_num (last) [optional] 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc new_prefix { prefix } {
   $self instvar nsaddr_ nblevel_ 

   set addr_list [split $prefix "."]
   set l [llength $addr_list]
   if { $l == 0 } {
        set p $nsaddr_($prefix)
   } elseif { $l < $nblevel_ } {
        set p $prefix.$nsaddr_($prefix)
   } else {
        puts "new_prefix $prefix: try to add more levels ($l) than available ($nblevel_)"
        exit 1
   }
   set nsaddr_($p) 0
   incr nsaddr_($prefix)
   return $p
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 04/01
# Test validity of address (return "FALSE" if out of scope)
# XXX: could also be used to test validity of a site / subnet prefix
# by replacing host id by "0"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
Topoman instproc is_valid_addr { addr } { 
   set addr_list [split $addr "."]
   set dom [lindex $addr_list 0]
   set site [lindex $addr_list 1]
   set sub [lindex $addr_list 2]
   set host [lindex $addr_list 3]

   if { [$self get_nb_prefix ""] > $dom } {
      if { [$self get_nb_prefix $dom] > $site } {
   	if { [$self get_nb_prefix $dom.$site] > $sub } {
   	   if { [$self get_nb_prefix $dom.$site.$sub] > $host } {
		return "TRUE"
	   }
	}
      }
     }
   return "FALSE"
}

################################################################
# 
################################################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 02/01 
# Check if node id is the next available node id before creation.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc check_next_node {node_id} {
   # $self instvar nb_node

   if { $node_id != [$self get_nb_nodes] } {
	return FALSE 
   } else {
	return TRUE 
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 05/2002 
# Create a new router in a subnet and set its address 
# Return node_id of newly created subnet router
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc new_router_addr { prefix } {
   $self instvar nb_node all_info
   $self instvar nblevel_ addrtype_

   if { $nblevel_ == 3 && $addrtype_ == "MIN_DOM" } {
      # Router while be in provided subnet
      set subnet_prefix $prefix
   } else {
      # New router = first create a new subnet
      set subnet_prefix [$self new_prefix $prefix]
   }

   # Router is first node in the subnet
   set addr [$self new_prefix $subnet_prefix]
   set all_info($nb_node) $addr
   incr nb_node
   return [expr $nb_node - 1]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 10/2000
# Create a new node in subnet.
# Return node_id of newly created node  
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc new_host_addr { subnet_prefix } {
   $self instvar nb_node all_info

   set addr [$self new_prefix $subnet_prefix]
   
   set all_info($nb_node) $addr
   incr nb_node
   return [expr $nb_node -1] 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 10/2000
# Return next available address in subnet (but do not create it) 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc free_host_addr { subnet_prefix } {
   $self instvar nsaddr_
   return $subnet_prefix.$nsaddr_($subnet_prefix)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 12/2000
# Create Nodes, Links and NS addressing
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_create_topo { } {
   $self instvar all_info all_mobiles
   $self instvar tn_sites
   $self instvar s_borders s_nodes s_anchors nblevel_
   global tm_all_nodes topo_man

   # Node configuration: call node-config for all nodes
   if { $nblevel_ == 4 } {
	enhanced_all_nodes_config	
   } else {
   	def_all_nodes_config
   }
 
   # Reserve necessary space for NS addressing
   $self set_addr_params
  
   # Create all nodes sequentially
   for { set n 0 } { $n < [$self get_nb_nodes] } { incr n} {
      switch [lindex $all_info($n) 1] {
        TRANSIT_NODE {
           set tm_all_nodes($n) \
		[eval create-transit-router [lreplace $all_info($n) 1 1]]
        }
        BORDER_NODE {
           set tm_all_nodes($n) \
		[eval create-border-router [lreplace $all_info($n) 1 1]]
        }
        SITE_ROUTER {
           set tm_all_nodes($n) \
		[eval create-site-router [lreplace $all_info($n) 1 1]]
        }
        BASE_STATION {
           set tm_all_nodes($n) \
		[eval create-base-station [lreplace $all_info($n) 1 1]]
        }
        MOBILE {
           set tm_all_nodes($n) \
		[eval create-mobile [lreplace $all_info($n) 1 1]]
        }
        HOST {
           set tm_all_nodes($n) \
		[eval create-host [lreplace $all_info($n) 1 1]]
        }

	# Can add more if needed
        default {
          puts "tm_create_topo: [lindex $all_info($n) 1] undefined node type"
        }
      }
   }
   # Create links
   tm_build_links
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 04/01 
# Compute recursively how many sublevel there is in each level
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_nb_nextlevel { prefix } {
   $self instvar nblevel_ addrlevel_

   set addr_list [split $prefix "."]
   set lev [expr [llength $addr_list] + 1]
   if { $lev >= $nblevel_} {
	return [$self get_nb_prefix $prefix] 
   }
   for { set i 0 } { $i < [$self get_nb_prefix $prefix] } { incr i } {
      if { [llength $addr_list] == 0 } {
	lappend addrlevel_($lev) [$self get_nb_nextlevel $i]
      } else {
	lappend addrlevel_($lev) [$self get_nb_nextlevel $prefix.$i]
      }
   }
   return [$self get_nb_prefix $prefix]
} 

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 04/01 
# Set NS internal addressing corresponding to the defined topology
# XXX: this proc depends on the selected addressing format. 
# XXX: Works for a 4-levels NS-2 addressing.
#      Not yet tested with other address format, but should work 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc set_addr_params {} {
   $self instvar addrlevel_
   $self instvar nblevel_

   set addrlevel_(0) [$self get_nb_nextlevel ""]  
   set i [expr [array size addrlevel_] - 1]
   while { $i  > 0 } {
        set clist $addrlevel_($i)
        set counter 0
        set i [expr $i - 1]
        set plist $addrlevel_($i)
        set len [llength $plist]
        for {set j 0} {$j < $len } {incr j} {
            set counter [ expr $counter + [lindex $plist $j]]
        }
        if {$counter != [llength $clist]  } {
            return 1
            puts "\tNb items in $clist is not equal to sum of items in list $plist"
            puts "Can not set NS addressing."
            exit 1
        }
   }

   # XXXX: we hope that NS variable domain_num etc will be replaced
   # by something more generic.   Moving to any nb of levels would be
   # straight forward.  It would be easy to define more hierarchies 
   # of node in Topoman.

   # Make the conversion between our addressing and NS addressing: 
   AddrParams set domain_num_ $addrlevel_(0)
   AddrParams set cluster_num_ $addrlevel_(1)
   AddrParams set nodes_num_ $addrlevel_(2)
   if { $nblevel_ == 4 } {
        AddrParams set last_num_ $addrlevel_(3)
   }
}

# ##############################################################
# Methods to query the topology 
# ##############################################################
# Notes about EXISTING NS procedures:
#
# The following only work for static nodes (unless specifically enhanced):
# Simulator instproc get-node-by-addr address
# Simulator instproc get-node-id-by-addr address
#
# The following work for ALL nodes:
# Node instproc id
# Node instproc node-addr 
# ##############################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Return information about a particular node
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc node_info {node_index} {
	global TOPOM
	return [concat $node_index [$TOPOM set all_info($node_index)]]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_addr_by_id { id } {
   $self instvar all_info

   if { [info exists all_info($id)] == 0 } {
      puts "get_addr_by_id: no node with given id $id"
      exit 1
   }
   return [lindex $all_info($id) 0] 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Return node index according to its address
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_node_id_by_addr address {
   $self instvar all_info
   set n [$self get_nb_nodes]
   for {set q 0} {$q < $n} {incr q} {
      if {[string compare [lindex $all_info($q) 0] $address] == 0} {
                       return $q
      }
   }
  error "get-node-id-by-addr:Cannot find node with given address"
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Return mobile node object corresponding to the ist mobile 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_mobile_by_index { index } {
   $self instvar all_mobiles 

   if { [info exists all_mobiles] != 0 } {
	global tm_all_nodes
   	return $tm_all_nodes([lindex $all_mobiles $index])
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 01/01
# Return the nb of wired node in the site    
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_nb_routers_by_site { site_prefix } {

   return [llength [$self get_routers_by_site $site_prefix]]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Return number of WIRELESS nodes 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_nb_mobiles {} {
   $self instvar all_mobiles
   return [llength $all_mobiles]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Return the number of WIRED and WIRELESS nodes 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_nb_nodes {} {
   $self instvar nb_node
   return $nb_node 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 12/2000
# Return number of WIRED nodes
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_nb_wired_nodes {} {
   return [expr [$self get_nb_nodes] - [$self get_nb_mobiles]]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Test 02/01 
# Returns the total number of administrative domains in the topology
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_nb_admin_domains {} {
   #$self instvar nb_dom
   #return $nb_dom
   $self instvar all_dom_prefix 
   return [array size all_dom_prefix]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Test 02/01 
# Returns the total number of sites in the topology
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_nb_sites {} {
#  $self instvar nb_site
#   return $nb_site
   $self instvar all_site_prefix 
   return [array size all_site_prefix]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Test 04/01 
# Returns number of sub-prefixes in NS level defined by prefix 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_nb_prefix {prefix} {
   $self instvar nsaddr_
   return $nsaddr_($prefix)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# List of site prefixes linked to the transit node
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_tn_sites {transit_node_id} {
   $self instvar tn_sites
   return $tn_sites($transit_node_id)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Test 02/01 
# Return a list containing prefixes of all sites in the topology 
# PS: "virtual" sites used by Transit Nodes are not 
# (and shouldn't be) included.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_all_sites {} {
   # $self instvar tn_sites transit_nodes

   $self instvar all_site_prefix

   set all_sites ""
   # set list_ind [array names all_site_prefix]
   # foreach i [lsort $list_ind] 
   foreach i [array names all_site_prefix] {
   	  lappend all_sites $all_site_prefix($i)
   } 	
   return $all_sites

   # for { set d 0 } { $d < $nb_dom } {incr d} {
   #     foreach tn $transit_nodes($d) {
   #	  set all_sites [concat $all_sites $tn_sites($tn)] 
   #    }
   # }
   #          return $all_sites 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 12/2000
# Return list of Border Routers in the site identified by its prefix
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_br_by_site {site_prefix} {
   $self instvar s_borders

   if {[info exists s_borders($site_prefix)]} {
      return $s_borders($site_prefix)
   } else {
      return ""
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 8/01
# Return list of all Transit Nodes in the topology
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_all_tn {} {
  $self instvar transit_nodes
  set tn_list ""
  set nb_dom [$self get_nb_admin_domains]

  for { set i 0 } { $i < $nb_dom } {incr i} {
        set tn_list [concat $tn_list $transit_nodes($i)]
  }
  return $tn_list
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 12/2000
# Return list of all Border Routers in the topology 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_all_br {} {
  set br_list ""
  set sites [$self get_all_sites] 
  foreach site $sites {
	set br_list [concat $br_list [$self get_br_by_site $site]]
  }
  return $br_list 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 12/2000
# Return id of site router according to its rank in site
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_site_router_by_index {site_prefix rank} {
   $self instvar s_nodes
  
   # I need to check if there is "rank" SR in the site 
   if { [llength $s_nodes($site_prefix)] >= $rank} {
      return [lindex $s_nodes($site_prefix) [expr $rank - 1]]
   } else {
      puts "get_site_router_by_index $site_prefix $rank: no SR $rank in site" 
      exit 1
   } 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 12/2000
# Return id the last created router in the site, or a border router
# Do I neeed this ??????
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_last_router {site_prefix} {
   $self instvar s_nodes s_borders

   if { [llength $s_nodes($site_prefix)] != 0 } {
	return [lindex $s_nodes($site_prefix) end]
   } else {
	return [lindex $s_borders($site_prefix) end]
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Not tested
# Return list of all site router in site given its prefix
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_srs_by_site {site_prefix} {
   $self instvar s_nodes 

   if { [llength $s_nodes($site_prefix)] != 0 } {
	return $s_nodes($site_prefix)
   } else {
        return ""
  }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 01/01 
# Return list of Router within a site identified by its prefix
# Routers = Border Routers + Site Routers   
# We don't add Base Stations
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_routers_by_site {site_prefix} {
   $self instvar s_borders s_nodes

   set list ""
   if {[info exists s_nodes($site_prefix)]} {
      set list [concat $list $s_nodes($site_prefix)]
   }
   if {[info exists s_borders($site_prefix)]} {
      set list [concat $list $s_borders($site_prefix)]
   } 
   return $list
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 12/2000
# Return list of Base Stations in the site identified by its prefix  
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_bs_by_site {site_prefix} {
   $self instvar s_anchors 

   if {[info exists s_anchors($site_prefix)]} {
      return $s_anchors($site_prefix)
   } else {
      return ""
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 12/2000
# Return list of all BS ids in the entire topology
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_all_bs_id {} {
   set all_bs ""
   set sites [$self get_all_sites]
   foreach site $sites {
        set all_bs [concat $all_bs [$self get_bs_by_site $site]] 
   }
   return $all_bs
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 05/2001 
# Return list of all MN ids in the entire topology
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_all_mn_id {} {
   $self instvar all_mobiles
   return $all_mobiles 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 02/01
# Return domain prefix according to its index
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_dom_prefix_by_num { dom_num } {
   $self instvar all_dom_prefix

   if { [info exists all_dom_prefix($dom_num)] } {
        return $all_dom_prefix($dom_num)
   } else {
        puts "get_dom_prefix_by_num: wrong number $dom_num"
        exit 1
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 12/2000
# Return site prefix according to its index
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_site_prefix_by_num { site_num } {
   $self instvar all_site_prefix

   # Check that site_num is a valid site num
   if { [info exists all_site_prefix($site_num)] } {
        return $all_site_prefix($site_num)
   } else {
        puts "get_site_prefix_by_num: wrong site number $site_num"
        exit 1
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 12/2000
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc toto_get_site_prefix_by_num { site_num } {
   global TOPOM
   return [$TOPOM get_site_prefix_by_num $site_num] 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Return the domain prefix of an address
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_domain_prefix { addr } {
   if { [$self is_valid_addr $addr] == "TRUE" } { 
      set addr_list [split $addr "."]
      return [lindex $addr_list 0]
   }
   puts "get_domain_prefix: $addr is not a valid address"
   exit 1
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Test 02/01 
# Return the domain prefix corresponding to its number 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_domain_prefix_by_num { dom_num } {
   $self instvar all_dom_prefix
 
   # Check if a corresponding administrative domain already exists 
   if ! [info exists all_dom_prefix($dom_num) ] {
      puts "is_domain_prefix: $dom_num out of scope"
      exit 1
   }
   return $all_dom_prefix($dom_num) 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Test 01/01
# Test if there exists a domain corresponding to the given prefix
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc is_domain_prefix { dom_prefix } { 
   set addr_list [split $dom_prefix "."]
   set dom [lindex $addr_list 0]

   if { [$self get_nb_prefix ""] > $dom } {
	return "TRUE"
   }
   return "FALSE"
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Test 02/01
# Check if a corresponding administrative domain already exists 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc is_admin_domain { dom_num } {
   $self instvar all_dom_prefix

   if ![info exists all_dom_prefix($dom_num)] {
	return "FALSE"
   }
   return "TRUE"
} 

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 01/01
# Test if addr corresponds to a mobile node 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc is_mobile {addr} {
   $self instvar all_info
   if { [$self is_valid_addr $addr] == "TRUE" } {
      set id [$self get_node_id_by_addr $addr]
      if { [lindex $all_info($id) 1] == "MOBILE" } {
	 return TRUE 
      } 
   }
   return FALSE 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 01/01
# Test if addr corresponds to a transit node 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc is_tn {addr} {
   $self instvar all_info
   if { [$self is_valid_addr $addr] == "TRUE" } {
      set id [$self get_node_id_by_addr $addr]
      if { [lindex $all_info($id) 1] == "TRANSIT_NODE" } {
	 return TRUE 
      } 
   }
   return FALSE 
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 01/01
# Test if addr corresponds to a base station
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc is_bs {addr} {
   $self instvar all_info
   if { [$self is_valid_addr $addr] == "TRUE" } {
      set id [$self get_node_id_by_addr $addr]
      if { [lindex $all_info($id) 1] == "BASE_STATION" } {
	return TRUE
      } 
   } 
   return FALSE 
}

################################################################
# Some fun tools to query the topology
################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 03/2001
# Return randomly the address of a Site Router
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc get_random_sr_addr {} {
   set nb_site [$self get_nb_sites]
   set rand_site [expr int(rand()*$nb_site) + 1]
   set site_prefix [$self get_site_prefix_by_num $rand_site]
   set site_routers [$self get_routers_by_site $site_prefix]
   set nb_node [llength $site_routers]
   set rand_id [expr int(rand()*$nb_node)]
   set cn_addr [$self get_addr_by_id [lindex $site_routers $rand_id]]
   return $cn_addr
}

################################################################
# Methods to display the topology AFTER NS object creation 
################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 05/2001
# Root proc to display topology AFTER NS object creation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_ns_topo {} {
   set nb_dom [$self get_nb_admin_domains]

   puts ""
   puts "  >--------------------- NS Topology ---------------------<"
   puts ""
   for {set dom 0} {$dom < $nb_dom } {incr dom} {
        $self display_ns_domain $dom
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Display details of the domain after NS object creation
# Subroutine of display_ns_topo 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_ns_domain { dom } {
   $self instvar transit_nodes tn_sites
   global tm_all_nodes

   puts "  >----------------- Transit Domain $dom --------------------<"
   foreach tn $transit_nodes($dom) {
      set object_id $tm_all_nodes($tn)
      set node_type [$object_id set nodetype_] 
      set tn_addr [$object_id set address_]
      set node_id [$object_id set id_]
      puts "  Transit Node $node_id: $tn_addr ($object_id) \[$node_type\] :"
      foreach site $tn_sites($tn) {
         $self display_ns_site $site 
      }
   }
   puts "  >-------------------------------------------------------<"
   puts ""
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Display details of site
# Subroutine of display_ns_topo 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_ns_site { site } {
   $self instvar s_borders s_nodes s_anchors

   puts "    Site $site:"
   puts "\tBorder Routers "
   foreach node_index $s_borders($site) {
        $self display_ns_node_info $node_index 
    }
    puts "\tSite Routers "
    foreach node_index $s_nodes($site) {
        $self display_ns_node_info $node_index 
    }
    puts "\tBase Stations "
    foreach node_index $s_anchors($site) {
        $self display_ns_node_info $node_index 
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Display mobile nodes after NS object creation
# Subroutine of display_ns_topo 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_ns_mobiles {} {
   $self instvar all_mobiles 
   global tm_all_nodes

   if { [info exists all_mobiles] == 0 } {
	return
   }
   puts ""
   puts "  >-------------------- Mobile Nodes ---------------------<"
   puts "  [$self get_nb_mobiles] mobile nodes:"
   foreach mobile_index $all_mobiles {
      set object_id $tm_all_nodes($mobile_index)
      set node_type [$object_id set nodetype_]
      set node_id [$object_id id]
      set node_addr [$object_id node-addr] 
      puts -nonewline "  Mobile node $node_id: $node_addr ($object_id) \[$node_type\] "
   }
   puts ""
   puts "  >-------------------------------------------------------<"
   puts ""
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Display information about a particular node after NS object creation
# Subroutine of display_ns_topo 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_ns_node_info {node_index} {
   global tm_all_nodes      
   set object_id $tm_all_nodes($node_index) 
   puts "            - [$object_id set id_]: [$object_id set address_] \
	($object_id) \[[$object_id set nodetype_]\]  "
}

################################################################
# Methods to display the topology BEFORE NS object creation 
################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Root proc to display topology BEFORE NS object creation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_topo {} {

   puts ""
   puts "  >----------------- Information about topology --------------------<"
   set nb_dom  [$self get_nb_admin_domains]
    
   puts "  Topology has $nb_dom domains: " 
   for { set d 0 } { $d < $nb_dom } {incr d } {
	puts ""
	$self tm_display_transit_nodes $d
	puts ""
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Display transit nodes  
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_display_transit_nodes {domain} {
   $self instvar transit_nodes tn_sites

   puts "  Domain $domain has [llength $transit_nodes($domain)] transit nodes: $transit_nodes($domain)"

   foreach tn_id $transit_nodes($domain) {
      set nb_site [llength $tn_sites($tn_id)]	
      puts "    Transit node [$self get_addr_by_id $tn_id] has $nb_site sites" 
      foreach s $tn_sites($tn_id) { 
	  $self tm_display_site $s
      }
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Display details of site
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_display_site {site} {
   $self instvar s_nodes s_borders s_anchors

   puts "    Site $site:" 
   puts -nonewline "\t[llength $s_borders($site)] borders ($s_borders($site)) "
   foreach node_index $s_borders($site) {
	puts -nonewline "- [$self get_addr_by_id $node_index] "
   }
   puts ""
   puts -nonewline "\t[llength $s_nodes($site)] routers ($s_nodes($site)) "
   foreach node_index $s_nodes($site) {
	puts -nonewline "- [$self get_addr_by_id $node_index] "
   }
   puts ""
   puts -nonewline "\t[llength $s_anchors($site)] bs ($s_anchors($site)) "
   foreach node_index $s_anchors($site) {
	puts -nonewline "- [$self get_addr_by_id $node_index] "
   }
   puts ""
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Display a summary of the topology 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_topo_recap { } {
   puts ""
   puts "  >------------------ Topology Summary -------------------<"
   puts "  [$self get_nb_admin_domains] administrative domains"
   puts "  [$self get_nb_sites] total number of sites"
   puts ""
   puts "  [$self get_nb_wired_nodes] total number of wired nodes"
   puts "  [$self get_nb_mobiles] mobile nodes"
   puts "  [$self get_nb_nodes] total number of nodes" 
   puts "  >-------------------------------------------------------<"
   puts ""
}
 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 01/2001
# Display the list of sites and their associated prefix
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_all_site_prefix { } {
   $self instvar all_site_prefix

   puts ""
   puts "  >------------------ Sites Prefixes ---------------------<"
   set nb [$self get_nb_sites]
   puts "  Total number of sites: $nb"
   for {set i 1} {$i <= $nb } {incr i} {
	puts "  Site $i: [$self get_site_prefix_by_num $i]" 
   }
   puts "  >-------------------------------------------------------<"
   puts ""
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 12/2000
# Display all Border Routers in the topology 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_all_br_info {} {
   $self instvar all_info
   puts ""
   puts "  >----------------- Border Routers --------------------<"
   set sites [lsort [$self get_all_sites]] 
   foreach site $sites {
      set br_list [$self get_br_by_site $site]
      foreach br_id $br_list {
        puts "  BR $br_id: [lindex $all_info($br_id) 0]\t\t(site prefix $site)"
      }
   }
   puts "  >-------------------------------------------------------<"
   puts ""
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Nicely display Base Stations
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_all_bs_info {} {
   puts ""
   puts "  >-------------------- Base Stations --------------------<"
   foreach node_index [$self get_all_bs_id] {
        puts "  [$self node_info $node_index]"
   }
   puts "  >-------------------------------------------------------<"
   puts ""
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Nicely display Mobile Nodes
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_all_mn_info {} {
   puts ""
   puts "  >----------------------- Mobiles -----------------------<"
   foreach node_index [$self get_all_mn_id] {
        puts "  [$self node_info $node_index]"
   }
   puts "  >-------------------------------------------------------<"
   puts ""
}

################################################################
# Misc Methods 
################################################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Generic proc to return the subnet prefix of an address
# Prefix 1.1.1.2 = 1.1.1
# Prefix 1.1.2 = 1.1
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc get_subnet_prefix { addr } {
   set addr_list [split $addr "."]

   set prefix_list [lrange $addr_list 0 [expr [llength $addr_list] -2] ]
   set prefix_string [join $prefix_list "."]
   return $prefix_string
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# Generic proc to return the site prefix of an address
# Prefix 1.1.1.2 = 1.1
# Prefix 1.1.2 = 1
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc get_site_prefix { addr } {
   set addr_list [split $addr "."]

   set prefix_list [lrange $addr_list 0 [expr [llength $addr_list] -3] ]
   set prefix_string [join $prefix_list "."]
   return $prefix_string
}

# ##############################################################
# Methods to query the topology 
# ##############################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc tm_node_info {node_index} {
   global TOPOM
   return [$TOPOM node_info $node_index]
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc get_mobile_by_index { index } {
   global TOPOM
   return [$TOPOM get_mobile_by_index $index]
}

# ##############################################################
# Methods to display information about the topology
# ##############################################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 10/2000
# Root proc to display all the topology before NS object creation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_all_before {} {
   $self display_topo 
   $self display_topo_recap
   $self display_all_br_info
   $self display_all_bs_info
   $self display_all_mn_info
   $self display_all_site_prefix
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 10/2000
# Root proc to display all the topology after NS object creation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc display_all_after {} {
   $self display_ns_topo 
   $self display_ns_mobiles
   $self display_topo_recap
   $self display_all_br_info
   $self display_all_bs_info
   $self display_all_mn_info
   $self display_all_site_prefix
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Demonstration of Topoman
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc tm_demo-topoman { } {
  global ns TOPOM

  puts ""
  puts ">------------ Demonstration of TopomanLib ---------------<"
  # Display info about all nodes
  $TOPOM display_topo
  $TOPOM display_topo_recap
  puts ""
  puts -nonewline "  Information about node 1:\t"
  tm_node_info 1
  puts ""
  puts -nonewline "  Sites linked to transit node 10: [$TOPOM get_tn_sites 10]"
  puts ""
  puts "  Details of site 1:"
  $TOPOM display_site [$TOPOM get_site_prefix_by_num 1]
  puts ""
  puts "  Details of first domain:"
  $TOPOM display_domain 0
  puts "  >-------------------------------------------------------<"
  puts ""
}

################################################################
# Do I need the following ones ?  Not sure this is still working
################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 09/2000
# List NS objects corresponding to all nodes 
# See Simulator insproc all-nodes-list
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Topoman instproc tm_list_nodes {} {
   global tm_all_nodes

   set list "" 
   foreach i [array names tm_all_nodes] {
	lappend list $tm_all_nodes($i)
   }
   set list	
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Useless ?
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc get-wired-only-nodes { } {
   global ns TOPOM
   lappend nodeaddr
   set nodelist [$TOPOM tm_get_wired_only_nodes]
   foreach n $nodelist {
        lappend nodeaddr [$ns get-node-by-id $n]
   }
   return $nodeaddr
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 05/2000
# Return addr of mobile node according to the ist mobile 
#Topoman instproc tm_get_addr_by_mobile_index { i } {
#
#   $self instvar tm_mobiles_addr
#   return [lindex $tm_mobiles_addr $i]
#}



