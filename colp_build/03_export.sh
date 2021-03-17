#!/bin/bash
source config.sh

echo "Generate output tables"
psql $BUILD_ENGINE -f sql/_export.sql
psql $BUILD_ENGINE -f sql/nov2020_corrections.sql

rm -rf output
mkdir -p output 
(
    cd output

    echo "Exporting COLP"
    CSV_export colp
    CSV_export ipis_unmapped
    CSV_export ipis_colp_georesults
    CSV_export ipis_modified_hnums
    CSV_export ipis_modified_names
    CSV_export usetype_changes
    echo "[$(date)] $DATE" > version.txt

    SHP_export $BUILD_ENGINE colp POINT colp
)

zip -r output/output.zip output

Upload latest &
Upload $DATE
rm -rf output

wait 
echo "Upload Complete"
