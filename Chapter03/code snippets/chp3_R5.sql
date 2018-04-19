-- RECIPE 5 ********************************************

-- How to do it ****************************************

-- Step 1 **********************************************
SELECT c1.name, c2.name,
ST_Distance(ST_Transform(c1.the_geom, 900913), 
ST_Transform(c2.the_geom, 900913))/1000 AS distance_900913
FROM chp03.cities AS c1
CROSS JOIN
chp03.cities AS c2
WHERE c1.pop_2000 > 1000000 AND c2.pop_2000 > 1000000 AND c1.name < c2.name
ORDER BY distance_900913 DESC;
 
-- Step 2 **********************************************
WITH cities AS (
    SELECT name, the_geom FROM chp03.cities
    WHERE pop_2000 > 1000000 )
SELECT c1.name, c2.name,
ST_Distance(ST_Transform(c1.the_geom, 900913), ST_Transform(c2.the_geom, 900913))/1000 AS distance_900913
FROM cities c1 CROSS JOIN cities c2
where c1.name < c2.name
ORDER BY distance_900913 DESC;

-- Step 3 **********************************************
WITH cities AS (
    SELECT name, the_geom FROM chp03.cities
    WHERE pop_2000 > 1000000 )
SELECT c1.name, c2.name,
ST_Distance(ST_Transform(c1.the_geom, 900913), ST_Transform(c2.the_geom, 900913))/1000 AS d_900913,
ST_Distance_Sphere(c1.the_geom, c2.the_geom)/1000 AS d_4326_sphere,
ST_Distance_Spheroid(c1.the_geom, c2.the_geom, 'SPHEROID["GRS_1980",6378137,298.257222101]')/1000 AS d_4326_spheroid,
ST_Distance(geography(c1.the_geom), geography(c2.the_geom))/1000 AS d_4326_geography
FROM cities c1 CROSS JOIN cities c2
where c1.name < c2.name
ORDER BY d_900913 DESC;
 