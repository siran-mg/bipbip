# Supabase Setup for Ndao

This directory contains SQL migrations for setting up the Supabase database for the Ndao application.

## Setup Instructions

1. Create a Supabase project at [https://supabase.com](https://supabase.com)
2. Get your Supabase URL and anon key from the project settings
3. Update the `.env` file with your Supabase credentials:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```
4. Run the SQL migrations in the Supabase SQL Editor in the following order:
   - `clients_table.sql`
   - `drivers_table.sql`

## Database Schema

### Clients Table

The `clients` table stores information about users who are looking for rides:

- `id`: UUID (primary key, linked to auth.users)
- `given_name`: Text (user's first name)
- `family_name`: Text (user's last name)
- `email`: Text (user's email address)
- `phone_number`: Text (user's phone number)
- `profile_picture_url`: Text (optional URL to profile picture)
- `rating`: Decimal (optional user rating)
- `created_at`: Timestamp (when the record was created)
- `updated_at`: Timestamp (when the record was last updated)

### Drivers Table

The `drivers` table stores information about drivers who provide rides:

- `id`: UUID (primary key, linked to auth.users)
- `given_name`: Text (driver's first name)
- `family_name`: Text (driver's last name)
- `email`: Text (driver's email address)
- `phone_number`: Text (driver's phone number)
- `profile_picture_url`: Text (optional URL to profile picture)
- `rating`: Decimal (optional driver rating)
- `is_available`: Boolean (whether the driver is currently available)
- `current_latitude`: Decimal (driver's current latitude)
- `current_longitude`: Decimal (driver's current longitude)
- `vehicle_license_plate`: Text (vehicle license plate number)
- `vehicle_model`: Text (vehicle model)
- `vehicle_color`: Text (vehicle color)
- `vehicle_type`: Text (vehicle type: motorcycle, car, bicycle, other)
- `created_at`: Timestamp (when the record was created)
- `updated_at`: Timestamp (when the record was last updated)

## Row Level Security (RLS)

Both tables have Row Level Security (RLS) policies to ensure data security:

- Clients can only view, insert, and update their own data
- Drivers can only view, insert, and update their own data
- Anyone can view available drivers

## Automatic User Creation

When a user signs up through Supabase Auth, a trigger automatically creates a corresponding record in the `clients` table.

## Indexes

The `drivers` table has indexes for:
- `is_available`: For faster queries on available drivers
- `current_latitude` and `current_longitude`: For faster geospatial queries
