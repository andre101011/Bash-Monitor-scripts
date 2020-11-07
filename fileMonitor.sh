#!/bin/bash

#Elaborado por Neyder Figueroa,Andres Llinas, Daniel Bonilla



#---------------------------Monitorear cambio en un solo archivo-------------------
while true
do
   ATIME=`stat -c %Z filelist.txt`
   if [[ "$ATIME" != "$LTIME" ]]
   then
       echo "Hace algo si hay un cambio en el archivo"
       LTIME=$ATIME
   fi
   sleep 5
done
#--------------------------------------------------

while read fileName  ; do

        modificationTime=$(stat -c '%y' $fileName)
        accessTime=$(stat -c '%x' $fileName)
        changeTime=$(stat -c '%z' $fileName)

        echo "$(date -Iseconds) | $fileName" >> fileStateLog.log
        echo -e Ultima modificacion:"$modificationTime" "\n"ultima lectura: "$accessTime" "\n"ultimo cambio: $changeTime"\n"  >> fileStateLog.log

notify-send "Lo mismo del log"

done <filelist.txt






