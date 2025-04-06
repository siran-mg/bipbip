# Driver Vehicles Collection

## Description

The `driver_vehicles` collection links drivers to their vehicles in the Ndao application. This is a junction table that enables a many-to-many relationship between drivers and vehicles.

## Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Primary key |
| `driver_id` | String | Yes | Foreign key to driver_details.user_id |
| `vehicle_id` | String | Yes | Foreign key to vehicles.id |
| `is_primary` | Boolean | Yes | Whether this is the driver's primary vehicle |
| `created_at` | DateTime | Yes | When the record was created |
| `updated_at` | DateTime | Yes | When the record was last updated |

## Indexes

- `driver_id_idx`: Index on the `driver_id` field for faster lookups
- `vehicle_id_idx`: Index on the `vehicle_id` field for faster lookups
- `is_primary_idx`: Index on the `is_primary` field for faster primary vehicle lookups

## Security Rules

- Users can read, update, and delete driver_vehicles records where they are the driver
- Users cannot read other users' driver_vehicles records

## Relationships

- Many-to-one with `driver_details` (many driver_vehicles records can belong to one driver)
- Many-to-one with `vehicles` (many driver_vehicles records can reference one vehicle)

## Example Document

```json
{
  "id": "1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p",
  "driver_id": "61f8b5e3-c8e0-4a4f-9d5a-3b5c8e7f9d2a",
  "vehicle_id": "9a8b7c6d-5e4f-3g2h-1i0j-9k8l7m6n5o4p",
  "is_primary": true,
  "created_at": "2023-01-01T00:00:00.000Z",
  "updated_at": "2023-01-01T00:00:00.000Z"
}
```

## Notes

- This collection was created to enable the relationship between drivers and vehicles
- The `is_primary` field allows a driver to designate one vehicle as their primary vehicle
- When a driver sets a vehicle as primary, all other vehicles for that driver should be set to non-primary
- This design allows for future features like vehicle sharing or fleet management
