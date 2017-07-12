#!/bin/sh
# -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}

# Install tmac in the lib directory of the tclsh used to execute
# this script.

set pk tmac
set pkv 1.0

set pkg $pk$pkv

# out works like a buffer and adds \n like puts
proc out args {upvar #0 out out; append out [join $args]\n}

if {$tcl_platform(platform) == "windows" &&
    ! [catch {package require Tk}] } {
    wm withdraw .
    proc bye args {
        global pkv
        tk_messageBox  -message [join $args] \
            -title "Tmac $pkv Install" \
            -type ok
        exit 1
    }
    set dowin 1
} else {
    proc bye args {
        puts stderr [join $args]
        exit 1
    }
    set dowin 0
}


if {[catch {package require Tcl 8.4}]} {
    bye "Sorry, $pkg requires Tcl 8.4"
}

set installdir [file join [file dirname [info library]] $pkg]

out "***** Tmac install ($pkg) *******"
if {[file isdirectory $installdir]} {
    out "$installdir currently contains:\n"
    set fmt %Y.%m.%d-%T
    foreach f [lsort -dictionary [glob -directory $installdir *]] {
        set fline ""
        append fline [clock format [file mtime $f] -format $fmt]
        append fline [format %6s [file size $f]] bytes
        append fline "   [file tail $f]"
        out \t$fline
    }
    out ""
} else {
    out "$installdir currently does not exist"
}

if {$dowin} {
    set ans [tk_messageBox -title "Install $pkg" -type yesno -icon question \
        -message "$out\nOk to install $pkg?"]
    if {$ans != "yes"} {
        exit 1
    }
} else {
    puts stderr $out
    puts -nonewline stderr "Ok to install $pkg ?"
    flush stderr
    gets stdin ans
    if {! [string match {[yY]*} $ans]} {
        bye stderr "Quitting with no action"
    }
}
set out ""


if {[catch {file mkdir $installdir} msg]} {
    bye "Tmac install failed to create $installdir ($msg)"
}

foreach f {pkgIndex.tcl tmac.tcl} {
    if {[catch {file copy -force $f $installdir} msg]} {
        out "File copy for $f failed ($msg)"
    } else {
        out "Copied $f"
    }
}
out "$pkg install done."
out "Use \"package require $pk\" "

if {$dowin} {
    set ans [tk_messageBox -title "Install $pkg" -type ok -icon info \
        -message "$out"]
} else {
    puts stderr $out
}

exit 0
