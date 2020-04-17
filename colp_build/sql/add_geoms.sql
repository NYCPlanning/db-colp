-- Add geometries from geocoding results

UPDATE colp
SET x_coord = a.x_coord,
    y_coord = a.y_coord,
    hnum = a.hnum,
    street = a.sname
FROM dcas_ipis_geocodes a
WHERE colp.bbl = a.bbl
AND colp.hnum = a.house_number
AND colp.street = a.street_name;