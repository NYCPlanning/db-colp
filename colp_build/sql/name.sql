WITH compare AS (
SELECT
TRIM(
REGEXP_REPLACE(
    REGEXP_REPLACE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(
                        REGEXP_REPLACE(
                            REGEXP_REPLACE(
                                REGEXP_REPLACE(
                                    REGEXP_REPLACE(
                                        REGEXP_REPLACE(
                                            REGEXP_REPLACE(
                                                REGEXP_REPLACE(
                                                    REGEXP_REPLACE(
                                                        REGEXP_REPLACE(
                                                            REGEXP_REPLACE(
                                                                REGEXP_REPLACE(
                                                                    REGEXP_REPLACE(
                                                                        REGEXP_REPLACE(
                                                                            REGEXP_REPLACE(
                                                                                REGEXP_REPLACE(
                                                                                    REGEXP_REPLACE(
                                                                                        REGEXP_REPLACE(TRIM(parcel_name)||' ', 
                                                                                        '&', 
                                                                                        'AND'
                                                                                        ), 
                                                                                    'PLAYLOT|PLGD|PLAYGRD|PLAYGND|PLYGRND|PLAYGRND|PLYGRD', 
                                                                                    'PLAYGROUND'
                                                                                    ),
                                                                                '@',
                                                                                'AT'
                                                                                ),
                                                                            'HSES',
                                                                            'HOUSES'
                                                                            ),
                                                                        ' GROUP 1 |\(GROUP 1 ',
                                                                        ' (GROUP 1) '
                                                                        ),
                                                                    ' PK',
                                                                    ' PARK'
                                                                    ),
                                                                'STA ',
                                                                'STATION '
                                                                ),
                                                            'LIBR ',
                                                            'LIBRARY '
                                                            ),
                                                        'INDUST PK|IND. PARK',
                                                        'INSUSTRIAL PARK'
                                                        ),
                                                    'PCT |PCT. ',
                                                    'PRECINCT '
                                                    ),
                                                'N.Y.C.P.D.',
                                                'NYPD'
                                                ),
                                            'F.H.A..|F.H.A. ',
                                            'FHA '
                                            ),
                                        'GDN |GARD ',
                                        'GARDEN '
                                        ),
                                    'AVE |AVE. |AVE- ',
                                    'AVENUE '
                                    ),
                                'HUNTS%POINT%AVENUE%REHAB',
                                'HUNTS POINT AVENUE REHAB'
                                ),
                            'AUTH ',
                            'AUTHORITY '
                            ),
                        'BK|BKLYN',
                        'BROOKLYN'
                        ),
                    'BX |BRNX ',
                    'BRONX '
                    ),
                'QNS ',
                'QUEENS '
                ),
            ' SI ',
            ' STATEN ISLAND '
            ),
        'MN ',
        'MANHATTAN '
        ),
    '\(JOP ',
    '(JOP)'
    ),
'REHABS\(ANDERSON',
'REHABS ANDERSON'
)) as new_name,
parcel_name as old_name
FROM dcas_ipis)

SELECT *
INTO dcas_parcel_names
FROM compare;
