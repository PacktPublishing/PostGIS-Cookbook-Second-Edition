--Chapter 6
--Recipe 5

--Getting Ready
--Step 1.
shp2pgsql -s 3734 -d -i -I -W LATIN1 -g the_geom ebrr_polygon chp06.voronoi_hydro | psql -U me -d postgis_cookbook


--How to do it
--Step 1.
CREATE TABLE chp06.voronoi_points AS(
    SELECT (ST_DumpPoints(ST_Segmentize(the_geom, 5))).geom AS the_geom FROM chp06.voronoi_hydro
      UNION ALL
    SELECT (ST_DumpPoints(ST_Extent(the_geom))).geom AS the_geom FROM chp06.voronoi_hydro
    )

--Step 2.
CREATE TABLE chp06.voronoi AS(
    SELECT (ST_Dump(
        ST_SetSRID(
            ST_VoronoiPolygons(points.the_geom),
            3734))).geom as the_geom
    FROM (
        SELECT
            ST_Collect(ST_SetSRID(the_geom, 3734)) as the_geom
        FROM chp06.voronoi_points
    ) as points);


--Step 3.
CREATE INDEX chp06_voronoi_geom_gist
    ON chp06.voronoi
    USING gist(the_geom);

DROP TABLE IF EXISTS voronoi_intersect;

CREATE TABLE chp06.voronoi_intersect AS
  WITH vintersect AS (
  SELECT ST_Intersection(ST_SetSRID(ST_MakeValid(a.the_geom), 3734), ST_MakeValid(b.the_geom)) AS the_geom FROM
    Chp06.voronoi a, chp06.voronoi_hydro b
    WHERE ST_Intersects(ST_SetSRID(a.the_geom, 3734), b.the_geom)
    ),
  linework AS (
      SELECT chp02.polygon_to_line(the_geom) AS the_geom FROM
    vintersect
      ),
  polylines AS (
        SELECT ((ST_Dump(ST_Union(lw.the_geom))).geom)::geometry(linestring, 3734) AS the_geom FROM
    linework AS lw
  ),
  externalbounds AS (
    SELECT chp02.polygon_to_line(the_geom) AS the_geom FROM
      voronoi_hydro
  )

  SELECT (ST_Dump(ST_Union(p.the_geom))).geom FROM
    polylines p, externalbounds b
    WHERE NOT ST_DWithin(p.the_geom, b.the_geom, 5)
    ;

--There's more
--Step 1.
ALTER TABLE chp06.voronoi_intersect ADD COLUMN gid serial;
ALTER TABLE chp06.voronoi_intersect ADD PRIMARY KEY (gid);

ALTER TABLE chp06.voronoi_intersect ADD COLUMN source integer;
ALTER TABLE chp06.voronoi_intersect ADD COLUMN target integer;


--Step 2.
SELECT pgr_createTopology('voronoi_intersect', 0.001, 'the_geom', 'gid', 'source', 'target', 'true');

CREATE INDEX source_idx ON chp06.voronoi_intersect("source");
CREATE INDEX target_idx ON chp06.voronoi_intersect("target");

ALTER TABLE chp06.voronoi_intersect ADD COLUMN length double precision;
UPDATE chp06.voronoi_intersect SET length = ST_Length(the_geom);

ALTER TABLE chp06.voronoi_intersect ADD COLUMN reverse_cost double precision;
UPDATE chp06.voronoi_intersect SET reverse_cost = length;


--Step 3.
CREATE TABLE chp06.voronoi_route AS
WITH dijkstra AS (
SELECT * FROM pgr_dijkstra('SELECT gid AS id, source, target,
    length AS cost FROM chp06.voronoi_intersect',
    10851, 3,
    false)
    )

SELECT gid, geom
  FROM voronoi_intersect et, dijkstra d
  WHERE et.gid = d.edge;





