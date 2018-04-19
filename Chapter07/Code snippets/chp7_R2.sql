--Chapter 7
--Recipe 2

--How to do it
--Step 1.
CREATE INDEX chp07_lidar_the_geom_idx 
ON chp07.lidar USING gist(the_geom);

--Step 2.
CREATE INDEX chp07_lidar_the_geom_3dx
ON chp07.lidar USING gist(the_geom gist_geometry_ops_nd);


--Step 3.
shp2pgsql -s 3734 -d -i -I -W LATIN1 -t 3DZ -g the_geom hydro_line chp07.hydro | PGPASSWORD=me psql -U me -d "postgis-cookbook" -h localhost

--Step 4.
DROP TABLE IF EXISTS chp07.lidar_patches_within;
CREATE TABLE chp07.lidar_patches_within AS
SELECT
   chp07.lidar_patches.gid, chp07.lidar_patches.the_geom
FROM
   chp07.lidar_patches,
   chp07.hydro 
WHERE
   ST_3DDWithin(chp07.hydro.the_geom, chp07.lidar_patches.the_geom, 5);

--Step 5.
DROP TABLE IF EXISTS chp07.lidar_patches_within_distinct;
CREATE TABLE chp07.lidar_patches_within_distinct AS
SELECT
   DISTINCT (chp07.lidar_patches.the_geom), 
   chp07.lidar_patches.gid 
FROM
   chp07.lidar_patches,
   chp07.hydro 
WHERE
   ST_3DDWithin(chp07.hydro.the_geom, chp07.lidar_patches.the_geom, 5);



