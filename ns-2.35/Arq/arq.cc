#include "arq.h"
static class ARQTxClass: public TclClass {
public:
    ARQTxClass() : TclClass("ARQTx") {}
    TclObject* create(int, const char*const*) {
        return (new ARQTx);
    }
} class_arq_tx;

static class ARQAckerClass: public TclClass {
public:
    ARQAckerClass() : TclClass("ARQAcker") {}
    TclObject* create(int, const char*const*) {
        return (new ARQAcker);
    }
} class_arq_acker;

static class ARQNackerClass: public TclClass {
public:
    ARQNackerClass() : TclClass("ARQNacker") {}
    TclObject* create(int, const char*const*) {
        return (new ARQNacker);
    }
} class_arq_nacker;

void ARQHandler::handle(Event* e) 
{
    arq_tx_.resume();
} 

ARQTx::ARQTx() : arqh_(*this)
{
    num_rtxs_ = 0;    retry_limit_ = 0; handler_ = 0;    
    pkt_ = 0; status_ = IDLE; blocked_ = 0;
    bind("retry_limit_", &retry_limit_);
}

void ARQTx::recv(Packet* p, Handler* h)
{
    if (status_!=IDLE) {
        fprintf(stderr,"Error at ARQTx::recv, a packet is received when the status is not IDLE\n");
        abort();
    }
    if (h != 0) 
        handler_ = h;
    status_ = SENT;
    if (&arqh_==0) {
        fprintf(stderr, "Error at ARQTx::recv, Cannot transmit when &arqh_ is Null\n");
        abort();
    }
    blocked_ = 1;
    send(p,&arqh_);
}

void ARQTx::ack()
{
    if (status_!=SENT) {
        fprintf(stderr,"Error at ARQTx::ack, an ACK is received when the status is not SENT\n");
        abort();
    }
    num_rtxs_ = 0; status_ = ACKED;
    if (!blocked_) {
        if (handler_ == 0) {
            fprintf(stderr,"Error at ARQTx::ack, handler_ is null\n");
            abort();
        }
        status_ = IDLE;    handler_->handle(0);
    } 
}

void ARQTx::nack(Packet* p)
{
    if (status_!=SENT) {
        fprintf(stderr,"Error at ARQTx::nack, a NACK is received when the status is not SENT\n");
        abort();
    }
    num_rtxs_++;
    if( num_rtxs_ <= retry_limit_) {
        if (!blocked_) {
            status_ = SENT;
            if (&arqh_==0) {
                fprintf(stderr, "Error at ARQTx::nack, Cannot transmit when &arqh_ is Null\n");
                abort();
            }
            pkt_ = 0; blocked_ = 1;
            send(p,&arqh_);
        } else {
            pkt_ = p;
            status_ = RTX;
        }
    } else {
        if (!blocked_) {
            status_ = IDLE;
            if (handler_ == 0) {
                fprintf(stderr,"Error at ARQTx::nack, handler_ is null\n");
                abort();
            }
            pkt_ = 0; drop(p);
            handler_->handle(0);
        } else {
            pkt_ = p;
            status_ = DROP;
        }
    }
}

void ARQTx::resume()
{
    blocked_ = 0;
    if ( status_ == ACKED ) {
        if (handler_ == 0) {
            fprintf(stderr,"Error at ARQTx::resume, handler_ is null\n");
            abort();
        }
        status_ = IDLE; handler_->handle(0);
    } else if ( status_ == RTX ) {
        if (&arqh_==0) {
            fprintf(stderr, "Error at ARQTx::resume, Cannot transmit when &arqh_ is Null\n");
            abort();
        }
        status_ = SENT; blocked_ = 1;
        send(pkt_,&arqh_);
    } else if ( status_ == DROP ) {
        if (handler_ == 0) {
            fprintf(stderr,"Error at ARQTx::resume, handler_ is null\n");
            abort();
        }
        status_ = IDLE; drop(pkt_);
        handler_->handle(0);
    }
}




int ARQRx::command(int argc, const char*const* argv) 
{
    Tcl& tcl = Tcl::instance();
    if (argc == 3) {
        if (strcmp(argv[1], "attach-ARQTx") == 0) {
            if (*argv[2] == '0') {
                tcl.resultf("Cannot attach NULL ARQTx\n");
                return(TCL_ERROR);
            }
             arq_tx_ = (ARQTx*)TclObject::lookup(argv[2]);
             return(TCL_OK);
        }
        
    } return Connector::command(argc, argv);
}


//====================================================
//=============== class ARQAcker ==================
//=================================================
// void ARQAcker::recv(Packet* p, Handler* h)
// {
//     arq_tx_->ack();
//     send(p,h);
// }


//====================================================
//=============== class ARQNacker ==================
//=================================================
// void ARQNacker::recv(Packet* p, Handler* h)
// {
//     arq_tx_->nack(p);
// }


// ============== ADD FOR DELAY ======================

void ARQRx::recv(Packet* p, Handler* h)
{
    pkt_ = p; handler_ = h;
    if (delay_ > 0)
        Scheduler::instance().schedule(this, &event_, delay_);
    else
        handle(&event_);
}


//====================================================
//=============== class ARQAcker ==================
//=================================================
void ARQAcker::handle(Event* e) 
{
    arq_tx_->ack();
    send(pkt_,handler_);
}


//====================================================
//=============== class ARQNacker ==================
//=================================================
void ARQNacker::handle(Event* e) 
{
    arq_tx_->nack(pkt_);
}




/*
#include "arq.h"

static class ARQTxClass : public TclClass
{
	public : 
		ARQTxClass() : TclClass("ARQTx"){}
		TclObject * create(int,const char*const*){
			return (new ARQTx);
	}

	
}class_arq_tx;

static class ARQAckerClass : public TclClass
{

	public:
		ARQAckerClass():TclClass("ARQAcker"){}
		TclObject* create(int, const char*const*){
			return (new ARQAcker);
		}

}class_arq_acker;

static class ARQNackerClass:public TclClass
{
public:
	ARQNackerClass(): TclClass("ARQNacker"){}
	TclObject* create (int, const char*const*){
		return (new ARQNacker);
	}
	
}class_arq_nacker;


ARQTx::ARQTx() :arqh_(*this) //Constructor clase ARQTx
{
	num_rtxs_=0; retry_limit_=0; handler_=0;
	pkt_=0; status_= IDLE; blocked_=0;
	bind("retry_limit_", &retry_limit_);
}


void ARQTx::recv(Packet* p, Handler* h)
{
	handler_=h; status_=SENT; blocked_=1;
	send(p,&arqh_);
	printf("Packete recibido\n");
}

void ARQTx::ack()
{
	num_rtxs_=0; status_=ACKED;
	printf("Packete ACK \n");
}

void ARQTx::nack(Packet* p)
{
	printf("Packete NACK \n");
	num_rtxs_++;
	pkt_=p;
	if (num_rtxs_ <= retry_limit_){
		printf("NACK: intentos: %i\n", num_rtxs_);
		status_ = RTX;
	}
	else 
		printf("NACK: Dropeado");
		status_=DROP;
}

void ARQTx::resume()
{
	printf("Resume: Entro");
	blocked_=0;
	if (status_ == ACKED){
		printf("Resume: status ACKED");
		status_=IDLE; 
		handler_->handle(0);
	} else if (status_ == RTX){
		printf("Resume: status RTX");
		status_=SENT; 
		blocked_=1;
		send(pkt_,&arqh_);
	} else if (status_ == DROP){
		printf("Resume: status drop");
		status_=IDLE; drop(pkt_);
		handler_->handle(0);
	}
}


void ARQHandler::handle(Event* e)
{
	arq_tx_.resume();
}


void ARQAcker::recv(Packet* p, Handler*h)
{
	arq_tx_->ack();
	send(p,h);
}

void ARQNacker::recv(Packet* p, Handler* h)
{
	arq_tx_->nack(p);
}


int ARQRx::command (int argc, const char*const* argv)
{
	Tcl& tcl = Tcl::instance();
	if (argc == 3){
		if(strcmp(argv[1],"attach-ARQTx") == 0){
			if (*argv[2] == '0'){
				tcl.resultf("Cannot attach NULL ARQTx\n");
				return(TCL_ERROR);
			}
			arq_tx_=(ARQTx*)TclObject::lookup(argv[2]);
			return(TCL_OK);
		}

	} return Connector :: command(argc,argv);
}



*/












