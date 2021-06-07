#!/bin/bash
source bash/config.sh

case $1 in 
    dataloading ) ./bash/01_dataloading.sh ;;
    build ) ./bash/02_build.sh ;;
    export ) ./bash/03_export.sh ;;
    * ) echo "COMMAND \"$1\" is not found. (valid commands: dataloading|build|export)" ;;
esac
