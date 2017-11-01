###################################################
#         Congestion Control WSN                  #
#     Camilo ALejandro Medina Mondragón           #
#   medina.camilo@javeriana.edu.co                #
###################################################

BEGIN {


    contadorA=0; #30
    contadorB=0; #60
    contadorC=0; #90
    contadorD=0; #120
    contadorE=0; #150
    contadorF=0; #190
    AcumuladoA=0;
    AcumuladoB=0;
    AcumuladoC=0;
    AcumuladoD=0;
    AcumuladoE=0;
    AcumuladoF=0;

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



      if($1="N"){
    
        if($3 <361){
          if($3>360){
          EnergiaF[contadorF]=$7;
          AcumuladoF=AcumuladoF + EnergiaF[contadorF];
            contadorF++;
          }        
        }






       
      }

}
   
  END {


      #promedioA=(AcumuladoA/contadorA)*100/3.9;
      #promedioB=(AcumuladoB/contadorB)*100/3.9;
      #promedioC=(AcumuladoC/contadorC)*100/3.9;
      #promedioD=(AcumuladoD/contadorD)*100/3.9;
      #promedioE=(AcumuladoE/contadorE)*100/3.9;
      promedioF=(AcumuladoF/contadorF)*100/3.9;

      #printf "E60: %0.2f%% \n", promedioA;
      #printf "E12: %0.2f%% \n", promedioB;
      #printf "E18: %0.2f%% \n", promedioC;
      #printf "E24: %0.2f%% \n", promedioD;
      #printf "E30: %0.2f%% \n", promedioE;
      printf "E36: %0.2f%% \n", promedioF;


      #printf "Contador 30:  %i \n", contadorA;
      #printf "Contador 60:  %i \n", contadorB;
      #printf "Contador 90:  %i \n", contadorC;
      #printf "Contador 120: %i \n", contadorD;
      #printf "Contador 150: %i \n", contadorE;
      #printf "Contador 190: %i \n", contadorF;

  

  }




