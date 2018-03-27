#!/bin/bash
for ((i = 1; i < 9 ; i++)) ; do
    echo "Importing earthquakes with magnitude $i to chp03.earthquakes PostGIS table..."
    ogr2ogr -append -f PostgreSQL -nln chp03.earthquakes PG:"dbname='postgis_cookbook' user='me' password='mypassword'" 2012_Earthquakes_ALL.kml -sql "SELECT name, description, CAST($i AS integer) AS magnitude FROM \"Magnitude $i\""
done
