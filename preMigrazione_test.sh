#!/bin/bash


spazio="###################################################"

# Ottieni il percorso della cartella corrente
current_folder=$(pwd)
reportPath="$current_folder/report.txt"
hostname=$(hostname -s)
echo "$spazio" >> $reportPath
echo "HOSTNAME DELLA MACCHINA: $hostname" >> $reportPath
echo " " >> $reportPath
ipPubblico=$(curl ifconfig.me)
echo "$spazio" >> $reportPath
echo "IP PUBBLICO: $ipPubblico" >> $reportPath
echo " " >> $reportPath
ipLocale=$(hostname -I | awk '{print $1}')
echo "$spazio" >> $reportPath
echo "IP LOCALE: $ipLocale" >> $reportPath
echo " " >> $reportPath
echo "Cerco la cartella del repository"
# Cerca il percorso della cartella "repository" limitando la ricerca alla profondità massima di 1
echo "$spazio" >> $reportPath
echo " " >> $reportPath
echo "Cerco la cartella del repository" >> $reportPath
echo " " >> $reportPath
repositoryPath=$(find / -type d -path "*/home/jboss/repository" 2> /dev/null)

# Verifica se il percorso della cartella "repository" è stato trovato correttamente
if [ -n "$repositoryPath" ]; then

    echo "Path della cartella repository trovato: $repositoryPath. Eseguo i comandi."
    echo "$spazio" >> $reportPath
    echo " " >> $reportPath
    # Salva nel report il percorso della cartella "repository" e invia l'output alla console
    echo "PATH DELLA REPOSITORY: $repositoryPath" >> $reportPath
    echo "CONTENUTO: " >> $reportPath
    ls -l "$repositoryPath" | awk '{print $9}' >> $reportPath
    echo " " >> $reportPath
    # Ottieni il percorso della cartella genitore di "repository" che sarebbe /home/jboss/
    parentPath=$(dirname "$repositoryPath") 

    if mkdir "$repositoryPath/appoggio"; then
        echo "$spazio" >> $reportPath
        echo " " >> $reportPath
        echo "PATH DELLA CARTELLA DI APPOGGIO: $repositoryPath/appoggio" >> $reportPath
        echo " " >> $reportPath
    else
        echo "$spazio" >> $reportPath
        echo " " >> $reportPath
        echo "Impossibile creare la cartella 'appoggio'. Interrompo lo script." >> $reportPath
        echo " " >> $reportPath
        exit 1
    fi
     
    #comandi PSQL
    echo "$spazio" >> $reportPath
    echo " " >> $reportPath
    echo "OPERAZIONI SU POSTGRESS:" >> $reportPath
    echo "'\l+':" >> $reportPath
    psql -h 127.0.0.1 -U postgres -c "\l+" >> $reportPath
    echo " " >> $reportPath
    echo "'\du':" >> $reportPath
    psql -h 127.0.0.1 -U postgres -c "\du" >> $reportPath
    echo " " >> $reportPath
    cd $repositoryPath/appoggio

    # Esegui i comandi cp con i percorsi relativi rispetto alla cartella genitore di "repository"
    cp -pr "${parentPath}/java/jre/lib/security/cacerts" .
    cp -pr "${parentPath}/wildfly_home/standalone/configuration/standalone-full.xml" .
    cp -pr "${parentPath}/wildfly_home/standalone/deploy/sicraweb.ear/server/signed-jars/conf.ig/sicraweb.server.config.xml" .
    cp -pr "${parentPath}/wildfly_home/standalone/deploy/sicraweb.ear/server/signed-jars/conf.ig/security_1" .
    cp -pr "${parentPath}/wildfly_home/standalone/deploy/sicraweb.ear/server/signed-jars/conf.ig/security_2" .
  
    # Verifica VAADIN
    if [ -f "$parentPath/wildfly_home/standalone/deploy/sicraweb-vaadin.war/WEB-INF/portal.properties" ]; then
        cp -pr "${parentPath}/wildfly_home/standalone/deploy/sicraweb-vaadin.war/WEB-INF/portal.properties" .
        echo "$spazio" >> $reportPath
        echo " " >> $reportPath
        echo "LISTA DEI FILE IN APPOGGIO:" >> $reportPath
        ls -1 >> $reportPath
        echo " " >> $reportPath
        cd ..
        echo "$spazio" >> $reportPath
        echo " " >> $reportPath
        echo "VAADIN: SI" >> $reportPath
        echo " " >> $reportPath
    else
        echo "$spazio" >> $reportPath
        echo " " >> $reportPath
        echo "LISTA DEI FILE IN APPOGGIO:" >> $reportPath
        ls -1 >> $reportPath
        echo " " >> $reportPath
        cd ..
        echo "$spazio" >> $reportPath
        echo " " >> $reportPath
        echo "VAADIN: NO" >> $reportPath
        echo " " >> $reportPath
    fi
    # Verifica GEOSERVER
    if [ -z "$(ls -A "$repositoryPath/geoserver/data")" ]; then
        echo "$spazio" >> $reportPath
        echo " " >> $reportPath
        echo "GEOSERVER: NO" >> $reportPath
        echo " " >> $reportPath
    else
        echo "$spazio" >> $reportPath
        echo " " >> $reportPath
        echo "GEOSERVER: SI" >> $reportPath
        echo " " >> $reportPath
    fi
    echo "$spazio" >> $reportPath
    echo " " >> $reportPath
    echo "LISTA DEI WS:" >> $reportPath
    echo cat $parentPath/wildfly_home/standalone/deploy/sicraweb.ear/sicraweb.war/WEB-INF/server-config.wsdd | grep "service name" | awk '{print $2}' | sed 's/name="//; s/"//' >> $reportPath
    echo " " >> $reportPath
    echo "$spazio" >> $reportPath
    echo " " >> $reportPath
    echo "LISTA DEGLI ALIAS DEI WS:" >> $reportPath
    cat $parentPath/wildfly_home/standalone/deploy/sicraweb.ear/server/signed-jars/conf.ig/sicraweb.server.config.xml | grep "alias" | awk '{print $4}' | grep 'name="[^"]*"' | sed 's/name="//; s/"//' >> $reportPath
    echo " " >> $reportPath
    echo "$spazio" >> $reportPath
    echo "$spazio" >> $reportPath
    echo " " >> $reportPath
    echo "Il report è pronto, consulta il file report.txt ($current_folder/report.txt) per tutte le informazioni. "
    echo "$spazio" >> $reportPath
else
    echo "$spazio" >> $reportPath
    echo " " >> $reportPath
    echo "La cartella 'repository' non è stata trovata. Interrompo lo script."
    echo "Path della cartella repository non trovato." >> $reportPath
    echo "$spazio" >> $reportPath
    exit 1
fi
