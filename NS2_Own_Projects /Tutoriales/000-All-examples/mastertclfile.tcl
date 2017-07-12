#     http://www.dcs.warwick.ac.uk/~adhoc1/mastertclfile.html


# FileName to go here
# Description for file to go here
# Code Written by Richard Myers
    
# General Config Settings
set val(showInfo)       0                           ;# show info (=1:yes,!=1:no)
set val(nodeColor)      1                           ;# color node(=1:yes,!=1:no)
set val(chan)           Channel/WirelessChannel     ;# channel type
set val(prop)           Propagation/TwoRayGround    ;# radio-propagation model
set val(netif)          Phy/WirelessPhy             ;# network interface type
set val(mac)            Mac/802_11                  ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue     ;# interface queue type
                                                    ;# For AODV : Queue/DropTail/PriQueue
                                                    ;# For DSR  : CMUPriQueue
set val(ll)             LL                          ;# link layer type
set val(ant)            Antenna/OmniAntenna         ;# antenna model
set val(ifqlen)         50                          ;# max packet in ifq

# Protocol Specifications
set val(rp_norm)        AODV                        ;# Normal Protocol
set val(rp_trust)       TRUSTAODV                   ;# Trusted Protocol
set val(rp_black_route) BLACKHOLEonRouteAODV        ;# Black Holes Faking On Route
set val(rp_black_dst)   BLACKHOLEfakeDstReplyAODV   ;# Black Holes Facking Route + Reached Dst
set val(rp_grey)        GREYHOLEAODV                ;# Grey Holes
set val(rp_mod)         MODIFICATIONAODV            ;# Modification Nodes (Modify data/headers)

# Number of each type of node
set val(nn_norm)        38                          ;# no. Normal Nodes
set val(nn_trust)       0                           ;# no. Trusted Nodes
set val(nn_black_route) 0                           ;# no. Black Holes Facking Route
set val(nn_black_dst)   12                          ;# no. Black Holes Facking Route + Reached Dst
set val(nn_grey)        0                           ;# no. Grey Holes
set val(nn_mod)         0                           ;# no. Modification Nodes


# Communication settings
set val(numConnections) 1                           ;# Number of Connections to establish

# Topography Settings
set val(nodeSize)       30                          ;# Size to draw nodes
set val(sizeX)          1000.0                      ;# X dimension of topography
set val(sizeY)          1000.0                      ;# Y dimension of topography  
set val(stop)           900.0                       ;# time of simulation end
set val(maxVelocity)    20.0                        ;# max speed a node can move
set val(waitTime)       10.0                        ;# max time to wait before
                                                          # moving again

# True Random / Specific Random selection
# 0:random each time  &  >0 is same random position each time
set val(positionSeed)   100                         ;# initial positioning seed
set val(moveSeed)       200                         ;# new position seed
set val(velocitySeed)   300                         ;# movement velocity seed
set val(timeSeed)       400                         ;# time to wait b4 moving


# File Settings
set val(namFile)            exampleFilledOutMaster.nam     ;# Nam output file name
set val(traceFile)          exampleFilledOutMaster.tr      ;# Trace file output name
set val(javeExecLocation)   /dcs/condor/condor/bin/java    ;# location and name of java executable


#-------------------------------------------------------------------------------
# Model code starts below this line
#-------------------------------------------------------------------------------

# ----------------------- Define Global Objects --------------------------------

set ns               [new Simulator]                ;# The NS Simulator !!!
set topo             [new Topography]               ;# The Network Topology Object
set tracefd          [open $val(traceFile) w]       ;# Trace file Object
set namtrace         [open $val(namFile) w]         ;# NAM Sim File
set node_()          null                           ;# Empty array to point at nodes
set currentNodeId    0                              ;# Used in looping of protocols to ensure using the next node
set nextNodeToColor  0                              ;# Used in looping of nodes to color them in

# Calcualte and store the total number of nodes
set val(nn_total)     [expr $val(nn_norm) + $val(nn_black_route) + $val(nn_black_dst) + $val(nn_grey) + $val(nn_mod) + $val(nn_trust)]

# ------------- Random Number Generators for Node Motion -----------------------

# Set up Random Number Generators
set rngMov [new RNG]
$rngMov seed $val(moveSeed)

set rngTime [new RNG]
$rngTime seed $val(timeSeed)

set rngVelocity [new RNG]
$rngVelocity seed $val(velocitySeed)


# Used to determine new X cord
set randNoMove_x [new RandomVariable/Uniform]
$randNoMove_x use-rng $rngMov
$randNoMove_x set min_ 0.0
$randNoMove_x set max_ $val(sizeX)

# Used to determine new Y cord
set randNoMove_y [new RandomVariable/Uniform]
$randNoMove_y use-rng $rngMov
$randNoMove_y set min_ 0.0
$randNoMove_y set max_ $val(sizeY)

# Used to determine time between movments
set randNoMove_t [new RandomVariable/Uniform]
$randNoMove_t use-rng $rngTime
$randNoMove_t set min_ 0.0
$randNoMove_t set max_ $val(waitTime)

# Used to determine velocity of movement
set randNoMove_v [new RandomVariable/Uniform]
$randNoMove_v use-rng $rngVelocity
$randNoMove_v set min_ 0.0
$randNoMove_v set max_ $val(maxVelocity)


# --------------------------- Define Procedures --------------------------------

# Displays Configuration Details and start simulation
proc setupSim {} {
    
    # Get variables used
    global val ns
    
    puts "------------------------------------------------------"
    puts "                Starting Simulation"
    puts "------------------------------------------------------"
    
    if { $val(showInfo) == 1 } {
        puts "Simulation and Node Settings:"
        puts "   Number of nodes within simulation     : $val(nn_total)"
        puts "   Of which are normal nodes             : $val(nn_norm)"
        puts "   Of which are trusted nodes            : $val(nn_trust)"
        puts "   Of which are black "
        puts "     -Faking route avalaible             : $val(nn_black_route)"
        puts "     -Faking route avalaible + reach dsk : $val(nn_black_dst)"
        puts "   Of which are malicious nodes          : $val(nn_grey)"
        puts "   Of which are modiciation nodes        : $val(nn_mod)"

        puts "\nPosition and Seed Settings:"
        puts "   Using positioning seed value of       : $val(positionSeed)"
        puts "   Using movement seed value of          : $val(moveSeed)"
        puts "   Using movment time seed value of      : $val(timeSeed)"
        puts "   Using velocity seed value of          : $val(velocitySeed)"
        puts "\nFile Settings:"
        puts "   Output trace file saved to            : $val(traceFile)"
        puts "   Output simulation file saved to       : $val(namFile)"
        puts "--------------------------------------------------\n"
    }
    
    # ----------------------- Some basic error checking ------------------------
    if { [expr $val(nn_norm) + $val(nn_trust)] < [expr $val(numConnections) * 2] } {
        puts "ERROR: You must have at least [expr $val(numConnections) * 2] normal/trusted nodes within the Simulation"
        puts "       in order to send data between $val(numConnections) pairs of nodes"
        $ns halt
        exit 1
    }
    # ------------------------ End of error checking ---------------------------
    
    
    # Setup ending of simulation
    $ns at $val(stop) "stopSim"
    
}



# Ends a simulation and loads nam with results
proc stopSim {} {

    # Get global variables
    global ns val namtrace tracefd
    
    if { $val(showInfo) == 1 } {
        puts " - Finishing up simulation..."
    }
    
    # Flush the trace and Simulation files
    $ns at $val(stop) "$ns nam-end-wireless $val(stop)"
    $ns flush-trace
    close $namtrace
    close $tracefd
    
    # Marks sender, reciever and maliciouse nodes in different colours
    if { $val(nodeColor) == 1 } {
        markNodes
    }
    
    puts "------------------------------------------------------"
    puts "                End of Simulation"
    puts "------------------------------------------------------"
    
    if { $val(showInfo) == 1 } {
        # Display Simulation output in NAM
        exec nam $val(namFile) &
    }
    
    # Exit NS2
    $ns halt
    exit 0

}


# Setup Simulation Tracing
proc setupTracing {} {

    # Get global variables
    global val ns namtrace tracefd

    if { $val(showInfo) == 1 } {
        puts " - Setting up simulation tracing..."
    }

    $ns trace-all $tracefd
    $ns namtrace-all-wireless $namtrace $val(sizeX) $val(sizeY)

}


# Setup the network topology
proc setupNetworkTopology {} {

    # Get global variables
    global topo val
    
    if { $val(showInfo) == 1 } {
        puts " - Setting up network topology..."
    }
    
    # Set the topology of network to be flat (I think)
    $topo load_flatgrid $val(sizeX) $val(sizeY)

}


# Create node objects and set node configuration settings
proc setupNodeConfiguration {} {

    # Get global variables
    global ns val topo node_ currentNodeId
    
    if { $val(showInfo) == 1 } {
        puts " - Generating network nodes..."
    }

    # Create the nodes (Required...not sure why)
    create-god $val(nn_total)

    # Create network channel
    set chan_1 [new $val(chan)]
    
    
    if { $val(showInfo) == 1 } {
        puts " - Configuring normal nodes..."
    }

    # Set the global next node id
    set $currentNodeId 0
    
    # Generate each set of nodes using a different protocol
    createNodesUsing $val(nn_norm)          $val(rp_norm)            $chan_1
    createNodesUsing $val(nn_trust)         $val(rp_trust)           $chan_1
    createNodesUsing $val(nn_black_route)   $val(rp_black_route)     $chan_1
    createNodesUsing $val(nn_black_dst)     $val(rp_black_dst)       $chan_1
    createNodesUsing $val(nn_grey)          $val(rp_grey)            $chan_1
    createNodesUsing $val(nn_mod)           $val(rp_mod)             $chan_1

    
    # Tell all nodes when the simulation will end
    for { set i 0 } { $i < $val(nn_total) } { incr i } {
        $ns at $val(stop) "$node_($i) reset";
    }
        
}

# Creates a required number of nodes using specified protocol and channel
proc createNodesUsing { createNodes rpProtocol channel } {

    # Get global variables used
    global val topo ns currentNodeId node_
    
    # Set up the node configuration
    $ns node-config -adhocRouting $rpProtocol \
                    -llType $val(ll) \
                    -macType $val(mac) \
                    -ifqType $val(ifq) \
                    -ifqLen $val(ifqlen) \
                    -antType $val(ant) \
                    -propType $val(prop) \
                    -phyType $val(netif) \
                    -topoInstance $topo \
                    -agentTrace ON \
                    -routerTrace ON \
                    -macTrace OFF \
                    -movementTrace OFF \
                    -channel $channel
    
    # Some local calculations for looping
    set fromNodeId     $currentNodeId
    set toNodeId    [expr $currentNodeId + $createNodes]
    
    # Create the nodes
    for { set i $fromNodeId } { $i < $toNodeId } { incr i } {
        set node_($i) [$ns node]
    }
    
    # Set the node id to use next (if called again)
    set currentNodeId $toNodeId

}
    
# Randomly positions the nodes within the room
proc positionTheNodes {} {
    
    # Get global variables
    global node_ val ns
        
    if { $val(showInfo) == 1 } {
        puts " - Configuring nodes initial positions..."
    }
        
    # Set up Random Number Generator
    set rngPos [new RNG]
    $rngPos seed $val(positionSeed)
    
    # Set up a uniformly distributed number sgenerators for X and Y position
    set randNoX [new RandomVariable/Uniform]
    $randNoX use-rng $rngPos
    $randNoX set min_ 0.0
    $randNoX set max_ $val(sizeX)

    set randNoY [new RandomVariable/Uniform]
    $randNoY use-rng $rngPos
    $randNoY set min_ 0.0
    $randNoY set max_ $val(sizeY)
    
    # Position the nodes randomly within the zone
    for {set i 0} {$i < $val(nn_total) } { incr i } {
        $node_($i) set X_ [$randNoX value]
        $node_($i) set Y_ [$randNoY value]
        $node_($i) set Z_ 0.0
    }
    
    # Tell NAM where nodes all start at
    for {set i 0} {$i < $val(nn_total) } { incr i } {
        $ns initial_node_pos $node_($i) $val(nodeSize)
    }

}

# Sets up initial random motion
proc setupSingleRandomMovement {} {

    # Get hold of global variables
    global ns val node_ randNoMove_x randNoMove_y randNoMove_t randNoMove_v

    if { $val(showInfo) == 1 } {
        puts " - Setting up single movment for all nodes..."
    }
    

    for {set i 0} {$i < $val(nn_total) } { incr i } {
        $ns at [$randNoMove_t value] "$node_($i) setdest [$randNoMove_x value] \
                                                         [$randNoMove_y value] \
                                                         [$randNoMove_v value]"

    }

}

# Sets up multiple random movement
proc setupContinuedRandomNodeMovement {} {

    # Get global variables
    global val
    
    if { $val(showInfo) == 1 } {
        puts " - Setting up triggers for initial node movments..."
    }
    
    for {set i 0} {$i < $val(nn_total) } { incr i } {
        setNewDestination $i
    }

}

# Sets node to move at a random time to a new destination and then schedules
# itself to be called again once its moving so it can move again
proc setNewDestination { nodeId } {

    # Get global variables
    global ns val node_ randNoMove_x randNoMove_y randNoMove_t randNoMove_v
    
    # Get time to start moving...must at or after current time
    set startTime [expr [$ns now] + [$randNoMove_t value]]    
            
    # Set movment to start at startTime
    $ns at $startTime "$node_($nodeId) setdest [$randNoMove_x value] \
                                               [$randNoMove_y value] \
                                               [$randNoMove_v value]"
    
    # Calculate time of next move
    set nextTriggerTime [ expr $startTime + [$randNoMove_t value] ]
    
    # Schedule a call to trigger next movement if we have time left to move in
    if { $nextTriggerTime < $val(stop) } {
        $ns at $nextTriggerTime "setNewDestination $nodeId"
    }

}

# Marks nodes in NAM file in different colours based on there purpose
proc markNodes {} {

    # Get global variables
    global ns node_ val nextNodeToColor
    
    if { $val(showInfo) == 1 } {
        puts " - Highlighting sender and reciever..."
    }

    # Mark senders as green
    for { set i 0 } { $i < $val(numConnections) } { incr i } {
        markNodeColor $val(namFile) [expr $i * 2] green
    }
    
    # Mark recievers as red
    for { set i 0 } { $i < $val(numConnections) } { incr i } {
        markNodeColor $val(namFile) [expr [expr $i * 2] + 1] red
    }
    
    # Now we have coloured in the senders and recieers set index of next node to color
    set nextNodeToColor [expr $val(numConnections) * 2]
    
    
    # Color in remaining nodes
    if { $nextNodeToColor < $val(nn_norm) } {
        colorMultipleNodes [expr $val(nn_norm) - $nextNodeToColor] blue
    }
    if { $nextNodeToColor < [expr $val(nn_norm) + $val(nn_trust)] } {
        colorMultipleNodes [expr [expr $val(nn_trust) + $val(nn_norm)] - $nextNodeToColor] orange
    }
    colorMultipleNodes $val(nn_black_route) black
    colorMultipleNodes $val(nn_black_dst)   brown
    colorMultipleNodes $val(nn_grey)        grey
    colorMultipleNodes $val(nn_mod)         yellow

    
}

# Colours the next [numNodesToColor] from [nextNodeToColor] in [colorToUse]
proc colorMultipleNodes { numNodesToColor colorToUse } {
    
    # Get global variables used
    global val nextNodeToColor
    
    # Some local calculations for looping
    set fromNodeId     $nextNodeToColor
    set toNodeId    [expr $nextNodeToColor + $numNodesToColor]
    
    # Create the nodes
    for { set i $fromNodeId } { $i < $toNodeId } { incr i } {
        markNodeColor $val(namFile) $i $colorToUse
    }
    
    # Set the node id to use next (if called again)
    set nextNodeToColor $toNodeId
    
}

# Finds and replaces the color of a given node from default color to a new color
proc markNodeColor { fileName nodeId color } {
    
    # Get global variables
    global val
    
    # Use 'sed' to find the node for which to change color
    # then replace the color of that node from default black to specified color
    # from the supplied file name and save output file to orinalFile.tmp
    #exec sed -e "s/^\\(n -t \\* -s $nodeId .*\\) black/\\1 $color/" $fileName > $fileName.tmp

    # Method 1...scans whole file    
    #exec sed "s/^\\(n -t \\* -s $nodeId .*\\) black/\\1 $color/" $fileName > $fileName.tmp

    # Method 2...replaces only on current row
    #exec sed "[expr $nodeId + 1],[expr $nodeId + 1]s/black/$color/" $fileName > $fileName.tmp

    # Now copy newly colored output file back to the original
    #exec cat $fileName.tmp > $fileName
    
    # And then finaly delete the temp file
    #exec rm $fileName.tmp
    
    # We now use a java replacer as its faster than using sed. This creates a temp
    # file called $fileName.tmp which we then rename to be $fileName
    
    if { $val(showInfo) == 1 } {
        puts "Running Color Replace Code : "
    }
    
    # We now use a java application to do node colouring as its much faster than sed
    exec $val(javeExecLocation) -cp . -jar ColorReplacer.jar [expr $nodeId + 1] $color $fileName
    exec mv $fileName.tmp $fileName

}



proc setupUDPwithCBR {} {

    # Get global variables we use
    global val
    
    # Setup UDP Traffic Connections
    for { set i 0 } { $i < $val(numConnections) } { incr i } {
        setupUDPBetweenNodes [expr $i * 2] [expr [expr $i * 2] + 1]
    }

}

# Create a UDP/CBR connection between 2 nodes 
proc setupUDPBetweenNodes { nodeSender nodeReciever } {

    # Get global variables
    global ns node_ val

    if { $val(showInfo) == 1 } {
        puts " - Setting up UDP / CBR network traffic between nodes $nodeSender and $nodeReciever ..."
    }

    # Setup a UDP connection between sender and reciever
    set udpSender [new Agent/UDP]
    $ns attach-agent $node_($nodeSender) $udpSender
    set udpReciever [new Agent/Null]
    $ns attach-agent $node_($nodeReciever) $udpReciever
    $ns connect $udpSender $udpReciever

    # Setup a CBR over udp connection between sender and reciever
    set cbrData [new Application/Traffic/CBR]
    $cbrData attach-agent $udpSender
    $cbrData set packetSize_ 512
    $cbrData set rate_ 0.1Mb
    $cbrData set random_ false

    $ns at 0.0 "$cbrData start"

}
    
# Start the simulation
proc startSim {} {
    
    # Get global variables
    global val ns
    
    if { $val(showInfo) == 1 } {
        puts " - Running Simulation..."
    }
    $ns run
    
}


# ------------------------- Run the Simulator ----------------------------------

setupSim                           ;#Display settings used by the simulator
setupTracing                       ;#Setup the tracing files
setupNetworkTopology               ;#Set the topology of network
setupNodeConfiguration             ;#Creates basic node setup & configuration
positionTheNodes                   ;#Randomly positions the nodes
#setupSingleRandomNodeMovement     ;#Give each node a single random movment
setupContinuedRandomNodeMovement   ;#Give each node a continued random movement
setupUDPwithCBR                    ;#Use UDP Connection setup
startSim                           ;#Starts the simulation
