# BusyBee Frontend

Next.js frontend for BusyBee Life OS with Supabase authentication.

## Quick Start

```bash
cd frontend

# Install dependencies
npm install

# Copy environment variables
cp .env.local.example .env.local

# Start development server
npm run dev
```

## Authentication

The app supports:
- Email/Password sign up & sign in
- GitHub OAuth
- Google OAuth

OAuth providers must be configured in your Supabase Dashboard:
- Go to Authentication → Providers
- Enable GitHub and/or Google
- Add your OAuth credentials

## Project Structure

```
frontend/
├── lib/
│   └── supabase.js      # Supabase client
├── context/
│   └── AuthContext.js  # Auth context provider
├── pages/
│   ├── _app.js          # App wrapper with AuthProvider
│   ├── index.js         # Redirects based on auth state
│   ├── login.js         # Login/Signup page
│   └── dashboard.js     # Main dashboard (protected)
└── package.json
```

## Environment Variables

```
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

Get these from Supabase Dashboard → Settings → API.