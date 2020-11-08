#!/bin/bash

#Elaborado por Neyder Figueroa,Andres Llinas, Daniel Bonilla

#TODO:  DESARROLLO AL 95%, falta cuadrar el icono y revisar el tema de los errores

export DISPLAY=:0


if [ ! -f cpuMonitor.log ] #se crea el log
    then
        touch cpuMonitor.log
fi

dateLog=$(date)

#cpus=$(lscpu | grep 'Core(s) per socket' |awk '{print $4}') #coje los reales

cpus=$(lscpu | grep 'CPU(s):' | head -1 |awk '{print $2}') #alternativa coje todos los nucleos

averageAux0=$(uptime)
averageAux1=$(echo $averageAux0 |awk '{print $8}'| cut -d',' -f1)
averageAux2=$(echo $averageAux0 |awk '{print $8}'| cut -d',' -f2)

average="$averageAux1.$averageAux2"
usedCPUPercentage=$(echo "scale=2; $average/$cpus *100" | bc)

echo "->Número de nucleos: $cpus"
echo "->Average: "$average
echo "->Porcentaje de uso: $usedCPUPercentage%"

processProblem=$(top -n1 -b | head -8| tail -1| awk '{print $12}')
event="niguno"

if [ $(echo "$usedCPUPercentage > 10.00" | bc) -eq 1 ]
then
    notify-send --icon=message_box_info -t 5000000 "ALERTA ALTO CONSUMO DE CPU" "\nCUIDADO CON EL PROCESO $processProblem " #buscar lo adecuado
    event="alto consumo"
fi

if [[ $event == "niguno" ]] 
then
    echo "_CPU en uso: $usedCPUPercentage% Evento: $event  Fecha: $dateLog Proceso: $processProblem ">>cpuMonitor.log
else
    echo "_CPU en uso: $usedCPUPercentage% Evento: $event  Fecha: $dateLog">>cpuMonitor.log

fi