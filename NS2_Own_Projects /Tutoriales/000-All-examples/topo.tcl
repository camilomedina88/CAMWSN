set val(nn) 2; #number of mobile nodes
set val(lline) 1; #landline node
###### (0) Node 100 ###### 
$ns_ node-config  -numif 1 
set node_(0) [create_node 0.000000 0.000000 0] 
### Interface 0 (Node 108) ### 
[$node_(0) set netif_(0)] set channel_number_ 1 
[$node_(0) set netif_(0)] set Pt_ 0.001570 
[$node_(0) set netif_(0)] set CSThresh_ 7.943282e-12 
set a00 [new Antenna/DirAntenna] 
$a00 setType 1 
$a00 setAngle 90.000000 
[$node_(0) set netif_(0)] dir-antenna $a00 

###### (1) Node 108 ###### 
$ns_ node-config  -numif 1 
set node_(1) [create_node 0.000000 601.000000 0] 
### Interface 0 (Node 100) ### 
[$node_(1) set netif_(0)] set channel_number_ 1 
[$node_(1) set netif_(0)] set Pt_ 0.001971 
[$node_(1) set netif_(0)] set CSThresh_ 1.284483e-11 
set a10 [new Antenna/DirAntenna] 
$a10 setType 1 
$a10 setAngle 270.000000 
[$node_(1) set netif_(0)] dir-antenna $a10 

#addstaticroute <# hops> <next hop> <dest node> <ifa to use>#
#### Routing-Uplink #### 
[$node_(0) set ragent_] addstaticroute 1 1 1 0; ##100:108##
#### Routing-Downlink ####
[$node_(1) set ragent_] addstaticroute 1 0 0 0; ##108:100##

 #add-arp-entry <node_addr> <mac_addr> #
set child_mac [[$node_(0) set mac_(0)] id];##100:108##
set parent_mac [[$node_(1) set mac_(0)] id];##108:100##
[$node_(0) set ll_(0)] add-arp-entry 1 $parent_mac
[$node_(1) set ll_(0)] add-arp-entry 0 $child_mac
