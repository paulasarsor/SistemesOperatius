#!/bin/bash
#EJERCICIO 2


#Comprobamos que el número de parámetros es el adecuado
if [ $# -ne 1 ]
then
    echo "Se requiere el siguiente formato: ./ejercicio2.sh <directorio>"
    exit 1
fi

#Comprobamos que el directorio existe
if [ ! -d $1 ]
then
    echo "El directorio '$1' no existe."
    exit 1
fi


#Contamos el número total de archivos y directorios en el directorio dado (si quisiéramos solo los primeros usaríamos -maxdepth 1)
echo "Cantidad de archivos: $(find $1 -type f | wc -l)"
echo "Cantidad de directorios: $(find $1 -type d | wc -l)"


exit 0
