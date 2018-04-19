--Chapter 7
--Recipe 8

--Getting Ready
{
  "pipeline": [{
    "type": "readers.ply",
    "filename": "/data/uas_flight/uas_points.ply"
  }, {
    "type": "writers.pgpointcloud",
    "connection": "host='localhost' dbname='postgis-cookbook' user='me' password='me' port='5432'",
    "table": "uas",
    "schema": "chp07"
  }]
}

