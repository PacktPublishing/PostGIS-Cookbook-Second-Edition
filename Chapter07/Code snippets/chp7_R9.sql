--Chapter 7
--Recipe 9

--How to do it
--Step 1.
DROP TABLE IF EXISTS chp07.uas_tin;
CREATE TABLE chp07.uas_tin AS WITH pts AS 
(
   SELECT
      PC_Explode(pa) AS pt 
   FROM
      chp07.uas_flights
)
SELECT
   ST_DelaunayTriangles(ST_Union(pt::geometry), 0.0, 2) AS the_geom 
FROM
   pts;



