# Copyright(c)2001 David Harrison. 
# Licensed according to the terms of the GNU Public License.
#
# Copies some of the functionality of makeflowmon.
#
# author: David Harrison

# inherited from QueueMonitor/ED/Flowmon
QueueMonitor/ED/RPIFlowmon set enable_in_ true
QueueMonitor/ED/RPIFlowmon set enable_out_ true
QueueMonitor/ED/RPIFlowmon set enable_drop_ true
QueueMonitor/ED/RPIFlowmon set enable_edrop_ true

# inherited from QueueMonitor/ED/RPI (see $NS/rpi/rpi-queue-monitor.cc)
QueueMonitor/ED/RPIFlowmon set pmax_qlen_ 0
QueueMonitor/ED/RPIFlowmon set bmax_qlen_ 0
QueueMonitor/ED/RPIFlowmon set pmin_qlen_ 0
QueueMonitor/ED/RPIFlowmon set bmin_qlen_ 0
QueueMonitor/ED/RPIFlowmon set debug_ false
QueueMonitor/ED/RPIFlowmon set bmax_qlen_thresh_ -1
QueueMonitor/ED/RPIFlowmon set time_qlen_exceeded_thresh_ 0.0

# inherited from QueueMonitor/ED/RPI (see $NS/rpi/rpi-queue-monitor.cc)
QueueMonitor/ED/RPIFlow set pmax_qlen_ 0
QueueMonitor/ED/RPIFlow set bmax_qlen_ 0
QueueMonitor/ED/RPIFlow set pmin_qlen_ 0
QueueMonitor/ED/RPIFlow set bmin_qlen_ 0
QueueMonitor/ED/RPIFlow set debug_ false
QueueMonitor/ED/RPIFlow set bmax_qlen_thresh_ -1
QueueMonitor/ED/RPIFlow set time_qlen_exceeded_thresh_ 0.0

# defined in QueueMonitor/ED/RPIFlow  (see $NS/rpi/rpi-flowmon.cc)
QueueMonitor/ED/RPIFlow set src_ -1
QueueMonitor/ED/RPIFlow set dst_ -1
QueueMonitor/ED/RPIFlow set flowid_ -1

# Create RPI flow monitor that classifies flows based on "cltype."
# cltype can be Fid, SrcDest, Dest, SrcDestFid or any other type
# for which there exists a Classifier/Hash subclass of the given name. 
Simulator instproc make-rpi-flowmon { cltype { clslots 29 } } {
	set flowmon [new QueueMonitor/ED/RPIFlowmon]
	set cl [new Classifier/Hash/$cltype $clslots]

	$cl proc unknown-flow { src dst fid hashbucket }  {
                set fdesc [new QueueMonitor/ED/RPIFlow]
                $fdesc set flowid_ $fid
                $fdesc set src_ $src
                $fdesc set dst_ $dst
                set dsamp [new Samples]

                # install monitors (this is not done by makeflowmon).
                $fdesc set-bytes-integrator [new Integrator]
                $fdesc set-pkts-integrator [new Integrator]

                $fdesc set-delay-samples $dsamp
                set slot [$self installNext $fdesc]
                $self set-hash $hashbucket $src $dst $fid $slot

        }

        $cl proc no-slot slotnum {
                #
                # note: we can wind up here when a packet passes
                # through either an Out or a Drop Snoop Queue for
                # a queue that the flow doesn't belong to anymore.
                # Since there is no longer hash state in the
                # hash classifier, we get a -1 return value for the
                # hash classifier's classify() function, and there
                # is no node at slot_[-1].  What to do about this?
                # Well, we are talking about flows that have already
                # been moved and so should rightly have their stats
                # zero'd anyhow, so for now just ignore this case..
                # puts "classifier $self, no-slot for slotnum $slotnum"
        }
        $flowmon classifier $cl
        return $flowmon
}

