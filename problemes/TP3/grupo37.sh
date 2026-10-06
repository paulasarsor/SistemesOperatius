#!/bin/bash
#PROBLEMA EVALUABLE 2


#Comprobamos que el número de parámetros es correcto
if [ $# -ne 1 ] && [ $# -ne 2 ]
then
	echo "El formato tiene que ser de la forma ./exercici.sh <directorio> [regexp]"
	exit 1
fi


#Comprobamos que el primer parámetro es un directorio y existe
if [ ! -d $1 ]
then
	echo "$1 no existe o no es un directorio"
	exit 1
fi


#Recorremos todos los directorios para contar los archivos deseados
directoris=$(find $1 -type d)

for directori in $directoris
do
	if [ $# -eq 1 ]
	then
		echo "directorio: $directori nfiles: $(find $directori -type f | wc -l)"
	else
		echo "directorio: $directori nfiles: $(ls $directori | grep -E "$2" | wc -l)"
	fi
done

exit 0
