--Chapter 7
--Recipe 1

--How to do it
--Step 3.
DROP TABLE IF EXISTS chp07.lidar;
CREATE TABLE chp07.lidar AS WITH patches AS 
(
   SELECT
      pa 
   FROM
      "chp07"."N2210595" 
   UNION ALL
   SELECT
      pa 
   FROM
      "chp07"."N2215595" 
   UNION ALL
   SELECT
      pa 
   FROM
      "chp07"."N2220595"
)
SELECT
   2 AS id,
   PC_Union(pa) AS pa 
FROM
   patches;

--Step 4.
CREATE TABLE chp07.lidar_patches AS WITH pts AS 
(
   SELECT
      PC_Explode(pa) AS pt 
   FROM
      chp07.lidar
)
SELECT
   pt::geometry AS the_geom 
FROM
   pts;
ALTER TABLE chp07.lidar_patches ADD COLUMN gid serial;
ALTER TABLE chp07.lidar_patches ADD PRIMARY KEY (gid);




