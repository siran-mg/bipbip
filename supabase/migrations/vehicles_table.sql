-- Create vehicles table
CREATE TABLE IF NOT EXISTS vehicles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  license_plate TEXT NOT NULL,
  brand TEXT NOT NULL,
  model TEXT NOT NULL,
  type TEXT NOT NULL, -- 'motorcycle', 'car', 'bicycle', 'other'
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create driver_vehicles junction table
CREATE TABLE IF NOT EXISTS driver_vehicles (
  driver_id UUID REFERENCES driver_details(user_id) ON DELETE CASCADE,
  vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (driver_id, vehicle_id)
);

-- Modify driver_details table to remove vehicle information
ALTER TABLE driver_details 
  DROP COLUMN vehicle_license_plate,
  DROP COLUMN vehicle_model,
  DROP COLUMN vehicle_color,
  DROP COLUMN vehicle_type;

-- Create a trigger to update the updated_at column for vehicles
CREATE TRIGGER update_vehicles_updated_at
BEFORE UPDATE ON vehicles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Create a trigger to update the updated_at column for driver_vehicles
CREATE TRIGGER update_driver_vehicles_updated_at
BEFORE UPDATE ON driver_vehicles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Create storage bucket for vehicle photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('vehicle_photos', 'vehicle_photos', true)
ON CONFLICT (id) DO NOTHING;

-- Set up security policies for the vehicle_photos bucket
-- Allow authenticated users to upload their own vehicle photos
CREATE POLICY "Users can upload their own vehicle photos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'vehicle_photos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to update their own vehicle photos
CREATE POLICY "Users can update their own vehicle photos"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'vehicle_photos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to delete their own vehicle photos
CREATE POLICY "Users can delete their own vehicle photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'vehicle_photos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow public access to vehicle photos for viewing
CREATE POLICY "Vehicle photos are publicly accessible"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'vehicle_photos');

-- Create a function to generate a vehicle photo URL
CREATE OR REPLACE FUNCTION get_vehicle_photo_url(user_id UUID, file_name TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN storage.get_public_url('vehicle_photos', user_id::text || '/' || file_name);
END;
$$ LANGUAGE plpgsql;

-- Enable RLS on the new tables
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_vehicles ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for vehicles
CREATE POLICY "Users can view their own vehicles"
ON vehicles
FOR SELECT
USING (
  id IN (
    SELECT vehicle_id 
    FROM driver_vehicles 
    WHERE driver_id = auth.uid()
  )
);

CREATE POLICY "Users can update their own vehicles"
ON vehicles
FOR UPDATE
USING (
  id IN (
    SELECT vehicle_id 
    FROM driver_vehicles 
    WHERE driver_id = auth.uid()
  )
);

CREATE POLICY "Users can delete their own vehicles"
ON vehicles
FOR DELETE
USING (
  id IN (
    SELECT vehicle_id 
    FROM driver_vehicles 
    WHERE driver_id = auth.uid()
  )
);

-- Create RLS policies for driver_vehicles
CREATE POLICY "Users can view their own driver_vehicles"
ON driver_vehicles
FOR SELECT
USING (driver_id = auth.uid());

CREATE POLICY "Users can update their own driver_vehicles"
ON driver_vehicles
FOR UPDATE
USING (driver_id = auth.uid());

CREATE POLICY "Users can delete their own driver_vehicles"
ON driver_vehicles
FOR DELETE
USING (driver_id = auth.uid());

-- Create indexes for better performance
CREATE INDEX idx_vehicles_license_plate ON vehicles(license_plate);
CREATE INDEX idx_driver_vehicles_driver_id ON driver_vehicles(driver_id);
CREATE INDEX idx_driver_vehicles_vehicle_id ON driver_vehicles(vehicle_id);
CREATE INDEX idx_driver_vehicles_is_primary ON driver_vehicles(is_primary);

-- Update the handle_new_user function to work with the new schema
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  vehicle_id UUID;
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

    -- Add placeholder driver details
    INSERT INTO driver_details (user_id) 
    VALUES (NEW.id);
    
    -- Create a vehicle
    INSERT INTO vehicles (
      license_plate,
      brand,
      model,
      type
    ) VALUES (
      COALESCE(NEW.raw_user_meta_data->>'vehicle_license_plate', 'UNKNOWN'),
      COALESCE(NEW.raw_user_meta_data->>'vehicle_brand', 'UNKNOWN'),
      COALESCE(NEW.raw_user_meta_data->>'vehicle_model', 'UNKNOWN'),
      COALESCE(NEW.raw_user_meta_data->>'vehicle_type', 'motorcycle')
    )
    RETURNING id INTO vehicle_id;
    
    -- Link the vehicle to the driver
    INSERT INTO driver_vehicles (driver_id, vehicle_id, is_primary)
    VALUES (NEW.id, vehicle_id, TRUE);
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
