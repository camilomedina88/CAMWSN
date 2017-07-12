source $env(RCA_LIBRARY)/timer.tcl
source $env(RCA_LIBRARY)/meta/new-key-set.tcl
source $env(RCA_LIBRARY)/meta/ns-key-meta.tcl
source $env(RCA_LIBRARY)/meta/ns-advlist.tcl
source $env(RCA_LIBRARY)/resources/ns-neighbor-resource.tcl
source $env(RCA_LIBRARY)/resources/ns-energy-resource.tcl
source $env(RCA_LIBRARY)/resources/ns-resource-manager.tcl
source $env(RCA_LIBRARY)/misc/overlappingkey.tcl
#source $env(RCA_LIBRARY)/misc/simplekey.tcl
source $env(RCA_LIBRARY)/misc/ns-rca-stats.tcl
source $env(RCA_LIBRARY)/misc/rca-sim-utils.tcl
source $env(RCA_LIBRARY)/ns-rca.tcl
source $env(RCA_LIBRARY)/ns-rca-flooding.tcl
source $env(RCA_LIBRARY)/ns-ranode.tcl

# ======================================================================
# Default Script Options
# ======================================================================

set opt(rcapp)         "Application/RCApp"  ;# Agent type
set opt(interval)      .01		            ;# Checking interval
set opt(statsfile)     "rca" 		        ;# name of statistics trace file
set opt(tr)     			 "rca" 		        ;# name of trace file
set opt(mtype)         "KeyMetaData"        ;# Meta-data type
set opt(overlap)       1 		            ;# Amount of data overlap
set opt(bw)            1e6                  ;# bits/sec
set opt(prop_speed)    3e8                  ;# meters/sec (speed of light)
set opt(xcvr_power)    200e-3               ;# Transceiver-- 200mW
set opt(amp_power)     400e-3               ;# Power Amp-- 400mW
set opt(comp_power)    600e-3               ;# Processor-- 600mW
set opt(proc_speed)    1e9                  ;# Processor speed-- 1G ops/sec
set opt(xcvr_cost)     [expr [expr $opt(xcvr_power) / $opt(bw) ] * 8]
set opt(amp_cost)      [expr [expr $opt(amp_power)  / $opt(bw) ] * 8]
set opt(comp_cost)     [expr $opt(comp_power) / $opt(proc_speed)]
set opt(init_energy)   8000                 ;# initial energy level
set opt(thresh_energy) 100		            ;# threshold for power adaptation
set opt(ll)            RCALinkLayer         ;# our arpless link-layer
set opt(mac)		   		 Mac/802_11           ;# we assume 802.11


# ===== Get rid of the warnings in bind ================================
Resource/Energy set energyLevel_ $opt(init_energy)
Resource/Energy set alarmLevel_ $opt(thresh_energy)
Resource/Energy set expended_ 0

Agent/RCAgent set sport_        0
Agent/RCAgent set dport_        0
Agent/RCAgent set packetMsg_    0
Agent/RCAgent set packetSize_   0


RCALinkLayer set mindelay_		  50us
RCALinkLayer set delay_			    25us
RCALinkLayer set bandwidth_		  0	  ;# not used
RCALinkLayer set off_prune_		  0	  ;# not used
RCALinkLayer set off_CtrMcast_	0	  ;# not used
RCALinkLayer set macDA_	        0	  ;# not used

set MacTrace			OFF

Phy/WirelessPhy set PXcvr_ 0

# This is an unfortunate hack that we do to get
# our own, one-time only initializations into the simulation. 
set rca_initialized 0

proc rca-create-mobile-node { id } {
    global ns_ chan prop topo tracefd opt node_ ns
    global chan prop tracefd topo opt rca rcagent
    global rca_initialized

    if {$rca_initialized == 0} {
			rca_init
			set rca_initialized 1
    }

    puts "Creating mobile node $id"

    set node_($id) [new MobileNode/ResourceAwareNode]
    set node $node_($id)

    $node set-energy $opt(init_energy) $opt(thresh_energy)

    $node random-motion 0		;# disable random motion
    $node topography $topo

    # connect up the channel
    $node add-interface $chan $prop $opt(ll) $opt(mac)	\
				$opt(ifq) $opt(ifqlen) $opt(netif) $opt(ant)

    #
    # This Trace Target is used to log changes in direction
    # and velocity for the mobile node and log actions of the DSR agent
    #
    set T [new Trace/Generic]
    $T target [$ns_ set nullAgent_]
    $T attach $tracefd
    $T set src_ $id
    $node log-target $T

    $ns_ at 0.0 "$node_($id) start-app"
}

proc rca_init {} {

    global ns_ opt ns

    # Disgusting hack required because the timer
    # code has hard-coded the global variable ns to
    # be the simulator.
    set ns $ns_

    # RCA Specific Initialization Commands
    set fc [new FinishCheck]
    $fc set finish_command_ "rca_finish"
    $fc set check_command_ "rca_check_wants_empty"
    $fc set interval_ $opt(interval)

    $ns_ at 0.0 "[$fc set check_command_]"
    $ns_ at 0.0 "$fc sched $opt(interval)"

    rca_init_stats $opt(statsfile)

    $ns_ at $opt(stop) "[$fc set finish_command_]"
}

