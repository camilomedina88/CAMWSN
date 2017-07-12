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
# Display simulation parameters 
################################################################
proc display-param { } {
   global opt infof 

   puts $infof ""
   puts $infof "Simulation parameters:"
   puts $infof "\tRecord Interval for trace = every $opt(record_interval) sec"

   puts $infof "Files:"
   puts $infof "\tBS Configuration file = $opt(bs_config_file)"
   puts $infof "\tCN Configuration file = $opt(cn_config_file)"
   puts $infof "\tTopology file = $opt(topo_file)"
   puts $infof "\tScenario file = $opt(scen_file)"
   puts $infof "\tTrace file = $opt(tracefile)"

   puts $infof "Variables:"
   puts $infof "\tRandom Seed = $opt(seed)"
   puts $infof "\tProtocol = $opt(protocol)"
   puts $infof "\tStop Time = $opt(stop)"
   
   puts $infof "Configuration:"
   puts $infof "\tnb Mobile Nodes = $opt(mn_nn)"
   puts $infof "\tnb Correspondent Nodes = $opt(cn_nn)"
   puts $infof "\tnb Base Stations per site = $opt(bs_nn)"
   puts $infof "\tTopography: $opt(x) x $opt(y)"
   puts $infof "\tConfiguration MNs: $opt(mn_config)"
   puts $infof "\tConfiguration BSs: $opt(bs_config)"
   puts $infof "\tConfiguration RPs: $opt(rp_config)"
   puts $infof "\tCN config: $opt(cn_config)"
   puts $infof "\tCN traffic: $opt(cn_traffic)"
   puts $infof "\tConfiguration Sites: $opt(site_config)"
   puts $infof "\tConfiguration Scenario: $opt(scen_config)"
}

################################################################
# Display some info about topology / addressing / channels
# proc tm_XXX needs TOPOMAN Library
################################################################
#proc display-all-info { } {
#  tm_display_all_topo
#  display_all_channels
#  display_ns_addr_domain
#}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Display channels to see what's going on
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc display_all_channels {} {
   global all_channels
   puts ""
   puts "  >---------------------- Channels -----------------------<"
   foreach i [array name all_channels] {
        puts "\tStub $i has channel $all_channels($i)"
   }
   puts "  >---------------------- [array size all_channels] channels \
		--------------------<"
   puts ""
}

