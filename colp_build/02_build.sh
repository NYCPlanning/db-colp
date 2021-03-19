#!/bin/bash
source config.sh

START=$(date +%s);

docker run --rm\
    -v `pwd`:/home/colp_build\
    -w /home/colp_build\
    -u $(id -u ${USER}):$(id -g ${USER}) \
    -e BUILD_ENGINE=$BUILD_ENGINE\
    nycplanning/docker-geosupport:latest bash -c "python3 python/geo_qaqc.py;
                                                python3 python/geocode.py"

psql $BUILD_ENGINE -f sql/_procedures.sql                                         
psql $BUILD_ENGINE -f sql/name.sql
psql $BUILD_ENGINE -f sql/create_colp.sql
psql $BUILD_ENGINE -f sql/qaqc.sql

psql $BUILD_ENGINE -1 -c "CALL apply_correction('_colp', 'corrections');"

END=$(date +%s);
echo $((END-START)) | awk '{print int($1/60)" minutes and "int($1%60)" seconds elapsed."}'

