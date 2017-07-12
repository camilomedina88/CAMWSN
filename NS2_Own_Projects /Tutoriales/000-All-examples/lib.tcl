#----------------------------------------------
# Dichiara un modulo e ottiene un riferimento.
#----------------------------------------------
proc declareModule { agent utility algorithm header } {

	global module moduleCount
	
	set module($moduleCount.agent) $agent
	set module($moduleCount.header) $header
	set module($moduleCount.utility) $utility
	set module($moduleCount.algorithm) $algorithm
	
	add-packet-header $module($moduleCount.header)
	
	incr moduleCount
}

proc begin-simulation { path } {

	global moduleCount fileComponents fileTopologia nodiTopologia pathCompleto
	
	set pathCompleto $path
	
	set moduleCount 0

	remove-all-packet-headers
	add-packet-header IP LL Mac Common

	set fileComponents [split $pathCompleto /]

	set fileTopologia [lindex $fileComponents [expr [llength $fileComponents] - 1]]

	if {[regexp {^coordS(.*)N(.*)$} $fileTopologia match indiceTopologia nodiTopologia] != 1} {
		puts "Il formato del file di topologia deve essere:"
		puts "coordS{IndiceDiTopologia}N{NumeroNodi}"
		exit 0
	}
}

# ==================================================================
# Crea un nodo
# ==================================================================
proc enable-clustering { node simulator stack-utility } {

	global moduleCount module utility separator 
	
	# Ottiene il link layer.
	set ll [$node set ll_(0)]
	
	for {set i 0} {$i < $moduleCount } {incr i} {
	
		set _module_($i) [new $module($i.agent)]
		$simulator attach-agent $node $_module_($i)
		$_module_($i) addr [$node id]
		$_module_($i) node $node
		$_module_($i) utility $utility($i)
		
		if {$i == 0} {
			$_module_($i) lower
		}

		$utility($i) set-algorithm-name $module($i.algorithm)
				
		# Registra i moduli nei joiner.
		$separator register [$node id] $_module_($i)
	}
	
	$ll up-target $_module_(0)
	$_module_(0) target $ll
	
	for {set i 0} {$i < [expr $moduleCount - 1]} {incr i} {
		$_module_($i) up-target $_module_([expr $i + 1])
	}

	for {set i 1} {$i < [expr $moduleCount]} {incr i} {
		$_module_($i) target $_module_([expr $i - 1])
	}

	# Imposta l'utility per monitorare i bytes trasmessi a livello Mac
	set mac [$ll mac]
	$mac utility ${stack-utility}

	# Lancia l'esecuzione del modulo piu'in basso.
}

proc start-simulation {} {

	global opt module pathCompleto fileTopologia nodiTopologia moduleCount utility separator

	# ==================================================================
	# Stampa la topologia di cui effettua la simulazione.
	# ==================================================================

	puts -nonewline stdout "$fileTopologia "
	flush stdout

	set separator [new Utility/SEPARATOR]
	set stack-utility [new Utility/STACK]
	
	${stack-utility} set-separator $separator
	${stack-utility} set-topology-name $fileTopologia

	# ==================================================================
	# Create simulator
	# =================================================================
	set ns_		[new Simulator]

	# ==================================================================
	# Create Topology
	# =================================================================
	set topo	[new Topography]

	# ==================================================================
	# Set default configuration for a sensor node.
	# =================================================================
	$ns_ node-config -adhocRouting $opt(_adhocRouting) \
			-llType        $opt(_ll) \
			-macType       $opt(_mac) \
			-ifqType       $opt(_ifq) \
			-ifqLen        $opt(_ifqlen) \
			-antType       $opt(_antenna) \
			-propType      $opt(_propagation) \
			-phyType       $opt(_netif) \
			-topoInstance  $topo \
			-agentTrace    OFF \
			-routerTrace   OFF \
			-macTrace      OFF  \
			-energyModel   $opt(_energy-model) \
			-rxPower       $opt(_rx-power) \
			-txPower       $opt(_tx-power) \
			-idlePower     $opt(_idle-power) \
			-initialEnergy $opt(_initial-energy) \
			-channel       [new $opt(_channel)]

	# =======================================================================
	# Disable default tracing (redirect to /dev/null).
	# =======================================================================
	set tracefd	[open $opt(_tr) w]
	$ns_ use-newtrace
	$ns_ trace-all $tracefd
	#set nf [open $opt(_nam) w]
	#$ns_ namtrace-all-wireless $nf $opt(_x) $opt(_y)

	# =======================================================================
	# Load Grid
	# =======================================================================
	$topo load_flatgrid $opt(_x) $opt(_y)

	# =======================================================================
	# Create GOD
	# =======================================================================
	set god_ [create-god $nodiTopologia]

	for {set i 0} {$i < $moduleCount } {incr i} {
		set utility($i) [new $module($i.utility)]
		${stack-utility} set-module $i $utility($i)
	}

	# =======================================================================
	# Set nodes.
	# =======================================================================
	for {set i 0} {$i < $nodiTopologia } {incr i} {
		#
		# Create node
		#
		set node_($i) [$ns_ node $i]

		#
		# Disable random motion.
		#
		$node_($i) random-motion 0		;# disable random motion
	
		#
		# Add note to god.
		#
		$god_ new_node $node_($i)

		#
		# Add clustering agent to node's network stack.
		#
		enable-clustering $node_($i) $ns_ ${stack-utility}
    
	}

	# =======================================================================
	# Load nodes distributions.
	# =======================================================================
	source $pathCompleto

	# =======================================================================
	# Set grid.
	# =======================================================================
	set gkeeper     [new GridKeeper]
	$gkeeper dimension $opt(_x) $opt(_y)
	for {set i 0} {$i < $nodiTopologia } {incr i} {
		$gkeeper addnode $node_($i)
		$node_($i) radius $opt(_radius)
	}

	# =======================================================================
	# Lancia l'esecuzione del modulo piu'in basso.
	# =======================================================================
	$ns_ at 0.0 "$separator start"

	# =======================================================================
	# Set end-time simulation
	# =======================================================================
	$ns_ at  $opt(_stop).000000001 "$ns_ halt"

	# =======================================================================
	# Set dump-time simulation
	# =======================================================================
	$ns_ at $opt(_dump_time) "${stack-utility} dump"

	# =======================================================================
	# Start simulation
	# =======================================================================
	$ns_ run
}
