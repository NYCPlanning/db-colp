DROP TABLE IF EXISTS colp;
SELECT *
INTO colp
FROM _colp
WHERE xcoord IS NOT NULL;

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
ON a.bbl = b.input_bbl
WHERE a.xcoord IS NULL;