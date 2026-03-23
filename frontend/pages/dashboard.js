import { useEffect, useState } from 'react'
import { useAuth } from '../context/AuthContext'
import { supabase } from '../lib/supabase'

export default function Dashboard() {
  const { user, signOut } = useAuth()
  const [profile, setProfile] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (user) fetchProfile()
  }, [user])

  const fetchProfile = async () => {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single()
    
    if (!error) setProfile(data)
    setLoading(false)
  }

  const domains = [
    { name: 'Health', icon: '❤️', color: '#ff6b6b' },
    { name: 'Career', icon: '💼', color: '#4ecdc4' },
    { name: 'Finance', icon: '💰', color: '#ffd93d' },
    { name: 'Goals', icon: '🎯', color: '#6c5ce7' },
    { name: 'Habits', icon: '✅', color: '#00b894' },
    { name: 'Mindset', icon: '🧠', color: '#a29bfe' },
    { name: 'Relationships', icon: '❤️‍🔥', color: '#fd79a8' },
    { name: 'Education', icon: '📚', color: '#00cec9' },
    { name: 'Spirituality', icon: '🕊️', color: '#74b9ff' },
    { name: 'Family', icon: '👨‍👩‍👧', color: '#fab1a0' },
    { name: 'Recreation', icon: '🎮', color: '#e17055' },
    { name: 'Travel', icon: '✈️', color: '#0984e3' },
  ]

  if (loading) return <div style={styles.loading}>Loading...</div>

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <h1>🐝 BusyBee</h1>
        <div style={styles.userInfo}>
          <span>Level {profile?.level || 1} • {profile?.xp || 0} XP</span>
          <button onClick={signOut} style={styles.signOutBtn}>Sign Out</button>
        </div>
      </header>

      <main style={styles.main}>
        <div style={styles.welcome}>
          <h2>Welcome back, {profile?.display_name || profile?.username || 'Bee'}! 🐝</h2>
          <p>Track your life across 12 domains</p>
        </div>

        <div style={styles.grid}>
          {domains.map(domain => (
            <div key={domain.name} style={{...styles.card, borderLeftColor: domain.color}}>
              <span style={styles.icon}>{domain.icon}</span>
              <span style={styles.domainName}>{domain.name}</span>
              <span style={styles.arrow}>→</span>
            </div>
          ))}
        </div>
      </main>
    </div>
  )
}

const styles = {
  container: {
    minHeight: '100vh',
    background: '#f8f9fa'
  },
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '20px 40px',
    background: 'white',
    boxShadow: '0 2px 10px rgba(0,0,0,0.1)'
  },
  userInfo: {
    display: 'flex',
    alignItems: 'center',
    gap: '20px'
  },
  signOutBtn: {
    padding: '8px 16px',
    borderRadius: '8px',
    border: '1px solid #ddd',
    background: 'white',
    cursor: 'pointer'
  },
  main: {
    padding: '40px'
  },
  welcome: {
    marginBottom: '32px'
  },
  grid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))',
    gap: '20px'
  },
  card: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
    padding: '20px',
    background: 'white',
    borderRadius: '12px',
    borderLeft: '4px solid',
    boxShadow: '0 2px 10px rgba(0,0,0,0.05)',
    cursor: 'pointer',
    transition: 'transform 0.2s, box-shadow 0.2s'
  },
  icon: {
    fontSize: '28px'
  },
  domainName: {
    flex: 1,
    fontWeight: '500',
    fontSize: '16px'
  },
  arrow: {
    color: '#ccc',
    fontSize: '20px'
  },
  loading: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    height: '100vh',
    fontSize: '18px'
  }
}