-- RECIPE 8 ********************************************

-- How to do it ****************************************

-- Step 1 **********************************************
CREATE VIEW chp03.rivers_clipped_by_country AS
    SELECT 
    r.name, 
    c.iso2, 
    ST_Intersection(r.the_geom, c.the_geom)::geometry(Geometry,4326) AS the_geom
    FROM chp03.countries AS c
    JOIN chp03.rivers AS r
    ON ST_Intersects(r.the_geom, c.the_geom);
