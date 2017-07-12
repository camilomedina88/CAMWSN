#       #  http://code.dma.unipi.it/projects/ns-modules/browser/trunk/ns-2.29/tcl/mobility/dsr.tcl
#       #  trunk/ns-2.29/tcl/mobility/dsr.tcl 

 
 
1	#
2	# Copyright (c) 1996-1998 Regents of the University of California.
3	# All rights reserved.
4	#
5	# Redistribution and use in source and binary forms, with or without
6	# modification, are permitted provided that the following conditions
7	# are met:
8	# 1. Redistributions of source code must retain the above copyright
9	#    notice, this list of conditions and the following disclaimer.
10	# 2. Redistributions in binary form must reproduce the above copyright
11	#    notice, this list of conditions and the following disclaimer in the
12	#    documentation and/or other materials provided with the distribution.
13	# 3. All advertising materials mentioning features or use of this software
14	#    must display the following acknowledgement:
15	#       This product includes software developed by the MASH Research
16	#       Group at the University of California Berkeley.
17	# 4. Neither the name of the University nor of the Research Group may be
18	#    used to endorse or promote products derived from this software without
19	#    specific prior written permission.
20	#
21	# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
22	# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
23	# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
24	# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
25	# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
26	# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
27	# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
28	# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
29	# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
30	# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
31	# SUCH DAMAGE.
32	#
33	# Ported from CMU-Monarch project's mobility extensions -Padma, 10/98.
34	# dsr.tcl
35	# $Id: dsr.tcl,v 1.16 2003/12/23 17:36:35 haldar Exp $
36	
37	# ======================================================================
38	# Default Script Options
39	# ======================================================================
40	
41	set opt(rt_port) 255
42	set opt(cc)      "off"            ;# have god check the caches for bad links?
43	
44	# ======================================================================
45	# god cache monitoring
46	
47	#source tcl/ex/timer.tcl
48	Class CacheTimer -superclass Timer
49	CacheTimer instproc timeout {} {
50	    global opt node_;
51	    $self instvar agent;
52	    $agent check-cache
53	    $self sched 1.0
54	}
55	
56	proc checkcache {a} {
57	    global cachetimer ns
58	
59	    set cachetimer [new CacheTimer]
60	    $cachetimer set agent $a
61	    $cachetimer sched 1.0
62	}
63	
64	# ======================================================================
65	Class SRNode -superclass Node/MobileNode
66	
67	SRNode instproc init {args} {
68	        global ns ns_ opt tracefd RouterTrace
69	        $self instvar dsr_agent_ dmux_ entry_point_ address_
70	        set ns_ [Simulator instance]
71	
72	        eval $self next $args   ;# parent class constructor
73	        if {$dmux_ == "" } {
74	                set dmux_ [new Classifier/Port]
75	                $dmux_ set mask_ [AddrParams PortMask]
76	                $dmux_ set shift_ [AddrParams PortShift]
77	                #
78	                # point the node's routing entry to itself
79	                # at the port demuxer (if there is one)
80	                #
81	        }
82	        # puts "making dsragent for node [$self id]"
83	        set dsr_agent_ [new Agent/DSRAgent]
84	        # setup address (supports hier-address) for dsragent
85	
86	        $dsr_agent_ addr $address_
87	        $dsr_agent_ node $self
88	        if [Simulator set mobile_ip_] {
89	            $dsr_agent_ port-dmux [$self set dmux_]
90	        }
91	        # set up IP address
92	        $self addr $address_
93	       
94	    if { $RouterTrace == "ON" } {
95	        # Recv Target
96	        set rcvT [cmu-trace Recv "RTR" $self]
97	        $rcvT target $dsr_agent_
98	        set entry_point_ $rcvT 
99	    } else {
100	        # Recv Target
101	        set entry_point_ $dsr_agent_
102	    }
103	
104	    #
105	    # Drop Target (always on regardless of other tracing)
106	    #
107	    set drpT [cmu-trace Drop "RTR" $self]
108	    $dsr_agent_ drop-target $drpT
109	
110	    #
111	    # Log Target
112	    #
113	
114	    set T [new Trace/Generic]
115	    $T target [$ns_ set nullAgent_]
116	    $T attach $tracefd
117	    $T set src_ [$self id]
118	    $dsr_agent_ log-target $T
119	
120	    $dsr_agent_ target $dmux_
121	
122	    # packets to the DSR port should be dropped, since we've
123	    # already handled them in the DSRAgent at the entry.
124	    set nullAgent_ [$ns_ set nullAgent_]
125	    $dmux_ install $opt(rt_port) $nullAgent_
126	
127	    # SRNodes don't use the IP addr classifier.  The DSRAgent should
128	    # be the entry point
129	    $self instvar classifier_
130	    set classifier_ "srnode made illegal use of classifier_"
131	
132	}
133	
134	SRNode instproc start-dsr {} {
135	    $self instvar dsr_agent_
136	    global opt;
137	
138	    $dsr_agent_ startdsr
139	    if {$opt(cc) == "on"} {checkcache $dsr_agent_}
140	}
141	
142	SRNode instproc entry {} {
143	        $self instvar entry_point_
144	        return $entry_point_
145	}
146	
147	
148	
149	SRNode instproc add-interface {args} {
150	# args are expected to be of the form
151	# $chan $prop $tracefd $opt(ll) $opt(mac)
152	    global ns ns_ opt RouterTrace
153	
154	    eval $self next $args
155	
156	    $self instvar dsr_agent_ ll_ mac_ ifq_
157	
158	    $dsr_agent_ mac-addr [$mac_(0) id]
159	
160	    if { $RouterTrace == "ON" } {
161	        # Send Target
162	        set sndT [cmu-trace Send "RTR" $self]
163	        $sndT target $ll_(0)
164	        $dsr_agent_ add-ll $sndT $ifq_(0)
165	    } else {
166	        # Send Target
167	        $dsr_agent_ add-ll $ll_(0) $ifq_(0)
168	    }
169	   
170	    # setup promiscuous tap into mac layer
171	    $dsr_agent_ install-tap $mac_(0)
172	
173	}
174	
175	SRNode instproc reset args {
176	    $self instvar dsr_agent_
177	    eval $self next $args
178	
179	    $dsr_agent_ reset
180	}
181	
182	# ======================================================================
183	
184	proc dsr-create-mobile-node { id args } {
185	        global ns_ chan prop topo tracefd opt node_
186	        set ns_ [Simulator instance] 
187	        if [Simulator hier-addr?] {
188	            if [Simulator set mobile_ip_] {
189	                set node_($id) [new SRNode/MIPMH $args]
190	            } else {
191	                set node_($id) [new SRNode $args]
192	            }
193	        } else {
194	            set node_($id) [new SRNode]
195	        }
196	        set node $node_($id)
197	        $node random-motion 0           ;# disable random motion
198	        $node topography $topo
199	
200	        # XXX Activate energy model so that we can use sleep, etc. But put on
201	        # a very large initial energy so it'll never run out of it.
202	        if [info exists opt(energy)] {
203	                $node addenergymodel [new $opt(energy) $node 1000 0.5 0.2]
204	        }
205	
206	        if ![info exist inerrProc_] {
207	            set inerrProc_ ""
208	        }
209	        if ![info exist outerrProc_] {
210	            set outerrProc_ ""
211	        }
212	        if ![info exist FECProc_] {
213	            set FECProc_ ""
214	        }
215	
216	        # connect up the channel
217	        $node add-interface $chan $prop $opt(ll) $opt(mac)     \
218	            $opt(ifq) $opt(ifqlen) $opt(netif) $opt(ant) $topo \
219	            $inerrProc_ $outerrProc_ $FECProc_ 
220	
221	        #
222	        # This Trace Target is used to log changes in direction
223	        # and velocity for the mobile node and log actions of the DSR agent
224	        #
225	        set T [new Trace/Generic]
226	        $T target [$ns_ set nullAgent_]
227	        $T attach $tracefd
228	        $T set src_ $id
229	        $node log-target $T
230	
231	        $ns_ at 0.0 "$node start-dsr"
232	        return $node