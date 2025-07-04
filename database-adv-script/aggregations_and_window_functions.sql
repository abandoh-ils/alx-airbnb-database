-- a query to find the total number of bookings made by each user, using the COUNT function and GROUP BY clause.

SELECT
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN bookings b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email
ORDER BY total_bookings DESC;

-- a window function (ROW_NUMBER, RANK) to rank properties based on the total number of bookings they have received.

WITH property_bookings AS (
    SELECT
        p.property_id,
        p.name AS property_name,
        COUNT(b.booking_id) AS total_bookings
    FROM properties p
    LEFT JOIN bookings b ON p.property_id = b.property_id
    GROUP BY p.property_id, p.name
)
SELECT
    property_id,
    property_name,
    total_bookings,
    ROW_NUMBER() OVER (ORDER BY total_bookings DESC) AS row_num_rank,
    RANK() OVER (ORDER BY total_bookings DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY total_bookings DESC) AS dense_rank
FROM property_bookings;
