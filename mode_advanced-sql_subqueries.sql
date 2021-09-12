


-- ADV. SQL TUTORIAL PRACTICE PROBLEMS
-- FOUND ON: https://mode.com/sql-tutorial/sql-sub-queries/



---------------PROBLEM 1------------------------------------
-- Write a query that selects all Warrant Arrests from the
-- tutorial.sf_crime_incidents_2014_01 dataset, then wrap it
-- in an outer query that only displays unresolved incidents.

--MY SOLUTION:
SELECT main.*
FROM tutorial.sf_crime_incidents_2014_01 main
JOIN  (SELECT *
            FROM tutorial.sf_crime_incidents_2014_01
            WHERE descript = 'WARRANT ARREST') sub
ON main.id = sub.id
WHERE main.resolution = 'NONE';

-- EXAMPLE SOLUTION:
 SELECT sub.*
      FROM (
            SELECT *
              FROM tutorial.sf_crime_incidents_2014_01
             WHERE descript = 'WARRANT ARREST'
           ) sub
     WHERE sub.resolution = 'NONE'

-- KEY NOTES:
-- Example has superior readibility.

---------------PROBLEM 2------------------------------------
-- Write a query that displays the average number of monthly incidents
-- for each category. Hint: use tutorial.sf_crime_incidents_cleandate
-- to make your life a little easier.

-- MY SOLUTION: Couldn't solve within 30 minutes.

SELECT
      EXTRACT('month' FROM cleaned_date) AS month,
      category,
      COUNT(1) AS incidents
  FROM  tutorial.sf_crime_incidents_cleandate;
  GROUP BY 1, 2;


-- EXAMPLE SOLUTION:
SELECT sub.category,
       AVG(sub.incidents) AS avg_incidents_per_month
  FROM (
        SELECT EXTRACT('month' FROM cleaned_date) AS month,
               category,
               COUNT(1) AS incidents
          FROM tutorial.sf_crime_incidents_cleandate
         GROUP BY 1,2
       ) sub
 GROUP BY 1

-- KEY NOTES:
-- Tried returning month with substr to think about ranking by month
--    Using SUBSTR threw syntax threw errors (likely bc date col is the wrong type)
-- watch out for misplaced semi-colons!!!
--    Remix: I'm just dropping the semicolon for the next problems!
-- careful about naming subqueries then using table.col_name properly.
-- Be sure you're using GROUP BY on the right column.


---------------PROBLEM 3------------------------------------
-- Write a query that displays all rows from the
-- three categories with the fewest incidents reported.


-- MY SOLUTION: WORKS!!!
SELECT out.*
FROM tutorial.sf_crime_incidents_cleandate out
JOIN (
      SELECT category,
          COUNT(*)
    FROM tutorial.sf_crime_incidents_cleandate
    GROUP BY category
    ORDER BY 2 ASC
    LIMIT 3
    ) sub
  ON out.category = sub.category

-- EXAMPLE SOLUTION:
SELECT incidents.*,
       sub.count AS total_incidents_in_category
  FROM tutorial.sf_crime_incidents_2014_01 incidents
  JOIN (
        SELECT category,
               COUNT(*) AS count
          FROM tutorial.sf_crime_incidents_2014_01
         GROUP BY 1
         ORDER BY 2
         LIMIT 3
       ) sub
    ON sub.category = incidents.category

-- KEY NOTES:
-- watch out for misplaced semi-colons!!!
-- is it important to name the outer table sthg descriptive like incidents vs my name 'out'?
-- ***** Need to apply the the WINDOWS function and get off the noob-tier ORDER BY x LIMIT y.
-- EXAMPLE LINE 2: sub.count AS total_incidents_in_category .... Seems unnecessary?? Not defined in the problem's question.

---------------PROBLEM 4------------------------------------
-- Write a query that counts the number of companies founded and
-- acquired by quarter starting in Q1 2012. Create the aggregations
-- in two separate queries, then join them.


-- MY SOLUTION: WORKS!!!!
SELECT
      COALESCE(founded.founded_quarter, acquired.acquired_quarter) as quarter,
      founded.companies_founded,
      acquired.companies_acquired
FROM (
        SELECT COUNT(*) AS companies_founded,
              founded_quarter
        FROM tutorial.crunchbase_companies
        GROUP BY founded_quarter
        HAVING founded_quarter >= '2012-Q1'
        --ORDER BY 2
      ) founded
FULL JOIN (
        SELECT COUNT(*) AS companies_acquired,
            acquired_quarter
        FROM tutorial.crunchbase_acquisitions
        GROUP BY acquired_quarter
        HAVING  acquired_quarter >= '2012-Q1'
        --ORDER BY 2
      ) acquired
       ON founded.founded_quarter = acquired.acquired_quarter
       ORDER BY 1;

-- EXAMPLE SOLUTION:
    SELECT COALESCE(companies.quarter, acquisitions.quarter) AS quarter,
           companies.companies_founded,
           acquisitions.companies_acquired
      FROM (
            SELECT founded_quarter AS quarter,
                   COUNT(permalink) AS companies_founded
              FROM tutorial.crunchbase_companies
             WHERE founded_year >= 2012
             GROUP BY 1
           ) companies
      LEFT JOIN (
            SELECT acquired_quarter AS quarter,
                   COUNT(DISTINCT company_permalink) AS companies_acquired
              FROM tutorial.crunchbase_acquisitions
             WHERE acquired_year >= 2012
             GROUP BY 1
           ) acquisitions

        ON companies.quarter = acquisitions.quarter
     ORDER BY 1

-- KEY NOTES:
-- I peeked at the sample answer to find out where they defined companies founded.
--    I was originally using (crunchbase_investments) the wrong table.
--    It was in tutorial.crunchbase_companies
-- Example problem uses a LEFT JOIN. It could drop quarters if the 'right' table.
-- I used FULL JOIN because it guarantees all quarters >='2012-Q1' get added.
-- No need for me to use ORDER BY on the subqueries. It's not DRY coding.


---------------PROBLEM 4------------------------------------
-- Write a query that ranks investors from the combined dataset
-- above by the total number of investments they have made.

-- MY SOLUTION: WORKS!!!!
SELECT investor_name,
       COUNT(*) AS investments_made
  FROM (
        SELECT *
          FROM tutorial.crunchbase_investments_part1

        UNION ALL

        SELECT *
          FROM tutorial.crunchbase_investments_part2
        ) crunchbase_investments_union_all
  GROUP BY investor_name
  ORDER BY investments_made DESC

-- EXAMPLE SOLUTION:
SELECT investor_name,
       COUNT(*) AS investments
  FROM (
        SELECT *
          FROM tutorial.crunchbase_investments_part1

         UNION ALL

         SELECT *
           FROM tutorial.crunchbase_investments_part2
       ) sub
 GROUP BY 1
 ORDER BY 2 DESC

-- KEY NOTES:
-- I keep forgetting to use digits on the col references (GROUP BY 1)
-- I opt for longer, descriptivecolumn names than the examles seem to use.
--    ARE these big issues for pro-level styling??


---------------PROBLEM 5------------------------------------
-- Write a query that does the same thing as in the previous problem,
-- except only for companies that are still operating.
-- Hint: operating status is in tutorial.crunchbase_companies.

-- MY SOLUTION: WORKS!!! (after checking example answer)
SELECT investor_name,
      COUNT(*) AS investments_made
  FROM (
        SELECT *
          FROM tutorial.crunchbase_investments_part1

        UNION ALL

        SELECT *
          FROM tutorial.crunchbase_investments_part2
        ) crunchbase_investments_union_all
  JOIN (
        SELECT *
          FROM tutorial.crunchbase_companies
        WHERE status = 'operating'
        ) sub
    -- ON crunchbase_investments_union_all.id = sub.id
        ON runchbase_investments_union_all.company_permalink = sub.permalink
  GROUP BY investor_name
  ORDER BY investments_made DESC

-- EXAMPLE SOLUTION:
SELECT investments.investor_name,
       COUNT(investments.*) AS investments
  FROM tutorial.crunchbase_companies companies
  JOIN (
        SELECT *
          FROM tutorial.crunchbase_investments_part1

         UNION ALL

         SELECT *
           FROM tutorial.crunchbase_investments_part2
       ) investments
    ON investments.company_permalink = companies.permalink
 WHERE companies.status = 'operating'
 GROUP BY 1
 ORDER BY 2 DESC

-- KEY NOTES:
-- ERROR: Example problem made the join on permalink, mine was on 'id'.
-- Example Runtime was 5:54.
--    I either got this really wrong or really right. or weird internet.
--    I botched the ON statement. After joining on permalink....
--    My New Runtime is 3:24 sec
-- The WHERE clause on the example problem seems inefficient.
--    It could be nested as a subquery and eliminate redundant iterations.
