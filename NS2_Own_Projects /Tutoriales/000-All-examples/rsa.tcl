#!/usr/bin/tclsh

# Tcl program to encrpyt and decrypt a file using RSA

# initialize the parameters for RSA algorithm
set e 3
set d 11787
set n 17947

# accept the user's choice
puts "Enter 'E' to encrpyt or 'D' to decrypt"
set choice [gets stdin]
set choice [string toupper $choice]
if {$choice eq "E"} {

# accept the name of the file to encrypt from the user
puts "Enter the absolute path of the file to be encrypted :\t"
set fname [gets stdin]
puts "ENCRYPTION IN PROGRESS ......"
set new [split $fname {.}]
set newfile [lindex $new 0]

# open the file in read mode
set fileid1 [open $fname r]

# open another file in write mode
append newfile "_crypt.txt"
set fileid2 [open $newfile w]

# read the input file
set cont [read $fileid1]
close $fileid1

#split the file contents into constituent characters
set mylist [split $cont {}]

# process character-wise and encrypt
foreach {char} $mylist {
	set asc [scan $char %c] ; # scan command here is used to convert char to ascii
	set res 1
	for {set i 1} {$i <= $e} {incr i} {
		set res [expr "($res * $asc) % $n"]
	}
	set newchar [format "%c" $res]
	puts -nonewline $fileid2 $newchar
}
close $fileid2
puts "ENCRYPTION COMPLETE ......"
}


if {$choice eq "D"} {
# Tcl program to decrpyt a file using RSA 

# initialize the parameters for RSA algorithm
set e 3
set d 11787
set n 17947

# accept file name to decrypt
puts "Enter the absolute path of the file to be decrypted :\t"
set fname [gets stdin]
puts "DECRYPTION IN PROGRESS ......"
set new [split $fname {.}]
set newfile [lindex $new 0] 


# open the file in read mode
set fileid1 [open $fname r]

# open another file in write mode
append newfile "_decrypt.txt"
set fileid2 [open $newfile w]

# read the input file
set cont [read $fileid1]
close $fileid1

#split the file contents into constituent characters
set mylist [split $cont {}]

# process character-wise
foreach {char} $mylist {
	if {$char eq ""} {break}
	set asc [scan $char %c]
	set res 1
	for {set i 1} {$i <= $d} {incr i} {
		set res [expr "($res * $asc) % $n"]
	}
	set newchar [format "%c" $res]
	puts -nonewline $fileid2 $newchar
}
close $fileid2
puts "DECRYPTION COMPLETE ......"
}
