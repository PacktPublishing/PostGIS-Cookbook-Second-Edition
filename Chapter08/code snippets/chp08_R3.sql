--Chapter 8
--Recipe 3

--Getting ready
--Step 3.
source postgis-cb-env/bin/activate

--Step 4.
pip install gdal
install simplejson



--How to do it...

--Step 4. import_places.py 
import sys
import requests
import simplejson as json
from osgeo import ogr, osr

MAXROWS = 10
USERNAME = 'postgis' #enter your username here

def CreatePGLayer():
    """
    Create the PostGIS table.
    """
    driver = ogr.GetDriverByName('PostgreSQL')
    srs = osr.SpatialReference()
    srs.ImportFromEPSG(4326)
    ogr.UseExceptions()
    pg_ds = ogr.Open("PG:dbname='postgis_cookbook' host='localhost' port='5432' user='me' password='password'", update = 1)
    pg_layer = pg_ds.CreateLayer('wikiplaces', srs = srs, geom_type=ogr.wkbPoint,
        options = [
            'DIM=3', # we want to store the elevation value in point z coordinate
            'GEOMETRY_NAME=the_geom',
            'OVERWRITE=YES', # this will drop and recreate the table every time
            'SCHEMA=chp08',
        ])
    # add the fields
    fd_title = ogr.FieldDefn('title', ogr.OFTString)
    pg_layer.CreateField(fd_title)
    fd_countrycode = ogr.FieldDefn('countrycode', ogr.OFTString)
    pg_layer.CreateField(fd_countrycode)
    fd_feature = ogr.FieldDefn('feature', ogr.OFTString)
    pg_layer.CreateField(fd_feature)
    fd_thumbnail = ogr.FieldDefn('thumbnail', ogr.OFTString)
    pg_layer.CreateField(fd_thumbnail)
    fd_wikipediaurl = ogr.FieldDefn('wikipediaurl', ogr.OFTString)
    pg_layer.CreateField(fd_wikipediaurl)
    return pg_ds, pg_layer

def AddPlacesToLayer(places):
    """
    Read the places dictionary list and add features in the PostGIS table for each place.
    """
    # iterate every place dictionary in the list
    print "places: ", places
    for place in places:
        lng = place['lng']
        lat = place['lat']
        z = place.get('elevation') if 'elevation' in place else 0
        # we generate a point representation in wkt, and create an ogr geometry
        point_wkt = 'POINT(%s %s %s)' % (lng, lat, z)
        point = ogr.CreateGeometryFromWkt(point_wkt)
        # we create a LayerDefn for the feature using the one from the layer
        featureDefn = pg_layer.GetLayerDefn()
        feature = ogr.Feature(featureDefn)
        # now time to assign the geometry and all the other feature's fields,
        # if the keys are contained in the dictionary (not always the GeoNames
        # Wikipedia Fulltext Search contains all of the information)
        feature.SetGeometry(point)
        feature.SetField('title',
            place['title'].encode("utf-8") if 'title' in place else '')
        feature.SetField('countrycode',
            place['countryCode'] if 'countryCode' in place else '')
        feature.SetField('feature',
            place['feature'] if 'feature' in place else '')
        feature.SetField('thumbnail',
            place['thumbnailImg'] if 'thumbnailImg' in place else '')
        feature.SetField('wikipediaurl',
            place['wikipediaUrl'] if 'wikipediaUrl' in place else '')
        # here we create the feature (the INSERT SQL is issued here)
        pg_layer.CreateFeature(feature)
        print 'Created a places titled %s.' % place['title']

def GetPlaces(placename):
    """
    Get the places list for a given placename.
    """
    # uri to access the JSON GeoNames Wikipedia Fulltext Search web service
    uri = ('http://api.geonames.org/wikipediaSearchJSON?formatted=true&q=%s&maxRows=%s&username=%s&style=full'
            % (placename, MAXROWS, USERNAME))
    data = requests.get(uri)
    js_data = json.loads(data.text)
    return js_data['geonames']

def GetNamesList(filepath):
    """
    Open a file with a given filepath containing place names and return a list.
    """
    f = open(filepath, 'r')
    return f.read().splitlines()

# first we need to create a PostGIS table to contains the places
# we must keep the PostGIS OGR dataset and layer global, for the reasons
# described here: http://trac.osgeo.org/gdal/wiki/PythonGotchas
from osgeo import gdal
gdal.UseExceptions()
pg_ds, pg_layer = CreatePGLayer()

try:
    # query geonames for each name and store found places in the table
    names = GetNamesList('names.txt')
    print names
    for name in names:
        AddPlacesToLayer(GetPlaces(name))
except Exception as e:
    print(e)
    print sys.exc_info()[0]


--Step 5.
python import_places.py

--Step 6.
select ST_AsText(the_geom), title, countrycode, feature from chp08.wikiplaces;





