-- Add agreement types
UPDATE colp
SET use_code = '1900',
use_type = 'IN USE-TENANTED'
WHERE use_code IN ('1910', '1920', '1930');