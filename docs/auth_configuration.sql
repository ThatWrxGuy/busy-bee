-- =====================================================
-- AUTH CONFIGURATION
-- Run this to configure auth settings
-- Note: Some settings require Supabase Dashboard UI
-- =====================================================

-- =====================================================
-- AUTH CONFIG (via SQL)
-- =====================================================

-- Create a function to handle new user signup - auto-create profile
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

-- Trigger for auto-creating profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- EMAIL CONFIRMATION (Optional - enable if you want email verification)
-- =====================================================

-- Uncomment to require email confirmation:
-- ALTER TABLE auth.users ALTER COLUMN email_confirm_at SET DEFAULT now();

-- =====================================================
-- SESSION CONFIGURATION
-- =====================================================

-- Note: These require Dashboard configuration:
-- 1. Go to Authentication → Settings
-- 2. Configure Email → Enable "Confirm email" 
-- 3. Configure Site URL (for your Vercel deployment)
-- 4. Add redirect URLs for local development

-- =====================================================
-- AUTH HOOKS (for advanced use)
-- =====================================================

-- Create a function to handle user deletion (cascade to profile)
CREATE OR REPLACE FUNCTION public.handle_delete_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete user's data (cascades due to RLS/foreign keys)
    DELETE FROM public.profiles WHERE id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- CONFIGURATION NOTES
-- =====================================================
/*
To complete Auth setup in Supabase Dashboard:

1. Go to: Authentication → Providers → Email

2. Enable "Enable email signup" ✓
3. Enable "Enable email confirmations" (optional)
4. Set "Secure token" length (default 32)

5. Go to: Authentication → Settings

6. Set "Site URL" to your Vercel deployment URL
   - e.g., https://busy-bee.vercel.app

7. Add "Redirect URLs":
   - http://localhost:3000/auth/callback
   - https://your-vercel-app.vercel.app/auth/callback

8. (Optional) Enable OAuth providers:
   - GitHub
   - Google
   - Discord
   - etc.

=====================================================
OAuth Setup Example (GitHub):
=====================================================

1. Create OAuth App in GitHub:
   - Go to GitHub → Settings → Developer settings → OAuth Apps
   - Homepage URL: https://your-vercel-app.vercel.app
   - Callback: https://vvqxvjwvnilgxqekxvio.supabase.co/auth/v1/callback

2. Add to Supabase:
   - Authentication → Providers → GitHub
   - Enable ✓
   - Add Client ID and Secret from GitHub
   - Save

=====================================================
Discord OAuth Setup:
=====================================================

1. Create Discord App:
   - Go to https://discord.com/developers/applications
   - Create Application → OAuth2
   - Add redirect: https://vvqxvjwvnilgxqekxvio.supabase.co/auth/v1/callback

2. Add to Supabase:
   - Authentication → Providers → Discord
   - Enable ✓
   - Add Client ID and Secret
   - Save

=====================================================
Same process for Google, Apple, etc.
*/

SELECT '✅ Auth configuration complete!' AS message;
SELECT '📝 Manual setup required in Supabase Dashboard:' AS note;
SELECT '1. Authentication → Providers → Enable Email provider' AS step1;
SELECT '2. Authentication → Settings → Set Site URL' AS step2;
SELECT '3. Add redirect URLs for production & local' AS step3;
SELECT '4. (Optional) Enable OAuth providers' AS step4;
