#!/bin/bash
source bash/config.sh

echo "Running QAQC"

psql $BUILD_ENGINE -f sql/geo_qaqc.sql
psql $BUILD_ENGINE -f sql/export_qaqc.sql