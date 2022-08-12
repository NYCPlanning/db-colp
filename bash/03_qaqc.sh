#!/bin/bash
source bash/config.sh

echo "Running QAQC"
docker run --rm\
    --network host\
    -v `pwd`:/home/colp_build/\
    -w /home/colp_build\
    -u $(id -u ${USER}):$(id -g ${USER}) \
    -e BUILD_ENGINE=$BUILD_ENGINE\
    nycplanning/docker-geosupport:latest bash -c "python3 -m python.geo_qaqc"

psql $BUILD_ENGINE -f sql/geo_qaqc.sql
psql $BUILD_ENGINE -f sql/colp_qaqc.sql