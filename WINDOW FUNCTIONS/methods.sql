-- Select the id, account_id, and total variable from the orders table, then create a column called total_rank that ranks this total amount of paper ordered (from highest to lowest) for each account using a partition. Your final table should have these four columns.

SELECT id,
       account_id,
       total,
       RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders

-- Now, create and use an alias to shorten the following query (which is different from the one in the Aggregates in Windows Functions video) that has multiple window functions. Name the alias account_year_window, which is more descriptive than main_window in the example above.

SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER account_year_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS
       (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at));


--        LAG function
-- Purpose
--
-- It returns the value from a previous row to the current row in the table.
--
-- Step 1:
--
-- Let’s first look at the inner query and see what this creates.

SELECT     account_id, SUM(standard_qty) AS standard_sum
FROM       orders
GROUP BY   1
-- What you see after running this SQL code:
--
-- The query sums the standard_qty amounts for each account_id to give the standard paper each account has purchased overall time. E.g., account_id 2951 has purchased 8181 units of standard paper.
-- Notice that the results are not ordered by account_id or standard_qty.

-- Step 2:
--
-- We start building the outer query, and name the inner query as sub.

SELECT account_id, standard_sum
FROM   (
        SELECT   account_id, SUM(standard_qty) AS standard_sum
        FROM     orders
        GROUP BY 1
       ) sub

-- Step 3 (Part A):
-- We add the Window Function OVER (ORDER BY standard_sum) in the outer query that will create a result set in ascending order based on the standard_sum column.

SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag
FROM   (
        SELECT   account_id, SUM(standard_qty) AS standard_sum
        FROM     orders
        GROUP BY 1
       ) sub
-- This ordered column will set us up for the other part of the Window Function (see below).
--
-- Step 3 (Part B):

-- The LAG function creates a new column called lag as part of the outer query: LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag. This new column named lag uses the values from the ordered standard_sum (Part A within Step 3).

SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag
FROM   (
        SELECT   account_id,
                 SUM(standard_qty) AS standard_sum
        FROM     orders
        GROUP BY 1
       ) sub
-- Each row’s value in lag is pulled from the previous row. E.g., for account_id 1901, the value in lag will come from the previous row. However, since there is no previous row to pull from, the value in lag for account_id 1901 will be NULL. For account_id 3371, the value in lag will be pulled from the previous row (i.e., account_id 1901), which will be 0. This goes on for each row in the table.
--


-- Step 4:
-- To compare the values between the rows, we need to use both columns (standard_sum and lag). We add a new column named lag_difference, which subtracts the lag value from the value in standard_sum for each row in the table:
-- standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference

SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference
FROM (
       SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders
       GROUP BY 1
      ) sub
-- Each value in lag_difference is comparing the row values between the 2 columns (standard_sum and lag). E.g., since the value for lag in the case of account_id 1901 is NULL, the value in lag_difference for account_id 1901 will be NULL. However, for account_id 3371, the value in lag_difference will compare the value 79 (standard_sum for account_id 3371) with 0 (lag for account_id 3371) resulting in 79. This goes on for each row in the table.

--
-- Code from the Video
--
-- Query1

SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER(ORDER BY standard_sum) AS lag,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead
FROM (
       SELECT account_id,
              SUM(standard_qty) AS standard_sum
       FROM orders
       GROUP BY 1
) sub
-- Query2

SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER(ORDER BY standard_sum) AS lag,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
       SELECT account_id,
              SUM(standard_qty) AS standard_sum
       FROM orders
       GROUP BY 1
) sub

-- LAG and LEAD
-- Use Case
-- When you need to compare the values in adjacent rows or rows that are offset by a certain number, LAG and LEAD come in very handy.

-- Scenarios for using LAG and LEAD functions
-- You can use LAG and LEAD functions whenever you are trying to compare the values in adjacent rows or rows that are offset by a certain number.
--
-- Example 1: You have a sales dataset with the following data and need to compare how the market segments fare against each other on profits earned.

-- Market Segment	Profits earned by each market segment
-- A	               $550
-- B	               $500
-- C	               $670
-- D              	 $730
-- E	               $982
-- Example 2: You have an inventory dataset with the following data and need to compare the number of days elapsed between each subsequent order placed for Item A.
--
-- Inventory	        Order_id	   Dates when orders were placed
-- Item A	            001	         11/2/2017
-- Item A	            002	         11/5/2017
-- Item A	            003	         11/8/2017
-- Item A	            004	         11/15/2017
-- Item A	            005	         11/28/2017
-- As you can see, these are useful data analysis tools that you can use for more complex analysis!

--  Imagine you're an analyst at Parch & Posey and you want to determine how the current order's total revenue ("total" meaning from sales of all types of paper) compares to the next order's total revenue.
SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM (
SELECT occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders
 GROUP BY 1
) sub

-- Percentiles with Partitions
-- You can use partitions with percentiles to determine the percentile of a specific subset of all rows. Imagine you're an analyst at Parch & Posey and you want to determine the largest orders (in terms of quantity) a specific customer has made to encourage them to order more similarly sized large orders. You only want to consider the NTILE for that customer's account_id.
--
-- In the SQL Explorer below, write three queries (separately) that reflect each of the following:
--
-- Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders. Your resulting table should have the account_id, the occurred_at time for each order, the total amount of standard_qty paper purchased, and one of four levels in a standard_quartile column.

SELECT
       account_id,
       occurred_at,
       standard_qty,
       NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
  FROM orders
 ORDER BY account_id DESC
-- Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders. Your resulting table should have the account_id, the occurred_at time for each order, the total amount of gloss_qty paper purchased, and one of two levels in a gloss_half column.

SELECT
       account_id,
       occurred_at,
       gloss_qty,
       NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
  FROM orders
 ORDER BY account_id DESC
-- Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders. Your resulting table should have the account_id, the occurred_at time for each order, the total amount of total_amt_usd paper purchased, and one of 100 levels in a total_percentile column.

SELECT
       account_id,
       occurred_at,
       total_amt_usd,
       NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
  FROM orders
 ORDER BY account_id DESC


