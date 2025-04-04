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
   - `user_table.sql`
   - `storage_setup.sql`

## Database Schema

### Users Table

The `users` table stores common information for all users:

- `id`: UUID (primary key, linked to auth.users)
- `given_name`: Text (user's first name)
- `family_name`: Text (user's last name)
- `email`: Text (user's email address)
- `phone_number`: Text (user's phone number)
- `profile_picture_url`: Text (optional URL to profile picture)
- `created_at`: Timestamp (when the record was created)
- `updated_at`: Timestamp (when the record was last updated)

### User Roles Table

The `user_roles` table tracks the roles of each user:

- `user_id`: UUID (foreign key to users.id)
- `role`: Text ('client' or 'driver')
- `is_active`: Boolean (whether the role is currently active)
- `created_at`: Timestamp (when the record was created)

### Driver Details Table

The `driver_details` table stores driver-specific information:

- `user_id`: UUID (foreign key to users.id)
- `is_available`: Boolean (whether the driver is currently available)
- `current_latitude`: Decimal (driver's current latitude)
- `current_longitude`: Decimal (driver's current longitude)
- `vehicle_license_plate`: Text (vehicle license plate number)
- `vehicle_model`: Text (vehicle model)
- `vehicle_color`: Text (vehicle color)
- `vehicle_type`: Text (vehicle type: motorcycle, car, bicycle, other)
- `rating`: Decimal (optional driver rating)
- `created_at`: Timestamp (when the record was created)
- `updated_at`: Timestamp (when the record was last updated)

### Client Details Table

The `client_details` table stores client-specific information:

- `user_id`: UUID (foreign key to users.id)
- `rating`: Decimal (optional client rating)
- `created_at`: Timestamp (when the record was created)
- `updated_at`: Timestamp (when the record was last updated)

## Storage

The application uses Supabase Storage for storing profile photos:

- **Bucket**: `profile_photos` - Stores user profile photos
- **Structure**: Files are stored in folders named after the user's ID
- **Security**: RLS policies ensure users can only access their own photos
- **Public Access**: Profile photos are publicly accessible for viewing

## Row Level Security (RLS)

All database tables and storage buckets have Row Level Security (RLS) policies to ensure data security:

- Users can only view, insert, and update their own data
- Users can only view and update their own roles
- Users can only view and update their own driver or client details
- Anyone can view available drivers

## Automatic User Creation

When a user signs up through Supabase Auth, a trigger automatically creates corresponding records in the following tables:
- `users` table with basic user information
- `user_roles` table with the appropriate role ('client' or 'driver')
- `driver_details` or `client_details` table based on the user's role

## Indexes

The database has several indexes for better performance:
- `user_roles_user_id`: For faster role lookups
- `user_roles_role`: For faster filtering by role
- `driver_details_is_available`: For faster queries on available drivers
- `driver_details_location`: For faster geospatial queries
