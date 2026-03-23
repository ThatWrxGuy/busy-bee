-- =====================================================
-- STORAGE & INDEXES - Performance & Avatars
-- Add to existing database (run after main schema)
-- =====================================================

-- =====================================================
-- STORAGE BUCKETS
-- =====================================================

-- Create storage bucket for user avatars
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_extensions)
VALUES ('avatars', 'avatars', true, 5242880, ARRAY['jpg', 'jpeg', 'png', 'gif', 'webp'])
ON CONFLICT (id) DO NOTHING;

-- Create storage bucket for user uploads (documents, etc.)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_extensions)
VALUES ('uploads', 'uploads', true, 10485760, ARRAY['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx'])
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- STORAGE POLICIES
-- =====================================================

-- Avatars: Users can upload their own avatar
CREATE POLICY "Users can upload avatar"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Avatars: Users can update their own avatar
CREATE POLICY "Users can update avatar"
ON storage.objects FOR UPDATE
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Avatars: Anyone can view avatars (public)
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

-- =====================================================
-- PERFORMANCE INDEXES
-- =====================================================

-- Health entries indexes
CREATE INDEX IF NOT EXISTS idx_health_user_date ON health_entries(user_id, date);
CREATE INDEX IF NOT EXISTS idx_health_date ON health_entries(date);

-- Career entries indexes
CREATE INDEX IF NOT EXISTS idx_career_user_date ON career_entries(user_id, date);
CREATE INDEX IF NOT EXISTS idx_career_status ON career_entries(status);

-- Finance entries indexes
CREATE INDEX IF NOT EXISTS idx_finance_user_date ON finance_entries(user_id, date);
CREATE INDEX IF NOT EXISTS idx_finance_type ON finance_entries(transaction_type);

-- Goals indexes
CREATE INDEX IF NOT EXISTS idx_goals_user_status ON goals(user_id, status);
CREATE INDEX IF NOT EXISTS idx_goals_target_date ON goals(target_date);

-- Habits indexes
CREATE INDEX IF NOT EXISTS idx_habits_user ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_category ON habits(category);

-- Habit completions indexes
CREATE INDEX IF NOT EXISTS idx_completions_habit_date ON habit_completions(habit_id, completed_date);
CREATE INDEX IF NOT EXISTS idx_completions_user ON habit_completions(
    (SELECT user_id FROM habits WHERE id = habit_completions.habit_id),
    completed_date
);

-- Mindset entries indexes
CREATE INDEX IF NOT EXISTS idx_mindset_user_date ON mindset_entries(user_id, date);
CREATE INDEX IF NOT EXISTS idx_mindset_type ON mindset_entries(entry_type);

-- Relationships indexes
CREATE INDEX IF NOT EXISTS idx_relationships_user ON relationships(user_id);
CREATE INDEX IF NOT EXISTS idx_relationships_type ON relationships(relationship_type);

-- Education entries indexes
CREATE INDEX IF NOT EXISTS idx_education_user_date ON education_entries(user_id, date);
CREATE INDEX IF NOT EXISTS idx_education_status ON education_entries(status);

-- Family members indexes
CREATE INDEX IF NOT EXISTS idx_family_user ON family_members(user_id);

-- Recreation entries indexes
CREATE INDEX IF NOT EXISTS idx_recreation_user_date ON recreation_entries(user_id, date);

-- Travel entries indexes
CREATE INDEX IF NOT EXISTS idx_travel_user ON travel_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_travel_status ON travel_entries(status);

-- User achievements index
CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON user_achievements(user_id);

-- Leaderboard indexes
CREATE INDEX IF NOT EXISTS idx_leaderboard_period ON leaderboard_entries(period);
CREATE INDEX IF NOT EXISTS idx_leaderboard_xp ON leaderboard_entries(period, xp DESC);

-- Profiles index
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_xp ON profiles(xp DESC);

SELECT 
    '✅ Storage & Indexes added!' AS message,
    '2 buckets, 3 policies, ' || 
    (SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'public' AND indexname LIKE 'idx_%') || 
    ' indexes' AS details;
