# Client Details Collection

## Description

The `client_details` collection stores information specific to users who are clients (passengers) in the Ndao application.

## Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | String | Yes | Primary key, foreign key to users.id |
| `rating` | Double | No | Client's rating (1-5 scale) |
| `created_at` | DateTime | Yes | When the record was created |
| `updated_at` | DateTime | Yes | When the record was last updated |

## Indexes

- `user_id_idx`: Index on the `user_id` field for faster lookups

## Security Rules

- Users can read and update their own client details
- Users cannot delete their client details
- Drivers can read client details of users they are providing rides to

## Relationships

- One-to-one with `users` (one client detail belongs to one user)

## Example Document

```json
{
  "user_id": "72a9c4d8-e5f6-4g7h-8i9j-0k1l2m3n4o5p",
  "rating": 4.9,
  "created_at": "2023-01-01T00:00:00.000Z",
  "updated_at": "2023-01-01T00:00:00.000Z"
}
```

## Notes

- The client details collection is intentionally minimal, as most client information is stored in the users collection
- Additional client-specific fields may be added in the future as needed
