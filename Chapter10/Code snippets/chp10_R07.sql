--Chapter 10
--Recipe 7

--Step 1.
pg_dump –U me -f chapter10.backup -F custom chapter10

--Step 2.
psql -d postgres –U me
CREATE DATABASE new10;

--Step 3.
\c new10
CREATE SCHEMA postgis;

--Step 4.
CREATE EXTENSION postgis WITH SCHEMA postgis;

--Step 5.ALTER DATABASE new10 SET search_path = public, postgis;

--Step 6.
pg_restore –U me -d new10 --schema=public chapter10.backup

--Step 8.
pg_restore -f chapter10.sql --schema=public chapter10.backup

--Step 9.
SET search_path = public, pg_catalog;

--Step 10.
SET search_path = public, postgis, pg_catalog;

--Step 11.
psql –U me -d new10 -f chapter10.sql
