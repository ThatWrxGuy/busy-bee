-- =====================================================
-- 🐝 BUSYBEE LIFE OS - COMPLETE DATABASE SCHEMA
-- Master SQL File - Run this in Supabase SQL Editor
-- =====================================================

-- =====================================================
-- PART 1: EXTENSIONS & BASE TABLES
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- USERS & PROFILES
-- =====================================================

CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    username TEXT UNIQUE,
    display_name TEXT,
    avatar_url TEXT,
    xp INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- LIFE DOMAIN: HEALTH
-- =====================================================
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
);

-- =====================================================
-- LIFE DOMAIN: CAREER
-- =====================================================
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
);

-- =====================================================
-- LIFE DOMAIN: FINANCE
-- =====================================================
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
);

-- =====================================================
-- LIFE DOMAIN: GOALS
-- =====================================================
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
);

CREATE TABLE IF NOT EXISTS goal_milestones (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    goal_id UUID REFERENCES goals(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    due_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- LIFE DOMAIN: HABITS
-- =====================================================
CREATE TABLE IF NOT EXISTS habits (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    frequency TEXT DEFAULT 'daily' CHECK (frequency IN ('daily', 'weekly', 'monthly')),
    category TEXT,
    streak INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS habit_completions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    habit_id UUID REFERENCES habits(id) ON DELETE CASCADE,
    completed_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(habit_id, completed_date)
);

-- =====================================================
-- LIFE DOMAIN: MINDSET
-- =====================================================
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
);

-- =====================================================
-- LIFE DOMAIN: RELATIONSHIPS
-- =====================================================
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
);

-- =====================================================
-- LIFE DOMAIN: EDUCATION
-- =====================================================
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
);

-- =====================================================
-- LIFE DOMAIN: SPIRITUALITY
-- =====================================================
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
);

-- =====================================================
-- LIFE DOMAIN: FAMILY
-- =====================================================
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
);

-- =====================================================
-- LIFE DOMAIN: RECREATION
-- =====================================================
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
);

-- =====================================================
-- LIFE DOMAIN: TRAVEL
-- =====================================================
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
);

-- =====================================================
-- GAMIFICATION: ACHIEVEMENTS
-- =====================================================
CREATE TABLE IF NOT EXISTS achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT CHECK (category IN ('finance', 'goals', 'health', 'habits', 'relationships', 'general')),
    xp_reward INTEGER DEFAULT 0,
    icon TEXT,
    requirement_json JSONB
);

CREATE TABLE IF NOT EXISTS user_achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES achievements(id),
    unlocked_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- =====================================================
-- GAMIFICATION: LEADERBOARD
-- =====================================================
CREATE TABLE IF NOT EXISTS leaderboard_entries (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    period TEXT CHECK (period IN ('weekly', 'monthly', 'all_time')),
    xp INTEGER DEFAULT 0,
    rank INTEGER,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- GAMIFICATION: LEVEL DEFINITIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS level_definitions (
    level INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    xp_required INTEGER NOT NULL,
    total_xp INTEGER NOT NULL,
    unlock_features JSONB DEFAULT '[]',
    profile_frame TEXT
);

-- Insert 16 levels (Newcomer → Transcendent)
INSERT INTO level_definitions (level, title, xp_required, total_xp, unlock_features, profile_frame) VALUES
(1, 'Newcomer', 0, 0, '["basic_tracking"]', '🥉 Bronze'),
(2, 'Beginner', 1000, 1000, '["basic_tracking", "habits"]', '🥉 Bronze'),
(3, 'Explorer', 2500, 3500, '["basic_tracking", "habits", "goals"]', '🥈 Silver'),
(4, 'Adventurer', 5000, 8500, '["basic_tracking", "habits", "goals", "notes"]', '🥈 Silver'),
(5, 'Achiever', 10000, 18500, '["basic_tracking", "habits", "goals", "notes", "achievements"]', '🥈 Silver'),
(6, 'Champion', 17500, 36000, '["all_basic", "leaderboard_view"]', '🥇 Gold'),
(7, 'Warrior', 27500, 63500, '["all_basic", "leaderboard_view", "advanced_analytics"]', '🥇 Gold'),
(8, 'Elite', 40000, 103500, '["all_basic", "leaderboard", "analytics", "export"]', '🥇 Gold'),
(9, 'Master', 55000, 158500, '["all_features", "themes"]', '💎 Diamond'),
(10, 'Grandmaster', 75000, 233500, '["all_features", "themes", "api_access"]', '💎 Diamond'),
(11, 'Legend', 100000, 333500, '["all_features", "custom_achievements"]', '💎 Diamond'),
(12, 'Mythic', 130000, 463500, '["all_features", "priority_support"]', '🔮 Mythic'),
(13, 'Transcendent', 165000, 628500, '["all_features", "beta_access"]', '🔮 Mythic'),
(14, 'Celestial', 200000, 828500, '["all_features", "lifetime_access"]', '🌟 Celestial'),
(15, 'Divine', 250000, 1078500, '["all_features", "founder_badge"]', '🌟 Divine'),
(16, 'Transcendent', 300000, 1378500, '["all_features", "legacy_badge"]', '🐝 Busy Bee Legend');

-- =====================================================
-- GAMIFICATION: REWARDS
-- =====================================================
CREATE TABLE IF NOT EXISTS rewards (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    reward_type TEXT CHECK (reward_type IN ('badge', 'frame', 'feature', 'theme', 'title')),
    icon TEXT,
    unlock_level INTEGER REFERENCES level_definitions(level),
    xp_cost INTEGER DEFAULT 0
);

-- Seed rewards
INSERT INTO rewards (name, description, reward_type, icon, unlock_level) VALUES
('Bronze Frame', 'Bronze profile frame', 'frame', '🥉', 1),
('Silver Frame', 'Silver profile frame', 'frame', '🥈', 4),
('Gold Frame', 'Gold profile frame', 'frame', '🥇', 8),
('Diamond Frame', 'Diamond profile frame', 'frame', '💎', 10),
('Mythic Frame', 'Mythic profile frame', 'frame', '🔮', 12),
('Celestial Frame', 'Celestial profile frame', 'frame', '🌟', 14),
('Newcomer', 'Newcomer title', 'title', '🌱', 1),
('Explorer', 'Explorer title', 'title', '🧭', 3),
('Champion', 'Champion title', 'title', '🏆', 6),
('Legend', 'Legend title', 'title', '📜', 11),
('Transcendent', 'Transcendent title', 'title', '🐝', 16),
('Achievements Unlocked', 'Unlock achievements system', 'feature', '🎖️', 5),
('Leaderboard Access', 'View leaderboards', 'feature', '📊', 6),
('Advanced Analytics', 'Deep insights & charts', 'feature', '📈', 7),
('Data Export', 'Export your data', 'feature', '📤', 8),
('Custom Themes', 'Customize app theme', 'feature', '🎨', 9),
('API Access', 'Developer API access', 'feature', '🔌', 10),
('Custom Achievements', 'Create custom achievements', 'feature', '✨', 11),
('Priority Support', 'Priority support access', 'feature', '💬', 12),
('Beta Access', 'Early access to new features', 'feature', '🧪', 13),
('Lifetime Access', 'Lifetime premium features', 'feature', '♾️', 14),
('Founder Badge', 'Founder badge on profile', 'badge', '🏛️', 15),
('Legacy Badge', 'Legacy status badge', 'badge', '📯', 16);

CREATE TABLE IF NOT EXISTS user_rewards (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    reward_id UUID REFERENCES rewards(id),
    unlocked_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, reward_id)
);

-- =====================================================
-- PART 2: STORAGE BUCKETS
-- =====================================================

-- Note: Supabase storage schema may vary by version. Using core columns.
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('uploads', 'uploads', true)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- PART 3: AUTH TRIGGERS
-- =====================================================

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, username, display_name, avatar_url, xp, level)
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data->>'username',
        NEW.raw_user_meta_data->>'display_name',
        NEW.raw_user_meta_data->>'avatar_url',
        0,
        1
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- PART 4: ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE career_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE mindset_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE education_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE spirituality_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE recreation_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE travel_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE level_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_rewards ENABLE ROW LEVEL SECURITY;

-- ==================== PROFILES ====================
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- ==================== HEALTH ====================
CREATE POLICY "Users can view own health" ON health_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own health" ON health_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own health" ON health_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own health" ON health_entries FOR DELETE USING (auth.uid() = user_id);

-- ==================== CAREER ====================
CREATE POLICY "Users can view own career" ON career_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own career" ON career_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own career" ON career_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own career" ON career_entries FOR DELETE USING (auth.uid() = user_id);

-- ==================== FINANCE ====================
CREATE POLICY "Users can view own finance" ON finance_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own finance" ON finance_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own finance" ON finance_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own finance" ON finance_entries FOR DELETE USING (auth.uid() = user_id);

-- ==================== GOALS ====================
CREATE POLICY "Users can view own goals" ON goals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own goals" ON goals FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own goals" ON goals FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own goals" ON goals FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own milestones" ON goal_milestones FOR SELECT USING (
    auth.uid() = (SELECT user_id FROM goals WHERE id = goal_milestones.goal_id)
);
CREATE POLICY "Users can insert own milestones" ON goal_milestones FOR INSERT WITH CHECK (
    auth.uid() = (SELECT user_id FROM goals WHERE id = goal_milestones.goal_id)
);
CREATE POLICY "Users can update own milestones" ON goal_milestones FOR UPDATE USING (
    auth.uid() = (SELECT user_id FROM goals WHERE id = goal_milestones.goal_id)
);
CREATE POLICY "Users can delete own milestones" ON goal_milestones FOR DELETE USING (
    auth.uid() = (SELECT user_id FROM goals WHERE id = goal_milestones.goal_id)
);

-- ==================== HABITS ====================
CREATE POLICY "Users can view own habits" ON habits FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own habits" ON habits FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own habits" ON habits FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own habits" ON habits FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own completions" ON habit_completions FOR SELECT USING (
    auth.uid() = (SELECT user_id FROM habits WHERE id = habit_completions.habit_id)
);
CREATE POLICY "Users can insert own completions" ON habit_completions FOR INSERT WITH CHECK (
    auth.uid() = (SELECT user_id FROM habits WHERE id = habit_completions.habit_id)
);
CREATE POLICY "Users can update own completions" ON habit_completions FOR UPDATE USING (
    auth.uid() = (SELECT user_id FROM habits WHERE id = habit_completions.habit_id)
);
CREATE POLICY "Users can delete own completions" ON habit_completions FOR DELETE USING (
    auth.uid() = (SELECT user_id FROM habits WHERE id = habit_completions.habit_id)
);

-- ==================== MINDSET ====================
CREATE POLICY "Users can view own mindset" ON mindset_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own mindset" ON mindset_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own mindset" ON mindset_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own mindset" ON mindset_entries FOR DELETE USING (auth.uid() = user_id);

-- ==================== RELATIONSHIPS ====================
CREATE POLICY "Users can view own relationships" ON relationships FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own relationships" ON relationships FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own relationships" ON relationships FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own relationships" ON relationships FOR DELETE USING (auth.uid() = user_id);

-- ==================== EDUCATION ====================
CREATE POLICY "Users can view own education" ON education_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own education" ON education_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own education" ON education_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own education" ON education_entries FOR DELETE USING (auth.uid() = user_id);

-- ==================== SPIRITUALITY ====================
CREATE POLICY "Users can view own spirituality" ON spirituality_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own spirituality" ON spirituality_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own spirituality" ON spirituality_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own spirituality" ON spirituality_entries FOR DELETE USING (auth.uid() = user_id);

-- ==================== FAMILY ====================
CREATE POLICY "Users can view own family" ON family_members FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own family" ON family_members FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own family" ON family_members FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own family" ON family_members FOR DELETE USING (auth.uid() = user_id);

-- ==================== RECREATION ====================
CREATE POLICY "Users can view own recreation" ON recreation_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own recreation" ON recreation_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own recreation" ON recreation_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own recreation" ON recreation_entries FOR DELETE USING (auth.uid() = user_id);

-- ==================== TRAVEL ====================
CREATE POLICY "Users can view own travel" ON travel_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own travel" ON travel_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own travel" ON travel_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own travel" ON travel_entries FOR DELETE USING (auth.uid() = user_id);

-- ==================== ACHIEVEMENTS ====================
CREATE POLICY "Public can view achievements" ON achievements FOR SELECT USING (true);
CREATE POLICY "Users can view own achievements" ON user_achievements FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can unlock own achievements" ON user_achievements FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own achievements" ON user_achievements FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own achievements" ON user_achievements FOR DELETE USING (auth.uid() = user_id);

-- ==================== LEADERBOARD ====================
CREATE POLICY "Public can view leaderboard" ON leaderboard_entries FOR SELECT USING (true);
CREATE POLICY "Users can view own leaderboard entry" ON leaderboard_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can upsert own leaderboard" ON leaderboard_entries FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ==================== LEVELS & REWARDS ====================
CREATE POLICY "Public can view levels" ON level_definitions FOR SELECT USING (true);
CREATE POLICY "Public can view rewards" ON rewards FOR SELECT USING (true);
CREATE POLICY "Users can view own rewards" ON user_rewards FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can unlock own rewards" ON user_rewards FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own rewards" ON user_rewards FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own rewards" ON user_rewards FOR DELETE USING (auth.uid() = user_id);

-- ==================== STORAGE POLICIES ====================
CREATE POLICY "Users can upload avatar" ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "Users can update avatar" ON storage.objects FOR UPDATE USING (
    bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "Anyone can view avatars" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');

-- =====================================================
-- PART 5: DATABASE INDEXES (Performance)
-- =====================================================

-- Health
CREATE INDEX IF NOT EXISTS idx_health_user_date ON health_entries(user_id, date);
CREATE INDEX IF NOT EXISTS idx_health_date ON health_entries(date);

-- Career
CREATE INDEX IF NOT EXISTS idx_career_user_date ON career_entries(user_id, date);
CREATE INDEX IF NOT EXISTS idx_career_status ON career_entries(status);

-- Finance
CREATE INDEX IF NOT EXISTS idx_finance_user_date ON finance_entries(user_id, date);
CREATE INDEX IF NOT EXISTS idx_finance_type ON finance_entries(transaction_type);

-- Goals
CREATE INDEX IF NOT EXISTS idx_goals_user_status ON goals(user_id, status);
CREATE INDEX IF NOT EXISTS idx_goals_target_date ON goals(target_date);

-- Habits
CREATE INDEX IF NOT EXISTS idx_habits_user ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_category ON habits(category);
CREATE INDEX IF NOT EXISTS idx_completions_habit_date ON habit_completions(habit_id, completed_date);

-- Mindset
CREATE INDEX IF NOT EXISTS idx_mindset_user_date ON mindset_entries(user_id, date);
CREATE INDEX IF NOT EXISTS idx_mindset_type ON mindset_entries(entry_type);

-- Relationships
CREATE INDEX IF NOT EXISTS idx_relationships_user ON relationships(user_id);
CREATE INDEX IF NOT EXISTS idx_relationships_type ON relationships(relationship_type);

-- Education
CREATE INDEX IF NOT EXISTS idx_education_user_date ON education_entries(user_id, date);
CREATE INDEX IF NOT EXISTS idx_education_status ON education_entries(status);

-- Family
CREATE INDEX IF NOT EXISTS idx_family_user ON family_members(user_id);

-- Recreation
CREATE INDEX IF NOT EXISTS idx_recreation_user_date ON recreation_entries(user_id, date);

-- Travel
CREATE INDEX IF NOT EXISTS idx_travel_user ON travel_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_travel_status ON travel_entries(status);

-- Gamification
CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_leaderboard_period ON leaderboard_entries(period);
CREATE INDEX IF NOT EXISTS idx_leaderboard_xp ON leaderboard_entries(period, xp DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_xp ON profiles(xp DESC);

-- =====================================================
-- PART 6: SEED DATA - 100 ACHIEVEMENTS
-- =====================================================

INSERT INTO achievements (name, description, category, xp_reward, icon) VALUES
-- Health (20)
('First Step', 'Complete your first workout', 'health', 50, '🏃'),
('Early Bird', 'Log 5 workouts before 9 AM', 'health', 100, '🌅'),
('Marathon Runner', 'Complete 42 km total', 'health', 200, '🎽'),
('Sleep Champion', 'Log 7 days of sleep', 'health', 75, '😴'),
('Well Rested', 'Get 8+ hours sleep 5 times', 'health', 100, '🛏️'),
('Nutrition Ninja', 'Log 30 days of nutrition', 'health', 150, '🥗'),
('Weight Goal', 'Reach your target weight', 'health', 250, '⚖️'),
('Vital Signs', 'Log 50 vital readings', 'health', 100, '❤️'),
('Hydration Hero', 'Log water intake 14 days', 'health', 75, '💧'),
('Recovery Master', 'Log 20 recovery sessions', 'health', 100, '🧘'),
('Consistency King', 'Work out 30 days straight', 'health', 300, '👑'),
('Variety Pack', 'Try 10 workout types', 'health', 150, '🎯'),
('Personal Best', 'Set a new workout record', 'health', 100, '🏆'),
('Rest Day Pro', 'Log 20 rest days properly', 'health', 75, '🧸'),
('Morning Routine', 'Morning workout 7 days', 'health', 150, '☀️'),
('Evening Unwind', 'Evening workout 7 days', 'health', 150, '🌙'),
('Cardio Queen', '10 hours cardio total', 'health', 200, '💓'),
('Strength Builder', '100 strength workouts', 'health', 200, '💪'),
('Flexibility Flex', '50 stretching sessions', 'health', 100, '🤸'),
('Active Explorer', 'Try 5 new activities', 'health', 125, '🗺️'),

-- Finance (20)
('First Deposit', 'Log your first income', 'finance', 50, '💰'),
('Budget Boss', 'Create your first budget', 'finance', 75, '📊'),
('Saver Superstar', 'Save 1000 units', 'finance', 150, '🏦'),
('Investor Init', 'Log first investment', 'finance', 100, '📈'),
('Debt Destroyer', 'Log a debt payment', 'finance', 100, '🔥'),
('Expense Tracker', 'Log 100 expenses', 'finance', 150, '🧾'),
('Financial Review', 'Review finances weekly 4x', 'finance', 100, '📋'),
('Goal Getter', 'Reach a savings goal', 'finance', 200, '🎯'),
('Diversified', 'Track 5 account types', 'finance', 125, '🔀'),
('Tax Prepared', 'Log tax-related entries', 'finance', 75, '📑'),
('Retirement Ready', 'Log retirement contribution', 'finance', 150, '🏖️'),
('Emergency Fund', 'Log emergency savings', 'finance', 200, '🛡️'),
('Side Hustle', 'Log side income', 'finance', 100, '💼'),
('Smart Spender', 'Stay under budget 10x', 'finance', 150, '🧠'),
('Money Mindful', 'Log 50 journal entries', 'finance', 100, '📝'),
('Bill Manager', 'Track 10 recurring bills', 'finance', 125, '📄'),
('Net Worth', 'Calculate net worth', 'finance', 75, '📉'),
('Monthly Master', 'Perfect monthly budget', 'finance', 200, '📅'),
('Financial Win', 'Reach money goal', 'finance', 250, '🏅'),
('Wealth Builder', 'Save 10,000 units', 'finance', 500, '💎'),

-- Goals (20)
('Goal Setter', 'Create your first goal', 'goals', 50, '🎯'),
('Dreamer', 'Have 5 active goals', 'goals', 75, '✨'),
('Achiever', 'Complete a goal', 'goals', 150, '✅'),
('Milestone Maker', 'Complete 10 milestones', 'goals', 100, '🪜'),
('On Track', 'Reach 50% on a goal', 'goals', 100, '📍'),
('Almost There', 'Reach 90% on a goal', 'goals', 150, '🏁'),
('Goal Crusher', 'Complete 5 goals', 'goals', 300, '💥'),
('Big Dreamer', 'Have goal worth 10K XP', 'goals', 200, '🌠'),
('Planner Pro', 'Add milestones to 5 goals', 'goals', 125, '📋'),
('Time Manager', 'Set target dates 5 goals', 'goals', 100, '⏰'),
('Category King', 'Complete goal in each domain', 'goals', 250, '👑'),
('Quick Win', 'Complete goal in <7 days', 'goals', 100, '⚡'),
('Long Haul', 'Work on goal 90+ days', 'goals', 200, '🗓️'),
('Revisor', 'Update goal progress 30x', 'goals', 150, '🔄'),
('Goal Visualizer', 'Add description to 10 goals', 'goals', 75, '👁️'),
('Priority Focus', 'Complete highest priority goal', 'goals', 150, '🔝'),
('Category Master', 'Complete 3 goals in one domain', 'goals', 200, '🎖️'),
('Goal types', 'Create different goal types', 'goals', 100, '📂'),
('Reflection Pro', 'Complete goal and journal', 'goals', 125, '📓'),
('Goal Legend', 'Complete 10 goals', 'goals', 500, '🏆'),

-- Habits (20)
('Habit Former', 'Create your first habit', 'habits', 50, '🌱'),
('Streak Starter', '3 day streak', 'habits', 50, '🔥'),
('Week Warrior', '7 day streak', 'habits', 100, '⚔️'),
('Fortnight Focus', '14 day streak', 'habits', 150, '🗓️'),
('Monthly Master', '30 day streak', 'habits', 300, '📆'),
('Habit Builder', 'Create 5 habits', 'habits', 75, '🏗️'),
('Routine Creator', 'Complete 100 completions', 'habits', 150, '🔁'),
('Habit Variety', 'Track 10 different habits', 'habits', 125, '🎨'),
('Perfect Week', 'Complete all habits 7 days', 'habits', 200, '💯'),
('Early Riser', 'Morning habit 14 days', 'habits', 150, '🌅'),
('Night Owl', 'Evening habit 14 days', 'habits', 150, '🦉'),
('Health Nut', '5 health habits active', 'habits', 150, '🥦'),
('Mind Master', '5 mindset habits active', 'habits', 150, '🧠'),
('Social Butterfly', '5 relationship habits', 'habits', 150, '🦋'),
('Learner', '5 education habits', 'habits', 150, '📚'),
('Zen Zone', '5 spirituality habits', 'habits', 150, '🕉️'),
('Streak Legend', '100 day streak', 'habits', 500, '🔥'),
('Habitual', 'Complete 500 completions', 'habits', 300, '🏅'),
('All Rounder', 'Habits in 8+ categories', 'habits', 200, '🌈'),
('Habit Hero', '10 habits with 30+ day streak', 'habits', 500, '🦸'),

-- Relationships (20)
('Social Star', 'Add first contact', 'relationships', 50, '👋'),
('Networker', 'Add 10 contacts', 'relationships', 75, '🤝'),
('Connector', 'Add 25 contacts', 'relationships', 125, '🔗'),
('Birthday Buddy', 'Log 5 birthdays', 'relationships', 75, '🎂'),
('Touch Base', 'Contact 5 people', 'relationships', 100, '📞'),
('Quality Time', 'Log 20 quality time entries', 'relationships', 100, '⏰'),
('Family First', 'Add 5 family members', 'relationships', 100, '👨‍👩‍👧‍👦'),
('Work Wife', 'Add work colleague', 'relationships', 50, '💼'),
('Bestie', 'Mark someone as best friend', 'relationships', 75, '💛'),
('Event Planner', 'Log 5 events', 'relationships', 100, '🎉'),
('Reminder Pro', 'Set 10 contact reminders', 'relationships', 100, '⏰'),
('Follow Up', 'Complete 10 follow-ups', 'relationships', 125, '🔜'),
('Relationship Rich', '50 contacts', 'relationships', 200, '👥'),
('Social Circle', 'Have 5 close friends', 'relationships', 150, '⭐'),
('Memory Maker', 'Log 20 relationship notes', 'relationships', 100, '📝'),
('Celebrant', 'Log 10 birthdays', 'relationships', 150, '🎈'),
('Active Networker', 'Contact 20 people', 'relationships', 175, '📣'),
('Deep Bonds', '5 very close relationships', 'relationships', 200, '💎'),
('Social Legend', '100 contacts', 'relationships', 400, '🏆'),
('Community Builder', 'Organize 3 group events', 'relationships', 300, '🎪');

-- =====================================================
-- ✅ SETUP COMPLETE!
-- =====================================================

SELECT '🎉 BusyBee Database Setup Complete!' AS message;
SELECT COUNT(*) || ' tables created' AS table_count FROM information_schema.tables WHERE table_schema = 'public';
SELECT COUNT(*) || ' achievements seeded' AS achievement_count FROM achievements;
SELECT COUNT(*) || ' levels defined' AS level_count FROM level_definitions;
SELECT COUNT(*) || ' rewards available' AS reward_count FROM rewards;
