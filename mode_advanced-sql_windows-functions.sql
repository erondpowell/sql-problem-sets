-- ADV. SQL -- WINDOWS FUNCTIONS -- TUTORIAL PRACTICE PROBLEMS
-- FOUND ON: https://mode.com/sql-tutorial/sql-window-functions/



---------------PROBLEM 1------------------------------------
-- Write a query modification of the above example query that
-- shows the duration of each ride as a percentage of the total
-- time accrued by riders from each start_terminal


--MY SOLUTION: WORKS!!! BUT...
SELECT start_terminal,
       duration_seconds,
       (duration_seconds / SUM(duration_seconds) OVER (PARTITION BY start_terminal))
         AS duration_percentage
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'


-- EXAMPLE SOLUTION:
SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER (PARTITION BY start_terminal) AS start_terminal_sum,
       (duration_seconds/SUM(duration_seconds) OVER (PARTITION BY start_terminal))*100 AS pct_of_total_time
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY 1, 4 DESC

-- KEY NOTES:
-- deleted my initial SUM(duration_seconds) column. not necessary.
-- I left my answer as a decimal. They want a percantage.. Needs a x100
-- Column name is not as clear as example's


---------------PROBLEM 2------------------------------------
-- Write a query that shows a running total of the duration of bike rides
-- (similar to the last example), but grouped by end_terminal,
-- and with ride duration sorted in descending order.


--MY SOLUTION: WRONG!!!
SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         --(PARTITION BY end_terminal ORDER BY start_time DESC)
         (PARTITION BY end_terminal ORDER BY duration_seconds DESC)
         AS running_total_by_end_terminal
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'


-- EXAMPLE SOLUTION:
SELECT end_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY end_terminal ORDER BY duration_seconds DESC)
         AS running_total
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'

-- KEY NOTES:
-- Misunderstood the initial question. Ordered by start_time, not duration_seconds.
--    Make a criteria checklist to ensure the query matches it.


---------------PROBLEM 3------------------------------------



--MY SOLUTION: COULD NOT SOLVE
SELECT
  start_terminal,   -- sanity check
  start_time,       -- sanity check
  duration_seconds, -- sanity check
  RANK() OVER (PARTITION BY start_terminal ORDER BY duration_seconds DESC)
FROM tutorial.dc_bikeshare_q1_2012
WHERE start_time < '2012-01-08'

-- EXAMPLE SOLUTION:
SELECT *
  FROM (
        SELECT start_terminal,
               start_time,
               duration_seconds AS trip_time,
               RANK() OVER (PARTITION BY start_terminal ORDER BY duration_seconds DESC) AS rank
          FROM tutorial.dc_bikeshare_q1_2012
         WHERE start_time < '2012-01-08'
               ) sub
 WHERE sub.rank <= 5

-- KEY NOTES:
-- I kept trying to place a LIMIT clause in the query.... smdh
-- I really enjoyed seeing this answer. I had never imagined it before.


---------------PROBLEM 4------------------------------------
-- Write a query that shows only the duration of the trip
-- and the percentile into which that duration falls
-- (across the entire dataset—not partitioned by terminal).


-- MY SOLUTION:
SELECT
  duration,
  duration_seconds,
  NTILE(100) OVER (ORDER BY duration_seconds) AS percentile
FROM tutorial.dc_bikeshare_q1_2012

-- EXAMPLE SOLUTION:
SELECT duration_seconds,
       NTILE(100) OVER (ORDER BY duration_seconds)
         AS percentile
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY 1 DESC

-- KEY NOTES:
-- The example answer's WHERE and ORDER BY clauses were not accounted for
--    in the original query description.
