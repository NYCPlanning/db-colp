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

DROP TABLE IF EXISTS qaqc_colp_unmapped;
SELECT a.*,
    b.geo_function,
    b.input_hnum,
    b.input_sname,
    b.grc,
    b.rsn,
    b.msg
INTO qaqc_colp_unmapped
FROM _colp a
JOIN dcas_ipis_geocodes b
ON a."BBL" = b.input_bbl::numeric(19,8)
WHERE a."XCOORD" IS NULL;