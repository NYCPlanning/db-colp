DROP TABLE IF EXISTS corrections;
CREATE TABLE corrections(
    uid text,
    field text,
    old_value text,
    new_value text,
    editor text,
    date text,
    notes text
);

\COPY corrections FROM '_data/corrections.csv' DELIMITER ',' CSV HEADER;

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

\COPY reviewed_modified_names FROM '_data/ipis_modified_names.csv' DELIMITER ',' CSV HEADER;