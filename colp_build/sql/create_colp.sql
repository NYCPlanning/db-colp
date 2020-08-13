/*
DESCRIPTION:
    1) Cleans relevant columns from DCAS' IPIS. 
    2) Merges these records with the results of running input BBLs 
        through Geosupport's BL function.
    3) Creates category and expanded category fields for use types
    4) Backfills missing community districts by joining with PLUTO on the geosupport-returned
        billing BBL.
    
INPUTS: 

    dcas_ipis (
        boro,
        block,
        lot,
        * bbl,
        cd,
        parcel_name,
        agency,
        primary_use_code,
        u_a_use_cod
    )

    dcas_ipis_geocodes (
        * input_bbl,
        geo_bbl,
        x_coord,
        y_coord
    )

    dcp_mappluto (
        * bbl,
        cd
    )

OUTPUTS: 
    colp (
        borough,
        block,
        lot,
        bbl,
        geo_bbl,
        cd,
        hnum,
        sname,
        parcel,
        agency,
        use_code,
        use_type,
        category,
        expand_cat,
        leased,
        final_com,
        agreement,
        mappable,
        x_coord,
        y_coord,
        geom
    )
*/

DROP TABLE IF EXISTS colp CASCADE;
WITH 
geo_merge as (
    SELECT 
        a.boro as borough,
        a.block,
        a.lot,
        a.bbl,
        -- Add geosupport-returned billing BBL
        b.geo_bbl,
        -- Create temp cd field from IPIS, pre-pluto backfill
        (CASE 
            WHEN a.cd::text LIKE '_0' OR a.cd IS NULL 
                THEN NULL
            ELSE a.cd::text 
        END) as _cd,
        b.hnum,
        b.sname,
        a.parcel_name as parcel,
        a.agency,
        -- Create temp use code field, without 1900 cleaning
        (LPAD(split_part(a.primary_use_code::text, '.', 1), 4, '0')) as _use_code,
        -- Create temp use type field, without 1900 cleaning
        a.primary_use_text as _use_type,
        -- Fill null ownership values
        (CASE 
            WHEN a.owner IS NULL 
                THEN 'P' 
            ELSE a.owner 
        END) as ownership,
        a.owned_leased as leased,
        -- Fill null final commitment values
        (CASE 
            WHEN a.u_f_use_code IS NULL 
                THEN NULL 
            ELSE 'D' 
        END) as final_com,
        -- Parse use codes to determine agreement length
        (CASE 
            WHEN split_part(a.u_a_use_code::text, '.', 1) = '1910' OR 
            LPAD(split_part(a.primary_use_code::text, '.', 1), 4, '0') = '1910' 
                THEN 'L'
            WHEN split_part(a.u_a_use_code::text, '.', 1) = '1920'  OR
            LPAD(split_part(a.primary_use_code::text, '.', 1), 4, '0') = '1920' 
                THEN 'S'
            WHEN split_part(a.u_a_use_code::text, '.', 1) = '1930' OR
            LPAD(split_part(a.primary_use_code::text, '.', 1), 4, '0') = '1930' 
                THEN 'M'
            ELSE NULL 
        END) as agreement,
        -- Add coordinates, mappable flag, and geometry from geocode.py results
        b.x_coord,
        b.y_coord,
        (CASE 
            WHEN b.x_coord IS NULL THEN 0
            ELSE 1
        END) as mappable,
        (CASE
            WHEN b.longitude IS NOT NULL AND b.longitude <> ''
            THEN ST_SetSRID(ST_MakePoint(b.longitude::double precision, b.latitude::double precision),4326)
            ELSE NULL
        END) as geom
    FROM dcas_ipis a
    JOIN dcas_ipis_geocodes b
    ON a.bbl = b.input_bbl
    WHERE a.owner <> 'R'
),

pluto_merge AS (
    SELECT
        a.*,
        -- Backfill missing cd with pluto
        (CASE 
            WHEN a._cd IS NULL 
                THEN b.cd
            ELSE a._cd
        END) as cd
    FROM geo_merge a 
    JOIN dcp_pluto b
    ON a.geo_bbl = b.bbl
),

categorized as (
    SELECT 
        a.*,
        -- In-use tenanted use codes should all be 1900. Length is in agreement field.
        (CASE
            WHEN a._use_code IN ('1910', '1920', '1930')
            THEN '1900'
            ELSE a._use_code
        END) as use_code,
        -- In-use tenanted use types should all be 1900. Length is in agreement field.
        (CASE
            WHEN a._use_code IN ('1910', '1920', '1930')
            THEN 'IN USE-TENANTED'
            ELSE a._use_type
        END) as use_type,
        -- Parse use codes to create categories
        (CASE
                WHEN a._use_code LIKE '15%' THEN '3'
                WHEN a._use_code LIKE '14%' THEN '2'
                WHEN a._use_code IS NULL OR a._use_code LIKE '16%' THEN NULL
                ELSE '1'
            END) as category,
        -- Parse use codes to create expanded categories
        (CASE
            WHEN a._use_code LIKE '01%' 
                OR a._use_code = '1310'
                OR a._use_code = '1340'
                OR a._use_code = '1341'
                OR a._use_code = '1349' THEN '1'
            WHEN a._use_code LIKE '02%' THEN '2'
            WHEN a._use_code LIKE '03%'
                OR a._use_code LIKE '04%'
                OR a._use_code = '1330' THEN '3'
            WHEN a._use_code LIKE '05%' 
                OR a._use_code LIKE '12%' 
                OR a._use_code = '1390' THEN '4'
            WHEN a._use_code LIKE '06%'
                OR a._use_code LIKE '07%' THEN '5'
            WHEN a._use_code LIKE '19%'
                OR a._use_code = '1342' THEN '6'
            WHEN a._use_code LIKE '08%'
                OR a._use_code LIKE '09%'
                OR a._use_code LIKE '10%'
                OR a._use_code LIKE '11%' 
                OR a._use_code = '1312'
                OR a._use_code = '1313'
                OR a._use_code = '1350'
                OR a._use_code = '1360'
                OR a._use_code = '1370'
                OR a._use_code = '1380' THEN '7'
            WHEN a._use_code LIKE '15%'
                OR a._use_code = '1420' THEN '8'
            WHEN a._use_code = '1410' 
                OR a._use_code = '1400'THEN '9'
            ELSE NULL
        END) as expand_cat
    FROM pluto_merge a
)

-- Reorder columns for outpu
SELECT
    borough,
    block,
    lot,
    bbl,
    geo_bbl,
    cd,
    hnum,
    sname,
    parcel,
    agency,
    use_code,
    use_type,
    category,
    expand_cat,
    leased,
    final_com,
    agreement,
    mappable,
    x_coord,
    y_coord,
    geom
INTO colp
FROM categorized;
