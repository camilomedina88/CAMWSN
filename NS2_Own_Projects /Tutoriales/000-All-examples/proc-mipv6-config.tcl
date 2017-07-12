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
# How to configure nodes for Mobile IPv6 
# ############################################################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Procs to create nodes according to their function in the topology
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc create-router {address args} {
    global ns 
    def_transit_config
    return  [$ns node $address]
}

proc create-transit-router {address args} {
    global ns 
    def_transit_config
    return  [$ns node $address]
}

proc create-border-router {address args} {
    global ns
    def_border_config
    return  [$ns node $address]
}

proc create-site-router {address args} {
    global ns
    def_node_config
    return  [$ns node $address]
}

proc create-host {address args} {
    global ns
    def_host_config
    return  [$ns node $address]
}

proc create-base-station {address attach_pt_addr X Y Z args} {
   global ns 
   def_bs_config
 
   # Base Stations in distinct sites listen on distinct channels
   set channel [set_channel_by_addr $address]
   $ns set chan $channel
   set local_node [$ns node $address]
   $local_node random-motion 0 
   $local_node set X_ $X 
   $local_node set Y_ $Y 
   $local_node set Z_ $Z 

   set attach_pt [$ns get-node-by-addr $attach_pt_addr]
   $ns duplex-link $attach_pt $local_node 5Mb 2ms DropTail
   return $local_node
}

proc create-mobile {home_addr ha_addr X Y Z random args} {
   global ns
   def_mobile_config

   # Home site 
   set channel [set_channel_by_addr $home_addr]
   $ns set chan $channel
   set local_node [$ns node $home_addr]
   $local_node set-ha $ha_addr
   $local_node set X_ $X 
   $local_node set Y_ $Y 
   $local_node set Z_ $Z 
   $local_node random-motion $random

   set start [lindex $args 0]

   if { $random != 0 } {
	$ns at $start "$local_node start"
   }
   return $local_node
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Default calls to node-config
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc def_all_nodes_config { } {
    global ns
 
    $ns node-config \
	-addressType hierarchical 
}

proc enhanced_all_nodes_config { } {
    global ns
 
    $ns node-config \
	-addressType "hierarchical 4 8 8 8 8"
}

proc def_transit_config { } {
    global ns
    $ns node-config \
	-mipv6 ON \
	-mipagent CN
}

proc def_border_config { } {
    global ns
    $ns node-config \
	-mipv6 ON \
	-mipagent CN 
}

proc def_node_config { } {
    global ns
    $ns node-config \
	-mipv6 ON \
	-mipagent CN 
}

proc def_host_config { } {
    global ns
    $ns node-config \
	-mipv6 ON \
	-mipagent CN 
}

proc def_bs_config { } {
   global ns topo
   $ns node-config \
	-mipv6 ON \
	-mipagent BS \
	-mobileIP ON \
	-wiredRouting ON \
	-adhocRouting Network \
	-llType LL \
	-macType Mac/802_11 \
	-ifqType Queue/DropTail/PriQueue \
	-ifqLen 50 \
	-antType Antenna/OmniAntenna \
	-propType Propagation/TwoRayGround \
	-phyType Phy/WirelessPhy \
	-channelType Channel/WirelessChannel \
	-topoInstance $topo \
	-agentTrace ON \
	-routerTrace ON
}

proc def_mobile_config { } {
   global ns

   $ns node-config \
	-mipv6 ON \
	-mipagent MN \
	-wiredRouting OFF \
	-adhocRouting Network \
	-mobileIP ON 
}

