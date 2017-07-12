# srnode.tcl
# $Id: srnode.tcl,v 1.2 1998/02/17 20:27:57 dmaltz Exp $

# ARGH! this is broken in the presence of multiple links...
# the forwarder needs to figure out what the right target is
#  since there could be multiple targets.  the source route itself
#  must also encode which inf the packet should be sent out.


source cmu/mobile_node.tcl

Class SRNode -superclass MobileNode

SRNode instproc init {args} {
    global opt ns_
    $self instvar dsr_agent_ dmux_

    eval $self next $args	;# parent class constructor

    $self mobile_ 1
    $self forwarding_ 1

    puts "making dsragent"
    set dsr_agent_ [new Agent/DSRAgent]
    $dsr_agent_ ip-addr [$self id]

    set dmux_ [new Classifier/Addr]
    $dmux_ set mask_ 0xff
    $dmux_ set shift_ 0

    #
    # point the node's routing entry to itself
    # at the port demuxer (if there is one)
    #
    $dsr_agent_ target $dmux_
    
    # packets to the DSR port should be dropped, since we've
    # already handled them in the DSRAgent at the entry.
    set nullAgent_ [$ns_ set nullAgent_]
    $dmux_ install $opt(rt_port) $nullAgent_

    # SRNodes don't use the IP addr classifier.  The DSRAgent should
    # be the entry point
    $self instvar classifier_
    set classifier_ "srnode made illegal use of classifier_"

}

SRNode instproc start-dsr {} {
    $self instvar dsr_agent_
    $dsr_agent_ startdsr
}

SRNode instproc entry {} {
        $self instvar dsr_agent_
        return $dsr_agent_
}

SRNode instproc add-if {args} {
# args are expected to be of the form
# $chan $prop $tracefd $opt(ll) $opt(mac)
    global ns_ opt

    eval $self next $args

    $self instvar dsr_agent_ dmux_ mac_

    $dsr_agent_ mac-addr [$mac_(0) id]
    $dsr_agent_ ll-queue [$self get-queue 0]

    # setup promiscuous tap into mac layer
    $mac_(0) tap $dsr_agent_

    set tracefd [lindex $args 2];
    if {$tracefd != ""} {
	set T [new Trace/Generic]
	$T target [$ns_ set nullAgent_]
	$T attach $tracefd
	$T set src_ [$self id]

	$dsr_agent_ tracetarget $T
    }
}

