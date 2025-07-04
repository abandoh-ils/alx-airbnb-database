-- a query to find all properties where the average rating is greater than 4.0 using a subquery.

SELECT p.property_id, p.name, p.location, 
       ROUND(avg_rating, 2) AS average_rating
FROM properties p
INNER JOIN (
    SELECT property_id, AVG(rating) AS avg_rating
    FROM reviews
    GROUP BY property_id
    HAVING AVG(rating) > 4.0
) r ON p.property_id = r.property_id ORDER BY avg_rating;

-- a correlated subquery to find users who have made more than 3 bookings.

SELECT user_id, first_name, last_name, email
FROM users u
WHERE (
    SELECT COUNT(*) 
    FROM bookings b 
    WHERE b.user_id = u.user_id
) > 3 ORDER BY user_id;

