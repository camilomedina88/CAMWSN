# Message Type Constants
set ADV 0
set REQ 1
set DATA 2
set RESEND 3
set MAC_BROADCAST 0xffffffff
set LINK_BROADCAST 0xffffffff

Class Application/RCApp -superclass Application


############################################################################
#
# Miscellaneous functions
#
############################################################################

# RcApp::init
#
# This function initializes the application and all variables associated
# with it.

set index 0

Application/RCApp instproc init {md_class wantslist haslist} {

    global hasarray index

    $self instvar packetMsg_
    $self instvar stats_
    $self instvar adv_threshold_
    $self instvar pending_delay_
    $self instvar rng_ 
    $self instvar has_ wants_ pending_ md_class_ 
		$self instvar advlist_
    $self instvar neighbors_
    $self instvar init_wants_
    $self instvar advert_period_
    $self instvar already_sent_data_
    $self instvar resend_timeout_

    # initilizations
    set md_class_ $md_class
    set has_ [new $md_class]
    $has_ addlist $haslist
    set wants_ [new $md_class]
    $wants_ addlist $wantslist
    set init_wants_ [$wants_ copy]
    set pending_ [new $md_class]
    set advlist_ [new Advlist]
    set already_sent_data_ [new $md_class]
    set resend_timeout_ .2

    $wants_ subtract $has_

    set hasarray($index) $has_
    incr index

    set stats_ [new RCStats]

    set packetMsg_ 0
    set adv_threshold_ 0
    set pending_delay_ .4
    set advert_period_ .4
    set neighbors_ [new Set/KeySet]

    set rng_ [new RNG]
    $rng_ seed 0

    $self next

}

# RcApp::getER
#
# This function returns the EnergyResource 
# 
Application/RCApp instproc getER {} {

    set er [[[$self agent] set node_] getER]
    return $er
}

# RcApp::log
#
# Send a comment to the log
# 
Application/RCApp instproc log {msg} {
    [$self agent] log $msg
}

# RcApp::log-acquired
#
# Send a comment to the log
# 
Application/RCApp instproc log-acquired {has} {

    $self instvar init_wants_

    set id [[[$self agent] set node_] id]
    set hassize [$has maptosize]
    set wantssize [$init_wants_ maptosize]

    if {$wantssize} {
		set percent [expr ($hassize + 0.0)  / $wantssize]
    } else {
		set percent 0
    }
    set msg "$id has = $percent"
    $self log $msg
}

# RcApp::start
#
# This function will start data exchanges between the nodes
# 
Application/RCApp instproc start {} {

    global ADV DATA MAC_BROADCAST LINK_BROADCAST ns_

    $self instvar has_ adv_threshold_ advert_id_ advert_period_

    # Decide whether have enough energy to ADV data 
    # Note: if data is ADV'd, node must send the data
    set adv_meta [$self decideADV $has_]

    if {![$adv_meta emptyset?]} {
		set datasize [$adv_meta maptosize]
	    
		set copy_meta [$adv_meta copy]
		if {$datasize <= $adv_threshold_} {
	   		$self send $MAC_BROADCAST $LINK_BROADCAST $DATA $copy_meta $datasize
		} else {
	    	$self send_meta $MAC_BROADCAST $LINK_BROADCAST $ADV $copy_meta
		}
    } else {
		set nodeID [[[$self agent] set node_] id]
		puts "Node $nodeID decided NOT to ADV has_ = [$has_ metatostring]"
    }
    $adv_meta destroy
    return
}

# RcApp::stop
#
# This function stops data exchanges between the nodes
# 
Application/RCApp instproc stop {} {
    puts "Stopping RCApp..."
    [$self agent] close
}


############################################################################
#
# Receiving functions
#
############################################################################

# RcApp::recv
#
# This function handles packets.  It picks out the packet header,
# and dispatches to other functions, based on the type of the message.
# 
Application/RCApp instproc recv {args}  {
    global ADV REQ DATA RESEND ns_ opt
    
    $self instvar md_class_ stats_ neighbors_ rng_ advlist_ has_

    if {[llength $args] < 2} {
		puts "Error:  RCApp receive function called with too few args"
		return
    }

    # Get the size and the string out of the arg list
    set link_dst [lindex $args 0]
    set sender [lindex $args 1]
    set data_size [lindex $args 2]
    set meta_string [lrange $args 3 end]

    # Add the sender to the list of known neighbors
    $neighbors_ add $sender 

    # The type is stored internally
    set msg_type [[$self agent] set packetMsg_]

    # Convert the meta-data string into a data-structure
    set meta_data [new $md_class_]
    $meta_data stringtometa $meta_string

    set nodeID [[[$self agent] set node_] id]
    set senderID $sender
    set msg [lindex [list ADV REQ DATA RESEND] $msg_type]

    puts "\nNode $nodeID received $msg ($meta_string) from Node $senderID to $link_dst. Data size is $data_size."
    $neighbors_ pp "Neighbors now"

    # Dispatch based on type
    if {$msg_type == $ADV} {
		# Add meta_data and sender to advlist_
		# This list keeps track of ADVs and who sent the ADV.  O/w  
		# could get an REQ for data which this node cannot receive b/c
		# it is outside the transmission area of the sending node, e.g.:
		# A  -->  B       C : A sends ADV, but only B hears
		# A  <--  B  -->  C : B sends REQ, both A and C hear REQ
		# A  -->  B       C : A sends DATA, but only B hears
		# In this situation, C should not place meta-data REQd by B 
		# on pending list, since data will not be heard by C!

		$advlist_ addADV $sender $meta_data

		if {[$meta_data subset $has_]} {
		    # We do nothing
		    puts "\n Node $nodeID already has advertised data. We do nothing."
		    $meta_data destroy
		    return
		}
	    
		# There is a 3 ms delay between sending and receiving an REQ
		# Waiting time should be R=N*D to achieve E[dup] = 1
		set D 3
		set N [$self count_duplicates $meta_data]
		if {$N < 3} {
		    set N 5
		}
		set delay_bound [expr $D * $N]
		set delay [$rng_ uniform 0 $delay_bound]
		set delay_ms [expr $delay * .001]
		set random_delay [expr [$ns_ now] + $delay_ms]
    	$ns_ at $random_delay "$self recvADV $link_dst $sender $meta_data"
    } elseif {$msg_type == $REQ} {
		$self recvREQ $link_dst $sender $meta_data
    } elseif {$msg_type == $RESEND} {
		$self recvRESEND $sender $meta_data
    } elseif {$msg_type == $DATA} {
		$self recvDATA $link_dst $sender $meta_data $data_size
    }
}

# RcApp::recvADV 
#

# This function handles an ADV message.  It updates
# "wants" using the received meta-data.  It then sends out a request
# based on the intersection of "wants" and the advertisement.  This
# function takes care of freeing the meta-data by freeing the data
# itself, or calling another function that frees the meta-data.

Application/RCApp instproc recvADV {link_dst sender meta_data} {

    global ns_ REQ ADV MAC_BROADCAST 

    $self instvar wants_ has_ stats_ pending_ pending_delay_

    set nodeID [[[$self agent] set node_] id]
    puts "Node $nodeID recvADV $link_dst $sender [$meta_data metatostring]: at [$ns_ now]"

    $stats_ update_rcvs $sender $ADV [$meta_data numelements] 0

puts "meta-data = [$meta_data metatostring], pending = [$pending_ metatostring], has = [$has_ metatostring]"
    #  Subtract what is already pending from the meta-data
    $meta_data subtract $pending_

    # Now subtract what we have out of the remaining meta-data
    $meta_data subtract $has_

    set finalsize [$meta_data numelements]
    $stats_ update_useful $sender $ADV $finalsize 0

    # If the meta-data contains_ nothing we want, stop.
    if {[$meta_data emptyset?]} {
		puts "Node $nodeID does not have any data to request from Node $sender"
		$meta_data destroy
		return
    }

    # Find the union of wants with the meta-data
    $wants_ union $meta_data

    # Decide whether to REQ data
    set req_meta [$self decideREQ $meta_data]

    if {![$req_meta emptyset?]} {

		puts "Now sending an REQ back to $sender"

		# Set this meta data to ageout from the pending list
		set metastring [$req_meta metatostring]
		$ns_ at [expr [$ns_ now] + $pending_delay_] "$self ageout_pending $sender \"$metastring\""

		# Add the meta-data to the pending set
		$pending_ union $req_meta
	
		# Now send a request back to the sender for this meta-data
		set copy_meta [$req_meta copy]
		$self send_now $MAC_BROADCAST $sender $REQ $copy_meta 0 

    } else {
		puts "Application not requesting data [$meta_data metatostring]."
    }

    $req_meta destroy
    $meta_data destroy
}

# RCApp::recvREQ
#
# This function handles an REQ message.  Map the data described in the
# meta-data to actual data, and send it back to the sender using a DATA
# message.  This function takes care of freeing the meta-data by freeing
# the data itself, or calling another function that frees the meta-data.

Application/RCApp instproc recvDirectREQ {sender meta_data} {

    global DATA REQ MAC_BROADCAST LINK_BROADCAST ns_

    $self instvar has_ stats_ already_sent_data_  advlist_
    $self instvar pending_delay_ resend_timeout_

    puts "I just received a direct request for data [$meta_data metatostring].  I've already sent: [$already_sent_data_ metatostring]."

    # Figure out how much of this data we actually possess
    set meta_we_have [$meta_data copy]

    # Send the data if we possess it
    $meta_we_have intersection $has_
    if {[$meta_we_have emptyset?]} {

	set nodeID [[[$self agent] set node_] id]

	puts "Node $nodeID does not have data requested by Node $sender"
	$meta_we_have destroy
	$meta_data destroy
	return
    }

    $meta_we_have subtract $already_sent_data_

    if {[$meta_we_have emptyset?]} {
		puts "We've recently sent data [$meta_we_have metatostring] requested by Node $sender.  Not sending."
	
		$meta_data destroy
		$meta_we_have destroy
		return
    }

    # Now figure out how large a message would be if we sent it
    set datasize [$meta_we_have maptosize]
    set copy_meta [$meta_we_have copy]

	# Keep track of what data has already been sent and do not 
	# re-broadcast message 
	# NOTE:  we need to add a time-out for this list!
    $already_sent_data_ union $meta_we_have
    set metastring [$copy_meta metatostring]
    puts "Sending out data $metastring"
    $ns_ at [expr [$ns_ now] + $resend_timeout_] "$self resend_timeout \"$metastring\""

    $self send_now $MAC_BROADCAST $LINK_BROADCAST $DATA $copy_meta $datasize
    
    $meta_data destroy
    $meta_we_have destroy
}


Application/RCApp instproc recvIndirectREQ {link_dst sender meta_data} {

    global DATA REQ MAC_BROADCAST LINK_BROADCAST ns_

    $self instvar has_ stats_ already_sent_data_ pending_ advlist_
    $self instvar pending_delay_

    puts "I've just received an indirect REQ for [$meta_data metatostring]."

    # What data have we heard advertised for this destination?
    $advlist_ pp "Current advlist"
    puts "Looking up destination $link_dst"
    set adv_meta [$advlist_ findADV $link_dst]

    puts "Received adv_meta $adv_meta"

    if {$adv_meta == ""} {
		# We never heard the ADV.  Forget about this message, since
		# link_dst may not even be our neighbor.
	
		puts "Heard an REQ for [$meta_data metatostring] data that we've never heard advertised."

		$meta_data destroy
		return
    }
    
    # We need to find the intersection of the data that is being
    # requested and the data we need.

    set meta_we_need [$meta_data copy]
    $meta_we_need subtract $has_
    $meta_we_need subtract $pending_

    # Now intersect this data with the requested data
    $meta_we_need intersection $meta_data

    # Now see whether we've heard an advertisement for this
    # data from this particular destination.
    if {![$meta_we_need emptyset?] && [$meta_we_need subset $adv_meta] == 1} {
	
		puts "\t adding [$meta_we_need metatostring] to pending_"

		$pending_ union $meta_we_need

		# Set this meta data to ageout from the pending list
		set metastring [$meta_we_need metatostring]
		$ns_ at [expr [$ns_ now] + $pending_delay_] "$self ageout_pending $link_dst \"$metastring\""
		return
    }

    $meta_we_need destroy
    $meta_data destroy
}

Application/RCApp instproc recvREQ {link_dst sender meta_data} {

    global REQ
    $self instvar stats_

    $stats_ update_rcvs $sender $REQ [$meta_data numelements] 0

    set nodeID [[[$self agent] set node_] id]
    
    if {$nodeID != $link_dst} {
		$self recvIndirectREQ $link_dst $sender $meta_data
    } else {
		$self recvDirectREQ $sender $meta_data
    }
}

Application/RCApp instproc recvRESEND {sender meta_data} {

    global DATA REQ MAC_BROADCAST LINK_BROADCAST ns_

    $self instvar has_ stats_ already_sent_data_  advlist_
    $self instvar pending_delay_ resend_timeout_

    puts "I just received a resend request for data [$meta_data metatostring]."

    # Figure out how much of this data we actually possess
    set meta_we_have [$meta_data copy]

    # Send the data if we possess it
    $meta_we_have intersection $has_
    if {[$meta_we_have emptyset?]} {
		puts "Node $nodeID does not have data requested by Node $sender"
		$meta_we_have destroy
		$meta_data destroy
		return
    }

    # Now figure out how large a message would be if we sent it
    set datasize [$meta_we_have maptosize]
    set copy_meta [$meta_we_have copy]

    $self send_now $MAC_BROADCAST $LINK_BROADCAST $DATA $copy_meta $datasize
    
    $meta_data destroy
    $meta_we_have destroy
}

# RCApp::recvDATA
#
# This function handles a DATA message.  If this is not the last packet 
# of the data, wait for remaining packets before continue and destroy
# meta_data.  If all the data has been received, figure out what is 
# new data, update stats, and send data to computation module (meta_data
# is destroyed in this function).

Application/RCApp instproc recvDATA {link_dst sender meta_data data_size} {

    global DATA

    $self instvar has_ stats_ pending_

    set full_packet_size [[$self agent] set packetSize_] 
    if {$data_size == $full_packet_size} {
		puts "Waiting for rest of the data associated with [$meta_data metatostring]"
		$meta_data destroy
		return
    }
    set origsize [$meta_data maptosize]
    $stats_ update_rcvs $sender $DATA [$meta_data numelements] $origsize

    # Take this data out of the pending list
    $pending_ subtract $meta_data

    # Figure out which meta-data is new 
    $meta_data subtract $has_

    if {![$meta_data emptyset?]} {

		set usefulsize [$meta_data maptosize]
		$stats_ update_useful $sender $DATA [$meta_data numelements] $usefulsize

		# Compute with the new data
		# When computation is complete, function calls finishCOMP function
		$self computeDATA $meta_data $sender

    } else {
		puts "Node [[[$self agent] set node_] id] received no new data from $sender"
		$meta_data destroy
    }

    return
}

# RCApp::finishCOMP
# This function is called when the computation has finished (simulated
# by a certain waiting time).  It updates the has_ and wants_ lists based
# on the meta_data on which the computation was performed and it decides
# whether to ADV any new data to the node's neighbors.

Application/RCApp instproc finishCOMP {meta_data sender} {
    global ADV DATA ns_ MAC_BROADCAST LINK_BROADCAST

    $self instvar adv_threshold_ has_ wants_ advert_id_

    puts "\n***********Finished computation (Time is [$ns_ now])***********"

    # Update has based on the data we received 
    $has_ union $meta_data

    # Remove the data we received from wants
    $wants_ subtract $has_

    # log it if there is new stuff
    # this is separate from the check below,
    # which may depend upon the energy level.
    if {![$meta_data emptyset?]} {
		$self log-acquired $has_
    }

    # Decide whether have enough energy to ADV data 
    # Note: if data is ADV'd, node must send the data
    #set adv_meta [$self decideADV $meta_data]
    set adv_meta [$self decideADV $has_]

    if {![$adv_meta emptyset?]} {

		puts "Node [[[$self agent] set node_] id] sending ADV ([$adv_meta metatostring]) to neighbors..."
		set metasize [$adv_meta maptosize]

		set copy_meta [$adv_meta copy]
		if {$metasize <= $adv_threshold_} {
	   		$self send $MAC_BROADCAST $LINK_BROADCAST $DATA $copy_meta $metasize
		} else {
	   		$self send_meta $MAC_BROADCAST $LINK_BROADCAST $ADV $copy_meta
		}

	    } else {
		puts "Decided NOT to send ADV of data [$meta_data metatostring]."
	    }

    $adv_meta destroy
    $meta_data destroy
}


############################################################################
#
# Sending functions
#
############################################################################

# RcApp::send_meta and RcApp::send
# Sends a message with the given type to the sender These functions_ DO
# NOT DESTROY the meta-data that is passed in as an argument.

Application/RCApp instproc send_meta {mac_dst link_dst type meta_data} {

    $self send $mac_dst $link_dst $type $meta_data 0
}

Application/RCApp instproc send {mac_dst link_dst type meta_data data_size} {

    global ns_

    $self instvar rng_

    set random_delay [expr 0.005 + [$rng_ uniform 0 0.005]]
    $ns_ at [expr [$ns_ now] + $random_delay] "$self send_now $mac_dst $link_dst $type $meta_data $data_size"
}
    
Application/RCApp instproc send_now {mac_dst link_dst type meta_data data_size} {

    global opt 

    $self instvar stats_ 

    $stats_ update_sends $mac_dst $type [$meta_data numelements] $data_size

    # Set up the message type
    [$self agent] set packetMsg_ $type

    # Set the destination
    [$self agent] set dst_ $mac_dst


    # Turn the meta-data into a parsable message
    set meta_string [$meta_data metatostring]

    set nodeID [[[$self agent] set node_] id]
    set destinationID $mac_dst
    set msg [lindex [list ADV REQ DATA RESEND] $type]

    puts "Node $nodeID sending $msg ($meta_string) to Node $destinationID ($link_dst).  Data size is $data_size."

    [$self agent] sendmsg $data_size $meta_string $mac_dst $link_dst
    
    $meta_data destroy

}


############################################################################
#
# Resource-aware decision-making functions
#
############################################################################



Application/RCApp instproc decideADV meta_data {

    $self instvar has_ neighbors_ advlist_ md_class_
    
    # Do not advertise this data if all known neighbors have already advertised it.
    set neighborlist [$neighbors_ settolist]

    set same 1 
    
#    puts "\n\tdecideADV testing for sameness"
    for {set i 0} {($i < [llength $neighborlist]) && ($same == 1)} {incr i} {


	set neighbor [lindex $neighborlist $i]
	set neighbor_meta [$advlist_ findADV $neighbor]

	if {$neighbor_meta == ""} {
	    set same 0
	} else {
	    set same [$meta_data subset $neighbor_meta]
	}
    }
    
    if {($same == 1) && ($neighborlist != "")} {

		puts "Yay!  We just saved ourselves an advertisement!!!"
		set emptyset [new $md_class_]
		return $emptyset
    } 

    set meta_copy [$meta_data copy]
    return $meta_copy
} 

Application/RCApp instproc decideREQ meta_data {

#    puts "Not using resource-aware decision making for decideREQ."
    return [$meta_data copy]
} 

Application/RCApp instproc computeDATA {meta_data sender} {

#    puts "Not performing any application computation."
    $self finishCOMP $meta_data $sender
} 

Application/RCApp instproc ageout_pending {link_dst metastring} {

    global ns_ REQ MAC_BROADCAST
    $self instvar pending_ md_class_ pending_delay_ advlist_

    puts "Pending timeout: [[$self agent] set addr_] data $metastring."

    set meta_data [new $md_class_]
    $meta_data stringtometa $metastring
    $meta_data intersection $pending_

    # Is this data still pending?
    
    if {[$meta_data emptyset?]} {
		puts "Agent [[$self agent] set addr_] data $metastring is no longer pending."
		$meta_data destroy
		return
    }

    $self send_now $MAC_BROADCAST $link_dst $REQ $meta_data 0
    $ns_ at [expr [$ns_ now] + $pending_delay_] "$self ageout_pending $link_dst \"$metastring\""
}

Application/RCApp instproc resend_timeout {metastring} {

    global ns_ 
    $self instvar already_sent_data_ md_class_

    set nodeID [[[$self agent] set node_] id]
    puts "Resend timeout:  Node $nodeID putting $metastring back on the list of data we can send"

    set meta_data [new $md_class_]
    $meta_data stringtometa $metastring
    $already_sent_data_ subtract $meta_data

		#NEW!!!
		$meta_data destroy
}

Application/RCApp instproc count_duplicates {meta_data} {

    $self instvar advlist_ neighbors_ has_
    
    # We start out with 1 because we assume that the
    # meta_data is in our own data-set.
    set dup 1

    foreach pair [$advlist_ settolist] {

		set neighbor_meta [lindex $pair 1]
	
		if {![$meta_data subset $neighbor_meta]} {
	   	 incr dup
		}
    }

    if {![$meta_data subset $has_]} {
		incr dup
    }

    puts "count duplicates for [$meta_data metatostring] is $dup"
    return $dup
}

