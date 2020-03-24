-- Derive from IPIS primary use

UPDATE colp
SET no_curr_use = CASE
        WHEN use_code = '1500' THEN 'K'
        WHEN use_code = '1510' THEN 'S'
        WHEN use_code = '1520' THEN 'V'
        WHEN use_code = '1530' THEN 'W'
        ELSE NULL
    END;