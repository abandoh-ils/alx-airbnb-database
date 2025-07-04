-- a query using an INNER JOIN to retrieve all bookings and the respective users who made those bookings.
SELECT 
  b.booking_id,
  b.start_date,
  b.end_date,
  u.user_id,
  u.email,
  CONCAT(u.first_name, ' ', u.last_name) AS guest_name
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id ORDER BY b.booking_id;

-- a query using aLEFT JOIN to retrieve all properties and their reviews, including properties that have no reviews
SELECT 
  p.property_id,
  p.name AS property_name,
  r.review_id,
  r.rating,
  r.comment
FROM properties p
LEFT JOIN reviews r ON p.property_id = r.property_id ORDER BY p.property_id;

-- a query using a FULL OUTER JOIN to retrieve all users and all bookings, even if the user has no booking or a booking is not linked to a user.

SELECT 
  u.user_id,
  u.email,
  b.booking_id,
  b.start_date
FROM users u
FULL OUTER JOIN bookings b ON u.user_id = b.user_id ORDER BY u.user_id;