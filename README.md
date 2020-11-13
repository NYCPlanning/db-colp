# City Owned and Leased Properties Database ![CI](https://github.com/NYCPlanning/db-colp/workflows/CI/badge.svg)

Various city authorities own or lease a large inventory of properties. This repo contains code to create a database of all city owned and leased properties, as required under Section 204 of the City Charter. The database contains information about each property's use, owning/leasing agency, location, and tenent agreements. This repo is a refactoring of the dataset found on [Bytes of the Big Apple](https://www1.nyc.gov/site/planning/about/publications/colp.page), and is currently in development.

The input data for COLP is the Integrated Property Information System (IPIS), a real estate database maintained by the Department of Citywide Administrative Services (DCAS).

## Outputs
| File | Description |
| ---- | ----------- |
| [colp.zip](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/colp.zip) | Shapefile version COLP database, only including records with coordinates |
| [colp.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/colp.csv) | CSV version COLP database, only including records with coordinates |
| [colp_unmapped.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/colp_unmapped.csv) | Records from COLP that did not successfully geocode, along with error messages from Geosupport |
| [address_comparison.csv](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/address_comparison.csv) | Comparison of addresses between DCAS IPIS form, normalized form, and addresses returned by geocoding on BBL |
| [version.txt](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/version.txt) | Versions of the input data |
| [All files](https://edm-publishing.nyc3.digitaloceanspaces.com/db-colp/latest/output/output.zip) | All outputs in a compressed directory |

## Additional Resources
Look-up tables for agency abbreviations and use types are availaible in CSV form under [`/resources`](https://github.com/NYCPlanning/db-colp/tree/master/resources)

## Building COLP
To build COLP, add an entry in [`maintenance/log.md`](https://github.com/NYCPlanning/db-colp/blob/master/maintenance/log.md), then commit with **`[build]`** in the commit message. More detailed intructions for building COLP are contained in [`maintenance/instructions.md`](https://github.com/NYCPlanning/db-colp/blob/master/maintenance/instructions.md).

## Data Dictionary

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

`BILLBBL` 
+ **Longform name:** Billing BBL 
+ **Data source:** Department of City Planning 
+ **Description:** For condominium lots, the billing BBL is the 75nn-series record shown on the tax map and in MapPLUTO. It is generally associated with the condominium management organization. For non-condo lots, BILLBBL is the same as BBL. 
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
+ **Description:** Name of the parcel or facility on the lot     
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

`GEOM`
+ **Longform name:** Geometry
+ **Description:** Point geometry type
+ **Data type:** geometry
