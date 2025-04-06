# Database Schema Documentation

This directory contains detailed documentation for each collection and storage bucket in the Ndao application's database.

## Collections

- [Users](users.md) - Common information for all users
- [User Roles](user_roles.md) - Roles assigned to users (client, driver)
- [Driver Details](driver_details.md) - Information specific to drivers
- [Client Details](client_details.md) - Information specific to clients
- [Vehicles](vehicles.md) - Information about vehicles
- [Driver Vehicles](driver_vehicles.md) - Junction collection linking drivers to vehicles

## Storage

- [Storage Buckets](storage.md) - Documentation for profile_photos and vehicle_photos buckets

## Entity Relationship Diagram

```
┌─────────────┐       ┌──────────────┐       ┌───────────────┐
│    Users    │       │  User Roles  │       │ Driver Details│
├─────────────┤       ├──────────────┤       ├───────────────┤
│ id          │───┐   │ id           │       │ user_id       │───┐
│ given_name  │   └──>│ user_id      │       │ is_available  │   │
│ family_name │       │ role         │       │ current_lat   │   │
│ email       │       │ is_active    │       │ current_long  │   │
│ phone_number│       │ created_at   │       │ rating        │   │
│ profile_pic │       │ updated_at   │       │ created_at    │   │
│ created_at  │       └──────────────┘       │ updated_at    │   │
│ updated_at  │                              └───────────────┘   │
└─────────────┘                                                  │
       │                                                         │
       │       ┌──────────────┐                                  │
       │       │Client Details│                                  │
       │       ├──────────────┤                                  │
       └──────>│ user_id      │          ┌─────────────────┐     │
               │ rating       │          │ Driver Vehicles │     │
               │ created_at   │          ├─────────────────┤     │
               │ updated_at   │          │ id              │     │
               └──────────────┘          │ driver_id       │<────┘
                                         │ vehicle_id      │───┐
                                         │ is_primary      │   │
                                         │ created_at      │   │
                                         │ updated_at      │   │
                                         └─────────────────┘   │
                                                               │
                                         ┌─────────────────┐   │
                                         │    Vehicles     │   │
                                         ├─────────────────┤   │
                                         │ id              │<──┘
                                         │ license_plate   │
                                         │ brand           │
                                         │ model           │
                                         │ type            │
                                         │ photo_url       │
                                         │ created_at      │
                                         │ updated_at      │
                                         └─────────────────┘
```

## Notes

- All collections include `created_at` and `updated_at` timestamps
- Primary keys are generally named `id`, except for collections where the primary key is also a foreign key
- Foreign keys follow the naming convention `entity_id` (e.g., `user_id`, `vehicle_id`)
- All collections have appropriate indexes for performance optimization
