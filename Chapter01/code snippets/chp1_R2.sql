-- RECIPE 2 ********************************************
-- Step 5 **********************************************

CREATE TABLE global_24h (
  ogc_fid integer NOT NULL,
  latitude character varying,
  longitude character varying,
  brightness character varying,
  scan character varying,
  track character varying,
  acq_date character varying,
  acq_time character varying,
  satellite character varying,
  confidence character varying,
  version character varying,
  bright_t31 character varying,
  frp character varying,
  the_geom public.geometry(Point,3857)
);

-- Step 6 **********************************************

SELECT f_geometry_column, coord_dimension, srid, type 
FROM geometry_columns 
WHERE f_table_name = 'global_24h';

-- Step 7 **********************************************

SELECT count(*) FROM chp01.global_24h;

-- Step 8 **********************************************

SELECT ST_AsEWKT(the_geom) FROM chp01.global_24h LIMIT 1;