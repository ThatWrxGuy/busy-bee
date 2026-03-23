-- =====================================================
-- EXPANDED RLS POLICIES
-- Add to existing database (run after main schema)
-- More granular policies for better security
-- =====================================================

-- =====================================================
-- MINDSET - Expanded Policies
-- =====================================================

DROP POLICY IF EXISTS "Users manage own mindset" ON mindset_entries;

-- View own mindset entries
CREATE POLICY "Users can view own mindset" 
    ON mindset_entries FOR SELECT 
    USING (auth.uid() = user_id);

-- Insert own mindset entries
CREATE POLICY "Users can insert own mindset" 
    ON mindset_entries FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Update own mindset entries
CREATE POLICY "Users can update own mindset" 
    ON mindset_entries FOR UPDATE 
    USING (auth.uid() = user_id);

-- Delete own mindset entries
CREATE POLICY "Users can delete own mindset" 
    ON mindset_entries FOR DELETE 
    USING (auth.uid() = user_id);

-- =====================================================
-- RELATIONSHIPS - Expanded Policies
-- =====================================================

DROP POLICY IF EXISTS "Users manage own relationships" ON relationships;

-- View own relationships
CREATE POLICY "Users can view own relationships" 
    ON relationships FOR SELECT 
    USING (auth.uid() = user_id);

-- Insert own relationships
CREATE POLICY "Users can insert own relationships" 
    ON relationships FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Update own relationships
CREATE POLICY "Users can update own relationships" 
    ON relationships FOR UPDATE 
    USING (auth.uid() = user_id);

-- Delete own relationships
CREATE POLICY "Users can delete own relationships" 
    ON relationships FOR DELETE 
    USING (auth.uid() = user_id);

-- =====================================================
-- EDUCATION - Expanded Policies
-- =====================================================

DROP POLICY IF EXISTS "Users manage own education" ON education_entries;

-- View own education
CREATE POLICY "Users can view own education" 
    ON education_entries FOR SELECT 
    USING (auth.uid() = user_id);

-- Insert own education
CREATE POLICY "Users can insert own education" 
    ON education_entries FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Update own education
CREATE POLICY "Users can update own education" 
    ON education_entries FOR UPDATE 
    USING (auth.uid() = user_id);

-- Delete own education
CREATE POLICY "Users can delete own education" 
    ON education_entries FOR DELETE 
    USING (auth.uid() = user_id);

-- =====================================================
-- SPIRITUALITY - Expanded Policies
-- =====================================================

DROP POLICY IF EXISTS "Users manage own spirituality" ON spirituality_entries;

-- View own spirituality
CREATE POLICY "Users can view own spirituality" 
    ON spirituality_entries FOR SELECT 
    USING (auth.uid() = user_id);

-- Insert own spirituality
CREATE POLICY "Users can insert own spirituality" 
    ON spirituality_entries FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Update own spirituality
CREATE POLICY "Users can update own spirituality" 
    ON spirituality_entries FOR UPDATE 
    USING (auth.uid() = user_id);

-- Delete own spirituality
CREATE POLICY "Users can delete own spirituality" 
    ON spirituality_entries FOR DELETE 
    USING (auth.uid() = user_id);

-- =====================================================
-- FAMILY - Expanded Policies
-- =====================================================

DROP POLICY IF EXISTS "Users manage own family" ON family_members;

-- View own family
CREATE POLICY "Users can view own family" 
    ON family_members FOR SELECT 
    USING (auth.uid() = user_id);

-- Insert own family
CREATE POLICY "Users can insert own family" 
    ON family_members FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Update own family
CREATE POLICY "Users can update own family" 
    ON family_members FOR UPDATE 
    USING (auth.uid() = user_id);

-- Delete own family
CREATE POLICY "Users can delete own family" 
    ON family_members FOR DELETE 
    USING (auth.uid() = user_id);

-- =====================================================
-- RECREATION - Expanded Policies
-- =====================================================

DROP POLICY IF EXISTS "Users manage own recreation" ON recreation_entries;

-- View own recreation
CREATE POLICY "Users can view own recreation" 
    ON recreation_entries FOR SELECT 
    USING (auth.uid() = user_id);

-- Insert own recreation
CREATE POLICY "Users can insert own recreation" 
    ON recreation_entries FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Update own recreation
CREATE POLICY "Users can update own recreation" 
    ON recreation_entries FOR UPDATE 
    USING (auth.uid() = user_id);

-- Delete own recreation
CREATE POLICY "Users can delete own recreation" 
    ON recreation_entries FOR DELETE 
    USING (auth.uid() = user_id);

-- =====================================================
-- TRAVEL - Expanded Policies
-- =====================================================

DROP POLICY IF EXISTS "Users manage own travel" ON travel_entries;

-- View own travel
CREATE POLICY "Users can view own travel" 
    ON travel_entries FOR SELECT 
    USING (auth.uid() = user_id);

-- Insert own travel
CREATE POLICY "Users can insert own travel" 
    ON travel_entries FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Update own travel
CREATE POLICY "Users can update own travel" 
    ON travel_entries FOR UPDATE 
    USING (auth.uid() = user_id);

-- Delete own travel
CREATE POLICY "Users can delete own travel" 
    ON travel_entries FOR DELETE 
    USING (auth.uid() = user_id);

-- =====================================================
-- ALSO EXPAND OTHER TABLES FOR CONSISTENCY
-- =====================================================

-- Health entries - expand
DROP POLICY IF EXISTS "Users manage own health" ON health_entries;

CREATE POLICY "Users can view own health" ON health_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own health" ON health_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own health" ON health_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own health" ON health_entries FOR DELETE USING (auth.uid() = user_id);

-- Career entries - expand
DROP POLICY IF EXISTS "Users manage own career" ON career_entries;

CREATE POLICY "Users can view own career" ON career_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own career" ON career_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own career" ON career_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own career" ON career_entries FOR DELETE USING (auth.uid() = user_id);

-- Finance entries - expand
DROP POLICY IF EXISTS "Users manage own finance" ON finance_entries;

CREATE POLICY "Users can view own finance" ON finance_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own finance" ON finance_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own finance" ON finance_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own finance" ON finance_entries FOR DELETE USING (auth.uid() = user_id);

SELECT '✅ Expanded RLS policies added for all tables!' AS message;
