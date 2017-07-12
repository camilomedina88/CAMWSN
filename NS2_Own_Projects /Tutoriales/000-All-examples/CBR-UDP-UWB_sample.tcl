#       http://code.google.com/p/hsbt/source/browse/wiki/Sample_TCL_Script.wiki?r=140


# = Sample TCL Script =
# === Please note that alternative values are written as comments ===
{{{
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
                         -agentTrace OFF \
                         -routerTrace OFF \
                         -macTrace OFF \
                         -movementTrace OFF \
                         -energyModel $val(energy) \
                         -initialEnergy $val(initialenergy)
# Create Nodes

 for {set i 0} {$i < $val(nn) } {incr i} {
                set filename "$r$val(controller)$val(agent)node$i.csv"
                set nodeTrace($i) [open $filename w]
                set node_($i) [$ns_ node $i]
               
                #$node_($i) set X_ [expr (5 * $i) + 10]
                #$node_($i) set Y_ 25.0
                #$node_($i) set Z_ 0.0

                $node_($i) rt AODV
                $node_($i) on
                #$ns_ initial_node_pos $node_($i) 10
                [$node_($i) set l2cap_] set ifq_limit_ 30 ;#set the size of the queue for the L2CAP layer
                $node_($i) set-rate 3   ;# set 3mb high rate
                set bb($i) [$node_($i) set bb_]
                $bb($i) set energy_ $val(initialenergy)
                $bb($i) set activeEnrgConRate_ $val(btActiveEnrgConRate_)

                puts $nodeTrace($i) "Time BTEn AmpEn IdleT IdleE TXT TXE RXT RXE"
        }
        ############# Add 802.11 PAL #####################
        for {set i 0} {$i < $val(nn) } {incr i} {
                $node_($i) add-PAL $val(palType) $val(version) $topo $chan $val(prop) \
                $val(txPower_) $val(rxPower_) $val(idlePower_) \
                $val(sleepPower_) $val(transitionPower_) $val(transitionTime_) \
                $modulationInstance_
        }
set ifq [new Queue/DropTail] ;#Declaration of the queue or buffer
$ifq set limit_ 20 ;#Limit the queue (packet)

# Initialize Node Coordinates


#$node_(0) pos 5.0 5.0

#$node_(1) pos 15.0 5.0

#$node_(2) pos 5.0 50.0

#$node_(3) pos 15.0 50.0

 

# Setup traffic flow between nodes
puts "nc = $val(numberOfConnections)"
puts "nn = $val(nn)"
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
        #$app($i) set interval_ $val(interval)          ;##### frange( 0.001, 0.05, 0.0005 )
        $app($i) attach-agent $agent($i)             ;# Attach Application to agent

        #connection trace
        set filename "$r$val(controller)$val(agent)connection$i.csv"
        set connectionTrace($i) [open $filename w]
        puts $connectionTrace($i) "Time bytes packets Throughput loss delay totalReceived totalLost"
        # Initialize Flags
       
        set holdtime($i) 0
        set holdseq($i) 0
        set holdrate($i) 0
        set sentBytes($i) 0
        set receivedBytes($i) 0
        set oldReceivedBytes($i) 0
        set totalSentBytes($i) 0
        set totalReceivedBytes($i) 0
        set totalLost($i) 0
        set totalReceivedBytes($i) 0
        set avgDelay($i) 0
        set count($i) 0
        set totalTime($i) 0
}

# Function To record Statistcis (Bit Rate, Delay, Drop)

 

proc record {} {

        global node_ app agent sink holdtime holdseq holdrate receivedBytes oldReceivedBytes sentBytes \
        totalSentBytes totalReceivedBytes totalLost nodeTrace connectionTrace val avgDelay count totalTime

        set ns [Simulator instance]

        set time 0.5 ;#Set Sampling Time to 0.9 Sec

        set totalDataRate 0
        set totalBytes 0
       
        for {set i 0} {$i < $val(numberOfConnections) } {incr i} {
        set now [$ns now]
               
        if { $val(agent)=="UDP"} {
                set b($i) [$sink($i) set bytes_]
                set l($i) [$sink($i) set nlost_]
                set lpt($i) [$sink($i) set lastPktTime_]
                set np($i) [$sink($i) set npkts_]
        } else {
                set b($i) [$agent($i) set ndatabytes_]
                set l($i) [$agent($i) set nrexmitpack_]
                set np($i) [$agent($i) set ndatapack_]
                set lpt($i) $now
puts "agent window = [$agent($i) set cwnd_]
num retra [$agent($i) set nrexmit_]
re pack num [$agent($i) set nrexmitpack_]
re byte num [$agent($i) set nrexmitbytes_]
num pack [$agent($i) set ndatapack_]
num bytes [$agent($i) set ndatabytes_]
num ack pack [$agent($i) set nackpack_]

num red [$agent($i) set ncwndcuts_]
num red res [$agent($i) set necnresponses_]
num red cong [$agent($i) set ncwndcuts1_]
"
        }

               
               
        set receivedBytes($i) [expr ($receivedBytes($i)+$b($i))]
       
       
        set totalReceivedBytes($i) [expr ($totalReceivedBytes($i)+$b($i))]
        set totalLost($i) [expr ($totalLost($i)+$l($i))]

        # Record Received Bytes in Trace Files // # Record Bit Rate in Trace Files // # Record Packet Loss Rate in File // # Record Packet Delay in File // total received // total lost
        set delay($i) [expr ($np($i) - $holdseq($i))]

        if { $np($i) > $holdseq($i) } {
                  set delay($i) [expr ($lpt($i) - $holdtime($i))/($np($i) - $holdseq($i))]
         }

        set totalDataRate [expr ($totalDataRate + [expr (($b($i)+$holdrate($i))*8)/(2*$time*1000000)])]
        set totalBytes [expr ($totalBytes + $receivedBytes($i))]
    # 2= to average the rate of this record and the previous one
    if { [expr (($b($i)+$holdrate($i))*8)/(2*$time*1000000)] > 0 } {
        puts $connectionTrace($i) "$now $receivedBytes($i) $np($i) [expr (($b($i)+$holdrate($i))*8)/(2*$time*1000000)] [expr $l($i)/$time] $delay($i) $totalReceivedBytes($i) $totalLost($i)"
        # do not consider the first entry in calculating the averages
        if { $holdrate($i) > 0 } {
            if { $delay($i) > 0 } {
              set avgDelay($i) [expr ($avgDelay($i) + $delay($i))]
              set count($i) [expr ($count($i)+1)]
            }
        }
        if { $oldReceivedBytes($i) !=  $receivedBytes($i) } {
            set totalTime($i) [expr ($totalTime($i) + $time)]
     
        }
    }

                # Reset Variables
               
        if { $val(agent)=="UDP"} {
                $sink($i) set nlost_ 0
                $sink($i) set bytes_ 0
        } else {
                $agent($i) set ndatabytes_ 0
                $agent($i) set nrexmitpack_ 0
        }
                set oldReceivedBytes($i) $receivedBytes($i)
                set holdtime($i) $lpt($i)
                set holdseq($i) $np($i)
                set holdrate($i) $b($i)
        }


for {set i 0} {$i < $val(nn) } {incr i} {
                set bb($i) [$node_($i) set bb_]
                set btEn($i) [$bb($i) set energy_]
                #amp Energy
                set ampEn($i) [$node_($i) ampEnergy]
                set ampIdleT($i) [$node_($i) ampIdleTime]
                set ampIdleE($i) [$node_($i) ampEnergyIdle]
                set ampTXT($i) [$node_($i) ampTXTime]
                set ampTXE($i) [$node_($i) ampEnergyTX]
                set ampRXT($i) [$node_($i) ampRXTime]
                set ampRXE($i) [$node_($i) ampEnergyRX]
               
                puts $nodeTrace($i) "$now $btEn($i) $ampEn($i) $ampIdleT($i) $ampIdleE($i) $ampTXT($i) $ampTXE($i) $ampRXT($i) $ampRXE($i)"
        }
        if {$totalDataRate == 0 && $totalBytes > 0 && [$ns now] > $val(trafficStartTime)} {
                $ns at [expr ([$ns now]+0.5)] "stop"
        } else {
                $ns at [expr $now+$time] "record"   ;# Schedule Record after $time interval sec
        }

}

# Stop Simulation at Time 80 sec
#$ns_ at $val(simulationStopTime) "stop"

# Start Recording at Time 0
$ns_ at 0.0 "record"
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



# Exit Simulatoion at Time 80.01 sec
#$ns_ at 15.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
        global ns_ resultsf tracefd namtrace nodeTrace connectionTrace val r avgDelay count totalReceivedBytes totalTime totalLost sink node_
       
        set networkDelay 0
        set networkThroughput 0
        set networkEnergyConsumption 0
        set networkDeliveryRatio 0
        set networkBytesReceived 0
        set networkEnergyPerBit 0
        set nonEstablishedConnections 0
        set simulationTotalTime 0

        puts $resultsf "agent controller Run_id application_Generation_Rate(bps) packet_Size(bytes) #nodes #Connections Distance(m) connection_id from to  avg_Delay(sec) avg_rate(Mbps) avg_lost_ratio%(%packets) sent(bytes) received(bytes) total_time(sec) count Energy_per_bit(wpb)"
        for {set i 0} {$i < $val(numberOfConnections) } {incr i} {
                close $connectionTrace($i)
            set from [expr (2 * $i)]
            set to [expr ((2*$i)+1)]
            if { $i >= [expr ($val(nn)/2)]} {
              set from [expr (($i % ($val(nn)/2))*2+1)]
              set to [expr (($i % ($val(nn)/2))*2)]
            }
           
          set bb($to) [$node_($to) set bb_]
          set btEn($to) [$bb($to) set energy_]
          #amp Energy
          set ampEn($to) [$node_($to) ampEnergy]
          set totalEn($to) [expr (2 * $val(initialenergy) - $btEn($to) - $ampEn($to))]
        if { $val(agent)=="UDP"} {
          set np($i) [$sink($i) set npkts_]
        } else {
          set np($i) 0
        }
         
                if { $count($i) == 0 } {
                        set count($i) 1
                        set nonEstablishedConnections [expr ($nonEstablishedConnections + 1)]
                }
                if { $totalTime($i) == 0 } {
                        set totalTime($i) 1
                }
                if { $totalLost($i) == 0 } {
                        set totalLost($i) 1
                }
                if { $totalReceivedBytes($i) == 0 } {
                        set totalReceivedBytes($i) 1
                }
            #   Average_Delay = Sum_of_all_Packet_Delays / Total_Num_of_Received_Pkts
            #           Connection Throughput =(Total_Data_Bits_Received) / (Simulation_Runtime)
            #     Delivery_Ratio = (Number_of_Received_Packets / Number_of_Transmitted_Packets) * 100
            #           Connection sent bytes size      
            #   Connection received bytes size
            #  Watt per bit
            #
            puts $resultsf "$val(agent) $val(controller) $r $val(packetGenerationRate) $val(packetSize) $val(nn) $val(numberOfConnections) NA $i $from $to  [expr ($avgDelay($i)/$count($i))] [expr (($totalReceivedBytes($i) * 8)/($totalTime($i) * 1000000))] [expr ($totalLost($i)*100 /($np($i)+$totalLost($i)))] NA $totalReceivedBytes($i) $totalTime($i) $count($i) [expr ($totalEn($to) / ($totalReceivedBytes($i) * 8))]"
           
   
            set networkDelay [expr ($networkDelay + [expr ($avgDelay($i)/$count($i))] )]
            set networkThroughput [expr ($networkThroughput + [expr (($totalReceivedBytes($i) * 8)/($totalTime($i) * 1000000))])]
            set networkDeliveryRatio [expr ($networkDeliveryRatio + [expr (100*$totalLost($i)/($np($i)+$totalLost($i)))])]
            set networkBytesReceived [expr ($networkBytesReceived + $totalReceivedBytes($i))]
            set networkEnergyPerBit [expr ( $networkEnergyPerBit + $totalEn($to))]
            set simulationTotalTime [expr ($simulationTotalTime + $totalTime($i))]
        puts "$i node = $to energytotal = $networkEnergyPerBit //// after adding $totalEn($to)\n"
        }

 

  puts $resultsf "agent controller Run_id application_Generation_Rate(bps) packet_Size(bytes) #nodes #Connections Distance(m) node_id BT_energy(%mW) AMP_energy(%mW) total_energy_consumption(%mW) bt ampTotal idleE idleT RXE RXT TXE TXT sleepE sleepT"        
        for {set i 0} {$i < $val(nn) } {incr i} {
                close $nodeTrace($i)
         
        set totalEn($i) [expr (2 * $val(initialenergy) )]
       
        set bb($i) [$node_($i) set bb_]
          set btEn($i) [$bb($i) set energy_]
          set totalEn($i) [expr ($totalEn($i) - $btEn($i))]
          #  Percent_Energy_Consumed = (InitialEnergy - FinalEnergy) / InitialEnergy * 100  
          set btEn($i) [expr (($val(initialenergy) - $btEn($i))*100/$val(initialenergy))]
          #amp Energy
          set ampEn($i) [$node_($i) ampEnergy]


          set totalEn($i) [expr ($totalEn($i) - $ampEn($i))]

          set ampEn($i) [expr (($val(initialenergy) - $ampEn($i))*100/$val(initialenergy))]
               
          set totalEn($i) [expr (($totalEn($i))*100/(2*$val(initialenergy)))]
          set networkEnergyConsumption [expr ($networkEnergyConsumption + $totalEn($i))]
         
         
          puts $resultsf "$val(agent) $val(controller) $r $val(packetGenerationRate) $val(packetSize) $val(nn) $val(numberOfConnections) NA $i $btEn($i) $ampEn($i) $totalEn($i) [$bb($i) set energy_] [$node_($i) ampEnergy] [$node_($i) ampEnergyIdle] [$node_($i) ampIdleTime] [$node_($i) ampEnergyRX] [$node_($i) ampRXTime] [$node_($i) ampEnergyTX] [$node_($i) ampTXTime] [$node_($i) ampEnergySleep] [$node_($i) ampSleepTime]"
           
        }
       
       
    #    Network_Throughput = (Sum_of_Throughput_of_Nodes_Involved_in_Data_Trans.) / (Number_of_Nodes)
    set networkThroughput [expr ($networkThroughput / $val(numberOfConnections) )]
    set networkDeliveryRatio [expr ($networkDeliveryRatio / $val(numberOfConnections))]  
    set networkDelay [expr ($networkDelay / $val(numberOfConnections))]  
    set simulationTotalTime [expr ($simulationTotalTime / $val(numberOfConnections))]  
    #    Average_Energy_Consumed = Sum_of_Percent_Energy_Consumed_by_All_Nodes / Number_of_Nodes
    set networkEnergyConsumption [expr ($networkEnergyConsumption / $val(nn))]
   
puts " energytotal = $networkEnergyPerBit //// bytes total = $networkBytesReceived EPB results = [expr (($networkEnergyPerBit /$networkBytesReceived)/ 8) ]\n"

    set networkEnergyPerBit [expr (($networkEnergyPerBit /$networkBytesReceived)/ 8) ]
   
    puts $resultsf "agent controller Run_id application_Generation_Rate(bps) packet_Size(bytes) #nodes #Connections Distance(m) avg_NW_Delay(sec) avg_NW_rate(Mbps) avg_NW_lost_ratio(%packets) NW_sent(bytes) NW_received(bytes) NW_Energy_per_bit(wpb) NW_total_energy_consumption(%mW) #nonEstablishedConnections simulationTotalTime"      
    puts $resultsf "$val(agent) $val(controller) $r $val(packetGenerationRate) $val(packetSize) $val(nn) $val(numberOfConnections) NA $networkDelay $networkThroughput $networkDeliveryRatio NA $networkBytesReceived $networkEnergyPerBit $networkEnergyConsumption $nonEstablishedConnections $simulationTotalTime"
 
        close $resultsf

       # Plot Recorded Statistics
        #exec xgraph data1.tr data2.tr data3.tr data4.tr data5.tr data6.tr data7.tr -t "Data Recieved in Bytes" -geometry 800x400 &
        #exec xgraph out1.tr out2.tr out3.tr out4.tr out5.tr out6.tr out7.tr -t "Bit Rate" -geometry 800x400 &
        #exec xgraph lost1.tr lost2.tr lost3.tr lost4.tr lost5.tr lost6.tr lost7.tr -t "Packet Loss Rate" -geometry 800x400 &
        #exec xgraph delay1.tr delay2.tr delay3.tr delay4.tr delay5.tr delay6.tr delay7.tr -t "Packet Delay" -geometry 800x400 &      
        # Reset Trace File

        $ns_ flush-trace
        close $tracefd      
        close $namtrace
        exit 0

}

puts "Starting Simulation..."

$ns_ run
}}} 
