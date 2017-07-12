#    Copyright (c) University of Maryland, Baltimore County, 2003.
#    Original Authors: Ramakrishna Shenai, Sunil Gowda and Krishna Sivalingam.
  
#    This software is developed at the University of Maryland, Baltimore County under
#    grants from Cisco Systems Inc and the University of Maryland, Baltimore County.
  
#    Permission to use, copy, modify, and distribute this software and its
#    documentation in source and binary forms for non-commercial purposes
#    and without fee is hereby granted, provided that the above copyright
#    notice appear in all copies and that both the copyright notice and
#    this permission notice appear in supporting documentation. and that
#    any documentation, advertising materials, and other materials related
#    to such distribution and use acknowledge that the software was
#    developed by the University of Maryland, Baltimore County.  The name of
#    the University may not be used to endorse or promote products derived from
#    this software without specific prior written permission.
  
#    Copyright (C) 2000-2003 Washington State University. All rights reserved.
#    This software was originally developed at Alcatel USA and subsequently modified
#    at Washington State University, Pullman, WA  through research work which was
#    supported by Alcatel USA, Inc and Cisco Systems Inc.

#    The  following notice is in adherence to the Washington State University
#    copyright policy follows.
  
#    License is granted to copy, to use, and to make and to use derivative
#    works for research and evaluation purposes, provided that Washington
#    State University is acknowledged in all documentation pertaining to any such
#    copy or derivative work. Washington State University grants no other
#    licenses expressed or implied. The Washington State University name
#    should not be used in any advertising without its written permission.
  
#    WASHINGTON STATE UNIVERSITY MAKES NO REPRESENTATIONS CONCERNING EITHER
#    THE MERCHANTABILITY OF THIS SOFTWARE OR THE SUITABILITY OF THIS SOFTWARE
#    FOR ANY PARTICULAR PURPOSE.  The software is provided "as is"
#     without express or implied warranty of any kind. These notices must
#    be retained in any copies of any part of this software.
  


# Burst Manager defaults
# BurstManager set burstTimeout_ 0.1
# BurstManager set offsetTime_ 0.000010
# BurstManager set delta_ 0.00001
# BurstManager set maxBurstSize_ 10000
# BurstManager set pcntguard_ 0
# BurstManager set debug_ 0

# classifier defaults
# Classifier/EdgeClassifier set address_ -1
Classifier/BaseClassifier set address_ -1 
Classifier/BaseClassifier set proc_time 0.000001
Classifier/OBSPort set address_ -1

#GMG -- added initialization for bhpProcTime in edge and core
#       classifiers, and for FDLdelay in OBSFiberDelayLink

Classifier/BaseClassifier/CoreClassifier set bhpProcTime 0.000002
Classifier/BaseClassifier/EdgeClassifier set bhpProcTime 0.000002
OBSFiberDelayLink set FDLdelay 0.000001

# I need this for testing the routing funda of Agent
Agent/IPKT set packetSize_ 64
Agent/IPKT set address_ -1

NodeTrace set trace_on 0

#Defaults for fdl scheduling (note that option_ and max_fdls_ are
#   also initialized to zero in fdl-scheduler.cc (in C++);
#   we initialize here as well to avoid OTcl warning messages
Classifier/BaseClassifier set fdldelay 0.000001
Classifier/BaseClassifier set nfdl 1
Classifier/BaseClassifier set option 0
Classifier/BaseClassifier set maxfdls 0

#Default option for electronic buffering at edge node
Classifier/BaseClassifier set ebufoption 0

#Defaults for Self Similar Traffic Model

RandomVariable/Gamma set avg 1.0
RandomVariable/Gamma set stdev 1.0
RandomVariable/NegBinom set avg 1.0
RandomVariable/NegBinom set sparm 0
Application/Traffic/SelfSimilar set rate 1.0
Application/Traffic/SelfSimilar set std_dev_inter_batch_time 1.0
Application/Traffic/SelfSimilar set batchsize 1.0
Application/Traffic/SelfSimilar set sb 0
Application/Traffic/SelfSimilar set Ht 0.5
Application/Traffic/SelfSimilar set Hb -0.5
Application/Traffic/SelfSimilar set starttime 0.0
Application/Traffic/SelfSimilar set stoptime 1.0
