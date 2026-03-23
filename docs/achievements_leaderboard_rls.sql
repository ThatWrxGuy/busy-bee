-- =====================================================
-- ACHIEVEMENTS & LEADERBOARD - Expanded RLS Policies
-- Add to existing database
-- =====================================================

-- =====================================================
-- ACHIEVEMENTS CATALOG - Expanded Policies
-- (The catalog is public read-only, but users manage their own unlocks)
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Anyone can view achievements" ON achievements;

-- View achievements - PUBLIC (anyone can see the catalog)
CREATE POLICY "Public can view achievements" 
    ON achievements FOR SELECT 
    USING (true);

-- =====================================================
-- USER ACHIEVEMENTS - Expanded Policies
-- (Users manage their own unlocked achievements)
-- =====================================================

DROP POLICY IF EXISTS "Users manage own achievements" ON user_achievements;

-- View own achievements
CREATE POLICY "Users can view own achievements" 
    ON user_achievements FOR SELECT 
    USING (auth.uid() = user_id);

-- Unlock achievement (insert)
CREATE POLICY "Users can unlock own achievements" 
    ON user_achievements FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Update achievement (rare, but allow)
CREATE POLICY "Users can update own achievements" 
    ON user_achievements FOR UPDATE 
    USING (auth.uid() = user_id);

-- Remove achievement (if needed)
CREATE POLICY "Users can delete own achievements" 
    ON user_achievements FOR DELETE 
    USING (auth.uid() = user_id);

-- =====================================================
-- LEADERBOARD - Expanded Policies
-- (Leaderboard is public, but users manage their own entries)
-- =====================================================

DROP POLICY IF EXISTS "Anyone can view leaderboard" ON leaderboard_entries;
DROP POLICY IF EXISTS "Users manage own leaderboard" ON leaderboard_entries;

-- View leaderboard - PUBLIC (anyone can see rankings)
CREATE POLICY "Public can view leaderboard" 
    ON leaderboard_entries FOR SELECT 
    USING (true);

-- View own leaderboard entry
CREATE POLICY "Users can view own leaderboard entry" 
    ON leaderboard_entries FOR SELECT 
    USING (auth.uid() = user_id);

-- Insert/update own leaderboard entry (system typically manages this)
CREATE POLICY "Users can upsert own leaderboard" 
    ON leaderboard_entries FOR ALL 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- LEVEL DEFINITIONS - Policies
-- (Public read-only)
-- =====================================================

DROP POLICY IF EXISTS "Anyone can view levels" ON level_definitions;

CREATE POLICY "Public can view levels" 
    ON level_definitions FOR SELECT 
    USING (true);

-- =====================================================
-- REWARDS - Policies
-- (Public catalog + user's unlocked rewards)
-- =====================================================

DROP POLICY IF EXISTS "Anyone can view rewards" ON rewards;
DROP POLICY IF EXISTS "Users manage own rewards" ON user_rewards;

-- View rewards catalog - PUBLIC
CREATE POLICY "Public can view rewards" 
    ON rewards FOR SELECT 
    USING (true);

-- View own rewards
CREATE POLICY "Users can view own rewards" 
    ON user_rewards FOR SELECT 
    USING (auth.uid() = user_id);

-- Unlock reward (insert)
CREATE POLICY "Users can unlock own rewards" 
    ON user_rewards FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Update own rewards
CREATE POLICY "Users can update own rewards" 
    ON user_rewards FOR UPDATE 
    USING (auth.uid() = user_id);

-- Delete own rewards
CREATE POLICY "Users can delete own rewards" 
    ON user_rewards FOR DELETE 
    USING (auth.uid() = user_id);

-- =====================================================
-- GOALS & MILESTONES - Expand Policies
-- =====================================================

DROP POLICY IF EXISTS "Users manage own goals" ON goals;
DROP POLICY IF EXISTS "Users manage own milestones" ON goal_milestones;

-- Goals
CREATE POLICY "Users can view own goals" ON goals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own goals" ON goals FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own goals" ON goals FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own goals" ON goals FOR DELETE USING (auth.uid() = user_id);

-- Milestones
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

-- =====================================================
-- HABITS & COMPLETIONS - Expand Policies
-- =====================================================

DROP POLICY IF EXISTS "Users manage own habits" ON habits;
DROP POLICY IF EXISTS "Users manage own completions" ON habit_completions;

-- Habits
CREATE POLICY "Users can view own habits" ON habits FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own habits" ON habits FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own habits" ON habits FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own habits" ON habits FOR DELETE USING (auth.uid() = user_id);

-- Habit Completions
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

-- =====================================================
-- PROFILES - Expand Policies
-- =====================================================

DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

-- Profiles
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Optional: Allow viewing other users' profiles (for leaderboard display names)
-- CREATE POLICY "Users can view public profiles" ON profiles FOR SELECT USING (true);

SELECT '✅ Expanded RLS policies for achievements & leaderboard!' AS message;
