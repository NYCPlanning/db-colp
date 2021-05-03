#!/bin/bash
source config.sh

import_public dcp_pluto &
import_public dcp_colp &
import_public dcas_ipis &
import_public dof_air_rights_lots

psql $BUILD_ENGINE -f sql/load_corrections.sql  