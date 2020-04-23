# City Owned and Leased Properties Database ![CI](https://github.com/NYCPlanning/db-colp/workflows/CI/badge.svg)

Various city authorities own or lease a large inventory of properties. This repo contains code to create a database of all city owned and leased properties, as required under Section 204 of the City Charter. The database contains information about each property's use, owning/leasing agency, location, and tenent agreements. This repo is a refactoring of the dataset found on [Bytes of the Big Apple](https://www1.nyc.gov/site/planning/about/publications/colp.page), and is currently in development.

The input data for COLP is the Integrated Property Information System (IPIS), a real estate database maintained by the Department of Citywide Administrative Services (DCAS).

## Building COLP
To build COLP, add an entry in [`maintenance/log.md`](https://github.com/NYCPlanning/db-colp/blob/master/maintenance/log.md), then commit with **`[build]`** in the commit message. More detailed intructions for building COLP are contained in [`maintenance/instructions.md`](https://github.com/NYCPlanning/db-colp/blob/master/maintenance/instructions.md).

## Data Dictionary
As this version of the COLP database is currently in development, the output schema is not yet stable.

+ `borough`: Numeric borough code
+ `block`: Tax block
+ `lot`: Tax lot
+ `cd`: Three-digit community district, with borough code as the first digit
+ `hnum`: Building number portion of property address
+ `street`: Street portion of property address
+ `parcel`: Parcel name, where exists
+ `agency`: Code for owning/leasing agency
+ `use_code`: Four-digit use-code derived from IPIS
+ `use_type`: Description associated with use-code
+ `ownership`: Ownership type
    + C: City-owned
    + P: Privately owned
    + M: Mixed (either 'C' & 'P' or 'C' & 'O')
    + O: Other public agencies/authorities
+ `leased`: Flag indicating whether the property is owned or leased
    + O: Owned
    + L: Leased
+ `final_commit`: Flag indicating whether the property is a disposition
+ `agreement`: Agreement type
    + L: Long-term
    + S: Short-term
    + M: Mixed
+ `category_code`:
    + 1: Other
    + 2: Residential use
    + 3: No current use
+ `expanded_cat_code`:
    + 1: Offices
    + 2: Educational facilities
    + 3: Recreational & cultural facilities
    + 4: Public safety and judicial
    + 5: Health & social services
    + 6: Tenented & retail
    + 7: Transportation & infrastructure
    + 8: Not in use
    + 9: In-use residential
