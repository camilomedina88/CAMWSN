/*
###################################################
#         Congestion Control WSN               	  #
#     Camilo ALejandro Medina Mondragón           #
#   medina.camilo@javeriana.edu.co            	  #
###################################################

*/

#ifndef __daipas_h__
#define __daipas_h__

#include <cmu-trace.h>
#include <priqueue.h>
#include <classifier/classifier-port.h>
#include <mobilenode.h> 

#define NETWORK_DIAMETER		64
//#define DEFAULT_BEACON_INTERVAL		10 // seconds;
#define DEFAULT_BEACON_INTERVAL		10 // seconds;
#define DEFAULT_ROUTE_EXPIRE 		2*DEFAULT_BEACON_INTERVAL // seconds;
#define ROUTE_PURGE_FREQUENCY		2 // seconds



#define ROUTE_FRESH			0x01
#define ROUTE_EXPIRED		0x02
#define ROUTE_FAILED		0x03

class DAIPAS;

// ======================================================================
//  Timers : Beacon Timer, Route Cache Timer
// ======================================================================

class daipasBeaconTimer : public Handler {
public:
        daipasBeaconTimer(DAIPAS* a) : agent(a) {}
        void	handle(Event*);
private:
        DAIPAS    *agent;
	Event	intr;
};

class daipasRouteCacheTimer : public Handler {
public:
        daipasRouteCacheTimer(DAIPAS* a) : agent(a) {}
        void	handle(Event*);
private:
        DAIPAS    *agent;
	Event	intr;
};

// ======================================================================
//  Route Cache Table
// ======================================================================
class RouteCache {
	friend class DAIPAS;
 public:
	RouteCache(nsaddr_t bsrc) { rt_vecino = bsrc; }
 protected:
	LIST_ENTRY(RouteCache) rt_link;
	
	//nsaddr_t        rt_dst;		// route destination    
	//u_int32_t		rt_xpos;	// x position of destination;
	//u_int32_t		rt_ypos;	// y position of destination;
	//u_int8_t		rt_state;	// state of the route: FRESH, EXPIRED, FAILED (BROKEN)
	//u_int8_t		rt_hopcount;    // number of hops up to the destination (sink)
    //double          rt_expire; 	// when route expires : Now + DEFAULT_ROUTE_EXPIRE
    //u_int32_t       rt_seqno;	// route sequence number
    nsaddr_t		rt_vecino;	// next hop node towards the destionation
    double 		rt_bufferOccupancy; 
	double		rt_remainingPower;
	int 		rt_level;
	bool 		rt_flag;
	int 		rt_prioridad;

};
LIST_HEAD(daipas_rtcache, RouteCache);


// ======================================================================
//  DAIPAS Routing Agent : the routing protocol
// ======================================================================

class DAIPAS : public Agent {
	friend class RouteCacheTimer;

 public:
	DAIPAS(nsaddr_t id);

	void		recv(Packet *p, Handler *);
	int         command(int, const char *const *);

	// Agent Attributes
	nsaddr_t	index;     // node address (identifier)
	nsaddr_t	seqno;     // beacon sequence number (used only when agent is sink)
	int nivel;
	int turnoVecino;
	bool softStage;
	bool hardStage;

	// Node Location
	//uint32_t	posx;       // position x;
	//uint32_t	posy;       // position y;
		
	// Routing Table Management
	void		rt_insert(nsaddr_t vecino, float buffer, float energia, int nivel, bool bandera );
	void		rt_remove(RouteCache *rt);
	void		rt_purge();
	RouteCache*	rt_lookup(nsaddr_t dst);
	RouteCache* rt_buscarVecino(Packet *p);

	int estadisticasVecinos [15][2];

	bool primeraVez;

	double iEnergy;
	MobileNode *iNode;
	Node *nodoNormi;

	// Timers
	daipasBeaconTimer		bcnTimer;
	daipasRouteCacheTimer	rtcTimer;
	
	// Caching Head
	daipas_rtcache	rthead;	
	// Send Routines
	void		send_beacon();
	void		send_ACK(nsaddr_t sink);
	void		send_connect(nsaddr_t destinoConnect);
	void		send_error(nsaddr_t unreachable_destination);
	void		forward(Packet *p, nsaddr_t nexthop, double delay);
	void 		send_hello();
	
	// Recv Routines
	void		recv_data(Packet *p);
	void		recv_daipas(Packet *p);
	void 		recv_beacon(Packet *p);
	void 		recv_hello(Packet *p);
	void		recv_error(Packet *p);
	void        recv_ack(Packet *p);
	void        recv_connect(Packet *p);
	
	// Position Management
	void		update_position();


    //  A mechanism for logging the contents of the routing table.
    Trace		*logtarget;

    // A pointer to the network interface queue that sits between the "classifier" and the "link layer"
    PriQueue	*ifqueue;

	// Port classifier for passing packets up to agents
	PortClassifier	*dmux_;

};


#endif /* __daipas_h__ */