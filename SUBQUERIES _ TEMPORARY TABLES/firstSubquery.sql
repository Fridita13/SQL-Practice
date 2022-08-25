-- We would like to know which channels send the most traffic per day on average to Parch and Posey. In order to do that, we'll need to aggregate events by channel by day, then we need to take those and average them.

-- Build the Subquery: The aggregation of an existing table that you’d like to leverage as a part of the larger query.
-- Run the Subquery: Because a subquery can stand independently, it’s important to run its content first to get a sense of whether this aggregation is the interim output you are expecting.
-- Encapsulate and Name: Close this subquery off with parentheses and call it something. In this case, we called the subquery table ‘sub.’
-- Test Again: Run a SELECT * within the larger query to determine if all syntax of the subquery is good to go.
-- Build Outer Query: Develop the SELECT * clause as you see fit to solve the problem at hand, leveraging the subquery appropriately.

SELECT channel,
       AVG(event_count) AS avg_event_count
FROM
(SELECT DATE_TRUNC('day',occurred_at) AS day,
        channel,
        count(*) as event_count
   FROM web_events
   GROUP BY 1,2
   ) sub
   GROUP BY 1
   ORDER BY 2 DESC

--    Solutions to Your First Subquery
-- First, we needed to group by the day and channel. Then ordering by the number of events (the third column) gave us a quick way to answer the first question.

SELECT DATE_TRUNC('day',occurred_at) AS day,
       channel, COUNT(*) as events
FROM web_events
GROUP BY 1,2
ORDER BY 3 DESC;
-- Here you can see that to get the entire table in question 1 back, we included an * in our SELECT statement. You will need to be sure to alias your table.

SELECT *
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
                channel, COUNT(*) as events
          FROM web_events
          GROUP BY 1,2
          ORDER BY 3 DESC) sub;
-- Finally, here we are able to get a table that shows the average number of events a day for each channel.

SELECT channel, AVG(events) AS average_events
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
                channel, COUNT(*) as events
         FROM web_events
         GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;
