-- RECIPE 6 ********************************************

-- How to do it ****************************************
CREATE TABLE chp04.lidar_buildings_buffer AS

WITH lidar_query AS
(SELECT ST_ExteriorRing(ST_SimplifyPreserveTopology((ST_Dump(ST_Union(ST_Buffer(the_geom, 5)))).geom, 10)) AS the_geom FROM
  chp04.lidar_buildings)

SELECT chp04.polygonize_to_multi(the_geom) AS the_geom from lidar_query;
