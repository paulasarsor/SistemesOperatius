#!/bin/bash
#EJERCICIO 6


#Comprobamos que el número de parámetros es el adecuado
if [ $# -ne 3 ]
then
    echo "Se requiere el siguiente formato: ./ejercicio6.sh <directorio> <cadena_busqueda> <cadena_reemplazo>"
    exit 1
fi

#Comprobamos que el primer parámetro existe y es un directorio
if [ ! -d $1 ]
then
    echo "El directorio '$1' no existe."
    exit 1
fi


#Buscamos y reempazamos los nombres 
echo "Realizando búsqueda y reemplazo en el nombre de archivos en '$1/' y subdirectorios..."

arxius=$(find "$1" -type f)
for arxiu in $arxius
do
    new_nom=$(echo "$arxiu" | sed "s/$2/$3/g")
    if [ "$arxiu" != "$new_nom" ]
    then
        mv "$arxiu" "$new_nom"
    fi
done

echo "Búsqueda y reemplazo completados."


exit 0
