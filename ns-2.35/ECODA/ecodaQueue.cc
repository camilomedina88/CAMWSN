/*
###################################################
#         Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#   medina.camilo@javeriana.edu.co            #
###################################################

*/
#include "ecodaQueue.h"
#include <cmath> 

#define CURRENT_TIME    Scheduler::instance().clock()
/*
static class AODVclass : public TclClass {
public:
        AODVclass() : TclClass("Agent/AODV") {}
        TclObject* create(int argc, const char*const* argv) {
          assert(argc == 5);
          //return (new AODV((nsaddr_t) atoi(argv[4])));
    return (new AODV((nsaddr_t) Address::instance().str2addr(argv[4])));
        }
} class_rtProtoAODV;
*/


static class EcodaQueueClass : public TclClass {
public:
        EcodaQueueClass() : TclClass("Queue/Ecoda") {}
        TclObject* create(int argc, const char*const* argv) {
          //printf("El parametro recibido es %s\n", argv[4]);
	         return (new EcodaQueue(atoi(argv[4])));

	}
} class_dropt_tail_round_robin;


void EcodaQueue::enque(Packet* p)
{

  hdr_ip* iph = hdr_ip::access(p);
  hdr_cmn *ch = HDR_CMN(p);
  int tamanioActual=(q1_->length() + q2_->length());
//ESTADO REJECT
  if(tamanioActual > qlim_*2/3) estadoBuffer=2;
//ESTADO ACEPT
  if(tamanioActual < qlim_*1/3) estadoBuffer=0;
//ESTADO FILTER
  if(tamanioActual >= qlim_*1/3 && tamanioActual <= qlim_*2/3)     estadoBuffer=1;   
  
  if(iph->saddr() == index){ //Origen el Nodo...       

    if (ch->ptype() == PT_AODV){
      //printf("Prioridad estatica 3 \n");
      iph->staticPriority=3;
    } else if(ch->ptype() == PT_EXP){
      //printf("Prioridad estatica 2 \n");
      iph->staticPriority=2;
      } else{
        //printf("Prioridad estatica 1 \n");
        iph->staticPriority=1;
      }

    //Calcular prioridad dinamica....
      int hops= ch->num_forwards();
      double delay= hops*0.005;
      double stacCalculation= (alpha*1+iph->getStaticPriority())/(1+beta*delay);
      if (stacCalculation>5) stacCalculation=5;
    // Agregar prioridad dinamica....
      iph->dynamicPriority = stacCalculation;
    //Revisar el estado de la cola y realizar politica de admision


    if(stacCalculation>3.5){
      q1_->enqueHead(p);


    }else{
      q1_->enque(p);
    }
    
    if(estadoBuffer==1){
      //Estado Filter
      if(stacCalculation<2){
        //printf("Drop en Q1 Estado Filter\n");
        q1_->remove(p);
        drop(p);
      }
    }

    if (estadoBuffer==2) {
      //Estado reject
        if(stacCalculation<=3 || tamanioActual>=(qlim_-1)){
          //printf("Drop en Q1 Estado Reject\n");
        q1_->remove(p);
        drop(p);
      }
    }    
  }  
  else { //Origen Distinto *****************

    //Revisar prioridad dinamica.
     int hops= ch->num_forwards();
     double delay= hops*0.005;

    float prioActual= (alpha*hops+iph->getStaticPriority())/(1+beta*delay);
    if (prioActual>5) prioActual=5;
    iph->dynamicPriority=prioActual;


    //Revisar el estado de la cola, y realizar politica de admision


    if(prioActual>3.5){
      q2_->enqueHead(p);
    }else{
      q2_->enque(p);
    }

    

  if(estadoBuffer==1){
       //Estado Filter
       if(prioActual<2){
         q2_->remove(p);
         //printf("Drop en Q2 Estado Filter\n");
         drop(p);
       }
    }
    if (estadoBuffer==2) {
      //Estado reject
        if(prioActual<=3 || tamanioActual>=(qlim_-1)){
        q2_->remove(p);
        //printf("Drop en Q2 Estado Reject\n");
        drop(p);
      }

  }

  }
}


Packet* EcodaQueue::deque()
{
  Packet *p;

  //sortQueue(q1_);
  
  //Buscar la forma de ordenarlo por flujos y paquetes...
  if (deq_turn_ == 1) {    
    p =  q1_->deque();    
    
    if (p == 0) {
      p = q2_->deque();
      deq_turn_ = 1;
    }
    else {
      deq_turn_ = 2;
      //printf("DEQueue: Nodo: %i DEEncolado en Q1 \n",index);
    }
  }
  else {    
    p =  q2_->deque();    
    if (p == 0) {
      p = q1_->deque();
      deq_turn_ = 2;
    }
    else {
      deq_turn_ = 1;
      //printf("DEQueue: Nodo: %i DEEncolado en Q2 \n",index);
    }
  }
  return (p);
}





void EcodaQueue::sortQueue(PacketQueue* queueActual){

int lenghtQueue=queueActual->length();
//printf("Tamaño: %i\n",lenghtQueue );

Packet* ordenada[lenghtQueue];
Packet* paqueteActual=queueActual->head(); //Cabeza de la cola
ordenada[0]=paqueteActual;

for(int i=1;i<lenghtQueue-2;i++){
Packet* paqueteActual=paqueteActual->next_;
ordenada[i]=paqueteActual;
}

/*
printf("En el nodo: %i se tienen los paquetes:\n", index);

for(int i=0;i<lenghtQueue;i++){

  printf("%i packete: \n",i,ordenada[i]->hdrlen_);


}
*/



}

