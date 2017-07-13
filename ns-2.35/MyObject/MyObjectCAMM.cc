#include "MyObjectCAMM.h"
#include <stdio.h>
#include <iostream>
using namespace std;


static class MyObjectCAMMClass : public TclClass {
public:
    MyObjectCAMMClass() : TclClass("MyObjectCAMM") {} 
    TclObject* create(int, const char*const*) {
        return (new MyObjectCAMM());
    }
}  class_my_object;




MyObjectCAMM::MyObjectCAMM (){

	printf(" Hello From the other side \n");
	bind("my_otcl_val_",&my_c_var_);
	my_c_var_;
	


}

int MyObjectCAMM::command(int argc, const char*const* argv){


	Tcl& tcl = Tcl::instance();
	//tcl.evalc("set val");
	//const char* value =tcl.result();

	if(argc==2){

		if(strcmp(argv[1],"print-variable")==0){
			//Tcl& tcl=Tcl::instance();

			//cout<<"---------------------"<<endl;
			tcl.resultf("%d",my_c_var_);			
			//cout<<my_c_var_<<endl;
			//cout<<"---------------------"<<endl;

			//cout<<"Valor de la variable: "<<testVariable<<endl;
			return TCL_OK;

		}




	}

	//return (NsObject::command(argc,argv));
	


}
