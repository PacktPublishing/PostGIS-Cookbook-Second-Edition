-- RECIPE 2 ********************************************
-- Step 1 ***************************************************

CREATE TABLE chp12.supermarkets (
   sup_id serial,
 	the_geom geometry(Point,4326),
   latitude numeric,
   longitude numeric,
   PRIMARY KEY (sup_id)
);

CREATE TABLE chp12.supermarkets_mapir (
    sup_id int REFERENCES chp12.supermarkets (sup_id),
    cellid int,
    levelid int
);

-- Step 2 ***************************************************

CREATE OR REPLACE FUNCTION __trigger_supermarkets_after_insert(
) RETURNS trigger AS $__$
DECLARE
tempcelliD integer;
BEGIN
	FOR i IN -2..6
    LOOP
		tempcellid = mod((mod(CAST(TRUNC(ABS(NEW.latitude)*POWER(10,i))as int),10)+1) * (mod(CAST(TRUNC(ABS(NEW.longitude)*POWER(10,i))as int),10)+1), 11)-1;
        
	INSERT INTO chp12.supermarkets_mapir (sup_id, cellid, levelid) VALUES (NEW.sup_id, tempcellid, i);

    END LOOP;
	Return NEW;	
	
END;
$__$ LANGUAGE plpgsql;

CREATE TRIGGER supermarkets_after_insert AFTER INSERT ON chp12.supermarkets FOR EACH ROW EXECUTE PROCEDURE __trigger_supermarkets_after_insert ();

-- Step 3 ***************************************************

INSERT INTO chp12.supermarkets (the_geom, longitude, latitude)
VALUES
(ST_GEOMFROMTEXT('POINT(-76.304202 3.8992
)',4326),-76.304202, 3.8992),(ST_GEOMFROMTEXT('POINT(-76.308476 3.894591
)',4326),-76.308476, 3.894591 ),(ST_GEOMFROMTEXT('POINT(-76.297893 3.890615
)',4326),-76.297893, 3.890615 ),(ST_GEOMFROMTEXT('POINT(-76.299017 3.901726
)',4326),-76.299017, 3.901726),(ST_GEOMFROMTEXT('POINT(-76.292027 3.909094
)',4326),-76.292027, 3.909094 ),(ST_GEOMFROMTEXT('POINT(-76.299687 3.888735
)',4326),-76.299687, 3.888735 ),(ST_GEOMFROMTEXT('POINT(-76.307102 3.899181
)',4326), -76.307102, 3.899181 ),(ST_GEOMFROMTEXT('POINT(-76.310342 3.90145
)',4326),-76.310342, 3.90145),(ST_GEOMFROMTEXT('POINT(-76.297366 3.889721
)',4326), -76.297366, 3.889721),(ST_GEOMFROMTEXT('POINT(-76.293296 3.906171
)',4326),-76.293296, 3.906171 ),(ST_GEOMFROMTEXT('POINT(-76.300154 3.901235
)',4326),-76.300154, 3.901235 ),(ST_GEOMFROMTEXT('POINT(-76.299755 3.899361
)',4326),-76.299755, 3.899361 ),(ST_GEOMFROMTEXT('POINT(-76.303509 3.911253
)',4326),-76.303509, 3.911253),(ST_GEOMFROMTEXT('POINT(-76.300152 3.901175
)',4326),-76.300152, 3.901175 ),(ST_GEOMFROMTEXT('POINT(-76.299286 3.900895
)',4326), -76.299286, 3.900895),(ST_GEOMFROMTEXT('POINT(-76.309937 3.912021)',4326),-76.309937, 3.912021);

-- Step 4 ***************************************************

SELECT * 
FROM supermarkets_mapir
WHERE sup_id = 8;


-- Step 5 ***************************************************

SELECT sm.the_geom AS the_geom
FROM chp12.supermarkets_mapir AS smm, chp12.supermarkets AS sm
WHERE smm.levelid = 2 AND smm.cellid = 9 AND smm.sup_id = sm.sup_id;

