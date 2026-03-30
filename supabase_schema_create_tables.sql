-- WellQueue Supabase Database Schema
-- Run this script in Supabase SQL Editor to create all tables

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone VARCHAR(20),
  age INTEGER,
  role VARCHAR(50) DEFAULT 'user' CHECK (role IN ('user', 'admin', 'clinic_manager', 'super_admin')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Clinics Table
CREATE TABLE IF NOT EXISTS clinics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  latitude NUMERIC(10, 8) NOT NULL,
  longitude NUMERIC(11, 8) NOT NULL,
  wait_time_minutes INTEGER DEFAULT 0,
  rating NUMERIC(3, 2) DEFAULT 0,
  services TEXT[] DEFAULT ARRAY[]::TEXT[],
  image_url VARCHAR(500),
  phone VARCHAR(20),
  email VARCHAR(255),
  admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Queue Entries Table
CREATE TABLE IF NOT EXISTS queue_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
  clinic_name VARCHAR(255) NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  user_target_position INTEGER NOT NULL,
  status VARCHAR(50) DEFAULT 'waiting' CHECK (status IN ('waiting', 'confirmed', 'called', 'completed', 'cancelled')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  estimated_wait_minutes INTEGER DEFAULT 0,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Queue Updates Table (for tracking status changes)
CREATE TABLE IF NOT EXISTS queue_updates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  queue_entry_id UUID NOT NULL REFERENCES queue_entries(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  type VARCHAR(50),
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Admin Users Table (for clinic managers)
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  clinic_id UUID REFERENCES clinics(id) ON DELETE CASCADE,
  role VARCHAR(50) CHECK (role IN ('manager', 'super_admin')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Clinic Services Table (normalized services)
CREATE TABLE IF NOT EXISTS clinic_services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
  service_name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Appointments Table (for future appointment booking)
CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  appointment_time TIMESTAMP WITH TIME ZONE NOT NULL,
  status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled', 'no_show')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_queue_entries_clinic_status ON queue_entries(clinic_id, status);
CREATE INDEX IF NOT EXISTS idx_queue_entries_user_id ON queue_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_clinics_location
  ON clinics USING GIST (ll_to_earth(latitude::double precision, longitude::double precision));
CREATE INDEX IF NOT EXISTS idx_appointments_clinic_user ON appointments(clinic_id, user_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Create comments for documentation
COMMENT ON TABLE users IS 'Stores user account information and roles';
COMMENT ON TABLE clinics IS 'Stores clinic/hospital information with location';
COMMENT ON TABLE queue_entries IS 'Tracks user queue positions at clinics';
COMMENT ON TABLE queue_updates IS 'Tracks queue status updates and notifications';
COMMENT ON TABLE appointments IS 'Stores appointment bookings';

COMMENT ON COLUMN users.role IS 'User role: user, admin, clinic_manager, super_admin';
COMMENT ON COLUMN queue_entries.status IS 'Queue status: waiting, confirmed, called, completed, cancelled';
COMMENT ON COLUMN appointments.status IS 'Appointment status: scheduled, completed, cancelled, no_show';
