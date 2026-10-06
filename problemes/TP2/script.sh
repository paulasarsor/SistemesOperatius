#!/bin/bash

if [ $# -ne 1 ]
then 
    echo "Nombre incorrecte de parametres"
    exit 1
fi

directori=$1

ls -l "$directori" > aux.txt
bytes=($(awk '{print $5}' aux.txt)) 

len=${#bytes[*]}

i=0
sum=0

while [ $i -lt $len ]
do
  	sum=$(($sum+${bytes[$i]}))
  	(( i++ ))
done

echo $sum


rm aux.txt

exit 0
