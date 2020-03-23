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
    renewal,
    final_commit,
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
    owner,
    owned_leased,
    lur_urbanrenewalsite,
    u_f_use_code,
    bbl
FROM dcas_ipis;