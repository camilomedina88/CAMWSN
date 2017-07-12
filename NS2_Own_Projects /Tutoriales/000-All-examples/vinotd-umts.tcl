######    http://vinotdtechsimulator.blogspot.dk/2012/09/ns2-coding-3g-umts-network-simulation.html


 #Create a simulator object
 set ns [new Simulator]
 
 #Open the nam trace file
 set nf [open out.nam w]
 $ns namtrace-all $nf
 
 #Define a 'finish' procedure
 proc finish {} {
         global ns nf
         $ns flush-trace
         #Close the trace file
         close $nf
         #Execute nam on the trace file
         exec nam out.nam &
         puts "Simulation ended!"
         exit 0
 }
 
 # Insert your own code for topology creation
 # and agent definitions, etc. here
 
 # Node address is 0
 $ns node-config -UmtsNodeType rnc
 set rnc [$ns create-Umtsnode]
 
 # Node address is 1
 $ns node-config -UmtsNodeType bs \
                 -downlinkBW 32kbs \
                 -downlinkTTI 10ms \
                 -uplinkBW 32kbs \
                 -uplinkTTI 10ms \
 
 set bs [$ns create-Umtsnode]
 
 #Iub configuration between RNC and BS
 $ns setup-Iub $bs $rnc 622Mbit 622Mbit 15ms 15ms DummyDropTail 2000
 
 # Node address for ue1 is 2
 $ns node-config -UmtsNodeType ue \
                 -baseStation $bs \
                 -radioNetworkController $rnc
 
 set ue1 [$ns create-Umtsnode]
 
 # Node address for sgsn0 and ggsn0 is 3 and 4, respectively
 set sgsn0 [$ns node]
 set ggsn0 [$ns node]
 
 # Node address for node1 is 5
 set node1 [$ns node]
 
 $ns duplex-link $node1 $ggsn0 622Mbit 1ms DropTail 1000
 $ns duplex-link $ggsn0 $sgsn0 622Mbit 1ms DropTail 1000
 $ns duplex-link $sgsn0 $rnc 622Mbit 1ms DropTail 1000
 
 $rnc add-gateway $sgsn0
 
 set rtp_sender [new Agent/RTP]
 $ns attach-agent $node1 $rtp_sender
 
 set rtp_receiver [new Agent/RTP]
 $ns attach-agent $ue1 $rtp_receiver
 
 # Create a CBR traffic source and attach it to udp0
 set cbr0 [new Application/Traffic/CBR]
 $cbr0 set packetSize_ 500
 $cbr0 set interval_ 0.005
 $cbr0 attach-agent $rtp_sender
 
 #creation of DCH channel
 $ns node-config -llType UMTS/RLC/AM \
                 -downlinkBW 64kbs \
                 -uplinkBW 64kbs \
                 -downlinkTTI 10ms \
                 -uplinkTTI 10ms
 
 set dch0 [$ns create-dch $ue1 $rtp_receiver]
 
 #Call the finish procedure after 5 seconds simulation time
 $ns at 5.0 "finish"
 
 #Run the simulation
 $ns run 
