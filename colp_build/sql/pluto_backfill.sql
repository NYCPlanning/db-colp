-- Backfill CD from PLUTO
UPDATE colp
SET cd = a.cd
FROM dcp_pluto a
WHERE colp.cd IS NULL
AND colp.bbl = a.bbl;
