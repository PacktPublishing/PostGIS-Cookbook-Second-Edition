--Chapter 6
--Recipe 3

--How to do it
--Step 1.
SELECT *FROM pgr_drivingDistance(
    'SELECT id, source, target, cost FROM chp06.edge_table',    2,
    3    );

--Step 2.
WITH DD AS (
    SELECT *
    FROM pgr_drivingDistance(
        'SELECT id, source, target, cost 
         FROM chp06.edge_table',
         2,
         3
    )
)

SELECT ST_AsText(the_geom)
  FROM chp06.edge_table_vertices_pgr w, DD d
  WHERE w.id = d.node;

--Step 3.
WITH DD AS (
SELECT *
        FROM pgr_drivingDistance(
                'SELECT id, source, target, cost FROM chp06.edge_table',
                2, 3
        )
        )
SELECT 
    id::integer, 
    ST_X(the_geom)::float AS x, 
    ST_Y(the_geom)::float AS y  
FROM chp06.edge_table_vertices_pgr w, DD d
WHERE w.id = d.node;

--Step 4.
WITH alphashape AS (
    SELECT pgr_alphaShape('
        WITH DD AS (
           SELECT *
           FROM pgr_drivingDistance(
               ''SELECT id, source, target, cost 
                  FROM chp06.edge_table'',
                 2,
                  3
            )
        ),
        dd_points AS(
            SELECT id::integer, ST_X(the_geom)::float AS x, 
            ST_Y(the_geom)::float AS y
           FROM chp06.edge_table_vertices_pgr w, DD d
           WHERE w.id = d.node
       )
       SELECT * FROM dd_points
    ')
),alphapoints AS (
    SELECT ST_MakePoint((pgr_alphashape).x, (pgr_alphashape).y) 
    FROM alphashape
),
alphaline AS (
    SELECT ST_Makeline(ST_MakePoint) 
    FROM alphapoints
)
SELECT 
    ST_MakePolygon(
        ST_AddPoint(ST_Makeline, ST_StartPoint(ST_Makeline))
    )
FROM alphaline;



