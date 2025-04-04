-- This script fixes the issue with driver registration

-- 1. First, check if the uuid-ossp extension is enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create a function to check if a user is a driver
CREATE OR REPLACE FUNCTION is_driver(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM drivers WHERE id = user_id);
END;
$$ LANGUAGE plpgsql;

-- 3. Modify the handle_new_user function to check if the user is registering as a driver
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the user is registering as a driver
  IF NEW.raw_user_meta_data->>'user_type' = 'driver' THEN
    -- Don't create a client record for drivers
    RETURN NEW;
  END IF;
  
  -- Only insert if the user doesn't already exist in the clients table
  IF NOT EXISTS (SELECT 1 FROM clients WHERE id = NEW.id) THEN
    BEGIN
      INSERT INTO clients (id, given_name, family_name, email, phone_number)
      VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'given_name', 'New'),
        COALESCE(NEW.raw_user_meta_data->>'family_name', 'User'),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'phone_number', '')
      );
    EXCEPTION
      WHEN OTHERS THEN
        -- Log the specific error but don't fail the transaction
        RAISE NOTICE 'Error inserting client record: %', SQLERRM;
    END;
  END IF;
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the transaction
    RAISE NOTICE 'Error in handle_new_user: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Update RLS policies to allow drivers to access their own data
CREATE POLICY "Drivers can view their own data"
ON drivers
FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Drivers can insert their own data"
ON drivers
FOR INSERT
WITH CHECK (auth.uid() = id);

CREATE POLICY "Drivers can update their own data"
ON drivers
FOR UPDATE
USING (auth.uid() = id);

-- 5. Ensure RLS is enabled for both tables
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
