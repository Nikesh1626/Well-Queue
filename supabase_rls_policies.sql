-- WellQueue Supabase Row-Level Security (RLS) Policies
-- Run this script to set up security policies

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinics ENABLE ROW LEVEL SECURITY;
ALTER TABLE queue_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE queue_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinic_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- ============== USERS TABLE POLICIES ==============

-- Users can view their own profile
CREATE POLICY "Users can view their own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Users can view all other users (for directory/listing)
CREATE POLICY "Users can view all users"
  ON users FOR SELECT
  USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- System can insert new users during signup
CREATE POLICY "System can insert new users"
  ON users FOR INSERT
  WITH CHECK (true);

-- ============== CLINICS TABLE POLICIES ==============

-- Everyone can view all clinics
CREATE POLICY "Everyone can view clinics"
  ON clinics FOR SELECT
  USING (true);

-- Admins can create clinics
CREATE POLICY "Admins can create clinics"
  ON clinics FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  );

-- Clinic managers can update their own clinics
CREATE POLICY "Clinic managers can update their clinics"
  ON clinics FOR UPDATE
  USING (
    admin_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  );

-- Admins can delete clinics
CREATE POLICY "Admins can delete clinics"
  ON clinics FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  );

-- ============== QUEUE ENTRIES TABLE POLICIES ==============

-- Users can view their own queue entries
CREATE POLICY "Users can view their own queues"
  ON queue_entries FOR SELECT
  USING (auth.uid() = user_id);

-- Clinic managers can view queues for their clinics
CREATE POLICY "Clinic managers can view their clinic queues"
  ON queue_entries FOR SELECT
  USING (
    clinic_id IN (
      SELECT id FROM clinics WHERE admin_id = auth.uid()
    ) OR 
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  );

-- Users can create queue entries
CREATE POLICY "Users can join queue"
  ON queue_entries FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can cancel their own queue entries
CREATE POLICY "Users can cancel their own queues"
  ON queue_entries FOR UPDATE
  USING (auth.uid() = user_id);

-- Clinic managers can update queue status
CREATE POLICY "Clinic managers can manage queue status"
  ON queue_entries FOR UPDATE
  USING (
    clinic_id IN (
      SELECT id FROM clinics WHERE admin_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  );

-- ============== QUEUE UPDATES TABLE POLICIES ==============

-- Users can view updates for their queue entries
CREATE POLICY "Users can view their queue updates"
  ON queue_updates FOR SELECT
  USING (
    queue_entry_id IN (
      SELECT id FROM queue_entries WHERE user_id = auth.uid()
    )
  );

-- Clinic managers can view updates for their clinic queues
CREATE POLICY "Clinic managers can view queue updates"
  ON queue_updates FOR SELECT
  USING (
    queue_entry_id IN (
      SELECT id FROM queue_entries
      WHERE clinic_id IN (
        SELECT id FROM clinics WHERE admin_id = auth.uid()
      )
    ) OR
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  );

-- System can insert queue updates
CREATE POLICY "System can insert queue updates"
  ON queue_updates FOR INSERT
  WITH CHECK (true);

-- ============== APPOINTMENTS TABLE POLICIES ==============

-- Users can view their own appointments
CREATE POLICY "Users can view their appointments"
  ON appointments FOR SELECT
  USING (auth.uid() = user_id);

-- Users can create appointments
CREATE POLICY "Users can create appointments"
  ON appointments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own appointments
CREATE POLICY "Users can update their appointments"
  ON appointments FOR UPDATE
  USING (auth.uid() = user_id);

-- Clinic managers can view appointments for their clinics
CREATE POLICY "Clinic managers can view clinic appointments"
  ON appointments FOR SELECT
  USING (
    clinic_id IN (
      SELECT id FROM clinics WHERE admin_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  );

-- ============== ADMIN_USERS TABLE POLICIES ==============

-- Admins can view admin assignments
CREATE POLICY "Admins can view admin users"
  ON admin_users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  );

-- Admins can assign clinic managers
CREATE POLICY "Admins can create admin assignments"
  ON admin_users FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  );

-- ============== CLINIC_SERVICES TABLE POLICIES ==============

-- Everyone can view clinic services
CREATE POLICY "Everyone can view clinic services"
  ON clinic_services FOR SELECT
  USING (true);

-- Clinic managers can manage their services
CREATE POLICY "Clinic managers can manage services"
  ON clinic_services FOR INSERT
  WITH CHECK (
    clinic_id IN (
      SELECT id FROM clinics WHERE admin_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  );

-- Grant appropriate permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;
