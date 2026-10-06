#!/bin/bash
#Ejercicio 2


#Comprovem que s'ha introduit el nombre necesssari d'arguments
if [ $# -ne 2 ]
then
        echo "Se requiere el siguiente formato: ./ejercicio2.sh <archivo> <permisos_octales>"
        exit 1
fi

#Comprovem que el fitxer existeix
if [ ! -e "$1" ]
then
        echo "El archivo '$1' no existe."
        exit 1
fi

#Comprovem que s'ha introduit un permis octal valid
if [[ ! "$2" =~ ^[0-7]{3}$ ]]
then 
        echo "Los permisos deben ser un código numérico (octal) de tres dígitos."
        exit 1
fi


#Imprimim els permisos actuals
per=$(ls -l $1 | awk '{print $1}')
echo "Permisos actuales de $1: $per"

#Canviem els permisos
chmod $2 $1

#Imprimim els nous permisos
per=$(ls -l $1 | awk '{print $1}')
echo "Nuevos permisos de $1: $per"


exit 0
