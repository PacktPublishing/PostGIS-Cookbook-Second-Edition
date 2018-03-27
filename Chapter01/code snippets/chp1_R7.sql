-- RECIPE 7 ********************************************
-- Getting Ready ***************************************
-- Step 4 **********************************************

CREATE DATABASE rome OWNER me;
\connect rome;
create extension postgis;

-- Step 6 **********************************************

CREATE EXTENSION hstore;

-- How to do it ***************************************
-- Step 3 *********************************************

SELECT f_table_name, f_geometry_column, coord_dimension, srid, type 
FROM geometry_columns;

-- Step 6 *********************************************

CREATE VIEW rome_trees AS  SELECT way, tags 
FROM planet_osm_polygon  
WHERE (tags -> 'landcover') = 'trees';

-- How it works ***************************************

SELECT way, tags 
FROM planet_osm_polygon
WHERE (tags -> 'landcover') = 'trees';