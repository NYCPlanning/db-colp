-- Add agreement types
UPDATE colp
SET use_code = '1900'
WHERE use_code IN ('1910', '1920', '1930');