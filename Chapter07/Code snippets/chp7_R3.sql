--Chapter 7
--Recipe 3

--Getting ready

--Step1.
DROP TABLE IF EXISTS chp07.simple_building;
CREATE TABLE chp07.simple_building AS 
SELECT
   1 AS gid,
   ST_MakePolygon(
      ST_GeomFromText(
         'LINESTRING(0 0,2 0, 2 1, 1 1, 1 2, 0 2, 0 0)'
      )
   ) AS the_geom;


--Step 2.
CREATE OR REPLACE FUNCTION chp07.threedbuilding(footprint geometry, 
  height numeric)
RETURNS geometry AS
$BODY$


--Step 3.
WITH simple_lines AS
(
  SELECT 
    1 AS gid, 
    ST_MakeLine(ST_PointN(the_geom,pointn),
    ST_PointN(the_geom,pointn+1)) AS the_geom
  FROM (
    SELECT 1 AS gid,
    polygon_to_line($1) AS the_geom 
  ) AS a
  LEFT JOIN(
    SELECT 
      1 AS gid, 
      generate_series(1, 
        ST_NumPoints(polygon_to_line($1))-1
      ) AS pointn 
  ) AS b
  ON a.gid = b.gid
)

--Step 4.
threeDlines AS
(
  SELECT ST_Force3DZ(the_geom) AS the_geom FROM simple_lines
)

explodedLine AS
(
  SELECT (ST_Dump(the_geom)).geom AS the_geom FROM threeDLines
)

--Step 5.
threeDline AS
(
  SELECT ST_MakeLine(
    ARRAY[
    ST_StartPoint(the_geom),
    ST_EndPoint(the_geom),
    ST_Translate(ST_EndPoint(the_geom), 0, 0, $2),
    ST_Translate(ST_StartPoint(the_geom), 0, 0, $2),
    ST_StartPoint(the_geom)
    ]
  )
AS the_geom FROM explodedLine
)

threeDwall AS
(
  SELECT ST_MakePolygon(the_geom) as the_geom FROM threeDline
)

buildingTop AS
(
  SELECT ST_Translate(ST_Force3DZ($1), 0, 0, $2) AS the_geom
),

buildingBottom AS
(
  SELECT ST_Translate(ST_Force3DZ($1), 0, 0, 0) AS the_geom
)

--Step 6.
wholeBuilding AS
(
  SELECT the_geom FROM buildingBottom
    UNION ALL
  SELECT the_geom FROM threeDwall
    UNION ALL
  SELECT the_geom FROM buildingTop
),
-- then convert this collecion to a multipolygon
multiBuilding AS
(
  SELECT ST_Multi(ST_Collect(the_geom)) AS the_geom FROM 
    wholeBuilding
)

--Step 7.
textBuilding AS
(
  SELECT ST_AsText(the_geom) textbuilding FROM multiBuilding
),
textBuildSurface AS
(
  SELECT ST_GeomFromText(replace(textbuilding, 'MULTIPOLYGON', 
    'POLYHEDRALSURFACE')) AS the_geom FROM textBuilding
)
SELECT the_geom FROM textBuildSurface

--Step 8.
CREATE OR REPLACE FUNCTION chp07.threedbuilding(footprint geometry, 
  height numeric)
RETURNS geometry AS
$BODY$

-- make our polygons into lines, and then chop up into individual line segments
WITH simple_lines AS
(
  SELECT 1 AS gid, ST_MakeLine(ST_PointN(the_geom,pointn),
    ST_PointN(the_geom,pointn+1)) AS the_geom
  FROM (SELECT 1 AS gid, polygon_to_line($1) AS the_geom ) AS a
  LEFT JOIN
  (SELECT 1 AS gid, generate_series(1, 
    ST_NumPoints(polygon_to_line($1))-1) AS pointn 
  ) AS b
  ON a.gid = b.gid
),
-- convert our lines into 3D lines, which will set our third  coordinate to 0 by default
threeDlines AS
(
  SELECT ST_Force3DZ(the_geom) AS the_geom FROM simple_lines
),
-- now we need our lines as individual records, so we dump them out using ST_Dump, and then just grab the geometry portion of the dump
explodedLine AS
(
  SELECT (ST_Dump(the_geom)).geom AS the_geom FROM threeDLines
),
-- Next step is to construct a line representing the boundary of the  extruded "wall"
threeDline AS
(
  SELECT ST_MakeLine(
    ARRAY[
    ST_StartPoint(the_geom),
    ST_EndPoint(the_geom),
    ST_Translate(ST_EndPoint(the_geom), 0, 0, $2),
    ST_Translate(ST_StartPoint(the_geom), 0, 0, $2),
    ST_StartPoint(the_geom)
    ]
  )
AS the_geom FROM explodedLine
),
-- we convert this line into a polygon
threeDwall AS
(
  SELECT ST_MakePolygon(the_geom) as the_geom FROM threeDline
),
-- add a top to the building
buildingTop AS
(
  SELECT ST_Translate(ST_Force3DZ($1), 0, 0, $2) AS the_geom
),
-- and a floor
buildingBottom AS
(
  SELECT ST_Translate(ST_Force3DZ($1), 0, 0, 0) AS the_geom
),
-- now we put the walls, roof, and floor together
wholeBuilding AS
(
  SELECT the_geom FROM buildingBottom
    UNION ALL
  SELECT the_geom FROM threeDwall
    UNION ALL
  SELECT the_geom FROM buildingTop
),
-- then convert this collecion to a multipolygon
multiBuilding AS
(
  SELECT ST_Multi(ST_Collect(the_geom)) AS the_geom FROM 
    wholeBuilding
),
-- While we could leave this as a multipolygon, we'll do things properly and munge an informal cast
-- to polyhedralsurfacem which is more widely recognized as the appropriate format for a geometry like
-- this. In our case, we are already formatted as a polyhedralsurface, minus the official designation,
-- so we'll just convert to text, replace the word MULTIPOLYGON with POLYHEDRALSURFACE and then convert
-- back to geometry with ST_GeomFromText

textBuilding AS
(
  SELECT ST_AsText(the_geom) textbuilding FROM multiBuilding
),
textBuildSurface AS
(
  SELECT ST_GeomFromText(replace(textbuilding, 'MULTIPOLYGON', 
    'POLYHEDRALSURFACE')) AS the_geom FROM textBuilding
)
SELECT the_geom FROM textBuildSurface
;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION chp07.threedbuilding(geometry, numeric)
  OWNER TO me;



--How to do it
--Step 1.
DROP TABLE IF EXISTS chp07.threed_building;
CREATE TABLE chp07.threed_building AS 
SELECT
   chp07.threeDbuilding(the_geom, 10) AS the_geom 
FROM
   chp07.simple_building;

--Step 2.
shp2pgsql -s 3734 -d -i -I -W LATIN1 -g the_geom building_footprints \ chp07.building_footprints | psql -U me -d postgis-cookbook \ -h <HOST> -p <PORT>

--Step 3.
DROP TABLE IF EXISTS chp07.build_footprints_threed;
CREATE TABLE chp07.build_footprints_threed AS 
SELECT
   gid,
   height,
   chp07.threeDbuilding(the_geom, height) AS the_geom 
FROM
   chp07.building_footprints;


