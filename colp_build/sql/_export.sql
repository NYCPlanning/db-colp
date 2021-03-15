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