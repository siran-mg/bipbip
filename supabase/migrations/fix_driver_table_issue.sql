-- This script fixes issues with the driver table

-- 1. First, check if the uuid-ossp extension is enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Make sure the id column in the drivers table accepts auth.uid values
ALTER TABLE drivers ALTER COLUMN id DROP DEFAULT;

-- 3. Modify the RLS policies to be more permissive for testing
-- Temporarily disable RLS on the drivers table
ALTER TABLE drivers DISABLE ROW LEVEL SECURITY;

-- 4. Create a function to debug driver insertion
CREATE OR REPLACE FUNCTION debug_driver_insert()
RETURNS TRIGGER AS $$
BEGIN
  RAISE NOTICE 'Inserting driver with ID: %', NEW.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. Create a trigger to log driver insertions
DROP TRIGGER IF EXISTS debug_driver_insert_trigger ON drivers;
CREATE TRIGGER debug_driver_insert_trigger
BEFORE INSERT ON drivers
FOR EACH ROW
EXECUTE FUNCTION debug_driver_insert();

-- 6. Create a test driver record to verify the table works
INSERT INTO drivers (
  id, 
  given_name, 
  family_name, 
  email, 
  phone_number, 
  vehicle_license_plate, 
  vehicle_model, 
  vehicle_color, 
  vehicle_type
)
VALUES (
  uuid_generate_v4(), 
  'Test', 
  'Driver', 
  'test.driver@example.com', 
  '+1234567890', 
  'TEST123', 
  'Test Model', 
  'Red', 
  'motorcycle'
)
ON CONFLICT (email) DO NOTHING;

-- 7. List all drivers to verify
SELECT * FROM drivers;
