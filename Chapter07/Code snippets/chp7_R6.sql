--Chapter 7
--Recipe 6

--Getting Ready
COPY(WITH pts AS (SELECT PC_Explode(pa) AS pt FROM chp07.giraffe) SELECT '
  <X3D xmlns="http://www.web3d.org/specifications/x3d-namespace" 
    showStat="false" showLog="false" x="0px" y="0px" width="800px" 
    height="600px">
    <Scene>
      <Transform>
        <Shape>' ||  ST_AsX3D(ST_Union(pt::geometry))  ||
        '</Shape>
      </Transform>
    </Scene>
  </X3D>' FROM pts)
TO STDOUT WITH CSV;


--How to do it
--Step 1.
<link rel="stylesheet" type="text/css" 
  href="http://x3dom.org/x3dom/example/x3dom.css" />
<script type="text/javascript" 
  src="http://x3dom.org/x3dom/example/x3dom.js"></script>

The full query to generate the XHTML of X3D data is as follows:
COPY(WITH pts AS (SELECT PC_Explode(pa) AS pt FROM chp07.giraffe)
  SELECT regexp_replace('
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <meta http-equiv="X-UA-Compatible" content="chrome=1" />
      <meta http-equiv="Content-Type" content="text/html;charset=utf-8" 
        />
      <title>Point Cloud in a Browser</title>
      <link rel="stylesheet" type="text/css" 
          href="http://x3dom.org/x3dom/example/x3dom.css" />
      <script type="text/javascript" 
        src="http://x3dom.org/x3dom/example/x3dom.js"></script>
    </head>
    <body>
      <h1>Point Cloud in the Browser</h1>
      <p>
        Use mouse to rotate, scroll wheel to zoom, and control (or 
          command) click to pan.
      </p>
      <X3D xmlns="http://www.web3d.org/specifications/x3d-namespace" 
        showStat="false" showLog="false" x="0px" y="0px" width="800px" 
        height="600px">
        <Scene>
          <Transform>
            <Shape>' ||  ST_AsX3D(ST_Union(pt::geometry))  ||
            '</Shape>
          </Transform>
        </Scene>
      </X3D>
    </body>
  </html>', E'[\\n\\r]+','', 'g') FROM pts)
TO STDOUT;

--There's more
--Step 1.
CREATE OR REPLACE FUNCTION AsX3D_XHTML(geometry)
  RETURNS character varying AS
$BODY$

SELECT regexp_replace('
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="X-UA-Compatible" content="chrome=1" />
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" 
      />
    <title>Point Cloud in a Browser</title>
    <link rel="stylesheet" type="text/css" 
      href="http://x3dom.org/x3dom/example/x3dom.css" />
    <script type="text/javascript" 
      src="http://x3dom.org/x3dom/example/x3dom.js"></script>
  </head>
  <body>
    <h1>Point Cloud in the Browser</h1>
    <p>
      Use mouse to rotate, scroll wheel to zoom, and control (or 
        command) click to pan.
    </p>
    <X3D xmlns="http://www.web3d.org/specifications/x3d-namespace" 
      showStat="false" showLog="false" x="0px" y="0px" width="800px" 
      height="600px">
      <Scene>
        <Transform>
          <Shape>' ||  ST_AsX3D($1)  ||
          '</Shape>
        </Transform>
      </Scene>
    </X3D>
  </body>
</html>', E'[\\n\\r]+','', 'g') As x3dXHTML;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;


--Step 2.
copy(
  WITH pts AS (
    SELECT 
      PC_Explode(pa) AS pt 
    FROM giraffe
  )
  SELECT AsX3D_XHTML(ST_UNION(pt::geometry)) FROM pts) to stdout;


