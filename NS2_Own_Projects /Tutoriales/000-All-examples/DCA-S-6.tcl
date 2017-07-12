#============================
# Load Library.
#============================
source "template/config/lib.tcl"

#============================
# Load Algorithms's Defaults.
#============================
source "template/defaults/sensors.default"
source "template/defaults/DCA.default"
source "template/defaults/CONNECTOR.default"
source "template/defaults/SHIVA.default"

Agent/DCA set degree								false
Agent/SHIVA set max-length							6



Agent/SHIVA set debug true



Agent/SHIVA set timeout-destruction					5.0
if { [string compare [lindex $argv 1] ""] != 0 } {
	Agent/SHIVA set timeout-destruction                 [lindex $argv 1]
}

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
	declareModule {Agent/DCA} {Utility/CLUSTERING} {DCA} {DCA}
	declareModule {Agent/MYCONNECTOR} {Utility/CONNECTOR} {CONNECTOR} {CONNECTOR}
	declareModule {Agent/SHIVA} {Utility/SHIVA} {SHIVA(6)} {SHIVA}
start-simulation

