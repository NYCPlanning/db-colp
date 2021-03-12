DROP TABLE IF EXISTS colp;
SELECT *
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
    b.geo_function,
    b.input_hnum,
    b.input_sname,
    b.grc,
    b.msg,
    b.msg2
INTO colp_unmapped
FROM _colp a
JOIN dcas_ipis_geocodes b
ON a."BBL" = b.input_bbl::numeric(19,8)
WHERE a."XCOORD" IS NULL;

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