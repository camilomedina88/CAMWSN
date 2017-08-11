/*
###################################################
#         Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#   medina.camilo@javeriana.edu.co            #
###################################################

*/
#include "ecodaQueue.h"

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

  if(tamanioActual > qlim_*2/3){
          //printf("Estado Reject\n");
          estadoBuffer=2;
   }

   if(tamanioActual < qlim_*1/3){
          //printf("Estado Accept\n");
          estadoBuffer=0;
   }

   if(tamanioActual >= qlim_*1/3 && tamanioActual <= qlim_*2/3){
          //printf("Estado Filter\n");
          estadoBuffer=1;
   }
  
  if(iph->saddr() == index){ //Origen el Nodo...    
    q1_->enque(p);
    if (estadoBuffer==2) {
      //printf("Drop en Q1 \n");
      q1_->remove(p);
      drop(p);
    }    
  }  else { //Origen Distinto
    q2_->enque(p);
    if (estadoBuffer==2) {
      //printf("Drop en Q2 \n");
      q2_->remove(p);
      drop(p);
    }
  }

}


Packet* EcodaQueue::deque()
{
  Packet *p;
  

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


