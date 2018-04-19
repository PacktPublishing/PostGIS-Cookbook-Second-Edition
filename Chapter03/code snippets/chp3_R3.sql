-- RECIPE 3 ********************************************

-- Getting ready ***************************************

-- Step 5 **********************************************
ALTER TABLE chp03.earthquakes RENAME wkb_geometry  TO the_geom;

-- How to do it ****************************************

-- Step 1 **********************************************
SELECT s.state, COUNT(*) AS hq_count
FROM chp03.states AS s
    JOIN chp03.earthquakes AS e
    ON ST_Intersects(s.the_geom, e.the_geom)
    GROUP BY s.state
    ORDER BY hq_count DESC;

-- Step 2 **********************************************
SELECT c.name, e.magnitude, count(*) as hq_count FROM chp03.cities AS c
    JOIN chp03.earthquakes AS e
    ON ST_DWithin(geography(c.the_geom), geography(e.the_geom), 200000)
    WHERE c.pop_2000 > 1000000
    GROUP BY c.name, e.magnitude
    ORDER BY c.name, e.magnitude, hq_count;

-- Step 3 **********************************************
SELECT c.name, e.magnitude,
    ST_Distance(geography(c.the_geom), geography(e.the_geom)) AS distance FROM chp03.cities AS c
    JOIN chp03.earthquakes AS e
    ON ST_DWithin(geography(c.the_geom), geography(e.the_geom), 200000)
    WHERE c.pop_2000 > 1000000
    ORDER BY distance;
 
-- Step 4 **********************************************
SELECT s.state, COUNT(*) AS city_count, SUM(pop_2000) AS pop_2000 
FROM chp03.states AS s
JOIN chp03.cities AS c
ON ST_Intersects(s.the_geom, c.the_geom)
WHERE c.pop_2000 > 0 -- NULL values is -9999 on this field!
GROUP BY s.state
ORDER BY pop_2000 DESC;
 
-- Step 5 **********************************************
ALTER TABLE chp03.earthquakes ADD COLUMN state_fips character varying(2);

-- Step 6 **********************************************
UPDATE chp03.earthquakes AS e
    SET state_fips = s.state_fips
    FROM chp03.states AS s
    WHERE ST_Intersects(s.the_geom, e.the_geom);
