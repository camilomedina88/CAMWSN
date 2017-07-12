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

Agent/DCA set degree								true
Agent/SHIVA set max-length							4

Agent/SHIVA set timeout-destruction                 2.0
if { [string compare [lindex $argv 1] ""] != 0 } {
	Agent/SHIVA set timeout-destruction                 [lindex $argv 1]
}

	Agent/DCA set max-delay					0.125

        Agent/DCA set jitter-timeout-hello                 0.1
	Agent/DCA set jitter-timeout-ch			0.1
	Agent/DCA set jitter-timeout-join		0.1
	Agent/DCA set jitter-timeout-signal		0.1

        Agent/DCA set timeout-hello                                0.4
	Agent/DCA set timeout-ch				0.4
	Agent/DCA set timeout-join				0.4
	Agent/DCA set timeout-signal			0.4

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
	declareModule {Agent/DCA} {Utility/CLUSTERING} {DCA(D)} {DCA}
	declareModule {Agent/MYCONNECTOR} {Utility/CONNECTOR} {CONNECTOR} {CONNECTOR}
	declareModule {Agent/SHIVA} {Utility/SHIVA} {SHIVA(4)} {SHIVA}
start-simulation

