# Storage Buckets

The Ndao application uses Appwrite Storage for storing files. This document describes the storage buckets used by the application.

## Profile Photos Bucket

### Description

The `profile_photos` bucket stores profile photos for users of the Ndao application.

### Configuration

- **Bucket ID**: `profile_photos`
- **Maximum File Size**: 10MB
- **Allowed File Extensions**: .jpg, .jpeg, .png, .gif
- **Enabled**: Yes
- **File Security**: Yes (files are private by default)

### Security Rules

- Users can upload, read, update, and delete their own profile photos
- Users cannot access other users' profile photos directly
- Profile photos are publicly accessible for viewing through generated URLs

### File Structure

Files are stored in folders named after the user's ID:

```
profile_photos/
├── user_id_1/
│   └── profile.jpg
├── user_id_2/
│   └── profile.jpg
└── ...
```

### Usage

- Profile photos are displayed in the user profile
- Profile photos are displayed in the driver list
- Profile photos are displayed in ride details

## Vehicle Photos Bucket

### Description

The `vehicle_photos` bucket stores photos of vehicles used by drivers in the Ndao application.

### Configuration

- **Bucket ID**: `vehicle_photos`
- **Maximum File Size**: 10MB
- **Allowed File Extensions**: .jpg, .jpeg, .png, .gif
- **Enabled**: Yes
- **File Security**: Yes (files are private by default)

### Security Rules

- Users can upload, read, update, and delete photos of their own vehicles
- Users cannot access other users' vehicle photos directly
- Vehicle photos are publicly accessible for viewing through generated URLs

### File Structure

Files are stored in folders named after the user's ID:

```
vehicle_photos/
├── user_id_1/
│   ├── vehicle_1.jpg
│   └── vehicle_2.jpg
├── user_id_2/
│   └── vehicle_1.jpg
└── ...
```

### Usage

- Vehicle photos are displayed in the driver profile
- Vehicle photos are displayed in the vehicle selection screen
- Vehicle photos are displayed in ride details
