--Chapter 7
--Recipe 7

--Getting Ready
psql -U me -d postgis_cookbook -f ST_RotateX.sql
psql -U me -d postgis_cookbook -f ST_RotateY.sql
psql -U me -d postgis_cookbook -f ST_RotateXYZ.sql
psql -U me -d postgis_cookbook -f pyramidMaker.sql
psql -U me -d postgis_cookbook -f volumetricIntersection.sql



--How to do it
--Step 1.
CREATE OR REPLACE FUNCTION chp07.pbr(origin geometry, pitch numeric, 
  bearing numeric, roll numeric, anglex numeric, angley numeric, 
  height numeric)
  RETURNS geometry AS
$BODY$

WITH widthx AS
(
  SELECT height / tan(anglex) AS basex
),
widthy AS
(
  SELECT height / tan(angley) AS basey
),
iViewCone AS (
  SELECT pyramidMaker(origin, basex::numeric, basey::numeric, height) 
    AS the_geom
    FROM widthx, widthy
),
iViewRotated AS (
  SELECT ST_RotateXYZ(the_geom, pi() - pitch, 0 - roll, pi() - 
    bearing, origin) AS the_geom FROM iViewCone
)
SELECT the_geom FROM iViewRotated
;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

--Step 2.
DROP TABLE IF EXISTS chp07.viewshed;
CREATE TABLE chp07.viewshed AS
SELECT 1 AS gid, roll, pitch, heading, fileName,
  chp07.pbr(ST_Force3D(geom),
        radians(0)::numeric,
        radians(heading)::numeric,
        radians(roll)::numeric,
        radians(40)::numeric,
        radians(50)::numeric,
        ( (3.2808399 * altitude_a) - 838)::numeric)
  AS the_geom FROM uas_locations;

--Step 3.
pg_restore -h localhost -p 8000 -U me -d "postgis-cookbook" \
  --schema chp07 --verbose "lidar_tin.backup"

DROP TABLE IF EXISTS chp07.viewshed;
CREATE TABLE chp07.viewshed AS 
SELECT
   1 AS gid,
   roll,
   pitch,
   heading,
   fileName,
   chp07.pbr(ST_Force3D(geom), radians(0)::numeric, radians(heading)::numeric, radians(roll) ::numeric, radians(40)::numeric, radians(50)::numeric, 1000::numeric) AS the_geom 
FROM
   uas_locations 
WHERE
   fileName = 'IMG_0512.JPG';

