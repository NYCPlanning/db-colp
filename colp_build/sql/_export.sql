DROP TABLE IF EXISTS colp;
SELECT 
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

DROP TABLE IF EXISTS unmapped_airrights;
SELECT *
INTO unmapped_airrights
FROM _colp
WHERE "XCOORD" IS NULL
AND LEFT("LOT"::text, 1) = '9' AND LENGTH("LOT"::text) = 4;

DROP TABLE IF EXISTS colp_unmapped;
SELECT a.*,
    b.input_bbl,
    b.grc,
    b.rsn,
    b.msg
INTO colp_unmapped
FROM _colp a
JOIN dcas_ipis_geocodes b
ON a."BBL" = b.input_bbl::numeric(19,8)
WHERE a."XCOORD" IS NULL;

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

DROP TABLE IF EXISTS modified_hnums;
SELECT 
    dcas_bbl, 
    dcas_hnum, 
    display_hnum, 
    dcas_sname, 
    sname_1b
INTO modified_hnums
FROM ipis_colp_geoerrors
WHERE dcas_hnum <> display_hnum
OR (dcas_hnum IS NOT NULL AND display_hnum = '')
OR (dcas_hnum IS NULL AND display_hnum <> '');