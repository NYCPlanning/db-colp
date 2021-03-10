DROP TABLE IF EXISTS ipis_colp_geoerrors;
SELECT
    a.*,
    b."AGENCY",
    b."USECODE",
    b."USETYPE",
    b."OWNERSHIP",
    b."CATEGORY",
    b."EXPANDCAT",
    b."EXCATDESC",
    b."LEASED",
    b."FINALCOM",
    b."AGREEMENT"
INTO ipis_colp_geoerrors
FROM geo_qaqc a
JOIN _colp b
ON a.dcas_ipis_uid = b.dcas_ipis_uid
;