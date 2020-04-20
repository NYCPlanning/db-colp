#!/bin/bash
source config.sh

START=$(date +%s);

# Column mapping
echo "Create COLP"
psql $BUILD_ENGINE -f sql/create.sql
echo "Map IPIS columns"
psql $BUILD_ENGINE -f sql/map_ipis.sql
echo "Merge geocoding results"
psql $BUILD_ENGINE -f sql/add_geoms.sql
echo "Create category codes"
psql $BUILD_ENGINE -f sql/cat_codes.sql
echo "Correct agreement fields"
psql $BUILD_ENGINE -f sql/agreement.sql
echo "Backfill CD from PLUTO"
psql $BUILD_ENGINE -f sql/pluto_backfill.sql

END=$(date +%s);
echo $((END-START)) | awk '{print int($1/60)" minutes and "int($1%60)" seconds elapsed."}'

