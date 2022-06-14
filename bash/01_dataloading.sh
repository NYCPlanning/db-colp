#!/bin/bash
source bash/config.sh

import_public dcp_pluto &
import_public dcp_colp &
import_public dcas_ipis &
import_public dof_air_rights_lots &
wait 
echo "dataloading complete"