--Chapter 6
--Recipe 4

--Getting Ready
--Step 1.
CREATE OR REPLACE FUNCTION chp02.proportional_sum(geometry, geometry, numeric)
  RETURNS numeric AS
$BODY$
     SELECT $3 * areacalc FROM
           (
           SELECT (ST_Area(ST_Intersection($1, $2))/ST_Area($2))::numeric AS areacalc
           ) AS areac
;
$BODY$
  LANGUAGE sql VOLATILE;

--Step 2.
shp2pgsql -s 3734 -d -i -I -W LATIN1 -g the_geom census chp06.census | psql -U me -d postgis_cookbook -h localhost


--How to do it
--Step 1.
CREATE TABLE chp06.zoo_bikezone AS (
WITH alphashape AS (
SELECT pgr_alphaShape('
  WITH DD AS (
  SELECT *
    FROM pgr_drivingDistance(
      ''SELECT gid AS id, source, target, reverse_cost AS cost FROM chp06.cleveland_ways'',
      165232, 6.437376, false
    )
        ),
  dd_points AS(
  SELECT id::int4, ST_X(the_geom)::float8 as x, ST_Y(the_geom)::float8 AS y
    FROM chp06.cleveland_ways_vertices_pgr w, DD d
    WHERE w.id = d.node
    )
    SELECT * FROM dd_points
  ')
  ),
alphapoints AS (
  SELECT ST_MakePoint((pgr_alphashape).x, (pgr_alphashape).y) FROM alphashape
  ),
alphaline AS (
  SELECT ST_Makeline(ST_MakePoint) FROM alphapoints
  )
SELECT 1 as id,  ST_SetSRID(ST_MakePolygon(ST_AddPoint(ST_Makeline, ST_StartPoint(ST_Makeline))), 4326) AS the_geom FROM alphaline
);


--Step 2.
SELECT ROUND(SUM(chp02.proportional_sum(ST_Transform(a.the_geom,3734), b.the_geom, b.pop))) AS population FROM
      Chp06.zoo_bikezone AS a, chp06.census as b
     WHERE ST_Intersects(ST_Transform(a.the_geom, 3734), b.the_geom)
     GROUP BY a.id;

--Step 3.
buffered distance?
SELECT ROUND(SUM(chp02.proportional_sum(ST_Transform(a.the_geom,3734), b.the_geom, b.pop))) AS population FROM
     (SELECT 1 AS id, ST_Buffer(ST_Transform(the_geom, 3734), 21120) AS the_geom FROM cleveland_ways_vertices_pgr WHERE id = 165232) AS a,
     census as b
     WHERE ST_Intersects(ST_Transform(a.the_geom, 3734), b.the_geom)
     GROUP BY a.id; 





