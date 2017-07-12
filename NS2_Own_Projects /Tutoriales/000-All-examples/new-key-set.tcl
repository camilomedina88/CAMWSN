Set/KeySet instproc copy {args} {

    # this will work even if this
    # function is called by a subclass
    set cl [$self info class]
    if {[llength $args] == 0} {
	set name [new $cl]
    } else {
	set name [lindex $args 0]
	$cl $name
    }
    $name addlist [$self settolist]

    return $name
}

Set/KeySet instproc addlist {elements} {

    foreach el $elements {
	if {[llength $el] > 1} {
	    $self add [lindex $el 0] [lindex $el 1]
	} else	{
	    $self add $el
	}
    }
}
