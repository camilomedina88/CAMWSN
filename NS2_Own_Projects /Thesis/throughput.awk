BEGIN {
recvdSize = 0
txsize=0
drpSize=0
startTime = 400
stopTime = 0
goodput=0

}

{
event = $1
time = $2
N_id = $3
Pak_size = $8
level = $4

if (level == "AGT" && event == "s" && time >0 ) {
if (time < startTime) {
startTime = time
}

txsize++;

}

if (level == "RTR" && event == "r" && time >0) {
if (time > stopTime) {
stopTime = time
}
recvdSize++
goodput=(recvdSize/txsize)
printf(" %.2f %.2f \n" ,time,goodput)

}

}
END {
}


