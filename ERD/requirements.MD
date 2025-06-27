# ER Diagram Requirements

## Overview
This document covers the diagram models, all specified entities, attributes, relationships, and constraints while maintaining AirBnB's core functionality for property listings, bookings, payments, reviews, and messaging.

## Entities and Attributes Identified

### User
* user_id: Primary Key, UUID, Indexed
* first_name: VARCHAR, NOT NULL
* last_name: VARCHAR, NOT NULL
* email: VARCHAR, UNIQUE, NOT NULL
* password_hash: VARCHAR, NOT NULL
* phone_number: VARCHAR, NULL
* role: ENUM (guest, host, admin), NOT NULL
* created_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

### Property
* property_id: Primary Key, UUID, Indexed
* host_id: Foreign Key, references User(user_id)
* name: VARCHAR, NOT NULL
* description: TEXT, NOT NULL
* location: VARCHAR, NOT NULL
* pricepernight: DECIMAL, NOT NULL
* created_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
* updated_at: TIMESTAMP, ON UPDATE CURRENT_TIMESTAMP

### Booking
* booking_id: Primary Key, UUID, Indexed
* property_id: Foreign Key, references Property(property_id)
* user_id: Foreign Key, references User(user_id)
* start_date: DATE, NOT NULL
* end_date: DATE, NOT NULL
* total_price: DECIMAL, NOT NULL
* status: ENUM (pending, confirmed, canceled), NOT NULL
* created_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

### Payment
* payment_id: Primary Key, UUID, Indexed
* booking_id: Foreign Key, references Booking(booking_id)
* amount: DECIMAL, NOT NULL
* payment_date: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
* payment_method: ENUM (credit_card, paypal, stripe), NOT NULL

### Review
* review_id: Primary Key, UUID, Indexed
* property_id: Foreign Key, references Property(property_id)
* user_id: Foreign Key, references User(user_id)
* rating: INTEGER, CHECK: rating >= 1 AND rating <= 5, NOT NULL
* comment: TEXT, NOT NULL
* created_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

### Message
* message_id: Primary Key, UUID, Indexed
* sender_id: Foreign Key, references User(user_id)
* recipient_id: Foreign Key, references User(user_id)
* message_body: TEXT, NOT NULL
* sent_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

## Defined Relationships

### 1. User to Property (1-to-many):

* A user (host) can list multiple properties (USER ||--o{ PROPERTY)
* Each property belongs to exactly one host

### 2. User to Booking (1-to-many):

* A user (guest) can make multiple bookings (USER ||--o{ BOOKING)
* Each booking is made by exactly one user

### 3. Property to Booking (1-to-many):

* A property can have multiple bookings (PROPERTY ||--o{ BOOKING)
* Each booking is for exactly one property

### 4. Booking to Payment (1-to-1):

* Each booking has exactly one payment (BOOKING ||--|| PAYMENT)
* Each payment corresponds to exactly one booking

### 5. User to Review (1-to-many):

* A user can write multiple reviews (USER ||--o{ REVIEW)
* Each review is written by exactly one user

### 6. Property to Review (1-to-many):

* A property can receive multiple reviews (PROPERTY ||--o{ REVIEW)
* Each review is for exactly one property

### 7.User to Message (dual relationships):

* A user can send multiple messages (USER ||--o{ MESSAGE as sender)
* A user can receive multiple messages (USER ||--o{ MESSAGE as recipient)
* Each message has exactly one sender and one recipient

## ERD Diagram
![Alt text](ERD/ERD-airbnb.png)