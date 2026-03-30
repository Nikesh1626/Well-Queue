/// Supabase Database Schema Constants
/// Defines all table names and column names for consistency

class SupabaseSchema {
  // Table Names
  static const String usersTable = 'users';
  static const String clinicsTable = 'clinics';
  static const String queueEntriesTable = 'queue_entries';
  static const String queueUpdatesTable = 'queue_updates';
  static const String adminUsersTable = 'admin_users';
  static const String clinicServicesTable = 'clinic_services';
  static const String appointmentsTable = 'appointments';

  // User Table Columns
  static const String userId = 'id';
  static const String userEmail = 'email';
  static const String userFirstName = 'first_name';
  static const String userLastName = 'last_name';
  static const String userPhone = 'phone';
  static const String userAge = 'age';
  static const String userRole = 'role';
  static const String userCreatedAt = 'created_at';
  static const String userUpdatedAt = 'updated_at';

  // Clinic Table Columns
  static const String clinicId = 'id';
  static const String clinicName = 'name';
  static const String clinicAddress = 'address';
  static const String clinicLatitude = 'latitude';
  static const String clinicLongitude = 'longitude';
  static const String clinicWaitTime = 'wait_time_minutes';
  static const String clinicRating = 'rating';
  static const String clinicImageUrl = 'image_url';
  static const String clinicPhone = 'phone';
  static const String clinicEmail = 'email';
  static const String clinicCreatedAt = 'created_at';
  static const String clinicUpdatedAt = 'updated_at';
  static const String clinicAdminId = 'admin_id';

  // Queue Entry Table Columns
  static const String queueId = 'id';
  static const String queueClinicId = 'clinic_id';
  static const String queueClinicName = 'clinic_name';
  static const String queueUserId = 'user_id';
  static const String queuePosition = 'position';
  static const String queueUserTargetPosition = 'user_target_position';
  static const String queueStatus = 'status';
  static const String queueJoinedAt = 'joined_at';
  static const String queueEstimatedWait = 'estimated_wait_minutes';
  static const String queueCompletedAt = 'completed_at';
  static const String queueCreatedAt = 'created_at';
  static const String queueUpdatedAt = 'updated_at';

  // Admin User Table Columns
  static const String adminId = 'id';
  static const String adminUserId = 'user_id';
  static const String adminClinicId = 'clinic_id';
  static const String adminRole = 'role'; // 'manager', 'super_admin'
  static const String adminCreatedAt = 'created_at';
  static const String adminUpdatedAt = 'updated_at';

  // User Roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  static const String roleClinicManager = 'clinic_manager';
  static const String roleSuperAdmin = 'super_admin';

  // Queue Statuses
  static const String statusWaiting = 'waiting';
  static const String statusConfirmed = 'confirmed';
  static const String statusCalled = 'called';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
}
