#  This file contains the following:
#
#  Utilities for gathering statistics during the course of the simulation.
#  RCStats class -- statistics class for resource-controlled applications
#  RCStats/Detailed class -- class for detailed statistics collection of 
#                            resource-controlled applications

# Utilities
#
# To start up a suite of statistics under the name "trace1"
# call:
# 
#                 rca_init_stats "trace1"
# 
# Every time you want to add a new sample to the statistics collection,
# call:
#                 rca_gather_stats
# 
# When you are finished gathering statistics, call:
#
#                 rca_close_stats
#
# The following statistics will be stored under the given file names:
#
#                 trace1.meta_sent -- total meta-data sent at each sample
#                 trace1.meta_rcvd -- total meta-data received at each sample
#                 trace1.data_sent -- total  message data sent at each time
#                 trace1.data_rcvd -- total message data received at each time
#                 trace1.useless_meta -- total useless meta-data sent at each time
#                 trace1.useless_data -- useless message data sent at each time
#                 trace1.meta_msgs_sent -- total meta-data messages sent at each sample
#                 trace1.meta_msgs_rcvd -- total meta-data messages received at each sample
#                 trace1.data_msgs_sent -- total message data messages sent at each time
#                 trace1.data_msgs_rcvd -- total message data messages received at each time
#                 trace1.useless_meta_msgs -- total useless meta-data sent at each time
#                 trace1.useless_data_msgs -- total useless msg-data sent at each time
#                 trace1.wants -- total amount of data in the wants lists of the system
#                 trace1.has  -- total amount of data in the has lists of the system
#
# NOTE:  All of these functions assume that the following global variables exist:
#
#             ns  -- contains the simulator
#             num_nodes -- contains the number of nodes in the system
#             rca    -- an array of all the resource-controlled apps in the system 

# These are global variables used for the statistics
# It's very kludgy to rely on all these global variables.
# However, functions scheduled using "$ns at" have a problem
# taking variables in as arguments (free-variable capture problem).
# This was the only solution I could find.
set rca_meta_sentf 0
set rca_meta_rcvdf 0
set rca_data_sentf 0
set rca_data_rcvdf 0
set rca_useless_metaf 0
set rca_useless_msgf 0
set rca_hasf 0
set rca_wantsf 0
set rca_energyf 0

# rca_init_stats
#
# Initializes the files required for rca statistics
#
# ns  -- a simulator
# rca -- an array of rca apps
# nsf -- the ns trace file
# num_nodes -- the number of nodes in rc
# namf -- the name file

proc rca_init_stats {name} {
    global rca_meta_sentf rca_meta_rcvdf 
    global rca_data_sentf rca_data_rcvdf
    global rca_useless_metaf rca_useless_msgf
    global rca_hasf rca_wantsf rca_energyf

    set rca_meta_sentf [open "$name.meta_sent" w]
    set rca_meta_rcvdf [open "$name.meta_rcvd" w]
    set rca_data_sentf [open "$name.msg_sent" w]
    set rca_data_rcvdf [open "$name.msg_rcvd" w]
    set rca_useless_metaf [open "$name.useless_meta" w]
    set rca_useless_msgf [open "$name.useless_data" w]
    set rca_hasf [open "$name.has" w]
    set rca_wantsf [open "$name.wants" w]
    set rca_energyf [open "$name.energy" w]
}

# rca_gather_stats
#
#
# ns  -- a simulator
# rca -- an array of rca apps
# nsf -- the ns trace file
# num_nodes -- the number of nodes in rc
# namf -- the name file

proc rca_gather_stats {args} {

    global ns_ node_ opt
    global rca_meta_sentf rca_meta_rcvdf 
    global rca_data_sentf rca_data_rcvdf
    global rca_useless_metaf rca_useless_msgf
    global rca_hasf rca_wantsf rca_energyf

    set pp_on 0
    if {[llength $args] > 0} {
	set pp_on [lindex $args 0]
    }

    set total_meta_sent 0
    set samples_meta_sent 0
    set total_meta_rcvd 0 
    set samples_meta_rcvd 0 
    set total_msg_data_sent 0
    set samples_msg_data_sent 0
    set total_msg_data_rcvd 0 
    set samples_msg_data_rcvd 0 
    set total_useless_meta 0
    set samples_useless_meta 0
    set total_useless_msg_data 0
    set samples_useless_msg_data 0
    set total_energy 0


    # Print out the has and wants list for all the nodes
    for {set id 0} {$id < $opt(nn)} {incr id} {
	set app [$node_($id) set rca_app_]
	set stats [$app set stats_]

	set bad_adv [$stats set total_useless_adv_]
	set bad_REQ [$stats set total_useless_REQ_]
	set bad_data [$stats set total_useless_data_]

	set bad_adv_samples [$stats set samples_useless_adv_]
	set bad_REQ_samples [$stats set samples_useless_REQ_]
	set bad_data_samples [$stats set samples_useless_data_]

	incr total_meta_sent [$stats set total_meta_sent_]
	incr samples_meta_sent [$stats set samples_meta_sent_]

	incr total_meta_rcvd [$stats set total_meta_rcvd_]
	incr samples_meta_rcvd [$stats set samples_meta_rcvd_]

	incr total_msg_data_sent [$stats set total_msg_data_sent_]
	incr samples_msg_data_sent [$stats set samples_msg_data_sent_]

	incr total_msg_data_rcvd [$stats set total_msg_data_rcvd_]
	incr samples_msg_data_rcvd [$stats set samples_msg_data_rcvd_]

	incr total_useless_meta [expr $bad_adv + $bad_REQ + $bad_data]
	incr samples_useless_meta [expr $bad_adv_samples + $bad_REQ_samples + $bad_data_samples]

	incr total_useless_msg_data [$stats set total_useless_msg_data_]
	incr samples_useless_msg_data [$stats set samples_useless_msg_data_]

	set er [$node_($id) getER]
	set expended [$er set expended_]
	$stats set total_energy_ $expended
	set total_energy [expr $total_energy + $expended]
    }

    set total_wants [rca_gather_wants]
    set total_has [rca_gather_has]
    set thetime [$ns_ now]

    if {$pp_on == 1} {
	puts "\n Statistics at time $thetime"

	puts "Total meta data wanted in system is $total_wants"
	puts "Total meta data acquired by system is $total_has"

	puts "\n"
	puts "Total meta-data sent is $total_meta_sent"
	puts "Total meta-data received is $total_meta_rcvd"
	puts "Total message-data sent is $total_msg_data_sent"
	puts "Total message-data received is $total_msg_data_rcvd"
	puts "Total useless meta data is $total_useless_meta"
	puts "Total useless message data is $total_useless_msg_data"

	puts "\n"
	puts "Meta-data messages sent is $samples_meta_sent"
	puts "Meta-data messages received is $samples_meta_rcvd"
	puts "Message-data messages sent is $samples_msg_data_sent"
	puts "Message-data messages received is $samples_msg_data_rcvd"
	puts "Useless meta messages is $samples_useless_meta"
	puts "Useless message messages data is $samples_useless_msg_data"


	puts "\n"
	if {$samples_meta_sent != 0} {
	    set average_meta_sent [expr $total_meta_sent / $samples_meta_sent]
	    puts "Average meta-data/message sent is $average_meta_sent"
	}
	if {$samples_meta_rcvd != 0} {
	    set average_meta_rcvd [expr $total_meta_rcvd / $samples_meta_rcvd]
	    puts "Average meta-data/message received is $average_meta_rcvd"
	}
	if {$samples_msg_data_sent != 0} {
	    set average_msg_data_sent [expr $total_msg_data_sent / $samples_msg_data_sent]
	    puts "Average message-data/data message sent is $average_msg_data_sent"
	}

	if {$samples_msg_data_rcvd != 0} {
	    set average_msg_data_rcvd [expr $total_msg_data_rcvd / $samples_msg_data_rcvd]
	    puts "Average message-data/data message received is $average_msg_data_rcvd"
	}

	puts "System energy expended is is $total_energy"
    }

    puts $rca_meta_sentf "$thetime $total_meta_sent"
    puts $rca_meta_rcvdf "$thetime $total_meta_rcvd"
    puts $rca_data_sentf "$thetime $total_msg_data_sent"
    puts $rca_data_rcvdf "$thetime $total_msg_data_rcvd"
    puts $rca_useless_metaf "$thetime $total_useless_meta"
    puts $rca_useless_msgf "$thetime $total_useless_msg_data"
    puts $rca_wantsf "$thetime $total_wants"
    puts $rca_hasf "$thetime $total_has"

    puts $rca_energyf "$thetime $total_energy"
    return
}

# rca_gather_wants
#
# Gathers all the data wanted by the system.
#
# ns  -- a simulator
# rca -- an array of rca apps
# nsf -- the ns trace file
# num_nodes -- the number of nodes in rc
# namf -- the name file

proc rca_gather_wants {} {

    global ns_ opt node_

    set total_wants 0

    for {set id 0} {$id < $opt(nn)} {incr id} {
	set app [$node_($id) set rca_app_]
	set wants [$app set wants_]

	incr total_wants [$wants numelements]
    }

    return $total_wants
}



# rca_close_stats
#
# Closes all the statitistics files
#
# ns  -- a simulator
# rca -- an array of rca apps
# nsf -- the ns trace file
# num_nodes -- the number of nodes in rc
# namf -- the name file

proc rca_close_stats {} {
    global rca_meta_sentf rca_meta_rcvdf 
    global rca_data_sentf rca_data_rcvdf
    global rca_useless_metaf rca_useless_msgf
    global rca_hasf rca_wantsf rca_energyf

    close $rca_meta_sentf
    close $rca_meta_rcvdf
    close $rca_data_sentf
    close $rca_data_rcvdf
    close $rca_useless_metaf
    close $rca_useless_msgf
    close $rca_hasf
    close $rca_wantsf
    close $rca_energyf
}

# rca_gather_has
#
# Gathers all the data wanted by the system.
#
# ns  -- a simulator
# rca -- an array of rca apps
# nsf -- the ns trace file
# num_nodes -- the number of nodes in rc
# namf -- the name file

proc rca_gather_has {} {

    global ns_ opt node_

    set total_has 0


    for {set id 0} {$id < $opt(nn)} {incr id} {
	set app [$node_($id) set rca_app_]

	set has [$app set has_]
	incr total_has [$has numelements]
    }

    return $total_has
}

#
# RCStats class
#
# RCStats objects are used to gather statistics about resource-controlled
# applications.  The following functions are currently available for storing
# statistics:
#
#          update_rcvs -- used to store information about received messages
#          update_sends -- used to store information about sent messages
#          update_useful -- used to store information about messages that were
#                           sent or received and perceived to be useful
#

Class RCStats

RCStats instproc init {} {

    $self instvar total_sent_adv_
    $self instvar samples_sent_adv_
    $self instvar total_sent_REQ_
    $self instvar samples_sent_REQ_
    $self instvar total_sent_data_
    $self instvar samples_sent_data_

    $self instvar total_rcvd_adv_
    $self instvar samples_rcvd_adv_
    $self instvar total_rcvd_REQ_
    $self instvar samples_rcvd_REQ_
    $self instvar total_rcvd_data_
    $self instvar samples_rcvd_data_

    $self instvar total_useful_adv_
    $self instvar samples_useful_adv_
    $self instvar total_useful_data_
    $self instvar samples_useful_data_
    $self instvar total_useful_REQ_
    $self instvar samples_useful_REQ_
    $self instvar total_useful_msg_data_
    $self instvar samples_useful_msg_data_

    $self instvar total_useless_adv_
    $self instvar samples_useless_adv_
    $self instvar total_useless_data_
    $self instvar samples_useless_data_
    $self instvar total_useless_msg_data_
    $self instvar samples_useless_msg_data_
    $self instvar total_useless_REQ_
    $self instvar samples_useless_REQ_

    $self instvar total_meta_sent_
    $self instvar samples_meta_sent_
    $self instvar total_meta_rcvd_
    $self instvar samples_meta_rcvd_
    $self instvar total_msg_data_sent_
    $self instvar samples_msg_data_sent_
    $self instvar total_msg_data_rcvd_
    $self instvar samples_msg_data_rcvd_

    $self instvar total_energy_

    set total_sent_adv_ 0
    set samples_sent_adv_ 0
    set total_sent_REQ_ 0
    set samples_sent_REQ_ 0
    set total_sent_data_ 0
    set samples_sent_data_ 0

    set total_rcvd_adv_ 0
    set samples_rcvd_adv_ 0
    set total_rcvd_REQ_ 0
    set samples_rcvd_REQ_ 0
    set total_rcvd_data_ 0
    set samples_rcvd_data_ 0

    set total_useful_adv_ 0
    set samples_useful_adv_ 0
    set total_useful_data_ 0
    set samples_useful_data_ 0
    set total_useful_msg_data_ 0
    set samples_useful_msg_data_ 0
    set total_useful_REQ_ 0
    set samples_useful_REQ_ 0

    set total_useless_adv_ 0
    set samples_useless_adv_ 0
    set total_useless_REQ_ 0
    set samples_useless_REQ_ 0
    set total_useless_data_ 0
    set samples_useless_data_ 0
    set total_useless_msg_data_ 0
    set samples_useless_msg_data_ 0

    set total_meta_sent_ 0
    set samples_meta_sent_ 0
    set total_meta_rcvd_ 0
    set samples_meta_rcvd_ 0
    set total_msg_data_sent_ 0
    set samples_msg_data_sent_ 0
    set total_msg_data_rcvd_ 0
    set samples_msg_data_rcvd_ 0

    set total_energy_ 0
}

RCStats instproc update_rcvs {sender msg_type metasize data_size} {

    global ADV REQ DATA

    $self instvar total_rcvd_adv_
    $self instvar samples_rcvd_adv_
    $self instvar total_rcvd_REQ_
    $self instvar samples_rcvd_REQ_
    $self instvar total_rcvd_data_
    $self instvar samples_rcvd_data_
    $self instvar total_meta_rcvd_
    $self instvar samples_meta_rcvd_
    $self instvar total_msg_data_rcvd_
    $self instvar samples_msg_data_rcvd_


    if {$msg_type == $ADV} {
	incr total_rcvd_adv_ $metasize
	incr samples_rcvd_adv_
    } elseif {$msg_type == $REQ} {
	incr total_rcvd_REQ_ $metasize
	incr samples_rcvd_REQ_
    } elseif {($msg_type == $DATA) && ($metasize != 0)} {
	incr total_rcvd_data_ $metasize
	incr samples_rcvd_data_
    } 

    if {$metasize != 0} {
	incr total_meta_rcvd_ $metasize
	incr samples_meta_rcvd_
	incr samples_msg_data_rcvd_
    }
    incr total_msg_data_rcvd_ $data_size
}

RCStats instproc update_sends { sender msg_type metasize data_size} {
    global ADV REQ DATA

    $self instvar total_sent_adv_
    $self instvar samples_sent_adv_
    $self instvar total_sent_REQ_
    $self instvar samples_sent_REQ_
    $self instvar total_sent_data_
    $self instvar samples_sent_data_
    $self instvar total_meta_sent_
    $self instvar samples_meta_sent_
    $self instvar total_msg_data_sent_
    $self instvar samples_msg_data_sent_

    if {$msg_type == $ADV} {
	incr total_sent_adv_ $metasize
	incr samples_sent_adv_
    } elseif {$msg_type == $REQ} {
	incr total_sent_REQ_ $metasize
	incr samples_sent_REQ_
    } elseif {$msg_type == $DATA} {
	incr total_sent_data_ $metasize
	incr samples_sent_data_
    } 

    incr total_meta_sent_ $metasize
    incr samples_meta_sent_
    incr total_msg_data_sent_ $data_size
    incr samples_msg_data_sent_
}

RCStats instproc update_useful {sender msg_type metasize data_size} {
    global ADV REQ DATA


    $self instvar total_rcvd_adv_
    $self instvar samples_rcvd_adv_
    $self instvar total_rcvd_data_
    $self instvar samples_rcvd_data_
    $self instvar total_sent_REQ_
    $self instvar samples_sent_REQ_

    $self instvar total_useful_adv_
    $self instvar samples_useful_adv_
    $self instvar total_useful_data_
    $self instvar samples_useful_data_
    $self instvar total_useful_REQ_
    $self instvar samples_useful_REQ_
    $self instvar total_useful_msg_data_
    $self instvar samples_useful_msg_data_

    $self instvar total_useless_adv_
    $self instvar samples_useless_adv_
    $self instvar total_useless_data_
    $self instvar samples_useless_data_
    $self instvar total_useless_REQ_
    $self instvar samples_useless_REQ_
    $self instvar total_useless_msg_data_
    $self instvar samples_useless_msg_data_
    $self instvar total_msg_data_rcvd_
    $self instvar samples_msg_data_rcvd_

    if {$msg_type == $ADV} {
	incr total_useful_adv_ $metasize
	incr samples_useful_adv_
	set total_useless_adv_ [expr $total_rcvd_adv_ - $total_useful_adv_]
	incr samples_useless_adv_
    } elseif {$msg_type == $DATA} {

        if {$metasize > 0} {
	      incr samples_useful_data_
              incr total_useful_data_ $metasize
        }
        if {$data_size > 0} {
            incr samples_useful_msg_data_
	    incr total_useful_msg_data_ $data_size
        }

        set old_total_useless_msg $total_useless_msg_data_
	set total_useless_msg_data_ [expr $total_msg_data_rcvd_ - $total_useful_msg_data_]
        if {$total_useless_msg_data_ > $old_total_useless_msg} {
	incr samples_useless_msg_data_
	}

        set old_total_useless_data $total_useless_data_
	set total_useless_data_ [expr $total_rcvd_data_ - $total_useful_data_]

        if {$total_useless_data_ > $old_total_useless_data} {
	       incr samples_useless_data_
        }
    } 
}

RCStats instproc pp {} {

    $self instvar total_sent_adv_
    $self instvar total_sent_REQ_
    $self instvar total_sent_data_

    $self instvar total_rcvd_adv_
    $self instvar total_rcvd_REQ_
    $self instvar total_rcvd_data_

    $self instvar total_useful_adv_
    $self instvar total_useful_data_
    $self instvar total_useful_REQ_
    $self instvar total_useful_msg_data_

    $self instvar total_useless_adv_
    $self instvar total_useless_data_
    $self instvar total_useless_msg_data_
    $self instvar total_useless_REQ_

    $self instvar total_meta_sent_
    $self instvar total_meta_rcvd_
    $self instvar total_msg_data_sent_
    $self instvar total_msg_data_rcvd_

    $self instvar total_energy_

    puts "\n Overall totals"
    puts "Type\tS/R\tTotal\tUseful\tUseless"

    puts "ADV \t S \t $total_sent_adv_"
    puts "ADV \t R \t $total_rcvd_adv_ \t $total_useful_adv_ \t $total_useless_adv_"

    puts "REQ \t S \t $total_sent_REQ_ \t $total_useful_REQ_ \t $total_useless_REQ_"
    puts "REQ \t R \t $total_rcvd_adv_"

    puts "DATA \t S \t $total_sent_data_"
    puts "DATA \t R \t $total_rcvd_data_ \t $total_useful_data_ \t $total_useless_data_"

    puts "MSG \t S \t $total_msg_data_sent_"
    puts "MSG \t R \t $total_msg_data_rcvd_ \t $total_useful_msg_data_ \t $total_useless_msg_data_"

    set thetotal $total_meta_sent_ 
    puts "Total DATA meta-data sent is $thetotal"

    puts "\nTotal Energy used: $total_energy_ Joules"
}

#
# RCStats/Detailed class
#
# The difference between this class and its superclass is that statistics
# are stored on a sender basis (as well as by aggregate totals).
#

Class RCStats/Detailed -superclass RCStats

RCStats/Detailed instproc init {} {

    $self instvar senders_
    set senders_ [new Set/KeySet]

    $self next
}

RCStats/Detailed instproc init_sender {sender} {
    global ADV REQ DATA

    $self instvar senders_ rcvd_ sent_ useful_ useless_ useful_msg_data_
    $self instvar useless_msg_data_
    $self instvar rcvd_this_sender_
    $self instvar sent_this_sender_
    $self instvar rcvd_data_this_sender_
    $self instvar sent_data_this_sender_

    if {![$senders_ member $sender]} {
	$senders_ add [list $sender]

	foreach type [list $ADV $REQ $DATA] {
	    
	    set rcvd_($sender,$type) 0
	    set sent_($sender,$type) 0
	    set useful_($sender,$type) 0
	    set useless_($sender,$type) 0
	    set useful_msg_data_($sender) 0
	    set useless_msg_data_($sender) 0
	    set rcvd_this_sender_($sender) 0
	    set sent_this_sender_($sender) 0
	    set rcvd_data_this_sender_($sender) 0
	    set sent_data_this_sender_($sender) 0
	}
    }
}
	

RCStats/Detailed instproc update_rcvs {sender msg_type metasize data_size} {

    global ADV REQ DATA

    $self instvar rcvd_
    $self instvar rcvd_this_sender_
    $self instvar rcvd_data_this_sender_

    $self init_sender $sender

    set thercvs $rcvd_($sender,$msg_type)
    set rcvd_($sender,$msg_type) [expr $thercvs  + $metasize]

    incr rcvd_this_sender_($sender) $metasize
    incr rcvd_data_this_sender_($sender) $data_size

    $self next $sender $msg_type $metasize $data_size
}

RCStats/Detailed instproc update_sends { sender msg_type metasize data_size} {
    global ADV REQ DATA

    $self instvar senders_ sent_
    $self instvar sent_this_sender_
    $self instvar sent_data_this_sender_

    $self init_sender $sender

    set thesends $sent_($sender,$msg_type)

    set sent_($sender,$msg_type) [expr $thesends + $metasize]

    incr sent_this_sender_($sender) $metasize
    incr sent_data_this_sender_($sender) $data_size

    $self next $sender $msg_type $metasize $data_size
}

RCStats/Detailed instproc update_useful {sender msg_type metasize data_size} {
    global ADV REQ DATA

    $self instvar rcvd_ rcvd_data_this_sender_
    $self instvar useful_ useful_msg_data_
    $self instvar useless_ useless_msg_data_

    $self init_sender $sender

    # compute useful
    set theuseful $useful_($sender,$msg_type)
    set useful_($sender,$msg_type) [expr $theuseful + $metasize]

    # compute useless
    set theuseful $useful_($sender,$msg_type)
    set thercvs $rcvd_($sender,$msg_type)
    set useless_($sender,$msg_type) [expr $thercvs - $theuseful]


    if {$msg_type == $DATA} {

	set theuseful_data $useful_msg_data_($sender)
	set useful_msg_data_($sender) [expr $theuseful_data + $data_size]

	set theuseful_data $useful_msg_data_($sender)
	set thercv_data $rcvd_data_this_sender_($sender)

	set useless_msg_data_($sender) [expr $thercv_data - $theuseful_data]
    } 

    $self next $sender $msg_type $metasize $data_size
}


RCStats/Detailed instproc pp {} {
    global ADV REQ DATA

    $self instvar senders_ rcvd_ sent_ useful_ sent_data_ useless_
    $self instvar sent_this_sender_
    $self instvar rcvd_this_sender_

    foreach sender [$senders_ uniquekeys] {
	
	puts "\n Statistics for neighbor $sender"
	set thetotal $sent_($sender,$ADV)
	puts "Total ADV meta-data sent is $thetotal"

	set thetotal $sent_($sender,$REQ)
	puts "Total REQ meta-data sent is $thetotal"

	set thetotal $sent_($sender,$DATA)
	puts "Total DATA meta-data sent is $thetotal"

	set thetotal $sent_this_sender_($sender)
	puts "Total meta-data sent is $thetotal"

	set thetotal $rcvd_($sender,$ADV)
	puts "Total ADV meta-data rcvd is $thetotal"

	set thetotal $rcvd_($sender,$REQ)
	puts "Total REQ meta-data rcvd is $thetotal"

	set thetotal $rcvd_($sender,$DATA)
	puts "Total DATA meta-data rcvd is $thetotal"

	set thetotal $rcvd_this_sender_($sender)
	puts "Total meta-data sent is $thetotal"

	set thetotal $useful_($sender,$ADV)
	puts "Total useful ADV meta-data rcvd is $thetotal"
	
	set thetotal $useful_($sender,$DATA)
	puts "Total useful DATA meta-data rcvd is $thetotal"

	set thetotal $useless_($sender,$ADV)
	puts "Total useless ADV meta-data rcvd is $thetotal"
	
	set thetotal $useless_($sender,$DATA)
	puts "Total useless DATA meta-data rcvd is $thetotal"

	set thetotal $useful_($sender,$RCS)
	puts "Total useful REQ meta-data sent is $thetotal"
	
	set thetotal $useless_($sender,$REQ)
	puts "Total useless REQ meta-data sent is $thetotal"

    }

    $self next
}

