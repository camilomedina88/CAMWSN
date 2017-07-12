
# BitTorrent P2P Simulation
# Flashcrowd
# PARAMETERS: N_P RNG_SEED C_up

global argv


if { $argc > 0 } {
	set i 1
        foreach arg $argv {
	
		if {$i==1} {
			set no_of_peers $arg
		}
		if {$i==2} {
			set s $arg
		}
		if {$i==3} {
			set C_up [expr $arg * 1000]
		}			
                incr i
        }
}

if {$argc != 3} {
	puts "Error: wrong parameters ->  peers  run upload_cap\[kBits/s\]"
	exit 0
}



set ns [new Simulator]

$ns use-scheduler Heap

# Simulation Parameters:
	source bittorrent/bittorrent_default.tcl
		
	BitTorrentApp set leave_option -1
	
	# number of request to pipeline (set to 1 to ensure fairness between peers. Requests are handled in FIFO manner.)
	BitTorrentApp set pipelined_requests 1
	
	# number of peers
	set N_P $no_of_peers
		
	# number of seeds
	set N_S 1
	
	# upload capacity of node [bits/s]
	set C_up_bytes [expr $C_up / 8.0 ]	
	
	# file size
	set S_F_MB 100
	
	set S_F [expr $S_F_MB * 1024.0 *1024.0]
	set S_C [expr 256.0 *1024]	
	set N_C [format %.0f [expr ceil($S_F / $S_C)]]

	# set the seed for the RNG (0: non-deterministic, 1 - MAXINT (2147483647))
	set rng_seed $s

# End of SimulationParameters

set peerCount 0
set FinishedPeers 0

# NAME OF TRACE FILE
set p2ptrace	bittorrent/results_flash_flow_
append p2ptrace $S_F_MB
append p2ptrace MB_N_P_
append p2ptrace $N_P
append p2ptrace _C_
append p2ptrace $C_up_bytes
append p2ptrace Bps
append p2ptrace _seed_
append p2ptrace $s
append p2ptrace _
append p2ptrace [clock seconds]

exec mkdir $p2ptrace
puts $p2ptrace

set p2ptrace2 $p2ptrace
append p2ptrace /log

#exec cp bittorrent/scripts/bt_flashcrowd_flow.tcl $p2ptrace2
exec cp bittorrent/bittorrent_default.tcl $p2ptrace2

set fh [open $p2ptrace w]


# Seed the default RNG (Problem with seeds: some random seed are larger than MAXINT)
global defaultRNG
$defaultRNG seed $rng_seed

proc done {} {

	global N_P app FinishedPeers fh ns

	incr FinishedPeers
	
	if {$FinishedPeers == $N_P} {
		for {set i 0} {$i < $N_P} {incr i} {
			$app($i) stop
		}
	
		close $fh
		puts [$ns now]
		exit 0
	}
}


# create tracker (Parameters: File Size [B], Chunk Size [B])
set go [new BitTorrentTracker/Flowlevel $S_F $S_C]
$go tracefile $p2ptrace


# uniform start offset for peers
set t_offset_rng [new RNG]
set t_offset [new RandomVariable/Uniform]
$t_offset set min_ 0
$t_offset set max_ [BitTorrentApp set choking_interval]
$t_offset use-rng $t_offset_rng



# Create Seeds
for {set i 0} {$i < $N_P} {incr i} {		
	
	if {$i < $N_S} {
		set app($peerCount) [new BitTorrentApp/Flowlevel 1 $C_up_bytes  $go]
		
		$app($peerCount) set super_seeding 1
		$app($peerCount) tracefile $p2ptrace
		
		# start apps
		$ns at 0.0 "$app($peerCount) start"
		
		incr FinishedPeers
	} else {
		set app($peerCount) [new BitTorrentApp/Flowlevel 0 $C_up_bytes $go]
		
		$app($peerCount) tracefile $p2ptrace
	
		# start apps
		$ns at [$t_offset value] "$app($peerCount) start"
	}	
	
	incr peerCount
}

# Run the simulation
$ns run