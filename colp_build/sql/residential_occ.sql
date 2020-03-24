-- Derive residential use from primary use
UPDATE colp
SET residential_occ = CASE
        WHEN use_code = '1410' THEN 'O'
        WHEN use_code = '1420' THEN 'N'
        ELSE NULL
    END;