--Chapter 8
--Recipe 4

--Getting ready
--Step 1.
sudo apt-get install postgresql-plpython-9.1

--Step 2.
psql -U me postgis_cookbook

CREATE EXTENSION plpythonu;




--How to do it...

--Step 3. 
CREATE OR REPLACE FUNCTION chp08.GetWeather(lon float, lat float)
    RETURNS float
AS $$
    import urllib2
    import simplejson as json
    data = urllib2.urlopen(
        'http://api.openweathermap.org/data/2.1/find/station?lat=%s&lon=%s&cnt=1'
        % (lat, lon))
    js_data = json.load(data)
    if js_data['cod'] == '200': # only if cod is 200 we got some effective results
                if int(js_data['cnt'])>0: # check if we have at least a weather station
                    station = js_data['list'][0]
                    print 'Data from weather station %s' % station['name']
                    if 'main' in station:
                        if 'temp' in station['main']:
                            temperature = station['main']['temp'] - 273.15 # we want the temperature in Celsius
                        else:
                            temperature = None
    else:
            temperature = None
    return temperature
$$ LANGUAGE plpythonu;

--Step 4. 
SELECT chp08.GetWeather(100.49, 13.74);

--Step 5.
SELECT name, temperature, chp08.GetWeather(ST_X(the_geom), ST_Y(the_geom)) AS temperature2 FROM chp08.cities LIMIT 5;

--Step 6.
CREATE OR REPLACE FUNCTION chp08.GetWeather(geom geometry)
    RETURNS float
AS $$
    BEGIN
        RETURN chp08.GetWeather(ST_X(ST_Centroid(geom)), ST_Y(ST_Centroid(geom)));
    END;
$$ LANGUAGE plpgsql;

--Step 7.
SELECT chp08.GetWeather(ST_GeomFromText('POINT(-71.064544 42.28787)'));

--Step 8. 
SELECT name, temperature, chp08.GetWeather(the_geom) AS temperature2 FROM chp08.cities LIMIT 5;


