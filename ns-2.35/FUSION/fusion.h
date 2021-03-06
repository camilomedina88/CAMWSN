/* 
###################################################
#           Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#       medina.camilo@javeriana.edu.co            #
###################################################

 */

#ifndef __fusion_h__
#define __fusion_h__

#include <cmu-trace.h>
#include <priqueue.h>
#include "mac.h"
//#include <wpan/p802_15_4mac.h>
#include <classifier/classifier-port.h>

#define NETWORK_DIAMETER            64
#define DEFAULT_BEACON_INTERVAL     10 // seconds;
#define DEFAULT_ROUTE_EXPIRE        2*DEFAULT_BEACON_INTERVAL // seconds;
#define ROUTE_PURGE_FREQUENCY       2 // seconds
#define DEFAULT_SENSADO_INTERVAL    1 // seconds;



#define ROUTE_FRESH     0x01
#define ROUTE_EXPIRED       0x02
#define ROUTE_FAILED        0x03

class FUSION;

// ======================================================================
//  Timers : Beacon Timer, Route Cache Timer
// ======================================================================

class fusionBeaconTimer : public Handler {
public:
        fusionBeaconTimer(FUSION* a) : agent(a) {}
        void    handle(Event*);
private:
        FUSION    *agent;
        Event   intr;
};

class fusionRouteCacheTimer : public Handler {
public:
        fusionRouteCacheTimer(FUSION* a) : agent(a) {}
        void    handle(Event*);
private:
        FUSION    *agent;
        Event   intr;
};


class fusionSensadoMACTimer : public Handler {
public:
        fusionSensadoMACTimer(FUSION* a) : agent(a) {}
        void    handle(Event*);
private:
        FUSION    *agent;
        Event   intr;
};





// ======================================================================
//  Route Cache Table
// ======================================================================
class RouteCache {
    friend class FUSION;
 public:
    RouteCache(nsaddr_t bsrc, u_int32_t bid) { rt_dst = bsrc; rt_seqno = bid;  }
 protected:
    LIST_ENTRY(RouteCache) rt_link;
    u_int32_t       rt_seqno;   // route sequence number
    nsaddr_t        rt_dst;     // route destination
    nsaddr_t    rt_nexthop; // next hop node towards the destionation
    //u_int32_t   rt_xpos;    // x position of destination;
    //u_int32_t   rt_ypos;    // y position of destination;
    u_int8_t    rt_state;   // state of the route: FRESH, EXPIRED, FAILED (BROKEN)
    u_int8_t    rt_hopcount;    // number of hops up to the destination (sink)
    double          rt_expire;  // when route expires : Now + DEFAULT_ROUTE_EXPIRE

};
LIST_HEAD(fusion_rtcache, RouteCache);


// ======================================================================
//  fusion Routing Agent : the routing protocol
// ======================================================================

class FUSION : public Agent {
    friend class RouteCacheTimer;

 public:
    FUSION(nsaddr_t id);

    void        recv(Packet *p, Handler *);
    int         command(int, const char *const *);

    // Agent Attributes
    nsaddr_t    index;     // node address (identifier)
    nsaddr_t    seqno;     // beacon sequence number (used only when agent is sink)
    bool congestionado;     // Esta variable sirve para Hop-by Hop Control
    bool congestionadoOrigen; // Esta variable indica a la APP que esta congestionado el nodo
        
    // Routing Table Management
    void        rt_insert(nsaddr_t src, u_int32_t id, nsaddr_t nexthop, u_int8_t hopcount);
    void        rt_remove(RouteCache *rt);
    void        rt_purge();
    RouteCache* rt_lookup(nsaddr_t dst);
    int     sensadoMAC();

    // Timers
    fusionBeaconTimer       bcnTimer;
    fusionRouteCacheTimer   rtcTimer;
    fusionSensadoMACTimer   sensadoTimer;

    nsaddr_t nodoPadre;
    bool cambioEstado;
    int medidas[4]; // para almacenar las cuadro medidas del canal

    int token;
    double backoff;
    
    // Caching Head
    fusion_rtcache  rthead; 
    // Send Routines
    void        send_beacon();
    void        send_congestionBit();
    //void        send_error(nsaddr_t unreachable_destination);
    void        forward(Packet *p, nsaddr_t nexthop, double delay);
    
    // Recv Routines
    void        recv_data(Packet *p);
    void        recv_fusion(Packet *p);
    void        recv_beacon(Packet *p);
    void        recv_error(Packet *p);
    void        recv_congestion(Packet *p);
    
    //  A mechanism for logging the contents of the routing table.
    Trace       *logtarget;

    // A pointer to the network interface queue that sits between the "classifier" and the "link layer"
    PriQueue    *ifqueue;

    // Port classifier for passing packets up to agents
    PortClassifier  *dmux_;

    Mac *macLayer;
    //Mac802_15_4 *macLayer;
    MacState estadoMac;

    int vecesSensado; // Contador para saber las veces que se ha sensado el medio
    int channelBusy; // Contador indicando cuantas veces el canal estaba ocupado.
    //bool primeraVezSensado; //Para el calculo de MAC utilization

};


#endif /* __fusion_h__ */