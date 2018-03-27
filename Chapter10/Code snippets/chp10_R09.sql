--Chapter 10
--Recipe 9

--Step 1.
psql –d postgis_cookbook –U me

--Step 2.
CREATE SCHEMA chp10;

--Step 3.
CREATE TABLE chp10.hotspots_dist (id serial PRIMARY KEY, the_geom public.geometry(Point,4326));

--Step 4.
postgis_cookbook=# \q

--Step 5.
psql –U me

--Step 6.

CREATE DATABASE quad_NW;
CREATE DATABASE quad_NE;
CREATE DATABASE quad_SW;
CREATE DATABASE quad_SE;

\c quad_NW;
CREAT EXTENSION postgis;
CREATE TABLE hotspots_quad_NW (id serial PRIMARY KEY, the_geom public.geometry(Point,4326));

\c quad_NE;
CREAT EXTENSION postgis;
CREATE TABLE hotspots_quad_NE (id serial PRIMARY KEY, the_geom public.geometry(Point,4326));

\c quad_SW;
CREAT EXTENSION postgis;
CREATE TABLE hotspots_quad_SW (id serial PRIMARY KEY, the_geom public.geometry(Point,4326));

\c quad_SE;
CREAT EXTENSION postgis;
CREATE TABLE hotspots_quad_SE (id serial PRIMARY KEY, the_geom public.geometry(Point,4326));

\q

--Step 7.
--<OGRVRTDataSource>
--  <OGRVRTLayer name="Global_24h">
--    <SrcDataSource>Global_24h.csv</SrcDataSource>
--    <GeometryType>wkbPoint</GeometryType>
--    <LayerSRS>EPSG:4326</LayerSRS>
--    <GeometryField encoding="PointFromColumns"      x="longitude" y="latitude"/>
--  </OGRVRTLayer>
--</OGRVRTDataSource>

--Step 8.
ogr2ogr -f PostgreSQL PG:"dbname='postgis_cookbook' user='me' password='mypassword'" -lco SCHEMA=chp10 global_24h.vrt -lco OVERWRITE=YES -lco GEOMETRY_NAME=the_geom -nln hotspots

--Step 9.
postgis_cookbook =# CREATE EXTENSION postgres_fdw;

--Step 10. 
CREATE SERVER quad_NW FOREIGN DATA WRAPPER postgres_fdw OPTIONS (dbname 'quad_NW', host 'localhost', port '5432');
CREATE SERVER quad_SW FOREIGN DATA WRAPPER postgres_fdw OPTIONS (dbname 'quad_SW', host 'localhost', port '5432');
CREATE SERVER quad_NE FOREIGN DATA WRAPPER postgres_fdw OPTIONS (dbname 'quad_NE', host 'localhost', port '5432');
CREATE SERVER quad_SE FOREIGN DATA WRAPPER postgres_fdw OPTIONS (dbname 'quad_SE', host 'localhost', port '5432');

--Step 11.
CREATE USER MAPPING FOR POSTGRES SERVER quad_NW OPTIONS (user 'remoteme1', password 'myPassremote1');
CREATE USER MAPPING FOR POSTGRES SERVER quad_SW OPTIONS (user 'remoteme2', password 'myPassremote2');
CREATE USER MAPPING FOR POSTGRES SERVER quad_NE OPTIONS (user 'remoteme3', password 'myPassremote3');
CREATE USER MAPPING FOR POSTGRES SERVER quad_SE OPTIONS (user 'remoteme4', password 'myPassremote4');

--Step 12.
CREATE FOREIGN TABLE hotspots_quad_NW () INHERITS (chp10.hotspots_dist) SERVER quad_NW OPTIONS (table_name 'hotspots_quad_sw');
CREATE FOREIGN TABLE hotspots_quad_SW () INHERITS (chp10.hotspots_dist) SERVER quad_SW OPTIONS (table_name 'hotspots_quad_sw');
CREATE FOREIGN TABLE hotspots_quad_NE () INHERITS (chp10.hotspots_dist) SERVER quad_NE OPTIONS (table_name 'hotspots_quad_ne');
CREATE FOREIGN TABLE hotspots_quad_SE () INHERITS (chp10.hotspots_dist) SERVER quad_SE OPTIONS (table_name 'hotspots_quad_se');


--Step 13. 
CREATE OR REPLACE FUNCTION __trigger_users_before_insert(
) RETURNS trigger AS $__$
DECLARE

angle integer;

BEGIN
	
    EXECUTE $$ select (st_azimuth(ST_geomfromtext('Point(0 0)' ,4326), $1) /(2*PI()))*360 $$
		INTO angle
    USING
    	NEW.the_geom; 
    
    	IF (angle >= 0 AND angle<90) THEN
  		EXECUTE $$
  			INSERT INTO hotspots_quad_ne (the_geom) VALUES (
            	$1
        	)
        $$ USING
        	NEW.the_geom;
        END IF;
        	
            IF (angle >= 90 AND angle <180) THEN
        	EXECUTE $$
                INSERT INTO hotspots_quad_NW  (the_geom) VALUES (
                    $1
                )
            $$ USING
                NEW.the_geom;
            END IF;
            
            	IF (angle >= 180 AND angle <270) THEN
        		EXECUTE $$
                    INSERT INTO hotspots_quad_SW  (the_geom) VALUES (
                        $1
                    )
                $$ USING
                    NEW.the_geom;
                END IF;
                
                IF (angle >= 270 AND angle <360) THEN
                	EXECUTE $$
                        INSERT INTO hotspots_quad_SE  (the_geom) VALUES (
                            $1
                        )
                    $$ USING
                        NEW.the_geom;
                END IF;
    RETURN null;
END;
$__$ LANGUAGE plpgsql;
CREATE TRIGGER users_before_insert BEFORE INSERT ON chp10.hotspots_dist FOR EACH ROW EXECUTE PROCEDURE __trigger_users_before_insert();

--Step 14.
INSERT INTO CHP10.hotspots_dist (the_geom) VALUES (0, st_geomfromtext('POINT (10 10)',4326)); 
INSERT INTO CHP10.hotspots_dist (the_geom) VALUES ( st_geomfromtext('POINT (-10 10)',4326));
INSERT INTO CHP10.hotspots_dist (the_geom) VALUES ( st_geomfromtext('POINT (-10 -10)',4326));

--Step 15.
postgis_cookbook=# SELECT ST_ASTEXT(the_geom) FROM CHP10.hotspots_dist;

postgis_cookbook=# SELECT ST_ASTEXT(the_geom) FROM hotspots_quad_ne;

 
--Step 16.
postgis_cookbook=# insert into CHP10.hotspots_dist (the_geom, quadrant)
select the_geom, 0 as geom
from chp10.hotspots;

--Step 17.
postgis_cookbook=# SELECT ST_ASTEXT(the_geom) FROM CHP10.hotspots_dist;


 

The results show the first 10 points stored in the local logical version of the database.

postgis_cookbook=# SELECT ST_ASTEXT(the_geom) FROM hotspots_quad_ne;

