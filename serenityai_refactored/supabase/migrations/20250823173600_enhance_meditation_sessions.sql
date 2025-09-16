-- Migration: Enhanced Meditation Sessions with Audio Support
-- Created: 2025-08-23
-- Description: Add audio URLs and metadata columns to existing meditation_sessions table

-- Add missing columns to existing meditation_sessions table
ALTER TABLE public.meditation_sessions
ADD COLUMN IF NOT EXISTS audio_url TEXT,
ADD COLUMN IF NOT EXISTS image_url TEXT,
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS instructor_name TEXT,
ADD COLUMN IF NOT EXISTS category TEXT,
ADD COLUMN IF NOT EXISTS difficulty_level INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS background_music TEXT,
ADD COLUMN IF NOT EXISTS session_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS average_rating NUMERIC(3,2) DEFAULT 0.0,
ADD COLUMN IF NOT EXISTS is_premium BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS tags TEXT[];

-- Add indexes for new columns
CREATE INDEX IF NOT EXISTS idx_meditation_sessions_category ON public.meditation_sessions(category);
CREATE INDEX IF NOT EXISTS idx_meditation_sessions_difficulty ON public.meditation_sessions(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_meditation_sessions_is_premium ON public.meditation_sessions(is_premium);
CREATE INDEX IF NOT EXISTS idx_meditation_sessions_rating ON public.meditation_sessions(average_rating DESC);

-- Update existing sample data with audio content
DO $$
DECLARE
    session_uuid UUID;
BEGIN
    -- Update existing sessions with audio content
    UPDATE public.meditation_sessions 
    SET 
        audio_url = CASE session_title
            WHEN 'Morning Mindfulness' THEN 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav'
            WHEN 'Breathing Exercise' THEN 'https://file-examples.com/storage/fe68c9fa69cffee2a80ae9f/2017/11/file_example_MP3_700KB.mp3'
            ELSE 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav'
        END,
        image_url = CASE session_title
            WHEN 'Morning Mindfulness' THEN 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3'
            WHEN 'Breathing Exercise' THEN 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3'
            ELSE 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3'
        END,
        description = CASE session_title
            WHEN 'Morning Mindfulness' THEN 'Start your day with calm awareness and focused breathing to set positive intentions.'
            WHEN 'Breathing Exercise' THEN 'Learn fundamental breathing techniques to reduce stress and increase focus.'
            ELSE 'A guided meditation session designed to help you find inner peace and relaxation.'
        END,
        instructor_name = CASE session_title
            WHEN 'Morning Mindfulness' THEN 'Dr. Sarah Chen'
            WHEN 'Breathing Exercise' THEN 'Michael Rodriguez'
            ELSE 'Dr. Sarah Chen'
        END,
        category = CASE meditation_type
            WHEN 'mindfulness' THEN 'Mindfulness'
            WHEN 'breathing' THEN 'Stress Relief'
            ELSE 'General'
        END,
        difficulty_level = CASE meditation_type
            WHEN 'mindfulness' THEN 2
            WHEN 'breathing' THEN 1
            ELSE 1
        END,
        background_music = 'Nature Sounds',
        session_count = CASE session_title
            WHEN 'Morning Mindfulness' THEN 1247
            WHEN 'Breathing Exercise' THEN 892
            ELSE 156
        END,
        average_rating = CASE session_title
            WHEN 'Morning Mindfulness' THEN 4.8
            WHEN 'Breathing Exercise' THEN 4.6
            ELSE 4.2
        END,
        is_premium = false,
        tags = CASE session_title
            WHEN 'Morning Mindfulness' THEN ARRAY['morning', 'mindfulness', 'awareness', 'focus']
            WHEN 'Breathing Exercise' THEN ARRAY['breathing', 'stress relief', 'beginner', 'anxiety']
            ELSE ARRAY['relaxation', 'peace', 'calm']
        END
    WHERE session_title IN ('Morning Mindfulness', 'Breathing Exercise');

    -- Add more sample meditation sessions with working audio
    INSERT INTO public.meditation_sessions (
        user_id, session_title, meditation_type, duration_seconds, session_status,
        completion_percentage, audio_url, image_url, description, instructor_name,
        category, difficulty_level, background_music, session_count, average_rating,
        is_premium, tags, created_at
    ) VALUES 
    (
        (SELECT user_id FROM public.meditation_sessions LIMIT 1),
        'Deep Sleep Relaxation',
        'sleep',
        1800, -- 30 minutes
        'completed'::public.session_status,
        100,
        'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
        'https://images.unsplash.com/photo-1520637836862-4d197d17c13a?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
        'A soothing guided meditation designed to help you fall into peaceful, restorative sleep.',
        'Dr. Lisa Thompson',
        'Sleep',
        1,
        'Rain Sounds',
        2156,
        4.9,
        false,
        ARRAY['sleep', 'relaxation', 'evening', 'calm'],
        CURRENT_TIMESTAMP
    ),
    (
        (SELECT user_id FROM public.meditation_sessions LIMIT 1),
        'Anxiety Relief Meditation',
        'anxiety',
        900, -- 15 minutes
        'completed'::public.session_status,
        85,
        'https://file-examples.com/storage/fe68c9fa69cffee2a80ae9f/2017/11/file_example_MP3_700KB.mp3',
        'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
        'Powerful techniques to manage anxiety and restore inner calm and confidence.',
        'James Wilson',
        'Stress Relief',
        2,
        'Ambient Sounds',
        967,
        4.7,
        false,
        ARRAY['anxiety', 'stress', 'calm', 'confidence'],
        CURRENT_TIMESTAMP
    ),
    (
        (SELECT user_id FROM public.meditation_sessions LIMIT 1),
        'Focus Enhancement',
        'focus',
        1200, -- 20 minutes
        'in_progress'::public.session_status,
        0,
        'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
        'Improve concentration and mental clarity with advanced mindfulness techniques.',
        'Dr. Sarah Chen',
        'Focus',
        3,
        'Binaural Beats',
        743,
        4.5,
        true,
        ARRAY['focus', 'concentration', 'productivity', 'advanced'],
        CURRENT_TIMESTAMP
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error updating meditation sessions: %', SQLERRM;
END $$;

-- Add function to get meditation library
CREATE OR REPLACE FUNCTION public.get_meditation_library(
    user_uuid UUID DEFAULT NULL,
    category_filter TEXT DEFAULT NULL,
    difficulty_filter INTEGER DEFAULT NULL
)
RETURNS TABLE(
    id UUID,
    session_title TEXT,
    instructor_name TEXT,
    description TEXT,
    audio_url TEXT,
    image_url TEXT,
    duration_seconds INTEGER,
    category TEXT,
    difficulty_level INTEGER,
    average_rating NUMERIC,
    session_count INTEGER,
    is_premium BOOLEAN,
    tags TEXT[],
    user_completed BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ms.id,
        ms.session_title,
        ms.instructor_name,
        ms.description,
        ms.audio_url,
        ms.image_url,
        ms.duration_seconds,
        ms.category,
        ms.difficulty_level,
        ms.average_rating,
        ms.session_count,
        ms.is_premium,
        ms.tags,
        CASE 
            WHEN user_uuid IS NOT NULL THEN
                EXISTS(
                    SELECT 1 FROM public.meditation_sessions user_sessions 
                    WHERE user_sessions.user_id = user_uuid 
                    AND user_sessions.session_title = ms.session_title
                    AND user_sessions.session_status = 'completed'::public.session_status
                )
            ELSE false
        END as user_completed
    FROM public.meditation_sessions ms
    WHERE 
        (category_filter IS NULL OR ms.category = category_filter)
        AND (difficulty_filter IS NULL OR ms.difficulty_level = difficulty_filter)
        AND ms.audio_url IS NOT NULL
    GROUP BY ms.id, ms.session_title, ms.instructor_name, ms.description, 
             ms.audio_url, ms.image_url, ms.duration_seconds, ms.category,
             ms.difficulty_level, ms.average_rating, ms.session_count, 
             ms.is_premium, ms.tags
    ORDER BY ms.average_rating DESC, ms.session_count DESC;
END;
$$;

-- Add function to get specific meditation session
CREATE OR REPLACE FUNCTION public.get_meditation_session(session_id UUID)
RETURNS TABLE(
    id UUID,
    session_title TEXT,
    instructor_name TEXT,
    description TEXT,
    audio_url TEXT,
    image_url TEXT,
    duration_seconds INTEGER,
    category TEXT,
    difficulty_level INTEGER,
    background_music TEXT,
    average_rating NUMERIC,
    session_count INTEGER,
    is_premium BOOLEAN,
    tags TEXT[]
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ms.id,
        ms.session_title,
        ms.instructor_name,
        ms.description,
        ms.audio_url,
        ms.image_url,
        ms.duration_seconds,
        ms.category,
        ms.difficulty_level,
        ms.background_music,
        ms.average_rating,
        ms.session_count,
        ms.is_premium,
        ms.tags
    FROM public.meditation_sessions ms
    WHERE ms.id = session_id
    AND ms.audio_url IS NOT NULL
    LIMIT 1;
END;
$$;