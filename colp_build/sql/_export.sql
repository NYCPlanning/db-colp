DROP TABLE IF EXISTS colp;
SELECT *
INTO colp
FROM _colp
WHERE "XCOORD" IS NOT NULL;

DROP TABLE IF EXISTS colp_unmapped;
SELECT a.*,
    b.geo_function,
    b.input_hnum,
    b.input_sname,
    b.grc,
    b.msg,
    b.msg2
INTO colp_unmapped
FROM _colp a
JOIN dcas_ipis_geocodes b
ON a."BBL" = b.input_bbl
WHERE a."XCOORD" IS NULL;