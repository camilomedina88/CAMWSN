/* 
###################################################
#        	Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#		medina.camilo@javeriana.edu.co            #
###################################################
 *
 */

#ifndef __ecoda_h__
#define __ecoda_h__

#include <cmu-trace.h>
#include <priqueue.h>
#include <classifier/classifier-port.h>

#define NETWORK_DIAMETER		64
#define DEFAULT_BEACON_INTERVAL		10 // seconds;
#define DEFAULT_ROUTE_EXPIRE 		2*DEFAULT_BEACON_INTERVAL // seconds;
#define ROUTE_PURGE_FREQUENCY		2 // seconds



#define ROUTE_FRESH		0x01
#define ROUTE_EXPIRED		0x02
#define ROUTE_FAILED		0x03

class ECODA;

// ======================================================================
//  Timers : Beacon Timer, Route Cache Timer
// ======================================================================

class ecodaBeaconTimer : public Handler {
public:
        ecodaBeaconTimer(ECODA* a) : agent(a) {}
        void	handle(Event*);
private:
        ECODA    *agent;
	Event	intr;
};

class ecodaRouteCacheTimer : public Handler {
public:
        ecodaRouteCacheTimer(ECODA* a) : agent(a) {}
        void	handle(Event*);
private:
        ECODA    *agent;
	Event	intr;
};

// ======================================================================
//  Route Cache Table
// ======================================================================
class RouteCache {
	friend class ECODA;
 public:
	RouteCache(nsaddr_t bsrc, u_int32_t bid) { rt_dst = bsrc; rt_seqno = bid;  }
 protected:
	LIST_ENTRY(RouteCache) rt_link;
	u_int32_t       rt_seqno;	// route sequence number
	nsaddr_t        rt_dst;		// route destination
    nsaddr_t	rt_nexthop;	// next hop node towards the destionation
	u_int32_t	rt_xpos;	// x position of destination;
	u_int32_t	rt_ypos;	// y position of destination;
	u_int8_t	rt_state;	// state of the route: FRESH, EXPIRED, FAILED (BROKEN)
	u_int8_t	rt_hopcount;    // number of hops up to the destination (sink)
	double  	retardo;
    double          rt_expire; 	// when route expires : Now + DEFAULT_ROUTE_EXPIRE

};
LIST_HEAD(ecoda_rtcache, RouteCache);


// ======================================================================
//  ecoda Routing Agent : the routing protocol
// ======================================================================

class ECODA : public Agent {
	friend class RouteCacheTimer;

 public:
	ECODA(nsaddr_t id);

	void		recv(Packet *p, Handler *);
	int         command(int, const char *const *);


	double tasaEnvio;
	bool primerBeacon;
	double retardoPrev;

	// Agent Attributes
	nsaddr_t	index;     // node address (identifier)
	nsaddr_t	seqno;     // beacon sequence number (used only when agent is sink)

	// Node Location
	uint32_t	posx;       // position x;
	uint32_t	posy;       // position y;
		
	// Routing Table Management
	void		rt_insert(nsaddr_t src, u_int32_t id, nsaddr_t nexthop, u_int32_t xpos, u_int32_t ypos, u_int8_t hopcount, double retardo);
	void		rt_remove(RouteCache *rt);
	void		rt_purge();
	RouteCache*	rt_lookup(nsaddr_t dst);

	// Timers
	ecodaBeaconTimer		bcnTimer;
	ecodaRouteCacheTimer	rtcTimer;
	
	// Caching Head
	ecoda_rtcache	rthead;	
	// Send Routines
	void		send_beacon();
	void		send_error(nsaddr_t unreachable_destination);
	void		forward(Packet *p, nsaddr_t nexthop, double delay);
	
	// Recv Routines
	void		recv_data(Packet *p);
	void		recv_ecoda(Packet *p);
	void 		recv_beacon(Packet *p);
	void		recv_error(Packet *p);
	
	// Position Management
	void		update_position();


    //  A mechanism for logging the contents of the routing table.
    Trace		*logtarget;

    // A pointer to the network interface queue that sits between the "classifier" and the "link layer"
    PriQueue	*ifqueue;

	// Port classifier for passing packets up to agents
	PortClassifier	*dmux_;

};


#endif /* __ecoda_h__ */