--Chapter 10
--Recipe 8

--Step 1.
mkdir postgis_cookbook/db
mkdir postgis_cookbook/db/primary
mkdir postgis_cookbook/db/standby

--Step 2.
cd postgis_cookbook/db
initdb --encoding=utf8 --locale=en_US.utf-8 –U me -D primary
initdb --encoding=utf8 --locale=en_US.utf-8 –U me -D standby


--Step 3.
mkdir postgis_cookbook/db/primary/archive
mkdir postgis_cookbook/db/standby/archive

--Step 6.
pg_ctl start -D primary -l primary\postgres.log


--Step 9.
psql -p 5433 -U me -c "SELECT pg_start_backup('base_backup', true)"
xcopy primary\* standby\ /e /exclude:primary\exclude.txt
psql -p 5433 -U me -c "SELECT pg_stop_backup()"

--Step 13.
pg_ctl start –U me -D standby -l standby\postgres.log

--Step 15
psql -p 5433 -U me
CREATE DATABASE test;
\c test
CREATE TABLE test AS SELECT 1 AS id, 'one'::text AS value;


--Step 16.
psql -p 5434 -U me


--Step 17
\l

--Step 18.
\c test
 
