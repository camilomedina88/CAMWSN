#============================
# Load Library.
#============================
source "template/config/lib.tcl"

#============================
# Load Algorithms's Defaults.
#============================
source "template/defaults/sensors.default"
source "template/defaults/RAJARAMAN.default"
source "template/defaults/CONNECTOR.default"
source "template/defaults/SHIVA.default"

Agent/SHIVA set max-length							4

Agent/SHIVA set timeout-destruction                 1.5
if { [string compare [lindex $argv 1] ""] != 0 } {
	Agent/SHIVA set timeout-destruction                 [lindex $argv 1]
}

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
	declareModule {Agent/RAJARAMAN} {Utility/RAJARAMAN} {RAJARAMAN} {RAJARAMAN}
	declareModule {Agent/MYCONNECTOR} {Utility/CONNECTOR} {CONNECTOR} {CONNECTOR}
	declareModule {Agent/SHIVA} {Utility/SHIVA} {SHIVA(4)} {SHIVA}
start-simulation

