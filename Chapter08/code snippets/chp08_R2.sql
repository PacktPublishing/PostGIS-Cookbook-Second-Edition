--Chapter 8
--Recipe 2

--Getting ready
--Step 1.
CREATE SCHEMA chp08;

--Step 2.
ogr2ogr -f PostgreSQL -s_srs EPSG:4269 -t_srs EPSG:4326 -lco GEOMETRY_NAME=the_geom -nln chp08.cities PG:"dbname='postgis_cookbook' user='me' password='mypassword'" -where "POP_2000 > 100000" citiesx020.shp

--Step 3.
ALTER TABLE chp08.cities ADD COLUMN temperature real;

--Step 4.
source postgis-cb-env/bin/activate


--How to do it...

--Step 1.
CREATE TABLE chp08.wstations
(
id bigint NOT NULL,
the_geom geometry(Point,4326),
name character varying(48),
temperature real,
CONSTRAINT wstations_pk PRIMARY KEY (id )
);


--Step 4. get_weather_data.py:
import sys
import requests
import simplejson as json
import psycopg2

def GetWeatherData(lon, lat, key):
    """
    Get the 10 closest weather stations data for a given point.
    """
    # uri to access the JSON openweathermap web service
    uri = (
      'https://api.openweathermap.org/data/2.5/find?lat=%s&lon=%s&cnt=10&appid=%s'
      % (lat, lon, key))
    print 'Fetching weather data: %s' % uri
    try:
        data = requests.get(uri)
        print 'request status: %s' % data.status_code
        js_data = json.loads(data.text)
        return js_data['list']
    except:
        print 'There was an error getting the weather data.'
        print sys.exc_info()[0]
        return []

def AddWeatherStation(station_id, lon, lat, name, temperature):
    """
    Add a weather station to the database, but only if it does not already
    exists.
    """
    curws = conn.cursor()
    curws.execute('SELECT * FROM chp08.wstations WHERE id=%s', (station_id,))
    count = curws.rowcount
    if count==0: # we need to add the weather station
        curws.execute(
            """INSERT INTO chp08.wstations (id, the_geom, name, temperature)
            VALUES (%s, ST_GeomFromText('POINT(%s %s)', 4326), %s, %s)""",
            (station_id, lon, lat, name, temperature)
        )
        curws.close()
        print 'Added the %s weather station to the database.' % name
        return True
    else: # weather station already in database
        print 'The %s weather station is already in the database.' % name
        return False

# program starts here
# get a connection to the database
conn = psycopg2.connect('dbname=postgis_cookbook user=me password=password')
# we do not need transaction here, so set the connection to autocommit mode
conn.set_isolation_level(0)

# open a cursor to update the table with weather data
cur = conn.cursor()

# iterate all of the cities in the cities PostGIS layer, and for each of them
# grap the actual temperature from the closest weather station, and add the 10
# closest stations to the city to the wstation PostGIS layer
cur.execute("""SELECT ogc_fid, name,
    ST_X(the_geom) AS long, ST_Y(the_geom) AS lat FROM chp08.cities;""")
for record in cur:
    ogc_fid = record[0]
    city_name = record[1]
    lon = record[2]
    lat = record[3]
    stations = GetWeatherData(lon, lat, 'YOURKEY')
    print stations
    for station in stations:
        print station
        station_id = station['id']
        name = station['name']
        # for weather data we need to access the 'main' section in the json
        # 'main': {'pressure': 990, 'temp': 272.15, 'humidity': 54}
        if 'main' in station:
            if 'temp' in station['main']:
                temperature = station['main']['temp']
        else:
            temperature = -9999 # in some case the temperature is not available
        # "coord":{"lat":55.8622,"lon":37.395}
        station_lat = station['coord']['lat']
        station_lon = station['coord']['lon']
        # add the weather station to the database
        AddWeatherStation(station_id, station_lon, station_lat,
            name, temperature)
        # first weather station from the json API response is always the closest
        # to the city, so we are grabbing this temperature and store in the
        # temperature field in the cities PostGIS layer
        if station_id == stations[0]['id']:
          print 'Setting temperature to %s for city %s' % (
                temperature, city_name)
          cur2 = conn.cursor()
          cur2.execute(
                'UPDATE chp08.cities SET temperature=%s WHERE ogc_fid=%s',
                (temperature, ogc_fid))
            cur2.close()

# close cursor, commit and close connection to database
cur.close()
conn.close()


--Step 5.	
python get_weather_data.py
