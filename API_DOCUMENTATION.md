# WellQueue API & Integration Documentation

## Table of Contents

1. [Supabase Integration](#supabase-integration)
2. [Authentication API](#authentication-api)
3. [Clinic API](#clinic-api)
4. [Queue API](#queue-api)
5. [Real-time Updates](#real-time-updates)
6. [Admin API](#admin-api)
7. [N8N Webhook Integration](#n8n-webhook-integration)

---

## Supabase Integration

### Configuration

All Supabase operations are managed through `SupabaseConfig` class and individual service classes.

```dart
import 'package:well_queue_2026/core/services/supabase_config.dart';

// Initialize in main()
await SupabaseConfig.initialize();

// Access client
final client = SupabaseConfig.client;
```

### Authentication

Supabase Auth provides email/password authentication with automatic user profile creation.

---

## Authentication API

### AuthService Methods

#### 1. Sign Up

```dart
final authService = AuthService();

bool success = await authService.signUp(
  email: 'user@example.com',
  password: 'SecurePassword123',
  firstName: 'John',
  lastName: 'Doe',
);
```

**Response**: Boolean indicating success.

**Database Entry**: Creates user profile in `users` table with role='user'

---

#### 2. Sign In

```dart
bool success = await authService.signIn(
  email: 'user@example.com',
  password: 'SecurePassword123',
);
```

**Response**: Boolean indicating success. Loads current user profile.

---

#### 3. Update Profile

```dart
bool success = await authService.updateProfile(
  firstName: 'Jane',
  lastName: 'Smith',
  phone: '+1234567890',
  age: 30,
);
```

**Response**: Boolean indicating success.

---

#### 4. Reset Password

```dart
bool success = await authService.resetPassword('user@example.com');
```

**Response**: Boolean indicating success. Sends reset email via Supabase.

---

#### 5. Sign Out

```dart
await authService.signOut();
```

---

## Clinic API

### ClinicService Methods

#### 1. Fetch All Clinics

```dart
final clinicService = ClinicService();
await clinicService.fetchClinics();

final clinics = clinicService.clinics; // List<Clinic>
```

---

#### 2. Get Clinic by ID

```dart
final clinic = await clinicService.getClinicById('clinic-uuid');
```

**Returns**: `Clinic?` object or null if not found.

---

#### 3. Search Clinics

```dart
clinicService.searchClinics('Apollo');

final results = clinicService.filteredClinics; // Search results
```

---

#### 4. Filter by Service

```dart
clinicService.filterByService('Cardiology');

final results = clinicService.filteredClinics; // Filtered results
```

---

#### 5. Sort by Distance

```dart
clinicService.sortByDistance(
  userLat: 28.6139,
  userLng: 77.2090,
);
```

---

## Queue API

### QueueService Methods

#### 1. Join Queue

```dart
final queueService = QueueService();

bool success = await queueService.joinQueue(
  clinicId: 'clinic-uuid',
  clinicName: 'Apollo Hospital',
  userId: 'user-uuid',
);
```

**Database**: Creates entry in `queue_entries` table with:

- `position`: Auto-calculated based on current queue
- `status`: 'confirmed'
- `estimatedWaitMinutes`: Position × 5 minutes

---

#### 2. Cancel Queue

```dart
bool success = await queueService.cancelQueue('queue-entry-uuid');
```

**Database**: Updates `queue_entries` status to 'cancelled'

---

#### 3. Load User's Current Queue

```dart
await queueService.loadUserQueue('user-uuid');

final currentQueue = queueService.currentQueue; // QueueEntry?
```

---

#### 4. Load Queue History

```dart
await queueService.loadQueueHistory('user-uuid');

final history = queueService.queueHistory; // List<QueueEntry>
```

---

## Real-time Updates

### Automatic Realtime Listening

The queue service automatically listens for updates on the current queue:

```dart
// Already implemented in QueueService
void _startQueueListener(String queueEntryId) {
  _queueRealtimeChannel = _supabase
      .channel('queue_$queueEntryId')
      .onPostgresChange(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'queue_entries',
        filter: 'id=eq.$queueEntryId',
        callback: (payload) {
          _currentQueueEntry = QueueEntry.fromJson(payload.newRecord);
          notifyListeners(); // Updates UI
        },
      )
      .subscribe();
}
```

---

## Geofencing API

### GeofencingService Methods

#### 1. Start Monitoring

```dart
final geofencingService = GeofencingService();

geofencingService.startMonitoring(
  targetLatitude: 28.6139,
  targetLongitude: 77.2090,
  geofenceName: 'Apollo Hospital',
);
```

**Features**:

- Continuous location polling (10-second intervals)
- 50-meter radius detection
- Local persistence via SharedPreferences
- Automatic notifications

---

#### 2. Register Callback

```dart
geofencingService.onGeofenceEvent((event) {
  switch (event.type) {
    case GeofenceEventType.entered:
      print('Entered ${event.name}');
      break;
    case GeofenceEventType.approaching:
      print('Approaching: ${event.distance}m away');
      break;
    default:
      break;
  }
});
```

---

#### 3. Stop Monitoring

```dart
await geofencingService.stopMonitoring();
```

---

## Admin API

### Admin-Only Operations

#### 1. Create Clinic (Admin only)

```dart
await Supabase.instance.client
    .from('clinics')
    .insert({
      'name': 'New Clinic',
      'address': '123 Main St',
      'latitude': 28.6139,
      'longitude': 77.2090,
      'wait_time_minutes': 15,
      'rating': 0.0,
      'admin_id': adminUserUuid,
    });
```

---

#### 2. Update Queue Status

```dart
await Supabase.instance.client
    .from('queue_entries')
    .update({
      'status': 'called', // or 'completed', 'cancelled'
      'updated_at': DateTime.now().toIso8601String(),
    })
    .eq('id', queueEntryUuid);
```

---

#### 3. Assign Admin Role

```dart
await Supabase.instance.client
    .from('users')
    .update({'role': 'admin'})
    .eq('email', 'admin@example.com');
```

---

## N8N Webhook Integration

### WebhookService Methods

#### 1. Trigger AI Call

```dart
import 'package:well_queue_2026/core/services/webhook_service.dart';

await WebhookService.triggerAICall(
  userName: 'John Doe',
  userPhone: '+1234567890',
  userEmail: 'john@example.com',
  clinicName: 'Apollo Hospital',
);
```

**Payload sent to N8N**:

```json
{
  "name": "John Doe",
  "phone": "+1234567890",
  "email": "john@example.com",
  "clinic": "Apollo Hospital",
  "action": "call_button_clicked",
  "timestamp": "2024-03-30T10:30:00.000Z"
}
```

---

#### 2. Book Appointment via AI

```dart
await WebhookService.bookAppointmentViaAI(
  userName: 'John Doe',
  userPhone: '+1234567890',
  userEmail: 'john@example.com',
  clinicName: 'Apollo Hospital',
  preferredTime: '2024-03-31T14:00:00',
);
```

---

#### 3. Send SMS Notification

```dart
await WebhookService.sendSmsNotification(
  phoneNumber: '+1234567890',
  message: 'Your queue position at Apollo is now 2. ETA: 10 minutes',
);
```

---

## Error Handling

All services include error handling and expose error messages:

```dart
try {
  final success = await authService.signUp(...);
  if (!success && authService.error != null) {
    print('Error: ${authService.error}');
  }
} catch (e) {
  print('Exception: $e');
}
```

---

## Performance Considerations

### Database Indexing

Indexes are automatically created on:

- `queue_entries(clinic_id, status)` - Fast queue filtering
- `users(email)` - Fast user lookup
- `clinics(latitude, longitude)` - Geospatial queries
- `appointments(clinic_id, user_id)` - Fast appointment lookup

### Caching

- Clinic list is cached in memory
- User profile cached in `SharedPreferences`
- Geofence data persisted locally

### Rate Limiting

- Location updates: 10-second intervals
- Queue polling: Real-time via WebSocket
- HTTP requests: Standard retry logic

---

## Security Best Practices

1. **Never** commit Supabase credentials to version control
2. Use RLS policies to enforce data access rules
3. All client SDK operations go through Supabase Auth context
4. Admin operations verified server-side via RLS policies
5. Location data should be sent over HTTPS only

---

## Troubleshooting

### Common Issues

**Database Connection Failed**

- Verify Supabase credentials in supabase_config.dart
- Check project is active in Supabase dashboard
- Verify network connectivity

**Real-time Updates Not Working**

- Enable Realtime in Supabase settings
- Check WebSocket connection status
- Verify RLS policies allow reads

**Location Permission Denied**

- iOS: Check Info.plist location descriptions
- Android: Verify AndroidManifest.xml permissions
- Request runtime permissions explicitly

**Queue Position Not Updated**

- Verify database transaction completed
- Check RLS policies allow updates
- Clear app cache and reinstall

---

## Code Examples

### Complete Queue Join Workflow

```dart
import 'package:provider/provider.dart';

// In UI widget
void joinClinicQueue(BuildContext context, Clinic clinic) async {
  final authService = context.read<AuthService>();
  final queueService = context.read<QueueService>();
  final geofencingService = context.read<GeofencingService>();

  if (authService.currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please login first')),
    );
    return;
  }

  // Join queue
  bool success = await queueService.joinQueue(
    clinicId: clinic.id,
    clinicName: clinic.name,
    userId: authService.currentUser!.id,
  );

  if (success) {
    // Start geofencing if enabled
    geofencingService.startMonitoring(
      targetLatitude: clinic.latitude,
      targetLongitude: clinic.longitude,
      geofenceName: clinic.name,
    );

    // Navigate to queue tracking
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const QueueCheckInScreen(),
    ));
  }
}
```

---

## API Versioning

Current API Version: **1.0.0**

Breaking changes will be announced with version updates.

---

## Support

For API documentation issues or questions:

- GitHub Issues: [Link to repo]
- Email: api-support@wellqueue.com
- Discord: [Link to discord]
