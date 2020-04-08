-- Add agreement types
UPDATE colp
SET agreement = CASE
        WHEN use_code = '1910' THEN 'L'
        WHEN use_code = '1920' THEN 'S'
        WHEN use_code = '1930' THEN 'M'
        WHEN use_code = '1900' THEN 'T'
        ELSE NULL
    END;