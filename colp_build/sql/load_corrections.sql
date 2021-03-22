DROP TABLE IF EXISTS corrections;
CREATE TABLE corrections(
    dcas_ipis_uid text,
    field text,
    old_value text,
    new_value text,
    editor text,
    date text,
    notes text
);

\COPY corrections FROM '_data/corrections.csv' DELIMITER ',' CSV HEADER;
