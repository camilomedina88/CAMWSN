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


        if($3 <61){
          if($3>60){

            EnergiaA[contadorA]=$7;
            AcumuladoA=AcumuladoA + EnergiaA[contadorA];
            contadorA++;
          }        
        }

        if($3 <121){
          if($3>120){
            EnergiaB[contadorB]=$7;
            AcumuladoB=AcumuladoB + EnergiaB[contadorB];
            contadorB++;
          }        
        }

      if($3 <181){
          if($3>180){
          EnergiaC[contadorC]=$7;
          AcumuladoC=AcumuladoC + EnergiaC[contadorC];
            contadorC++;
          }        
        }

      if($3 <241){
          if($3>240){
          EnergiaD[contadorD]=$7;
          AcumuladoD=AcumuladoD + EnergiaD[contadorD];
            contadorD++;
          }        
        }

        if($3 <301){
          if($3>300){
          EnergiaE[contadorE]=$7;
          AcumuladoE=AcumuladoE + EnergiaE[contadorE];
            contadorE++;
          }        
        }

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


      promedioA=(AcumuladoA/contadorA)*100/3.9;
      promedioB=(AcumuladoB/contadorB)*100/3.9;
      promedioC=(AcumuladoC/contadorC)*100/3.9;
      promedioD=(AcumuladoD/contadorD)*100/3.9;
      promedioE=(AcumuladoE/contadorE)*100/3.9;
      promedioF=(AcumuladoF/contadorF)*100/3.9;

      printf "Energia en 60  seg:       %0.2f%% \n", promedioA;
      printf "Energia en 120 seg:       %0.2f%% \n", promedioB;
      printf "Energia en 180 seg:       %0.2f%% \n", promedioC;
      printf "Energia en 240 seg:       %0.2f%% \n", promedioD;
      printf "Energia en 300 seg:       %0.2f%% \n", promedioE;
      printf "Energia en 360 seg:       %0.2f%% \n", promedioF;


      #printf "Contador 30:  %i \n", contadorA;
      #printf "Contador 60:  %i \n", contadorB;
      #printf "Contador 90:  %i \n", contadorC;
      #printf "Contador 120: %i \n", contadorD;
      #printf "Contador 150: %i \n", contadorE;
      #printf "Contador 190: %i \n", contadorF;

  

  }




