--Chapter 10
--Recipe 6

--Step 1.
SELECT
  di.school,
  police_address,
  distance
FROM ( -- for each school, get the minimum distance to a 
       -- police station
  SELECT
    gid,
    school,
    min(distance) AS distance
  FROM ( -- get distance between every school and every police 
         -- station in San Francisco
    SELECT
      sc.gid,
      sc.name AS school,
      po.address AS police_address,
      ST_Distance(po.geom_3310, sc.geom_3310) AS distance
    FROM ( -- get schools in San Francisco
      SELECT
        ca.gid,
        ca.name,
        ST_Transform(ca.geom, 3310) AS geom_3310
      FROM sfpoly sf
      JOIN caschools ca
        ON ST_Intersects(sf.geom, ST_Transform(ca.geom, 3310))
    ) sc
    CROSS JOIN ( -- get police stations in San Francisco
      SELECT
        ca.address,
        ST_Transform(ca.geom, 3310) AS geom_3310
      FROM sfpoly sf
      JOIN capolice ca
        ON ST_Intersects(sf.geom, ST_Transform(ca.geom, 3310))
    ) po
      ORDER BY 1, 2, 4
  ) scpo
  GROUP BY 1, 2
  ORDER BY 2
) di
JOIN ( -- for each school, collect the police station      
       -- addresses ordered by distance
  SELECT
    gid,
    school,
    (array_agg(police_address))[1] AS police_address
  FROM ( -- get distance between every school and every police station in San Francisco
    SELECT
      sc.gid,
      sc.name AS school,
      po.address AS police_address,
      ST_Distance(po.geom_3310, sc.geom_3310) AS distance
    FROM ( -- get schools in San Francisco
      SELECT
        ca.gid,
        ca.name,
        ST_Transform(ca.geom, 3310) AS geom_3310
      FROM sfpoly sf
      JOIN caschools ca
        ON ST_Intersects(sf.geom, ST_Transform(ca.geom, 3310))
    ) sc
    CROSS JOIN ( -- get police stations in San Francisco
      SELECT
        ca.address,
        ST_Transform(ca.geom, 3310) AS geom_3310
      FROM sfpoly sf
      JOIN capolice ca
        ON ST_Intersects(sf.geom, ST_Transform(ca.geom, 3310))
    ) po
    ORDER BY 1, 2, 4
  ) scpo
  GROUP BY 1, 2
   ORDER BY 2
) po
  ON di.gid = po.gid
ORDER BY di.school;


--Step 4.
WITH scpo AS ( -- get distance between every school and every 
               -- police station in San Francisco
  SELECT
    sc.gid,
    sc.name AS school,
    po.address AS police_address,
    ST_Distance(po.geom_3310, sc.geom_3310) AS distance
  FROM ( -- get schools in San Francisco
    SELECT
      ca.*,
      ST_Transform(ca.geom, 3310) AS geom_3310
    FROM sfpoly sf
    JOIN caschools ca
      ON ST_Intersects(sf.geom, ST_Transform(ca.geom, 3310))
  ) sc
  CROSS JOIN ( -- get police stations in San Francisco
    SELECT
      ca.*,
      ST_Transform(ca.geom, 3310) AS geom_3310
    FROM sfpoly sf
    JOIN capolice ca
      ON ST_Intersects(sf.geom, ST_Transform(ca.geom, 3310))
  ) po
  ORDER BY 1, 2, 4
)

SELECT
  di.school,
  police_address,
  distance
FROM ( -- for each school, get the minimum distance to a                      
       -- police station
  SELECT
    gid,
    school,
    min(distance) AS distance
  FROM scpo
  GROUP BY 1, 2
  ORDER BY 2
) di
JOIN ( -- for each school, collect the police station 
       -- addresses ordered by distance
  SELECT
    gid,
    school,
    (array_agg(police_address))[1] AS police_address
  FROM scpo
  GROUP BY 1, 2
  ORDER BY 2
) po
      ON di.gid = po.gid
ORDER BY 1;


--Step 6.
WITH scpo AS ( -- get distance between every school and every
               -- police station in San Francisco
  SELECT
    sc.name AS school,
    po.address AS police_address,
    ST_Distance(po.geom_3310, sc.geom_3310) AS distance
  FROM ( -- get schools in San Francisco
    SELECT
      ca.name,
      ST_Transform(ca.geom, 3310) AS geom_3310
    FROM sfpoly sf
    JOIN caschools ca
      ON ST_Intersects(sf.geom, ST_Transform(ca.geom, 3310))
  ) sc
  CROSS JOIN ( -- get police stations in San Francisco
    SELECT
      ca.address,
      ST_Transform(ca.geom, 3310) AS geom_3310
    FROM sfpoly sf
    JOIN capolice ca
      ON ST_Intersects(sf.geom, ST_Transform(ca.geom, 3310))
  ) po
  ORDER BY 1, 3, 2
)
SELECT
  DISTINCT school,
  first_value(police_address) OVER (PARTITION BY school ORDER
    BY distance),
  first_value(distance) OVER (PARTITION BY school ORDER BY
    distance)
FROM scpo
ORDER BY 1;


--Step 12.
WITH sc AS ( -- get schools in San Francisco
  SELECT
    ca.gid,
    ca.name,
    ca.geom
  FROM sfpoly sf
  JOIN caschools ca
    ON ST_Intersects(sf.geom, ST_Transform(ca.geom, 3310))
), po AS ( -- get police stations in San Francisco
  SELECT
    ca.gid,
    ca.address,
    ca.geom
  FROM sfpoly sf
  JOIN capolice ca
    ON ST_Intersects(sf.geom, ST_Transform(ca.geom, 3310))
)
SELECT
  school,
  police_address,
  ST_Distance(ST_Transform(school_geom, 3310), ST_Transform(police_geom, 3310)) AS distance
FROM ( -- for each school, number and order the police
       -- stations by how close each station is to the school
  SELECT
    ROW_NUMBER() OVER (PARTITION BY sc.gid ORDER BY sc.geom <-> po.geom) AS r,
      sc.name AS school,
      sc.geom AS school_geom,
      po.address AS police_address,
      po.geom AS police_geom
  FROM sc
  CROSS JOIN po
) scpo
WHERE r < 2
ORDER BY 1;