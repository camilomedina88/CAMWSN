#  Adhoc.tcl ---
#  
#      This file is part of The Coccinella application. 
#      It implements XEP-0050: Ad-Hoc Commands
#      
#  Copyright (c) 2007  Mats Bengtsson
#  
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#   
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#   
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#  
# $Id: Adhoc.tcl,v 1.14 2008-03-29 07:08:41 matben Exp $

# @@@ Maybe all this should be a component?

package provide Adhoc 1.0

namespace eval ::Adhoc {

    ::hooks::register discoInfoHook                   ::Adhoc::DiscoInfoHook
    ::hooks::register discoPostCommandHook            ::Adhoc::PostMenuHook
    
    variable prefs
    set prefs(autoDisco) 1
    
    variable xmlns
    set xmlns(commands) "http://jabber.org/protocol/commands"
    set xmlns(xdata)    "jabber:x:data"
    set xmlns(oob)      "jabber:x:oob"
    
    variable uid 0
    
    variable noteType
    set noteType(info)  "The note is informational only. This is not really an exceptional condition."
    set noteType(warn)  "The note indicates a warning. Possibly due to illogical (yet valid) data."
    set noteType(error) "The note indicates an error. The text should indicate the reason for the error."
}

proc ::Adhoc::DiscoInfoHook {type from queryE args} {
    variable xmlns
    variable prefs

    if {!$prefs(autoDisco)} {
	return
    }
    if {$type eq "error"} {
	return
    }
    set node [wrapper::getattribute $queryE node]
    if {[::Jabber::Jlib disco hasfeature $xmlns(commands) $from]} {
	GetCommandList $from [namespace code GetCommandListCB]
    }
}

proc ::Adhoc::GetCommandList {jid cmd} {
    variable xmlns
    ::Jabber::Jlib disco get_async items $jid $cmd -node $xmlns(commands)
}

proc ::Adhoc::GetCommandListCB {jlibname type from queryE args} {
    # empty
}

proc ::Adhoc::PostMenuHook {m clicked jid node} {
    variable xmlns
    
    if {![::Jabber::Jlib disco hasfeature $xmlns(commands) $jid $node]} {
	return
    }
    set name mAdHocCommands
    set midx [::AMenu::GetMenuIndex $m $name]
    if {$midx eq ""} {
	# Probably a submenu.
	return
    }
    $m entryconfigure $midx -state normal
    set mt [$m entrycget $midx -menu]
    set xmllist [::Jabber::Jlib disco getxml items $jid $xmlns(commands)]
    set queryE [wrapper::getfirstchildwithtag $xmllist query]
    foreach itemE [::wrapper::getchildren $queryE] {
	if {[wrapper::gettag $itemE] eq "item"} {
	    set jid  [wrapper::getattribute $itemE jid]
	    set node [wrapper::getattribute $itemE node]
	    set name [wrapper::getattribute $itemE name]
	    set label $name
	    if {$label eq ""} {
		set label $jid
	    }
	    $mt add command -label "$label..." \
	      -command [namespace code [list Execute $jid $node]]
	}
    }
}

proc ::Adhoc::FindLabelForJIDNode {jid node} {
    variable xmlns

    set label $jid
    set xmllist [::Jabber::Jlib disco getxml items $jid $xmlns(commands)]
    set queryE [wrapper::getfirstchildwithtag $xmllist query]
    foreach itemE [::wrapper::getchildren $queryE] {
	if {[wrapper::gettag $itemE] eq "item"} {
	    set xjid  [wrapper::getattribute $itemE jid]
	    set xnode [wrapper::getattribute $itemE node]
	    if {($jid eq $xjid) && ($node eq $xnode)} {
		set name [wrapper::getattribute $itemE name]
		set label $name
		if {$label eq ""} {
		    set label $jid
		}
		break
	    }
	}
    }
    return $label
}

proc ::Adhoc::Execute {jid node} {
    variable xmlns

    set commandE [wrapper::createtag command \
      -attrlist [list xmlns $xmlns(commands) node $node action execute]]
    ::Jabber::Jlib send_iq set [list $commandE] -to $jid \
      -command [namespace code [list ExecuteCB $jid $node]] \
      -xml:lang [jlib::getlang]
}

proc ::Adhoc::ExecuteCB {jid node type subiq args} {

    if {$type eq "error"} {
	set errcode [lindex $subiq 0]
	set errmsg  [lindex $subiq 1]
	set label [FindLabelForJIDNode $jid $node]
	ui::dialog -icon error -title [mc "Error"] \
	  -message "Ad-Hoc command for \"$label\" at $jid failed because: $errmsg"
    } else {
	BuildDlg $jid $node $subiq
    }
}

proc ::Adhoc::BuildDlg {jid node subiq} {
    global  wDlgs
    variable uid

    # Collect some useful attributes.
    set sessionid [wrapper::getattribute $subiq sessionid]
    set status    [wrapper::getattribute $subiq status]
    
    set w $wDlgs(jadhoc)[incr uid]
        
    # Keep instance specific state array.
    variable $w
    upvar 0 $w state    

    set state(w)          $w
    set state(sessionid)  $sessionid
    set state(status)     $status

    ::UI::Toplevel $w -class AdHoc  \
      -usemacmainmenu 1 -macstyle documentProc -macclass {document closeBox} \
      -closecommand [namespace code CloseCmd]
    set label [FindLabelForJIDNode $jid $node]
    wm title $w "Ad-Hoc for \"$label\""

    set nwin [llength [::UI::GetPrefixedToplevels $wDlgs(jadhoc)]]
    if {$nwin == 1} {
	::UI::SetWindowPosition $w $wDlgs(jadhoc)
    }

    ttk::frame $w.all -padding [option get . dialogPadding {}]
    pack $w.all -side top -fill both -expand 1
    
    # Duplicates the form, typically.
    # set label [FindLabelForJIDNode $jid $node]
    # ttk::label $w.all.lbl -text $label
    # pack $w.all.lbl -side top
    
    # NB: We may not always get an xdata element, it could be note elements,
    #     or jabber:x:oob.
    set state(wmain)  $w.all.main
    set state(wform)  $w.all.main.form
    set state(wnotes) $w.all.main.notes
    PayloadFrame $w $subiq

    set bot $w.all.bot
    ttk::frame $bot -padding [option get . okcancelTopPadding {}]

    if {$status eq "completed"} {
	
	# completed: The command has completed. The command session has ended.
	# Typical if a command does not require any interaction.
	ttk::button $bot.close -text [mc "Cancel"] -default active \
	  -command [namespace code [list CloseCmd $w]]
	pack $bot.close -side right
	
	bind $w <Return> [list $bot.close invoke]
    } else {
	ttk::button $bot.next -text [mc "Next"] -default active \
	  -command [namespace code [list Action $w execute]]
	ttk::button $bot.prev -text [mc "Previous"] \
	  -command [namespace code [list Action $w prev]]
	$bot.prev state {disabled}
	set padx [option get . buttonPadX {}]
	pack $bot.next -side right
	pack $bot.prev -side right -padx $padx
    }
    ::UI::ChaseArrows $bot.arr
    pack $bot.arr -side left -padx 5 -pady 5
    
    pack $bot -side bottom -fill x

    set state(wclose)     $bot.close
    set state(wnext)      $bot.next
    set state(wprev)      $bot.prev
    set state(warrows)    $bot.arr
    set state(jid)        $jid
    set state(node)       $node
    
    if {$status ne "completed"} {
	SetActionButtons $w $subiq
    }   
    return $w
}

# Adhoc::PayloadFrame --
# 
#       Build the payload frame from the xml payload of the command element.
#       Normally a single jabber:x:data element but can also be jabber:x:oob
#       elements and a number of note elements.
#       
#       XEP-0050: When the precedence of these payload elements becomes 
#       important (such as when both "jabber:x:data" and "jabber:x:oob" 
#       elements are present), the order of the elements SHOULD be used. 
#       Those elements that come earlier in the child list take precedence 
#       over those later in the child list. 

proc ::Adhoc::PayloadFrame {w subiq} {
    variable $w
    upvar 0 $w state
    
    ttk::frame $state(wmain)
    pack $state(wmain) -side top -fill both -expand 1

    XDataFrame $w $subiq
    NotesFrame $w $subiq
    OOBFrame $w $subiq
}

proc ::Adhoc::XDataFrame {w subiq} {
    variable $w
    upvar 0 $w state
    variable xmlns
    
    foreach E [wrapper::getchildren $subiq] {
	if {([wrapper::gettag $E] eq "x") && \
	  ([wrapper::getattribute $E xmlns] eq $xmlns(xdata))} {
	    set wform $state(wform)
	    set state(xtoken) [::JForms::XDataFrame $wform $E -width 300]
	    pack $wform -side top -fill both -expand 1
	    
	    if {$state(status) eq "completed"} {
		::JForms::SetState $state(xtoken) disabled
	    }
	    break
	}
    }  
}

proc ::Adhoc::NotesFrame {w subiq} {
    variable $w
    upvar 0 $w state
    variable xmlns
    variable noteType
    
    set i 0
    set wnotes $state(wnotes)
    foreach E [wrapper::getchildren $subiq] {
	if {[wrapper::gettag $E] eq "note"} {
	    if {![winfo exists $wnotes]} {
		ttk::frame $wnotes
		pack $wnotes -side top -fill both -expand 1
	    }
	    set wlab $wnotes.l$i
	    ttk::label $wlab -text [wrapper::getcdata $E]
	    grid  $wlab  -sticky w
	    
	    set type [wrapper::getattribute $E type]
	    if {$type eq ""} {
		set type "info"
	    }
	    if {[info exists noteType($type)]} {
		::balloonhelp::balloonforwindow $wlab $noteType($type)
	    }
	    incr i
	}
    }
}

proc ::Adhoc::OOBFrame {w subiq} {
    variable $w
    upvar 0 $w state
    variable xmlns
    
    foreach E [wrapper::getchildren $subiq] {
	if {([wrapper::gettag $E] eq "query") && \
	  ([wrapper::getattribute $E xmlns] eq $xmlns(oob))} {
	    
	    # @@@ It is unclear what this looks like.
	}
    }
}

# Adhoc::GetActions --
# 
#       Extract any action element from the commands element:
#           <actions execute='complete'>
#               <prev/>
#               <complete/>
#           </actions> 

proc ::Adhoc::GetActions {subiq} {
    
    set actions [list]
    set execute ""
    if {[wrapper::gettag $subiq] eq "command"} {
	set commandE $subiq
	set actionsE [wrapper::getfirstchildwithtag $commandE actions]
	if {[llength $actionsE]} {
	    set execute [wrapper::getattribute $actionsE execute]
	    foreach E [wrapper::getchildren $actionsE] {
		lappend actions [wrapper::gettag $E]
	    }
	}
    }
    return [list $actions $execute]
}

proc ::Adhoc::Action {w action} {
    variable $w
    upvar 0 $w state
    variable xmlns
    
    $state(warrows) start
    $state(wprev) state {disabled}
    $state(wnext) state {disabled}
    
    set xdataEs [::JForms::GetXML $state(xtoken)]
    set attr [list xmlns $xmlns(commands) node $state(node) action $action \
      sessionid $state(sessionid)]
    set commandE [wrapper::createtag command \
      -attrlist $attr -subtags $xdataEs]
    ::Jabber::Jlib send_iq set [list $commandE] -to $state(jid) \
      -command [namespace code [list ActionCB $w]] \
      -xml:lang [jlib::getlang]
}

proc ::Adhoc::ActionCB {w type subiq args} {
    
    if {![winfo exists $w]} {
	return
    }
    variable $w
    upvar 0 $w state

    $state(warrows) stop
 
    set status [wrapper::getattribute $subiq status]
    set state(status) $status
    
    if {$type eq "error"} {
	set errcode [lindex $subiq 0]
	set errmsg  [lindex $subiq 1]
	set label [FindLabelForJIDNode $state(jid) $state(node)]
	ui::dialog -icon error -title [mc "Error"] \
	  -message "Ad-Hoc command for \"$label\" at $jid failed because: $errmsg"
	Close $w
    } else {
	
	set wmain $state(wmain)
	destroy $wmain
	PayloadFrame $w $subiq
	
	if {$status eq "completed"} {
	    $state(wprev) configure -default normal
	    $state(wnext) configure -default normal
	    $state(wnext) state {!disabled}
	    $state(wnext) configure -text [mc "Cancel"] -default active \
	      -command [namespace code [list Close $w]]
	} else {
	    SetActionButtons $w $subiq
	}	
	
	# There can be one or many jabber:iq:oob elements as well.
	
    }
}

proc ::Adhoc::SetActionButtons {w subiq} {
    variable $w
    upvar 0 $w state
    
    $state(wprev) configure -default normal
    $state(wnext) configure -default normal
    bind $w <Return> {}

    lassign [GetActions $subiq] actions execute
    foreach action $actions {
	switch -- $action {
	    next - prev {
		$state(w$action) state {!disabled}
		$state(w$action) configure \
		  -command [namespace code [list Action $w $action]]
	    }
	    complete {
		$state(wnext) state {!disabled}
		$state(wnext) configure -text [mc "Finish"] \
		  -default active \
		  -command [namespace code [list Action $w complete]]
	    }
	}
    }
    switch -- $execute {
	next - prev {
	    $state(w$execute) configure -default active
	    bind $w <Return> [list $state(w$execute) invoke]
	}
	complete {
	    $state(wnext) configure -default active
	    bind $w <Return> [list $state(wnext) invoke]
	}
    }
}

proc ::Adhoc::Cancel {w} {
    variable $w
    upvar 0 $w state
    variable xmlns

    set attr [list xmlns $xmlns(commands) node $state(node) action cancel \
      sessionid $state(sessionid)]
    set commandE [wrapper::createtag command -attrlist $attr]
    ::Jabber::Jlib send_iq set [list $commandE] -to $state(jid) \
      -xml:lang [jlib::getlang]
}

proc ::Adhoc::CloseCmd {w} {
    variable $w
    upvar 0 $w state
    
    if {$state(status) ne "completed"} {
	Cancel $w
    }
    Close $w
}

proc ::Adhoc::Close {w} {
    global  wDlgs

    ::UI::SaveWinGeom $wDlgs(jadhoc) $w
    unset -nocomplain state
    destroy $w
    return
}

