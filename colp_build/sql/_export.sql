DROP TABLE IF EXISTS colp;
SELECT *
INTO colp
FROM _colp
WHERE x_coord IS NOT NULL;

DROP TABLE IF EXISTS colp_unmapped;
SELECT *
INTO colp_unmapped
FROM _colp
WHERE x_coord IS NULL;