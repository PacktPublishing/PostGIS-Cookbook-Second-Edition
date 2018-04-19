--Chapter 10
--Recipe 2

--Step 1.
CREATE ROLE group1 NOLOGIN;
CREATE ROLE group2 NOLOGIN;
CREATE ROLE user1 LOGIN PASSWORD 'pass1' IN ROLE group1;
CREATE ROLE user2 LOGIN PASSWORD 'pass2' IN ROLE group1;
CREATE ROLE user3 LOGIN PASSWORD 'pass3' IN ROLE group2;

--Step 2.
GRANT CONNECT, TEMP ON DATABASE chapter10 TO GROUP group1;
GRANT ALL ON DATABASE chapter10 TO GROUP group2;

--Step 3.
psql –U me -d chapter10
 
--Step 4.
REVOKE ALL ON DATABASE chapter10 FROM public;

--Step 7.
GRANT USAGE ON SCHEMA postgis TO group1, group2;

--Step 8.
GRANT USAGE ON SCHEMA postgis TO public;

REVOKE USAGE ON SCHEMA postgis FROM public;

--Step 10.
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA postgis TO public;

--Step 11.
REVOKE ALL ON FUNCTION postgis_full_version() FROM public;
REVOKE ALL ON FUNCTION postgis.postgis_full_version() FROM public;

--Step 12.
GRANT SELECT, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA postgis TO public;

--Step 13.
GRANT INSERT ON spatial_ref_sys TO group1;

--Step 14.
GRANT UPDATE, DELETE ON spatial_ref_sys TO user2;

--Step 15.
psql -d chapter10 -u user3

--Step 16.
SELECT count(*) FROM spatial_ref_sys;

--Step 17.
chapter10=# INSERT INTO spatial_ref_sys VALUES (99999, 'test', 99999, '', '');

--Step 18.
UPDATE spatial_ref_sys SET srtext = 'Lorum ipsum';

--Step 19.
chapter10=# SELECT postgis_full_version();



