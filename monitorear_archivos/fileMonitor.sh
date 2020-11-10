#!/bin/bash

#Elaborado por Neyder Figueroa,Andres Llinas, Daniel Bonilla

#Inicializa el archivo (fileStateLog) que guarda el estado inicial de cada archivo a monitorear
inicializarLog(){
    echo > fileStateLog.log
    while read fileName  ; do

        if [ -f "$fileName" ]; then
            exists="true"
            modificationTime=$(stat -c '%y' $fileName)
            accessTime=$(stat -c '%x' $fileName)
        else 
            exists="false"
            modificationTime=""
            accessTime=""
        fi

        echo $fileName,$exists,"$modificationTime","$accessTime",  >> fileStateLog.log
    done <filelist.txt
}

inicializarLog

#Se inicia un ciclo infinito para monitorear los archivos
while true
do
    #Itera por cada archivo verificando si las fechas han cambiado
    while read fileName  ; do
        
        #Se busca la fila con el nombre del archivo en el fileStateLog
        var="$(grep $fileName fileStateLog.log)"
        echo Analizando $fileName ...
        #Se divide la linea en un array
        readarray -d , -t strarr <<<"$var"

        #Si el archivo existe en el directorio
        if [ -f "$fileName" ]
        then
            #Si no esta como verdadero en el registro, lo modifica
            if [[ "${strarr[1]}" == "false" ]]
            then
                #Se crea el archivo
                notify-send "Se ha creado el archivo" $fileName
                echo "Se ha creado el archivo" $fileName

                exists="true"
                modificationTime=$(stat -c '%y' $fileName)
                accessTime=$(stat -c '%x' $fileName)

                #Se agrega el evento al log de eventos
                echo "Time: $(date). se ha creado $fileName." >> events.log

                #Se reemplaza la linea en fileStateLog con las nuevas fechas
                fila=$fileName,$exists,"$modificationTime","$accessTime",
                sed -i -e 's/'"$var"'/'"$fila"'/' fileStateLog.log


                var="$(grep $fileName fileStateLog.log)"
                #Se divide la linea en un array
                readarray -d , -t strarr <<<"$var"
            fi

            #Compara la fecha actual de modificacion del archivo con la que esta almacenada en el fileStateLog
            currentModtime=$(stat -c '%y' $fileName)
            if [[ "${strarr[2]}" != "$currentModtime" ]]
            then

                #Envia la notificacion
                notify-send "Se ha modificado el archivo" $fileName
                echo "Se ha modificado el archivo" $fileName                

                #Se agrega el evento al log de eventos
                echo "Time: $(date). se ha modificado $fileName." >> events.log

                #Se reemplaza la fecha antigua por la nueva en el fileStateLog
                nuevaFila=$fileName,"true","$currentModtime","${strarr[3]}",
                sed -i -e 's/'"$var"'/'"$nuevaFila"'/' fileStateLog.log

                var="$(grep $fileName fileStateLog.log)"
                #Se divide la linea en un array
                readarray -d , -t strarr <<<"$var"

            fi

            #Compara la fecha actual de lectura del archivo con la que esta almacenada en el fileStateLog
            currentAccesstime=$(stat -c '%x' $fileName)
            if [[ "${strarr[3]}" != "$currentAccesstime" ]]
            then

                #Envia la notificacion
                notify-send "Se ha leido el archivo" $fileName
                echo "Se ha leido el archivo" $fileName

                echo "Time: $(date). se ha accedido a $fileName." >> events.log
                nuevaFila=$fileName,"true","${strarr[2]}","$currentAccesstime",
                sed -i -e 's/'"$var"'/'"$nuevaFila"'/' fileStateLog.log

                var="$(grep $fileName fileStateLog.log)"
                #Se divide la linea en un array
                readarray -d , -t strarr <<<"$var"

            fi

        else
            #verificar en el registro. si esta como verdadero, el archivo fue eliminado
            
            if [[ "${strarr[1]}" == "true" ]]
            then
                #Envia la notificacion
                notify-send "Se ha eliminado el archivo" $fileName
                echo "Se ha eliminado el archivo" $fileName


                fila=$fileName,"false","","",
                sed -i -e 's/'"$var"'/'"$fila"'/' fileStateLog.log
                echo "Time: $(date). se ha eliminado $fileName." >> events.log
            fi
        fi


        sleep 1
    done <filelist.txt
done

