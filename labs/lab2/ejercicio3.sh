#!/bin/bash
#EJERCICIO 3


#Comprobamos que el número de parámetros es el adecuado
if [ $# -ne 3 ]
then
    echo "Se requiere el siguiente formato: ./ejercicio3.sh <directorio> <patron> <reemplazo>"
    exit 1
fi

#Comprobamos que el directorio existe
if [ ! -d $1 ]
then
    echo "El directorio '$1' no existe."
    exit 1
fi


#Buscamos y reemplazamos
find $1 -type f -exec sed -i "s/$2/$3/g" {} \;
echo "Archivos actualizados"


exit 0
