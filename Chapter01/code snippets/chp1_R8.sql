-- RECIPE 8 ********************************************
-- How to do it ***************************************

-- Step 5 **********************************************

SELECT * FROM raster_columns;

-- Step 6 **********************************************

SELECT count(*) FROM chp01.tmax01;

-- Step 11 **********************************************

SELECT * FROM (
  SELECT c.name, ST_Value(t.rast, ST_Centroid(c.the_geom))/10 as tmax_jan FROM chp01.tmax01 AS t
  JOIN chp01.countries AS c
  ON ST_Intersects(t.rast, ST_Centroid(c.the_geom))
) AS foo
ORDER BY tmax_jan LIMIT 10;
