-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table for common user data
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  given_name TEXT NOT NULL,
  family_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone_number TEXT NOT NULL,
  profile_picture_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_roles table to track roles (client, driver, or both)
CREATE TABLE IF NOT EXISTS user_roles (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role TEXT NOT NULL, -- 'client' or 'driver'
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, role)
);

-- Create driver_details table for driver-specific information
CREATE TABLE IF NOT EXISTS driver_details (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  is_available BOOLEAN DEFAULT FALSE,
  current_latitude DECIMAL(10, 8),
  current_longitude DECIMAL(11, 8),
  vehicle_license_plate TEXT NOT NULL,
  vehicle_model TEXT NOT NULL,
  vehicle_color TEXT NOT NULL,
  vehicle_type TEXT NOT NULL,
  rating DECIMAL(3, 1),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create client_details table for client-specific information
CREATE TABLE IF NOT EXISTS client_details (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  rating DECIMAL(3, 1),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create a trigger to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for each table
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_driver_details_updated_at
BEFORE UPDATE ON driver_details
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_client_details_updated_at
BEFORE UPDATE ON client_details
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Drop the existing function if it exists
DROP FUNCTION IF EXISTS handle_new_user();

-- Create function to handle new user signups
CREATE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert into users table
  INSERT INTO users (id, given_name, family_name, email, phone_number)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'given_name', 'New'),
    COALESCE(NEW.raw_user_meta_data->>'family_name', 'User'),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'phone_number', '')
  );

  -- Determine role from metadata
  IF NEW.raw_user_meta_data->>'user_type' = 'driver' THEN
    -- Add driver role
    INSERT INTO user_roles (user_id, role) VALUES (NEW.id, 'driver');

    -- Add placeholder driver details (these will be updated later)
    INSERT INTO driver_details (
      user_id,
      vehicle_license_plate,
      vehicle_model,
      vehicle_color,
      vehicle_type
    ) VALUES (
      NEW.id,
      COALESCE(NEW.raw_user_meta_data->>'vehicle_license_plate', 'UNKNOWN'),
      COALESCE(NEW.raw_user_meta_data->>'vehicle_model', 'UNKNOWN'),
      COALESCE(NEW.raw_user_meta_data->>'vehicle_color', 'UNKNOWN'),
      COALESCE(NEW.raw_user_meta_data->>'vehicle_type', 'motorcycle')
    );
  ELSE
    -- Default to client role
    INSERT INTO user_roles (user_id, role) VALUES (NEW.id, 'client');

    -- Add client details
    INSERT INTO client_details (user_id) VALUES (NEW.id);
  END IF;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the transaction
    RAISE NOTICE 'Error in handle_new_user: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop the existing trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger for new user signups
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION handle_new_user();

-- Create RLS policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_details ENABLE ROW LEVEL SECURITY;

-- Users can view and update their own data
DROP POLICY IF EXISTS "Users can view their own data" ON users;
CREATE POLICY "Users can view their own data"
ON users
FOR SELECT
USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own data" ON users;
CREATE POLICY "Users can update their own data"
ON users
FOR UPDATE
USING (auth.uid() = id);

-- Users can view and update their own roles
DROP POLICY IF EXISTS "Users can view their own roles" ON user_roles;
CREATE POLICY "Users can view their own roles"
ON user_roles
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own roles" ON user_roles;
CREATE POLICY "Users can update their own roles"
ON user_roles
FOR UPDATE
USING (auth.uid() = user_id);

-- Users can view and update their own driver details
DROP POLICY IF EXISTS "Users can view their own driver details" ON driver_details;
CREATE POLICY "Users can view their own driver details"
ON driver_details
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own driver details" ON driver_details;
CREATE POLICY "Users can update their own driver details"
ON driver_details
FOR UPDATE
USING (auth.uid() = user_id);

-- Users can view and update their own client details
DROP POLICY IF EXISTS "Users can view their own client details" ON client_details;
CREATE POLICY "Users can view their own client details"
ON client_details
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own client details" ON client_details;
CREATE POLICY "Users can update their own client details"
ON client_details
FOR UPDATE
USING (auth.uid() = user_id);

-- Anyone can view available drivers
DROP POLICY IF EXISTS "Anyone can view available drivers" ON driver_details;
CREATE POLICY "Anyone can view available drivers"
ON driver_details
FOR SELECT
USING (is_available = TRUE);

-- Create indexes for better performance
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role);
CREATE INDEX idx_driver_details_is_available ON driver_details(is_available);
CREATE INDEX idx_driver_details_location ON driver_details(current_latitude, current_longitude);
