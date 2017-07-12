
source $env(NS)/tcl/rpi/file-tools.tcl

puts -nonewline "file-tools.tcl Test:"

set tmp_dir [create-tmp-directory]
if { [file exists $tmp_dir] } {
  puts "\tPASSED"
  exec rm -rf $tmp_dir
} else {
  puts "\tFAILED
    Directory \"$tmp_dir\" was supposedly created, but is not found."
  exit -1
}

