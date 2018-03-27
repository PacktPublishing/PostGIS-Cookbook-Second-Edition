-- RECIPE 5 ********************************************

-- Getting Ready ***************************************
-- Step 2 **********************************************

ALTER TABLE chp01.hotspots
ALTER COLUMN the_geom
SET DATA TYPE geometry(Point, 4326)
USING ST_Transform(the_geom, 4326);

-- How to do it ***************************************
-- Step 1 **********************************************

SELECT c.country_name, MIN(c.iso2) as iso2, count(*) as hs_count
FROM chp01.hotspots as hs 
JOIN chp01.countries as c 
ON ST_Contains(c.the_geom, hs.the_geom) 
GROUP BY c.country_name ORDER BY c.country_name;

-- Step 2 **********************************************

COPY (SELECT c.country_name, MIN(c.iso2) as iso2, count(*) as hs_count
  FROM chp01.hotspots as hs
  JOIN chp01.countries as c
  ON ST_Contains(c.the_geom, hs.the_geom)
  GROUP BY c.country_name
  ORDER BY c.country_name) TO '/tmp/hs_countries.csv' WITH CSV HEADER;

-- Step 8 **********************************************

CREATE TABLE chp01.hs_uploaded
(
  ogc_fid serial NOT NULL,
  acq_date character varying(80),
  acq_time character varying(80),
  bright_t31 character varying(80),
  iso2 character varying,
  upload_datetime character varying,
  shapefile character varying,
  the_geom geometry(POINT, 4326),
  CONSTRAINT hs_uploaded_pk PRIMARY KEY (ogc_fid)
);

-- Step 14 **********************************************

SELECT upload_datetime, shapefile, ST_AsText(the_geom) 
FROM chp01.hs_uploaded 
WHERE ISO2='AT';

