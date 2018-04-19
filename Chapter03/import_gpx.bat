@echo off
for %%I in (runkeeper_gpx\*.gpx*) do (
    echo Importing gpx file %%~nxI to chp03.rk_track_points PostGIS table...
    ogr2ogr -append -update -f PostgreSQL PG:"dbname='postgis_cookbook' user='me' password='mypassword'" runkeeper_gpx/%%~nxI -nln chp03.rk_track_points -sql "SELECT ele, time FROM track_points"
)