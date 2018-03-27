-- RECIPE 7 ********************************************

-- How to do it ****************************************

-- Step 1 **********************************************
SELECT r1.gid AS gid1, r2.gid AS gid2,
    ST_AsText(ST_Intersection(r1.the_geom, r2.the_geom)) AS the_geom
    FROM chp03.rivers r1
    JOIN chp03.rivers r2
    ON ST_Intersects(r1.the_geom, r2.the_geom)
    WHERE r1.gid != r2.gid;

-- Step 3 **********************************************    
SELECT COUNT(*),
    ST_GeometryType(ST_Intersection(r1.the_geom, r2.the_geom)) AS geometry_type
    FROM chp03.rivers r1
    JOIN chp03.rivers r2
    ON ST_Intersects(r1.the_geom, r2.the_geom)
    WHERE r1.gid != r2.gid
    GROUP BY geometry_type;

-- Step 4 **********************************************
CREATE TABLE chp03.intersections_simple AS
    SELECT r1.gid AS gid1, r2.gid AS gid2,
      ST_Multi(ST_Intersection(r1.the_geom,
      r2.the_geom))::geometry(MultiPoint, 4326) AS the_geom
    FROM chp03.rivers r1
    JOIN chp03.rivers r2
    ON ST_Intersects(r1.the_geom, r2.the_geom)
    WHERE r1.gid != r2.gid
    AND ST_GeometryType(ST_Intersection(r1.the_geom,
      r2.the_geom)) != 'ST_GeometryCollection';

-- Step 5 **********************************************
CREATE TABLE chp03.intersections_all AS
    SELECT gid1, gid2, the_geom::geometry(MultiPoint, 4326) FROM (
    SELECT r1.gid AS gid1, r2.gid AS gid2,
    CASE
        WHEN ST_GeometryType(ST_Intersection(r1.the_geom, 
          r2.the_geom)) != 'ST_GeometryCollection' THEN
        ST_Multi(ST_Intersection(r1.the_geom,
          r2.the_geom))
        ELSE ST_CollectionExtract(ST_Intersection(r1.the_geom,
          r2.the_geom), 1)
    END AS the_geom
    FROM chp03.rivers r1
    JOIN chp03.rivers r2
    ON ST_Intersects(r1.the_geom, r2.the_geom)
    WHERE r1.gid != r2.gid
    ) AS only_multipoints_geometries;

-- Step 6 **********************************************
SELECT SUM(ST_NPoints(the_geom)) FROM chp03.intersections_simple; --2268 points per 1444 records
SELECT SUM(ST_NPoints(the_geom)) FROM chp03.intersections_all; --2282 points per 1448 records
