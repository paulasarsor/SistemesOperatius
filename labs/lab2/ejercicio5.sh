#!/bin/bash
#EJERCICIO 5


#Comprobamos que el número de parámetros es el adecuado
if [ $# -ne 1 ]
then
    echo "Se requiere el siguiente formato: ./ejercicio5.sh <directorio>"
    exit 1
fi

#Comprobamos que el directorio existe
if [ ! -d $1 ]
then
    echo "El directorio '$1' no existe."
    exit 1
fi



directoris=$(find $1 -type d)   #rutas de los directorios
arxius=$(find $1 -type f)       #rutas de los archivos

#Creamos subdirectorios para cada extensión y movemos los archivos
for arxiu in $arxius
do
    nom=$(basename "$arxiu")
    #Los archivos sin extensión van a un subdirectorio propio
    if [[ "$nom" == *.* ]]
    then
        extension="${nom##*.}"
    else
        extension="sin_extension"
    fi
    #Si el archivo ya está en el subdirectorio de su extensión no hace falta moverlo
    if [ "$arxiu" -ef "$1/$extension/$nom" ]
    then
        continue
    fi
    #Creamos el subdirectorio de la extensión si todavía no existe
    if [ ! -d "$1/$extension" ]
    then
        mkdir "$1/$extension"
    fi
    mv "$arxiu" "$1/$extension"
done

#Eliminamos los subdirectorios originales, que deberían estar ya vacíos (de dentro hacia fuera)
for directori in $(echo "$directoris" | sort -r)
do
    if [ "$directori" != "$1" ]
    then
        rmdir "$directori" 2>/dev/null
    fi
done



echo "Archivos clasificados correctamente."



exit 0
