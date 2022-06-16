DROP TABLE IF EXISTS colp;
SELECT 
    uid::varchar(32) as uid,
    "BOROUGH",
    "BLOCK",
    "LOT",
    "BBL",
    "MAPBBL",
    "CD",
    "HNUM",
    "SNAME",
    (CASE 
        WHEN "HNUM" IS NOT NULL AND "SNAME" <> ''
            THEN CONCAT("HNUM", ' ', "SNAME")
        ELSE "SNAME"
    END) as "ADDRESS",
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
    ---(CASE
    ---    WHEN uid IN (SELECT DISTINCT uid FROM modifications_applied) THEN 'Y'
    ---END)::varchar(1) as "DCPEDITED",
    "DCPEDITED",
    "GEOM"
INTO colp
FROM _colp
WHERE "XCOORD" IS NOT NULL;
