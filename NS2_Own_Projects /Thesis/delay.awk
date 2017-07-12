BEGIN {
sent=0;
received=0;
start_time = 0;
}
{
time = $2;
  if(($1=="s"))
   {
    sent++;
   }
  else if(($1=="r"))
   {
     received++;
   }
  else if(($1=="f"))
   {
     forward++;
   }

start_time = time;
a=(sent/received);
if(a != "-nan" && a !="inf" && start_time >0)
{


printf "%f\t%.2f\n",start_time,((sent/received));
}
}

