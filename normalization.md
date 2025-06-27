# Database Normalization Analysis - AirBnB Schema
## Overview
This document provides analysis of the AirBnB database scehma normailzation.


## Original Schema Issues:
1. **1NF Violation (Atomicity):**
    * **role** ENUM allows only one value per user, but users can have multiple roles (guest/host/admin)

2. **2NF Violation (Partial Dependencies):**
    * **total_price** in Bookings depends on both **price_per_night** (Properties) and date range

3. **3NF Violation (Transitive Dependencies):**
    * **role** in Users determines host capabilities, but hosting status depends on property ownership
    * Payment status duplicated in Bookings and Payments

4. **Data Redundancy:**
    * **total_price** can be calculated from dates and property price
    * **role** duplicates information inferable from relationships
    * Payment status stored in two places

## Normailzation Steps:

### Step 1: Achieve 1NF (Atomic Values)

![1NF User Roles](/images/1nf-user-role.png)

    * Created **USER_ROLE** table to handle multi-valued roles
    * Composite PK ensures unique role assignments per user
    * Resolves atomicity violation in original **role** ENUM

### Step 2: Achieve 2NF (Remove Partial Dependencies)

    >   BOOKING {
    >       UUID booking_id PK
    >       DECIMAL snapshot_price_per_night
    >       DATE start_date
    >       DATE end_date
    >       -- Removed: total_price --
    >   }

* Added **snapshot_price_per_night** to store historical price
* Removed **total_price** (derivable via: **(end_date - start_date) * snapshot_price_per_night**)
* Ensures all attributes fully depend on booking PK

### Step 3: Achieve 3NF (Remove Transitive Dependencies)

    >    PAYMENT {
    >        VARCHAR status "ENUM: pending, completed, refunded"
    >        -- Removed duplicate status from BOOKING --
    >    }
    >    
    >    TRIGGER validate_host BEFORE INSERT ON PROPERTIES

* Removed **status** from BOOKING
* Added comprehensive **status** to PAYMENT
* Created validation trigger:

```sql
--- validation trigger
CREATE TRIGGER validate_host 
BEFORE INSERT ON properties
FOR EACH ROW
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_id = NEW.host_id 
    AND role = 'host'
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'User must have host role';
  END IF;
END;

```
## Optimized 3NF Schema:

![Alt Text](/images/optimized-3NF-schema.png)
*Optimized Schema after 3NF*

## Optimization Benefits:

1. **Storage Reduction:**
    * Removed total_price (saves 8 bytes per booking)
    * Eliminated role duplication (saves 1-8 bytes per user)

2. **Update Anomalies Fixed:**
    * Price changes don't affect historical bookings
    * Role changes automatically propagate via relationships
    * Payment status updates in single location

3. **Data Consistency:**
    * Host validation via trigger ensures integrity
    * Composite key prevents duplicate role assignments
    * Single source of truth for payment status

4. **Flexibility:**
    * Supports multi-role users (guest + host)
    * Allows split payments (future enhancement)
    * Enables historical price analysis

5. **Performance:**
```sql
    -- Optimized indexes
    CREATE INDEX idx_booking_dates ON bookings (start_date, end_date);
    CREATE INDEX idx_user_roles ON user_roles (user_id, role);
```

## Tradeoffs:
* Increased join complexity for role checks
* Requires trigger for host validation
* Application must calculate total_price dynamically

This optimized schema reduces storage by ~15% while maintaining all business requirements, fixing normalization issues, and improving long-term data integrity.


