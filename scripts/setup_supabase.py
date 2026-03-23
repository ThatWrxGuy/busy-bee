#!/usr/bin/env python3
"""
Supabase Database Setup for BusyBee Life OS
Creates schema for all 12 life domains + gamification
"""

import os
from supabase import create_client, Client

SUPABASE_URL = "https://vvqxvjwvnilgxqekxvio.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2cXh2and2bmlsZ3hxZWt4dmlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNzYzMzksImV4cCI6MjA4OTg1MjMzOX0.HNVGShYCnJTslEbZaKzS1M--0x8aLAMHiueA7BNsDkI"

def create_tables(client: Client):
    """Create all database tables"""
    
    # Enable UUID extension
    client.sql("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"")
    
    # ==================== USERS & PROFILES ====================
    
    # Profiles table (extends auth.users)
    client.sql("""
        CREATE TABLE IF NOT EXISTS profiles (
            id UUID REFERENCES auth.users(id) PRIMARY KEY,
            username TEXT UNIQUE,
            display_name TEXT,
            avatar_url TEXT,
            xp INTEGER DEFAULT 0,
            level INTEGER DEFAULT 1,
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # ==================== LIFE DOMAINS ====================
    
    # Health Domain
    client.sql("""
        CREATE TABLE IF NOT EXISTS health_entries (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            date DATE DEFAULT CURRENT_DATE,
            workout_type TEXT,
            workout_duration INTEGER,
            sleep_hours DECIMAL,
            sleep_quality INTEGER,
            nutrition_notes TEXT,
            vitals_bpm INTEGER,
            vitals_bp_systolic INTEGER,
            vitals_bp_diastolic INTEGER,
            weight DECIMAL,
            notes TEXT,
            created_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # Career Domain
    client.sql("""
        CREATE TABLE IF NOT EXISTS career_entries (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            date DATE DEFAULT CURRENT_DATE,
            job_title TEXT,
            company TEXT,
            status TEXT CHECK (status IN ('applied', 'interview', 'offer', 'rejected', 'accepted')),
            interview_date DATE,
            notes TEXT,
            created_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # Finance Domain
    client.sql("""
        CREATE TABLE IF NOT EXISTS finance_entries (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            date DATE DEFAULT CURRENT_DATE,
            transaction_type TEXT CHECK (transaction_type IN ('income', 'expense', 'investment', 'savings')),
            category TEXT,
            amount DECIMAL,
            description TEXT,
            account_name TEXT,
            created_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # Goals Domain
    client.sql("""
        CREATE TABLE IF NOT EXISTS goals (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT,
            target_date DATE,
            progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
            status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # Goal Milestones
    client.sql("""
        CREATE TABLE IF NOT EXISTS goal_milestones (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            goal_id UUID REFERENCES goals(id) ON DELETE CASCADE,
            title TEXT NOT NULL,
            completed BOOLEAN DEFAULT FALSE,
            due_date DATE,
            created_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # Habits Domain
    client.sql("""
        CREATE TABLE IF NOT EXISTS habits (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            name TEXT NOT NULL,
            description TEXT,
            frequency TEXT DEFAULT 'daily' CHECK (frequency IN ('daily', 'weekly', 'monthly')),
            category TEXT,
            streak INTEGER DEFAULT 0,
            created_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # Habit Completions
    client.sql("""
        CREATE TABLE IF NOT EXISTS habit_completions (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            habit_id UUID REFERENCES habits(id) ON DELETE CASCADE,
            completed_date DATE DEFAULT CURRENT_DATE,
            created_at TIMESTAMPTZ DEFAULT NOW(),
            UNIQUE(habit_id, completed_date)
        )
    """)
    
    # Mindset Domain
    client.sql("""
        CREATE TABLE IF NOT EXISTS mindset_entries (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            date DATE DEFAULT CURRENT_DATE,
            entry_type TEXT CHECK (entry_type IN ('affirmation', 'meditation', 'journal', 'visualization')),
            duration_minutes INTEGER,
            content TEXT,
            mood_before INTEGER,
            mood_after INTEGER,
            created_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # Relationships Domain
    client.sql("""
        CREATE TABLE IF NOT EXISTS relationships (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            name TEXT NOT NULL,
            relationship_type TEXT CHECK (relationship_type IN ('friend', 'family', 'colleague', 'partner', 'other')),
            contact_frequency TEXT,
            last_contact_date DATE,
            notes TEXT,
            birthday DATE,
            created_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # Education Domain
    client.sql("""
        CREATE TABLE IF NOT EXISTS education_entries (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            date DATE DEFAULT CURRENT_DATE,
            title TEXT NOT NULL,
            type TEXT CHECK (type IN ('course', 'certification', 'book', 'study_session', 'other')),
            provider TEXT,
            status TEXT DEFAULT 'in_progress' CHECK (status IN ('not_started', 'in_progress', 'completed')),
            progress INTEGER DEFAULT 0,
            hours_spent DECIMAL DEFAULT 0,
            notes TEXT,
            created_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # Spirituality Domain
    client.sql("""
        CREATE TABLE IF NOT EXISTS spirituality_entries (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            date DATE DEFAULT CURRENT_DATE,
            practice_type TEXT,
            duration_minutes INTEGER,
            gratitude_list TEXT,
            values_reflected TEXT,
            notes TEXT,
            created_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # Family Domain
    client.sql("""
        CREATE TABLE IF NOT EXISTS family_members (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            name TEXT NOT NULL,
            relationship TEXT,
            birthday DATE,
            milestones TEXT,
            time_spent_hours DECIMAL DEFAULT 0,
            notes TEXT,
            created_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # Recreation Domain
    client.sql("""
        CREATE TABLE IF NOT EXISTS recreation_entries (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            date DATE DEFAULT CURRENT_DATE,
            activity_type TEXT,
            name TEXT,
            duration_hours DECIMAL,
            enjoyment_rating INTEGER,
            bucket_list BOOLEAN DEFAULT FALSE,
            notes TEXT,
            created_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # Travel Domain
    client.sql("""
        CREATE TABLE IF NOT EXISTS travel_entries (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            destination TEXT NOT NULL,
            start_date DATE,
            end_date DATE,
            status TEXT DEFAULT 'planned' CHECK (status IN ('planned', 'completed', 'cancelled')),
            bucket_list BOOLEAN DEFAULT FALSE,
            itinerary TEXT,
            notes TEXT,
            created_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # ==================== GAMIFICATION ====================
    
    # Achievements
    client.sql("""
        CREATE TABLE IF NOT EXISTS achievements (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            category TEXT CHECK (category IN ('finance', 'goals', 'health', 'habits', 'relationships', 'general')),
            xp_reward INTEGER DEFAULT 0,
            icon TEXT,
            requirement_json JSONB
        )
    """)
    
    # User Achievements
    client.sql("""
        CREATE TABLE IF NOT EXISTS user_achievements (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            achievement_id UUID REFERENCES achievements(id),
            unlocked_at TIMESTAMPTZ DEFAULT NOW(),
            UNIQUE(user_id, achievement_id)
        )
    """)
    
    # Leaderboard
    client.sql("""
        CREATE TABLE IF NOT EXISTS leaderboard_entries (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            period TEXT CHECK (period IN ('weekly', 'monthly', 'all_time')),
            xp INTEGER DEFAULT 0,
            rank INTEGER,
            updated_at TIMESTAMPTZ DEFAULT NOW()
        )
    """)
    
    # ==================== SETUP COMPLETE ====================
    print("✅ All tables created successfully!")
    print("\n📊 Tables created:")
    print("  - profiles")
    print("  - health_entries")
    print("  - career_entries")
    print("  - finance_entries")
    print("  - goals + goal_milestones")
    print("  - habits + habit_completions")
    print("  - mindset_entries")
    print("  - relationships")
    print("  - education_entries")
    print("  - spirituality_entries")
    print("  - family_members")
    print("  - recreation_entries")
    print("  - travel_entries")
    print("  - achievements + user_achievements")
    print("  - leaderboard_entries")


if __name__ == "__main__":
    client = create_client(SUPABASE_URL, SUPABASE_KEY)
    create_tables(client)
