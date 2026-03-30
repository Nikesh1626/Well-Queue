# WellQueue - Quick Start Checklist

## ⚡ Get Started in 5 Steps

### Step 1: Prepare Supabase (5 minutes)

- [ ] Create Supabase project at https://supabase.com
- [ ] Copy Project URL and Anon Key
- [ ] Paste credentials in `lib/core/services/supabase_config.dart`:
  ```dart
  static const String supabaseUrl = 'https://YOUR-PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR-ANON-KEY';
  ```

### Step 2: Set Up Database (10 minutes)

- [ ] Open Supabase > SQL Editor
- [ ] Copy content of `supabase_schema_create_tables.sql`
- [ ] Execute in SQL Editor
- [ ] Copy content of `supabase_rls_policies.sql`
- [ ] Execute in SQL Editor
- [ ] Verify all tables created (View in Table Editor)

### Step 3: Install Dependencies (5 minutes)

```bash
cd well_queue_2026
flutter pub get
```

### Step 4: Run App (2 minutes)

```bash
flutter run
```

### Step 5: Test Features (10 minutes)

- [ ] **Sign Up**: Create test account
- [ ] **Verify**: Check user in Supabase users table
- [ ] **Add Test Clinic**: Insert clinic in Supabase (see Step 6 below)
- [ ] **View Clinics**: See test clinic appear in app
- [ ] **Test Admin Panel**: Update user role to admin

---

## 📋 Detailed Setup Guide

### Command Line Quick Reference

```bash
# Setup
flutter pub get

# Run
flutter run

# Clean build
flutter clean && flutter pub get && flutter run

# Build APK for Android
flutter build apk --release

# Build iOS
flutter build ios
```

---

### Add Test Clinic to Database

In Supabase > SQL Editor, run:

```sql
INSERT INTO clinics (
  name,
  address,
  latitude,
  longitude,
  wait_time_minutes,
  rating,
  services
) VALUES (
  'Apollo Hospital',
  '123 Main Street, New Delhi',
  28.6139,
  77.2090,
  15,
  4.5,
  ARRAY['General Medicine', 'Cardiology', 'Pediatrics']
);
```

---

### Create Admin User

In Supabase > SQL Editor, run:

```sql
UPDATE users
SET role = 'admin'
WHERE email = 'your-admin@example.com';
```

---

## 🔑 Key Files to Know

| File                                   | Purpose                      |
| -------------------------------------- | ---------------------------- |
| `lib/main.dart`                        | App entry point with routing |
| `lib/core/services/auth_service.dart`  | Authentication logic         |
| `lib/core/services/queue_service.dart` | Queue management             |
| `SUPABASE_SETUP.md`                    | Detailed setup instructions  |
| `API_DOCUMENTATION.md`                 | Complete API reference       |
| `supabase_schema_create_tables.sql`    | Database schema              |

---

## 🧪 Testing Checklist

### User Flows

- [ ] Sign Up → Profile Created → Can See Clinics
- [ ] Browse Clinics → See wait times
- [ ] Join Queue → Position shown
- [ ] Call AI Agent → Webhook triggered
- [ ] Track Position → Real-time updates

### Admin Flows

- [ ] Log in as Admin → See Admin Dashboard
- [ ] Add Clinic → Appears in user app
- [ ] View Queue → See all users
- [ ] Mark User Called → Queue updates
- [ ] Manage Users → See all registered users

---

## 🐛 Troubleshooting

### Build Fails

```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

### Location Not Working

1. Android:
   - Go to Settings > Apps > WellQueue > Permissions
   - Enable "Location"
2. iOS:
   - Settings > Privacy > Location Services > WellQueue (While Using)

### Database Errors

1. Check Supabase credentials in `supabase_config.dart`
2. Verify SQL scripts executed successfully
3. Check network connectivity
4. Try refreshing browser if in Supabase console

### Queue Not Real-time

1. Go to Supabase > Project Settings > Real-time
2. Ensure "Realtime" is enabled for `queue_entries` table

---

## 📱 Platform-Specific Steps

### Android

- [ ] Verify `android/app/src/main/AndroidManifest.xml` has permissions
- [ ] Test on Android 10+ device or emulator
- [ ] Build: `flutter build apk --release`

### iOS

- [ ] Add location descriptions to `ios/Runner/Info.plist`
- [ ] Test on iOS 13+ device or simulator
- [ ] Build: `flutter build ios`

---

## 🚀 Deployment Preparation

### Before Release

- [ ] Update `supabase_config.dart` with production credentials
- [ ] Test all features thoroughly
- [ ] Update version in `pubspec.yaml`
- [ ] Create release build
- [ ] Test on real devices

### Environment Setup

```bash
# For production, use environment variables (optional)
export SUPABASE_URL=production_url
export SUPABASE_ANON_KEY=production_key
```

---

## 📞 Support & Resources

- **Documentation**: See `SUPABASE_SETUP.md` and `API_DOCUMENTATION.md`
- **Supabase Docs**: https://supabase.com/docs
- **Flutter Docs**: https://flutter.dev/docs
- **Geolocator Package**: https://pub.dev/packages/geolocator

---

## 🎯 Success Criteria

You're done when:

- ✅ App runs without errors
- ✅ Can sign up and login
- ✅ Can see clinics in list
- ✅ Can join queue
- ✅ Admin can see dashboard
- ✅ Admin can manage clinics
- ✅ Real-time queue updates work

---

## 📊 Architecture at a Glance

```
┌─────────────┐
│   Flutter   │ UI Layer
│     App     │
└─────────────┘
      │ Provider
      ↓
┌─────────────────────────────┐
│   Services Layer            │
│ - AuthService              │
│ - QueueService             │
│ - ClinicService            │
│ - GeofencingService        │
└─────────────────────────────┘
      │ Supabase SDK
      ↓
┌─────────────────────────────┐
│   Supabase Backend          │ Database Layer
│ - PostgreSQL DB             │
│ - Auth                      │
│ - Realtime                  │
└─────────────────────────────┘
      │
      ↓
┌─────────────────────────────┐
│   External Services         │
│ - N8N (AI Calling)         │
│ - Google Maps (Optional)    │
└─────────────────────────────┘
```

---

## ✨ Quick Tips

1. **Hot Reload**: Press 'r' in terminal to hot reload while coding
2. **Debug Output**: Use `print()` for debugging
3. **Check Logs**: Use `flutter logs` to see app output
4. **Test Geofencing**: Use Android emulator's location mock
5. **Admin Testing**: Use Supabase console to directly update roles

---

## 📝 Next Phase Features

- [ ] Payment integration
- [ ] Video consultation
- [ ] Prescription delivery
- [ ] Medical records
- [ ] Insurance integration
- [ ] Multi-language support
- [ ] Advanced analytics

---

**Ready to go? Start with Step 1 above! 🚀**

Last updated: March 30, 2024
