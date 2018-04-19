-- RECIPE 3 ********************************************

-- How to do it ****************************************

CREATE OR REPLACE FUNCTION chp04.angle_to_street (geometry) RETURNS double precision AS $$

WITH index_query as
                (SELECT ST_Distance($1,road.the_geom) as dist,
                                degrees(ST_Azimuth($1, ST_ClosestPoint(road.the_geom, $1))) as azimuth
                FROM  chp04.knn_streets As road
                ORDER BY $1 <#> road.the_geom limit 5)

SELECT azimuth
                FROM index_query
                ORDER BY dist
LIMIT 1;

$$ LANGUAGE SQL;
---
CREATE TABLE chp04.tsr_building AS

SELECT ST_Rotate(ST_Envelope(ST_Buffer(the_geom, 20)), radians(90 - chp04.angle_to_street(addr.the_geom)), addr.the_geom)
  AS the_geom FROM
  chp04.knn_addresses addr
  LIMIT 500;
