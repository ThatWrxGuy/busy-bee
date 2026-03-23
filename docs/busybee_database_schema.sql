-- =====================================================
-- BUSYBEE LIFE OS - SUPABASE DATABASE SCHEMA
-- Run this in Supabase SQL Editor
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- USERS & PROFILES
-- =====================================================

-- Profiles table (extends auth.users)
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
-- GAMIFICATION
-- =====================================================

-- Achievements catalog
CREATE TABLE IF NOT EXISTS achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT CHECK (category IN ('finance', 'goals', 'health', 'habits', 'relationships', 'general')),
    xp_reward INTEGER DEFAULT 0,
    icon TEXT,
    requirement_json JSONB
);

-- User achievements
CREATE TABLE IF NOT EXISTS user_achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES achievements(id),
    unlocked_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- Leaderboard
CREATE TABLE IF NOT EXISTS leaderboard_entries (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    period TEXT CHECK (period IN ('weekly', 'monthly', 'all_time')),
    xp INTEGER DEFAULT 0,
    rank INTEGER,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) - Security
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

-- Create policies (users can only see their own data)
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Health
CREATE POLICY "Users manage own health" ON health_entries FOR ALL USING (auth.uid() = user_id);

-- Career
CREATE POLICY "Users manage own career" ON career_entries FOR ALL USING (auth.uid() = user_id);

-- Finance
CREATE POLICY "Users manage own finance" ON finance_entries FOR ALL USING (auth.uid() = user_id);

-- Goals
CREATE POLICY "Users manage own goals" ON goals FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own milestones" ON goal_milestones FOR ALL USING (
    auth.uid() = (SELECT user_id FROM goals WHERE id = goal_milestones.goal_id)
);

-- Habits
CREATE POLICY "Users manage own habits" ON habits FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own completions" ON habit_completions FOR ALL USING (
    auth.uid() = (SELECT user_id FROM habits WHERE id = habit_completions.habit_id)
);

-- Mindset
CREATE POLICY "Users manage own mindset" ON mindset_entries FOR ALL USING (auth.uid() = user_id);

-- Relationships
CREATE POLICY "Users manage own relationships" ON relationships FOR ALL USING (auth.uid() = user_id);

-- Education
CREATE POLICY "Users manage own education" ON education_entries FOR ALL USING (auth.uid() = user_id);

-- Spirituality
CREATE POLICY "Users manage own spirituality" ON spirituality_entries FOR ALL USING (auth.uid() = user_id);

-- Family
CREATE POLICY "Users manage own family" ON family_members FOR ALL USING (auth.uid() = user_id);

-- Recreation
CREATE POLICY "Users manage own recreation" ON recreation_entries FOR ALL USING (auth.uid() = user_id);

-- Travel
CREATE POLICY "Users manage own travel" ON travel_entries FOR ALL USING (auth.uid() = user_id);

-- Achievements (read-only catalog + user's achievements)
CREATE POLICY "Anyone can view achievements" ON achievements FOR SELECT USING (true);
CREATE POLICY "Users manage own achievements" ON user_achievements FOR ALL USING (auth.uid() = user_id);

-- Leaderboard
CREATE POLICY "Anyone can view leaderboard" ON leaderboard_entries FOR SELECT USING (true);
CREATE POLICY "Users manage own leaderboard" ON leaderboard_entries FOR ALL USING (auth.uid() = user_id);

-- =====================================================
-- SEED DATA: Achievements (100 achievements)
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
-- DONE!
-- =====================================================

SELECT '🎉 Database setup complete! ' || COUNT(*) || ' tables created.' AS message
FROM information_schema.tables 
WHERE table_schema = 'public';
