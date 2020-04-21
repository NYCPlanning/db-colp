-- Add coordinates from geocoding results
UPDATE colp
SET x_coord = a.x_coord,
    y_coord = a.y_coord,
    hnum = a.hnum,
    street = a.sname
FROM dcas_ipis_geocodes a
WHERE colp.bbl = a.input_bbl;

-- Create geom column from coordinates
UPDATE colp
SET geom = ST_SetSRID(ST_MakePoint(a.longitude::double precision, a.latitude::double precision),4326)
FROM dcas_ipis_geocodes a
WHERE colp.bbl = a.input_bbl
AND a.longitude IS NOT NULL AND a.longitude <> '';

-- Set mappable flag to indicate missing geometries
UPDATE colp
SET mappable = (CASE 
    WHEN x_coord IS NULL THEN 1
    ELSE 0
    END);
