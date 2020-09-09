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

g = Geosupport()
engine = create_engine(os.getenv('BUILD_ENGINE'))

def get_sname(street_name_in): 
    try:
        geo = g['N*'](street_name=street_name_in)
        return geo.get('First Street Name Normalized', '')
    except:
        return ''

def get_address(house_number_in, street_name_in):
    hnum = '' if house_number_in is None else house_number_in.upper()
    if house_number_in is not None and house_number_in.replace('0','') == '':
        hnum = ''
        sname = get_sname(street_name_in)
    elif house_number_in is not None and house_number_in.replace('BED OF','') == '':
        hnum = ''
        sname = "BED OF " + get_sname(street_name_in)
    else:
        hnum = re.sub(r"[^0-9a-zA-Z \-/]+", "", hnum)\
        .replace(' - ', '')\
        .strip()\
        .lstrip('0')\
        .lstrip('-')
        sname = get_sname(street_name_in)
    return {'hnum':hnum, 'sname':sname}

def normalize(inputs):
    house_number = inputs.pop('house_number')
    street_name = inputs.pop('street_name')
    bbl = inputs.pop('bbl')
    address = get_address(house_number, street_name)
    return {'input_bbl':bbl,
            'input_hnum': house_number,
            'hnum': address.pop('hnum'),
            'input_sname': street_name, 
            'sname': address.pop('sname')}

if __name__ == '__main__':
    df = pd.read_sql('''SELECT DISTINCT bbl, house_number, street_name
                        from dcas_ipis''',
                    con=engine)
    print(f'Input data shape: {df.shape}')

    records = df.to_dict('records')
    
    print('Address normalization begins here ...')
    # Multiprocess
    with Pool(processes=cpu_count()) as pool:
        it = pool.map(normalize, records, 10000)
    
    print('Address normalization finished ...')
    result = pd.DataFrame(it)
    print(result.head())

    table_name = f'dcas_ipis_addresses'
    exporter(result, table_name, con=engine, sep='~', null='')