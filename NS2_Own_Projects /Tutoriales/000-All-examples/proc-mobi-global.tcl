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
# ############################################################################
# Proc for local-mobility
# ############################################################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set mobile into a new BS coverage 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc enter_bs {oldbs_ newbs_} {
   # This may require to change X,Y coordinates
   puts "Node/MobileNode instproc enter_bs not implemented"
   exit 1
}

# ############################################################################
# Proc for global-mobility
# ############################################################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Allow mobile node to receive and send DTGs in new site 
# => Set Network interface of mobile to a new channel 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc enter-site {site_prefix} {
 global ns
 $self instvar stack_ ragent_ netif_ 
 if { [$ns set iface_] == "DUAL" } {
   set newchan [get_channel_by_prefix $site_prefix]
   set nulchan [set_null_channel]

   if ![info exists stack_] {
	set stack_ 0
   }
   $netif_($stack_) removechan  

   if { $stack_ == 1 } {
	set stack_ 0
   } else {
	set stack_ 1
   }
   $newchan changeif $netif_($stack_)

   # XXX: We should have a proc that return top of the interface stack
   # XXX: because it may not always be ll_
   $ragent_ target [$self set ll_($stack_)]

 } else {
   set newchan [get_channel_by_prefix $site_prefix]
   $self change_channel $newchan
 }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Test 05/01
# XXX apparently, we don't need this
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc set-site {site_prefix} {
   global ns 
   $self instvar stack_ ragent_ netif_ 

   set newchan [get_channel_by_prefix $site_prefix]
   if ![info exists stack_] {
	set stack_ 0
   }
   if { $stack_ == 1 } {
	set stack_ 0
   } else {
	set stack_ 1
   }
   $newchan changeif $netif_($stack_)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Test 05/01
# XXX apparently, we don't need this
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc leave-site {} {
   set nulchan [set_null_channel]
   $nulchan changeif $netif_($stack_)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Remove netif from previous channel and add it to new channel
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Node/MobileNode instproc change_channel {newchan} {
   $self instvar netif_

   $newchan changeif $netif_(0)
   # XXX: Set netif's new downtarget
   # XXX: Seems to be useless (done by channel ?)
   # XXX: $netif_(0) channel $newchan
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Returns the channel object corresponding to the site_prefix 
# Assume there is one channel per site
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc get_channel_by_prefix { site_prefix } {
   global all_channels

    if ![info exists all_channels($site_prefix)] {
	puts "get_channel_by_prefix $site_prefix: no channel for this site"
    }
    return $all_channels($site_prefix)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Returns the channel object corresponding to the address
# Assume there is one channel per site
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc get_channel_by_addr {addr} {
   global all_channels

   set site_prefix [get_site_prefix $addr]
   if ![info exists all_channels($site_prefix)] {
      puts "get_channel_by_addr $addr: no channel for this site"
   }
   return $all_channels($site_prefix)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set a new channel if no one exists for this site
# Returns the channel object corresponding to the address
# Assume there is one channel per site
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc set_channel_by_addr {address} {
   global all_channels

   set site_prefix [get_site_prefix $address]

   # If no channel has been allocated to this site, create one
   if ![info exists all_channels($site_prefix)] {
      set all_channels($site_prefix) [new [[Simulator instance] set channelType_]]
   }
   return $all_channels($site_prefix)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OK 05/2001
# Set a fake channel used for "idle" interfaces
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc set_null_channel {} {
   global all_channels

   # If not already created, create it
   if ![info exists all_channels(null)] {
      set all_channels(null) [new [[Simulator instance] set channelType_]]
   }
  return $all_channels(null)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MN enters a new site (i.e. it moves from one channel to another)
# In order to limit simulation memory and trace files:
# - BS(s) in new site start to emit beacons
# - BS(s) in previous site stop to do so
# - Then we switch to the new site 
# - XXX: this may cause problems if more than one MN
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc enter-site {mob_num site_num time} {
   global ns opt TOPOM
   set mob [get_mobile_by_index $mob_num]

   # Get BSs in current site and stop beacon emisson

   # First, get the BS I was attached to in order
   # to determine in which site I was.  Then, find
   # out what are all the BSs in the same site. 
   set cbs [$mob get-bs]
   if { [$TOPOM is_valid_addr $cbs] == "TRUE" } {
        set cp [get_site_prefix $cbs]
        set cbs_id_list [$TOPOM get_bs_by_site $cp]
        foreach cbs_id $cbs_id_list { 
          set cbs [$ns get-node-by-id $cbs_id]      
          set cbs_regagent [$cbs set regagent_]
          $cbs_regagent stop-beacon
        } 
   } 
   # else there is probably no registered BS 

   # Get BSs in new site and start beacon emisson
   if { $time < $opt(stop) } { 
      set site_prefix [$TOPOM get_site_prefix_by_num $site_num]
      set bs_id_list [$TOPOM get_bs_by_site $site_prefix]

      foreach bs_id $bs_id_list { 
         set bs [$ns get-node-by-id $bs_id]      
         set bs_regagent [$bs set regagent_]
         $ns at $time.02 "$bs_regagent start-beacon"
         # $bs_regagent start-beacon
      } 
      $ns at $time.01 "$mob enter-site $site_prefix"
   }
}

