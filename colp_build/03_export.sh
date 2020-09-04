#!/bin/bash
source config.sh

echo "Generate output tables"
psql $BUILD_ENGINE -f sql/_export.sql

mkdir -p output 
(
    cd output

    echo "Exporting COLP"
    CSV_export colp &
    CSV_export colp_unmapped &
    echo "[$(date)] $DATE" > version.txt
)

zip -r output/output.zip output

# Upload latest &
# Upload $DATE

# wait 
# display "Upload Complete"