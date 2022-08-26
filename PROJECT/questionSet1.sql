/* Question 1: Which countries have the most Invoices?
Use the Invoice table to determine the countries that have the most invoices. Provide a table of BillingCountry and Invoices ordered by the number of invoices for each country. The country with the most invoices should appear first.

Check Your Solution
 Your solution should have 2 columns and 24 rows. The below image shows a header of your ending table. The Invoices columns in a count of the number of invoices for each country. It should be sorted from most to least. */ 

SELECT billingcountry, COUNT(*) as number_invoices from Invoice
GROUP BY 1
ORDER BY 2 DESC;

/* Question 2: Which city has the best customers?
We want to throw a promotional Music Festival in the city we made the most money. Write a query that returns the 1 city that has the highest sum of invoice totals. Return both the city name and the sum of all invoice totals. */

SELECT BillingCity, SUM(Total) as Totals
FROM Invoice
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

/* Check Your Solution
The top city for Invoice dollars was Prague, with an amount of 90.24.

Question 3: Who is the best customer?
The customer who has spent the most money will be declared the best customer. Build a query that returns the person who has spent the most money. I found the solution by linking the following three: Invoice, InvoiceLine, and Customer tables to retrieve this information, but you can probably do it with fewer! */

SELECT  c.CustomerId, c.FirstName, c.LastName, SUM(i.Total) as TotalSpent
FROM Customer c, Invoice i
WHERE c.CustomerId = i.CustomerId
GROUP BY 1
ORDER BY TotalSpent DESC
LIMIT 1;