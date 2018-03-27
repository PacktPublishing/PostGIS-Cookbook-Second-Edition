--Chapter 8
--Recipe 7

--Getting ready...

--Step 1.
sudo pip install geopy
--In Windows
pip install geopy


--Step 2.
sudo apt-get install postgresql-contrib-9.1

--Step 3.
CREATE EXTENSION plpythonu;



--How to do it...

--Step 1. 
CREATE OR REPLACE FUNCTION chp08.Geocode(address text)
        RETURNS geometry(Point,4326)
    AS $$
        from geopy import geocoders
        g = geocoders.GoogleV3()
        place, (lat, lng) = g.geocode(address)
        plpy.info('Geocoded %s for the address: %s' % (place, address))
        plpy.info('Longitude is %s, Latitude is %s.' % (lng, lat))
        plpy.info("SELECT ST_GeomFromText('POINT(%s %s)', 4326)" % (lng, lat))
        result = plpy.execute("SELECT ST_GeomFromText('POINT(%s %s)', 4326) AS point_geocoded" % (lng, lat))
        geometry = result[0]["point_geocoded"]
        return geometry
    $$ LANGUAGE plpythonu;


--Step 2. 
SELECT chp08.Geocode('Viale Ostiense 36, Rome');

--Step 3.
CREATE OR REPLACE FUNCTION chp08.Geocode(address text, api text DEFAULT 'google')
    RETURNS geometry(Point,4326)
AS $$
    from geopy import geocoders
    plpy.info('Geocoing the given address using the %s api' % (api))
    if api.lower() == 'geonames':
        g = geocoders.GeoNames()
    elif api.lower() == 'geocoderdotus':
        g = geocoders.GeocoderDotUS()
    else: # in all other cases, we use google
        g = geocoders.GoogleV3()
    try:
        place, (lat, lng) = g.geocode(address)
        plpy.info('Geocoded %s for the address: %s' % (place, address))
        plpy.info('Longitude is %s, Latitude is %s.' % (lng, lat))
        result = plpy.execute("SELECT ST_GeomFromText('POINT(%s %s)', 4326) AS point_geocoded" % (lng, lat))
        geometry = result[0]["point_geocoded"]
        return geometry
    except:
        plpy.warning('There was an error in the geocoding process, setting geometry to Null.')
        return None
$$ LANGUAGE plpythonu;

 
--Step 4.
SELECT chp08.Geocode('161 Court Street, Brooklyn, NY');

--Step 5. SELECT chp08.Geocode('161 Court Street, Brooklyn, NY', 'GeocoderDotUS');

