from multiprocessing import Pool, cpu_count
from utils.exporter import exporter
from geosupport import Geosupport, GeosupportError
from sqlalchemy import create_engine
from datetime import date
import pandas as pd
import json
import os 

g = Geosupport()
engine = create_engine(os.getenv('BUILD_ENGINE'))

def get_address(bbl):
    try:
        geo = g['BL'](bbl=bbl)
        addresses = geo.get('LIST OF GEOGRAPHIC IDENTIFIERS', '')
        filter_addresses = [d for d in addresses if d['Low House Number'] != '' and d['5-Digit Street Code'] != '']
        address = filter_addresses[0]
        b5sc = address.get('Borough Code', '0')+address.get('5-Digit Street Code', '00000')
        sname = get_sname(b5sc)
        hnum = address.get('Low House Number', '')
        return dict(sname=sname, hnum=hnum)
    except:
        return dict(sname='', hnum='')

def get_sname(b5sc): 
    try:
        geo = g['D'](B5SC=b5sc)
        return geo.get('First Street Name Normalized', '')
    except:
        return ''

def geocode(inputs):
    bbl = inputs.pop('bbl')
    address = get_address(bbl)

    sname = address.get('sname', '')
    hnum = address.get('hnum', '')
    borough = bbl[0]

    try: 
        geo1 = g['1A'](street_name=sname, house_number=hnum, borough=borough, mode='regular')
        geo2 = g['1E'](street_name=sname, house_number=hnum, borough=borough, mode='regular')
        geo = {**geo1, **geo2}
        geo = parse_output(geo)
        geo.update(input_bbl=bbl, input_hnum=hnum, input_sname=sname)
        return geo
    except GeosupportError: 
        try: 
            geo = g['1B'](street_name=sname, house_number=hnum, borough=borough, mode='regular')
            geo = parse_output(geo)
            geo.update(input_bbl=bbl, input_hnum=hnum, input_sname=sname)
            return geo
        except GeosupportError as e1:
            try:
                geo = g['BL'](bbl=bbl)
                geo = parse_output(geo)
                geo.update(input_bbl=bbl, input_hnum=hnum, input_sname=sname)
                return geo
            except GeosupportError as e2:
                geo = parse_output(e1.result)
                geo.update(input_bbl=bbl, input_hnum=hnum, input_sname=sname)
                return geo

def parse_output(geo):
    return dict(
        bbl = geo.get('BOROUGH BLOCK LOT (BBL)', '').get('BOROUGH BLOCK LOT (BBL)', ''),
        cd = geo.get('COMMUNITY DISTRICT', {}).get('COMMUNITY DISTRICT', ''),
        hnum = geo.get('House Number - Display Format', ''),
        sname = geo.get('First Street Name Normalized', ''),
        latitude = geo.get('Latitude', ''),
        longitude = geo.get('Longitude', ''),
        x_coord = '',
        y_coord = '', 
        grc = geo.get('Geosupport Return Code (GRC)', ''), 
        grc2 = geo.get('Geosupport Return Code 2 (GRC 2)', ''),
        msg = geo.get('Message', ''),
        msg2 = geo.get('Message 2', ''),
    )

if __name__ == '__main__':
    df = pd.read_sql('''SELECT DISTINCT bbl
                        from dcas_ipis''',
                    con=engine)
    print(f'input data shape: {df.shape}')

    records = df.to_dict('records')
    
    print('geocoding begins here ...')
    # Multiprocess
    with Pool(processes=cpu_count()) as pool:
        it = pool.map(geocode, records, 10000)
    
    print('geocoding finished ...')
    result = pd.DataFrame(it)
    print(result.head())

    table_name = f'dcas_ipis_geocodes'
    exporter(result, table_name, con=engine, sep='~', null='')

    engine.execute(f'''
        ALTER TABLE {table_name}
            ADD wkb_geometry geometry(Geometry,4326);
        UPDATE {table_name}
        SET wkb_geometry = ST_SetSRID(ST_Point(longitude::DOUBLE PRECISION,
                            latitude::DOUBLE PRECISION), 4326); 
        UPDATE {table_name}
        SET x_coord = ST_X(ST_TRANSFORM(wkb_geometry, 2263))::text,
            y_coord = ST_Y(ST_TRANSFORM(wkb_geometry, 2263))::text;
    ''')