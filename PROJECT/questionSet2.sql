/* Question 1
Use your query to return the email, first name, last name, and Genre of all Rock Music listeners (Rock & Roll would be considered a different category for this exercise). Return your list ordered alphabetically by email address starting with A.

I chose to link information from the Customer, Invoice, InvoiceLine, Track, and Genre tables, but you may be able to find another way to get at the information.

Check Your Solution
From my query, I found that all of the customers have a connection to Rock music (you could see this by looking at the original length of the customers table). Your final table should have 59 rows and 4 columns (if you want to check the connection to 'Rock' music). The header of this table is provided below. */

SELECT c.Email, c.FirstName, c.LastName, g.Name
FROM Customer c
JOIN Invoice i
ON c.CustomerId = i.CustomerId
JOIN InvoiceLine iL
ON i.InvoiceId = iL.InvoiceId
JOIN Track t
ON t.TrackId = iL.TrackId
JOIN Genre g
ON g.GenreId = t.GenreId 
WHERE g.Name = 'Rock'
GROUP BY c.Email;

/* Question 2: Who is writing the rock music?
Now that we know that our customers love rock music, we can decide which musicians to invite to play at the concert.

Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands.

You will need to use the Genre, Track , Album, and Artist tables.

Check Your Solution
The top 10 bands are shown below along with the number of songs each band has on record. */

SELECT a.ArtistId, a.Name, COUNT(t.Name) as Songs
FROM Artist a
JOIN Album al
ON a.ArtistId = al.ArtistId
JOIN Track t
ON al.AlbumId = t.AlbumId
JOIN Genre g
ON t.GenreId = g.GenreId
WHERE g.Name = 'Rock'
GROUP BY a.ArtistId, a.Name, g.Name
ORDER BY Songs DESC
LIMIT 10;

/* Question 3
First, find which artist has earned the most according to the InvoiceLines?

Now use this artist to find which customer spent the most on this artist.

For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, Album, and Artist tables.

Notice, this one is tricky because the Total spent in the Invoice table might not be on a single product, so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price for each artist.

Check Your Solution
The top artists according to invoice amounts are shown in the table below. The very top being Iron Maiden. */

WITH BestSellingArtist AS
(
SELECT SUM(il.UnitPrice * il.Quantity) as ArtistTotal , a.Name as Name, a.ArtistId
FROM InvoiceLine il, Track t, Album al, Artist a
WHERE il.TrackId=t.TrackId AND
al.AlbumId=t.AlbumId AND
a.ArtistId=al.ArtistId
GROUP BY a.ArtistId
ORDER BY ArtistTotal DESC
LIMIT 1
)

SELECT 	bsa.Name, bsa.ArtistTotal, c.CustomerId, c.FirstName, c.LastName,
		SUM(il.Quantity*il.UnitPrice) AS 'AmountSpent'
FROM 	Artist a 
		JOIN Album al ON a.ArtistId = al.ArtistId 
		JOIN Track t ON t.AlbumId = al.AlbumId 
		JOIN InvoiceLine il ON t.TrackId = il.Trackid 
		JOIN Invoice i ON il.InvoiceId = i.InvoiceId 
		JOIN Customer c ON c.CustomerId = i.CustomerId 
		JOIN BestSellingArtist bsa ON bsa.ArtistId = a.ArtistId
GROUP BY c.CustomerId 
ORDER BY AmountSpent DESC
