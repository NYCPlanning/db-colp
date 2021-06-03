DROP TABLE IF EXISTS colp;
SELECT 
    uid,
    "BOROUGH",
    "BLOCK",
    "LOT",
    "BBL",
    "MAPBBL",
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
