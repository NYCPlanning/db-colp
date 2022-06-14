DROP TABLE IF EXISTS modifications;
CREATE TABLE modifications(
    uid text,
    field text,
    old_value text,
    new_value text,
    editor text,
    date text,
    notes text
);


\COPY modifications FROM 'data/modifications.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS reviewed_modified_names;
CREATE TABLE reviewed_modified_names(
    dcas_bbl text,
    dcas_hnum text,
    display_hnum character varying(20),
    dcas_sname text,
    sname_1b text,
    parcel_name character varying,
    display_name text,
    agency character varying,
    primary_use_code character varying,
    primary_use_text character varying,
    reviewed text
);

\COPY reviewed_modified_names FROM 'data/ipis_modified_names.csv' DELIMITER ',' CSV HEADER;


DROP TABLE IF EXISTS modifications_by_ID;
CREATE TABLE modifications_by_ID as (
    SELECT uid as old_uid, NULL new_uid, field, old_value, new_value, editor, date, notes from modifications WHERE field = 'AGREEMENT'
);


DROP TABLE IF EXISTS modifications_by_value;
CREATE TABLE modifications_by_value as (
    SELECT  DISTINCT NULL as uid, field, old_value, new_value from modifications WHERE field <> 'AGREEMENT'
)