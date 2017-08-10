###################################################
#        	Congestion Control WSN                #
#     Camilo ALejandro Medina Mondragón           #
#		medina.camilo@javeriana.edu.co            #
###################################################

# Se calcula con la diferencia entre Tx y Rx no con paquetes DROP

BEGIN {	
	enviado=0;
	drop=0;
	recibidos=0;
	perdidos=0;
	porcentajePerdidos=0;

	

}

{

	event = $1
	time = $2
	node_id = $3
	level = $4

	packetId= $6
	type= $7
	pkt_size = $8
	
	if ($1=="s"){
		if($7=="exp"){
			enviado++;
		}
	}


	if ($1=="r"){
		if($7=="exp"){
			recibidos++;
		}
		
	}

	if ($1=="D")
		drop++;


}

END{

	perdidos=enviado-recibidos;
	porcentajePerdidos=(perdidos/enviado)*100;


	#printf "Enviados: %i \n", enviado;
	#printf "Recibidos: %i \n", recibidos;
	#printf "Drop: %i \n", drop;
	printf  "Porcentaje Perdidos: %f \n", porcentajePerdidos;




	

}