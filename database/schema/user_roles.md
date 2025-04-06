# User Roles Collection

## Description

The `user_roles` collection tracks the roles assigned to each user in the Ndao application. A user can have multiple roles (e.g., both client and driver).

## Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Primary key |
| `user_id` | String | Yes | Foreign key to users.id |
| `role` | String | Yes | Role name: 'client' or 'driver' |
| `is_active` | Boolean | Yes | Whether the role is currently active |
| `created_at` | DateTime | Yes | When the record was created |
| `updated_at` | DateTime | Yes | When the record was last updated |

## Indexes

- `user_role_idx`: Composite index on `user_id` and `role` fields for faster role lookups

## Security Rules

- Users can read their own roles
- Users cannot create, update, or delete roles directly (this is handled by the application)

## Relationships

- Many-to-one with `users` (many roles can belong to one user)

## Example Document

```json
{
  "id": "7a1b2c3d-4e5f-6g7h-8i9j-0k1l2m3n4o5p",
  "user_id": "61f8b5e3-c8e0-4a4f-9d5a-3b5c8e7f9d2a",
  "role": "driver",
  "is_active": true,
  "created_at": "2023-01-01T00:00:00.000Z",
  "updated_at": "2023-01-01T00:00:00.000Z"
}
```
