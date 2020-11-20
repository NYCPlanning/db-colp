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
    CSV_export unmapped_airrights
    CSV_export colp_unmapped
    CSV_export address_comparison
    echo "[$(date)] $DATE" > version.txt

    SHP_export $BUILD_ENGINE colp POINT colp
)

zip -r output/output.zip output

Upload latest &
Upload $DATE

wait 
echo "Upload Complete"