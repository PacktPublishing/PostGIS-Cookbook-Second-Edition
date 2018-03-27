--Chapter 11
--Recipe 2

--Step 2
--Substep 2.
SELECT AddGeometryColumn('chp11', 'lines','geom_sp',3734, 'MULTILINESTRING', 2);
UPDATE "chp11".lines 
SET geom_sp = ST_Transform(the_geom,3734);

--Substep 4.
SELECT gid, ST_Buffer(geom_sp, 10) AS geom, fullname, roadflg FROM "chp11".lines WHERE roadflg = 'Y'

--Substep 5.
CREATE TABLE "chp11".roads_buffer_sp AS SELECT gid, ST_Buffer(geom_sp, 10) AS geom, fullname, roadflg FROM "chp11".lines WHERE roadflg = 'Y'




