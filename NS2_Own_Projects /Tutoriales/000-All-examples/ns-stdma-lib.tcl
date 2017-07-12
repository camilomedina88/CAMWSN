# This is the command used to create an STDMA link between two nodes
Simulator instproc stdma-link { n1 n2 bw delay chnl qtype args } {
    # The following has been copied from simplex-link, and modified
    # accordingly, Bhaskar 22 Jul 2003

    $self instvar link_ queueMap_ nullAgent_ useasim_
    set sid [$n1 id]
    set did [$n2 id]

    # Debo
    if { $useasim_ == 1 } {
	set slink_($sid:$did) $self
    }

    if [info exists queueMap_($qtype)] {
	set qtype $queueMap_($qtype)
    }
    # construct the queue
    #BAG WFQ
    set qtypeOrig $qtype
    switch -exact $qtype {
	ErrorModule {
	    if { [llength $args] > 0 } {
		set q1 [eval new $qtype $args]
		set q2 [eval new $qtype $args]
	    } else {
		set q1 [new $qtype Fid]
		set q2 [new $qtype Fid]
	    }
	}
	intserv {
	    set qtype [lindex $args 0]
	    set q1 [new Queue/$qtype]
	    set q2 [new Queue/$qtype]
	}
	WFQ {
	    set q1 [new Queue/$qtype]
	    $q1 set bandwidth_ $bw
	    set q2 [new Queue/$qtype]
	    $q2 set bandwidth_ $bw
	}
	default {
	    if { [llength $args] == 0} {
		set q1 [new Queue/$qtype]
		set q2 [new Queue/$qtype]
	    } else {
		set q1 [new Queue/$qtype $args]
		set q2 [new Queue/$qtype $args]
	    }
	}
    }
    # Now create the STDMA links
    set link1 [new STDMALink $n1 $n2 $bw $delay $chnl $q1]
    set link2 [new STDMALink $n2 $n1 $bw $delay $chnl $q2]
    set link_($sid:$did) $link1
    set link_($did:$sid) $link2

    # Make the two ends known to one another
    $link1 set-other-end $link2
    $link2 set-other-end $link1

    if {$qtype == "RED/Pushback"} {
	set pushback 1
    } else {
	set pushback 0
    }
    $n1 add-neighbor $n2 $pushback
    $n2 add-neighbor $n1 $pushback
    
    #XXX yuck
    if {[string first "RED" $qtype] != -1 || 
	[string first "PI" $qtype] != -1 || 
	[string first "Vq" $qtype] != -1 ||
	[string first "REM" $qtype] != -1 ||  
	[string first "GK" $qtype] != -1 ||  
	[string first "RIO" $qtype] != -1} {
	$q1 link [$link_($sid:$did) set link_]
	$q2 link [$link_($did:$sid) set link_]
    }
    
    set trace [$self get-ns-traceall]
    if {$trace != ""} {
	$self trace-queue $n1 $n2 $trace
	$self trace-queue $n2 $n1 $trace
    }
    set trace [$self get-nam-traceall]
    if {$trace != ""} {
	$self namtrace-queue $n1 $n2 $trace
	$self namtrace-queue $n2 $n1 $trace
    }
    
    # Register this simplex link in nam link list. Treat it as 
    # a duplex link in nam
    $self register-nam-linkconfig $link_($sid:$did)
    $self register-nam-linkconfig $link_($did:$sid)
}

