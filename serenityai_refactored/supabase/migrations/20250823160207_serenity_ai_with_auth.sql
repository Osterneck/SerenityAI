-- Location: supabase/migrations/20250823160207_serenity_ai_with_auth.sql
-- Schema Analysis: Fresh project - no existing schema
-- Integration Type: Complete authentication system for mental wellness app
-- Dependencies: none - creating new schema

-- 1. Types and Core Tables
CREATE TYPE public.user_role AS ENUM ('user', 'therapist', 'admin');
CREATE TYPE public.mood_level AS ENUM ('very_poor', 'poor', 'neutral', 'good', 'excellent');
CREATE TYPE public.session_status AS ENUM ('completed', 'in_progress', 'paused');

-- Critical intermediary table for auth
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'user'::public.user_role,
    avatar_url TEXT,
    date_of_birth DATE,
    timezone TEXT DEFAULT 'UTC',
    preferred_meditation_duration INTEGER DEFAULT 300, -- 5 minutes in seconds
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Mood tracking table
CREATE TABLE public.mood_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    mood_level public.mood_level NOT NULL,
    notes TEXT,
    emotion_tags TEXT[] DEFAULT '{}',
    energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 10),
    stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 10),
    sleep_hours DECIMAL(3,1),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Meditation sessions table
CREATE TABLE public.meditation_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    session_title TEXT NOT NULL,
    duration_seconds INTEGER NOT NULL,
    completion_percentage INTEGER DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    session_status public.session_status DEFAULT 'completed'::public.session_status,
    meditation_type TEXT, -- e.g., 'mindfulness', 'breathing', 'body_scan'
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User preferences table
CREATE TABLE public.user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    daily_goal_minutes INTEGER DEFAULT 10,
    reminder_enabled BOOLEAN DEFAULT true,
    reminder_time TIME DEFAULT '09:00:00',
    notification_settings JSONB DEFAULT '{"mood_reminders": true, "meditation_reminders": true, "weekly_summary": true}'::jsonb,
    theme_preference TEXT DEFAULT 'light',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_mood_entries_user_id ON public.mood_entries(user_id);
CREATE INDEX idx_mood_entries_created_at ON public.mood_entries(created_at DESC);
CREATE INDEX idx_meditation_sessions_user_id ON public.meditation_sessions(user_id);
CREATE INDEX idx_meditation_sessions_created_at ON public.meditation_sessions(created_at DESC);
CREATE INDEX idx_user_preferences_user_id ON public.user_preferences(user_id);

-- 3. Functions for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'user')::public.user_role
  );
  
  -- Create default preferences
  INSERT INTO public.user_preferences (user_id)
  VALUES (NEW.id);
  
  RETURN NEW;
END;
$$;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 4. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mood_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meditation_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies using correct patterns

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for mood entries
CREATE POLICY "users_manage_own_mood_entries"
ON public.mood_entries
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for meditation sessions
CREATE POLICY "users_manage_own_meditation_sessions"
ON public.meditation_sessions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for user preferences
CREATE POLICY "users_manage_own_user_preferences"
ON public.user_preferences
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 6. Triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at
  BEFORE UPDATE ON public.user_preferences
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 7. Complete Mock Data for testing
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    mood_entry_id UUID := gen_random_uuid();
    session_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@serenityai.com', crypt('SecurePass123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "SerenityAI Admin", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@serenityai.com', crypt('WellnessUser123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Wellness Seeker", "role": "user"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Sample mood entries
    INSERT INTO public.mood_entries (id, user_id, mood_level, notes, emotion_tags, energy_level, stress_level, sleep_hours) VALUES
        (gen_random_uuid(), user_uuid, 'good'::public.mood_level, 'Feeling positive after morning meditation', ARRAY['calm', 'focused'], 7, 3, 7.5),
        (gen_random_uuid(), user_uuid, 'neutral'::public.mood_level, 'Regular day, nothing special', ARRAY['neutral'], 5, 5, 6.0);

    -- Sample meditation sessions
    INSERT INTO public.meditation_sessions (id, user_id, session_title, duration_seconds, completion_percentage, meditation_type) VALUES
        (gen_random_uuid(), user_uuid, 'Morning Mindfulness', 600, 100, 'mindfulness'),
        (gen_random_uuid(), user_uuid, 'Breathing Exercise', 300, 80, 'breathing');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 8. Helper functions for app functionality
CREATE OR REPLACE FUNCTION public.get_user_mood_stats(user_uuid UUID)
RETURNS TABLE(
    avg_mood_level DECIMAL,
    total_entries INTEGER,
    this_week_entries INTEGER
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    CASE 
        WHEN AVG(CASE mood_level 
            WHEN 'very_poor' THEN 1
            WHEN 'poor' THEN 2
            WHEN 'neutral' THEN 3
            WHEN 'good' THEN 4
            WHEN 'excellent' THEN 5
        END) IS NULL THEN 0.0
        ELSE ROUND(AVG(CASE mood_level 
            WHEN 'very_poor' THEN 1
            WHEN 'poor' THEN 2
            WHEN 'neutral' THEN 3
            WHEN 'good' THEN 4
            WHEN 'excellent' THEN 5
        END), 2)
    END as avg_mood_level,
    COUNT(*)::INTEGER as total_entries,
    COUNT(CASE WHEN created_at >= date_trunc('week', CURRENT_TIMESTAMP) THEN 1 END)::INTEGER as this_week_entries
FROM public.mood_entries 
WHERE user_id = user_uuid;
$$;

-- Cleanup function for development
CREATE OR REPLACE FUNCTION public.cleanup_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get test user IDs
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%@serenityai.com';

    -- Delete in dependency order
    DELETE FROM public.user_preferences WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.meditation_sessions WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.mood_entries WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;