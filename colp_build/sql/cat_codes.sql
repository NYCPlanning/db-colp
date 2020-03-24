-- Generate category codes
-- 1: Everything else
-- 2: Residential
-- 3: No current use

UPDATE colp
SET category_code = CASE
        WHEN no_curr_use IS NOT NULL THEN '3'
        WHEN residential_occ IS NOT NULL THEN '2'
        WHEN use_code IS NULL THEN NULL
        ELSE '1'
    END;


-- Generate extended category codes
-- 1: Offices
-- 2: Educational facilities
-- 3: Recreational & cultural facilities, cemetaries
-- 4: Public safety and judicial
-- 5: Health & social services
-- 6: Tenented & retail
-- 7: Transportation & infrastructure
-- 8: Not in use
-- 9: In use residential
-- NULL: Dispositions and other final commitments

UPDATE colp
SET expanded_cat_code = CASE
        WHEN use_code LIKE '01%' 
            OR use_code = '1310'
            OR use_code = '1340'
            OR use_code = '1341'
            OR use_code = '1349' THEN '1'
        WHEN use_code LIKE '02%' THEN '2'
        WHEN use_code LIKE '03%'
            OR use_code LIKE '04%'
            OR use_code = '1330' THEN '3'
        WHEN use_code LIKE '05%' 
            OR use_code LIKE '12%' 
            OR use_code = '1390' THEN '4'
        WHEN use_code LIKE '06%'
            OR use_code LIKE '07%' THEN '5'
        WHEN use_code LIKE '19%'
            OR use_code = '1342' THEN '6'
        WHEN use_code LIKE '08%'
            OR use_code LIKE '09%'
            OR use_code LIKE '10%'
            OR use_code LIKE '11%' 
            OR use_code LIKE '13%' 
            OR use_code = '1312'
            OR use_code = '1313'
            OR use_code = '1350'
            OR use_code = '1360'
            OR use_code = '1370'
            OR use_code = '1380' THEN '7'
        WHEN use_code LIKE '15%'
            OR use_code = '1420' THEN '8'
        WHEN use_code = '1410' 
            OR use_code = '1400'THEN '9'
        ELSE NULL
    END;