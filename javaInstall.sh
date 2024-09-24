#!/bin/bash

# Exit script on any error
set -e

# Variables


installJavaFromFile(){
    read -p "Enter the path to the Downloaded Java installer (including filename): " filePath
    
    echo "installing java from : $filePath"
    extractedPath=$(tar tf $filePath | head -1 | sed 's/.$//')
    cd ~
    pathToHome=$(pwd)
    $(gzip -dc $filePath | tar xf -)
    pathToJavaHome="$pathToHome/$extractedPath"
    export JAVA_HOME=$pathToJavaHome
    export PATH=$JAVA_HOME/bin:$PATH
    if [[ $(java -version 2>&1) = *'Salesforce OneJDK'* ]]
    then
        echo "Java Installed :)" 
    else
        echo "JAVA Not Found. Could not install Java :("
    fi
}

echo "Checking if Java is Installed !!!!!"

if [[ $(java -version 2>&1) = *'Salesforce OneJDK'* ]]
then
    echo Found Java. 
else
    echo "***************************************************************"
    echo "JAVA Not Found. Java Runtime is required to Continue the setup."
    echo "***************************************************************"

    echo "You have two options to continue:"
    echo "1) Do you want to download Saleforce OneJDK ?" 
    echo "2) You Already have Salesforce OneJDK file downlaoded ?" 

    read -p "Choose one option:" choice
    case $choice in
    1) echo "Download Java from this link (https://confluence.internal.salesforce.com/display/CORE/Get+Salesforce+OneJDK) and re run the script." ;;
    2) installJavaFromFile ;;
    *) echo "Unrecognized selection: $choice. Exiting !!!" ;;
    esac
fi

echo "Done !!!!!"
