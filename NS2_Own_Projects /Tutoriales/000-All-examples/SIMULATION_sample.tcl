#
# Copyright (c) 2012 Regents of the SIGNET lab, University of Padova.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the University of Padova (SIGNET lab) nor the 
#    names of its contributors may be used to endorse or promote products 
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# This script allows two nodes (one transmitter and one receiver) to communicate using a patch module that directly connects
# nodes with the dumb wirless channel of NS-Miracle
#
# STACK adopted in this sample: UWCBR/UWUDP/UWstaticROUTING/UWIP/UWMLL/ALOHA/UWMPHYPATCH
# 
#
#	+-----------------------+	                        +-----------------------+
#	|    7.  UWCBR  (tx)    |------------------------------>|      7. UWCBR(rx)     |
#	+-----------------------+	                        +-----------------------+
#	|       6. UWUDP        |                               |       6. UWUDP        |
#	+-----------------------+	                        +-----------------------+
#	|  5. UWstaticROUTING   |                               |  5. UWstaticROUTING   |
#	+-----------------------+	                        +-----------------------+
#	|       4. UWIP         |                               |       4. UWIP         |
#	+-----------------------+	                        +-----------------------+
#	|       3. UWMLL        |                               |       3. UWMLL        |
#	+-----------------------+                               +-----------------------+
#	|     2.   ALOHA        |                               |    2.    ALOHA        |
#       +.......................+                               +.......................+
#	:     1. MPHYPATCH      :                               :     1. MPHYPATCH      :
#	+.......................+	                        +.......................+
#                     |                                               |
#	       +--------------------------------------------------------------+
#              |                       DumbWirelessChannel                    |
#              +--------------------------------------------------------------+
#
# Author: Riccardo Masiero
# Version: 1.0.0
# NOTE: tcl sample tested on Ubuntu 12.04, 64 bits OS

######################
# Simulation Options #
######################
# Put here flags to enable or disable high level options for the simulation setup (optional)

#####################
# Library Loading   #
#####################
# Load here all the NS-Miracle libraries you need
# e.g.,
load libMiracle.so
load libmphy.so
load libMiracleWirelessCh.so 
load libMiracleBasicMovement.so
load libuwip.so
load libuwmll.so
load libuwstaticrouting.so
load libuwaloha.so
load libuwudp.so
load libuwcbr.so
load libuwcbrtracer.so
load libuwmphypatch.so

#############################
# NS-Miracle initialization #
#############################
# You always need the following two lines to use the NS-Miracle simulator
set ns [new Simulator]
$ns use-Miracle

##################
# Tcl variables  #
##################
# Put here all the tcl variables you need for simulation management (optional), namely, values for the binded variables, location parameters, module configuration's parameters, ...

set opt(start) 0
set opt(stop) 15
set opt(tr_file_name) "SIMULATION_test"

# time when actually to stop the simulation
set time_stop [expr "$opt(stop)+5"]

#Trace file name
set tf_name "${opt(tr_file_name)}.tr"

#Open a file for writing the trace data
set tf [open $tf_name w]
$ns trace-all $tf

#########################
# Module Configuration  #
#########################
# Put here all the commands to set globally the initialization values of the binded variables (optional)

# variables for the CBR module
Module/UW/CBR set period_              4
Module/UW/CBR set PoissonTraffic_      0

################################
# Procedure(s) to create nodes #
################################
# Define here one or more procedures that allow you to create as many different kind of nodes
proc createNode { id } {
    
    # include all the global variable you are going to use inside this procedure
    global ns opt node_ app_ transport_ port_ routing_ ipif_ mll_ mac_ phy_
    
    # build the NS-Miracle node
    set node_($id) [$ns create-M_Node]

    # define the module(s) you want to put in the node
    # APPLICATION LAYER
    set app_($id) [new Module/UW/CBR]
    
    # TRANSPORT LAYER
    set transport_($id) [new Module/UW/UDP]

    # NETWORK LAYER
    # Static Routing
    set routing_($id) [new Module/UW/StaticRouting]
	
    # IP interface
    set ipif_($id) [new Module/UW/IP]
	
    # DATA LINK LAYER - MEDIA LINK LAYER
    set mll_($id) [new Module/UW/MLL]
    
    # DATA LINK LAYER - MAC LAYER
    set mac_($id) [new Module/UW/ALOHA]

    # PHY LAYER
    set phy_($id) [new Module/UW/MPhypatch]
    
    # insert the module(s) into the node
    $node_($id) addModule 7 $app_($id) 1 "CBR"
    $node_($id) addModule 6 $transport_($id) 1 "UDP"
    $node_($id) addModule 5 $routing_($id) 1 "IPR"
    $node_($id) addModule 4 $ipif_($id) 1 "IPIF"
    $node_($id) addModule 3 $mll_($id) 1 "ARP TABLES"
    $node_($id) addModule 2 $mac_($id) 1 "ALOHA"
    $node_($id) addModule 1 $phy_($id) 1 "PHY PATCH" 
    
    # intra-node module connections (if needed)
    $node_($id) setConnection $app_($id) $transport_($id) trace
    $node_($id) setConnection $transport_($id) $routing_($id) trace
    $node_($id) setConnection $routing_($id) $ipif_($id) trace
    $node_($id) setConnection $ipif_($id) $mll_($id) trace
    $node_($id) setConnection $mll_($id) $mac_($id) trace
    $node_($id) setConnection $mac_($id) $phy_($id) trace
    
    # set module and node parameters (optional)
    
    # assign a port number to the application considered (CBR or VBR)
    set port_($id) [$transport_($id) assignPort $app_($id)]
    # set IP address
    $ipif_($id) addr "1.0.0.${id}"

    # initialize node's modules (if needed)
    
    # add node positions (optional: required by the DumbWireless channel of NS-Miracle)
    set position($id) [new "Position/BM"]
    $node_($id) addPosition $position($id)
    $position($id) setX_ $id.0
    $position($id) setY_ 0.0      
}

#################
# Node Creation #
#################
# Create here all the nodes you want to network together
createNode 1
puts "node 1 created!"
createNode 2
puts "node 2 created!"

################################
# Inter-node module connection #
################################
# Put here all the commands required to connect nodes in the network (optional), namely, specify end to end connections, fill ARP tables, define routing settings

# connections at the application level
$app_(1) set destAddr_ [$ipif_(2) addr]
$app_(1) set destPort_ $port_(2)

# connections at the network layer
# addRoute (destination, mask, next hop)
$routing_(1) addRoute [$ipif_(2) addr-string] "255.255.255.255" [$ipif_(2) addr-string]

# connection at the data link layer
# $mll($id1) addentry [$ipif($id2) addr] [$mac($id2) addr]
$mll_(1) addentry [$ipif_(2) addr] [$mac_(2) addr]
$mll_(2) addentry [$ipif_(1) addr] [$mac_(1) addr]

# connection to the channel
set channel [new Module/DumbWirelessCh]

$node_(1) addToChannel $channel $phy_(1) trace 
$node_(2) addToChannel $channel $phy_(2) trace

#####################
# Start/Stop Timers #
#####################
# Set here the timers to start and/or stop modules (optional)
# e.g., 
$ns at $opt(start) "$app_(1) start"
$ns at $opt(stop) "$app_(1) stop"

###################
# Final Procedure #
###################
# Define here the procedure to call at the end of the simulation
proc finish {} {
   
   global ns tf tf_name	
   # computation of the statics

   # display messages
   puts "done!"
   puts "tracefile: $tf_name"

   # save traces
   $ns flush-trace
   
   # close files
   close $tf
}

##################
# Run simulation #
##################
# Specify the time at which to call the finish procedure and halt ns
$ns at $time_stop "finish; $ns halt"

# You always need the following line to run the NS-Miracle simulator
$ns run
