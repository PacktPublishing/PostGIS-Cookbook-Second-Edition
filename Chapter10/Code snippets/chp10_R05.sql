--Chapter 10
--Recipe 5

--Step 1.
SELECT
  schoolid
FROM caschools sc
JOIN sfpoly sf
  ON ST_Intersects(sf.geom, ST_Transform(sc.geom, 3310));

--Step 3.
CLUSTER caschools
  USING caschools_geom_3310_idx;
