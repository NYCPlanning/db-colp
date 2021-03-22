DROP TABLE IF EXISTS colp;
SELECT 
    dcas_ipis_uid,
    "BOROUGH",
    "BLOCK",
    "LOT",
    "BBL",
    "BILLBBL",
    "CD",
    "HNUM",
    "SNAME",
    "ADDRESS",
    "PARCELNAME",
    "AGENCY",
    "USECODE",
    "USETYPE",
    "OWNERSHIP",
    "CATEGORY",
    "EXPANDCAT",
    "EXCATDESC",
    "LEASED",
    "FINALCOM",
    "AGREEMENT",
    "XCOORD",
    "YCOORD",
    "LATITUDE",
    "LONGITUDE",
    "GEOM"
INTO colp
FROM _colp
WHERE "XCOORD" IS NOT NULL;

-- Create QAQC table of unmappable input records
DROP TABLE IF EXISTS ipis_unmapped;
SELECT a.*,
	b.geo_bbl,
    b.grc,
    b.rsn,
    b.msg
INTO ipis_unmapped
FROM dcas_ipis a
JOIN dcas_ipis_geocodes b
ON a.bbl = b.input_bbl
AND md5(CAST((a.*)AS text)) IN (SELECT DISTINCT dcas_ipis_uid FROM _colp WHERE "XCOORD" IS NULL);

-- Create QAQC table of records with modified house numbers
DROP TABLE IF EXISTS ipis_modified_hnums;
SELECT 
    a.dcas_bbl, 
    a.dcas_hnum, 
    a.display_hnum, 
    a.dcas_sname, 
    a.sname_1b,
    b.parcel_name,
    b.agency,
    b.primary_use_code,
    b.primary_use_text
INTO ipis_modified_hnums
FROM ipis_colp_georesults a
JOIN dcas_ipis b
ON a.dcas_ipis_uid = md5(CAST((b.*)AS text))
WHERE a.dcas_hnum <> a.display_hnum
OR (a.dcas_hnum IS NOT NULL AND a.display_hnum = '')
OR (a.dcas_hnum IS NULL AND a.display_hnum <> '');

-- Create QAQC table of records with modified parcel names
DROP TABLE IF EXISTS ipis_modified_names;
SELECT 
    a.dcas_bbl, 
    a.dcas_hnum, 
    a.display_hnum, 
    a.dcas_sname, 
    a.sname_1b,
    b.parcel_name,
    a."PARCELNAME" as display_name,
    b.agency,
    b.primary_use_code,
    b.primary_use_text
INTO ipis_modified_names
FROM ipis_colp_georesults a
JOIN dcas_ipis b
ON a.dcas_ipis_uid = md5(CAST((b.*)AS text))
WHERE b.parcel_name <> a."PARCELNAME";

-- Create QAQC table of version-to-version changes in the number of records per use type
DROP TABLE IF EXISTS usetype_changes;
WITH 
prev AS (
    SELECT
        v as v_previous,
        usetype,
        COUNT(*) as num_records_current
    FROM dcp_colp
    GROUP BY v, usetype
),
current AS (
    SELECT
        TO_CHAR(CURRENT_DATE, 'YYYY/MM/DD') as v_current,
        "USETYPE" as usetype,
        COUNT(*) as num_records_previous
    FROM colp
    GROUP BY "USETYPE"
)
SELECT
    a.usetype,
    a.v_previous,
    b.v_current,
    a.num_records_current,
    b.num_records_previous,
    a.num_records_current - b.num_records_previous as difference
INTO usetype_changes
FROM prev a
JOIN current b 
ON a.usetype = b.usetype;
