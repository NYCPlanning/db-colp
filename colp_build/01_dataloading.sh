#!/bin/bash
source config.sh

docker run --rm\
    -v `pwd`:/home/colp_build\
    -w /home/colp_build\
    -u $(id -u ${USER}):$(id -g ${USER}) \
    -e RECIPE_ENGINE=$RECIPE_ENGINE\
    -e BUILD_ENGINE=$BUILD_ENGINE\
    -e EDM_DATA=$EDM_DATA\
    nycplanning/cook:latest bash -c "python3 python/dataloading.py"