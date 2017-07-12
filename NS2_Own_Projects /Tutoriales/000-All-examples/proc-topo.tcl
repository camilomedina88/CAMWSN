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
# ############################################################################

################################################################
# Create the topology using ns-topoman
# Requires ns-topoman.tcl 
################################################################
proc topo-settings { } {
   global opt TOPOM mobile topo

   if { [dinput?] } {
	puts "* Build Topology"
   }

   # Create the TOPOMAN instance
   set TOPOM [new Topoman $opt(topoman)]

   # Load the main topology
   source $opt(topo_file) 
   tm_load_nodes

   # Load specific site topology (optional)
   # Useful if topo_file was autmatically generated and if we want to 
   # add more nodes 
   load-config-site $opt(site_config_file)
   
   # Load Base Stations 
   load-config-bs $opt(bs_nn) $opt(bs_config_file) 

   # Load Mobile Nodes 
   if { $opt(protocol) != "RT_TABLE"} {
	load-config-mn $opt(mn_nn) $opt(config_file)
   }

   if { $opt(RUN) == "TRUE" || $opt(RUN) == "NAM"} {
	# Create and define topography
	set topo        [new Topography]
	#   set prop        [new $opt(prop)]
	#   $prop topography $topo
	$topo load_flatgrid $opt(x) $opt(y)

	# god is a necessary object when wireless is used
	create-god $opt(mn_nn)
	# Effectively create Nodes, Links and NS addressing
	$TOPOM tm_create_topo

   	if { [dinput?] } { 
		$TOPOM display_all_after
		display_all_channels
	} else  {
		display_ns_addr_domain
	}
   } else {
	# Means we don't want to run NS, we just want to display 
	# information about the topology. 
	$TOPOM display_all_before
   }
}

################################################################
# Create the wired topology
# Modified 05/02 (cleanup to work if some options not set)
################################################################
proc wired-topo-settings { } {
   global opt TOPOM mobile topo

   if { [dinput?] } {
        puts "* Build Topology"
   }

    # Create the TOPOMAN instance
   set TOPOM [new Topoman $opt(topoman)]

   # Load the main topology
   source $opt(topo_file)
   tm_load_nodes

   # Load specific site topology (optional)
   # Useful if topo_file was autmatically generated and if we want to
   # add more nodes
   if { [info exists opt(site_config_file] } {
        load-config-site $opt(site_config_file)
   }

   if { $opt(RUN) == "TRUE" || $opt(RUN) == "NAM" } {
        # Effectively create Nodes, Links and NS addressing
        $TOPOM tm_create_topo

        if { [dinput?] } {
                $TOPOM display_all_after
        } else  {
                display_ns_addr_domain
        }
   } else {
        # This means we don't want to run NS, we just want to display
        # information about the topology.
        $TOPOM display_all_before
   }
}



