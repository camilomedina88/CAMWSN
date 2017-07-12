############################################################################
#
# This code was developed as part of the MIT uAMPS project. (June, 2000)
#
############################################################################


# Message Constants
set MAC_BROADCAST 0xffffffff
set LINK_BROADCAST 0xffffffff
set DATA       6


############################################################################
#
# Base Station Application
#
############################################################################

Class Application/BSApp -superclass Application


Application/BSApp instproc init args {

  $self instvar rng_ total_ now_ code_ 

  set rng_ [new RNG]
  $rng_ seed 0
  set total_ 0
  set now_ 0
  set code_ 0

  $self next $args

}

Application/BSApp instproc start {} {

  global opt ns_
  $self instvar code_ now_ data_ 

  set now_ [$ns_ now]
  set code_ $opt(bsCode)
  [$self mac] set code_ $code_
  [$self mac] set node_num_ [$self nodeID]

  # Keep track of the data received from each node.  Data may be received
  # either directly or as part of an aggregate signal.
  for {set i 0} {$i < $opt(nn_)} {incr i} {
      set data_($i) 0
  }
}


############################################################################
#
# Helper Functions
#
############################################################################

Application/BSApp instproc node {} {
  return [[$self agent] set node_]
}

Application/BSApp instproc nodeID {} {
  return [[$self node] id]
}

Application/BSApp instproc mac {} {
  return [[$self node] set mac_(0)]
}

Application/BSApp instproc getData {id} {
  $self instvar data_
  return $data_($id)
}


############################################################################
#
# Receiving Functions
#
############################################################################

Application/BSApp instproc recv {args} {

  global ns_ DATA

  set msg_type  [[$self agent] set packetMsg_]
  set chID      [lindex $args 0]
  set sender    [lindex $args 1]
  set data_size [lindex $args 2]
  set msg       [lrange $args 3 end]
  set nodeID    [$self nodeID]

  pp -file "temp" "BS\tnodeID\t$nodeID\tchID\t$chID\tsender\t$sender\t[$ns_ now]\tmsg\t$msg "


  if {$msg_type == $DATA && $nodeID == $chID} {
     $self recvDATA $sender $msg
  }

}

Application/BSApp instproc recvDATA {sender msg} {

  global ns_ opt node_ DATA
  $self instvar data_  

  # Keep track of how much data is received from each node.
  # Data may be sent directly or via an aggregate signal.
  pp -file "msg" "recv\t[$ns_ now]\tBSDATA\t$sender\tBS\t$DATA\t$msg\tNA\tNA\tNA\tNA"

  set nodes_data ""
  set actual_nodes_data ""
  set nodes_data [[$node_($sender) set rca_app_] set dataReceived_]
  foreach i $nodes_data {
    if {[[$node_($i) set rca_app_] set alive_] == 1} {
      incr data_($i)
      lappend actual_nodes_data $i
    }
  }
  #pp -file "temp" "This represents data from nodes: $actual_nodes_data"
}


############################################################################
#
# Sending Functions
#
############################################################################

Application/BSApp instproc send {mac_dst link_dst type msg
                                      data_size dist code} {
    [$self agent] set packetMsg_ $type
    [$self agent] set dst_ $mac_dst
    [$self agent] sendmsg $data_size $msg $mac_dst $link_dst $dist $code
}

