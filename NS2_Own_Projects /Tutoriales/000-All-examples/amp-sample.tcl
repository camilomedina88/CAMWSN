# ====================================================================
# Define Node Configuration paramaters
#====================================================================
set val(mac)            Mac/BNEP                 
set val(palType)        PAL/UWB                     ;#PAL/802_11 or PAL/UWB     
set val(prop)           Propagation/TwoRayGround
set val(chan)           Channel/WirelessChannel 
set modulationInstance_ [new Modulation/CodedPPM]
set val(energy)         EnergyModel             
set val(initialenergy)  10800000        ;# Initial power in Watts = 3Wh
set val(txPower_)       108 ;# Active alternative MAC/PHY TX Energy consumption per second
set val(rxPower_)       98  ;# Active alternative MAC/PHY RX Energy consumption per second
set val(idlePower_)     80;# Active alternative MAC/PHY Idle Energy consumption per second
set val(sleepPower_)    10
set val(transitionPower_)       10 
set val(transitionTime_)        0.005 
set val(btActiveEnrgConRate_) 81       ;# Active BT Energy consumption per second       
set val(x)              50             ;# X dimension of the topography
set val(y)              50             ;# Y dimension of the topography
set val(trafficStartTime) 7
set val(trafficStopTime) 22
set val(simulationStopTime) 40
##################################################
set val(numberOfConnections)    1
set val(nn)             [expr ($val(numberOfConnections)*2)]    
set val(numberOfMACs)   [expr ($val(nn)*2)]      ;# total number of MACs = twice number of nodes as each node has 2 MACs
set val(application) "CBR"              
set val(agent)       "UDP"            ;# "UDP" , "TCP"
set val(controller)  "UWB"            ;# "BT2.1+EDR","802.11b" , "802.11g" , "UWB"
set val(version) "802.11g"            ;# "802.11b" , "802.11g" note : must be set though it is only used when the controller is "802.11b" , "802.11g"
set val(packetGenerationRate)   30000000 
set val(packetSize) 1400 
#=====================================================================
# Initialize 
#=====================================================================

# *** Initialize Simulator ***
set ns_              [new Simulator]

# *** Initialize Trace file ***
set filename "$val(controller)$val(agent)trace.csv"
set tracefd     [open $filename w]
$ns_ trace-all $tracefd
        
# *** Initialize Network Animator ***
set filename "$val(controller)$val(agent)nam.nam"
set namtrace [open $filename w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# *** set up topography object ***
set chan        [new $val(chan)]    ;#Create wireless channel
set topo        [new Topography]
$topo load_flatgrid $val(x) $val(y)

# Create  General Operations Director (GOD) object. It is used to store global information about the state of the environment, network, or nodes that an omniscent observer would have, but that should not be made known to any participant in the simulation.

create-god $val(numberOfMACs)

# configure nodes

        $ns_ node-config -macType $val(mac) \
                         -agentTrace ON \
                         -routerTrace ON \
                         -macTrace ON \
                         -movementTrace OFF \
                         -energyModel $val(energy) \
                         -initialEnergy $val(initialenergy)
# Create Nodes

 for {set i 0} {$i < $val(nn) } {incr i} {
                set node_($i) [$ns_ node $i]
                $node_($i) rt AODV
                $node_($i) on
                [$node_($i) set l2cap_] set ifq_limit_ 30 ;#set the size of the queue for the L2CAP layer
                $node_($i) set-rate 3   ;# set 3mb high rate
                set bb($i) [$node_($i) set bb_]
                $bb($i) set energy_ $val(initialenergy) 
                $bb($i) set activeEnrgConRate_ $val(btActiveEnrgConRate_) 
        }
        ############# Add PAL and the alternative MAC/PHY #####################
        for {set i 0} {$i < $val(nn) } {incr i} {
                $node_($i) add-PAL $val(palType) $val(version) $topo $chan $val(prop) \
                $val(txPower_) $val(rxPower_) $val(idlePower_) \
                $val(sleepPower_) $val(transitionPower_) $val(transitionTime_) \
                $modulationInstance_
        }
set ifq [new Queue/DropTail] ;#Declaration of the queue or buffer
$ifq set limit_ 20 ;#Limit the queue (packet)



# Setup traffic flow between nodes
for {set i 0} {$i < $val(numberOfConnections) } {incr i} {
        # Create Constant four Bit Rate Traffic sources
        if { $val(agent)=="UDP"} {
                set agent($i) [new Agent/UDP]             ;# Create UDP Agent
        } else {
                set agent($i) [new Agent/TCP]             ;# Create TCP Agent
        }
                $agent($i) set prio_ 0                   ;# Set Its priority to 0
                $agent($i) set packetSize_ 1500
        if { $val(agent)=="UDP"} {
                set sink($i) [new Agent/LossMonitor]  ;# Create Loss Monitor Sink in order to be able to trace the number obytes received
        } else {
                set sink($i) [new Agent/TCPSink]
        }
        set j [expr (2 * $i)]
        if { $i < [expr ($val(nn)/2)]} {
                $ns_ attach-agent $node_($j) $agent($i)     ;# Attach Agent to source node
                $ns_ attach-agent $node_([expr ($j+1)]) $sink($i) ;# Attach Agent to sink node
puts "<   $j [expr ($j+1)]"
        } else {
                $ns_ attach-agent $node_([expr (($i % ($val(nn)/2))*2+1)]) $agent($i)     ;# Attach Agent to source node
                $ns_ attach-agent $node_([expr (($i % ($val(nn)/2))*2)]) $sink($i) ;# Attach Agent to sink node
puts ">   [expr (($i % ($val(nn)/2))*2+1)] [expr (($i % ($val(nn)/2))*2)]"
        }
        $ns_ connect $agent($i) $sink($i)            ;# Connect the nodes
        set app($i) [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
        $app($i) set packetSize_ $val(packetSize)               ;# Set Packet Size 
        $app($i) set rate_ $val(packetGenerationRate)        ;# Set CBR rate
        $app($i) attach-agent $agent($i)             ;# Attach Application to agent
}

####################### Connections Configuration ##########################
for {set i 0} {$i < $val(numberOfConnections) } {incr i} {
        set j [expr (2 * $i)]
        if { [string compare $val(controller) "802.11b"] == 0 || [string compare $val(controller) "802.11g"] == 0 || [string compare $val(controller) "UWB"] == 0} {
                if { $i < [expr ($val(nn)/2)]} {
                        $ns_ at [expr ($i/10+0.2)] "$node_($j) make-hs-connection $node_([expr ($j+1)])"
                        puts "($j) make-hs-connection [expr ($j+1)]"
                } else {
                        #$ns_ at 0.1 "$node_([expr (($i % ($val(nn)/2))*2+1)]) make-hs-connection $node_([expr (($i % ($val(nn)/2))*2)])"
                        puts "802.11 no con"
                }
        } elseif { [string compare $val(controller) "BT2.1+EDR"] == 0 } {
                if { $i < [expr ($val(nn)/2)]} {
                        $ns_ at [expr ($i/10+0.2)] "$node_([expr ($j)]) make-bnep-connection $node_([expr ($j+1)]) 3-DH5 3-DH5 noqos $ifq"
                        puts "[expr ($j)] make-bnep-connection [expr ($j+1)] DH5 DH5 noqos $ifq"
                } else {
                        #$ns_ at 0.1 "$node_([expr ([expr (($i % ($val(nn)/2))*2+1)])]) make-bnep-connection $node_([expr (($i % ($val(nn)/2))*2)]) DH5 DH5 noqos $ifq"
                        puts "bt no con"
                }
        } else {
                error "no type defined"
        }

        $ns_ at [expr (($i/10+0.2)+1+($i*2/10))] "$app($i) start"                 ;# Start transmission AODV get route
        $ns_ at [expr (($i/10+0.2)+2+($i*2/10))] "$app($i) stop"                 ;# Stop transmission AODV get route

        $ns_ at [expr ($val(trafficStartTime)+($i*2/10))] "$app($i) start"                 ;# Start transmission
        $ns_ at [expr ($val(trafficStopTime)+($i*2/10))] "$app($i) stop"                 ;# Stop transmission 
}

###################### Stop Procedure ###########################
proc stop {} {
        global ns_ tracefd namtrace

        $ns_ flush-trace
        close $tracefd      
        close $namtrace
        exit 0
}

################### Stop Simulation ###########################
$ns_ at $val(simulationStopTime) "stop"

################### Start Simulation ###########################
puts "Starting Simulation..."
$ns_ run 
