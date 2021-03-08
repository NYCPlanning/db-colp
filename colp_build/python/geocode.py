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

def parse_output(geo):
    return dict(
        geo_bbl = geo.get('BOROUGH BLOCK LOT (BBL)', {}).get('BOROUGH BLOCK LOT (BBL)', ''),
        bill_bbl=geo.get("Condominium Billing BBL", ""),
        latitude = geo.get('Latitude', ''),
        longitude = geo.get('Longitude', ''),
        x_coord = '',
        y_coord = '', 
        input_bbl = geo.get('input_bbl', ''),
        grc = geo.get('Geosupport Return Code (GRC)', ''), 
        rsn = geo.get('Reason Code', ''),
        msg = geo.get('Message', ''),
    )

def geocode(inputs):
    bbl = inputs.pop('bbl')
    borough = bbl[0]

    # Run input BBL through BL to get address. BL output gets saved in case 1A/1B fail.
    try:
        geo_bl = g['BL'](bbl=bbl)
        geo_bl = parse_output(geo_bl)

    except GeosupportError as e1:
        geo_bl = parse_output(e1.result)
    
    geo_bl.update(input_bbl=bbl, geo_function='BL')
    return geo_bl

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