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