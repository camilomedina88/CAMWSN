/*
###################################################
#         Congestion Control WSN               	  #
#     Camilo ALejandro Medina Mondragón           #
#   medina.camilo@javeriana.edu.co            	  #
###################################################

*/

#include <CAMM/CammRouter.h>
#include <CAMM/Camm_packet.h>
#include <random.h>
#include <cmu-trace.h>
#include <energy-model.h>
#include <unistd.h>
#include <cmath> 
#include <iostream>
#include <algorithm>

//#define max(a,b)        ( (a) > (b) ? (a) : (b) )
#define CURRENT_TIME    Scheduler::instance().clock()

//#define DEBUG

// ======================================================================
//  TCL Hooking Classes
// ======================================================================

int hdr_camm::offset_;
static class CAMMHeaderClass : public PacketHeaderClass {
 public:
	CAMMHeaderClass() : PacketHeaderClass("PacketHeader/CAMM", sizeof(hdr_all_camm)) {
	  bind_offset(&hdr_camm::offset_);
	} 
} class_rtProtoCAMM_hdr;

static class CAMMclass : public TclClass {
 public:
	CAMMclass() : TclClass("Agent/CAMM") {}
	TclObject* create(int argc, const char*const* argv) {
		assert(argc == 5);
		return (new CAMM((nsaddr_t) Address::instance().str2addr(argv[4])));
	}
} class_rtProtoCAMM;


int
CAMM::command(int argc, const char*const* argv) {
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
			if(ifqueue == 0)
				return TCL_ERROR;
			return TCL_OK;
		}

        else if(strcmp(argv[1], "mac") == 0) {
            macLayer = (Mac*) TclObject::lookup(argv[2]);
            macLayer->setDelay(backoff);
      
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

CAMM::CAMM(nsaddr_t id) : Agent(PT_CAMM), bcnTimer(this), rtcTimer(this) {
             

#ifdef DEBUG
	printf("N (%.6f): Routing agent is initialized for node %d \n", CURRENT_TIME, id);
#endif 
	index = id;
	seqno = 1;
	nivel=300; //Se inicializa con un nivel muy alto
	MobileNode *iNode;
	iEnergy=0.0;
	LIST_INIT(&rthead);
	logtarget = 0;
	ifqueue = 0;
	primeraVez=true;
	turnoVecino=1;
	//softStage=false;
	hardStage=false;
	backoff=0.0004;
	congestionadoOrigen=false;


	//Lenar la matriz de Estadisticas de vecinos.
	for (int i = 0; i < 15; i++){
		for (int j = 0; j < 2; j++){
			if (j==1){
				estadisticasVecinos [i][j]=0;
			}else{
				estadisticasVecinos [i][j]=200;
			}
		}	
	}

}

// ======================================================================
//  Timer Functions
// ======================================================================

void
cammRouteCacheTimer::handle(Event*) {
	agent->rt_purge();
	//Scheduler::instance().schedule(this, &intr, ROUTE_PURGE_FREQUENCY);
}

void
cammBeaconTimer::handle(Event*) {
	agent->send_beacon();
	Scheduler::instance().schedule(this, &intr, DEFAULT_BEACON_INTERVAL);
}


// ======================================================================
//  Send Beacon Routine
// ======================================================================
void
CAMM::send_beacon() { //SEND HELLO


	if(index==0)	nivel=0;

	 iNode=(MobileNode *)(Node::get_node_by_address(index));
	 iEnergy=iNode->energy_model()->energy();
	 double ocupacion=ifqueue->length();
	
	if(primeraVez){
	primeraVez=false;
	Packet *p = Packet::alloc();
	struct hdr_cmn *ch = HDR_CMN(p);
	struct hdr_ip *ih = HDR_IP(p);
	struct hdr_camm_beacon *bcn = HDR_CAMM_BEACON(p);

	// Write Channel Header
	ch->ptype() = PT_CAMM;
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
	bcn->pkt_type = CAMM_BEACON;
	bcn-> level = nivel;
	bcn->beacon_src = index;
	bcn->timestamp = CURRENT_TIME;
	bcn->bufferOccupancy=ocupacion*100/20;
	bcn->remainingPower=iEnergy*100/3.9;
	bcn->flag=true;


	printf("S (%.6f): send beacon by %d  \n", CURRENT_TIME, index);

	//double delay = 0.1 + Random::uniform();
	Scheduler::instance().schedule(target_, p, 0.0);
	}

}

// ======================================================================
//  Forward Routine
// ======================================================================

void 
CAMM::forward(Packet *p, nsaddr_t nexthop, double delay) {
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
// ======================================================================
//  Recv Packet
// ======================================================================

void
CAMM::recv(Packet *p, Handler*) {
struct hdr_cmn *ch = HDR_CMN(p);
struct hdr_ip *ih = HDR_IP(p);

	// if the packet is routing protocol control packet, give the packet to agent
	if(ch->ptype() == PT_CAMM) {
		ih->ttl_ -= 1;
		recv_camm(p);
		return;
	}
	//  Must be a packet I'm originating
	if((ih->saddr() == index) && (ch->num_forwards() == 0)) {
 			// Add the IP Header. TCP adds the IP header too, so to avoid setting it twice, 
		// we check if  this packet is not a TCP or ACK segment.
		if (ch->ptype() != PT_TCP && ch->ptype() != PT_ACK) {
			ch->size() += IP_HDR_LEN;
		}
		// Se le informa a la aplicación si el nodo está congestionado
		if (hardStage){
		congestionadoOrigen=true;
		}else{
		congestionadoOrigen=false;
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
CAMM::recv_data(Packet *p) {
	struct hdr_ip *ih = HDR_IP(p);
	struct hdr_cmn *ch = HDR_CMN(p);
	RouteCache *rt;
	
	//printf("R (%.6f): recv data by %d  \n", CURRENT_TIME, index);

	rt=rt_buscarVecino(p);
	//rt = rt_lookup(ih->daddr());
	// There is no route for the destination
	if (rt == NULL) {
	// TODO: queue the packet and wait for the route construction
		return ;
	}
	// if the route is not failed forward it;	
	else if (rt->rt_flag) {
		//printf("En el nodo %i se realizo forward a %i\n",index, rt->rt_vecino);
		forward(p, rt->rt_vecino, 0.0);

	}		
	// if the route has failed, wait to be updated;
	else {
		//TODO: queue the packet and wait for the route construction;
		return;
	}

}

// ======================================================================
//  Recv CAMM Packet
// ======================================================================
void
CAMM::recv_camm(Packet *p) {
	struct hdr_camm *wh = HDR_CAMM(p);
	//struct hdr_ip *ih = HDR_IP(p);

	assert(HDR_IP (p)->sport() == RT_PORT);
	assert(HDR_IP (p)->dport() == RT_PORT);

	// What kind of packet is this
	switch(wh->pkt_type) {

		case CAMM_BEACON:
			recv_beacon(p);
			break;

		case CAMM_ACK:
			recv_ack(p);			
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
CAMM::recv_beacon(Packet *p) {
	struct hdr_ip *ih = HDR_IP(p);
	struct hdr_camm_beacon *bcn = HDR_CAMM_BEACON(p);	
	// I have originated the packet, just drop it
	if (bcn->beacon_src == index)  {
		Packet::free(p);
		return;
		}
	//printf("R (%.6f): recv beacon by %d, src:%d, seqno:%d, hop: %d \n", 
	//CURRENT_TIME, index, bcn->beacon_src, bcn->beacon_id, bcn->beacon_hops);

	//printf("Se recibio beacon en %i con origen %i \n",index, bcn->beacon_src);
	RouteCache	*rt = rt_lookup(bcn->beacon_src);

	if (rt == NULL)  {
		rt_insert(bcn->beacon_src, bcn->bufferOccupancy, bcn->remainingPower, bcn-> level, bcn->flag);
	}

	int routeLevel=300;	
	RouteCache *r = rthead.lh_first;
	printf("\nTabla de Vecinos del nodo %i: \n",index);
  	for( ; r; r = r->rt_link.le_next) {
  		printf("Vecino: %i Nivel: %i Buffer: %0.2f Power: %0.2f \n", r->rt_vecino, r->rt_level, r->rt_bufferOccupancy, r->rt_remainingPower);
  		if (r->rt_level < routeLevel)
  		{
  			routeLevel=r->rt_level;
  		}  	
 	}
 	nivel=routeLevel +1;
 	printf("NODO %i Nivel: %i \n",index,nivel);	

 	send_beacon();
}

void
CAMM::send_ACK(nsaddr_t vecino){

	iNode=(MobileNode *)(Node::get_node_by_address(index));
	iEnergy=iNode->energy_model()->energy();
	double ocupacion=ifqueue->length();

	//Crear paquete
	Packet *p = Packet::alloc();
	struct hdr_cmn *ch = HDR_CMN(p);
	struct hdr_ip *ih = HDR_IP(p);
	struct hdr_camm_ack *ack = HDR_CAMM_ACK(p);
	// Write Channel Header
	ch->ptype() = PT_CAMM;
	ch->size() = IP_HDR_LEN + ack->size();
	ch->addr_type() = NS_AF_NONE;
	ch->prev_hop_ = index;
	// Write IP Header
	ih->saddr() = index;
	ih->daddr() = vecino;
	ih->sport() = RT_PORT;
	ih->dport() = RT_PORT;
	ih->ttl_ = NETWORK_DIAMETER;
	// Write ACK Header
	ack->pkt_type=CAMM_ACK;
	ack->timestamp=CURRENT_TIME;
	ack->nodeId=index;
	ack->nextPacket=false;
	ack->bufferOccupancy=ocupacion*100/20;
	ack->remainingPower=iEnergy*100/3.9;
	ack->level=nivel;
	ack->flag=(!hardStage);
	double delay = 0.1 + Random::uniform();
	Scheduler::instance().schedule(target_, p, delay);
	//printf("El nodo: %i envia un ACK al nodo %i \n", index,vecino);

}

void        
CAMM::recv_ack(Packet *p){
	
struct hdr_ip *ih = HDR_IP(p);
struct hdr_camm_ack *ack = HDR_CAMM_ACK(p);

// I have originated the packet, just drop it
	if (ih->saddr()== index)  {
		Packet::free(p);
		return;
	}

	if(ih->daddr()== index ){
		//Actualizar la tabla de vecinos con la nueva información del nodo.
		RouteCache *r = rthead.lh_first;
	  	for( ; r; r = r->rt_link.le_next) {
	  		if (r->rt_vecino==ih->saddr()){
	  			r->rt_bufferOccupancy=ack->bufferOccupancy; 
				r->rt_remainingPower=ack->remainingPower;
				r->rt_level=ack->level;
				r->rt_flag=ack->flag;
				//Disminuir la prioridad de esta ruta.
				r->rt_prioridad=r->rt_prioridad-1;
			}
	 	}
	}else{
		Packet::free(p);
		return;
	}

}
// ======================================================================
//  Routing Management
// ======================================================================

/* static void
camm::rt_failed_callback(Packet *p, void *arg) {

}*/

void
CAMM::rt_insert(nsaddr_t vecino, float buffer, float energia, int nivel, bool bandera ) {
	RouteCache	*rt = new RouteCache(vecino);

   	rt->rt_vecino=vecino;	// next hop node towards the destionation
    rt->rt_bufferOccupancy=buffer; 
	rt->rt_remainingPower=energia;
	rt->rt_level=nivel;
	rt->rt_flag=bandera;
	rt->rt_prioridad=500;

	LIST_INSERT_HEAD(&rthead, rt, rt_link);

	//printf("Se agregó la ruta en el nodo %i.... Vecino: %i \n", index, vecino);
}


RouteCache* 
CAMM::rt_buscarVecino(Packet *p){
	struct hdr_ip *ih = HDR_IP(p);
	struct hdr_cmn *ch = HDR_CMN(p);
	//Revisar que el vecino este agregado. si no esta. se agrega
	RouteCache	*rt = rt_lookup(ch->prev_hop());
	if (rt == NULL)  {
		rt_insert(ch->prev_hop(), 0.0, 0.0, 40, true);
	}

	//Contar cuantos vecinos de más bajo nivel existen para enviar el paquete por esos vecinos:
	RouteCache *r = rthead.lh_first;
	int contadorVecinos=0;	
  	for( ; r; r = r->rt_link.le_next) {
		if (r->rt_level < nivel){
			contadorVecinos+=1;
		}
 	}
	
	
 	for(int i=0;i<15;i++){
		//printf("En el nodo %i, se recibio un paquete Salto previo %i\n",index, ch->prev_hop() );
			if(estadisticasVecinos[i][0]==ch->prev_hop()){					
				estadisticasVecinos[i][1]+=1;
			}			
	}

 	// ########################################################################
 	// ######################### HARD STAGE ###################################
 	// ########################################################################


 	bool previo=hardStage;
 	// Revisar el buffer. Si supera un umbral, HardStage=true
	double ocupacion=ifqueue->length();
	if (ocupacion>16){
		//printf("Nodo %i Supero el buffer\n", index);
		hardStage=true;
	}	
			

 	// Revisar la energia. Si esta baja, HardStage=true
 	iNode=(MobileNode *)(Node::get_node_by_address(index));
	iEnergy=iNode->energy_model()->energy();
	if (iEnergy*(100/3.9) < 25 ){
		//printf("Nivel Energia\n");
		hardStage=true;
	}
	

 	// Revisar los vecinos, si todos estan en HardStage, entonces HardStage=true
	RouteCache *rp = rthead.lh_first;
	int vecinosNoDisponibles=0;
	for(  ; rp; rp = rp->rt_link.le_next) {
		if (rp->rt_level < nivel){
			if (rp->rt_flag==false){
				vecinosNoDisponibles+=1;
			}
		}
 	}

 	if(vecinosNoDisponibles>=contadorVecinos){
 		hardStage=true;
 		//printf("Nodo %i no tiene Vecinos disponibles\n",index);
 	}

 	// Para salir de Hard Stage
 	if (ocupacion<=15 && iEnergy*(100/3.9) >=25 && vecinosNoDisponibles<contadorVecinos){
 		//printf("El nodo %i esta OK\n", index);
 		hardStage=false;
 	}

 	if (index==0)
 		hardStage=false;

 	if (hardStage !=previo){
 		//printf("\n \n # \n ## \n ### \n ############# Nodo %i cambio de estado a %i \n", index,hardStage); 		
 		RouteCache *rl = rthead.lh_first;
 		for(  ; rl; rl = rl->rt_link.le_next) {
				send_ACK(rl->rt_vecino);		
 		}
 	}


 	// Si esta en HardStage, tener acceso prioritario al canal....
 	if (hardStage){
 	backoff=0.0001; 	
 	macLayer->setDelay(backoff);
 	} else {
 		backoff=0.0004;
        macLayer->setDelay(backoff);
 	}

 		
	// Si hay mas de dos vecinos con menor nivel se utiliza Round Robin
 	if (contadorVecinos ==1){
	 	RouteCache *ra = rthead.lh_first;
	  	for( ; ra; ra = ra->rt_link.le_next) {
			if (ra->rt_level < nivel){
				return ra;
			}
	 	}	
 	}

 	if (contadorVecinos > 1){	 	
 		// Revisar las prioridades de las rutas, si todas son iguales entonces pasar a round robin.
 		int tablaPrioridades[contadorVecinos][2];
 		RouteCache *ry = rthead.lh_first;
 		int entradaAnalizada=0;
 		int maximaPrioridad=0;
 		for( ; ry; ry = ry->rt_link.le_next) {
 			if (ry->rt_level < nivel){
 				tablaPrioridades[entradaAnalizada][0]=ry->rt_vecino;
 				tablaPrioridades[entradaAnalizada][1]=ry->rt_prioridad;
 				if (maximaPrioridad<ry->rt_prioridad) 
 						maximaPrioridad=ry->rt_prioridad; 				
 				entradaAnalizada+=1;
 			}
 		}

 		int nextRoute[entradaAnalizada];
 		int cantidadRutas=0;

 		for (int i = 0; i < entradaAnalizada; i++){
 			if (tablaPrioridades[i][1]==maximaPrioridad){
 				nextRoute[cantidadRutas]=tablaPrioridades[i][0];
 				cantidadRutas+=1;
 			}
 		}

/*
 		printf("Con los que se hara Round Robin\n");
		for (int row=0; row<entradaAnalizada; row++){
	   			printf("%d     ", nextRoute[row]);
	       		printf("\n");
		}*/
	
		//printf("Cantidad de rutas en round robin %i\n",cantidadRutas );

	 	int contadorAnalizado=1;
	 	if (turnoVecino>cantidadRutas)
	 						turnoVecino=1;


	 	for (int i = 0; i < entradaAnalizada; i++){
	 		if (turnoVecino==i+1){
	 			//printf("Se envia el paquete al %i vecino \n", turnoVecino);
	 			turnoVecino+=1;
	 			return rt_lookup(nextRoute[i]);
	 		}
	 	}
 	}
	return NULL;
}


RouteCache*	
CAMM::rt_lookup(nsaddr_t dst) {
	
	RouteCache *r = rthead.lh_first;

  	for( ; r; r = r->rt_link.le_next) {
		if (r->rt_vecino == dst)
			return r;
 	}	
	return NULL;
}

void
CAMM::rt_purge() {
/*	RouteCache *rt= rthead.lh_first;
	double now = CURRENT_TIME;

	for(; rt; rt = rt->rt_link.le_next) {
		if(rt->rt_expire <= now)
			rt->rt_state = ROUTE_EXPIRED;
 	}*/
}

void
CAMM::rt_remove(RouteCache *rt) {
	LIST_REMOVE(rt,rt_link);
}

