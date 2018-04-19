--Chapter 6
--Recipe 2

--How to do it
--Step 1.
WITH astar AS (
    SELECT * FROM pgr_astar(
        'SELECT gid AS id, source, target,
         length AS cost, x1, y1, x2, y2 FROM chp06.cleveland_ways',
    89475,
    14584,
    false
    ))SELECT
    gid,
    the_geom
    FROM chp06.cleveland_ways w, astar a
    WHERE w.gid = a.edge;

