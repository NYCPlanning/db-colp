#!/bin/bash
source config.sh

START=$(date +%s);

# Column mapping
psql $BUILD_ENGINE -f sql/create.sql
psql $BUILD_ENGINE -f sql/map_ipis.sql
psql $BUILD_ENGINE -f sql/add_geoms.sql
psql $BUILD_ENGINE -f sql/cat_codes.sql

END=$(date +%s);
echo $((END-START)) | awk '{print int($1/60)" minutes and "int($1%60)" seconds elapsed."}'