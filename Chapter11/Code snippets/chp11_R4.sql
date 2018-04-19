--Chapter 11
--Recipe 4

--Step 2.
SELECT gid, ST_BUFFER("chp11".lines.geom_sp, 75) AS the_geom, fullname FROM "chp11".lines WHERE fullname <> '' AND hydroflg = 'Y'

--Step 3.
SELECT AddGeometryColumn('chp11', 'lines','geom_sp',3734, 'MULTILINESTRING', 2);
UPDATE "chp11".lines SET geom_sp = ST_Transform(geom,3734);

--Step 10.
SELECT ST_UNION(geom1, geom2) AS geom

