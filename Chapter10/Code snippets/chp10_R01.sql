--Chapter 10
--Recipe 1

--Step 1.
CREATE DATABASE chapter10;

--Step 2.
CREATE SCHEMA postgis;

--Step 3.
CREATE EXTENSION postgis WITH SCHEMA postgis;

--Step 4.
psql –U me -d chapter10 
chapter10=# SET search_path = public, postgis;

--Step 5.
ALTER DATABASE chapter10 SET search_path = public, postgis;

--Step 6.
-- Without defining the searchpath
> raster2pgsql -s 4322 -t 100x100 -I -F -C -Y C:\postgis_cookbook\data\chap5\PRISM\ --PRISM_tmin_provisional_4kmM2_201703_asc.asc prism | psql -d chapter10 –U me

-- Defining the searchpath
> raster2pgsql -s 4322 -t 100x100 -I -F -C -Y C:\postgis_cookbook\data\chap5\PRISM\PRISM_tmin_provisional_4kmM2_201703_asc.asc prism | psql "dbname=chapter10 options=
search_path=postgis" me 

--Step 7.	
ALTER TABLE postgis.prism ADD COLUMN month_year DATE;
UPDATE postgis.prism SET  month_year = ( SUBSTRING(split_part(filename, '_', 5), 0, 5) || '-' ||  SUBSTRING(split_part(filename, '_', 5), 5, 4) || '-01' ) :: DATE;

--Step 8.
-- Without defining the searchpath
shp2pgsql -s 3310 -I C:\postgis_cookbook\data\chap5\SFPoly\sfpoly.shp sfpoly | psql -d chapter10 –U me

-- Defining the searchpath
shp2pgsql -s 3310 -I C:\postgis_cookbook\data\chap5\SFPoly\sfpoly.shp sfpoly | psql "dbname=chapter10 options=--search_path=postgis" me

--Step 9.
mkdir C:\postgis_cookbook\data\chap10
cp -r /path/to/book_dataset/chap10 C:\postgis_cookbook\data\chap10

-- Without defining the searchpath
shp2pgsql -s 4269 -I C:\postgis_cookbook\data\chap10\CAEmergencyFacilities \CA_police.shp capolice | psql -d chapter10 –U me

shp2pgsql -s 4269 C:\postgis_cookbook\data\chap10\CAEmergencyFacilities \CA_schools.shp caschools | psql -d chapter10 –U me


-- Defining the searchpath
shp2pgsql -s 4269 -I C:\postgis_cookbook\data\chap10\CAEmergencyFacilities
  \CA_schools.shp caschools | psql "dbname=chapter10 options=--search_path=postgis" me

shp2pgsql -s 4269 -I C:\postgis_cookbook\data\chap10\CAEmergencyFacilities
  \CA_police.shp capolice | psql "dbname=chapter10 options=--search_path=postgis" me


