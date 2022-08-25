-- Here is the necessary quiz to pull the first month/year combo from the orders table.
SELECT DATE_TRUNC('month', MIN(occurred_at))
FROM orders;
-- Then to pull the average for each, we could do this all in one query, but for readability, I provided two queries below to perform each separately.
SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gls, AVG(poster_qty) avg_pst
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
     (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);

SELECT SUM(total_amt_usd)
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
      (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);


      -- What is the top channel used by each account to market products?
      -- How often was that same channel used?
      -- However, we will need to do two aggregations and two subqueries to make this happen.
      --
      -- Let's find the number of times each channel is used by each account.
      --
      -- So we will need to count the number of rows by Account and Channel. This count will be our first aggregation needed.

      SELECT accounts.name, web_events.channel, Count(*)
      FROM accounts
      JOIN web_events
      ON accounts.id = web_events.account_id
      GROUP BY 1, 2
      ORDER BY 1,3

--       Ok, now we have how often each channel was used by each account. How do we only return the most used account (or accounts if multiple are tied for the most)?
-- We need to see which usage of the channel in our first query is equal to the maximum usage channel for that account. So, a keyword should jump out to you - maximum. This will be our second aggregation and it utilizes the data from the first table we returned so this will be our subquery. Let's take the maximum count from each account to create a table with the maximum usage channel amount per account.

SELECT T1.name, Max(T1.count)
FROM (
       SELECT accounts.name as name, web_events.channel as channel, Count(*) as count
       FROM accounts
       JOIN web_events ON accounts.id = Web_events.account_id
       GROUP BY 1, 2
       ORDER BY 1,3
) as T1
GROUP BY 1

-- So now we have the MAX usage number for a channel for each account. Now we can use this to filter the original table to find channels for each account that match the MAX amount for their account.
--
-- We do this by putting this in the WHERE clause

-- Query 1
SELECT a.id, a.name, we.channel
FROM accounts a
JOIN web_events we
ON a.id = we.account_id;

-- Query 2
SELECT a.id, a.name, we.channel, COUNT(*) ct
FROM accounts a
JOIN web_events we
ON a.id = we.account_id
GROUP BY a.id, a.name, we.channel;

-- Query 3
SELECT a.id, a.name, we.channel, COUNT(*) ct
FROM accounts a
JOIN web_events we
ON a.id = we.account_id
GROUP BY a.id, a.name, we.channel
ORDER BY a.id;

-- Query 4
SELECT t1.id, t1.name, MAX(ct)
FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
     FROM accounts a
     JOIN web_events we
     On a.id = we.account_id
     GROUP BY a.id, a.name, we.channel) T1
GROUP BY t1.id, t1.name

-- Query 5
SELECT t3.id, t3.name, t3.channel, t3.ct
FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
     FROM accounts a
     JOIN web_events we
     On a.id = we.account_id
     GROUP BY a.id, a.name, we.channel) T3
JOIN (SELECT t1.id, t1.name, MAX(ct) max_chan
      FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
            FROM accounts a
            JOIN web_events we
            ON a.id = we.account_id
            GROUP BY a.id, a.name, we.channel) t1
      GROUP BY t1.id, t1.name) t2
ON t2.id = t3.id AND t2.max_chan = t3.ct
ORDER BY t3.id;



-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

-- First, I wanted to find the total_amt_usd totals associated with each sales rep, and I also wanted the region in which they were located. The query below provided this information.

SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY 1,2
ORDER BY 3 DESC;
-- Next, I pulled the max for each region, and then we can use this to pull those rows in our final result.

SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1;
-- Essentially, this is a JOIN of these two tables, where the region and amount match.

SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;

-- For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?

-- The first query I wrote was to pull the total_amt_usd for each region.

SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name;
-- Then we just want the region with the max amount from this table. There are two ways I considered getting this amount. One was to pull the max using a subquery. Another way is to order descending and just pull the top value.

SELECT MAX(total_amt)
FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY r.name) sub;
-- Finally, we want to pull the total orders for the region with this amount:

SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);
-- This provides the Northeast with 2357 orders.

-- How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?
-- First, we want to find the account that had the most standard_qty paper. The query here pulls that account, as well as the total amount:

SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
-- Now, I want to use this to pull all the accounts with more total sales:

SELECT a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) sub);
-- This is now a list of all the accounts with more total orders. We can get the count with just another simple subquery.

SELECT COUNT(*)
FROM (SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT total
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)
             ) counter_tab;
-- For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

-- Here, we first want to pull the customer with the most spent in lifetime value.

SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 1;
-- Now, we want to look at the number of events on each channel this company had, which we can match with just the id.

SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;
-- I added an ORDER BY for no real reason, and the account name to assure I was only pulling from one account.

-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
-- First, we just want to find the top 10 accounts in terms of highest total_amt_usd.

SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 10;
Now, we just want the average of these 10 amounts.

SELECT AVG(tot_spent)
FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
       LIMIT 10) temp;
-- What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders?

-- First, we want to pull the average of all accounts in terms of total_amt_usd:

SELECT AVG(o.total_amt_usd) avg_all
FROM orders o
-- Then, we want to only pull the accounts with more than this average amount.

SELECT o.account_id, AVG(o.total_amt_usd)
FROM orders o
GROUP BY 1
HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                               FROM orders o);
-- Finally, we just want the average of these values.

SELECT AVG(avg_amt)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o)) temp_table;
