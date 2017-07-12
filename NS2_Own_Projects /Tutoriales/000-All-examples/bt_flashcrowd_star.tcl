
# BitTorrent P2P Simulation
# Flashcrowd
# PARAMETERS: N_P RNG_SEED C_up

global argv

# topology: STAR

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

#Create a simulator object
set ns [new Simulator]

remove-all-packet-headers
add-packet-header IP TCP Flags

$ns use-scheduler Heap

#set the routing protocol
$ns rtproto Manual


# Simulation Parameters:
	source bittorrent/bittorrent_default.tcl

	BitTorrentApp set leave_option -1

	# number of peers
	set N_P $no_of_peers
	
	# number of seeds
	set N_S 1
	
	# upload capacity in bytes
	set C_up_bytes [expr $C_up / 8.0 ]
	
	# factor that download capacity is higher than upload capacity
	set C_down_fac 8
	
	# queue size at access links (default 50)
	set Q_access 25
	
	# delay
	set DelayMin 1
	set DelayMax 50
	
	# file size
	set S_F_MB 100
	
	set S_F [expr $S_F_MB * 1024.0 *1024]
	set S_C [expr 256.0 *1024]
	set N_C [format %.0f [expr ceil($S_F / $S_C)]]

	# set the seed for the RNG (0: non-deterministic, 1 - MAXINT (2147483647))
	set rng_seed $s

# End of SimulationParameters

set peerCount 0
set FinishedPeers 0


# NAME OF TRACE FILE
set p2ptrace	bittorrent/results_flash_packet_star_
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

#exec cp bittorrent/scripts/bt_flashcrowd_star.tcl $p2ptrace2
exec cp bittorrent/bittorrent_default.tcl $p2ptrace2

set fh [open $p2ptrace w]


# set MSS for all FullTCP connections
Agent/TCP/FullTcp set segsize_ 1460
Queue set limit_ $Q_access

# Seed the default RNG 
global defaultRNG
$defaultRNG seed $rng_seed
#puts [$defaultRNG seed]


# Create Connections
proc fully_meshed2 {no_of_peers} {
	global ns peer router C_up C_down_fac DelayMin DelayMax
	
	
	set e2eDelayRng [new RNG]
	set e2eDelay [expr round([$e2eDelayRng uniform $DelayMin $DelayMax])]
	
	# upstream
	$ns simplex-link $peer($no_of_peers) $router $C_up [expr $e2eDelay]ms DropTail
	# downstream
	$ns simplex-link $router $peer($no_of_peers) [expr $C_down_fac * $C_up] [expr $e2eDelay]ms DropTail
	
	# do the routing manually between peer and router
	[$peer($no_of_peers) get-module "Manual"] add-route-to-adj-node -default [$router id]
	[$router get-module "Manual"] add-route-to-adj-node -default [$peer($no_of_peers) id]
	
	[$router get-module "Manual"] add-route [$peer($no_of_peers) id] [[$ns link $router $peer($no_of_peers)] head]
	
	[$peer($no_of_peers) get-module "Manual"] add-route [$router id] [[$ns link  $peer($no_of_peers) $router] head]
	
	
	return 0
}



proc done {} {
	global app FinishedPeers N_P fh ns
	
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

# create tracker
# Parameters: File Size [B], Chunk Size [B]
set go [new BitTorrentTracker $S_F $S_C]
$go tracefile $p2ptrace	
	

# uniform start offset for peers
set t_offset_rng [new RNG]
set t_offset [new RandomVariable/Uniform]
$t_offset set min_ 0
$t_offset set max_ [BitTorrentApp set choking_interval]
$t_offset use-rng $t_offset_rng	


set router [$ns node]

# Create Seeds
for {set i 0} {$i < $N_P} {incr i} {
	
	# make nodes
	set peer($i) [$ns node]
	
	# make links
	fully_meshed2 $i
	
	if {$i < $N_S} {
		set app($peerCount) [new BitTorrentApp 1 $C_up $go $peer($i)]
		
		$app($peerCount) set super_seeding 1
		$app($peerCount) tracefile $p2ptrace
		
		# start apps
		$ns at 0.0 "$app($peerCount) start"

		incr FinishedPeers		
	} else {
		set app($peerCount) [new BitTorrentApp 0 $C_up $go $peer($i)]
		
		$app($peerCount) tracefile $p2ptrace
	
		# start apps
		$ns at [$t_offset value] "$app($peerCount) start"
	}
	
	
	incr peerCount
}

# Run the simulation
$ns run