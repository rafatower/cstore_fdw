/* cstore_fdw/cstore_fdw--1.5.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION cstore_fdw" to load this file. \quit

CREATE FUNCTION cstore_fdw_handler()
RETURNS fdw_handler
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION cstore_fdw_validator(text[], oid)
RETURNS void
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FOREIGN DATA WRAPPER cstore_fdw
HANDLER cstore_fdw_handler
VALIDATOR cstore_fdw_validator;

CREATE FUNCTION cstore_ddl_event_end_trigger()
RETURNS event_trigger
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE EVENT TRIGGER cstore_ddl_event_end
ON ddl_command_end
EXECUTE PROCEDURE cstore_ddl_event_end_trigger();

CREATE FUNCTION cstore_table_size(relation regclass)
RETURNS bigint
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION cstore_clean_table_resources(oid)
RETURNS void
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION cstore_drop_trigger()
	RETURNS event_trigger
	LANGUAGE plpgsql
	AS $csdt$
DECLARE v_obj record;
BEGIN
	FOR v_obj IN SELECT * FROM pg_event_trigger_dropped_objects() LOOP

		IF v_obj.object_type NOT IN ('table', 'foreign table') THEN
			CONTINUE;
		END IF;

		PERFORM cstore_clean_table_resources(v_obj.objid);
	END LOOP;
END;
$csdt$;

CREATE EVENT TRIGGER cstore_drop_event
    ON SQL_DROP
    EXECUTE PROCEDURE cstore_drop_trigger();

-- We declare transition functions here. Note that these functions' declarations
-- and their definitions don't actually match. We manually set the arguments to
-- pass to these functions in vectorized_aggregates.c.

CREATE FUNCTION int4_sum_vec(bigint, int)
RETURNS bigint
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION int8_sum_vec(numeric, bigint)
RETURNS numeric
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION int4_avg_accum_vec(bigint[], int)
RETURNS bigint[]
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION int8_avg_accum_vec(numeric[], bigint)
RETURNS numeric[]
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION int8inc_vec(bigint)
RETURNS bigint
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION int8inc_any_vec(bigint, "any")
RETURNS bigint
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION float4pl_vec(real, real)
RETURNS real
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION float8pl_vec(double precision, double precision)
RETURNS double precision
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION float8_accum_vec(double precision[], double precision)
RETURNS double precision[]
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION float4_accum_vec(double precision[], real)
RETURNS double precision[]
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;