# Vehicles Collection

## Description

The `vehicles` collection stores information about vehicles used by drivers in the Ndao application.

## Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Primary key |
| `license_plate` | String | Yes | Vehicle license plate number |
| `brand` | String | Yes | Vehicle brand (manufacturer) |
| `model` | String | Yes | Vehicle model |
| `type` | String | Yes | Vehicle type: motorcycle, car, bicycle, other |
| `photo_url` | String | No | URL to vehicle photo in the vehicle_photos bucket |
| `created_at` | DateTime | Yes | When the record was created |
| `updated_at` | DateTime | Yes | When the record was last updated |

## Indexes

- `license_plate_idx`: Index on the `license_plate` field for faster lookups

## Security Rules

- Users can read, update, and delete vehicles linked to them through the driver_vehicles collection
- Users cannot read other users' vehicles

## Relationships

- One-to-many with `driver_vehicles` (one vehicle can be linked to multiple drivers, though this is rare)

## Example Document

```json
{
  "id": "9a8b7c6d-5e4f-3g2h-1i0j-9k8l7m6n5o4p",
  "license_plate": "ABC123",
  "brand": "Toyota",
  "model": "Corolla",
  "type": "car",
  "photo_url": "https://appwrite.io/storage/buckets/vehicle_photos/files/61f8b5e3-c8e0-4a4f-9d5a-3b5c8e7f9d2a/vehicle.jpg",
  "created_at": "2023-01-01T00:00:00.000Z",
  "updated_at": "2023-01-01T00:00:00.000Z"
}
```

## Notes

- This collection was created to separate vehicle information from driver details
- This design allows drivers to have multiple vehicles
- The `brand` field replaces the previous `color` field for better vehicle identification
