#!/bin/bash
source config.sh

# Column mapping
psql $BUILD_ENGINE -f sql/create.sql
psql $BUILD_ENGINE -f sql/map_ipis.sql
psql $BUILD_ENGINE -f sql/add_geoms.sql
psql $BUILD_ENGINE -f sql/residential_occ.sql
psql $BUILD_ENGINE -f sql/no_curr_use.sql
psql $BUILD_ENGINE -f sql/cat_codes.sql
