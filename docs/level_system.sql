-- =====================================================
-- LEVEL DEFINITIONS - 16 Tiers
-- Add to existing database (run after main schema)
-- =====================================================

-- Level definitions with XP thresholds
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
-- REWARDS / UNLOCKABLES
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
-- Profile Frames (unlock at various levels)
('Bronze Frame', 'Bronze profile frame', 'frame', '🥉', 1),
('Silver Frame', 'Silver profile frame', 'frame', '🥈', 4),
('Gold Frame', 'Gold profile frame', 'frame', '🥇', 8),
('Diamond Frame', 'Diamond profile frame', 'frame', '💎', 10),
('Mythic Frame', 'Mythic profile frame', 'frame', '🔮', 12),
('Celestial Frame', 'Celestial profile frame', 'frame', '🌟', 14),

-- Titles
('Newcomer', 'Newcomer title', 'title', '🌱', 1),
('Explorer', 'Explorer title', 'title', '🧭', 3),
('Champion', 'Champion title', 'title', '🏆', 6),
('Legend', 'Legend title', 'title', '📜', 11),
('Transcendent', 'Transcendent title', 'title', '🐝', 16),

-- Features
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

-- =====================================================
-- USER REWARDS (what users have unlocked)
-- =====================================================

CREATE TABLE IF NOT EXISTS user_rewards (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    reward_id UUID REFERENCES rewards(id),
    unlocked_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, reward_id)
);

-- Enable RLS
ALTER TABLE level_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_rewards ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view levels" ON level_definitions FOR SELECT USING (true);
CREATE POLICY "Anyone can view rewards" ON rewards FOR SELECT USING (true);
CREATE POLICY "Users manage own rewards" ON user_rewards FOR ALL USING (auth.uid() = user_id);

SELECT '🎉 Level system added! 16 levels, ' || (SELECT COUNT(*) FROM rewards) || ' rewards.' AS message;
