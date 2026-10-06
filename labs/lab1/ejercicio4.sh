#!/bin/bash
#Ejercicio 4


#Comprobamos el número de parámetros es correcto
if [ $# -ne 1 ]
then
	echo "Se requiere el siguiente formato: ./ejercicio4.sh <cadena>"
	exit 1
fi


#Comprobamos si la variable es un número
if [[ "$1" =~ ^[0-9]+$ ]]   #El + significa que no es una cadena vacía y tiene cualquier longitud
then
        echo "La cadena es un número."
        exit 1
fi


#Longitud de la cadena
echo "Longitud de la cadena: ${#1}"

#Mostrar la cadena en mayúsculas
echo "Cadena en mayúsculas: ${1^^}"


exit 0
