--Chapter 10
--Recipe 10

--Step 1.
psql -U postgres
CREATE USER me WITH PASSWORD 'me';
ALTER USER me WITH SUPERUSER;

--Step 2.
PGPASSWORD=me psql -U me –d postgres
CREATE DATABASE "postgis-cookbook";
\c postgis-cookbook
CREATE SCHEMA chp10;
CREATE EXTENSION postgis;

--Step 3.
shp2pgsql -s 3734 -W latin1 <SHP_PATH>/gis.osm_buildings_a_free_1.shp chp10.buildings | PGPASSWORD=me psql -U me -h localhost -p 5433 -d postgis-cookbook

--Step 4.
EXPLAIN ANALYZE SELECT Sum(ST_Area(geom)) FROM chp10.buildings;

SET max_parallel_workers = 8;
SET max_parallel_workers_per_gather = 8;

EXPLAIN ANALYZE SELECT Sum(ST_Area(geom)) FROM buildings;


--Step 5.
EXPLAIN ANALYZE SELECT * FROM chp10.buildings WHERE ST_Area(geom) > 10000;

ALTER FUNCTION ST_Area(geometry) COST 100;

EXPLAIN ANALYZE SELECT * FROM chp10.buildings WHERE ST_Area(geom) > 10000;

--Step 6.
DROP TABLE IF EXISTS chp10.pts_10;

CREATE TABLE chp10.pts_10 AS
SELECT
  (ST_Dump(ST_GeneratePoints(geom, 10))).geom::Geometry(point, 3734) AS geom,
  gid, osm_id, code, fclass, name, type
FROM chp10.buildings;

CREATE INDEX pts_10_gix ON chp10.pts_10 USING GIST (geom);

SET parallel_tuple_cost = 0.001;
