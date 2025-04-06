# Users Collection

## Description

The `users` collection stores common information for all users in the Ndao application. This includes both clients and drivers.

## Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Primary key, linked to Appwrite auth users |
| `given_name` | String | Yes | User's first name |
| `family_name` | String | Yes | User's last name |
| `email` | String | Yes | User's email address |
| `phone_number` | String | No | User's phone number |
| `profile_picture_url` | String | No | URL to profile picture in the profile_photos bucket |
| `created_at` | DateTime | Yes | When the record was created |
| `updated_at` | DateTime | Yes | When the record was last updated |

## Indexes

- `email_idx`: Index on the `email` field for faster user lookups

## Security Rules

- Users can read and update their own user document
- Users cannot delete their user document
- Users cannot read other users' documents directly (they can see available drivers through the driver_details collection)

## Relationships

- One-to-many with `user_roles` (one user can have multiple roles)
- One-to-one with `driver_details` (if the user is a driver)
- One-to-one with `client_details` (if the user is a client)

## Example Document

```json
{
  "id": "61f8b5e3-c8e0-4a4f-9d5a-3b5c8e7f9d2a",
  "given_name": "John",
  "family_name": "Doe",
  "email": "john.doe@example.com",
  "phone_number": "+1234567890",
  "profile_picture_url": "https://appwrite.io/storage/buckets/profile_photos/files/61f8b5e3-c8e0-4a4f-9d5a-3b5c8e7f9d2a/profile.jpg",
  "created_at": "2023-01-01T00:00:00.000Z",
  "updated_at": "2023-01-01T00:00:00.000Z"
}
```
