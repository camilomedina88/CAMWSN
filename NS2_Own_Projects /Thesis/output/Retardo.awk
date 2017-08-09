###################################################
#        	Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#		medina.camilo@javeriana.edu.co            #
###################################################


BEGIN {	
	
	num_recv =0;
	analizado=0;
	acumulado=0;
	

}

{

	event = $1;
	time = $2;
	node_id = $3;
	level = $4;
	Flags =$5;
	packetId= $6;
	type= $7;
	pkt_size = $8;
	destination =$10;
	Energy = $14;
	
	
	#Guardar Paquet Send time

	if(type == "exp"){
		if (event == "s"){
			if (destination="0"){
			 

			 sendTime[packetId]= time;
			 #printf "+ %i Enviado at: %f \n", packetId, sendTime[packetId];
			}
		}
	}


	# Guardar Paquet Recv Time

	if(type == "exp"){

		if (event == "r"){

				if(node_id =="_0_"){

					if (time != "0.0"){

					recvTime[packetId]= time;
					#printf "- %i recibido at: %f \n", packetId, recvTime[packetId];

					num_recv =packetId;

					}

					
				}
		}
	}
	
	


}

END{

	jitter1 = jitter2 = jitter3 = jitter4 = tmp_recv = 0;
	prev_time = delay = prev_delay = processed = currTime = 0;
	prev_delay = -1;


		for (i=0; processed <=num_recv; i++){

			if (recvTime[i]!="0"){

			diferencia=recvTime[i]-sendTime[i];
			printf "%i enviado at: %f \n", i, sendTime[i];
			printf "%i recibido at: %f \n", i, recvTime[i];
			printf "Diferencia: %f \n", diferencia;
			acumulado= acumulado + diferencia;

			analizado++;

			}
		processed ++;
		
		}

		printf "Recibidos: %i \n", num_recv;
		printf "Analizado: %i \n", analizado;
		printf "Acumulado: %0.4f \n", acumulado;

		retardo= acumulado/analizado;
		printf "Acumulado: %0.4f \n" , retardo;

			

}


function abs(value) {
	if (value < 0) value = 0-value
	return value
}