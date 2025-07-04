-- Step 1: Create partitioned table structure
CREATE TABLE partitioned_bookings (
    booking_id UUID NOT NULL,
    user_id UUID NOT NULL,
    property_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    guests INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (start_date);

-- Step 2: Create yearly partitions
CREATE TABLE bookings_y2023 PARTITION OF partitioned_bookings
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE bookings_y2024 PARTITION OF partitioned_bookings
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Step 3: Migrate data from original table
INSERT INTO partitioned_bookings
SELECT * FROM bookings;

-- Step 4: Replace original table (production rollout)
BEGIN;
ALTER TABLE bookings RENAME TO bookings_old;
ALTER TABLE partitioned_bookings RENAME TO bookings;
COMMIT;

-- Step 5: Create indexes on partitions
CREATE INDEX idx_bookings_2023_start ON bookings_y2023(start_date);
CREATE INDEX idx_bookings_2024_start ON bookings_y2024(start_date);

-- Query 1: Full table scan (pre-partitioning)
EXPLAIN ANALYZE
SELECT * FROM bookings_old;

-- Query 2: Full table scan (post-partitioning)
EXPLAIN ANALYZE
SELECT * FROM bookings;

-- Query 3: Date range query (pre-partitioning)
EXPLAIN ANALYZE
SELECT * FROM bookings_old
WHERE start_date BETWEEN '2023-07-01' AND '2023-07-31';

-- Query 4: Date range query (post-partitioning)
EXPLAIN ANALYZE
SELECT * FROM bookings
WHERE start_date BETWEEN '2023-07-01' AND '2023-07-31';