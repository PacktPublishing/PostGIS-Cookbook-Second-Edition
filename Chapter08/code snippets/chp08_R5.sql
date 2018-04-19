--Chapter 8
--Recipe 5

--How to do it...

--Step 2. 
ogrinfo CSV:IT.txt IT -al -so

--Step 3.	ogrinfo CSV:IT.txt IT -where "NAME = 'San Gimignano'"
 
--Step 4.
ogr2ogr -f PostgreSQL -s_srs EPSG:4326 -t_srs EPSG:4326 -lco GEOMETRY_NAME=the_geom -nln chp08.geonames PG:"dbname='postgis_cookbook' user='me' password='mypassword'" CSV:IT.txt -sql "SELECT NAME, ASCIINAME FROM IT"

--Step 5.
SELECT ST_AsText(the_geom), name FROM chp08.geonames LIMIT 10;
 
--Step 6.
CREATE OR REPLACE FUNCTION chp08.Get_Closest_PlaceNames(in_geom geometry, num_results int DEFAULT 5, OUT geom geometry, OUT place_name character varying)
    RETURNS SETOF RECORD
AS $$
    BEGIN
        RETURN QUERY
        SELECT the_geom as geom, name as place_name
        FROM chp08.geonames
        ORDER BY the_geom <-> ST_Centroid(in_geom) LIMIT num_results;
    END;
$$ LANGUAGE plpgsql;

--Step 7.
SELECT * FROM chp08.Get_Closest_PlaceNames(ST_PointFromText('POINT(13.5 42.19)', 4326), 10);

--Step 8.
SELECT * FROM chp08.Get_Closest_PlaceNames(ST_PointFromText('POINT(13.5 42.19)', 4326));

--Step 9.
CREATE OR REPLACE FUNCTION chp08.Find_PlaceNames(search_string text,
        num_results int DEFAULT 5,
        OUT geom geometry,
        OUT place_name character varying)
    RETURNS SETOF RECORD
AS $$
    BEGIN
        RETURN QUERY
        SELECT the_geom as geom, name as place_name
        FROM chp08.geonames
        WHERE name @@ to_tsquery(search_string)
        LIMIT num_results;
    END;
$$ LANGUAGE plpgsql;

--Step 10.
SELECT * FROM chp08.Find_PlaceNames('Rocca', 10);
