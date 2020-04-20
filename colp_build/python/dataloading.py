from cook import Importer
import os

RECIPE_ENGINE = os.environ.get('RECIPE_ENGINE', '')
BUILD_ENGINE=os.environ.get('BUILD_ENGINE', '')
EDM_DATA = os.environ.get('EDM_DATA', '')

def ETL(schema_name):
    importer = Importer(RECIPE_ENGINE, BUILD_ENGINE)
    importer.import_table(schema_name=schema_name)

def PLUTO_ETL():
    importer = Importer(EDM_DATA, BUILD_ENGINE)
    importer.import_table(schema_name='dcp_pluto', version='20v3')

if __name__ == "__main__":
    ETL('dcas_ipis')
    PLUTO_ETL()