--Chapter 8
--Recipe 6

--Getting ready...

--Step 2.
sudo apt-get install postgresql-contrib-9.1

--Step 3.
CREATE EXTENSION pg_trgm;

--Step 4.
source postgis-cb-env/bin/activate

--Step 5.
pip install pygdal
pip install psycopg2


--How to do it...

--Step 1. 
ogrinfo lazio.pbf

--Step 2. 
ogr2ogr -f PostgreSQL -lco GEOMETRY_NAME=the_geom -nln chp08.osm_roads PG:"dbname='postgis_cookbook' user='me' password='mypassword'" lazio.pbf lines

--Step 3.
SELECT name, similarity(name, 'via benedetto croce') AS sml, ST_AsText(ST_Centroid(the_geom)) AS the_geom
 FROM chp08.osm_roads
 WHERE name % 'via benedetto croce'
 ORDER BY sml DESC, name;
 
--Step 4.
SELECT name, name <-> 'via benedetto croce' AS weight
 FROM chp08.osm_roads
 ORDER BY weight LIMIT 10;

--Step 5. osmgeocoder.py 
import sys
import psycopg2

class OSMGeocoder(object):
    """
    A class to provide geocoding features using an OSM dataset in PostGIS.
    """

    def __init__(self, db_connectionstring):
        # initialize db connection parameters
        self.db_connectionstring = db_connectionstring

    def geocode(self, placename):
        """
        Geocode a given place name.
        """
        # here we create the connection object
        conn = psycopg2.connect(self.db_connectionstring)
        cur = conn.cursor()
        # this is the core sql query, using trigrams to detect streets similiar
        # to a given placename
        sql = """
            SELECT name, name <-> '%s' AS weight,
            ST_AsText(ST_Centroid(the_geom)) as  point
            FROM chp08.osm_roads
            ORDER BY weight LIMIT 10;
        """ % placename
        # here we execute the sql and return all of the results
        cur.execute(sql)
        rows = cur.fetchall()
        cur.close()
        conn.close()
        return rows

--Step 6.	
if __name__ == '__main__':
    # the user must provide at least two parameters, the place name
    # and the connection string to PostGIS
    if len(sys.argv) < 3 or len(sys.argv) > 3:
        print "usage: <placename> <connection string>"
        raise SystemExit
    placename = sys.argv[1]
    db_connectionstring = sys.argv[2]
    # here we instantiate the geocoder, providing the needed PostGIS connection
    # parameters
    geocoder = OSMGeocoder(db_connectionstring)
    # here we query the geocode method, for getting the geocoded points for the
    # given placename
    results = geocoder.geocode(placename)
    print results

--Step 7.	
python osmgeocoder.py "Via Benedetto Croce" "dbname=postgis_cookbook user=me password=mypassword"

--Step 8. geocode_streets.py
from osmgeocoder import OSMGeocoder
from osgeo import ogr, osr

# here we read the file
f = open('streets.txt')
streets = f.read().splitlines()
f.close()

# here we create the PostGIS layer using gdal/ogr
driver = ogr.GetDriverByName('PostgreSQL')
srs = osr.SpatialReference()
srs.ImportFromEPSG(4326)
pg_ds = ogr.Open(
    "PG:dbname='postgis_cookbook' host='localhost' port='5432' user='me' password='mypassword'",
    update = 1 )
pg_layer = pg_ds.CreateLayer('geocoded_points', srs = srs, geom_type=ogr.wkbPoint,
    options = [
        'GEOMETRY_NAME=the_geom',
        'OVERWRITE=YES', # this will drop and recreate the table every time
        'SCHEMA=chp08',
    ])
# here we add the field to the PostGIS layer
fd_name = ogr.FieldDefn('name', ogr.OFTString)
pg_layer.CreateField(fd_name)
print 'Table created.'

# now we geocode all of the streets in the file using the osmgeocoder class
geocoder = OSMGeocoder('dbname=postgis_cookbook user=me password=mypassword')
for street in streets:
    print street
    geocoded_street = geocoder.geocode(street)[0]
    print geocoded_street
    # format is
    # ('Via delle Sette Chiese', 0.0, 'POINT(12.5002166330412 41.859774874774)')
    point_wkt = geocoded_street[2]
    point = ogr.CreateGeometryFromWkt(point_wkt)
    # we create a LayerDefn for the feature using the one from the layer
    featureDefn = pg_layer.GetLayerDefn()
    feature = ogr.Feature(featureDefn)
    # now we store the feature geometry and the value for the name field
    feature.SetGeometry(point)
    feature.SetField('name', geocoded_street[0])
    # finally we create the feature (an INSERT command is issued only here)
    pg_layer.CreateFeature(feature)


--Step 9.	
python geocode_streets.py