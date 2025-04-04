-- Create storage buckets for profile photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile_photos', 'profile_photos', true)
ON CONFLICT (id) DO NOTHING;

-- Set up security policies for the profile_photos bucket
-- Allow authenticated users to upload their own profile photos
CREATE POLICY "Users can upload their own profile photos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile_photos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to update their own profile photos
CREATE POLICY "Users can update their own profile photos"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile_photos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authenticated users to delete their own profile photos
CREATE POLICY "Users can delete their own profile photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile_photos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow public access to profile photos for viewing
CREATE POLICY "Profile photos are publicly accessible"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'profile_photos');

-- Create a function to generate a profile photo URL
CREATE OR REPLACE FUNCTION get_profile_photo_url(user_id UUID, file_name TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN storage.get_public_url('profile_photos', user_id::text || '/' || file_name);
END;
$$ LANGUAGE plpgsql;
