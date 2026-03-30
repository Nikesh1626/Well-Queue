# WellQueue Supabase Setup Guide

## Prerequisites

- Supabase project created
- Supabase URL and anon key ready

## Step 1: Configure Supabase Credentials

Update `lib/core/services/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://YOUR-PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR-ANON-KEY';
  // ... rest of the code
}
```

## Step 2: Run Database Migrations

Execute the SQL scripts in your Supabase SQL Editor in the following order:

1. First, create tables:
   - Run `supabase_schema_create_tables.sql`

2. Then, set up security policies:
   - Run `supabase_rls_policies.sql`

3. Finally, create indexes for performance:
   - Run `supabase_indexes.sql`

## Step 3: Android Setup

### AndroidManifest.xml Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Gradle Configuration

Ensure `android/app/build.gradle.kts` has:

```kotlin
android {
    compileSdk = 34  // or higher

    defaultConfig {
        minSdk = 21
        targetSdk = 34
    }
}
```

## Step 4: iOS Setup

### Info.plist Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>WellQueue needs your location to manage clinic queues and find nearby clinics.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>WellQueue needs your location to manage clinic queues and find nearby clinics.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>WellQueue needs your location to manage clinic queues and find nearby clinics.</string>
```

## Step 5: Testing

1. After setup, test the authentication flow:

   ```bash
   flutter run
   ```

2. Sign up a test user
3. Test clinic listing
4. Test queue joining functionality
5. For admin testing, manually update the user role in Supabase:
   ```sql
   UPDATE users SET role = 'admin' WHERE email = 'admin@example.com';
   ```

## Database Schema Summary

| Table           | Purpose              | Key Fields                                       |
| --------------- | -------------------- | ------------------------------------------------ |
| `users`         | User accounts        | id, email, first_name, last_name, role           |
| `clinics`       | Clinic information   | id, name, latitude, longitude, wait_time_minutes |
| `queue_entries` | Queue management     | id, clinic_id, user_id, position, status         |
| `queue_updates` | Queue status history | id, queue_entry_id, message, type                |

## Real-time Updates

The app uses Supabase Realtime to listen for queue updates. Ensure Realtime is enabled in your Supabase project settings.

## Troubleshooting

### Location Permissions Denied

- iOS: Check `Info.plist` for proper location descriptions
- Android: Ensure permissions are in `AndroidManifest.xml` and runtime permissions are granted

### Database Connection Issues

- Verify Supabase credentials in `supabase_config.dart`
- Check that your Supabase project is active
- Verify RLS policies allow your auth user to access tables

### Queue Updates Not Showing

- Enable Realtime in Supabase project settings
- Check that the `$\users` table has `realtime` enabled
- Verify network connectivity

## Security Notes

- Never commit `supabase_config.dart` with real credentials
- Use environment variables or secrets management for production
- The anon key should only have minimal permissions (use RLS policies)
- All database operations should go through Supabase auth context
