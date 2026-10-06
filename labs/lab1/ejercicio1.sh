#!/bin/bash
#Ejercicio 1


#Comprovem que s'ha introduit el nombre necesssari d'arguments
if [ $# -ne 2 ]
then 
	echo "Se requiere el siguiente formato: ./ejercicio1.sh <archivo1> <archivo2>"
	exit 1
fi


#Comprovem que els dos fixters existeixen
if [ ! -f $1 ] || [ ! -f $2 ]
then
	echo "Al menos uno de los archivos no existe."
	exit 1
fi


#Imprimim el tamany dels fitxers donats
var=$(ls -l $1 | awk '{print $5}')
echo "Tamaño del archivo $1: $var bytes"
var=$(ls -l $2 | awk '{print $5}')
echo "Tamaño del archivo $2: $var bytes"


#Concatenem els fitxers
cat $1 $2 > concatenados.txt

#Imprimim nou tamany
var=$(ls -l concatenados.txt | awk '{print $5}')
echo "Tamaño del archivo concatenado: $var bytes"


exit 0
