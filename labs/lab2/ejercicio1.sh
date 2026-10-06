#!/bin/bash
#EJERCICIO 1


#Comprobamos que el número de parámetros es el adecuado
if [ $# -ne 1 ]
then
    echo "Se requiere el siguiente formato: ./ejercicio1.sh <archivo_log>"
    exit 1
fi

#Comprobamos que el archivo existe
if [ ! -f $1 ]
then
    echo "El archivo de registro '$1' no existe."
    exit 1
fi


#Como sabemos el formato del archivo de registro, solo hace falta contar el número de líneas en las que aparece la cadena ERROR y WARNING
echo "Errores encontrados: $(grep ERROR $1 | wc -l)"
echo "Advertencias encontradas: $(grep WARNING $1 | wc -l)"


exit 0
