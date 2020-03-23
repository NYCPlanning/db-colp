#!/bin/bash
source config.sh

START=$(date +%s);

psql $BUILD_ENGINE -f sql/drop_idx.sql

docker run --rm\
            -v `pwd`:/home/colp_build\
            -w /home/colp_build\
            --env-file .env\
            sptkl/cook:latest bash -c "python3 python/dataloading.py"

END=$(date +%s);
echo $((END-START)) | awk '{print int($1/60)" minutes and "int($1%60)" seconds elapsed."}'