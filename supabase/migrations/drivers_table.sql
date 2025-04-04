-- Create drivers table
CREATE TABLE IF NOT EXISTS drivers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone_number TEXT NOT NULL,
  profile_picture_url TEXT,
  rating DECIMAL(3, 1),
  is_available BOOLEAN DEFAULT FALSE,
  current_latitude DECIMAL(10, 8),
  current_longitude DECIMAL(11, 8),
  vehicle_license_plate TEXT NOT NULL,
  vehicle_model TEXT NOT NULL,
  vehicle_color TEXT NOT NULL,
  vehicle_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create a trigger to update the updated_at column
CREATE TRIGGER update_drivers_updated_at
BEFORE UPDATE ON drivers
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Create RLS policies
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;

-- Policy for users to see available drivers
CREATE POLICY "Anyone can view available drivers"
ON drivers
FOR SELECT
USING (is_available = TRUE);

-- Policy for drivers to see their own data
CREATE POLICY "Drivers can view their own data"
ON drivers
FOR SELECT
USING (auth.uid() = id);

-- Policy for drivers to insert their own data
CREATE POLICY "Drivers can insert their own data"
ON drivers
FOR INSERT
WITH CHECK (auth.uid() = id);

-- Policy for drivers to update their own data
CREATE POLICY "Drivers can update their own data"
ON drivers
FOR UPDATE
USING (auth.uid() = id);

-- Create index for faster queries on available drivers
CREATE INDEX idx_drivers_is_available ON drivers(is_available);

-- Create index for geospatial queries
CREATE INDEX idx_drivers_location ON drivers(current_latitude, current_longitude);
