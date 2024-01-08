Q1. whpo is senior most employee from job title?

select * from employee
order by levels desc
limit 1

Q1. which contries have most invoices?

select billing_country, count(*) as c from invoice
group by billing_country
order by c desc

Q3. top 3 invoices values?

select total from invoice
order by total desc
limit 3

Q4. city with highest sum of invoice total and return bith city and sum of invoice total?

select billing_city, sum(total) as s from invoice
group by billing_city
order by s desc

Q5. person who has spent the most money?

select customer.first_name, customer.last_name, sum(invoice.total) as s from customer 
inner join invoice on invoice.customer_id = customer.customer_id
group by customer.customer_id
order by s desc
limit 1

select * from invoice
select * from customer

Q6. return email, first name, last name of all rock music listener and order alphabatically by email starting with A?

select distinct email, first_name, last_name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in (
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock' 
)
order by email

Q7. artist who have written most no of rock music, return artist name and total no of count of top 10 rock bands

select artist.name, count(artist.artist_id) as number_of_songs from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
where track_id in (
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock' 
)
group by artist.artist_id
order by number_of_songs desc
limit 10

Q8. return all track names that have song length greater than average song length, return name and millisecond and order by song lenth in desc order?

select * from track

select name, milliseconds from track
where milliseconds > (
	SELECT avg(milliseconds) as avrage_length from track)
order by milliseconds desc

--Q9. find total amount spent by each customer on artist?
-- Write query to return customer name, artist name and total spent?


with best_selling_artist as 	(
	select artist.artist_id as artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price * invoice_line.quantity) as total_amount 
	from invoice_line
	join track on invoice_line.track_id = track.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price * il.quantity) from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on t.track_id = il.track_id
join album a on a.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = a.artist_id
group by 1,2,3,4
order by 5 desc

--Q10. Calculate most popular genre of each country 
--(most popular genre is highest no of purchases)

with popular_genre as(
	select customer.country, genre.genre_id, genre.name,count(invoice_line.quantity),
	ROW_NUMBER() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
	from customer
	join invoice on customer.customer_id = invoice.customer_id
	join invoice_line on invoice.invoice_id = invoice_line.invoice_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 1,2,3
	order by 1 asc,4 desc
)
select * from popular_genre where RowNo = 1





WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;

--Q10. write query that has determine the customer that has spent maximum on music for each country.
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount. 

with recursive
	customer_with_countries as(
	select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spent
	from invoice
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc),
	
	country_max_spending as(
	select billing_country, max(total_spent) as maximum_spending
	from customer_with_countries 
	group by billing_country)
	
select cc.customer_id, cc.first_name, cc.last_name, cc.billing_country, cc.total_spent
from customer_with_countries cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spent = ms.maximum_spending

--using rowno--

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1