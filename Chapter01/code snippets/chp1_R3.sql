-- RECIPE 3 ********************************************
-- Step 5 **********************************************

SELECT f_geography_column, coord_dimension, srid, type 
FROM geography_columns
WHERE f_table_name = 'global_24h_geographic';