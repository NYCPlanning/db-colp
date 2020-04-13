CREATE TABLE colp_temp (LIKE colp);

INSERT INTO colp_temp (
    borough,
    block,
    lot,
    cd,
    parcel,
    agency,
    use_code,
    use_type,
    ownership,
    leased,
    final_commit,
    agreement,
    bbl
    )
SELECT 
    boro,
    block,
    lot,
    (boro||LPAD(split_part(cd::text, '.', 1), 2, '0')) as cd,
    parcel_name,
    agency,
    (LPAD(split_part(primary_usecode::text, '.', 1), 4, '0')) as primary_usecode,
    primary_usetext,
    (CASE WHEN owner IS NULL then 'P' ELSE owner END) as owner,
    owned_leased,
    (CASE WHEN u_f_use_code IS NULL then NULL ELSE 'D' END) as final_commit,
    (CASE WHEN split_part(u_a_use_code::text, '.', 1) = '1910' OR 
        LPAD(split_part(primary_usecode::text, '.', 1), 4, '0') = '1910' THEN 'L'
        WHEN split_part(u_a_use_code::text, '.', 1) = '1920'  OR
        LPAD(split_part(primary_usecode::text, '.', 1), 4, '0') = '1920' THEN 'S'
        WHEN split_part(u_a_use_code::text, '.', 1) = '1930' OR
        LPAD(split_part(primary_usecode::text, '.', 1), 4, '0') = '1930' THEN 'M'
        ELSE NULL END) as agreement,
    bbl
FROM dcas_ipis;

-- Drop duplicates

INSERT INTO colp (
    borough,
    block,
    lot,
    cd,
    parcel,
    agency,
    use_code,
    use_type,
    ownership,
    leased,
    final_commit,
    agreement,
    bbl
    )
SELECT 
    DISTINCT ON (borough,
                block,
                lot,
                cd,
                parcel,
                agency,
                use_code,
                use_type,
                ownership,
                leased,
                final_commit,
                bbl) 
    borough,
    block,
    lot,
    cd,
    parcel,
    agency,
    use_code,
    use_type,
    ownership,
    leased,
    final_commit,
    agreement,
    bbl 
FROM colp_temp; 
DROP TABLE colp_temp;