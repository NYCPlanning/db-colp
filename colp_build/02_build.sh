#!/bin/bash
source config.sh

START=$(date +%s);

docker run --rm\
    -v `pwd`:/home/colp_build\
    -w /home/colp_build\
    -e RECIPE_ENGINE=$RECIPE_ENGINE\
    -e BUILD_ENGINE=$BUILD_ENGINE\
    nycplanning/docker-geosupport:latest bash -c "python3 python/geocode.py"

psql $BUILD_ENGINE -f sql/create_colp.sql

END=$(date +%s);
echo $((END-START)) | awk '{print int($1/60)" minutes and "int($1%60)" seconds elapsed."}'

