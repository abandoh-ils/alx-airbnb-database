# Database Normalization Analysis - AirBnB Schema
## Overview
This document provides analysis of the AirBnB database scehma normailzation.


## Original Schema Issues:
1. Partial Dependency in Bookings:

* total_price can be calculated from pricepernight and date difference

2. Transitive Dependency in Properties:

* host_id → role dependency exists (host role implies host capabilities)

3. Redundant Storage:

* role in Users table doesn't support multi-role users

* Payment status duplicated in Booking and Payment tables

4. Attribute Naming Inconsistency:

* pricepernight should be price_per_night