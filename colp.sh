#!/bin/bash
source bash/config.sh

function sql {
    shift;
    local filename=$1
    if [ -f $filename ]; then
        psql $BUILD_ENGINE -f $filename
    else
        echo "$filename is not a valid file path"
    fi
}

case $1 in 
    dataloading ) ./bash/01_dataloading.sh ;;
    build ) ./bash/02_build.sh ;;
    export ) ./bash/03_export.sh ;;
    upload ) ./bash/04_upload.sh ;;
    sql) sql $@ ;;
    * ) echo "COMMAND \"$1\" is not found. (valid commands: dataloading|build|export|upload)" ;;
esac
