#!/bin/bash

#Elaborado por Neyder Figueroa,Andres Llinas, Daniel Bonilla

#TODO:  DESARROLLO AL 95%, falta cuadrar el icono y revisar el tema de los errores

export DISPLAY=:0


if [ ! -f ramState.log ] #se crea el log
    then
        touch ramState.log
fi


dateLog=$(date)

totalMemory=$(free | head -2 |tail -1| awk '{print $2}')

usedMemory=$(free | head -2 |tail -1| awk '{print $3}')

usedMemoryPercentage=$(echo "scale=2; ($usedMemory*100)/$totalMemory" | bc) #calcula el porcentaje de uso

processProblem=$(ps -Ao pmem,comm |sort|tail -2 |head -1 |awk '{print $2}') #arroja el processo que esta consumiendo mas memoria


echo "-> memoria total en KB ${totalMemory}"
echo "-> memoria usada en KB ${usedMemory}"
echo "-> porcentaje de memoria usada: $usedMemoryPercentage %"
echo "-> proceso que mas consume: $processProblem "


condition0=$(echo "$usedMemoryPercentage > 75.00" | bc) #porcentaje para el caso 1
condition1=$(echo "$usedMemoryPercentage > 20.00" | bc) #porcentaje para el caso 2
condition2=$(echo "$usedMemoryPercentage < 22.38" | bc) #porcetaje para el caso 2

alert="No aplica"

if [[ $condition2 -eq 1 && $condition1 -eq 1 ]]
    then
        notify-send --icon=message_box_info -t 5000000 "ALERTA ALTO CONSUMO DE MEMORIA" "\n$usedMemoryPercentage% alcanzado"  #buscar lo adecuado
        alert="caso 2"
    else
        if [ $condition0 -eq 1 ]
        then
            notify-send --icon=message_box_info -t 5000000 "ALERTA ALTO CONSUMO DE MEMORIA" "\nCUIDADO CON EL PROCESO $processProblem " #buscar lo adecuado
            alert="caso 1"
        fi
    
fi


if [ $condition0 -eq 1 ] 
then
    echo "_Memoria en uso: $usedMemoryPercentage% Tipo caso: $alert  Fecha: $dateLog Proceso: $processProblem ">>ramState.log
else
    echo "_Memoria en uso: $usedMemoryPercentage% Tipo caso: $alert  Fecha: $dateLog">>ramState.log

fi

    

