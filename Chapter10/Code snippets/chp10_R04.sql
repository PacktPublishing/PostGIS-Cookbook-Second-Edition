--Chapter 10
--Recipe 4

--Step 1.

SELECT
  schoolid
FROM caschools sc
JOIN sfpoly sf
  ON ST_Intersects(sf.geom, ST_Transform(sc.geom, 3310));

--Step 3.
EXPLAIN ANALYZE
SELECT
  schoolid
FROM caschools sc
JOIN sfpoly sf
  ON ST_Intersects(sf.geom, ST_Transform(sc.geom, 3310));

--Step 4.
CREATE INDEX caschools_geom_idx
  ON caschools
  USING gist
  (geom);

--Step 7.
CREATE INDEX caschools_geom_3310_idx
  ON caschools
  USING gist
  (ST_Transform(geom, 3310));
