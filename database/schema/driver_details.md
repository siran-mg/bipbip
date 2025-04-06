# Driver Details Collection

## Description

The `driver_details` collection stores information specific to users who are drivers in the Ndao application.

## Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | String | Yes | Primary key, foreign key to users.id |
| `is_available` | Boolean | Yes | Whether the driver is currently available for rides |
| `current_latitude` | Double | No | Driver's current latitude coordinate |
| `current_longitude` | Double | No | Driver's current longitude coordinate |
| `rating` | Double | No | Driver's rating (1-5 scale) |
| `created_at` | DateTime | Yes | When the record was created |
| `updated_at` | DateTime | Yes | When the record was last updated |

## Indexes

- `available_idx`: Index on the `is_available` field for faster queries on available drivers
- `user_id_idx`: Index on the `user_id` field for faster lookups

## Security Rules

- Users can read and update their own driver details
- Users cannot delete their driver details
- All users can read driver details where `is_available` is true

## Relationships

- One-to-one with `users` (one driver detail belongs to one user)
- One-to-many with `driver_vehicles` (one driver can have multiple vehicles)

## Example Document

```json
{
  "user_id": "61f8b5e3-c8e0-4a4f-9d5a-3b5c8e7f9d2a",
  "is_available": true,
  "current_latitude": -18.8791902,
  "current_longitude": 47.5079055,
  "rating": 4.8,
  "created_at": "2023-01-01T00:00:00.000Z",
  "updated_at": "2023-01-01T00:00:00.000Z"
}
```

## Notes

- Vehicle information is now stored in the separate `vehicles` collection
- The relationship between drivers and vehicles is managed through the `driver_vehicles` collection
- This design allows drivers to have multiple vehicles
