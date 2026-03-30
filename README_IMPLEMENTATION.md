# WellQueue - Smart Clinic Queue Management

A Flutter application that helps users find nearby clinics, manage queues intelligently, and book appointments using AI calling agents. The app includes geofencing capabilities for automatic queue joining and a comprehensive admin panel for clinic management.

## Features

### User Features

- **Clinic Discovery**: Find nearby clinics with real-time wait times and ratings
- **Smart Queue Management**: Join queue with instant position notification
- **Geofencing**: Automatic queue joining when arriving within 50 meters of clinic
- **AI Calling Agent**: Book appointments via intelligent voice calling system
- **Real-time Queue Tracking**: Live position updates and estimated wait times
- **Appointment History**: Track past and upcoming appointments
- **User Profile**: Manage personal information and preferences

### Admin Features

- **Clinic Management**: Add, edit, and manage clinic information
- **Queue Oversight**: Real-time view of all clinic queues with status management
- **User Management**: View and manage registered users
- **Dashboard**: Analytics and statistics
- **Staff Management**: Assign roles to clinic staff

## Tech Stack

- **Framework**: Flutter 3.10+
- **Backend**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Real-time**: Supabase Realtime (WebSocket)
- **Location**: Geolocator
- **State Management**: Provider
- **Notifications**: Flutter Local Notifications
- **AI Integration**: N8N Webhook (Retell AI)

## Project Structure

```
lib/
├── core/
│   ├── constants/         # Database schema and constants
│   ├── models/            # Data models (User, Clinic, QueueEntry)
│   └── services/          # Core services (Auth, Queue, Geofencing, etc.)
├── features/
│   ├── auth/              # Authentication screens
│   ├── home/              # User home and clinic browsing
│   ├── admin/             # Admin dashboard and management
│   └── profile/           # User profile management
└── main.dart              # App entry point
```

## Setup Instructions

### 1. Clone Repository

```bash
git clone <repository-url>
cd well_queue_2026
```

### 2. Configure Supabase

1. Create a Supabase project at [supabase.io](https://supabase.io)
2. Get your project URL and anon key
3. Update `lib/core/services/supabase_config.dart`:
   ```dart
   static const String supabaseUrl = 'https://your-project.supabase.co';
   static const String supabaseAnonKey = 'your-anon-key';
   ```

### 3. Set Up Database

1. In Supabase SQL Editor, run scripts in order:
   ```
   1. supabase_schema_create_tables.sql
   2. supabase_rls_policies.sql
   ```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Configure Android

Add permissions to `android/app/src/main/AndroidManifest.xml` (already included in template)

### 6. Configure iOS

Add location descriptions to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>WellQueue needs your location to find nearby clinics</string>
```

### 7. Run App

```bash
flutter run
```

## Usage

### For Users

1. **Sign Up**: Create account with email and password
2. **Browse Clinics**: View nearby clinics on the map
3. **Join Queue**: Select clinic and join queue
4. **Track Position**: Monitor real-time queue position
5. **Use AI Booking**: Call AI agent for faster booking

### For Admins

1. **Log In**: Use admin credentials
2. **Access Dashboard**: View analytics and statistics
3. **Manage Clinics**: Add/edit clinic information
4. **Oversee Queues**: Manage queue statuses and users
5. **Call Users**: Mark users as called, completed, or cancelled

## Admin Credentials Setup

To make a user an admin:

1. In Supabase, go to SQL Editor
2. Run:
   ```sql
   UPDATE users SET role = 'admin' WHERE email = 'admin@example.com';
   ```

## Environment Variables (Optional)

For production, use environment variables:

```bash
export SUPABASE_URL=your_url
export SUPABASE_ANON_KEY=your_key
```

## API Integration

### N8N Webhook (AI Calling)

The app integrates with N8N for AI calling agent functionality. Update the webhook URL in `lib/core/services/webhook_service.dart` with your N8N endpoint.

## Database Schema

### Main Tables

- **users**: User accounts and profiles
- **clinics**: Clinic information with location
- **queue_entries**: User positions in clinic queues
- **appointments**: Appointment bookings
- **admin_users**: Admin role assignments

See `SUPABASE_SETUP.md` for detailed schema documentation.

## Security

- All database access is protected by Row-Level Security (RLS) policies
- Authentication tokens are stored securely
- Location data is encrypted in transit
- Admin actions are logged (see RLS policies)

## Troubleshooting

### Issue: Location permission denied on Android

**Solution**:

1. Go to Settings > Apps > WellQueue > Permissions
2. Enable "Location" permission

### Issue: Queue updates not showing

**Solution**:

1. Ensure Realtime is enabled in Supabase settings
2. Check network connectivity
3. Restart the app

### Issue: Clinic not appearing on map

**Solution**:

1. Verify clinic coordinates (latitude/longitude) are correct
2. Ensure location permission is granted
3. Check that clinics table has data

## Contributing

1. Create a feature branch (`git checkout -b feature/AmazingFeature`)
2. Commit changes (`git commit -m 'Add AmazingFeature'`)
3. Push to branch (`git push origin feature/AmazingFeature`)
4. Open a Pull Request

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Support

For issues and questions, please open an issue on GitHub or contact support@wellqueue.com

## Roadmap

- [ ] Payment integration for premium features
- [ ] Video consultation with doctors
- [ ] Prescription delivery
- [ ] Medical records management
- [ ] Insurance integration
- [ ] Multi-language support
- [ ] Advanced analytics for admins

## Changelog

### Version 1.0.0 (Initial Release)

- User authentication and profile management
- Clinic discovery and browsing
- Queue management with real-time updates
- Geofencing support
- AI calling agent integration
- Admin dashboard and clinic management
