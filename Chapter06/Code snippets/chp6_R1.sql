--Chapter 6
--Recipe 1

--Getting ready
--Step 1.
ALTER ROLE me SET search_path TO chp06,public;

--Step 2.
CREATE EXTENSION postgis;
CREATE EXTENSION pgrouting;

--Step 3.
CREATE TABLE chp06.edge_table (    
    id BIGSERIAL,    dir character varying,
    source BIGINT,    target BIGINT,
    cost FLOAT,
    reverse_cost FLOAT,    capacity BIGINT,
    reverse_capacity BIGINT,
    category_id INTEGER,
    reverse_category_id INTEGER,
    x1 FLOAT,
    y1 FLOAT,
    x2 FLOAT,
    y2 FLOAT,
    the_geom geometry);.


--Step 4.
SELECT pgr_createTopology('chp06.edge_table',0.001);

--How to do it
--Step 1.
SELECT * FROM pgr_dijkstra(
    'SELECT id, source, target, cost
         FROM chp06.edge_table_vertices_pgr',
    2,
    9,
);

--Step 2.
WITH dijkstra AS (	
    SELECT pgr_dijkstra(
        'SELECT id, source, target, cost, x1, x2, y1, y2 
         FROM chp06.edge_table',
        2,
        9
    )
)SELECT
    id,
    ST_AsText(the_geom)    FROM chp06.edge_table et, dijkstra d
    WHERE et.id = (d.pgr_dijkstra).edge;


