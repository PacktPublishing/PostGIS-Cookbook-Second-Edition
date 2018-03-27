-- RECIPE 9 ********************************************

-- Getting ready ***************************************

-- Step 1 **********************************************
CREATE EXTENSION postgis_topology;

-- Step 5 **********************************************
SELECT COUNT(*) FROM chp03.hungary;

-- How to do it ****************************************

-- Step 1 **********************************************
SET search_path TO chp03, topology, public;

-- Step 2 **********************************************
SELECT CreateTopology('hu_topo', 3857);

-- Step 3 **********************************************
SELECT * FROM topology.topology;

-- Step 4 **********************************************
\dtv hu_topo.*

SELECT topologysummary('hu_topo');
 
-- Step 6 **********************************************
CREATE TABLE chp03.hu_topo_polygons(gid serial primary key, name_1 varchar(75));

-- Step 7 **********************************************
SELECT AddTopoGeometryColumn('hu_topo', 'chp03', 'hu_topo_polygons', 'the_geom_topo', 'MULTIPOLYGON') As layer_id;

-- Step 8 **********************************************
postgis_cookbook=> INSERT INTO chp03.hu_topo_polygons(name_1, the_geom_topo)
    SELECT name_1, toTopoGeom(the_geom, 'hu_topo', 1)
    FROM chp03.hungary;
    Query returned successfully: 20 rows affected, 10598 ms execution time.

-- Step 9 **********************************************
SELECT topologysummary('hu_topo');
 
-- Step 10 **********************************************
SELECT row_number() OVER (ORDER BY ST_Area(mbr) DESC) as rownum, ST_Area(mbr)/100000 AS area FROM hu_topo.face ORDER BY area DESC;

-- Step 12 **********************************************
SELECT DropTopology('hu_topo');

DROP TABLE chp03.hu_topo_polygons;

SELECT CreateTopology('hu_topo', 3857, 1);

CREATE TABLE chp03.hu_topo_polygons(
  gid serial primary key, name_1 varchar(75));

SELECT AddTopoGeometryColumn('hu_topo',
  'chp03', 'hu_topo_polygons', 'the_geom_topo',
  'MULTIPOLYGON') As layer_id;

INSERT INTO chp03.hu_topo_polygons(name_1, the_geom_topo)
        SELECT name_1, toTopoGeom(the_geom, 'hu_topo', 1)
        FROM chp03.hungary;

-- Step 13 **********************************************
SELECT topologysummary('hu_topo');

-- Step 14 **********************************************
SELECT ST_ChangeEdgeGeom('hu_topo', edge_id, ST_SimplifyPreserveTopology(geom, 500))
  FROM hu_topo.edge;

-- Step 15 **********************************************
UPDATE chp03.hungary hu
  SET the_geom = hut.the_geom_topo
  FROM chp03.hu_topo_polygons hut
  WHERE hu.name_1 = hut.name_1;

