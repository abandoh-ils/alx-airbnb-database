#Performance Index

### Step 1: Identify High-Usage Columns  
Based on common query patterns:

| Table     | High-Usage Columns               | Usage Context                     |
|-----------|----------------------------------|-----------------------------------|
| `users`   | `email`, `created_at`, `role`    | WHERE (login), ORDER BY (reports) |
| `bookings`| `user_id`, `property_id`, `start_date`, `status` | JOINs, date filters, status checks |
| `properties` | `host_id`, `location`, `price_per_night` | Host dashboards, search queries |

---

### Step 2: Create Indexes (`database_index.sql`)  
```sql
-- Users Table Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_role ON users(role);

-- Bookings Table Indexes
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_bookings_dates ON bookings(start_date, end_date);
CREATE INDEX idx_bookings_status ON bookings(status);

-- Properties Table Indexes
CREATE INDEX idx_properties_host_id ON properties(host_id);
CREATE INDEX idx_properties_location ON properties(location);
CREATE INDEX idx_properties_price ON properties(price_per_night);
```

---

### Step 3: Measure Performance  
#### Before Indexes (Sample Query)  
```sql
EXPLAIN ANALYZE
SELECT * FROM bookings 
WHERE user_id = '00000000-0000-0000-0000-000000000003' 
  AND status = 'confirmed';
```
**Output**:  
```
Seq Scan on bookings  (cost=0.00..12548.20 rows=1 width=72) (actual time=32.15..32.16 rows=2 loops=1)
  Filter: ((user_id = '00000000-0000-0000-0000-000000000003'::uuid) AND (status = 'confirmed'::booking_status))
  Rows Removed by Filter: 100248
Planning Time: 0.15 ms
Execution Time: 32.18 ms
```

#### After Indexes  
```sql
EXPLAIN ANALYZE
SELECT * FROM bookings 
WHERE user_id = '00000000-0000-0000-0000-000000000003' 
  AND status = 'confirmed';
```
**Output**:  
```
Bitmap Heap Scan on bookings  (cost=4.58..12.64 rows=2 width=72) (actual time=0.03..0.04 rows=2 loops=1)
  Recheck Cond: (user_id = '00000000-0000-0000-0000-000000000003'::uuid)
  Filter: (status = 'confirmed'::booking_status)
  Heap Blocks: exact=1
  ->  Bitmap Index Scan on idx_bookings_user_id  (cost=0.00..4.58 rows=10 width=0) (actual time=0.02..0.02 rows=2 loops=1)
        Index Cond: (user_id = '00000000-0000-0000-0000-000000000003'::uuid)
Planning Time: 0.25 ms
Execution Time: 0.06 ms
```

---

### Performance Comparison  
| Metric          | Before Indexes | After Indexes | Improvement |
|-----------------|----------------|---------------|-------------|
| Execution Time  | 32.18 ms       | 0.06 ms       | 536x faster |
| Rows Scanned    | 100,248        | 2             | 50,124x fewer |
| Operation       | Seq Scan       | Bitmap Scan   | Index utilization |

---

### Indexing Strategy Summary  
1. **Equality Filters**: Index columns used in `WHERE` clauses with `=`  
   ```sql
   CREATE INDEX idx_users_email ON users(email);
   ```
   
2. **Range Queries**: Index date/time columns for temporal filters  
   ```sql
   CREATE INDEX idx_bookings_dates ON bookings(start_date, end_date);
   ```
   
3. **Composite Indexes**: Group frequently co-filtered columns  
   ```sql
   -- Not created above but useful example:
   CREATE INDEX idx_properties_search ON properties(location, price_per_night);
   ```

4. **Covering Indexes**: Include frequently accessed columns to avoid table lookups  
   ```sql
   CREATE INDEX idx_bookings_covering ON bookings(user_id, status) INCLUDE (start_date, end_date);
   ```

---

### Monitoring Recommendations  
```sql
-- Check index usage
SELECT * FROM pg_stat_all_indexes 
WHERE schemaname = 'public'
  AND relname IN ('users', 'bookings', 'properties');

-- Rebuild fragmented indexes
REINDEX INDEX idx_bookings_user_id;
```

**Key Metrics**:  
- Index scan ratio (>99% ideal)  
- Cache hit rate (>95% ideal)  
- Index size vs table size  

> **Note**: Add indexes *after* bulk data loads. Use `pg_stat_statements` to identify slow queries in production.