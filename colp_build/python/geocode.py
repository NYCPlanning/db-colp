from multiprocessing import Pool, cpu_count
from utils.exporter import exporter
from geosupport import Geosupport, GeosupportError
from sqlalchemy import create_engine
from datetime import date
import pandas as pd
import numpy as np
import json
import os 

g = Geosupport()
engine = create_engine(os.getenv('BUILD_ENGINE'))

def get_sname(b5sc): 
    try:
        geo = g['D'](B5SC=b5sc)
        return geo.get('First Street Name Normalized', '')
    except:
        return ''

def parse_output(geo):
    return dict(
        geo_bbl = geo.get('BOROUGH BLOCK LOT (BBL)', {}).get('BOROUGH BLOCK LOT (BBL)', ''),
        bill_bbl=geo.get("Condominium Billing BBL", ""),
        cd = geo.get('COMMUNITY DISTRICT', {}).get('COMMUNITY DISTRICT', ''),
        hnum = geo.get('House Number - Display Format', ''),
        sname = geo.get('First Street Name Normalized', ''),
        latitude = geo.get('Latitude', ''),
        longitude = geo.get('Longitude', ''),
        x_coord = '',
        y_coord = '', 
        input_bbl = geo.get('input_bbl', ''),
        input_hnum = geo.get('input_hnum', ''),
        input_sname = geo.get('input_sname', ''),
        grc = geo.get('Geosupport Return Code (GRC)', ''), 
        grc2 = geo.get('Geosupport Return Code 2 (GRC 2)', ''),
        msg = geo.get('Message', ''),
        msg2 = geo.get('Message 2', ''),
    )

def geocode(inputs):
    bbl = inputs.pop('bbl')
    borough = bbl[0]

    # Run input BBL through BL to get address. BL output gets saved in case 1A/1B fail.
    try:
        geo_bl = g['BL'](bbl=bbl)
        
        # Extract first address associated with BBL
        addresses = geo_bl.get('LIST OF GEOGRAPHIC IDENTIFIERS', '')
        
        # Prioritize addresses with  both hnum and 5sc
        ideal_addresses = [d for d in addresses if d['Low House Number'] != '' and d['5-Digit Street Code'] != '']
       
        # If none have hnum, take first address with a 5sc
        if len(ideal_addresses) == 0:
            ideal_addresses = [d for d in addresses if d['5-Digit Street Code'] != '']

        address = ideal_addresses[0] if len(ideal_addresses) > 0 else {}

        # Use boro and 5sc to translate into sname
        b5sc = address.get('Borough Code', '0')+address.get('5-Digit Street Code', '00000')
        sname = get_sname(b5sc)
        hnum = address.get('Low House Number', '')

        # Parse BL call outputs
        geo_bl = parse_output(geo_bl)
        geo_bl.update(input_bbl=bbl, input_hnum='', input_sname='', geo_function='BL')
        geo_bl['hnum'] = hnum
        geo_bl['sname'] = sname

    except GeosupportError as e1:
        hnum = ''
        sname = ''
        geo = parse_output(e1.result)
        geo.update(input_bbl=bbl, input_hnum=hnum, input_sname=sname, geo_function='BL')
        return geo

    # Run address returned from BL through functions 1A and 1B.
    try:
        geo = g['1A'](street_name=sname, house_number=hnum, borough=borough, mode='regular')
        geo = parse_output(geo)
        geo.update(input_bbl=bbl, input_hnum=hnum, input_sname=sname, geo_function='1A')
        return geo
    except GeosupportError: 
        try: 
            geo = g['1B'](street_name=sname, house_number=hnum, borough=borough, mode='regular')
            geo = parse_output(geo)
            geo.update(input_bbl=bbl, input_hnum=hnum, input_sname=sname, geo_function='1B')
            # If 1B succeeded but did not return coordinates, use BL results
            if geo['latitude'] == '' and geo['longitude'] == '':
                return geo_bl
            else:
                return geo
        except GeosupportError as e1:
            # Return BL results calculated previously, since no better results were found
            try:        
                return geo_bl
            except:
                # Output most recent geosupport error (1B) for research
                geo = parse_output(e1.result)
                geo.update(input_bbl=bbl, input_hnum=hnum, input_sname=sname)
                return geo

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
    print(list(result))
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