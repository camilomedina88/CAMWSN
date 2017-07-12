Class Application/RCApp/Flooding -superclass Application/RCApp

# RcApp::start
#
# This function will start data exchanges between the nodes
# 
Application/RCApp/Flooding instproc start {} {
    global DATA MAC_BROADCAST LINK_BROADCAST
    
    $self instvar has_
    
    set datasize [$has_ maptosize]

    set copy_meta [$has_ copy]
    $self send $MAC_BROADCAST $LINK_BROADCAST $DATA $copy_meta $datasize

    return
}


Application/RCApp/Flooding instproc recvDATA {link_dst sender meta_data data_size} {

    global DATA MAC_BROADCAST LINK_BROADCAST

    $self instvar has_ wants_ stats_ 

    set full_packet_size [[$self agent] set packetSize_] 
    if {$data_size == $full_packet_size} {
		puts "Waiting for rest of the data associated with [$meta_data metatostring]"
		$meta_data destroy
		return
    }

    set origsize [$meta_data maptosize]
    $stats_ update_rcvs $sender $DATA [$meta_data numelements] $origsize

    # Figure out which meta-data is new 
    $meta_data subtract $has_

    set datasize [$meta_data maptosize]
    $stats_ update_useful $sender $DATA [$meta_data numelements] $datasize

    $wants_ subtract $meta_data
    $has_ union $meta_data

    if {![$meta_data emptyset?]} {

		# Compute with the new data
		# When computation is complete, function calls finishCOMP function
		$self log-acquired $has_

		set copy_meta [$meta_data copy]
		$self send $MAC_BROADCAST $LINK_BROADCAST $DATA $copy_meta $datasize

    } else {
		puts "Node [[[$self agent] set node_] id] received no new data from [expr $sender / 256]"
	
    }
    
    $meta_data destroy

    return
}


