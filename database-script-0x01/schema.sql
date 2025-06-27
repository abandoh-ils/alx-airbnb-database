-- Create ENUM types
CREATE TYPE user_role AS ENUM ('guest', 'host', 'admin');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'canceled');
CREATE TYPE payment_method AS ENUM ('credit_card', 'paypal', 'stripe');
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'refunded');

-- Create tables
CREATE TABLE users (
    user_id UUID PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_roles (
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    role user_role NOT NULL,
    PRIMARY KEY (user_id, role)
);

CREATE TABLE properties (
    property_id UUID PRIMARY KEY,
    host_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL CHECK (price_per_night > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE bookings (
    booking_id UUID PRIMARY KEY,
    property_id UUID NOT NULL REFERENCES properties(property_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL CHECK (end_date > start_date),
    snapshot_price_per_night DECIMAL(10, 2) NOT NULL CHECK (snapshot_price_per_night > 0),
    status booking_status NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payments (
    payment_id UUID PRIMARY KEY,
    booking_id UUID NOT NULL UNIQUE REFERENCES bookings(booking_id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method payment_method NOT NULL,
    status payment_status NOT NULL
);

CREATE TABLE reviews (
    review_id UUID PRIMARY KEY,
    property_id UUID NOT NULL REFERENCES properties(property_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (property_id, user_id)  -- One review per user per property
);

CREATE TABLE messages (
    message_id UUID PRIMARY KEY,
    sender_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_properties_host ON properties(host_id);
CREATE INDEX idx_bookings_property ON bookings(property_id);
CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_dates ON bookings(start_date, end_date);
CREATE INDEX idx_reviews_property ON reviews(property_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_recipient ON messages(recipient_id);
CREATE INDEX idx_user_roles ON user_roles(user_id, role);

-- Trigger function to validate host role
CREATE OR REPLACE FUNCTION validate_host_role()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM user_roles 
        WHERE user_id = NEW.host_id 
        AND role = 'host'
    ) THEN
        RAISE EXCEPTION 'User must have host role to list properties';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to properties table
CREATE TRIGGER trigger_validate_host
BEFORE INSERT OR UPDATE ON properties
FOR EACH ROW EXECUTE FUNCTION validate_host_role();

-- Role validation
PRIMARY KEY (user_id, role)  -- Composite PK ensures unique roles

-- Host validation trigger
BEFORE INSERT OR UPDATE ON properties

-- Review uniqueness
UNIQUE (property_id, user_id)  -- One review per user per property

-- Date validation
CHECK (end_date > start_date)

-- Rating validation
CHECK (rating BETWEEN 1 AND 5)

