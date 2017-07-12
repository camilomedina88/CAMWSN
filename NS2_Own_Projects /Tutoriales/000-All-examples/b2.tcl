 
SELECT Validation Test: 

 A "triangle" consisting of three ASes.  Each AS has one
 BGP-speaking router.  Each router is connected directly to
 the routers in each neighboring AS.

    AS----AS 
     \    /  
      \  /   
       AS    

Simulation starts...

 time: 0.25 
 n0 (ip_addr 10.0.0.1)  defines a network 10.0.0.0/24.

 time: 0.35 
 n1 (ip_addr 10.0.1.1)  defines a network 10.0.1.0/24.

 time: 0.45 
 n2 (ip_addr 10.0.2.1)  defines a network 10.0.2.0/24.

 time: 39  
 dump routing tables in all BGP agents: 

BGP routing table of n0
BGP table version is 4, local router ID is 10.0.0.1
Status codes: * valid, > best, i - internal.
     Network            Next Hop       Metric  LocPrf  Weight Path 
*>   10.0.0.0/24        self                  -      -      -          
*>   10.0.1.0/24        10.0.1.1/32           -      -      - 1        
*>   10.0.2.0/24        10.0.2.1/32           -      -      - 2        

BGP routing table of n1
BGP table version is 6, local router ID is 10.0.1.1
Status codes: * valid, > best, i - internal.
     Network            Next Hop       Metric  LocPrf  Weight Path 
*>   10.0.0.0/24        10.0.0.1/32           -      -      - 0        
*>   10.0.1.0/24        self                  -      -      -          
*>   10.0.2.0/24        10.0.2.1/32           -      -      - 2        

BGP routing table of n2
BGP table version is 6, local router ID is 10.0.2.1
Status codes: * valid, > best, i - internal.
     Network            Next Hop       Metric  LocPrf  Weight Path 
*>   10.0.0.0/24        10.0.0.1/32           -      -      - 0        
*>   10.0.1.0/24        10.0.1.1/32           -      -      - 1        
*>   10.0.2.0/24        self                  -      -      -          

Simulation finished. Executing nam...