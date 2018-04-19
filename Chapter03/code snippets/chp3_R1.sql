-- RECIPE 1 ********************************************

-- How to do it ****************************************

-- Step 1 **********************************************
create schema chp03;

-- Step 2 **********************************************
CREATE TABLE chp03.rk_track_points
(
  fid serial NOT NULL,
  the_geom geometry(Point,4326),
  ele double precision,
  "time" timestamp with time zone,
  CONSTRAINT activities_pk PRIMARY KEY (fid)
);

-- Step 5 **********************************************
SELECT
ST_MakeLine(the_geom) AS the_geom,
    run_date::date,
    MIN(run_time) as start_time,
    MAX(run_time) as end_time
    INTO chp03.tracks
    FROM (
        SELECT the_geom,
        "time"::date as run_date,
        "time" as run_time
        FROM chp03.rk_track_points
        ORDER BY run_time
    ) AS foo GROUP BY run_date;

-- Step 6 **********************************************
CREATE INDEX rk_track_points_geom_idx ON chp03.rk_track_points USING gist(the_geom);
CREATE INDEX tracks_geom_idx ON chp03.tracks USING gist(the_geom);

-- Step 9 **********************************************
SELECT
    EXTRACT(year FROM run_date) AS run_year,
    EXTRACT(MONTH FROM run_date) as run_month,
    SUM(ST_Length(geography(the_geom)))/1000 AS distance FROM chp03.tracks
GROUP BY run_year, run_month ORDER BY run_year, run_month;

-- Step 10 **********************************************
SELECT
    c.country_name,
    SUM(ST_Length(geography(t.the_geom)))/1000 AS run_distance
FROM chp03.tracks AS t
JOIN chp01.countries AS c
ON ST_Intersects(t.the_geom, c.the_geom)
GROUP BY c.country_name
ORDER BY run_distance DESC;

