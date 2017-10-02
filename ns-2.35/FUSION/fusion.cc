/* 
###################################################
#           Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#       medina.camilo@javeriana.edu.co            #
###################################################

 */

#include <FUSION/fusion.h>
#include <FUSION/fusion_packet.h>
#include <random.h>
#include <cmu-trace.h>
#include <energy-model.h>
#include <stdlib.h>  

#define max(a,b)        ( (a) > (b) ? (a) : (b) )
#define CURRENT_TIME    Scheduler::instance().clock()

//#define DEBUG

// ======================================================================
//  TCL Hooking Classes
// ======================================================================

bool cambioEstado;

int hdr_fusion::offset_;
static class FUSIONHeaderClass : public PacketHeaderClass {
 public:
    FUSIONHeaderClass() : PacketHeaderClass("PacketHeader/FUSION", sizeof(hdr_all_fusion)) {
      bind_offset(&hdr_fusion::offset_);
    } 
} class_rtProtoFUSION_hdr;

static class FUSIONclass : public TclClass {
 public:
    FUSIONclass() : TclClass("Agent/FUSION") {}
    TclObject* create(int argc, const char*const* argv) {
        assert(argc == 5);
        return (new FUSION((nsaddr_t) Address::instance().str2addr(argv[4])));
    }
} class_rtProtoFUSION;


int
FUSION::command(int argc, const char*const* argv) {
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
      
            if(ifqueue == 0)
                return TCL_ERROR;
            return TCL_OK;
        }


        else if(strcmp(argv[1], "mac") == 0) {
            macLayer = (Mac*) TclObject::lookup(argv[2]);
            sensadoTimer.handle((Event*) 0);
      
            if(macLayer == 0)
                return TCL_ERROR;
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

FUSION::FUSION(nsaddr_t id) : Agent(PT_FUSION), bcnTimer(this), rtcTimer(this), sensadoTimer(this) {
               
    index = id;
    seqno = 2;
    LIST_INIT(&rthead);
    logtarget = 0;
    ifqueue = 0;
    congestionado=false;
    vecesSensado=0;
    channelBusy=0;
    cambioEstado=false; 
    //primeraVezSensado=true;  

}

// ======================================================================
//  Timer Functions
// ======================================================================

void
fusionRouteCacheTimer::handle(Event*) {
    agent->rt_purge();
    Scheduler::instance().schedule(this, &intr, ROUTE_PURGE_FREQUENCY);
}

void
fusionBeaconTimer::handle(Event*) {
    agent->send_beacon();
    Scheduler::instance().schedule(this, &intr, DEFAULT_BEACON_INTERVAL);
}

void
fusionSensadoMACTimer::handle(Event*) {
    agent->sensadoMAC();
    Scheduler::instance().schedule(this, &intr, DEFAULT_SENSADO_INTERVAL);
}


// ======================================================================
//  Send Beacon Routine
// ======================================================================
void
FUSION::send_beacon() {


    //printf("\n ESTOY ENVIANDO UN BEACON\n");
    //printf("\n \n MAC: %i\n",  macLayer->getAddress());  
    Packet *p = Packet::alloc();
    struct hdr_cmn *ch = HDR_CMN(p);
    struct hdr_ip *ih = HDR_IP(p);
    struct hdr_fusion_beacon *bcn = HDR_FUSION_BEACON(p);

    // Write Channel Header
    ch->ptype() = PT_FUSION;
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
    bcn->pkt_type = FUSION_BEACON;
    bcn->beacon_hops = 1;
    bcn->beacon_id = seqno;
    bcn->beacon_src = index;
    bcn->timestamp = CURRENT_TIME;

    // increase sequence number for next beacon
    seqno += 2;

    Scheduler::instance().schedule(target_, p, 0.0);

}


// ======================================================================
//  Forward Routine
// ======================================================================

void 
FUSION::forward(Packet *p, nsaddr_t nexthop, double delay) {

    if (cambioEstado)
    {        // Crear el paquete tipo FUSION algo, broadcast...
        send_congestionBit();
    }

    struct hdr_cmn *ch = HDR_CMN(p);
    struct hdr_ip *ih = HDR_IP(p);

    if (ih->ttl_ == 0) {
        drop(p, DROP_RTR_TTL);
    }
    
    if (nexthop != (nsaddr_t) IP_BROADCAST) {
        ch->next_hop_ = nexthop;
        ch->prev_hop_ = index;
        ch->addr_type() = NS_AF_INET;
        ch->direction() = hdr_cmn::DOWN;
    }
    else {
        assert(ih->daddr() == (nsaddr_t) IP_BROADCAST);
        ch->prev_hop_ = index;
        ch->addr_type() = NS_AF_NONE;
        ch->direction() = hdr_cmn::DOWN; 
    }
    
    Scheduler::instance().schedule(target_, p, delay);

}

void 
FUSION::send_congestionBit(){

    Packet *p = Packet::alloc();
    struct hdr_cmn *ch = HDR_CMN(p);
    struct hdr_ip *ih = HDR_IP(p);
    struct hdr_fusion_congestion_bit *bcn = HDR_CONGESTION_BIT(p);

    // Write Channel Header
    ch->ptype() = PT_FUSION;
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
    bcn->pkt_type = FUSION_CONGESTION_BIT;

    if (congestionado==true){
        bcn->congestion=1;  
    } else bcn->congestion=0;  


/*
    if (bcn->congestion==1)
     {
        printf("Nodo: %i Enviando Bit  1 de congestion\n",index); 
     } else  printf("Nodo: %i Enviando Bit 0 de NO congestion\n",index); 
*/


    Scheduler::instance().schedule(target_, p, 0.0);

}




// ======================================================================
//  Recv Packet
// ======================================================================

void
FUSION::recv(Packet *p, Handler*) {
struct hdr_cmn *ch = HDR_CMN(p);
struct hdr_ip *ih = HDR_IP(p);

//printf("En nodo %i...Paquete de %i, siguiente salto %i . Destino: %i \n", index, ih->saddr(), ch->next_hop_,ih->daddr());

    // Analizar si el paquete recibido esta congestionado. Si lo esta, hacer Hop by hop.
    double ocupacion=ifqueue->length();
    int porcentajeCanal=sensadoMAC();
    if ((ocupacion > (0.75 * ifqueue->limit())) || porcentajeCanal>70){
        if (congestionado==false)
        {
            cambioEstado=true;
            printf("Nodo: %i congestionado\n", index);
        } else cambioEstado=false;

       congestionado=true;
        
    } else{
        if (congestionado==true)
        {
            cambioEstado=true;
            printf("Nodo: %i Salio de congestionado\n", index);
        } else cambioEstado=false;
        congestionado=false;

    }

    // if the packet is routing protocol control packet, give the packet to agent
    if(ch->ptype() == PT_FUSION) {
        ih->ttl_ -= 1;
        recv_fusion(p);
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
FUSION::recv_data(Packet *p) {
    struct hdr_ip *ih = HDR_IP(p);
    RouteCache *rt;
    
    // if route fails at link layer, (link layer could not find next hop node) it will cal rt_failed_callback function
    //ch->xmit_failure_ = rt_failed_callback;
    //ch->xmit_failure_data_ = (void*) this;

    rt = rt_lookup(ih->daddr());
    // There is no route for the destination
    if (rt == NULL) {
    // TODO: queue the packet and wait for the route construction
        return ;
    }
    // if the route is not failed forward it;
    else if (rt->rt_state != ROUTE_FAILED) {
        forward(p, rt->rt_nexthop, 0.0);
    }
    
    // if the route has failed, wait to be updated;
    else {
        //TODO: queue the packet and wait for the route construction;
        return;
    }

}

// ======================================================================
//  Recv fusion Packet
// ======================================================================
void
FUSION::recv_fusion(Packet *p) {
    struct hdr_fusion *wh = HDR_FUSION(p);

    assert(HDR_IP (p)->sport() == RT_PORT);
    assert(HDR_IP (p)->dport() == RT_PORT);

    // What kind of packet is this
    switch(wh->pkt_type) {

        case FUSION_BEACON:
            recv_beacon(p);
            break;

        case FUSION_ERROR:
            recv_error(p);
            break;

        case FUSION_CONGESTION_BIT:

            //printf("nodo_ %i SE RECUBIO FUSION\n", index );
            recv_congestion(p);
            break;

        default:
            fprintf(stderr, "Invalid packet type (%x)\n", wh->pkt_type);
            exit(1);
    }
}


void
FUSION::recv_congestion(Packet *p) {
    printf("Nodo %i recibio paquete de congestion\n", index);

    struct hdr_ip *ih = HDR_IP(p);
    struct hdr_fusion_congestion_bit *bcn = HDR_CONGESTION_BIT(p);
    int estadoNodo=bcn->congestion;
    nsaddr_t origen = ih->saddr();

    RouteCache *r = rthead.lh_first;
    for( ; r; r = r->rt_link.le_next) {
        if (r->rt_nexthop == origen){
                if (estadoNodo==1)
                {
                    r->rt_state=ROUTE_FAILED;
                } else {
                    r->rt_state=ROUTE_FRESH;
                }

            
        }
    }    


}



// ======================================================================
//  Recv Beacon Packet
// ======================================================================
void 
FUSION::recv_beacon(Packet *p) {
    struct hdr_ip *ih = HDR_IP(p);
    struct hdr_fusion_beacon *bcn = HDR_FUSION_BEACON(p);
    double now = CURRENT_TIME;    
    // I have originated the packet, just drop it
    if (bcn->beacon_src == index)  {
        Packet::free(p);
        return;
    }
    // search for a route 
    RouteCache  *rt = rt_lookup(bcn->beacon_src);    
    // if there is no route toward this destination, insert the route and forward
    if (rt == NULL)  {
        rt_insert(bcn->beacon_src,bcn->beacon_id, ih->saddr(), bcn->beacon_hops);
        ih->saddr() = index;        
        bcn->beacon_hops +=1; // increase hop count
        double delay = 0.1 + Random::uniform();
        forward(p, IP_BROADCAST, delay);
    }
    // if the route is newer than I have (i.e. new beacon is received): update the route and forward
    else if (bcn->beacon_id > rt->rt_seqno) {
        //printf("Expiración: %0.2f , Actual: %0.2f\n", rt->rt_expire,now);
        //  the routing information is not necessarily advertised immediately,
        // if only the sequence numbers have been change
        bool cambioSignificativo=false;        
        if(rt->rt_nexthop != ih->saddr() || rt->rt_hopcount != bcn->beacon_hops){
            cambioSignificativo=true;
        }
        rt->rt_seqno = bcn->beacon_id;
        rt->rt_nexthop = ih->saddr();
        rt->rt_state = ROUTE_FRESH;
        rt->rt_hopcount = bcn->beacon_hops;
        rt->rt_expire = CURRENT_TIME + DEFAULT_ROUTE_EXPIRE;        
        ih->saddr() = index;
        bcn->beacon_hops +=1; // increase hop count
        double delay = 0.1 + Random::uniform();
        if (cambioSignificativo){
            //printf("\n \n \n Cambio significativo\n");
            double delay = 0.1 + Random::uniform();
            forward(p, IP_BROADCAST, delay);
        } 
    }
    // if the route is shorter than I have, update it
    else if ((bcn->beacon_id == rt->rt_seqno) && (bcn->beacon_hops < rt->rt_hopcount )) {
        //printf("Expiración: %0.2f , Actual: %0.2f\n", rt->rt_expire,now);
        rt->rt_seqno = bcn->beacon_id;
        rt->rt_nexthop = ih->saddr();
        rt->rt_state = ROUTE_FRESH;
        rt->rt_hopcount = bcn->beacon_hops;
        rt->rt_expire = CURRENT_TIME + DEFAULT_ROUTE_EXPIRE;
    }
    // Si ya paso el tiempo de expiracion del nodo
/*
    else if (rt->rt_expire <= now){
        printf("Expiración: %0.2f , Actual: %0.2f\n", rt->rt_expire,now);
        printf("\n Entro AQUIIIIIIIIII\n");
        rt->rt_seqno = bcn->beacon_id;
        rt->rt_nexthop = ih->saddr();
        rt->rt_state = ROUTE_FRESH;
        rt->rt_hopcount = bcn->beacon_hops;
        rt->rt_expire = CURRENT_TIME + DEFAULT_ROUTE_EXPIRE;        
        ih->saddr() = index;
        bcn->beacon_hops +=1; // increase hop count
        double delay = 0.1 + Random::uniform();
        forward(p, IP_BROADCAST, delay);

    }*/
    // TODO : initiate dequeue() routine to send queued packets;
}

// ======================================================================
//  Recv Error Packet
// ======================================================================

void
FUSION::recv_error(Packet *p) {
    // TODO: code should be update;
}


// ======================================================================
//  Routing Management
// ======================================================================


void
FUSION::rt_insert(nsaddr_t src, u_int32_t id, nsaddr_t nexthop, u_int8_t hopcount) {
    RouteCache  *rt = new RouteCache(src, id);
    rt->rt_nexthop = nexthop;
    rt->rt_state = ROUTE_FRESH;
    rt->rt_hopcount = hopcount;
    rt->rt_expire = CURRENT_TIME + DEFAULT_ROUTE_EXPIRE;
    LIST_INSERT_HEAD(&rthead, rt, rt_link);
}



RouteCache* 
FUSION::rt_lookup(nsaddr_t dst) {
    RouteCache *r = rthead.lh_first;
    for( ; r; r = r->rt_link.le_next) {
        if (r->rt_dst == dst)
            return r;
    }    
    return NULL;
}

void
FUSION::rt_purge() {
    RouteCache *rt= rthead.lh_first;
    double now = CURRENT_TIME;

    for(; rt; rt = rt->rt_link.le_next) {
        if(rt->rt_expire <= now)
            rt->rt_state = ROUTE_EXPIRED;
    }
}

void
FUSION::rt_remove(RouteCache *rt) {
    LIST_REMOVE(rt,rt_link);
}



int     
FUSION::sensadoMAC(){

    //printf("\n Hola desde SENSADO MAC\n");

    vecesSensado+=1;
    int utilizacionAnterior=channelBusy*100/vecesSensado;     
    estadoMac=macLayer->state();    
    if (estadoMac!= MAC_IDLE)
    {
        channelBusy+=1;
        //printf("\n CANAL OCUPADOOOOOOO\n");    
    } 

    int numero=rand()%100;
    if (numero>70){
        channelBusy+=1;
        //printf("\n CANAL OCUPADOOOOOOO\n"); 
    }
    //printf("Chanel  %i\n", channelBusy);
    //printf("Veces Sensado %i\n", vecesSensado);
    int utilizacionActual=channelBusy*100/vecesSensado;

    // Se requiere con EWMA
    //alpha*actual+ (1-alpha)*Anterior
    

    int utilizacionPonderada=0.85*utilizacionActual + (1-0.85)*utilizacionAnterior;
    //printf("Nodo %i Utulizacion:_ %i\n",index, utilizacionPonderada);
    return utilizacionPonderada;



}