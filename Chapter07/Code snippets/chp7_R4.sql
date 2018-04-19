--Chapter 7
--Recipe 4

--How to do it
--Step 1.
DROP TABLE IF EXISTS chp07.buildings_extruded;
CREATE TABLE chp07.buildings_extruded AS 
SELECT
   gid,
   ST_CollectionExtract(ST_Extrude(the_geom, 20, 20, 40), 3) as the_geom
FROM
   chp07.building_footprints
