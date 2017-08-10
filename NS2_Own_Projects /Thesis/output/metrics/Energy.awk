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


        if($3 <31){
          if($3>30){

            EnergiaA[contadorA]=$7;
            AcumuladoA=AcumuladoA + EnergiaA[contadorA];
            contadorA++;
          }        
        }

        if($3 <61){
          if($3>60){
            EnergiaB[contadorB]=$7;
            AcumuladoB=AcumuladoB + EnergiaB[contadorB];
            contadorB++;
          }        
        }

      if($3 <91){
          if($3>90){
          EnergiaC[contadorC]=$7;
          AcumuladoC=AcumuladoC + EnergiaC[contadorC];
            contadorC++;
          }        
        }

      if($3 <121){
          if($3>120){
          EnergiaD[contadorD]=$7;
          AcumuladoD=AcumuladoD + EnergiaD[contadorD];
            contadorD++;
          }        
        }

        if($3 <151){
          if($3>150){
          EnergiaE[contadorE]=$7;
          AcumuladoE=AcumuladoE + EnergiaE[contadorE];
            contadorE++;
          }        
        }

        if($3 <191){
          if($3>190){
          EnergiaF[contadorF]=$7;
          AcumuladoF=AcumuladoF + EnergiaF[contadorF];
            contadorF++;
          }        
        }






       
      }

}
   
  END {


      promedioA=(AcumuladoA/contadorA)*100/50;
      promedioB=(AcumuladoB/contadorB)*100/50;
      promedioC=(AcumuladoC/contadorC)*100/50;
      promedioD=(AcumuladoD/contadorD)*100/50;
      promedioE=(AcumuladoE/contadorE)*100/50;
      promedioF=(AcumuladoF/contadorF)*100/50;

      printf "Energia en 30  seg: %0.1f%% \n", promedioA;
      printf "Energia en 60  seg: %0.1f%% \n", promedioB;
      printf "Energia en 90  seg: %0.1f%% \n", promedioC;
      printf "Energia en 120 seg: %0.1f%% \n", promedioD;
      printf "Energia en 150 seg: %0.1f%% \n", promedioE;
      printf "Energia en 190 seg: %0.1f%% \n", promedioF;


      #printf "Contador 30:  %i \n", contadorA;
      #printf "Contador 60:  %i \n", contadorB;
      #printf "Contador 90:  %i \n", contadorC;
      #printf "Contador 120: %i \n", contadorD;
      #printf "Contador 150: %i \n", contadorE;
      #printf "Contador 190: %i \n", contadorF;

  

  }



