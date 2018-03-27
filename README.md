# PostGIS Cookbook - Second Edition
This is the code repository for [PostGIS Cookbook - Second Edition](https://www.packtpub.com/application-development/postgis-cookbook-second-edition?utm_source=github&utm_medium=repository&utm_campaign=9781788299329), published by [Packt](https://www.packtpub.com/?utm_source=github). It contains all the supporting project files necessary to work through the book from start to finish.
## About the Book
PostGIS is a spatial database that integrates the advanced storage and analysis of vector and raster data, and is remarkably flexible and powerful. PostGIS provides support for geographic objects to the PostgreSQL object-relational database and is currently the most popular open source spatial databases.

If you want to explore the complete range of PostGIS techniques and expose related extensions, then this book is for you.

This book is a comprehensive guide to PostGIS tools and concepts which are required to manage, manipulate, and analyze spatial data in PostGIS. It covers key spatial data manipulation tasks, explaining not only how each task is performed, but also why. It provides practical guidance allowing you to safely take advantage of the advanced technology in PostGIS in order to simplify your spatial database administration tasks. Furthermore, you will learn to take advantage of basic and advanced vector, raster, and routing approaches along with the concepts of data maintenance, optimization, and performance, and will help you to integrate these into a large ecosystem of desktop and web tools.

By the end, you will be armed with all the tools and instructions you need to both manage the spatial database system and make better decisions as your project's requirements evolve.
## Instructions and Navigation
All of the code is organized into folders. Each folder starts with a number followed by the application name. For example, Chapter02.



The code will look like the following:
```
SELECT ROUND(SUM(chp02.proportional_sum (ST_Transform(a.geom,3734), b.geom,b.pop))) AS population
  FROM nc_walkzone AS a, census_viewpolygon as b
  WHERE ST_Intersects(ST_Transform(a.geom, 3734), b.geom)
  GROUP BY a.id;
```

Before going further into this book, you will want to install latest versions of PostgreSQL and PostGIS (9.6 or 103 and 2.3 or 2.41, respectively). You may also want to install pgAdmin (1.18) if you prefer a graphical SQL tool. For most computing environments (Windows, Linux, macOS X), installers and packages include all required dependencies of PostGIS. The minimum required dependencies for PostGIS are PROJ.4, GEOS, libjson and GDAL.A basic understanding of the SQL language is required to understand and adapt the code found in this book's recipes.

## Related Products
* [Learning PostgreSQL 10 - Second Edition](https://www.packtpub.com/big-data-and-business-intelligence/learning-postgresql-10-second-edition?utm_source=github&utm_medium=repository&utm_campaign=9781788392013)

* [Learning PostgreSQL 10 - Second Edition](https://www.packtpub.com/big-data-and-business-intelligence/learning-postgresql-10-second-edition?utm_source=github&utm_medium=repository&utm_campaign=9781788392013)

* [Spring Boot 2.0 Cookbook - Second Edition](https://www.packtpub.com/application-development/spring-boot-cookbook-second-edition?utm_source=github&utm_medium=repository&utm_campaign=9781787129825)

### Suggestions and Feedback
[Click here](https://docs.google.com/forms/d/e/1FAIpQLSe5qwunkGf6PUvzPirPDtuy1Du5Rlzew23UBp2S-P3wB-GcwQ/viewform) if you have any feedback or suggestions.
