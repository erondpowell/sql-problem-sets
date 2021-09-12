



-- ADV. SQL TUTORIAL - PIVOTING DATA - NOTES
-- FOUND ON: https://mode.com/sql-tutorial/sql-pivot-table/

-- In this document I will go through the queries written
-- and explain what the code is doing line-by-line.
-- Queries will be written modularly for ease of testing.


---------------PIVOTING ROWS TO COLUMNS------------------------------------
-- the 'year' column indicates if each student is FR, SO, JR, SR
-- We will make each of these a column and count num of students.

SELECT teams.conference AS conference,
       players.year,
       COUNT(1) AS players
  FROM benn.college_football_players players
  JOIN benn.college_football_teams teams
    ON teams.school_name = players.school_name
 GROUP BY 1,2
 ORDER BY 1,2


--  Now let's that put in a subquery
--  Remove the order by clause and put it outside the query later on

SELECT *
  FROM (
        SELECT teams.conference AS conference,
               players.year,
               COUNT(1) AS players
          FROM benn.college_football_players players
          JOIN benn.college_football_teams teams
            ON teams.school_name = players.school_name
         GROUP BY 1,2
       ) sub


--  Columns are created for fr, so, jr, sr
--  To create accurate counts of players within each fr, so, jr, sr column,
--  the case clause extracts the number of players from players column when
--  year column value matches up to a fr, so, jr, sr column.
--  Otherwise it returns null.

SELECT conference,
       SUM(CASE WHEN year = 'FR' THEN players ELSE NULL END) AS fr,
       SUM(CASE WHEN year = 'SO' THEN players ELSE NULL END) AS so,
       SUM(CASE WHEN year = 'JR' THEN players ELSE NULL END) AS jr,
       SUM(CASE WHEN year = 'SR' THEN players ELSE NULL END) AS sr
  FROM (
        SELECT teams.conference AS conference,
               players.year,
               COUNT(1) AS players
          FROM benn.college_football_players players
          JOIN benn.college_football_teams teams
            ON teams.school_name = players.school_name
         GROUP BY 1,2
       ) sub
 GROUP BY 1
 ORDER BY 1

-- Let's add a total_players column to see how many players are in each conference
-- Then ORDER BY total_players from greatest to least

 SELECT conference,
       SUM(players) AS total_players,
       SUM(CASE WHEN year = 'FR' THEN players ELSE NULL END) AS fr,
       SUM(CASE WHEN year = 'SO' THEN players ELSE NULL END) AS so,
       SUM(CASE WHEN year = 'JR' THEN players ELSE NULL END) AS jr,
       SUM(CASE WHEN year = 'SR' THEN players ELSE NULL END) AS sr
  FROM (
        SELECT teams.conference AS conference,
               players.year,
               COUNT(1) AS players
          FROM benn.college_football_players players
          JOIN benn.college_football_teams teams
            ON teams.school_name = players.school_name
         GROUP BY 1,2
       ) sub
 GROUP BY 1
 ORDER BY 2 DESC


---------------PIVOTING COLUMNS TO ROWS------------------------------------
-- Let's look at some earthquake data. This data is presented for consumption,
-- not analysis. Let's remix it for better analysis.

SELECT *
  FROM tutorial.worldwide_earthquakes

-- I was not familiar with the v(year) syntax but this seems to create a new
-- table, with a column named year, and 13 rows with the values 2000, 2001, etc..

SELECT year
FROM (VALUES (2000),(2001),(2002),(2003),(2004),(2005),(2006),
              (2007),(2008),(2009),(2010),(2011),(2012)) v(year)

-- Next, let's cross join years onto earthquakes.
-- This will give us all the rows from earthquakes, and repeat them 13 times
-- due to cross join.

SELECT years.*,
       earthquakes.*
  FROM tutorial.worldwide_earthquakes earthquakes
 CROSS JOIN (
       SELECT year
         FROM (VALUES (2000),(2001),(2002),(2003),(2004),(2005),(2006),
                      (2007),(2008),(2009),(2010),(2011),(2012)) v(year)
       ) years

-- So let's create a 3rd column called number_of_earthquakes.
-- For each row, when the value in the year column is 2000, then input the value
-- from the year_2000 column... and so on.

SELECT years.*,
       earthquakes.magnitude,
       CASE year
         WHEN 2000 THEN year_2000
         WHEN 2001 THEN year_2001
         WHEN 2002 THEN year_2002
         WHEN 2003 THEN year_2003
         WHEN 2004 THEN year_2004
         WHEN 2005 THEN year_2005
         WHEN 2006 THEN year_2006
         WHEN 2007 THEN year_2007
         WHEN 2008 THEN year_2008
         WHEN 2009 THEN year_2009
         WHEN 2010 THEN year_2010
         WHEN 2011 THEN year_2011
         WHEN 2012 THEN year_2012
         ELSE NULL END
         AS number_of_earthquakes
  FROM tutorial.worldwide_earthquakes earthquakes
 CROSS JOIN (
       SELECT year
         FROM (VALUES (2000),(2001),(2002),(2003),(2004),(2005),(2006),
                      (2007),(2008),(2009),(2010),(2011),(2012)) v(year)
       ) years
