#!/bin/bash
#Ejercicio 3


#Comprovem que s'ha introduit el nombre necesssari d'arguments
if [ $# -ne 1 ]
then 
	echo "Se requiere el siguiente formato: ./ejercicio3.sh <número>"
	exit 1
fi


#Creem la taula
for (( i = 1; i <= 10; i++ ))
do
	echo "$1 x $i = $(($1*$i))"
done

exit 0
