Class STDMALink -superclass SimpleLink

# The constructor/initialization routine
STDMALink instproc init { src dst bw delay chnl q } {
    $self next $src $dst $bw $delay $q
    $self instvar link_ mac_ phy_ queue_ head_
    $self instvar drophead_

    set ns [Simulator instance]
    set drophead_ [new Connector]
    $drophead_ target [$ns set nullAgent_]

    set head_ [new Connector]
    $head_ set link_ $self

    #set head_ $queue_ -> replace by the following
    # xxx this is hacky
    if { [[$q info class] info heritage ErrModule] == "ErrorModule" } {
	$head_ target [$q classifier]
    } else {
	$head_ target $q
    }

    set queue_ $q
    set link_ [new LL/WP2P]
    $link_ set bandwidth_ $bw
    $link_ set delay_ $delay
    $link_ set chnl_ $chnl
    $link_ set-my-id [$src id]
    $link_ set-nbr-id [$dst id]

    set mac_ [new BiConnector/WP2P_MAC]
    $mac_ set bandwidth_ $bw
    $mac_ set delay_ $delay
    $mac_ set chnl_ $chnl
    $mac_ set-ll $link_

    set phy_ [new WP2P_PHY]
    $phy_ set bandwidth_ $bw
    $phy_ set delay_ $delay
    $phy_ set-ll $link_

    $queue_ target $link_
    $queue_ drop-target $drophead_

    $link_ down-target $mac_
    $mac_ down-target $phy_
    # This will actually be reset when set-other-end is called
    $phy_ target [$dst entry]

    # Set the target for packets on their way up the protocol stack
    $link_ up-target [$src entry]
    $mac_ up-target $link_

    # Set the variables in LLC
    $link_ mac $mac_
    $link_ ifq $queue_

    # This is incomplete, initialization will be complete after
    # set-other-end, and set-nbr are called

    # Finally, if running a multicast simulation,
    # put the iif for the neighbor node...
    if { [$ns multicast?] } {
	$self enable-mcast $src $dst
    }
    $ns instvar srcRt_
    if [info exists srcRt_] {
	if { $srcRt_ == 1 } {
	    $self enable-src-rt $src $dst $head_
	}
    }

}
# End STDMALink instproc init

STDMALink instproc set-other-end { other_end } {
    $self instvar link_ other_end_ phy_ mac_
    set other_end_ $other_end
    $mac_ set-other-end [$other_end mac]
    $phy_ target [$other_end mac]
}
# End STDMALink instproc set-other-end

STDMALink instproc mac {} {
    $self instvar mac_
    return $mac_
}
# End STDMALink instproc mac

STDMALink instproc phy {} {
    $self instvar phy_
    return $phy_
}
# End STDMALink instproc mac

STDMALink instproc set-nbr { nbr } {
    $self instvar link_ nbr_ mac_
    set nbr_ $nbr
    $mac_ set-nbr [$nbr mac]
}
# End STDMALink instproc set-nbr

STDMALink instproc set-send-recv-n { send_n recv_n } {
    $self instvar link_ mac_
    $link_ set send_n_ $send_n
    $mac_ set send_n_ $send_n
    $link_ set recv_n_ $recv_n
    $mac_ set recv_n_ $recv_n
}
# End STDMALink instproc set-send-recv-n
