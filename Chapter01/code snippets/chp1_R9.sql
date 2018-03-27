-- RECIPE 9 ********************************************
-- How to do it ****************************************

-- Step 2 **********************************************

SELECT r_raster_column, 
srid, 
ROUND(scale_x::numeric, 2) AS scale_x, 
ROUND(scale_y::numeric, 2) AS scale_y, 
blocksize_x, 
blocksize_y, 
num_bands, 
pixel_types, 
nodata_values, 
out_db 
FROM raster_columns 
where r_table_schema='chp01' AND r_table_name ='tmax_2012';

-- Step 3 **********************************************

SELECT rid, (foo.md).*
    FROM (SELECT rid, ST_MetaData(rast) As md FROM chp01.tmax_2012) As foo;

-- Step 4 **********************************************

SELECT COUNT(*) AS num_raster, MIN(filename) as original_file FROM chp01.tmax_2012
GROUP BY filename ORDER BY filename;

-- Step 5 **********************************************

SELECT REPLACE(REPLACE(filename, 'tmax', ''), '.bil', '') AS month,
                (ST_VALUE(rast, ST_SetSRID(ST_Point(12.49, 41.88), 4326))/10) AS tmax
                FROM chp01.tmax_2012
                WHERE rid IN (
                        SELECT rid FROM chp01.tmax_2012
                        WHERE ST_Intersects(ST_Envelope(rast), ST_SetSRID(ST_Point(12.49, 41.88), 4326))
                        )
                ORDER BY month;

-- Step 10 **********************************************

SELECT r_raster_column, srid, blocksize_x, blocksize_y, num_bands, pixel_types 
from raster_columns 
where r_table_schema='chp01' AND  r_table_name ='tmax_2012_multi';
