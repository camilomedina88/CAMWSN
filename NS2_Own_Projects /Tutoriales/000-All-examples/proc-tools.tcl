
# ############################################################### 
# Thierry Ernst 1999/2000
# INRIA Rhone-Alpes Grenoble FRANCE - MOTOROLA Labs Paris FRANCE 
# 
# Generic procedures for simulation
# ############################################################### 

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Display NS addressing
# OK 10/2000
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc display_ns_addr_domain {} {
   puts ""
   puts "  >-------------------- NS Addressing --------------------<"
   puts "  Domains (domain_num) : [AddrParams set domain_num_]"
   puts "  Clusters (cluster_num) : [AddrParams set cluster_num_]"
   puts "  Nodes (nodes_num) :  [AddrParams set nodes_num_]"
   #if { [AddrParams set hlevel_] == 4 } {
   #  puts "  Last (last_num) : [AddrParams set last_num_]"
   #}
   puts "  >-------------------------------------------------------<"
   puts ""
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Counter to follow up where we are
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc counter {time} {
   global ns 
   # puts "$time ..."
   $ns at [expr $time + 50] "counter [expr $time + 50]"
}  

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Usage
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc Usage {} {
        global opt argv0
        puts "Usage: $argv0 \[-stop sec\] \[-seed value\] \[-node numNodes\]"
        puts "\t\[-tr tracefile\] \[-g\]"
        exit 1
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Display Command Line
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc DisplayCommandLine {} {
   global opt argc argv

   puts "* Command Line is:"
   for {set i 0} {$i < $argc} {incr i} {
	puts -nonewline "[lindex $argv $i] "
   }
   puts ""
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Read arguments from the command line
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc Getopt {} {
   global opt argc argv

   for {set i 0} {$i < $argc} {incr i} {
                set key [lindex $argv $i]
                if ![string match {-*} $key] continue
                set key [string range $key 1 end]
                set val [lindex $argv [incr i]]
                set opt($key) $val
                if [string match {-[A-z]*} $val] {
                        incr i -1
                        continue
                }
                switch $key {
                        ll  { set opt($key) LL/$val }
                        ifq { set opt($key) Queue/$val }
                        mac { set opt($key) Mac/$val }
                }
   }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Log Movement
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc log-mn-movement { } {
  global logtimer ns
  Class LogTimer -superclass Timer
  LogTimer instproc timeout {} {
        [get_mobile_by_index 0] log-movement 
        $self sched 1 
  }
  set logtimer [new LogTimer]
  $logtimer sched 1  
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Dump topology
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Simulator instproc dump-topology { file } {
        $self instvar topology_dumped started_
        set started_ 1

        # set topology_dumped 1

        # make sure this does not affect anything else later on !
        # $self namtrace-all $file

        # Color configuration for nam
        $self dump-namcolors

        # Node configuration for nam
        $self dump-namnodes

        # Lan and Link configurations for nam
        $self dump-namlans
        $self dump-namlinks

        # nam queue configurations
        $self dump-namqueues

        # Traced agents for nam
        $self dump-namagents
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Periodic dump to trace file
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Simulator instproc periodic-dump { trace_file record_interval stop} {
	set ft 0
        while { $ft < $stop } {
                $self at $ft "flush $trace_file"
                set ft [expr $ft + $record_interval]
        }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Dump trace and post the time at which this proc will be
# executed next.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Simulator instproc dump-trace { file interval stop} {
	set now [$self now]
        flush $file
        set time [expr $now + $interval]
	if { $time < $stop } {
		$self at $time "$self dump-trace $file $interval $stop" 
        }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Display some information about a node id
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Simulator  instproc display_node_info {index} { 
   set node [$self set Node_($index)] 
   set address [$node set address_] 
   puts "Node $index: $address ($node) \[[$node set nodetype_]\]" 
}


