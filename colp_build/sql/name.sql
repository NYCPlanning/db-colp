DROP TABLE IF EXISTS dcas_parcel_names;
WITH compare AS(
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
		                                                                                    REGEXP_REPLACE(
		                                                                                        REGEXP_REPLACE(
		                                                                                            REGEXP_REPLACE(TRIM(parcel_name)||' ', 
		                                                                                            ' & ', 
		                                                                                            ' AND '
		                                                                                            ), 
		                                                                                        'PLAYLOT|PLGD|PLAYGRD|PLAYGND|PLYGRND|PLYGD|PLAYGRND|PLYGRD|PLGRD|PLGD.|PLYGD|PLAYGD', 
		                                                                                        'PLAYGROUND'
		                                                                                        ),
		                                                                                    '@',
		                                                                                    'AT'
		                                                                                    ),
		                                                                                'HSES',
		                                                                                'HOUSES'
		                                                                                ),
		                                                                            ' \(GROUP 1 ',
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
		                                                    'N.Y.C.P.D.|NYCPD',
		                                                    'NYPD'
		                                                    ),
		                                                'F.H.A..',
		                                                'FHA '
		                                                ),
		                                            'GDN |GARD ',
		                                            'GARDEN '
		                                            ),
	                                            'AVE\)|AVE.\)',
	                                            'AVENUE)'
	                                            ),
                                            '\(AVE|\(AVE.',
                                            '(AVENUE'
                                            ),
                                        ' AVE | AVE. | AVE- | AVE. | AV ',
                                        ' AVENUE '
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
            'MN |MANH ',
            'MANHATTAN '
            ),
    'REHABS\(|REHAB\(',
    'REHAB ('
    ),
'REHABS|REHAS',
'REHAB'
)) as new_name,
parcel_name as old_name
FROM dcas_ipis)

SELECT *
INTO dcas_parcel_names
FROM compare;
