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
    for (i=0; i <=100; i++){
      sendTime[i]==0;
    }

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

              if(node_id == "_9_"){
                if(sendTime[9]==0.0){
                  sendTime[9]= time;}
              }

              if(node_id == "_13_"){
                if(sendTime[13]==0){
                  sendTime[13]= time;}
              }

              if(node_id == "_26_"){
                if(sendTime[26]==0){
                  sendTime[26]= time;}
              }

              if(node_id == "_31_"){
                if(sendTime[31]==0){
                  sendTime[31]= time;}
              }

              if(node_id == "_35_"){
                if(sendTime[35]==0){
                  sendTime[35]= time;}
              }

              if(node_id == "_37_"){
                if(sendTime[37]==0){
                  sendTime[37]= time;}
              }

              if(node_id == "_40_"){
                if(sendTime[40]==0){
                  sendTime[40]= time;}
              }

              if(node_id == "_45_"){
                if(sendTime[45]==0){
                  sendTime[45]= time;}
              }

              if(node_id == "_59_"){
                if(sendTime[59]==0){
                  sendTime[59]= time;}
              }

              if(node_id == "_67_"){
                if(sendTime[67]==0){
                  sendTime[67]= time;}
              }

              if(node_id == "_93_"){
                if(sendTime[93]==0){
                  sendTime[93]= time;}
              }

              if(node_id == "_99_"){
                if(sendTime[99]==0){
                  sendTime[99]= time;}
              }

              if(node_id == "_83_"){
                if(sendTime[83]==0){
                  sendTime[83]= time;}
              }

              if(node_id == "_10_"){
                if(sendTime[10]==0){
                  sendTime[10]= time;}
              }

              if(node_id == "_12_"){
                if(sendTime[12]==0){
                  sendTime[12]= time;}
              }

              if(node_id == "_46_"){
                if(sendTime[46]==0){
                  sendTime[46]= time;}
              }

              if(node_id == "_50_"){
                if(sendTime[50]==0){
                  sendTime[50]= time;}
              }

              if(node_id == "_75_"){
                if(sendTime[75]==0){
                  sendTime[75]= time;}
              }

              if(node_id == "_28_"){
                if(sendTime[28]==0){
                  sendTime[28]= time;}
              }

              if(node_id == "_55_"){
                if(sendTime[55]==0){
                  sendTime[55]= time;}
              }

              if(node_id == "_73_"){
                if(sendTime[73]==0){
                  sendTime[73]= time;}
              }

              if(node_id == "_84_"){
                if(sendTime[84]==0){
                  sendTime[84]= time;}
              }

              if(node_id == "_61_"){
                if(sendTime[61]==0){
                  sendTime[61]= time;}
              }            
          }
        }
      }


      # Guardar Paquet Recv Time
      if(type == "exp"){
        if (event == "r"){
            if(node_id =="_0_"){ 

              if($24 == "[9:0"){ 
                  recvTime[9]= time; 
                  bitsRecibidos[9]=bitsRecibidos[9]+ pkt_size;
                  }
              if($24 == "[13:0"){ 
                  recvTime[13]= time; 
                  bitsRecibidos[13]= bitsRecibidos[13] + pkt_size;
                  } 
              if($24 == "[26:0"){ 
                  recvTime[26]= time; 
                  bitsRecibidos[26]=bitsRecibidos[26] + pkt_size;
                  } 
              if($24 == "[31:0"){ 
                  recvTime[31]= time; 
                  bitsRecibidos[31]=bitsRecibidos[31] + pkt_size;
                  } 

              if($24 == "[35:0"){ 
                  recvTime[35]= time; 
                  bitsRecibidos[35]=bitsRecibidos[35] + pkt_size
                  } 
              if($24 == "[37:0"){ 
                  recvTime[37]= time; 
                  bitsRecibidos[37]=bitsRecibidos[37] + pkt_size;
                  } 
              if($24 == "[40:0"){ 
                  recvTime[40]= time; 
                  bitsRecibidos[40]=bitsRecibidos[40] + pkt_size;
                  } 
              if($24 == "[45:0"){ 
                  recvTime[45]= time; 
                  bitsRecibidos[45]=bitsRecibidos[45] + pkt_size;
                  } 
              if($24 == "[59:0"){ 
                  recvTime[59]= time; 
                  bitsRecibidos[59]=bitsRecibidos[59] + pkt_size;
                  } 
              if($24 == "[67:0"){ 
                  recvTime[67]= time; 
                  bitsRecibidos[67]=bitsRecibidos[67] + pkt_size;
                  } 
              if($24 == "[93:0"){ 
                  recvTime[93]= time; 
                  bitsRecibidos[93]=bitsRecibidos[93] + pkt_size;
                  } 
              if($24 == "[99:0"){ 
                  recvTime[99]= time; 
                  bitsRecibidos[99]=bitsRecibidos[99] + pkt_size;
                  }
              if($24 == "[83:0"){ 
                  recvTime[83]= time; 
                  bitsRecibidos[83]=bitsRecibidos[83] + pkt_size;
                  }
              if($24 == "[10:0"){ 
                  recvTime[10]= time; 
                  bitsRecibidos[10]=bitsRecibidos[10] + pkt_size;
                  } 
              if($24 == "[12:0"){ 
                  recvTime[12]= time; 
                  bitsRecibidos[12]=bitsRecibidos[12] + pkt_size;
                  } 
              if($24 == "[46:0"){ 
                  recvTime[46]= time; 
                  bitsRecibidos[46]=bitsRecibidos[46] + pkt_size;
                  } 
              if($24 == "[50:0"){ 
                  recvTime[50]= time; 
                  bitsRecibidos[50]=bitsRecibidos[50] + pkt_size;
                  } 
              if($24 == "[75:0"){ 
                  recvTime[75]= time; 
                  bitsRecibidos[75]=bitsRecibidos[75] + pkt_size;
                  } 
              if($24 == "[28:0"){ 
                  recvTime[28]= time; 
                  bitsRecibidos[28]=bitsRecibidos[28] + pkt_size;
                  } 
              if($24 == "[55:0"){ 
                  recvTime[55]= time; 
                  bitsRecibidos[55]=bitsRecibidos[55] + pkt_size;
                  } 
              if($24 == "[73:0"){ 
                  recvTime[73]= time; 
                  bitsRecibidos[73]=bitsRecibidos[73] + pkt_size;
                  } 
              if($24 == "[84:0"){ 
                  recvTime[84]= time; 
                  bitsRecibidos[84]=bitsRecibidos[84] + pkt_size;
                  } 
              if($24 == "[61:0"){ 
                  recvTime[61]= time; 
                  bitsRecibidos[61]=bitsRecibidos[61] + pkt_size;
                  } 
            }
        }
      }

       
  }
   
  END {


    #Calculo del Throughput
      for (i=0; i <=100; i++){
        if (recvTime[i]!=0.0){
            Throughput[i]=(bitsRecibidos[i]/abs(recvTime[i]-sendTime[i]))*8/1000;
            #Throughput[i]=13;
            #printf "Paquete %i Throughput: %0.2f \n", i, Throughput[i];
            sumarThroughput++;            
        }     
      }

    ##############################################################
    Calculo Fairness
      for (i=0; i <=100; i++){
        numerador= numerador + Throughput[i];
      }

      for (i=0; i <=100; i++){
        denominador= denominador +(Throughput[i]*Throughput[i]);
      }

      fairnessIndex=(numerador*numerador)/(23*denominador)


      printf "Fai: %0.3f \n", fairnessIndex


      printf " \n"
      printf "TFA: %0.3f \n", numerador

      printf "N09: %0.3f\n" , Throughput[9]
      printf "N13: %0.3f\n" , Throughput[13] 
      printf "N26: %0.3f\n" , Throughput[26] 
      printf "N31: %0.3f\n" , Throughput[31] 
      printf "N35: %0.3f\n" , Throughput[35] 
      printf "N37: %0.3f\n" , Throughput[37] 
      printf "N40: %0.3f\n" , Throughput[40] 
      printf "N45: %0.3f\n" , Throughput[45] 
      printf "N54: %0.3f\n" , Throughput[54] 
      printf "N67: %0.3f\n" , Throughput[67] 
      printf "N93: %0.3f\n" , Throughput[93] 
      printf "N99: %0.3f\n" , Throughput[99] 
      printf "N83: %0.3f\n" , Throughput[83] 
      printf "N10: %0.3f\n" , Throughput[10] 
      printf "N12: %0.3f\n" , Throughput[12] 
      printf "N46: %0.3f\n" , Throughput[46] 
      printf "N50: %0.3f\n" , Throughput[50] 
      printf "N75: %0.3f\n" , Throughput[75] 
      printf "N28: %0.3f\n" , Throughput[28] 
      printf "N55: %0.3f\n" , Throughput[55] 
      printf "N73: %0.3f\n" , Throughput[73] 
      printf "N84: %0.3f\n" , Throughput[84] 
      printf "N61: %0.3f\n" , Throughput[61] 

  }

  function abs(value) {
  if (value < 0) value = 0-value
  return value
}