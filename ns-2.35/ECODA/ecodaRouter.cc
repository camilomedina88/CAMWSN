/* 
###################################################
#        	Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#		medina.camilo@javeriana.edu.co            #
###################################################
 *
 */

#include <ECODA/ecodaRouter.h>
#include <ECODA/ecoda_packet.h>
#include <random.h>
#include <cmu-trace.h>
#include <energy-model.h>

#define max(a,b)        ( (a) > (b) ? (a) : (b) )
#define CURRENT_TIME    Scheduler::instance().clock()

//#define DEBUG

// ======================================================================
//  TCL Hooking Classes
// ======================================================================

int hdr_ecoda::offset_;
static class ECODAHeaderClass : public PacketHeaderClass {
 public:
	ECODAHeaderClass() : PacketHeaderClass("PacketHeader/ECODA", sizeof(hdr_all_ecoda)) {
	  bind_offset(&hdr_ecoda::offset_);
	} 
} class_rtProtoecoda_hdr;

static class ECODAclass : public TclClass {
 public:
	ECODAclass() : TclClass("Agent/ECODA") {}
	TclObject* create(int argc, const char*const* argv) {
		assert(argc == 5);
		return (new ECODA((nsaddr_t) Address::instance().str2addr(argv[4])));
	}
} class_rtProtoecoda;


int
ECODA::command(int argc, const char*const* argv) {
	if(argc == 2) {

	Tcl& tcl = Tcl::instance();
    
		if(strncasecmp(argv[1], "id", 2) == 0) {
			tcl.resultf("%d", index);
			return TCL_OK;
		}
 
		if(strncasecmp(argv[1], "start", 5) == 0) {
			rtcTimer.handle((Event*) 0);
			return TCL_OK;
		}

		// Start Beacon Timer (which sends beacon message)
		if(strncasecmp(argv[1], "sink", 4) == 0) {
			bcnTimer.handle((Event*) 0);
#ifdef DEBUG
		printf("N (%.6f): sink node is set to %d, start beaconing  \n", CURRENT_TIME, index);
#endif 
		
			return TCL_OK;
		}
	}
	else if(argc == 3) {
		
		if(strcmp(argv[1], "index") == 0) {
			
			index = atoi(argv[2]);
			return TCL_OK;
		}

		else if(strcmp(argv[1], "log-target") == 0 || strcmp(argv[1], "tracetarget") == 0) {
			logtarget = (Trace*) TclObject::lookup(argv[2]);
			if(logtarget == 0)
				return TCL_ERROR;
      			return TCL_OK;
		}
		
		else if(strcmp(argv[1], "drop-target") == 0) {
			/* int stat = rqueue.command(argc,argv);
			if (stat != TCL_OK)
				return stat;
			return Agent::command(argc, argv);*/
			return TCL_OK;
		}

		else if(strcmp(argv[1], "if-queue") == 0) {
			ifqueue = (PriQueue*) TclObject::lookup(argv[2]);
      
			if(ifqueue == 0){
			
				return TCL_ERROR;
			}

			return TCL_OK;
		}

		else if (strcmp(argv[1], "port-dmux") == 0) {
			dmux_ = (PortClassifier *)TclObject::lookup(argv[2]);
			if (dmux_ == 0) {
				fprintf (stderr, "%s: %s lookup of %s failed\n", __FILE__,
				argv[1], argv[2]);
				return TCL_ERROR;
			}
			return TCL_OK;
		}
	}
	
	return Agent::command(argc, argv);
}

// ======================================================================
//  Agent Constructor
// ======================================================================

ECODA::ECODA(nsaddr_t id) : Agent(PT_ECODA), bcnTimer(this), rtcTimer(this) {
             

#ifdef DEBUG
	printf("N (%.6f): Routing agent is initialized for node %d \n", CURRENT_TIME, id);
#endif 
	index = id;
	seqno = 1;

	LIST_INIT(&rthead);
	posx = 0;
	posy = 0;

	logtarget = 0;
	ifqueue = 0;
	tasaEnvio=250000;
	primerBeacon=true;

}

// ======================================================================
//  Timer Functions
// ======================================================================

void
ecodaRouteCacheTimer::handle(Event*) {
	agent->rt_purge();
	Scheduler::instance().schedule(this, &intr, ROUTE_PURGE_FREQUENCY);
}

void
ecodaBeaconTimer::handle(Event*) {

	agent->send_beacon();
	Scheduler::instance().schedule(this, &intr, DEFAULT_BEACON_INTERVAL);

}


// ======================================================================
//  Send Beacon Routine
// ======================================================================
void
ECODA::send_beacon() {

	Packet *p = Packet::alloc();
	struct hdr_cmn *ch = HDR_CMN(p);
	struct hdr_ip *ih = HDR_IP(p);
	struct hdr_ecoda_beacon *bcn = HDR_ECODA_BEACON(p);

	// Write Channel Header
	ch->ptype() = PT_ECODA;
	ch->size() = IP_HDR_LEN + bcn->size();
	ch->addr_type() = NS_AF_NONE;
	ch->prev_hop_ = index;

	// Write IP Header
	ih->saddr() = index;
	ih->daddr() = IP_BROADCAST;
	ih->sport() = RT_PORT;
	ih->dport() = RT_PORT;
	ih->ttl_ = NETWORK_DIAMETER;

	// Write Beacon Header
	bcn->pkt_type = ECODA_BEACON;
	bcn->beacon_hops = 1;
	bcn->beacon_id = seqno;
	bcn->beacon_src = index;
	
	// update the node position before putting it in the packet
	update_position();

	bcn->beacon_posx = posx;
	bcn->beacon_posy = posy;

	bcn->timestamp = CURRENT_TIME;

	// increase sequence number for next beacon
	seqno += 1;

#ifdef DEBUG
	printf("S (%.6f): send beacon by %d  \n", CURRENT_TIME, index);
#endif 
	Scheduler::instance().schedule(target_, p, 0.0);


}

// ======================================================================
//  Send Error Routine
// ======================================================================
void 
ECODA::send_error(nsaddr_t unreachable_destination) {
	// TODO : code should be update;
}



// ======================================================================
//  Forward Routine
// ======================================================================

void 
ECODA::forward(Packet *p, nsaddr_t nexthop, double delay) {



	delay = delay + (Random::uniform()/10);
	//printf("El Delay es: %1f\n", delay);
	struct hdr_cmn *ch = HDR_CMN(p);
	struct hdr_ip *ih = HDR_IP(p);
	//printf("Saco las esctructuras \n");

	if (ih->ttl_ == 0) {

		//printf("Drop por TTL \n");
		drop(p, DROP_RTR_TTL);
	}
	
	if (nexthop != (nsaddr_t) IP_BROADCAST) {
		//printf("Siguiente Salto Broadcast \n");
		ch->next_hop_ = nexthop;
		ch->prev_hop_ = index;
		ch->addr_type() = NS_AF_INET;
		ch->direction() = hdr_cmn::DOWN;
	}
	else {
		assert(ih->daddr() == (nsaddr_t) IP_BROADCAST);
		//printf("Paquete enrutado a otro destino \n");
		ch->prev_hop_ = index;
		ch->addr_type() = NS_AF_NONE;
		ch->direction() = hdr_cmn::DOWN; 
	}
	
	Scheduler::instance().schedule(target_, p, delay);
	
	

}


// ======================================================================
//  Recv Packet
// ======================================================================

void
ECODA::recv(Packet *p, Handler*) {

	
struct hdr_cmn *ch = HDR_CMN(p);
struct hdr_ip *ih = HDR_IP(p);


	// if the packet is routing protocol control packet, give the packet to agent
	if(ch->ptype() == PT_ECODA) {
		ih->ttl_ -= 1;
		recv_ecoda(p);
		return;
	}

	//  Must be a packet I'm originating
	if((ih->saddr() == index) && (ch->num_forwards() == 0)) {
 	
		// Add the IP Header. TCP adds the IP header too, so to avoid setting it twice, 
		// we check if  this packet is not a TCP or ACK segment.

		if (ch->ptype() != PT_TCP && ch->ptype() != PT_ACK) {
			ch->size() += IP_HDR_LEN;
		}

	}

	// I received a packet that I sent.  Probably routing loop.
	else if(ih->saddr() == index) {
   		drop(p, DROP_RTR_ROUTE_LOOP);
		return;
	}

	//  Packet I'm forwarding...
	else {
		if(--ih->ttl_ == 0) {
			drop(p, DROP_RTR_TTL);
			return;
   		}
	}

	// This is data packet, find route and forward packet
	recv_data(p);
}


// ======================================================================
//  Recv Data Packet
// ======================================================================

void 
ECODA::recv_data(Packet *p) {
	struct hdr_ip *ih = HDR_IP(p);
	RouteCache *rt;
	
	// if route fails at link layer, (link layer could not find next hop node) it will cal rt_failed_callback function
	//ch->xmit_failure_ = rt_failed_callback;
	//ch->xmit_failure_data_ = (void*) this;

#ifdef DEBUG
	//printf("R (%.6f): recv data by %d  \n", CURRENT_TIME, index);
#endif 

	rt = rt_lookup(ih->daddr());

	// There is no route for the destination
	if (rt == NULL) {
	// TODO: queue the packet and wait for the route construction
		return ;
	}

	// if the route is not failed forward it;
	else if (rt->rt_state != ROUTE_FAILED) {
		//printf("Tasa Envio %f\n", tasaEnvio);

		double retardoAIMD=1/tasaEnvio;
		//printf("Retardo AIMD %f\n",retardoAIMD);

		forward(p, rt->rt_nexthop, retardoAIMD);
	}
	
	// if the route has failed, wait to be updated;
	else {
		//TODO: queue the packet and wait for the route construction;
		return;
	}

}

// ======================================================================
//  Recv ecoda Packet
// ======================================================================
void
ECODA::recv_ecoda(Packet *p) {
	struct hdr_ecoda *wh = HDR_ECODA(p);

	assert(HDR_IP (p)->sport() == RT_PORT);
	assert(HDR_IP (p)->dport() == RT_PORT);



	// What kind of packet is this
	switch(wh->pkt_type) {

		case ECODA_BEACON:
			recv_beacon(p);
			break;

		case ECODA_ERROR:
			recv_error(p);
			break;

		default:
			fprintf(stderr, "Invalid packet type (%x)\n", wh->pkt_type);
			exit(1);
	}
}


// ======================================================================
//  Recv Beacon Packet
// ======================================================================
void 
ECODA::recv_beacon(Packet *p) {


	struct hdr_ip *ih = HDR_IP(p);
	struct hdr_ecoda_beacon *bcn = HDR_ECODA_BEACON(p);


	double retardoActual=CURRENT_TIME-bcn->timestamp;


	if(primerBeacon){
		retardoPrev=100;
		tasaEnvio=1/retardoActual;
		primerBeacon=FALSE;
	}else{
		//Implementacion AIMD
		if(retardoActual < 1.1*retardoPrev){
			//Sumar Sending Rate
			//printf("++Se aummento el sending Rate\n");
			//printf("\n \n +++++++++++++++++++++  Se Aumento el sending Rate\n");
			tasaEnvio=tasaEnvio+0.5;			
		} else {
			//Dividir el sending rate
			//printf("\n \n -------Se Disminuyo el sending Rate\n");
			tasaEnvio=tasaEnvio/2;
		}
		retardoPrev=retardoActual;
	}


		


	//printf("Retardo del Beacon %f\n", retardoActual);

	
	// I have originated the packet, just drop it
	if (bcn->beacon_src == index)  {
		Packet::free(p);
		return;
	}

#ifdef DEBUG
	printf("R (%.6f): recv beacon by %d, src:%d, seqno:%d, hop: %d \n", 
		CURRENT_TIME, index, bcn->beacon_src, bcn->beacon_id, bcn->beacon_hops);
#endif 
	
	// search for a route 
	RouteCache	*rt = rt_lookup(bcn->beacon_src);
	
	// if there is no route toward this destination, insert the route and forward
 	if (rt == NULL)  {
		rt_insert(bcn->beacon_src,bcn->beacon_id, ih->saddr(), bcn->beacon_posx, bcn->beacon_posy, bcn->beacon_hops,retardoActual);

		ih->saddr() = index;		
		bcn->beacon_hops +=1; // increase hop count
		tasaEnvio=1/retardoActual;

		double delay = 0.1 + Random::uniform();

#ifdef DEBUG
	printf("F (%.6f): NEW ROUTE, forward beacon by %d \n", CURRENT_TIME, index);
#endif 

		forward(p, IP_BROADCAST, delay);
	}
	// if the route is newer than I have (i.e. new beacon is received): update the route and forward
	else if (bcn->beacon_id > rt->rt_seqno) {
	
		rt->rt_seqno = bcn->beacon_id;
		rt->rt_nexthop = ih->saddr();
		rt->rt_xpos = bcn->beacon_posx;
		rt->rt_ypos = bcn->beacon_posy;
		rt->rt_state = ROUTE_FRESH;
		rt->rt_hopcount = bcn->beacon_hops;
		rt->rt_expire = CURRENT_TIME + DEFAULT_ROUTE_EXPIRE;
		rt->retardo=retardoActual;		
		ih->saddr() = index;
		bcn->beacon_hops +=1; // increase hop count
		double delay = 0.1 + Random::uniform();
		#ifdef DEBUG
		printf("F (%.6f): UPDATE ROUTE, forward beacon by %d \n", CURRENT_TIME, index);
		#endif 
		forward(p, IP_BROADCAST, delay);
	}
	// if the route is shorter than I have, update it
	//else if ((bcn->beacon_id == rt->rt_seqno) && (bcn->beacon_hops < rt->rt_hopcount )) {
	else if ((bcn->beacon_id == rt->rt_seqno) && (retardoActual < rt->retardo )) {
		rt->rt_seqno = bcn->beacon_id;
		rt->rt_nexthop = ih->saddr();
		rt->rt_xpos = bcn->beacon_posx;
		rt->rt_ypos = bcn->beacon_posy;
		rt->rt_state = ROUTE_FRESH;
		rt->rt_hopcount = bcn->beacon_hops;
		rt->rt_expire = CURRENT_TIME + DEFAULT_ROUTE_EXPIRE;
		rt->retardo=retardoActual;
		
	}

	// TODO : initiate dequeue() routine to send queued packets;

}


// ======================================================================
//  Recv Error Packet
// ======================================================================

void
ECODA::recv_error(Packet *p) {
	// TODO: code should be update;
}


// ======================================================================
//  Routing Management
// ======================================================================

/* static void
ECODA::rt_failed_callback(Packet *p, void *arg) {

}*/

void
ECODA::rt_insert(nsaddr_t src, u_int32_t id, nsaddr_t nexthop, u_int32_t xpos, u_int32_t ypos, u_int8_t hopcount, double retardo) {
	RouteCache	*rt = new RouteCache(src, id);

	rt->rt_nexthop = nexthop;
	rt->rt_xpos = xpos;
	rt->rt_ypos = ypos;
	rt->rt_state = ROUTE_FRESH;
	rt->rt_hopcount = hopcount;
	rt->rt_expire = CURRENT_TIME + DEFAULT_ROUTE_EXPIRE;
	rt->retardo=retardo;

	LIST_INSERT_HEAD(&rthead, rt, rt_link);
}



RouteCache*	
ECODA::rt_lookup(nsaddr_t dst) {
	RouteCache *r = rthead.lh_first;

  	for( ; r; r = r->rt_link.le_next) {
		if (r->rt_dst == dst)
			return r;
 	}
	
	return NULL;
}

void
ECODA::rt_purge() {
	RouteCache *rt= rthead.lh_first;
	double now = CURRENT_TIME;

	for(; rt; rt = rt->rt_link.le_next) {
		if(rt->rt_expire <= now)
			rt->rt_state = ROUTE_EXPIRED;
 	}
}

void
ECODA::rt_remove(RouteCache *rt) {
	LIST_REMOVE(rt,rt_link);
}


void 
ECODA::update_position() {
	//TODO: we have to update node position
}

