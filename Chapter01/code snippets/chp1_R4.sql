-- RECIPE 4 ********************************************
-- Step 4 **********************************************

SELECT
ST_AsText(the_geom) AS the_geom, bright_t31
FROM chp01.global_24h
ORDER BY bright_t31 DESC LIMIT 100;

-- Step 5 **********************************************

SELECT
ST_AsText(f.the_geom) AS the_geom,   f.bright_t31, ac.iso2, ac.country_name
FROM chp01.global_24h as f
JOIN chp01.africa_countries as ac
ON ST_Contains(ac.the_geom, ST_Transform(f.the_geom, 4326))
ORDER BY f.bright_t31 DESC
LIMIT 100;