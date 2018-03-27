-- RECIPE 6 ********************************************

-- How to do it ***************************************
-- Step 3 **********************************************

SELECT MIN(subregion) AS subregion,
ST_Union(the_geom) AS the_geom,
SUM(pop2005) AS pop2005
FROM chp01.countries 
GROUP BY subregion;