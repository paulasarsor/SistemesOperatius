#!/bin/bash
#EJERCICIO 4 (funciona pero imprime fea la lista)


#Creamos la interfaz interactiva
echo "=== Monitor de Recursos Interactivo ==="
echo ""
    #ps -u
ps --sort=-%cpu -o "pid,user,%cpu,command"
echo ""
read -p "Seleccione el PID del proceso para realizar acciones (o presione Enter para salir):" pid

if [[ ! "$pid" =~ ^[0-9]+ ]]        #if [ pid -eq NULL ]  funciona?
then
    exit 0
fi

#Leemos la acción
read -p "Acciones disponibles: (1) Detener proceso / (2) Cambiar prioridad:" action


#Acción 1
if [ $action == 1 ]
then
    kill $pid
    echo "Proceso $pid detenido."
    exit 0
fi

#Acción 2
if [ $action == 2 ]
then
    read -p "Ingrese la nueva prioridad (número):" new_prioridad
    renice $new_prioridad -p $pid
    echo "Prioridad del proceso $pid cambiada a $new_prioridad."
    exit 0
fi

#Por si acaso
echo "No se ha introducido una acción válida"
exit 1
