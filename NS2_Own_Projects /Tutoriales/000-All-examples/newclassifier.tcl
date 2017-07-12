#
#
# Create a node with new classifier installed

proc node_with_classifier { clsfr } {
    global ns

    set nd [$ns node]
    $nd instvar reg_module_

    set mod [new RtModule/Base]
    $mod instvar classifier_
    set classifier_ $clsfr
    $classifier_ set mask_ [AddrParams NodeMask 1]
    $classifier_ set shift_ [AddrParams NodeShift 1]
    # XXX Base should ALWAYS be the first module to be installed.
    $nd install-entry $mod $clsfr

    $mod attach-node $nd
    $nd route-notify $mod
    $nd port-notify $mod

    set reg_module_([$mod module-name]) $mod

    return $nd
}
