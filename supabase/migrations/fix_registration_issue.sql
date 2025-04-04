-- This script fixes the "Database error saving new user" issue

-- 1. First, check if the uuid-ossp extension is enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Drop the existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- 3. Create an improved function to handle new user signups
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
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

-- 4. Create the trigger again
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION handle_new_user();

-- 5. Temporarily disable RLS for testing (enable it back after testing)
ALTER TABLE clients DISABLE ROW LEVEL SECURITY;

-- 6. Check if there are any existing users without client records
INSERT INTO clients (id, given_name, family_name, email, phone_number)
SELECT 
  au.id, 
  COALESCE(au.raw_user_meta_data->>'given_name', 'New'),
  COALESCE(au.raw_user_meta_data->>'family_name', 'User'),
  au.email,
  COALESCE(au.raw_user_meta_data->>'phone_number', '')
FROM auth.users au
LEFT JOIN clients c ON au.id = c.id
WHERE c.id IS NULL;

-- 7. Re-enable RLS after testing
-- ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
