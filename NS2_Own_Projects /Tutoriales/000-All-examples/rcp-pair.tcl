#
#  rcp-pair.tcl
#  

Class RCP_pair
#
# Variables:
#     rcps rcpr:  Sender RCP, Receiver RCP 
#     sn   dn  :  source/dest node which RCP sender/receiver exist
#              :  (only for setup_wnode)
#     delay    :  delay between sn and san (dn and dan)
#              :  (only for setup_wnode)
#     san  dan :  nodes to which sn/dn are attached   
#     aggr_ctrl:  Agent_Aggr_pair for callback
#     start_cbfunc:  callback at start
#     fin_cbfunc:  callback at start
#     group_id :  group id
#     pair_id  :  group id
#     id       :  flow id
# Public Functions:
#     setup{snode dnode}       <- either of them
#     setup_wnode{snode dnode} <- must be called
#     setgid {gid}             <- if applicable (default 0)
#     setpairid {pid}          <- if applicable (default 0)
#     setfid {fid}             <- if applicable (default 0)
#     set_debug_mode { mode }    ;# change to debug_mode
#     re_attach {snode dnode} ;# re-attach to node
#     start { nr_pkts } ;# let start sending nr_pkts 
#
#     set_fincallback { controller func} #; only Agent_Aggr_pair uses to 
#                                        #; registor itself and fin_notify
#     set_startcallback { controller func} #; only Agent_Aggr_pair uses to 
#                                        #; registor itself and start_notify
#     fin_notify {}  #; Callback .. this is called 
#                    #; by agent when it finished
# Private Function
#     flow_finished {} {

RCP_pair instproc init {args} {
    $self instvar pair_id group_id id debug_mode
    $self instvar rcps rcpr;# Sender RCP,  Receiver RCP

    eval $self next $args

    $self set rcps [new Agent/RCP]  ;# Sender RCP
    $self set rcpr [new Agent/RCP]  ;# Receiver RCP

    $rcps set_callback $self
#   $rcpr set_callback $self

    $self set pair_id  0
    $self set group_id 0
    $self set id       0
    $self set debug_mode 0
}

RCP_pair instproc set_debug_mode { mode } {
    $self instvar debug_mode
    $self set debug_mode $mode
}

RCP_pair instproc setup {snode dnode} {
#   Directly connect agents to snode, dnode.
#   For faster simulation.
    global ns link_rate
    $self instvar rcps rcpr;# Sender RCP,  Receiver RCP
    $self instvar san dan  ;# memorize dumbell node (to attach)

    $self set san $snode
    $self set dan $dnode

    $ns attach-agent $snode $rcps;
    $ns attach-agent $dnode $rcpr;

    $ns connect $rcps $rcpr
}

RCP_pair instproc re_attach {snode dnode} {
    global ns 
    $self instvar rcps rcpr;# Sender RCP,  Receiver RCP
    $self instvar san dan  ;# memorize dumbell node (to attach)

    $self set san $snode
    $self set dan $dnode

    $ns attach-agent $snode $rcps;
    $ns attach-agent $dnode $rcpr;

    $ns connect $rcps $rcpr
}

RCP_pair instproc detach {} {
    global ns
    $self instvar rcps rcpr;# Sender RCP,  Receiver RCP
    $self instvar san dan  ;# memorize dumbell node (to attach)

    $ns detach-agent $san $rcps;
    $ns detach-agent $dan $rcpr;
}

RCP_pair instproc setup_wnode {snode dnode link_dly} {
#
#   New nodes are allocated for sender/receiver agents.
#   They are connected to snode/dnode with link having delay of link_dly.
#   Caution: If the number of pairs is large, simulation gets way too slow,
#            and memory consumption gets very very large..
#            Use "setup" if possible in such cases.
#
    global ns link_rate
    $self instvar sn dn    ;# Source Node, Dest Node
    $self instvar rcps rcpr;# Sender RCP,  Receiver RCP
    $self instvar san dan  ;# memorize dumbell node (to attach)
    $self instvar delay    ;# local link delay

    $self set delay link_dly

    $self set sn [$ns node]
    $self set dn [$ns node]

    $self set san $snode
    $self set dan $dnode

    $ns duplex-link $snode $sn  [set link_rate]Gb $delay  DropTail
    $ns duplex-link $dn $dnode  [set link_rate]Gb $delay  DropTail

    $ns attach-agent $sn $rcps;
    $ns attach-agent $dn $rcpr;

    $ns connect $rcps $rcpr
}

RCP_pair instproc set_fincallback { controller func} {
    $self instvar aggr_ctrl fin_cbfunc
    $self set aggr_ctrl  $controller
    $self set fin_cbfunc  $func
}

RCP_pair instproc set_startcallback { controller func} {
    $self instvar aggr_ctrl start_cbfunc
    $self set aggr_ctrl $controller
    $self set start_cbfunc $func
}

RCP_pair instproc setgid { gid } {
    $self instvar group_id
    $self set group_id $gid
}

RCP_pair instproc setpairid { pid } {
    $self instvar pair_id
    $self set pair_id $pid
}

RCP_pair instproc setfid { fid } {
    $self instvar rcps rcpr
    $self instvar id
    $self set id $fid
    $rcps set fid_ $fid;
    $rcpr set fid_ $fid;
}

RCP_pair instproc start { nr_pkts } {
    global ns
    $self instvar rcps id group_id
    $self instvar start_time pkts
    $self instvar aggr_ctrl start_cbfunc
    $self instvar debug_mode

    $self set start_time [$ns now] ;# memorize
    $self set pkts       $nr_pkts  ;# memorize

    set pktsize [$rcps set packetSize_]

    if { $debug_mode == 1 } {
	puts "stats: [$ns now] start grp $group_id fid $id $nr_pkts pkts ($pktsize +40)"
    }

    if { [info exists aggr_ctrl] && [info exists start_cbfunc] } {
	$aggr_ctrl $start_cbfunc
    }

    $rcps set numpkts_ $nr_pkts
    $rcps sendfile
}


RCP_pair instproc stop {} {
    $self instvar rcps rcpr

    $rcps reset
    $rcpr reset
}

RCP_pair instproc fin_notify {} {
    global ns
    $self instvar sn dn san dan
    $self instvar rcps rcpr
    $self instvar aggr_ctrl fin_cbfunc
    $self instvar pair_id
    $self instvar pkts

    $self instvar dt
    $self instvar pps

    $self flow_finished

    $rcps reset
    $rcpr reset

    if { [info exists aggr_ctrl] && [info exists fin_cbfunc] } {
	$aggr_ctrl $fin_cbfunc $pair_id $pkts $dt $pps
    }
}

RCP_pair instproc flow_finished {} {
    global ns
    $self instvar start_time pkts id group_id
    $self instvar dt pps
    $self instvar debug_mode

    set ct [$ns now]
    $self set dt  [expr $ct - $start_time]
    $self set pps [expr $pkts / $dt ]

    if { $debug_mode == 1 } {
	puts "stats: $ct fin grp $group_id fid $id fldur $dt sec $pps pps"
    }
}

############################################
# Modification for  Agent/RCP
#
#   Let RCP sender to callback fin_notify
#   when it received fin-ack.
############################################
Agent/RCP instproc set_callback {rcp_pair} {
    $self instvar ctrl
    $self set ctrl $rcp_pair
}

Agent/RCP instproc done {} {
    global ns sink
    $self instvar ctrl
#    puts "[$ns now] $self fin-ack received";
    if { [info exists ctrl] } {
	$ctrl fin_notify
    }
}

######### Just for debugging ####################################
Agent/RCP instproc begin-datasend {} {
    global ns
#    $self instvar sstart
#    $self set sstart [$ns now]
#    puts "[$ns now] $self fid_ [$self set fid_] begin-datasend";
}
Agent/RCP instproc finish-datasend {} {
    global ns
#    puts "[$ns now] $self fid_ [$self set fid_] finish-datasend";
}

Agent/RCP instproc syn-sent {} {
    global ns
#    puts "[$ns now] $self fid_ [$self set fid_] sys-sent";
}

Agent/RCP instproc fin-received {} {
    global ns
    $self instvar ctrl
#    puts "[$ns now] $self fid_ [$self set fid_] fin-received";
#    $ctrl flow_finished
}
#################################################################
