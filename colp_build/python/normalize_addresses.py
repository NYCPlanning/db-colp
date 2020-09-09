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

def parse_output(geo):
    return dict(
        geo_bbl = geo.get('BOROUGH BLOCK LOT (BBL)', {}).get('BOROUGH BLOCK LOT (BBL)', ''),
        bill_bbl=geo.get("Condominium Billing BBL", ""),
        hnum = geo.get('House Number - Display Format', ''),
        sname = geo.get('First Street Name Normalized', ''),
        input_bbl = geo.get('input_bbl', ''),
        input_hnum = geo.get('input_hnum', ''),
        input_sname = geo.get('input_sname', ''),
        grc = geo.get('Geosupport Return Code (GRC)', ''), 
        grc2 = geo.get('Geosupport Return Code 2 (GRC 2)', ''),
        msg = geo.get('Message', ''),
        msg2 = geo.get('Message 2', '')
    )

def geocode_norms(norm_hnum, norm_sname, borough):
    try:
        geo = g['1A'](street_name=norm_sname, house_number=norm_hnum, borough=borough, mode='regular')
        geo = parse_output(geo)
        return geo
    except GeosupportError as e: 
        geo = parse_output(e.result)
        return geo

def normalize(inputs):
    house_number = inputs.pop('house_number')
    street_name = inputs.pop('street_name')
    bbl = inputs.pop('bbl')
    address = get_address(house_number, street_name)
    geo = geocode_norms(address.get('hnum', ''), address.get('sname', ''), bbl[0])
    return {'dcas_bbl':bbl,
            'dcas_hnum': house_number,
            'normalized_hnum': address.pop('hnum'),
            'dcas_sname': street_name, 
            'normalized_sname': address.pop('sname'),
            '"1a_bbl"': geo.pop('geo_bbl'),
            '"1a_bill_bbl"': geo.pop('bill_bbl'),
            '"1a_grc"': geo.pop('grc'),
            '"1a_grc2"': geo.pop('grc2'),
            '"1a_msg"': geo.pop('msg'),
            '"1a_msg2"': geo.pop('msg2')}

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