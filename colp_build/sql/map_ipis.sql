-- Create hash to use as unique ID throughout build
ALTER TABLE dcas_ipis
ADD hash text; 

UPDATE dcas_ipis as t
SET hash =  md5(CAST((t.*)AS text));

INSERT INTO colp (
    hash,
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
    renewal,
    final_commit,
    bbl
    )
SELECT 
    hash,
    boro,
    block,
    lot,
    (boro||LPAD(split_part(cd::text, '.', 1), 2, '0')) as cd,
    parcel_name,
    agency,
    (LPAD(split_part(primary_usecode::text, '.', 1), 4, '0')) as primary_usecode,
    primary_usetext,
    owner,
    owned_leased,
    lur_urbanrenewalsite,
    (CASE WHEN u_f_use_code IS NULL then NULL ELSE 'D' END) as final_commit,
    bbl
FROM dcas_ipis;