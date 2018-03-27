-- RECIPE 8 ********************************************

-- Getting ready ***************************************

DROP TABLE IF EXISTS chp04.voronoi_test_points;
CREATE TABLE chp04.voronoi_test_points
(
 x numeric,
 y numeric
)
WITH (OIDS=FALSE);

ALTER TABLE chp04.voronoi_test_points ADD COLUMN gid serial;
ALTER TABLE chp04.voronoi_test_points ADD PRIMARY KEY (gid);

INSERT INTO chp04.voronoi_test_points (x, y)
    VALUES (random() * 5, random() * 7);
INSERT INTO chp04.voronoi_test_points (x, y)
    VALUES (random() * 2, random() * 8);
INSERT INTO chp04.voronoi_test_points (x, y)
    VALUES (random() * 10, random() * 4);
INSERT INTO chp04.voronoi_test_points (x, y)
    VALUES (random() * 1, random() * 15);
INSERT INTO chp04.voronoi_test_points (x, y)
    VALUES (random() * 4, random() * 9);
INSERT INTO chp04.voronoi_test_points (x, y)
    VALUES (random() * 8, random() * 3);
INSERT INTO chp04.voronoi_test_points (x, y)
    VALUES (random() * 5, random() * 3);
INSERT INTO chp04.voronoi_test_points (x, y)
    VALUES (random() * 20, random() * 0.1);
INSERT INTO chp04.voronoi_test_points (x, y)
    VALUES (random() * 5, random() * 7);

SELECT AddGeometryColumn ('chp04','voronoi_test_points','the_geom',3734,'POINT',2);

 UPDATE chp04.voronoi_test_points
   SET the_geom = ST_SetSRID(ST_MakePoint(x,y), 3734)
     WHERE the_geom IS NULL
   ;

-- How to do it ****************************************

DROP TABLE IF EXISTS chp04.voronoi_diagram;
CREATE TABLE chp04.voronoi_diagram(
  gid serial PRIMARY KEY,
  the_geom geometry(MultiPolygon, 3734)
);
---
INSERT INTO chp04.voronoi_diagram(the_geom)(
  SELECT 
  ST_CollectionExtract(
    ST_SetSRID(
      ST_VoronoiPolygons(points.the_geom), 
    3734),
  3)
  FROM (
    SELECT
    ST_Collect(the_geom) as the_geom
    FROM chp04.voronoi_test_points
    ) as points); 
