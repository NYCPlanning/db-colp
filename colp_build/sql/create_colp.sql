/*
DESCRIPTION:
    1) Cleans relevant columns from DCAS' IPIS. 
    2) Merges these records with the results of running input BBLs 
        through Geosupport's BL function.
    3) Creates category and expanded category fields for use types

        Categories are:
        -- 1: Everything else
        -- 2: Residential
        -- 3: No current use

        Expanded categories are:
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

    4) Backfills missing community districts by joining with PLUTO on the geosupport-returned
        billing BBL.
    
INPUTS: 

    dcas_ipis (
        boro,
        block,
        lot,
        * bbl,
        house_number,
        street_name,
        cd,
        parcel_name,
        agency,
        primary_use_code,
        u_a_use_cod
    )

    dcas_ipis_geocodes (
        * input_bbl,
        bill_bbl,
        longitude,
        latitude,
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
        billbbl,
        cd,
        hnum,
        sname,
        address,
        name,
        agency,
        usecode,
        usetype,
        category,
        expandcat,
        leased,
        finalcom,
        agreement,
        xcoord,
        ycoord,
        geom
    )
*/

DROP TABLE IF EXISTS _colp CASCADE;
WITH 
geo_merge as (
    SELECT 
        a.boro as borough,
        a.block,
        a.lot,
        a.bbl,
        -- Add geosupport-returned billing BBL
        (CASE 
            WHEN b.bill_bbl = '0000000000' OR b.bill_bbl IS NULL
                THEN b.geo_bbl
            ELSE b.bill_bbl
        END) as billbbl,
        -- Create temp cd field from IPIS, pre-pluto backfill
        (CASE 
            WHEN a.cd::text LIKE '_0' OR a.cd IS NULL 
                THEN NULL
            ELSE a.cd::text 
        END) as _cd,
        -- Include address from source data
        a.house_number as _hnum,
        a.street_name as _sname,
        a.parcel_name as _name,
        a.agency,
        -- Create temp use code field, without 1900 cleaning
        (LPAD(split_part(a.primary_use_code::text, '.', 1), 4, '0')) as _usecode,
        -- Create temp use type field, without 1900 cleaning
        a.primary_use_text as _usetype,
        -- Fill null ownership values
        (CASE 
            WHEN a.owner IS NULL 
                THEN 'P' 
            ELSE a.owner 
        END) as ownership,
        a."owned/leased" as leased,
        -- Set final commitment as D for dispositions
        (CASE 
            WHEN a.u_f_use_code IS NULL OR a.u_f_use_code = ''
                THEN NULL 
            ELSE 'D' 
        END) as finalcom,
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
        b.x_coord as xcoord,
        b.y_coord as ycoord,
        b.latitude,
        b.longitude,
        (CASE
            WHEN b.longitude IS NOT NULL AND b.longitude <> ''
            THEN ST_SetSRID(ST_MakePoint(b.longitude::double precision, b.latitude::double precision),4326)
            ELSE NULL
        END) as geom
    FROM dcas_ipis a
    LEFT JOIN dcas_ipis_geocodes b
    ON a.bbl = b.input_bbl
    WHERE a.owner <> 'R'
),

address_merge AS (
    SELECT a.*,
    b.normalized_hnum as hnum,
    b.normalized_sname as sname,
    (CASE 
            WHEN b.normalized_hnum IS NOT NULL AND b.normalized_hnum <> ''
                THEN CONCAT(b.normalized_hnum, ' ', b.normalized_sname)
            ELSE b.normalized_sname
    END) as address
    FROM geo_merge a
    LEFT JOIN dcas_ipis_addresses b
    ON a.bbl = b.dcas_bbl
    AND a._hnum = b.dcas_hnum
    AND a._sname = b.dcas_sname
),

pluto_merge AS (
    SELECT
        a.*,
        -- Backfill missing cd with pluto
        (CASE 
            WHEN a._cd IS NULL 
                THEN b.cd::text
            ELSE a._cd
        END) as cd
    FROM address_merge a 
    LEFT JOIN dcp_pluto b
    ON a.bbl::text = b.bbl::text
),

normed_name_merge as (
    SELECT
        a.*,
        b.new_name as name
    FROM pluto_merge a
    LEFT JOIN dcas_ipis_parcel_names b
    ON a._name = b.old_name
),

categorized as (
    SELECT 
        a.*,
        -- In-use tenanted use codes should all be 1900. Length is in agreement field.
        (CASE
            WHEN a._usecode IN ('1910', '1920', '1930')
            THEN '1900'
            ELSE a._usecode
        END) as usecode,
        -- In-use tenanted use types should all be 1900. Length is in agreement field.
        (CASE
            WHEN a._usecode IN ('1910', '1920', '1930')
            THEN 'IN USE-TENANTED'
            ELSE a._usetype
        END) as usetype,
        -- Parse use codes to create categories
        (CASE
                WHEN a._usecode LIKE '15%' THEN '3'
                WHEN a._usecode LIKE '14%' THEN '2'
                WHEN a._usecode IS NULL OR a._usecode LIKE '16%' THEN NULL
                ELSE '1'
            END) as category,
        -- Parse use codes to create expanded categories
        (CASE
            WHEN a._usecode LIKE '01%' 
                OR a._usecode = '1310'
                OR a._usecode = '1340'
                OR a._usecode = '1341'
                OR a._usecode = '1349' THEN '1'
            WHEN a._usecode LIKE '02%' THEN '2'
            WHEN a._usecode LIKE '03%'
                OR a._usecode LIKE '04%'
                OR a._usecode = '1330' THEN '3'
            WHEN a._usecode LIKE '05%' 
                OR a._usecode LIKE '12%' 
                OR a._usecode = '1390' THEN '4'
            WHEN a._usecode LIKE '06%'
                OR a._usecode LIKE '07%' THEN '5'
            WHEN a._usecode LIKE '19%'
                OR a._usecode = '1342' THEN '6'
            WHEN a._usecode LIKE '08%'
                OR a._usecode LIKE '09%'
                OR a._usecode LIKE '10%'
                OR a._usecode LIKE '11%' 
                OR a._usecode = '1312'
                OR a._usecode = '1313'
                OR a._usecode = '1350'
                OR a._usecode = '1360'
                OR a._usecode = '1370'
                OR a._usecode = '1380' THEN '7'
            WHEN a._usecode LIKE '15%'
                OR a._usecode = '1420' THEN '8'
            WHEN a._usecode = '1410' 
                OR a._usecode = '1400'THEN '9'
            ELSE NULL
        END) as expandcat,
        -- Parse use codes to create expanded category descriptions
        (CASE
            WHEN a._usecode LIKE '01%' 
                OR a._usecode = '1310'
                OR a._usecode = '1340'
                OR a._usecode = '1341'
                OR a._usecode = '1349' THEN 'OFFICE USE'
            WHEN a._usecode LIKE '02%' THEN 'EDUCATIONAL USE'
            WHEN a._usecode LIKE '03%'
                OR a._usecode LIKE '04%'
                OR a._usecode = '1330' THEN 'CULTURAL & RECREATIONAL USE'
            WHEN a._usecode LIKE '05%' 
                OR a._usecode LIKE '12%' 
                OR a._usecode = '1390' THEN 'PUBLIC SAFETY & CRIMINAL JUSTICE USE'
            WHEN a._usecode LIKE '06%'
                OR a._usecode LIKE '07%' THEN 'HEALTH & SOCIAL SERVICES USE'
            WHEN a._usecode LIKE '19%'
                OR a._usecode = '1342' THEN 'LEASED OUT TO PRIVATE TENANT'
            WHEN a._usecode LIKE '08%'
                OR a._usecode LIKE '09%'
                OR a._usecode LIKE '10%'
                OR a._usecode LIKE '11%' 
                OR a._usecode = '1312'
                OR a._usecode = '1313'
                OR a._usecode = '1350'
                OR a._usecode = '1360'
                OR a._usecode = '1370'
                OR a._usecode = '1380' THEN 'MAINTENANCE, STORAGE, & INFRASTRUCTURE USE'
            WHEN a._usecode LIKE '15%'
                OR a._usecode = '1420' THEN 'PROPERTY WITH NO USE'
            WHEN a._usecode = '1410' 
                OR a._usecode = '1400'THEN 'PROPERTY WITH RESIDENTIAL USE'
            ELSE NULL
        END) as excatdesc
    FROM normed_name_merge a
)

-- Reorder columns for output
SELECT
    borough::varchar(2) as "BOROUGH",
    trim(block)::numeric(10,0) as "BLOCK",
    lot::numeric(5,0) as "LOT",
    bbl::numeric(19,8) as "BBL",
    billbbl::numeric(19,8) as "BILLBBL",
    cd::numeric(5,0) as "CD",
    hnum::varchar(20) as "HNUM",
    sname::varchar(40) as "SNAME",
    address as "ADDRESS",
    name as "NAME",
    agency::varchar(20) as "AGENCY",
    usecode::varchar(4) as "USECODE",
    usetype as "USETYPE",
    ownership::varchar(2) as "OWNERSHIP",
    category as "CATEGORY",
    expandcat as "EXPANDCAT",
    excatdesc as "EXCATDESC",
    leased::varchar(2) as "LEASED",
    finalcom::varchar(2) as "FINALCOM",
    agreement::varchar(2) as "AGREEMENT",
    round(xcoord::numeric)::numeric(10,0) as "XCOORD",
    round(ycoord::numeric)::numeric(10,0) as "YCOORD",
    latitude::numeric(19,7) as "LATITUDE",
    longitude::numeric(19,7) as "LONGITUDE",
    geom as "GEOM"
INTO _colp
FROM categorized;
