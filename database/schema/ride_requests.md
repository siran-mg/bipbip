# Ride Requests Collection

## Description

The `ride_requests` collection stores ride requests from clients to drivers in the Ndao application.

## Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Primary key |
| `client_id` | String | Yes | Foreign key to users.id representing the client |
| `pickup_latitude` | Double | Yes | Latitude of the pickup location |
| `pickup_longitude` | Double | Yes | Longitude of the pickup location |
| `destination_latitude` | Double | Yes | Latitude of the destination |
| `destination_longitude` | Double | Yes | Longitude of the destination |
| `destination_name` | String | Yes | Human-readable name of the destination |
| `budget` | Double | Yes | Client's budget for the ride |
| `status` | String | Yes | Status of the request: 'pending', 'accepted', 'rejected', 'completed', 'cancelled' |
| `driver_id` | String | No | Foreign key to users.id representing the driver who accepted the request |
| `created_at` | DateTime | Yes | When the record was created |
| `updated_at` | DateTime | Yes | When the record was last updated |

## Indexes

- `client_id_idx`: Index on the `client_id` field for faster lookups
- `driver_id_idx`: Index on the `driver_id` field for faster lookups
- `status_idx`: Index on the `status` field for faster queries on request status
- `location_idx`: Geospatial index on `pickup_latitude` and `pickup_longitude` for finding nearby requests

## Security Rules

- Clients can create ride requests and read/update their own requests
- Drivers can read requests near their location and update requests they've accepted
- Users cannot delete ride requests (for audit purposes)

## Relationships

- Many-to-one with `users` (many ride requests can belong to one client)
- Many-to-one with `users` (many ride requests can be accepted by one driver)

## Example Document

```json
{
  "id": "5e8f8f8f-8f8f-8f8f-8f8f-8f8f8f8f8f8f",
  "client_id": "1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p",
  "pickup_latitude": -18.8792,
  "pickup_longitude": 47.5079,
  "destination_latitude": -18.9000,
  "destination_longitude": 47.5200,
  "destination_name": "Analakely Market",
  "budget": 15000,
  "status": "pending",
  "driver_id": null,
  "created_at": "2023-01-01T00:00:00.000Z",
  "updated_at": "2023-01-01T00:00:00.000Z"
}
```

## Notes

- When a ride request is created, it is initially in the 'pending' status
- When a driver accepts a request, the status changes to 'accepted' and the driver_id is set
- When a driver rejects a request, the status remains 'pending' for other drivers to see
- The client can cancel a request at any time, changing the status to 'cancelled'
- When a ride is completed, the status changes to 'completed'
