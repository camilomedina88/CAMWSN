###################################################
#         Congestion Control WSN                  #
#     Camilo ALejandro Medina Mondragón           #
#   medina.camilo@javeriana.edu.co                #
###################################################

BEGIN {


    num_recv =0;
    analizado=0;
    acumulado=0;
    startTime=0;
    numerador=0;
    denominador=0;
    sumarThroughput=0;


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
              recvTime[packetId]= time;
              bitsRecibidos[packetId]=pkt_size;
              #printf "- %i recibido at: %f \n", bitsRecibidos[packetId] , recvTime[packetId];
              num_recv =packetId; 
              analizado++;        
            }
        }
      }

       
  }
   
  END {


    #Calculo del Throughput
      for (i=0; processed <=num_recv; i++){
        if (recvTime[i]!=0.0){

            Throughput[i]=(bitsRecibidos[i]/abs(recvTime[i]-sendTime[i]))*8/1000;
            #Throughput[i]=13;
            #printf "Paquete %i Throughput: %0.2f \n", i, Throughput[i];
            sumarThroughput++;
            
        }
        processed ++;
      
      }

    #Calculo Fairness

      for (i=0; calculado <=num_recv; i++){
       
            numerador=numerador+ Throughput[i];
            denominador=denominador + (Throughput[i]*Throughput[i]);   
            calculado ++;
      }


      fairnessIndex=(numerador*numerador)/(sumarThroughput*denominador)
      #printf "Numerador: %0.2f \n", numerador
      #printf "Denominador: %0.2f \n", denominador
      #printf "Procesados: %0.2f \n", sumarThroughput

      printf "Indice Fairness:           %0.3f \n", fairnessIndex

  }


  function abs(value) {
  if (value < 0) value = 0-value
  return value
}