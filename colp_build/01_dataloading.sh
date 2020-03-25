#!/bin/bash
source config.sh

START=$(date +%s);

docker run --rm\
            -v `pwd`:/home/colp_build\
            -w /home/colp_build\
            --env-file .env\
            sptkl/cook:latest bash -c "python3 python/dataloading.py"

docker run --rm\
            -v `pwd`:/home/colp_build\
            -w /home/colp_build\
            --env-file .env\
            sptkl/docker-geosupport:latest bash -c "python3 python/geocode.py"

END=$(date +%s);
echo $((END-START)) | awk '{print int($1/60)" minutes and "int($1%60)" seconds elapsed."}'