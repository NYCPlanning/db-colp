-- Add geometries from geocoding results

UPDATE colp
SET x_coord = a.x_coord,
    y_coord = a.y_coord
FROM dcas_ipis_geocodes a
WHERE colp.bbl = a.input_bbl;