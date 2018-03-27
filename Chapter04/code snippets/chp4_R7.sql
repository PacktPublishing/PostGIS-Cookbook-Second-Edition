-- RECIPE 7 ********************************************

-- Getting ready ***************************************
CREATE TABLE chp04.earthq_cent (
cid integer PRIMARY KEY, the_geom geometry('POINT',4326)
);

CREATE TABLE chp04.earthq_circ (
cid integer PRIMARY KEY, the_geom geometry('POLYGON',4326)
);

-- How to do it ****************************************

INSERT INTO chp04.earthq_cent (the_geom, cid) (
SELECT DISTINCT ST_SetSRID(ST_Centroid(tab2.ge2), 4326) as centroid, tab2.cid
FROM(
  SELECT ST_UNION(tab.ge) OVER (partition by tab.cid ORDER BY tab.cid) as ge2, tab.cid as cid
  FROM(
    SELECT ST_ClusterKMeans(e.the_geom, 10) OVER() AS cid, e.the_geom as ge
       FROM chp03.earthquakes as e) as tab
)as tab2
);
---
SELECT * FROM chp04.earthq_cent;
---
INSERT INTO chp04.earthq_circ (the_geom, cid) (
SELECT DISTINCT ST_SetSRID(
ST_MinimumBoundingCircle(tab2.ge2), 4326) as circle, tab2.cid
FROM(
      SELECT ST_UNION(tab.ge) 
OVER (partition by tab.cid ORDER BY tab.cid) as ge2, tab.cid as cid
      FROM(
        SELECT ST_ClusterKMeans(e.the_geom, 10) OVER() as cid, e.the_geom as ge
        FROM chp03.earthquakes AS e
      ) as tab
)as tab2
);

