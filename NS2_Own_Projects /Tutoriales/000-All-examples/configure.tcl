
# This script configures the graph package by finding
# the needed applications or allowing the user to input
# the paths to the needed applications.
#
# The configuration is output to $NS/tcl/rpi/options.tcl.
#
# author David Harrison


# Finds the specified application or an alternate application and
# then writes the result to the file specified by fp.  The output
# to the file is executable TCL as follows: 
#   
#    set X_app_path_ "$Y" 
#    set X_app_ "$Z" 
#
# where X is that plot device class name, Y is the absolute path to the
# application including the executable's file name, and Z is the
# application name.  For example, for gnuplot the result would be
#
#    set gnuplot_app_path_ "/usr/local/bin/gnuplot"
#    set gnuplot_app_ "gnuplot"
#
# if gnuplot is in /usr/local/bin.
#
# Arguments:
#   fp          outputs configuration to this file
#   plot_device_class_name
#               this proc configures the path to the application for the 
#               plot device with the given classname.
#   app_name    the default application for the given plot device class.
#   alternative_app_names
#               list of applications that can also operate with the given
#               plot device class.  This proc searches for this alternatives
#               only if the default application specified by "app_name"
#               is not found.
#   
# Returns
#               
#   "appname path"
#               The appname or selected alternative and the path to this
#               app or alternative. This path was
#               output to the options.tcl.
#
#   ""          The app and no alternative were found.
#
proc configure-app { fp plot_device_class_name app_name \
  { alternative_app_names "" } } \
{

  set path [find-in-path $app_name]

  # application was found.
  if { $path != "" } {
    puts $fp "set [set plot_device_class_name]_app_path_ \"$path\"" 
    puts $fp "set [set plot_device_class_name]_app_ \"$app_name\"" 
    return "$app_name $path"
  }

  # If the app was not found in the PATH then check for alternatives. 
  if { $path == "" } {
    for { set i 0 } { $i < [llength $alternative_app_names] } { incr i } {
      set alt_app_name [lindex $alternative_app_names $i]
      set alt_path [find-in-path $alt_app_name]
      if { $alt_path != "" } {
        puts -nonewline "
    $app_name was not found in your PATH, but an alternative 
    application $alt_app_name that works with the plot device class
    $alt_app_name was found at
      $alt_path
    Do you want to use $alt_app_name in place of $app_name \[y/n\]?"
        set answer ""
        while { $answer != "y" && $answer != "Y" && $answer != "n" && \
                $answer != "N" } {
          flush stdout
          set answer [gets stdin]
	    puts "" ;# just for prettiness, insert a blank line.
        }
        if { $answer == "y" || $answer == "Y" } {
          puts $fp \
            "set [set plot_device_class_name]_app_path_ \"$alt_path\""
          puts $fp \
            "set [set plot_device_class_name]_app_ \"$alt_app_name\""
          return "$alt_app_name $alt_path"
        }
      }
    }
  } 

  # no alternative was found. So ask for paths to the app_name and 
  # failing that ask for paths to the alternate applications.
  set path [user-enter-path $app_name 0] 

  if { $path != "" } {
    # extract app name from the path.
    set last_slash [string last "/" $path]
    set len [string length $path]
    if { $last_slash > -1 } {
      set app_name [string range $path [expr $last_slash+1] [expr $len-1]]
    } else {
      set app_name $path
    } 
 
    puts $fp "set [set plot_device_class_name]_app_path_ \"$path\""
    puts $fp "set [set plot_device_class_name]_app_ \"$app_name\""
    return "$app_name $path"
  }

  for { set i 0 } { $i < [llength $alternative_app_names] } { incr i } \
  {
    set alt_app_name [lindex $alternative_app_names $i]
    
    set alt_path [user-enter-path $alt_app_name 1]
    if { $alt_path != "" } {
      puts $fp "set [set plot_device_class_name]_app_path_ \"$alt_path\""
      puts $fp "set [set plot_device_class_name]_app_ \"$alt_app_name\""
      return "$alt_app_name $alt_path"
    }
  }
  
  # The app and none of its alternatives were found and the user provided
  # no paths to these apps so we simply recognize that the application
  # is not usable by the graph package and set the path to it to "".
  puts $fp "set [set plot_device_class_name]_app_path_ \"\""
  puts $fp "set [set plot_device_class_name]_app_ \"\""
  return ""
} 

# FIND IN PATH will search the path for a given program.
proc find-in-path { filename } {
  set result ""
  catch {
    set result [exec which $filename]
  } err

  if { $result != "" && [file exists $result] } {
    return $result
  }

  # else result is empty or does not refer to a valid file.
  return ""
}


# requests that the user input the path to an executable. 
proc user-enter-path { app_name is_alt } {
  puts -nonewline "  $app_name not found."
  while { 1 } {
    if { $is_alt } {
      puts -nonewline "  Enter path to alternative application $app_name or hit return if it's not installed:\n  "
    } else {
      puts -nonewline "  Enter path to $app_name or hit return if it's not installed:\n  "
    }

    set path [gets stdin]
    if { $path == "" } {
      return "" 
    } 
    if { [file isfile $path] } {
      return $path
    } 
    if { [file isdirectory $path] } {
      set len [string length $path]
      set lastchar [string range $path [expr $len-1] [expr $len-1]]
      if { $lastchar != "/" } {
        set path "[set path]/"
      }

      set path "[set path][set app_name]"
      if { [file isfile $path] } {
        return $path
      }
    } 

    # if the path were found then the function would've returned.
    puts "  $path does not exist."
  }
}

# backs up a file to a file with the same name except appending
# .bakXX where XX is replaced by a number.  The number is 
# unique so that no prior backup is deleted with a larger number
# denoting a more recent backup.
proc backup { file } {

  for { set i 0 } { 1 } { incr i } {
      if { ![ file exists "[set file].bak$i"] } {
        puts "  Backing up\n  $file\n   to\n  [set file].bak$i\n"
	file copy $file "[set file].bak$i"
      return
    }
  }
}


###############################################
# MAIN

if { ![info exists env(NS)] } {
  puts "
  Before running configure.tcl, please define the NS environment 
  such that it points to the root directory of the NS source code 
  tree."
  exit -1
}

# backup the existing options.tcl file if it already exists.
if { [file exists "$env(NS)/tcl/rpi/options.tcl"] } {
  backup "$env(NS)/tcl/rpi/options.tcl"
}

# Create a new options.tcl file.
set fp [open "$env(NS)/tcl/rpi/options.tcl" "w"]

# Output the header to the options.tcl file.
puts $fp "
# This is an automatically generated file that specifies the paths
# to the applications used by the RPI graph package.  It is created by 
# $env(NS)/tcl/rpi/configure.tcl
#
# If you install an application used by NS then rerun configure to 
# set up the appropriate path.
#
# When configure.tcl was run it copied any prior version of options.tcl
# to a backup with the same name except \".bakXX\" was appended.  Here 
# XX is replaced with a unique integer starting from 1.  Larger numbers 
# denote more recent versions of options.tcl.  If you no longer need
# a backup of the options.tcl file then you may delete it.
#
# author: David Harrison
"

# Configure the RPI graphing and statistics package.
set pair [configure-app $fp "nam" "nam"]
if { $pair != "" } {
  puts "  nam found."
} else {
  puts "  nam not found."
}

set pair [configure-app $fp "xgraph" "xgraph"]
if { $pair != "" } {
  puts "  xgraph found."
  set found_xgraph 1
} else {
  puts "  xgraph not found.  Cannot use xgraph plot device."
  set found_xgraph 0
}

set pair [configure-app $fp "gnuplot" "gnuplot"]
if { $pair != "" } {
  puts "  gnuplot found."
  set found_gnuplot 1
} else {
  puts "\
  gnuplot not found.  Cannot use:
    gnuplot, acroread, fig, latex, ghostview, postscript, and xdvi
    plot devices."
  set found_gnuplot 0
}

if { !$found_xgraph && !$found_gnuplot } {
  puts "

  Neither xgraph or gnuplot could be found in the PATH.  
  Without at least one of these applications, the graph 
  package cannot function."
  exit -1
}

set pair [configure-app $fp "ghostview" "ghostview" "gsview32 evince"]
if { $pair != "" } {
  set found_ghostview 1
  puts "  [lindex $pair 0] found."
} else {
  puts "  ghostview not found.  Cannot use ghostview plot device."
  set found_ghostview 0
}

set pair [configure-app $fp "latex" "latex"]
if { $pair != "" } {
  puts "  latex found."
  set found_latex 1
} else {
  puts "  latex not found.  Cannot use latex and xdvi plot devices."
  set found_latex 1
}

set pair [configure-app $fp "xdvi" "xdvi"]
if { $pair != "" } {
  puts "  xdvi found."
  set found_xdvi 1
} else {
  puts "  xdvi not found.  Cannot use xdvi plot device."
  set found_xdvi 0
}

set pair [configure-app $fp "pdf" "epstopdf" "pstopdf"]
if { $pair != "" } {
  puts "  [lindex $pair 0] found."
  set found_epstopdf 1
} else {
  puts "  epstopdf not found.  Cannot use pdf plot device."
  set found_epstopdf 0
}

set pair [configure-app $fp "pdflatex" "pdflatex"]
if { $pair != "" } {
  puts "  pdflatex found."
  set found_pdflatex 1
} else {
  puts "  pdflatex not found.  Cannot use acroread plot device."
  set found_pdflatex 0
}


set pair [configure-app $fp "acroread" "acroread" "acroread acrobat"]
if { $pair != "" } {
  puts "  [lindex $pair 0] found."
  set found_acroread 1
} else {
  puts "  acroread not found.  Cannot use acroread plot device."
  set found_acroread 0
}

# close the options file.
close $fp

if { !$found_xgraph ||
     !$found_gnuplot ||
     !$found_latex ||
     !$found_xdvi ||
     !$found_epstopdf ||
     !$found_pdflatex ||
     !$found_acroread } {
  puts -nonewline "\nNOTE: One or more applications used by the RPI
  graph and statistics package have not been found.  If these
  applications are installed on your system then re-run
  this configuration script.

  Without these applications, all graphs will still be
  displayable, but you will not be able to use the plot
  devices that depend on the missing applications."

} else {
  puts "
  All applications used by the RPI graph and statistics package were found."
}

puts "

  Hit return to continue configuring the RPI graphing and statistics
  package. "

gets stdin


