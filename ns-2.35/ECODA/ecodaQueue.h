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
#include "timer-handler.h"
//#include "packet.h"
//#include "ecodaPacket.h"



class EcodaQueue;

class EcodaTimer : public TimerHandler{
public:
	EcodaTimer(EcodaQueue *eco) {ecoda_=eco;};
	virtual void expire (Event *e);
protected:
	EcodaQueue *ecoda_;
};


class EcodaQueue : public Queue {
	friend class EcodaTimer;
 public:
        EcodaQueue(int id): timer_(this) { 
		q1_ = new PacketQueue;
		q2_ = new PacketQueue;
		pq_ = q1_;
		deq_turn_ = 1;
		index = id;
		estadoBuffer=0;
		alpha=0.5;
		beta=0.02;
		}
 protected:
     void enque(Packet*);
     void sortQueue(PacketQueue*);
	 Packet* deque();
	 Packet* sendEcoda();
	 //void enqueA(Packet* p);
	 //void enqueB(Packet* p);

	 PacketQueue *q1_;   // First  FIFO queue
	 PacketQueue *q2_;   // Second FIFO queue
	 //Packet *primerPaquete;

	 int deq_turn_;      // 1 for First queue 2 for Second
	 int index;
	 int estadoBuffer; //0 -> Accept State, 1 -> Filter State, 2 ->Reject State
	 float alpha;
	 float beta;
	 EcodaTimer timer_;
	
};