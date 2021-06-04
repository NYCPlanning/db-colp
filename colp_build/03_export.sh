#!/bin/bash
source config.sh

rm -rf output
mkdir -p output 
(
    cd output

    echo "Exporting COLP"
    CSV_export colp
    SHP_export colp POINT
    FGDB_export colp POINT

    CSV_export ipis_unmapped
    CSV_export ipis_colp_geoerrors
    CSV_export ipis_sname_errors
    CSV_export ipis_hnum_errors
    CSV_export ipis_bbl_errors
    CSV_export ipis_cd_errors
    CSV_export ipis_modified_hnums
    CSV_export ipis_modified_names
    CSV_export usetype_changes
    CSV_export modifications_applied
    CSV_export modifications_not_applied
    echo "[$(date)] $DATE" > version.txt

)

zip -r output/output.zip output

Upload latest &
Upload $DATE

wait 
echo "Upload Complete"
