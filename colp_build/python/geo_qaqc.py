from multiprocessing import Pool, cpu_count
from utils.exporter import exporter
from geosupport import Geosupport, GeosupportError
from sqlalchemy import create_engine
from datetime import date
import pandas as pd
import numpy as np
import json
import re
import os 
import sys
sys.path.append('../')

g = Geosupport()
engine = create_engine(os.getenv('BUILD_ENGINE'))

def parse_output(geo):
    return dict(
        geo_bbl = geo.get('BOROUGH BLOCK LOT (BBL)', {}).get('BOROUGH BLOCK LOT (BBL)', ''),
        bill_bbl=geo.get("Condominium Billing BBL", ""),
        hnum = geo.get('House Number - Display Format', ''),
        sname = geo.get('First Street Name Normalized', ''),
        input_bbl = geo.get('input_bbl', ''),
        input_hnum = geo.get('input_hnum', ''),
        input_sname = geo.get('input_sname', ''),
        grc_1e = geo.get('Geosupport Return Code (GRC)', ''), 
        grc_1a = geo.get('Geosupport Return Code 2 (GRC 2)', ''),
        rsn_1e = geo.get('Reason Code', ''),
        rsn_1a = geo.get('Reason Code 2', ''),
        msg_1e = geo.get('Message', ''),
        msg_1a = geo.get('Message 2', '')
    )

def geocode(hnum_in, sname_in, borough_in):
    try:
        geo = g['1B'](street_name=sname_in, house_number=hnum_in, borough=borough_in, mode='regular')
        geo = parse_output(geo)
        return geo
    except GeosupportError as e: 
        geo = parse_output(e.result)
        return geo

def run_1b(inputs):
    uid = inputs.get('uid')
    house_number = inputs.get('house_number')
    street_name = inputs.get('street_name')
    bbl = inputs.get('bbl')
    geo_dcas = geocode(re.sub(r"¦", "", house_number), street_name, bbl[0])
    return {'dcas_ipis_uid': uid,
            'dcas_bbl': bbl,
            'dcas_hnum': house_number,
            'dcas_sname': street_name, 
            'hnum_1b': geo_dcas.pop('hnum'),
            'sname_1b': geo_dcas.pop('sname'),
            'bbl_1b': geo_dcas.pop('geo_bbl'),
            'bill_bbl_1b': geo_dcas.pop('bill_bbl'),
            'grc_1a': geo_dcas.pop('grc_1a'),
            'rsn_1a': geo_dcas.pop('rsn_1a'),
            'msg_1a': geo_dcas.pop('msg_1a'),
            'grc_1e': geo_dcas.pop('grc_1e'),
            'rsn_1e': geo_dcas.pop('rsn_1e'),
            'msg_1e': geo_dcas.pop('msg_1e')}

if __name__ == '__main__':
    df = pd.read_sql('''SELECT DISTINCT 
                            md5(CAST((dcas_ipis.*)AS text)) as uid, 
                            bbl, 
                            house_number, 
                            street_name
                        from dcas_ipis''',
                    con=engine)
    print(f'Input data shape: {df.shape}')

    records = df.to_dict('records')
    
    # Multiprocess
    print('Geocode DCAS addresses with 1B...')
    with Pool(processes=cpu_count()) as pool:
        it = pool.map(run_1b, records, 10000)

    print('Geocoding finished ...')
    result = pd.DataFrame(it)
    print(result.head())

    table_name = f'geo_qaqc'
    exporter(result, table_name, con=engine, sep='~', null='')