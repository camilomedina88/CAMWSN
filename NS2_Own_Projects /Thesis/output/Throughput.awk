###################################################
#         Congestion Control WSN                  #
#     Camilo ALejandro Medina Mondragón           #
#   medina.camilo@javeriana.edu.co                #
###################################################

BEGIN {
       recvdSize = 0
       startTime = 30
       stopTime = 0
       totalRecv = 0
  }
   
  {
      event = $1
      time = $2
      node_id = $3
      level = $4
      packetId= $6
      type= $7
      pkt_size = $8


      event = $1;
      time = $2;
      node_id = $3;
      pkt_size = $8;
      level = $4;


  # Store start time

      if (type == "exp"){        
        if(event=="s"){      
          if(time < startTime){
            startTime=time;
          }
        }

      }
   
      if (type == "exp"){

      if (node_id == "_0_"){

      if(event=="r"){

            if(time>stopTime){
              stopTime=time;
            }


            totalRecv= totalRecv + pkt_size ;
            # Si fuera Goodput
            # hdr_size = pkt_size % 512
            #pkt_size -= hdr_size
            #recvdSize += pkt_size


        }
      }  
      }

       
  }
   
  END {

      printf "StopTime %0.2f \n", stopTime
      printf "StartTime %0.2f \n", startTime
      printf "Total Recividos %0.2f \n", totalRecv

      Throghput=totalRecv/(stopTime - startTime)*(8/1000);
      printf "Average Throughput[kbps]: %0.2f \n", Throghput;

       #printf("Average Throughput[kbps] = %.2f\t\t StartTime=%.2f\tStopTime=%.2f\n",(recvdSize/(stopTime-startTime))*(8/1000),startTime,stopTime)
  }