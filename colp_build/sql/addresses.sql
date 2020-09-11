DROP TABLE IF EXISTS address_comparison;
SELECT a.dcas_bbl, 
    a."1a_bbl",
    a."1a_bill_bbl",
    b.bill_bbl as bl_bill_bbl,
    a.dcas_hnum, 
    a.dcas_sname, 
    a.normalized_hnum, 
    a.normalized_sname,  
    b.hnum as bl_hnum, 
    b.sname as bl_sname,  
    b.geo_function as bl_geo_func,
    b.grc as bl_grc,
    b.grc2 as bl_grc2,
    b.msg as bl_msg,
    b.msg2 as bl_msg2,
    a."1a_grc",
    a."1a_grc2",
    a."1a_msg",
    a."1a_msg2"
INTO address_comparison
FROM dcas_ipis_addresses a
LEFT JOIN dcas_ipis_geocodes b
ON a.dcas_bbl = b.input_bbl;