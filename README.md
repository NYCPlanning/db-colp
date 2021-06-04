# City Owned and Leased Properties Database ![CI](https://github.com/NYCPlanning/db-colp/workflows/CI/badge.svg)

Various city authorities own or lease a large inventory of properties. This repo contains code to create a database of all city owned and leased properties, as required under Section 204 of the City Charter. The database contains information about each property's use, owning/leasing agency, location, and tenent agreements. This repo is a refactoring of the dataset found on [Bytes of the Big Apple](https://www1.nyc.gov/site/planning/about/publications/colp.page), and is currently in development.

The input data for COLP is the Integrated Property Information System (IPIS), a real estate database maintained by the Department of Citywide Administrative Services (DCAS).

## Outputs
| File | Description |
| ---- | ----------- |
| [output.zip](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/2021-04-01/output/output.zip) | Zipped directory containing all files below |
| [colp.shp.zip](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/colp.shp.zip) | Shapefile version COLP database, only including records with coordinates |
| [colp.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/colp.csv) | CSV version COLP database, only including records with coordinates |
| [ipis_modified_hnums.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/ipis_modified_hnums.csv) | QAQC table of records with modified house numbers |
| [ipis_modified_names.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/ipis_modified_names.csv) | QAQC table of records with modified parcel names |
| [usetype_changes.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/usetype_changes.csv) | QAQC table of version-to-version changes in the number of records per use type |
| [modifications_applied.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/modifications_applied.csv) | Table of manual modifications that were applied |
| [modifications_not_applied.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/modifications_not_applied.csv) | Table of manual modifications that existed in the modifications table, but failed to get applied |
| [ipis_unmapped.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/ipis_unmapped.csv) | QAQC table of unmappable input records |
| [ipis_colp_geoerrors.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/ipis_colp_geoerrors.csv) | QAQC table of addresses that return errors (or warnings type 1-9, B, C, I, J) from 1B |
| [ipis_sname_errors.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/ipis_sname_errors.csv) | QAQC table of addresses that return streetname errors (GRC is 11 or EE) from 1B |
| [ipis_hnum_errors.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/ipis_hnum_errors.csv) | QAQC table of addresses that return out-of-range address errors (GRC is 41 or 42) from 1B |
| [ipis_bbl_errors.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/ipis_bbl_errors.csv) | QAQC table of records where address isn't valid for input BBL |
| [ipis_cd_errors.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/ipis_cd_errors.csv) | QAQC table of mismatch between IPIS community district and PLUTO |
| [version.txt](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/version.txt) | Build date |

## Additional Resources
Look-up tables for agency abbreviations and use types are availaible in CSV form under [`/resources`](https://github.com/NYCPlanning/db-colp/tree/master/resources)

## Building COLP
To build COLP, add an entry in [`maintenance/log.md`](https://github.com/NYCPlanning/db-colp/blob/master/maintenance/log.md), then commit with **`[build]`** in the commit message. More detailed intructions for building COLP are contained in [`maintenance/instructions.md`](https://github.com/NYCPlanning/db-colp/blob/master/maintenance/instructions.md).

## Data Dictionary
`UID`
+ **Longform name:** Unique ID
+ **Data source:** Department of City Planning 
+ **Description:** Unique identifier created from a hash of all fields for the record on the IPIS source file.  As long as no fields change on the record, this identifier is static between versions of COLP. 
+ **Data type:** `text`  
+ **Example:** cbe20732be28f6ab445289d7a67bb241

`BOROUGH`
+ **Longform name:** Borough 
+ **Description:** NYC borough – 1 (Manhattan), 2 (Bronx), 3 (Brooklyn), 4 (Queens), 5 (Staten Island) 
+ **Data type:** `text`  
+ **Example:** 1 

`BLOCK`
+ **Longform name:** Tax block     
+ **Description:** The tax block in which the tax lot is located. Each tax block is unique within a borough. 
+ **Data type:** `int`
+ **Example:** 1637 

`LOT`
+ **Longform name:** Tax lot     
+ **Description:** The number of the tax lot. Each tax lot is unique within a tax block. 
+ **Data type:** `int`     
+ **Example:** 141 

`BBL`
+ **Longform name:** BBL  
+ **Description:** 10-digit identifier for a tax lot, consisting of the borough code followed by the tax block followed by the tax lot. The borough code is one numeric digit. The tax block is one to five numeric digits, preceded with leading zeros when the block is less than five digits. The tax lot is one to four digits and is preceded with leading zeros when the lot is less than four digits. For condominiums, this is usually the unit BBL. 
+ **Data type:** `double` 
+ **Example:** 1016370141 

`MAPBBL` 
+ **Longform name:** Mapped BBL 
+ **Data source:** Department of City Planning 
+ **Description:** he mapped BBL is the BBL used to map the record. For condominium lots, the mapped BBL is the billing BBL, which is the 75nn-series record shown on the tax map and in MapPLUTO. It is generally associated with the condominium management organization. For air rights lots, the mapped BBL is the donating BBL from the Air_Rights_Lot table in the Department of Finance’s Digital Tax Map. If there is more than one donating BBL, the one whose lot number most closely matches that of the air rights lot is used.  For all other lots, MAPBBL is the same as BBL.   
+ **Data type:** `double` 
+ **Example:** 1016370141 

`CD` 
+ **Longform name:** Community district   
+ **Data source:** Department of City Planning 
+ **Description:** The community district or joint interest area for the tax lot. The city is divided into 59 community districts and 12 joint interest areas, which are large parks or airports that are not considered part of any community district. This field consists of three digits, the first of which is the borough code. The second and third digits are the community district or joint interest area number, whichever is applicable.
+ **Data type:** `int` 
+ **Example:** 111 

`HNUM`
+ **Longform name:** House number        
+ **Description:** House number 
+ **Data type:** `text` 
+ **Example:** 1955 

`SNAME` 
+ **Longform name:** Street name         
+ **Description:** Name of the street 
+ **Data type:** `text`
+ **Example:** Third Avenue 

`NAME`
+ **Longform name:** Parcel name 
+ **Description:** Name of the parcel or facility on the lot. DCP applies some modifications to parcel names to improve readability. Some abbreviations are expanded programmatically. Other modifications are made after manual research. For the latter, DCPEDITED = "Y".     
+ **Data type:** `text`
+ **Example:** AGUILAR BRANCH LIBRARY 

`AGENCY` 
+ **Longform name:** Agency   
+ **Description:** Abbreviation for agency using the lot. See appendix A for a list of abbreviations with their full name. 
+ **Data type:** `text`
+ **Example:** NYPL 

`USECODE`
+ **Longform name:** Use code 
+ **Description:** The use code indicates how the lot is being used by the agency. See Appendix B for a complete list of use codes and descriptions. 
+ **Data type:** `text`
+ **Example:** 0332 

`USETYPE`
+ **Longform name:** Use description  
+ **Description:** Description of how the lot is being used by the agency. See Appendix B for a complete list of use codes and descriptions. 
+ **Data type:** `text` 
+ **Example:** BRANCH LIBRARY 

`OWNERSHIP` 
+ **Longform name:** Owner type 
+ **Description:** Type of owner 
+ **Data type:** `text` 
+ **Values:**
   + C – City owned 
   + M – Mixed ownership 
   + P – Private 
   + O – Other/public authority (includes properties owned by federal and state entities) 

`CATEGORY`
+ **Longform name:** Category     
+ **Description:** Category classifies lots as non-residential properties with a current use, residential properties, or properties without a current use.  
+ **Data type:** `int` 
+ **Values:**
   + 1 – Non-residential properties with a current use 
   + 2 – Residential properties 
   + 3 – Properties with no current use  

`EXPANDCAT`
+ **Longform name:** Expanded category 
+ **Data source:** Department of City Planning 
+ **Description:** This categorization classifies records into broad groups based on use. Valid values are 1 – 9. 
+ **Data type:** `int` 
+ **Description of values:**
    + 1 – Office use 
    + 2 – Educational use 
    + 3 – Cultural & recreational use 
    + 4 – Public safety & criminal justice use 
    + 5 – Health & social service use 
    + 6 – Leased out to a private tenant 
    + 7 – Maintenance, storage & infrastructure 
    + 8 – Property with no use 
    + 9 – Property with a residential used 

`EXCATDESC`
+ **Longform name:** Expanded category description 
+ **Data source:** Department of City Planning 
+ **Description:** Descriptions for the expanded category values. See `EXPANDCAT` for the domain values. 
+ **Data type:** `text` 

`LEASED`
+ **Longform name:** Leased 
+ **Description:** A value of “L” indicates that the agency’s use of the property is authorized through a lease. For questions about the lease or ownership status of specific lots, please contact DCAS at (212) 386-0622 or RESPlanning311@dcas.nyc.gov.
+ **Data type:** `text` 
+ **Values:** L or blank 

`FINALCOM` 
+ **Longform name:** Final commitment     
+ **Description:** A value of “D” indicates potential disposition by the City.  
+ **Data type:** `text` 
+ **Values:** D or blank 

`AGREEMENT`
+ **Longform name:** Lease agreement 
+ **Description:** For City-owned properties that are leased to another entity, this field indicates whether the agreement is short-term, long-term, or there are both short- and long-term agreements present.
+ **Data type:** text 
+ **Values:**
   + S – Short term 
   + L – Long term 
   + M – Mixed (there are both short and long term leases on the property) 

`XCOORD` 
+ **Longform name:** X coordinate  
+ **Data source:** Department of City Planning 
+ **Description:** X coordinate based on the Geosupport label point for the billing BBL. Coordinate system is NAD 1983 State Plane New York Long Island FIPS 3104 Feet. 
+ **Data type:** `int` 
+ **Example:** 999900 

`YCOORD`
+ **Longform name:** Y coordinate  
+ **Data source:** Department of City Planning 
+ **Description:** Y coordinate based on the Geosupport label point for the billing BBL. Coordinate system is NAD 1983 State Plane New York Long Island FIPS 3104 Feet. 
+ **Data type:** `int` 
+ **Example:** 228619 

`LATITUDE` 
+ **Longform name:** Latitude  
+ **Data source:** Department of City Planning 
+ **Description:** Latitude based on the Geosupport label point for the billing BBL. Coordinate system is NAD_1983. 
+ **Data type:** double 
+ **Example:** 40.794169 

`LONGITUDE` 
+ **Longform name:** Longitude  
+ **Data source:** Department of City Planning 
+ **Description:** Longitude based on the Geosupport label point for the billing BBL. Coordinate system is NAD_1983. 
+ **Data type:** double 
+ **Example:** -73.943479

`DCPEDITED` 
+ **Longform name:** DCP Edited   
+ **Data source:** Department of City Planning 
+ **Description:** City Planning modifies some records to correct street names or normalize parcel names when programmatic cleaning are insufficient. If a field has been manually modified, the original value can be found in modifications_applied.csv (see outputs above).
+ **Data type:** text 
+ **Example:** Y

`GEOM`
+ **Longform name:** Geometry
+ **Description:** Point geometry type
+ **Data type:** geometry
