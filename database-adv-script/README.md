# Advance SQL Queries

## Write a query using an INNER JOIN to retrieve all bookings and the respective users who made those bookings.

## Write a query using aLEFT JOIN to retrieve all properties and their reviews, including properties that have no reviews.

## Write a query using a FULL OUTER JOIN to retrieve all users and all bookings, even if the user has no booking or a booking is not linked to a user.

## Key Notes:
1. **INNER JOIN**
    * Returns only matched records: "Bookings with valid users"
    * Excludes: Users without bookings & orphaned bookings

2. **LEFT JOIN**
    * Returns all properties + reviews (matched or NULL)
    * Critical for: Displaying properties even with zero reviews

3. **FULL OUTER JOIN**
    * Returns all users + all bookings
    * Includes:
        * Users without bookings (e.g., hosts who never booked)
        * Orphaned bookings (e.g., if user account was deleted)

## Real-World Use Cases:
* **Booking History Page:** INNER JOIN (show only actual bookings)
* **Property Listing Page:** LEFT JOIN (show properties regardless of reviews)
* **Admin Audit:** FULL OUTER JOIN (identify data integrity issues)