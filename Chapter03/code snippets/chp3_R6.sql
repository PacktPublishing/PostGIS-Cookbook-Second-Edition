-- RECIPE 6 ********************************************

-- How to do it ****************************************

-- Step 1 **********************************************
SELECT county, fips, state_fips FROM chp03.counties ORDER BY county;
 
-- Step 2 **********************************************
CREATE TABLE chp03.states_from_counties AS SELECT ST_Multi(ST_Union(the_geom)) as the_geom, state_fips FROM chp03.counties GROUP BY state_fips;
