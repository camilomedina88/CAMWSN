/*
###################################################
#        	Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#		medina.camilo@javeriana.edu.co            #
###################################################

*/

#include <string.h>
#include "queue.h"
#include "address.h"
//#include "packet.h"
//#include "ecodaPacket.h"


class EcodaQueue : public Queue {
 public:
         EcodaQueue(int id) { 
		q1_ = new PacketQueue;
		q2_ = new PacketQueue;
		pq_ = q1_;
		deq_turn_ = 1;
		index = id;
		estadoBuffer=0;
		alpha=0.5;
		beta=0.02;

		//printf("Nodo: %i - \n", index);
	}
		 //void    recv(Packet *p, Handler *h);

 protected:
     void enque(Packet*);
     void sortQueue(PacketQueue*);
	 Packet* deque();
	 //void enqueA(Packet* p);
	 //void enqueB(Packet* p);

	 PacketQueue *q1_;   // First  FIFO queue
	 PacketQueue *q2_;   // Second FIFO queue
	 int deq_turn_;      // 1 for First queue 2 for Second
	 int index;
	 int estadoBuffer; //0 -> Accept State, 1 -> Filter State, 2 ->Reject State
	 float alpha;
	 float beta;
};