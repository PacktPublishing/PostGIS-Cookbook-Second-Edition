-- RECIPE 4 ********************************************

-- How to do it ****************************************

CREATE OR REPLACE FUNCTION chp04.polygonize_to_multi (geometry) RETURNS geometry AS $$

    WITH polygonized AS (
        SELECT ST_Polygonize($1) AS the_geom
        ),
    dumped AS (
    SELECT (ST_Dump(the_geom)).geom AS the_geom FROM
        polygonized
    )
     SELECT ST_Multi(ST_Collect(the_geom)) FROM
        dumped
;
$$ LANGUAGE SQL;
