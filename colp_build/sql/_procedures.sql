DROP TABLE IF EXISTS corrections_applied;
CREATE TABLE corrections_applied (
	dcas_ipis_uid 	text,
	field 	  		text,
	current_value 	text,
	old_value 		text,
	new_value 		text
);

DROP TABLE IF EXISTS corrections_not_applied;
CREATE TABLE corrections_not_applied (
	dcas_ipis_uid 	text,
	field 	  		text,
	current_value 	text,
	old_value 		text,
	new_value 		text
);

DROP PROCEDURE IF EXISTS correction;
CREATE OR REPLACE PROCEDURE correction (
    _table text,
    _dcas_ipis_uid text,
    _field text,
    _old_val text,
    _new_val text
) AS $BODY$
DECLARE
    field_type text;
    current_val text;
    applicable boolean;
BEGIN
    EXECUTE format($n$
        SELECT pg_typeof(a.%1$I) FROM %2$I a LIMIT 1;
    $n$, _field, _table) INTO field_type;

    EXECUTE format($n$
        SELECT a.%1$I::text FROM %2$I a WHERE a.dcas_ipis_uid = %3$L;
    $n$, _field, _table, _dcas_ipis_uid) INTO current_val;

    EXECUTE format($n$
        SELECT %1$L::%3$s = %2$L::%3$s 
        OR (%1$L IS NULL AND %2$L IS NULL)
    $n$, current_val, _old_val, field_type) INTO applicable;

    IF applicable THEN 
        RAISE NOTICE 'Applying Correction';
        EXECUTE format($n$
            UPDATE %1$I SET %2$I = %3$L::%4$s WHERE dcas_ipis_uid = %5$L;
            $n$, _table, _field, _new_val, field_type, _dcas_ipis_uid);

        EXECUTE format($n$
            DELETE FROM corrections_applied WHERE dcas_ipis_uid = %1$L AND field = %2$L;
            INSERT INTO corrections_applied VALUES (%1$L, %2$L, %3$L, %4$L, %5L);
            $n$, _dcas_ipis_uid, _field, current_val, _old_val, _new_val);
    ELSE 
        RAISE NOTICE 'Cannot Apply Correction';
        EXECUTE format($n$
            DELETE FROM corrections_not_applied WHERE dcas_ipis_uid = %1$L AND field = %2$L;
            INSERT INTO corrections_not_applied VALUES (%1$L, %2$L, %3$L, %4$L, %5L);
            $n$, _dcas_ipis_uid, _field, current_val, _old_val, _new_val);
    END IF;

END
$BODY$ LANGUAGE plpgsql;


DROP PROCEDURE IF EXISTS apply_correction;
CREATE OR REPLACE PROCEDURE apply_correction (
    _table text, 
    _corrections text
) AS $BODY$
DECLARE 
    _dcas_ipis_uid text;
    _field text;
    _old_value text;
    _new_value text;
    _valid_fields text[];
BEGIN
    SELECT array_agg(column_name) FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = _table INTO _valid_fields;

    FOR _dcas_ipis_uid, _field, _old_value, _new_value IN 
        EXECUTE FORMAT($n$
            SELECT dcas_ipis_uid, field, old_value, new_value 
            FROM %1$s
            WHERE field = any(%2$L)
        $n$, _corrections, _valid_fields)
    LOOP
        CALL correction(_table, _dcas_ipis_uid, _field, _old_value, _new_value);
    END LOOP;
END
$BODY$ LANGUAGE plpgsql;