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
Agent/SHIVA set max-length							4

Agent/SHIVA set timeout-destruction                 2.0
if { [string compare [lindex $argv 1] ""] != 0 } {
	Agent/SHIVA set timeout-destruction                 [lindex $argv 1]
}

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
	declareModule {Agent/DCA} {Utility/CLUSTERING} {DCA} {DCA}
	declareModule {Agent/MYCONNECTOR} {Utility/CONNECTOR} {CONNECTOR} {CONNECTOR}
	declareModule {Agent/SHIVA} {Utility/SHIVA} {SHIVA(4)} {SHIVA}
start-simulation

