-- RECIPE 1 ********************************************
-- Step 1 ***************************************************

create schema chp12;

-- Step 2 ***************************************************

CREATE OR REPLACE FUNCTION chp12.rand(radius numeric, the_geom geometry) returns geometry as $$
BEGIN
    return st_Project(the_geom, random()*radius, radians(random()*360));
END;
$$
LANGUAGE plpgsql;

-- Step 3 ***************************************************

CREATE OR REPLACE FUNCTION chp12.nrand(n integer, radius numeric, the_geom geometry) returns geometry as $$
DECLARE
tempdist numeric;
maxdist numeric;
BEGIN
	tempdist := 0;
    maxdist := 0;
    FOR i IN 1..n
    LOOP
       tempdist := random()*radius;
       IF maxdist < tempdist THEN
       		maxdist := tempdist;
       END IF;
    END LOOP;

    return st_Project(the_geom,maxdist, radians(random()*360));
END;
$$
LANGUAGE plpgsql;

-- Step 4 ***************************************************

CREATE OR REPLACE FUNCTION chp12.pinwheel(theta numeric, radius numeric, the_geom geometry) returns geometry as $$
DECLARE
angle numeric;
BEGIN
	 angle = random()*360;
    return st_Project(the_geom,mod(CAST(angle as integer),theta)/theta*radius, radians(angle));
END;
$$
LANGUAGE plpgsql;

-- Step 5 ***************************************************

CREATE TABLE chp12.rk_track_points
(
  fid serial NOT NULL,
  the_geom geometry(Point,4326),
  ele double precision,
  "time" timestamp with time zone,
  CONSTRAINT activities_pk PRIMARY KEY (fid)
);


-- Step 6 ***************************************************

CREATE OR REPLACE FUNCTION __trigger_rk_track_points_before_insert(
) RETURNS trigger AS $__$
DECLARE
maxdist integer;
n integer; 
BEGIN
	maxdist = 500;
	n = 4;
	NEW.the_geom  = chp12.nrand(n, maxdist, NEW.the_geom);
    RETURN NEW;
END;
$__$ LANGUAGE plpgsql;

CREATE TRIGGER rk_track_points_before_insert BEFORE INSERT ON chp12.rk_track_points FOR EACH ROW EXECUTE PROCEDURE __trigger_rk_track_points_before_insert();


-- Step 7 *****************************************************

--import_gpx.sh (for Linux/Unix)
--#!/bin/bash
--for f in `find runkeeper_gpx -name \*.gpx -printf "%f\n"`
--do
--    echo "Importing gpx file $f to chp12.rk_track_points PostGIS table..." #, ${f%.*}"
--    ogr2ogr -append -update  -f PostgreSQL PG:"dbname='postgis_cookbook' user='me' --password='mypassword'" runkeeper_gpx/$f -nln chp12.rk_track_points -sql "SELECT ele, time FROM --track_points"
--done

--import_gpx.bat (for Windows)
--@echo off
--for %%I in (runkeeper_gpx\*.gpx*) do (
--    echo Importing gpx file %%~nxI to chp12.rk_track_points PostGIS table...
--    ogr2ogr -append -update -f PostgreSQL PG:"dbname='postgis_cookbook' user='me' --password='mypassword'" runkeeper_gpx/%%~nxI -nln chp12.rk_track_points -sql "SELECT ele, time FROM 
--track_points")


-- Step 9 ***********************************************************

select ST_ASTEXT(rk.the_geom), ST_ASTEXT(rk2.the_geom)
from chp03.rk_track_points as rk, chp12.rk_track_points as rk2 
where rk.fid = rk2.fid
limit 10;

-- Step 10 **************************************************************

CREATE TABLE chp12.rk_points_rand_500 AS (
SELECT chp12.rand(500, the_geom)
FROM chp12.rk_track_points
);

CREATE TABLE chp12.rk_points_rand_1000 AS (
SELECT chp12.rand(1000, the_geom)
FROM chp12.rk_track_points
);

