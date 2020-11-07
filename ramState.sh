#!/bin/bash

#Elaborado por Neyder Figueroa,Andres Llinas, Daniel Bonilla



#totalMemory=$(top|head -4| tail -1 | cut -d',' -f1 | awk '{print $4}') Opcion alterna
totalMemory=$(free | head -2 |tail -1| awk '{print $2}')

#usedMemory=$(top|head -4| tail -1 | cut -d',' -f3 |awk '{print $2}' Opcion alterna
usedMemory=$(free | head -2 |tail -1| awk '{print $3}')


echo "-> memoria total en KB ${totalMemory}"
echo "-> memoria usada en KB ${usedMemory}"

#usedMemoryPercentage=$((($usedMemory *100)/$totalMemory))
usedMemoryPercentage=$(echo "scale=2; ($usedMemory*100)/$totalMemory" | bc) #calcula el porcentaje de uso


echo "-> porcentaje de memoria usada: $usedMemoryPercentage %"
#6-->100%
#used--> X

processProblem=$(top | head -8| tail -1|  awk '{print $13}') #arroja el processo que esta consumiendo mas memoria


condition0=$(echo "$usedMemoryPercentage > 75.00" | bc) #porcentaje para el caso 1
condition1=$(echo "$usedMemoryPercentage > 20.00" | bc) #porcentaje para el caso 2
condition2=$(echo "$usedMemoryPercentage < 25.38" | bc) #porcetaje para el caso 2


    if [[ $condition2 -eq 1 && $condition1 -eq 1 ]]
    then
        notify-send --icon=message_box_info "ALTO CONSUMO DE MEMORIA, CUIDADO CON EL PROCESO $processProblem" #buscar lo adecuado
    else
        if [ $condition0 -eq 1 ]
        then
            notify-send --icon=message_box_info "ALTO CONSUMO DE MEMORIA, $usedMemoryPercentage alcanzado" #buscar lo adecuado
           
        fi
    fi

    if [ -f .ramStateLog  ] #se actualiza o se crea el log
    then
        echo "lo que sea que vaya acá">>.ramStateLog
    else
        touch .ramStateLog
    fi


