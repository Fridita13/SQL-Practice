/* Which artists have the most tracks?
List the top 10 artists with the highest number of tracks. */


/* SELECT  t.AlbumId AS 'Album Id', t.Name, t.Composer, a.Title, ar.Name AS 'Artist Name', COUNT(*) AS 'Tracks'
FROM Track t 
JOIN Album a 
ON t.AlbumId = a.AlbumId  
JOIN Artist ar 
ON ar.ArtistId = a.ArtistId
GROUP BY  t.AlbumId
ORDER BY Tracks DESC
LIMIT 10; */

/* FINAL:
SELECT ar.Name AS 'Artist Name', COUNT(*) AS 'Tracks'
FROM Track t 
JOIN Album a 
ON t.AlbumId = a.AlbumId  
JOIN Artist ar 
ON ar.ArtistId = a.ArtistId
GROUP BY  1
ORDER BY Tracks DESC
LIMIT 10; */



/* Which artists sell the most?
Provide a query that shows the top 10 best selling artists. */

/* SELECT ar.Name, CAST (SUM (il.UnitPrice) AS INT)AS 'Total Sales'
FROM Artist ar, InvoiceLine il, Track t, Album a
WHERE il.TrackId = t.TrackId
AND t.AlbumId = a.AlbumId
AND a.ArtistId = ar.ArtistId
GROUP BY ar.Name
ORDER BY 2 DESC
LIMIT 10; */

SELECT ar.Name, CAST (SUM (il.UnitPrice) AS INT)AS 'Total Sales'
FROM Artist ar
JOIN Album a
ON a.ArtistId = ar.ArtistId
JOIN Track t
ON t.AlbumId = a.AlbumId
JOIN InvoiceLine il
WHERE il.TrackId = t.TrackId
GROUP BY ar.Name
ORDER BY 2 DESC
LIMIT 10;

/* How are the Total Sales divided by Country? Provide a query that shows the total sales per country. 22. AGREGAR PORCENTAJE  me rindo así que va en grafico*/

/* SELECT i.BillingCountry AS 'Billing Country', CAST (SUM(i.Total) AS INT) as 'Total Sales'
FROM Invoice i 
GROUP BY i.BillingCountry 
ORDER BY 2 DESC;  */

/* Provide a query that shows total sales made by each sales agent.  */
SELECT e.FirstName AS 'First Name', e.LastName AS 'Last Name', CAST (SUM(i.Total) AS INT) AS 'Total Sales'
FROM Employee e
JOIN Customer c
ON e.EmployeeId = c.SupportRepId
JOIN Invoice i 
ON c.CustomerId = i.CustomerId 
GROUP BY 1, 2;



/* what's the most popular genre for each country? */



WITH t1 AS(
SELECT g.GenreId AS genre_Id,
g.Name AS Name , 
c.Country  AS 'country_name' ,
COUNT(inv.InvoiceId) AS invoicescount
FROM Genre g
JOIN Track t
ON g.GenreId = t.GenreId
JOIN InvoiceLine invline
ON t.TrackId = invline.TrackId 
JOIN Invoice Inv
ON inv.InvoiceId = invline.InvoiceId
JOIN Customer c
ON c.CustomerId = inv.CustomerId
GROUP BY 1 ,2 ,3
ORDER BY 2),
t2 AS (SELECT 
country_name, MAX(invoicescount) AS MaxInvoicesCount
FROM t1
GROUP BY 1)
SELECT t1.invoicescount AS Purchases, t1.country_name AS Country, t1.name AS Name 
FROM t1
JOIN t2
ON t1.country_name = t2.country_name AND t1.invoicescount = t2.maxinvoicescount
ORDER BY 1 DESC;