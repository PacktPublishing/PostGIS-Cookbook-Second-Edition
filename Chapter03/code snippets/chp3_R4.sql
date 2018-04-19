-- RECIPE 3 ********************************************

-- How to do it ****************************************

-- Step 1 **********************************************
SET search_path TO chp03.public;

-- Step 2 **********************************************
CREATE TABLE states_simplify_topology AS
    SELECT ST_SimplifyPreserveTopology(ST_Transform(
      the_geom, 2163), 500) FROM states;

-- Step 4 **********************************************
SET search_path TO chp03, public;
-- first project the spatial table to a planar system (recommended for simplification operations)
CREATE TABLE states_2163 AS SELECT ST_Transform(the_geom, 2163)::geometry(MultiPolygon, 2163) AS the_geom, state FROM states;
-- now decompose the geometries from multipolygons to polygons (2895) using the ST_Dump function
CREATE TABLE polygons AS SELECT (ST_Dump(the_geom)).geom AS the_geom FROM states_2163;
-- now decompose from polygons (2895) to rings (3150) using the ST_DumpRings function
CREATE TABLE rings AS SELECT (ST_DumpRings(the_geom)).geom AS the_geom FROM polygons;
-- now decompose from rings (3150) to linestrings (3150) using the ST_Boundary function
CREATE TABLE ringlines AS SELECT(ST_boundary(the_geom)) AS the_geom FROM rings;
-- now merge all linestrings (3150) in a single merged linestring (this way duplicate linestrings at polygon borders disappear)
CREATE TABLE mergedringlines AS SELECT ST_Union(the_geom) AS the_geom FROM ringlines;
-- finally simplify the linestring with a tolerance of 150 meters
CREATE TABLE simplified_ringlines AS SELECT ST_SimplifyPreserveTopology(the_geom, 150) AS the_geom FROM mergedringlines;
-- now compose a polygons collection from the linestring using the ST_Polygonize function
CREATE TABLE simplified_polycollection AS SELECT ST_Polygonize(the_geom) AS the_geom FROM simplified_ringlines;
-- here you generate polygons (2895) from the polygons collection using ST_Dumps
CREATE TABLE simplified_polygons AS SELECT ST_Transform((ST_Dump(the_geom)).geom, 4326)::geometry(Polygon,4326) AS the_geom FROM simplified_polycollection;
-- time to create an index, to make next operations faster CREATE INDEX simplified_polygons_gist ON simplified_polygons USING GIST (the_geom);
-- now copy the state name attribute from old layer with a spatial join using the ST_Intersects and ST_PointOnSurface function
CREATE TABLE simplified_polygonsattr AS SELECT new.the_geom, old.state FROM simplified_polygons new, states old 
WHERE ST_Intersects(new.the_geom, old.the_geom) AND ST_Intersects(ST_PointOnSurface(new.the_geom), old.the_geom);
-- now make the union of all polygons with a common name
CREATE TABLE states_simplified AS SELECT ST_Union(the_geom) AS the_geom, state FROM simplified_polygonsattr GROUP BY state;
