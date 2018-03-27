-- RECIPE 1 ********************************************

-- Getting ready ***************************************

SELECT COUNT(*) FROM chp04.knn_addresses;

-- How to do it ****************************************

SELECT ST_Distance(searchpoint.the_geom, addr.the_geom) AS dist, * FROM
   chp04.knn_addresses addr,
   (SELECT ST_Transform(ST_SetSRID(ST_MakePoint(-81.738624, 41.396679), 4326), 3734) AS the_geom) searchpoint
    ORDER BY ST_Distance(searchpoint.the_geom, addr.the_geom)
    LIMIT 10;

---
SELECT ST_Distance(searchpoint.the_geom, addr.the_geom) AS dist, * FROM
   chp04.knn_addresses addr,
   (SELECT ST_Transform(ST_SetSRID(ST_MakePoint(-81.738624, 41.396679), 4326), 3734) AS the_geom) searchpoint
    WHERE ST_DWithin(searchpoint.the_geom, addr.the_geom, 200)
    ORDER BY ST_Distance(searchpoint.the_geom, addr.the_geom)
    LIMIT 10;

---
SELECT ST_Distance(searchpoint.the_geom, addr.the_geom) AS dist, * FROM
  chp04.knn_addresses addr,
  (SELECT ST_Transform(ST_SetSRID(ST_MakePoint(-81.738624, 41.396679), 4326), 3734) AS the_geom) searchpoint
  ORDER BY addr.the_geom <-> searchpoint.the_geom
  LIMIT 10;
