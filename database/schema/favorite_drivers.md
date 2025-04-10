# Favorite Drivers Collection

## Description

The `favorite_drivers` collection stores relationships between clients and their favorite drivers in the Ndao application.

## Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `client_id` | String | Yes | Foreign key to users.id representing the client |
| `driver_id` | String | Yes | Foreign key to users.id representing the driver |
| `created_at` | DateTime | Yes | When the record was created |
| `updated_at` | DateTime | Yes | When the record was last updated |

## Indexes

- `client_id_idx`: Index on the `client_id` field for faster lookups
- `driver_id_idx`: Index on the `driver_id` field for faster lookups
- `client_driver_idx`: Unique composite index on `client_id` and `driver_id` to prevent duplicates

## Security Rules

- Users can read and write their own favorite drivers
- Users cannot delete their favorite drivers directly (must use the application)
- Drivers can see which clients have marked them as favorites

## Relationships

- Many-to-many relationship between clients and drivers
- Each record represents one client marking one driver as a favorite

## Example Document

```json
{
  "client_id": "72a9c4d8-e5f6-4g7h-8i9j-0k1l2m3n4o5p",
  "driver_id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p",
  "created_at": "2023-01-01T00:00:00.000Z",
  "updated_at": "2023-01-01T00:00:00.000Z"
}
```

## Notes

- This collection implements a many-to-many relationship between clients and drivers
- Using a dedicated collection for favorites allows for more efficient querying and better scalability
- The composite index ensures that a client can only mark a driver as a favorite once
