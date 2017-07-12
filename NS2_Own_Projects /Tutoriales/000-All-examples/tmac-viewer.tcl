#############################################################################
# 
# Tmac - Tcl Macros: Viewer Application
#
# Part of: 
# Tmac version 1.0 Copyright (c) 2003 Roy E. Terry
# 
# The Tmac package and the software in this file are licensed similarly
# to Tcl/Tk.  Please see "tmac.license" in this directory for details.
# 
#===========================================================================
#
# INTRODUCTION:
#   Tmac Viewer loads macro enhanced Tcl code (usually from a file) and
#   then automates and makes visible all the phases of macro processing:
#   1. Finding definitions
#   2. Expanding invocations
#   3. Evaluating the result in a Tcl interpreter
#
#===========================================================================
#
#############################################################################


if {[catch {package require Tcl 8.4}]} {
    puts stderr "Sorry, tmac viewer needs Tcl 8.4 or higher"
    exit 1
}
if {[catch {package require Tk}]} {
    puts stderr "Sorry, tmac viewer needs package Tk for its GUI"
    exit 1
}

# Expect sample to be in same dir as packace provider script
# lappend auto_path [file dirname [info script]]

if {[catch {package require tmac} msg ]} {
    # Fall back to simply sourcing
    set tmLoadedBy "source tmac.tcl"
    set tmLoadedFrom "[pwd] (current directory)"
    if {[catch {source tmac.tcl} msg]} {
        tk_messageBox \
            -message "Tmac Viewer couldn't find ([pwd]) tmac package\n $msg\nExiting..." \
            -icon error -title "Tmac Viewer"
        exit 1
    }
} else {
    set tmLoadedBy "package require tmac"
    set tmLoadedFrom [lindex [package ifneeded tmac [package present tmac]] 1]
}
namespace import -force tmac::tm*  ;# get common functions


#--------------------------------------------------------------------------------
if 0 {
  DEVELOPER COMMENTS 

  Basic Structure: A left-to-right arrangement of text windows which
  reflects macro processing phases. Text windows are grouped with accessories 
  such as scrollbars, smaller statistics displays, titles, icons, etc.
  -or-
  In vertical mode, a top-to-bottom arrangement, more streamlined and
  quicker to run

  Naming: tv* ==> TmacViewer
  
 
 Avoids: depending on tmac as it may be broken or mis-installed, etc.

 14May03RT - added "vertical" mode display. Simplified, more compact and runs
             end-to-end on 1 button push. No exec, just catch/eval
 15May03RT - read/list mac buttons + help panel
 
}

#--------------------------------------------------------------------------------

# An image for the About box
set tvimgdat(gears) {
R0lGODlhPAA9APcAAAAAABISEhgYGCYmJikoKTIxMjg3ODk7OT5APgZKSQxL
ShZeXRtVVBtbWgBhXwdhXwhhXw1hXxFhXxVgXhthXwBiYABlYwBmZQZkYgVl
ZAFoZgBqaAJsagBubAVqaQVubAtjYQhmZQ1iYAxmZQpoZglubA5qaQ1sagxv
bQFwbgVwbg5wbwBycQB0cgB2dAVycAR0cgV3dQB4dgB6eAB8egp1cxJkYxZh
YBVlYxRnZhBoZhFvbRVsahRubR1oZxpubR1vbR1wbxN1cxtxcBt0chh2dB1x
cB91dB17eS1OTSJcWixUUixcWzFPTjJTUTVYVjxTUT5eXCFhXyZgXihhXzxg
XydiYSFqaCtsayFycCd1cyR3diR4dyZ8eip2dSx4dip7eTJ6eTB9fDV8ezd9
fDl9fENEQ0dIR0pLSkRRUERYV0NcW0xUU1NUU1dYV1NcWllXWVlZWVpcWllf
XlxeXEJgX0pgXldhX19gX0JlZEpkYkd5eFBhYF1mZV9oZlZ4d1l0dGJkY2ts
bG9wb3N0c3N4d3d5eHl5eXp8enx6fH18fS+AfjuAf0KAf36AfjGCgD2BgEOD
gkmGhUuIh06KiVaCgVGKiVSMi1aNjFmOjVyQj16QkGKNjGiNjWCSkWaTk2aV
lGiVlG2YmHOXl3SWlXCamXadnHqennegn3ugn36hoYB+gIKDgoiGiIuMi46Q
jpOTk5eYl5mWmZycnJ+gn4Kjo4OmpYSioYempYijoommpo6hoYynpouop4yp
qJCmpZOqqZKsq5WtrZmvr56ysp21taCdoKKjoqeop6imqKusq6+wr6CysqK1
taaxsaW2tqO4t6O5uay6urGusbOzs7e4t7G9vba8vLu8u7/Av7TBwbjDw7nG
xr7Dw7zGxr7JyMPEw8fIx8HIyMHOzsfIyMXNzcnKycvMy83OzcnR0cvW1s3S
0s7X19LW1tLZ2dXZ2dvb29nc3N3e3tzh4eHi4uHk5OXl5ebo6Onq6u3t7fHx
8fX19fn5+f7+/kAAAAAAACH5BAEAAP4ALAAAAAA8AD0AAAj+AP0JHEiwoMGD
CBMqXMiwocOHECMmtDevYD56EjMyjKdJBaSCqV5YWqexpMFNNGhsyEfQS8pI
JmMKnFcjZaqB2mLQcKFNpsxLKWOIknaqJo0vPn+mXMqUTNKI3toN1CeGxggn
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
}

## Toplevel app startup and init
proc tvMain {} {

    # Static Widget creation is stored table-wise
    global tvLayout tv argv argc
    array unset tvLayout
    array unset tv

    # 14May03RT support 2 display modes
    set m vertical
    if {[info exists argv] && [lindex $argv 0] eq "-mode"} {
        set m [lindex $argv 1]
        set argv [lrange $argv 2 end]
    }
    # Make mode value sensing tolerant of case/length
    # wide<=>horizontal, quick<=>vertical
    switch -glob [string tolower $m] {
        w* -
        h* { set tv(mode) horizontal}

        q* -
        v* { set tv(mode) vertical}
        default {
            puts stderr "Bad mode argument \"$m\""
            set tv(mode) vertical
        }
    }

    eval destroy [winfo child .]
    arrayNest tvLayout {
      # 'pg' ==> phase group
        %pg {
            %-options-horizontal {
                -height 35
                -width  72
            }
            %-options-vertical {
                -height 12
                -width  65
            }
            %-opStats {
                -height 5
            }
            font fixed
        }
        bwidth 10
        %bcolors  {
            doit lightgreen
            load lightblue
        }
        %plistcaps {
            src "Mac\nDefs"
            p1  "Mac\nCalls"
            p2 ""
            output ""
        }
        help-vertical {
            Quick-run (vertical) viewer is for experimenting, testing, exploring (mostly)\
            single macros. Push\
            "Browse Macs" to browse loaded macros. You can directly enter macro\
            definitions and invocations along with supporting code into\
            the "src" window.\
            Push "Rerun" to fully process and run the code.
        }
        help-horizontal {
            Wide viewer is for exploring and validating multi-macro files and\
            source. It also (as mind-jogger) illustrates the phases of\
            macro processing.\
            Click "Load" to bring in a file for examination. The tmac sample app\
            is "dirstat.tcl".\
            Click macro names in "Mac Defs" and "Mac Calls" to jump\
            the view to definitions or invocations. \
        }
        redo-horizontal {Redo ==> }
        redo-vertical {Rerun}
        eval-vertical {Eval now}
        evAuto-vertical {Eval on Rerun}
        pnames-horizontal {src p1 p2 output}
        # vertical format skips phase1 display
        pnames-vertical {src p2 output}
        %ptitles {
            # match phase names to title strings
            src     "Input text, definitions marked"
            p1      "Definitions removed, invocations marked"
            p2      "After macro invocations processed"
            output  "Final output from processed code"
        }
        %src {
            xcustomize tvSrcInit
        }
    }
    # parray tvLayout
    if {$tv(mode) eq "horizontal"} {
        tvLayoutCreateHorizontal
        foreach sn $tvLayout(pnames-horizontal) {
            tvPGCreate $tv(pg,$sn,f) $sn ""
        }
        set swp .8
    }  else {
        # vertical? ...
        tvLayoutCreateVertical
        foreach sn $tvLayout(pnames-vertical) {
            tvPGCreate $tv(pg,$sn,f) $sn ""
        }
        set swp .45
    }

    # Place the main window at least close to a useful size
    set sw [winfo screenwidth .]
    set sh [winfo screenheight .]
    wm geometry . \
    =[expr round($sw*$swp)]x[expr round($sh*.85)]+[expr round($sw*.05)]+[expr round($sh*.05)]

    # make sure the phase frames are properly spaced horizontally
    # as fonts and configured widths could both change
    after 500 tvLayoutRespace

    # vertical auto reads some macros
    if {$tv(mode) eq "vertical"} {
        foreach f [lsort [glob *.tmac]] {
            lappend tv(readmac,files) $f
            tmsource $f
        }
    }
}

proc tvSrcLoad {{fn ""} } {
    global tv
    # respond to button and load a file into source area
    # BEWARE: dirstat.tcl will "kill" the viewer in vertical mode!
    if {$fn eq "" && $tv(mode) eq "horizontal"} {
        set fn [tk_getOpenFile -initialfile dirstat.tcl]
    } else {
        set fn [tk_getOpenFile ]
    }
    if {$fn eq ""} return
    if {[catch {
        set ch [open $fn r]
        set data [read -nonewline $ch]
        close $ch
    } msg]} {
        tk_messageBox -title "Tmac View" \
            -icon error -message "Sorry can't load \"$fn\" ($msg)"
        return
    }

    # By default file loads replace completely
    global tv
    $tv(pg,src,t) delete 1.0 end

    tvSrcRefresh $data $fn
}
proc tvSrcRefresh {{data ""} {fname ""}} {
    # New text is in the control process it
    global tv
    set t $tv(pg,src,t)

    # 20Mar03RT - clear output as it's now definitely invalid
    $tv(pg,output,t) delete 1.0 end
    $tv(pg,output,detail) configure -text ""

    # Show the data
    if {$data ne ""} {
        $t insert end $data
    } else {
        set data [$t get 1.0 end-1c]
    }

    ### 1. Basic text stats
    # Put basic stats and file name into top detail area
    if {$fname eq ""} {
        set fname (nofile)
    }
    $tv(pg,src,detail) config -text "$fname - \
        [tvTextStatsString $data]"

    # Now analyize macro related information
    tvSrcRefreshMacInfo $data $fname
}
proc tvTextStatsString {text} {
    set lcnt [llength [split $text \n]]
    set wcnt [llength [regexp -indices -all -inline {\s+} $text] ] 
    if {$wcnt == 0 && [string trim $text] ne ""} {incr wcnt}
    set ccnt [string length $text]
    return "$lcnt lines, $wcnt words, $ccnt characters"
}
proc tvSrcRefreshMacInfo {data fname} {
    global tv

    # TODO - add clear/rest beforehand!

    # Get it checked for embedded macro subs
    # With careful error checking too
    set defmap ""
    set s [catch {set p1dat [tmfind $data defmap] } msg]
    # Highlight any found macros
    set t $tv(pg,src,t)
    set lb $tv(pg,src,maclist)
    $lb delete 0 end
    set tv(nav,src) ""
    foreach defpair $defmap {
        # Drill down
        foreach {mac ipair} $defpair {}
        foreach {is ie} $ipair {}

        # highlight
        incr is; incr ie 2
        $t tag add macdef "1.0+$is chars" "1.0+$ie chars"

        # put in list box and remember it
        $lb insert end $mac
        lappend tv(nav,src) [$t index "1.0+$is chars"]
    }
    bind $lb <<ListboxSelect>> "tvSrcMacSee $lb src"

    # Stats on what we found successfully
    tvStatClear src
    tvStatAdd src "[llength $defmap] static macro defs\n"

    if {$s} {
        # report an error
        # TODO: support (and add to tmac) finding multiple errors in one go
        if {$tv(pg,src,tstat) eq "tvnothing"} {
            tk_messageBox -message "Error encountered\n ($msg)" \
                -icon error -title "Tmac Viewer"
        } else {
            $tv(pg,src,tstat) insert end "ERROR DETECTED:\n$msg" red
        }
        tvP1Refresh ""
    } else {
        tvP1Refresh $p1dat
    }

}
proc tvP1Refresh {data} {
    # Put the result into the p1 box (mac defs have been removed)
    global tv
    if { [info exists tv(pg,p1,t)]} {
        set t $tv(pg,p1,t)
    } else {
        set t tvnothing
        set tv(pg,p1,maclist) tvnothing
        set tv(pg,p1,detail)  tvnothing
        set tv(pg,p1,tstat)   tvnothing
    }
    $t delete 1.0 end
    $t insert 1.0 $data

    set lb $tv(pg,p1,maclist)
    $lb delete 0 end

    $tv(pg,p1,detail) config -text [tvTextStatsString $data]

    if {$data eq ""} return
    # Process the embedded macros calls - if any
    set p2dat "" ;# 09May03RT
    set s [catch {set p2dat [tmexpand $data] } msg]
    if {$s} \
        {tvP2Refresh "Error encountered\n ($msg)" red} {tvP2Refresh $p2dat}

    # Highlight the possibly nested macro invocations using nested 
    # colors. Depends on parse info from tmac::
    set callcnt 0
    set nestmax 0
    set prev ""
    if {[info exists tmac::config(tree)]} {
        foreach cur $tmac::config(tree) {
            if {[string match ?0* $cur]} {set prev ""; continue}
            if {$prev eq ""} {set prev $cur; continue}

            # got a pair color based on leading level
            scan $prev {%[-+]%d%d} pd pl pi
            scan $cur {%[-+]%d%d} cd cl ci

            # Reuse colors on deep nesting
            if {$pl > $nestmax} {set nestmax $pl}
            set pl [expr {$pl % 5}] 
            if {$pl == 0} {set pl 1}
            set cl [expr {$cl % 5}] 
            if {$cl == 0} {set cl 1}

            set i1 [$t index "1.0+$pi c"]
            set i2 [$t index "$i1+[expr {$ci-$pi+1}] c"]
            set tag mcall[if {$pd eq "-"} {subst $cl} {subst $pl}]
            $t tag add $tag $i1 $i2
            
            # Pull out the macro name for def start indexes
            if {$pd eq "+"} {
                set frag [string range $data $pi [expr {$pi+50}] ]
                set mac ""
                regexp {\w+} $frag mac
                $lb insert end $mac
                incr callcnt
                if {[info exists callstat($mac)]} \
                    {incr callstat($mac)} {set callstat($mac) 1}

                # Set up click-to-nav data
                lappend tv(nav,p1) [$t index $i1]
            }

             # puts "$callcnt: i1=$i1, i2=$i2  seg: [string range $data $pi $ci]"
            set prev $cur
            
        }
    }
    bind $lb <<ListboxSelect>> "tvSrcMacSee $lb p1"
    # Stats on what we found successfully
    tvStatClear p1
    tvStatAdd p1 \
        "$callcnt macro invocations on [array size callstat] distinct macros\n"
    tvStatAdd p1 "Nested maximum depth: $nestmax"
    
    # Process the embedded macros calls - if any
    if 0 {
        # SEEMS THIS MUST BE DONE *ABOVE* ELSE tmac::config(tree) is NOT SET
        set p2dat "" ;# 09May03RT
        set s [catch {set p2dat [tmexpand $data] } msg]
        if {$s} {
            tvP2Refresh "Error encountered\n ($msg)" red
        } else {
            tvP2Refresh $p2dat
        }
    }

}
proc tvStatAdd {ptype s} {
    global tv
    set bul \u2022

    # enfore exactly 1 linebreak
    set s [string trimright $s \n]\n

    # add with leading bullet
    set t $tv(pg,$ptype,tstat)
    $t insert end " $bul $s"

    set h [$t cget -height]
    set curl [scan [$t index end] %d]
    if {$h > $curl} {
        # Shrinking?
        $t config -height $curl
        return
    }
    set newh $curl
    if {$newh > 7} {set newh 7}
    $t config -height $newh
}

proc tvStatClear {ptype} {
    global tv
    $tv(pg,$ptype,tstat) delete 1.0 end
    $tv(pg,$ptype,tstat) config -height 2
}
proc tvP2Refresh {data {errorColor ""} } {
    global tv errorInfo
    $tv(pg,p2,t) delete 1.0 end
    $tv(pg,p2,t) insert 1.0 $data $errorColor

    if {$errorColor ne ""} return

    $tv(pg,p2,detail) config -text [tvTextStatsString $data]

    # if vertical mode look for optional auto eval
    if {$tv(mode) eq "vertical" && $tv(evAuto)} {
        tvP2RefAutoRun $data
    }
}
proc tvOutputEval {} {
    # Service the vertical mode "eval" button
    # by passing phase 2 on to an eval/display step
    global tv
    tvP2RefAutoRun [$tv(pg,p2,t) get 1.0 end-1c]
}
proc tvP2RefAutoRun {data} {
    # Runs vertical mode style output (evals the mac output)
    global tv errorInfo
    catch {rename tv_saveputs ""}
    rename puts tv_saveputs
    proc puts args {global tv; lappend tv(puts) [join $args]}
    set tv(puts) ""
    set s [catch {uplevel #0 $data} msg]
    if {$s} {
        # Get ready to display error. Drop msg if it is
        # same string as first line of errorInfo
        if {[string first $msg $errorInfo] == 0} {
            set msg $errorInfo
        } else {
            append msg \n $errorInfo
        }
    }
    rename puts ""
    rename tv_saveputs puts

    $tv(pg,output,detail) config -text [tvTextStatsString $msg]
    $tv(pg,output,t) delete 1.0 end
    $tv(pg,output,t) insert 1.0 $msg [if {$s} {subst red} {subst ""}]
    $tv(pg,output,t) insert end \nPUTS:\n blue
    $tv(pg,output,t) insert end [join $tv(puts) \n] blue
}
proc tvSrcMacSee {lb ptype} {
    # make the clicked-on macro visible
    global tv
    set i [$lb curselection]
    # puts stderr "macsee $i"
    $tv(pg,$ptype,t) see [lindex $tv(nav,$ptype) $i]
}
proc tvHelpPanel f {
    global tv tvLayout
    set l [label $f.lhp -anchor w -justify left -bg khaki1]
    $l config -text [string trim $tvLayout(help-$tv(mode))] \
              -wraplength 5i
    return $l
}

proc tvLayoutCreateHorizontal {} {
    wm title . \
      "Tmac Wide Viewer (Tmac v. [lindex [package versions tmac] end])"

    return [tvLayoutCreate 3000 700 h 550]
}
proc tvLayoutCreateVertical {} {
    wm title . \
      "Tmac Quick View (Tmac v. [lindex [package versions tmac] end])"
    return [tvLayoutCreate 550 700 v 250]
}
proc tvLayoutCreate {cW cH HorV incrVal} {
    # 14May03RT a more compact vertical layout more suitable for
    # quick experiments with short examples
    # The main GUI presentation lives on a giant canvas and
    # features a horizontal or vertical line of phase groups (frames).
    # => Create canvas and cantainers for text groups
    # => Make it scroll
    global tv tvLayout


    set f ""

    # Above the canvas is a frame for non-scrolling toolbar (global app controls)
    pack [set tbf [frame $f.tbf]] -side top -fill x -pady {5 8} -padx 8
    tvLayoutToolBar $tbf

    pack [tvHelpPanel $f] -side top -fill x 

    # The canvas is quite wide (TODO smarter later)
    set c [canvas $f.c -scrollregion [list 0 0 $cW $cH] ]

    set hs [scrollbar $f.hs -orient horizontal -command "$c xview"]
    set vs [scrollbar $f.vs -orient vertical -command "$c yview"]
    $c config -xscrollcommand "$hs set"
    $c config -yscrollcommand "$vs set"

    pack $hs -side bottom -fill x 
    pack $vs -side right -fill y 
    pack $c -side left -fill both -expand yes

    set xincr 550
    set yincr 250
    set fx 10 ; set fy 10 
    set i -1
    foreach sn $tvLayout(pnames-$tv(mode)) {
        incr i
        set sf [frame $c.f$sn]
        # $sf config -width 500 -height 650 
        $sf config -border 1 -relief solid
        set tv(can,f,$sn) \
            [$c create window $fx $fy -window $sf -anchor nw]
        if {$HorV eq "v"} {
            incr fy $yincr
        } else {
            incr fx $xincr
        }
        set tv(pg,$sn,f) $sf
    }
    set tv(can,c) $c
}
proc tvLayoutRespace {{margin 35} } {
    global tv tvLayout

    if {$tv(mode) eq "vertical"} return ;# no need in vertical mode

    set c $tv(can,c)
    set left ""
    # Go left to right and respace the phase frames on the 
    # scrolling canvas. Happens after the frames get fully realized
    # and thus know there required sizes.
    # Right and left are canvas IDs

    # TODO if no use is made of intervening canvas area then STOP
    # BOTHERING with this and just put multi-frames in a big
    # single frame.
    foreach sn $tvLayout(pnames-horizontal) {
        set right $tv(can,f,$sn)
        if {$left eq ""} {
            # first time
            set left $right
            continue
        }
        set lx [lindex [$c bbox $left] 2]
        set lr [lindex [$c bbox $right] 0]
        # puts stderr "set rnew \[expr {$lr - ($lx + $margin)}\]"
        set rnew [expr {($lx + $margin) - $lr}]
        $c move $right $rnew 0
        set left $right
    }
    set c [$c config -scrollregion [$c bbox all] ]
}
proc tvnothing args {}
proc tvPGCreate {f ptype props} {
    ## Build Phase group for phase display & control
    # Make a Text Group in the passed frame 'f'
    # Use ptype to lookup static props and,
    # let 'props' over-ride the statics.
    # Store names of created components in tv() global array
    global tv tvLayout

    # pack propagate $f off

    ### 1. Title frame at top with a title inside
    pack [set tif [frame $f.tif]] -side top -fill x
    pack [set tifl [label $tif.lt1 -anchor w -padx 3 -font [tvFont Title] \
        -text "$ptype - $tvLayout(ptitles,$ptype)" ] ] -side top -fill x

    # Details (like file) name go here
    pack [set tifdet [label $tif.lt2 -anchor s \
        -bg gray95  -padx 2 -pady 2 -relief solid -bd 0 -font [tvFont Detail]] ] \
        -side left -padx 3

    # "redo" button used in split logic (could be a macro but we're not
    # going to use them in this tool)
    set redoCODE {
        pack [set fctl [frame $stf.fctl]] \
            -side bottom -fill x -padx 8 -pady {5 1}
        $fctl config -bg gray82 -relief groove -bd 2
        pack [button $fctl.b1 -text $tvLayout(redo-$tv(mode))\
            -bd 1 -relief solid -overrelief raised \
            -command {tvSrcRefresh "" ""} ] -side right -pady 3 -padx 4
    }

    ### 2 Stats frame at bottom for some phases
    # 14May03RT no stats, etc for vertical
    if {$tv(mode) eq "horizontal"} {
        pack [set stf [frame $f.stf ]] \
            -side bottom -fill x -anchor w -pady {3 5}

        if {$tvLayout(plistcaps,$ptype) eq ""} {
            set tv(pg,$ptype,tstat) tvnothing
            set tv(pg,$ptype,maclist) tvnothing
            if {$ptype == "p2"} {
                # Buttons to run the final output in an interp
                pack [set fctl [frame $stf.fctl]] \
                    -side bottom -fill x -padx 8 -pady {5 1}
                $fctl config -bg gray82 -relief groove -bd 2
                tvLayoutOutput $fctl
            }
        } else {
            # Macro name list box
            pack [set l1 [label $stf.l1]] \
                 -side left -fill y -expand no -anchor w -padx {8 0}
            $l1 config \
                -text $tvLayout(plistcaps,$ptype) \
                 -bd 0 \
                 -justify right \
                 -anchor ne -font [tvFont Title]

            set lb [listbox $stf.lbm -width 20 -height 10]
            $lb config -takefocus 1
            bind $lb <Button-1> "focus -force $lb"

            scrollbarAdd $lb vertical [set sb $stf.lbvs]
            pack $lb -side left -fill y  -ipadx 3
            pack $sb -side left -fill y

            # ## 3. Right bottom strip occupied by a few buttons
            if {$ptype == "src"} {
                eval $redoCODE
            }

            pack [set l2 [label $stf.l2]] \
                 -side left -fill y -expand no -anchor w -padx {8 0}
            $l2 config \
                -text "Stats " \
                 -bd 0 \
                 -justify right \
                 -anchor ne -font [tvFont Title]
            # text with scroll
            set ts [text $stf.t -bg lavender -width 10]
            # scrollbarAdd $ts vertical [set sb $stf.vs]

            # Work with these if variable height stats display +SB is wanted
            # pack $ts -side left -pady {1 2}  -anchor nw
            # pack $sb -side left -pady {1 2}  -anchor nw
            pack $ts -side left -pady {1 2}  -anchor nw -fill x -padx {0 10} -expand 1
            # pack $sb -side left -fill y -pady {1 2}
            eval $ts config $tvLayout(pg,opStats)
            markupTagsAdd $ts

            set tv(pg,$ptype,tstat) $ts
            set tv(pg,$ptype,maclist) $lb
        }
    } else {
        # vertical
        pack [set stf [frame $f.stf ]] \
            -side right -fill x -anchor w -pady {3 5}
        if {$ptype == "src"} {
            eval $redoCODE
        }
        # Over-ride auto eval of "redo" if wished - 15Nov03RT
        if {$ptype == "output"} {
            pack [set fctl [frame $stf.fctl]] \
                -side bottom -fill x -padx 8 -pady {5 1}
            $fctl config -bg gray82 -relief groove -bd 2
            pack [checkbutton $fctl.b1 -text $tvLayout(evAuto-$tv(mode))\
                -bd 1 -relief solid -overrelief raised \
                -variable tv(evAuto) ] -side top -anchor w -pady 3 -padx 4
            pack [button $fctl.b2 -text $tvLayout(eval-$tv(mode))\
                -bd 1 -relief solid -overrelief raised \
                -command tvOutputEval ] -side top -anchor w -pady 3 -padx 4
        }

        set tv(pg,$ptype,tstat) tvnothing
        set tv(pg,$ptype,maclist) tvnothing
    }
    ### 4. Main Text display with vertical scrollbar
    pack [set tf [frame $f.tf]] -side left 
    set t [text $tf.tmain]
    $t config -font [tvFont $tvLayout(pg,font)]
    eval $t config $tvLayout(pg,options-$tv(mode)) 
    scrollbarAdd $t vertical $tf.vs
    pack $tf.vs -side right -fill y
    pack $t -side left -fill both -padx {2 0}
    markupTagsAdd $t

    ### 5. Record the key names
    set tv(pg,$ptype,t) $t
    set tv(pg,$ptype,t) $t
    set tv(pg,$ptype,detail) $tifdet

    ### 6. Call customize proc if given
    if {[info exists tvLayout($ptype,customize)]} {
        $tvLayout($ptype,customize)
    }
}
proc tvLayoutToolBar {tbf} {
    # Create global level application controls
    global tv
    set BG gray82
    $tbf config -border 3 -relief groove -bg $BG
    arrayNest tb {
        order {exit load - readmac listmac  - fontb fonts - narrow wide about}
        # Command ID's with text and shortcut information associated
        %exit    {text "Exit!"            sc x side left}
        %load    {text "Load Src"         sc L side left}
        %readmac {text "Read Macs"        sc R side left}
        %listmac {text "Browse Macs"      sc B side left}
        %fontb   {text "Font++"           sc + side left}
        %fonts   {text "Font--"           sc - side left}
        %narrow  {text ">>Narrower<<"     sc N side left}
        %wide    {text "<< Wider >>"      sc W side left}
        %about   {text About              sc A side right}
    }
    set sp 0
    foreach bid $tb(order) {
        if {$bid eq "-"} {
            # add a spacer
            pack [frame $tbf.sp$sp -width 10 -bg $BG] -side left
            incr sp
            continue
        }
        # 14May03RT - vertical mode uses default (smaller font)
        # and doesn't use fixwidth buttons
        set b [button $tbf.$bid -text $tb($bid,text) \
            -relief groove -overrelief raised -border 2\
            -command "tvToolButtonDo $bid" ]
        
        if {$tv(mode) eq "horizontal"} {
            set sw [winfo screenwidth .]
            if {$sw <= 1024} {set bw 0} {set bw 15}
            $b configure -width $bw -font [tvFont Toolbar]
        }

        set scI [string first $tb($bid,sc) $tb($bid,text)]
        set scC [string index $tb($bid,text) $scI]
        $b config -underline $scI
        bind . <Alt-KeyPress-[string toupper $scC]> "$b invoke"
        bind . <Alt-KeyPress-[string tolower $scC]> "$b invoke"
        pack $b -side $tb($bid,side) -padx {5 0} -pady 5
    }
    
}
proc tvLayoutOutput {f} {
    # Buttons to create final output as desired
    array set obuts {
        order {save copy - tclsh wish other}
        save  { -side left -padx {5 0} }
        copy  { -side left -padx {5 0} }
        tclsh { -side top -anchor ne -pady {3 0} -padx 5}
        wish  { -side top -anchor ne -pady {3 0} -padx 5}
        other { -side top -anchor ne -pady {3 0} -padx 5}
    }
    set suf ""
    foreach bid $obuts(order) {
        if {$bid eq "-"} {
            set suf " ==>"
            pack [label $f.flab \
                -bg [$f cget -bg] \
                -anchor e -text Output\nUsing -font [tvFont Title] ] \
                -side left -anchor ne -expand 1 -fill x
            continue
        }
        set b [button $f.$bid -text [string totitle $bid]$suf -width 9 \
                -bd 1 -relief solid -overrelief raised \
                -command "tvOutputButtonDo $bid" ] 
        eval pack $b -pady 5 $obuts($bid)
    }
    
}
proc tvOutputButtonDo {id} {
    global tv
    set data [$tv(pg,p2,t) get 1.0 end-1c]
    switch $id {
        save {
            set fn [tk_getSaveFile -title "Saving macro expansions"]
            if {$fn eq ""} return
            if {[catch {
                set ch [open $fn w]
                puts $ch $data
                close $ch
            } msg ]} {
            tk_messageBox -message "Sorry save failed ($msg)" \
                -icon error -title "Tmac Viewer"
            }
        }
        copy {
            clipboard clear
            clipboard append $data
        }
        tclsh -
        wish -
        other { tvOutputCommandPreview $id}
    }
}
proc tvOutputCommandPreview {type} {
    # Let user confirm/edit the command line before dispatching it
    # We will let $f stand for the file
    global tv
    switch $type {
        wish -
        tclsh {
            set cmd [lindex [auto_execok $type] 0]
            if {$cmd eq ""} {set cmd "(executable_not_found)"} \
                            {set cmd [file attr $cmd -shortname]}
            append cmd " \$f"
        }
        default {
            set cmd "EXECUTABLE-HERE \$f"
        }
    }
    destroy .op
    toplevel .op
    ::tk::PlaceWindow .op pointer center
    wm title .op "Edit and Confirm output command"
    pack [label .op.l1 -anchor w -bg lavender\
        -text "Note: '\$f' will be replaced by a temp file name"] \
        -side top -anchor w -fill x -padx 3 -pady 15
    pack [entry .op.e -text $cmd -width 60] -side top -fill x -padx 5 
    .op.e delete 0 end
    if {[info exists tv(output,hist,$type)]} {
        .op.e insert 0 $tv(output,hist,$type)
    } else {
        .op.e insert 0 $cmd
    }
    pack [button .op.bgo -command "tvOutputGo $type" -width 8 -text Run! \
        -default active] \
        -side left -padx 10 -pady 10
    pack [button .op.bcan -command "destroy .op" -width 8 -text Cancel] \
        -side left -padx {0 10} -pady 10
    bind .op <Return> "tvOutputGo $type"
    bind .op <Escape> "destroy .op"
}
proc tvOutputGo {type} {
    # Run the command
    global tv
    set cmd [.op.e get]
    destroy .op


    # TODO more sophisticated matching test
    if { ! [regexp {\$f\M} $cmd]} {
            tk_messageBox -message "Sorry needs '\$f' " \
                -icon error -title "Tmac Viewer" -parent .op
        return
    }
    set tv(output,hist,$type) $cmd
    switch $type {
        wish {set back &}
        default {set back ""}
    }

    # Now need to make the promised temp file
    set data [$tv(pg,p2,t) get 1.0 end-1c]
    set f tmac-[pid].run
    set ch [open $f w]
    puts $ch $data
    close $ch

    set ferr $f.err
    set fstd $f.std

    set t $tv(pg,output,t) 
    $t delete 1.0 end

    # notice f is set exanded below
    $tv(pg,output,detail) configure -text [subst -nocommands -nobackslash $cmd]
    set errtext ""
    set out ""
    if {[catch {set out [eval exec $cmd 2> $ferr $back]} msg]} {
        # report the error
        $t insert end "An Error occurred:\n$msg\n" red
    } elseif {[file size $ferr] != 0} {
        # report stderr output
        $t insert end "Process wrote to stderr (see below)\n" red
        set ch [open $ferr r]
        set errtext [read $ch]
        close $ch
    }

    $t insert end STDOUT:\n
    $t insert end $out blue
    $t insert end \n

    if {$errtext ne ""} {
        $t insert end "\nSTD ERR:\n"
        $t insert end $errtext red
    }
}

proc tvToolButtonDo {id} {
    # global buttons
    global tv
    switch $id {
        exit exit
        load tvSrcLoad 
        about tvWinAbout

        readmac -
        listmac {tvReadList $id}

        fonts -
        fontb {
            set f $tv(fonts,fixed)
            if {$id eq "fonts"} {set op -1} {set op +1}
            set sz [font configure $f -size]
            font configure $f -size [incr sz $op]
            after 100 tvLayoutRespace 
        }
        wide -
        narrow {
            # Change displayed lines by +/- 25%
            if {$id eq "wide"} {set op +} {set op -}
            foreach {k t} [array get tv pg,*,t] {
                set w [$t cget -width]
                set val [expr {round($w*.25)} ]
                if {$id eq "narrow" && $w < 20} continue
                if {$id eq "wide" && $w > 300} continue
                $t config -width [incr w $op$val]
            }
            after 100 tvLayoutRespace 
        }
    }
}
proc tvWinAbout {} {
    # Show the about window with a graphic and with
    # assorted informative/useful information
    global tv 
    global  tvimgdat
    set tlev .about
    destroy $tlev
    toplevel $tlev
    wm geometry $tlev +9000+9000

    set BG gray95
    set BG2 gray90
    $tlev config -bg $BG

    # Set up to center it eventually
    set W 400
    set H 300
    wm transient $tlev .
    
    set sw [winfo screenwidth .]
    set sh [winfo screenheight .]
    set x [expr ($sw/2)-($W/2) ]
    set y [expr ($sh/2)-($H/2) ]

    # 1. Label with graphic and text
    set img [image create photo -data $tvimgdat(gears)]
    1line {pack [label $tlev.l1 
        -image $img 
        -text "   [wm title .]"
        -font  [tvFont Title]
        -foreground darkred
        -background $BG
        -compound left
        -anchor w
        ] -side top -fill x -anchor w -padx 10 -pady 10
    }
    # pack propagate $tlev false

    # 2. At the bottom put copyright and tclbuzz promo
    set fbot [frame $tlev.fbot -bg $BG]
    pack $fbot -side bottom -fill x
    # 2.a horizontal divider
    pack [frame $fbot.ftopline -bg black -height 1] -side top -fill x -padx 5
    # 2.b Copy right, etc. on left bottom
    1line {pack [label $fbot.lcpr
        -text "Tmac - macro package\n  Copyright Roy Terry, 2003"
        -bg $BG
        -anchor w
        -justify left
        ] -side left -fill y -padx 5 -pady 3 -anchor w
    }

    # 2.c refer to web page on right side
    1line {pack [label $fbot.lwebsee
        -text "For updates see"
        -bg $BG
        -anchor w
        -justify left
        -pady 0 -bd 0
        ] -side top -fill y -padx 5 -pady 0 -anchor e
    }
    1line {pack [label $fbot.lwebaddr
        -text www.tclbuzz.com
        -bg $BG
        -anchor w
        -justify left
        -font [tvFont Title]
        ] -side top -fill y -padx 5 -pady {0 3} -anchor ne
    }

    # 3. Add close button
    1line {pack [button $tlev.bclose
        -text Close
        -command "destroy $tlev"
        -bd 2
        -width 12
        -relief solid
        -overrelief raised
        ] -side bottom -anchor e -padx 10 -pady 12
    }

    # 4. Central area holds misc information
    set bul \u2022
    global  tmLoadedBy tmLoadedFrom
    set    info "Tmac was accessed using: "
    append info "$tmLoadedBy   From: $tmLoadedFrom"
    append info \n

    set mcnt [llength [array names tmac::macs *,type]]
    append info "$bul $mcnt macro's are defined (see \"Browse Macs\")"
    append info \n

    append info "$bul Usage options:"
    append info \n
    append info "   tmac-viewer.tcl -mode vertical|horizontal \[filename\]"
    append info \n
    append info "$bul Vertical mode is more compact and\n\
                 aimed at interactive experimentation.\n\
                 This is the default. Minimal strings are\n\
                 -v(ertical) or -q(uick)"
    append info \n
    append info "$bul Horizontal mode is extended with more detail,\n\
                 statistics and ability to spawn another process\n\
                 to evaluate a whole macro enhanced program\n\
                 such as the sample \"dirstat.tcl\"\n\
                 Minimal strings are -h(orizontal) or -w(ide)"
    


    1line {pack [label $tlev.linfo
        -text $info
        -justify left
        -font [tvFont default]
        -anchor w
        -bg $BG2
        ] -side bottom -anchor w -padx 10 -pady 12 -fill both -expand yes
    }

    # Final step - show it
    wm title $tlev "Tmac"
    # Let actual size float to adjust to center label content
    # wm geometry $tlev =${W}x${H}+$x+$y
    wm geometry $tlev +$x+$y
    raise $tlev
    focus -force $tlev
    bind $tlev <Escape> "destroy $tlev"
}

proc tvReadList cmd {
    global tv
    switch $cmd {
        listmac {
            # popup a quick view list
            set tlev .listmac
            if {[winfo exists $tlev]} {destroy $tlev}
            toplevel $tlev
            wm title $tlev "Currently defined macros"
            # 22Nov03RT - display "read from" list
            1line {pack [label $tlev.lfrom
                -text "READ FROM:\n   [join $tv(readmac,files) "\n   " ]"
                -justify left
                -anchor w
                ] -side bottom -fill x -anchor w
            }
            pack [label $tlev.l1 -text "Macro names"] -side top -anchor w
            set lb [listbox $tlev.lb -height 30 -width 15]
            pack $lb -side top
            set sv [scrollbar $tlev.sv -orient vertical -command "$lb yview"]
            $lb config -yscrollcommand "$sv set"
            foreach mt [lsort [array names tmac::macs *,type]] {
                set m [lindex [split $mt ,] 0]
                $lb insert end $m
            }
            pack $lb -side left -fill y
            pack $sv -side left -fill y
            bind $lb <1> "focus -force $lb"

            # Details with scrollbar
            pack [label $tlev.l2 -text "Details:"] -side top -anchor w
            set t [text $tlev.tinfo]
            set svt [scrollbar $tlev.svt -orient vertical -command "$t yview"]
            $t config -width 25 -yscrollcommand "$svt set"
            markupTagsAdd $t
            pack $svt -side right -fill y
            pack $t -side top -fill both -expand 1
            bind $lb <<ListboxSelect>> "tvMacShow $lb $t"
        }
        readmac {
            set fn [tk_getOpenFile]
            if {$fn eq ""} return
            if {[catch {
                set ch [open $fn r]
                set data [read -nonewline $ch]
                close $ch
            } msg]} {
                tk_messageBox -title "Tmac View" \
                    -icon error -message "Sorry can't read \"$fn\" ($msg)"
                return
            }
            lappend tv(readmac,files) $fn
            tmfindexpand $data
        }
    }
    
}
proc tvMacShow {lb t} {
    set name [$lb get [$lb curselection]]
    upvar ::tmac::macs macs
    $t delete 1.0 end
    $t insert end "MACRO\t" "" $name blue \n ""
    $t insert end "Type\t" "" $macs($name,type) blue \n ""
    $t insert end "Parse\t" "" $macs($name,parse) blue \n ""
    if {$macs($name,type) eq "BLOCK"} {
        $t insert end "Params\t" "" $macs($name,plist) blue \n ""
        $t insert end "Block:\n" "" $macs($name,def) blue \n ""
    } else {
        # 24Nov03RT -account for the fact that mac can have a script
        # as its def, instead of just a proc name
        set mdef [proc2String $macs($name,def)]
        if {$mdef == ""} {
            set mdef $macs($name,def)
        }
        $t insert end "CMD:\n" "" "$mdef" blue \n ""
    }
}

proc tvFont {fname} {
    # Return font for name, create if necessary
    global tv
    if { ! [info exists tv(fonts,$fname)]} {
        switch $fname {
            Title {
                set tv(fonts,$fname) \
                    [font create -family helvetica -size 13 -weight bold]
            }
            Detail {
                set tv(fonts,$fname) \
                    [font create -family helvetica -size 10 -weight normal]
            }
            fixed {
                set tv(fonts,$fname) [font create -family Courier -size 9]
            }
            Toolbar {
                set tv(fonts,$fname) \
                    [font create -family helvetica -size 9 -weight bold]
            }
            default {
                set tv(fonts,$fname) [font create -family helvetica -size 10]
            }
        }
    }
    return $tv(fonts,$fname)
}


### Accessory procedures ########################################

proc proc2String {p} {
	# particular worker
	if {"[info commands $p]" != "$p"} {
		return ""
	}
	set    out "proc $p \{[info args $p]\} \{"
	append out \n[string trimleft [info body $p] \n] \}
	return $out
}
proc arrayNest {arrayName args} {
	# An optional kind of array set command
	# Allows nested *keys* to save typing and visual space
	# ==> -order flag causes ddd- to be prepended to each elements index so
	# that sorting can recover the order in which the elements were listed
	# ==> Performs <category> substitution and
	#  <row> substitution on values
	# EXAMPLE:
	# % arrayNest a -order {%name {sub1 <row>x sub2 y<category>}}
	# % parray a
	# a(000-name,sub1) = 0x
	# a(000-name,sub2) = y000-name

	# Allows whole-line comments in the array by stripping them here
	set mc [regsub -all {[\n\r]+[\t ]*#[^\n\r]*} $args " " args]
	
	upvar $arrayName a
	if {[lindex $args 0] == "-order"} {
		set lst [lindex $args 1]
		set order 0
	} else {
		set order -1
		set lst [lindex $args 0]
	}
	set maxi [expr [llength $lst] - 1]
	for {set i 0} {$i <= $maxi} {} {
		if {$order >= 0} {
			set oStr [format %03d- $order]
			incr order
		} else {
			set oStr ""
		}
		set e [lindex $lst $i]
		# Keys beginning with % are treated as having sublists
		if {[string match %* $e]} {
			set pre $oStr[string range $e 1 end]
			foreach {subkey val} [lindex $lst [expr $i + 1]] {
				# Special pattern in value is substituted with
				# value of prefix *including* any autogenerated index

				# Compress values if %- in key
				if {[string match %-* $subkey]} {
					set subkey [string range $subkey 2 end]
					regsub -all {\s+} $val " " val
				}
				regsub -nocase <category> $val $pre val
				regsub -nocase <row> $val $i val
				set a($pre,$subkey) $val
			 }
		} else {
			set a($oStr$e) [lindex $lst [expr $i + 1]]
		}
		incr i 2
	}
}
proc scrollbarAdd {w orient sbname} {
    # Given a widget name create a scollbar and
    # link them together
    if {$orient eq "vertical"} {set xy y} {set xy x}

    scrollbar $sbname -orient $orient -command "$w ${xy}view"
    $w config -${xy}scrollcommand "$sbname set"
}
proc markupTagsAdd {t} {
    # Add common markup tags to text widget
    foreach c {red blue green orange black} {
        $t tag configure $c -foreground $c
        $t tag configure ${c}UL -foreground $c -underline 1
        $t tag configure ${c}BOLD -foreground $c -underline 1
    }
    $t tag configure macdef -foreground black -background palegreen
    # a series of mac call tags to depict nesting
    $t tag configure mcall1 -foreground black -background paleturquoise1
    $t tag configure mcall2 -foreground black -background khaki1
    $t tag configure mcall3 -foreground black -background turquoise1
    $t tag configure mcall4 -foreground black -background khaki2
    $t tag configure mcall5 -foreground black -background red
    $t tag raise sel
}
proc 1line {code} {return [uplevel [string map {\n " "} $code]]}

####### Run it! ####
tvMain
if {[info exists argv] && [llength $argv] > 0} {
    if {[llength $argv] == 1} {
        tvSrcLoad $argv
    } else {
        tk_messageBox -message "Startup can only use a single file name\
            (got '[join $argv]')" \
            -icon error -title "Tmac Viewer" -parent .
    }
}


# TEST HELPERS BELOW
# tvSrcLoad dirstat.tcl
