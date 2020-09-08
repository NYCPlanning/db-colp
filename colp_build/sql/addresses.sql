SELECT a.input_bbl as dcas_bbl, 
    a.input_hnum as dcas_hnum, 
    a.input_sname as dcas_sname, 
    a.hnum as cleaned_hnum, 
    a.sname as normalized_sname,  
    b.hnum as geo_hnum, 
    b.sname as geo_sname,  
    b.geo_function,
    b.grc,
    b.msg
INTO address_comparison
FROM dcas_ipis_addresses a
LEFT JOIN dcas_ipis_geocodes b
ON a.input_bbl = b.input_bbl;