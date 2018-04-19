-- RECIPE 2 ********************************************

-- How to do it ****************************************

-- Step 1 **********************************************
SELECT gid, name, ST_IsValidReason(the_geom)
    FROM chp03.countries
    WHERE ST_IsValid(the_geom)=false;

-- Step 2 **********************************************
SELECT * INTO chp03.invalid_geometries 
FROM (
	 SELECT 'broken'::varchar(10) as status,
	 ST_GeometryN(the_geom, generate_series(1, ST_NRings(the_geom)))::geometry(Polygon,4326) as the_geom 
	 FROM chp03.countries
	 WHERE name = 'Russia'
) AS foo
WHERE ST_Intersects(the_geom, ST_SetSRID(ST_Point(143.661926,49.31221), 4326));

-- Step 3 **********************************************
INSERT INTO chp03.invalid_geometries VALUES (
	'repaired', 
	(
		SELECT ST_MakeValid(the_geom)
		FROM chp03.invalid_geometries
	)
);

-- Step 5 **********************************************
SELECT status, ST_NRings(the_geom) 
FROM chp03.invalid_geometries;

-- Step 6 **********************************************
UPDATE chp03.countries
    SET the_geom = ST_MakeValid(the_geom)
    WHERE ST_IsValid(the_geom) = false;
---
ALTER TABLE chp03.countries
    ADD CONSTRAINT geometry_valid_check
    CHECK (ST_IsValid(the_geom));