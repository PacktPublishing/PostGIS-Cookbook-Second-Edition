--Chapter 10
--Recipe 3

--Step 1.
pg_dump -f chapter10.backup -F custom chapter10

--Step 2.
pg_restore -f chapter10.sql chapter10.backup


--Step 4.
pg_restore -f chapter10_public.sql -n public chapter10.backup
