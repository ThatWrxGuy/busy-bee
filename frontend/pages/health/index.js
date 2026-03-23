import { useEffect, useState } from 'react'
import { useAuth } from '../context/AuthContext'
import { supabase } from '../lib/supabase'
import Link from 'next/link'
import { useRouter } from 'next/router'

export default function Health() {
  const { user } = useAuth()
  const router = useRouter()
  const [entries, setEntries] = useState([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [newEntry, setNewEntry] = useState({
    date: new Date().toISOString().split('T')[0],
    workout_type: '',
    workout_duration: '',
    sleep_hours: '',
    sleep_quality: 5,
    nutrition_notes: '',
    weight: '',
    vitals_bpm: '',
    vitals_bp_systolic: '',
    vitals_bp_diastolic: ''
  })

  // Compute statistics
  const stats = entries.length > 0 ? {
    totalWorkouts: entries.filter(e => e.workout_type).length,
    avgSleep: entries.filter(e => e.sleep_hours).reduce((a, b) => a + b.sleep_hours, 0) / entries.filter(e => e.sleep_hours).length || 0,
    avgSleepQuality: entries.filter(e => e.sleep_quality).reduce((a, b) => a + b.sleep_quality, 0) / entries.filter(e => e.sleep_quality).length || 0,
    currentWeight: entries.find(e => e.weight)?.weight,
    streak: calculateStreak(entries)
  } : null

  function calculateStreak(entries) {
    // Simple streak: consecutive days with any entry
    let streak = 0
    const today = new Date()
    for (let i = 0; i < 30; i++) {
      const checkDate = new Date(today)
      checkDate.setDate(checkDate.getDate() - i)
      const dateStr = checkDate.toISOString().split('T')[0]
      if (entries.some(e => e.date === dateStr)) streak++
      else if (i > 0) break
    }
    return streak
  }

  // Recent trends
  const recentEntries = entries.slice(0, 7)

  useEffect(() => {
    if (!user) {
      router.push('/login')
    } else {
      fetchEntries()
    }
  }, [user])

  const fetchEntries = async () => {
    const { data } = await supabase
      .from('health_entries')
      .select('*')
      .eq('user_id', user?.id)
      .order('date', { ascending: false })
      .limit(20)
    setEntries(data || [])
    setLoading(false)
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    const { error } = await supabase.from('health_entries').insert({
      user_id: user.id,
      date: newEntry.date,
      workout_type: newEntry.workout_type || null,
      workout_duration: newEntry.workout_duration ? parseInt(newEntry.workout_duration) : null,
      sleep_hours: newEntry.sleep_hours ? parseFloat(newEntry.sleep_hours) : null,
      sleep_quality: parseInt(newEntry.sleep_quality),
      nutrition_notes: newEntry.nutrition_notes || null,
      weight: newEntry.weight ? parseFloat(newEntry.weight) : null,
      vitals_bpm: newEntry.vitals_bpm ? parseInt(newEntry.vitals_bpm) : null,
      vitals_bp_systolic: newEntry.vitals_bp_systolic ? parseInt(newEntry.vitals_bp_systolic) : null,
      vitals_bp_diastolic: newEntry.vitals_bp_diastolic ? parseInt(newEntry.vitals_bp_diastolic) : null
    })
    if (!error) {
      setShowForm(false)
      fetchEntries()
    }
  }

  if (loading) return <div style={styles.loading}>Loading...</div>

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <div style={styles.headerLeft}>
          <Link href="/dashboard" style={styles.backLink}>← Dashboard</Link>
          <h1>❤️ Health</h1>
        </div>
        <button onClick={() => setShowForm(!showForm)} style={styles.addBtn}>
          {showForm ? 'Cancel' : '+ Add Entry'}
        </button>
      </header>

      <main style={styles.main}>
        {stats && (
          <div style={styles.statsGrid}>
            <div style={styles.statCard}>
              <span style={styles.statValue}>{stats.totalWorkouts}</span>
              <span style={styles.statLabel}>Workouts</span>
            </div>
            <div style={styles.statCard}>
              <span style={styles.statValue}>{stats.avgSleep.toFixed(1)}h</span>
              <span style={styles.statLabel}>Avg Sleep</span>
            </div>
            <div style={styles.statCard}>
              <span style={styles.statValue}>{stats.avgSleepQuality.toFixed(1)}</span>
              <span style={styles.statLabel}>Sleep Quality</span>
            </div>
            <div style={styles.statCard}>
              <span style={styles.statValue}>{stats.currentWeight || '--'}kg</span>
              <span style={styles.statLabel}>Current Weight</span>
            </div>
            <div style={styles.statCard}>
              <span style={styles.statValue}>🔥 {stats.streak}</span>
              <span style={styles.statLabel}>Day Streak</span>
            </div>
          </div>
        )}

        {showForm && (
          <form onSubmit={handleSubmit} style={styles.form}>
            <div style={styles.formGrid}>
              <input type="date" value={newEntry.date} onChange={e => setNewEntry({...newEntry, date: e.target.value})} style={styles.input} required />
              <select value={newEntry.workout_type} onChange={e => setNewEntry({...newEntry, workout_type: e.target.value})} style={styles.input}>
                <option value="">Workout Type</option>
                <option value="running">Running</option>
                <option value="weights">Weights</option>
                <option value="yoga">Yoga</option>
                <option value="cycling">Cycling</option>
                <option value="swimming">Swimming</option>
                <option value="other">Other</option>
              </select>
              <input type="number" placeholder="Duration (min)" value={newEntry.workout_duration} onChange={e => setNewEntry({...newEntry, workout_duration: e.target.value})} style={styles.input} />
              <input type="number" step="0.1" placeholder="Sleep Hours" value={newEntry.sleep_hours} onChange={e => setNewEntry({...newEntry, sleep_hours: e.target.value})} style={styles.input} />
              <select value={newEntry.sleep_quality} onChange={e => setNewEntry({...newEntry, sleep_quality: e.target.value})} style={styles.input}>
                <option value="1">Sleep: 1</option>
                <option value="2">Sleep: 2</option>
                <option value="3">Sleep: 3</option>
                <option value="4">Sleep: 4</option>
                <option value="5">Sleep: 5</option>
                <option value="6">Sleep: 6</option>
                <option value="7">Sleep: 7</option>
                <option value="8">Sleep: 8</option>
                <option value="9">Sleep: 9</option>
                <option value="10">Sleep: 10</option>
              </select>
              <input type="number" step="0.1" placeholder="Weight (kg)" value={newEntry.weight} onChange={e => setNewEntry({...newEntry, weight: e.target.value})} style={styles.input} />
              <input type="number" placeholder="Heart Rate (bpm)" value={newEntry.vitals_bpm} onChange={e => setNewEntry({...newEntry, vitals_bpm: e.target.value})} style={styles.input} />
              <input type="number" placeholder="BP Systolic" value={newEntry.vitals_bp_systolic} onChange={e => setNewEntry({...newEntry, vitals_bp_systolic: e.target.value})} style={styles.input} />
              <input type="number" placeholder="BP Diastolic" value={newEntry.vitals_bp_diastolic} onChange={e => setNewEntry({...newEntry, vitals_bp_diastolic: e.target.value})} style={styles.input} />
            </div>
            <input type="text" placeholder="Nutrition notes" value={newEntry.nutrition_notes} onChange={e => setNewEntry({...newEntry, nutrition_notes: e.target.value})} style={{...styles.input, width: '100%'}} />
            <button type="submit" style={styles.submitBtn}>Save Entry</button>
          </form>
        )}

        <div style={styles.list}>
          {entries.length === 0 ? (
            <p style={styles.empty}>No health entries yet. Add your first entry!</p>
          ) : (
            entries.map(entry => (
              <div key={entry.id} style={styles.entryCard}>
                <div style={styles.entryHeader}>
                  <span style={styles.entryDate}>{entry.date}</span>
                  {entry.workout_type && <span style={styles.badge}>{entry.workout_type}</span>}
                </div>
                <div style={styles.entryStats}>
                  {entry.workout_type && <span>🏃 {entry.workout_type}</span>}
                  {entry.workout_duration && <span>{entry.workout_duration}min</span>}
                  {entry.sleep_hours && <span>😴 {entry.sleep_hours}h</span>}
                  {entry.sleep_quality && <span>⭐ {entry.sleep_quality}/10</span>}
                  {entry.weight && <span>⚖️ {entry.weight}kg</span>}
                </div>
                {(entry.vitals_bpm || entry.vitals_bp_systolic) && (
                  <div style={styles.entryVitals}>
                    {entry.vitals_bpm && <span>❤️ {entry.vitals_bpm} bpm</span>}
                    {entry.vitals_bp_systolic && <span>🩺 {entry.vitals_bp_systolic}/{entry.vitals_bp_diastolic} mmHg</span>}
                  </div>
                )}
                {entry.nutrition_notes && <p style={styles.entryNotes}>{entry.nutrition_notes}</p>}
              </div>
            ))
          )}
        </div>
      </main>
    </div>
  )
}

const styles = {
  container: { minHeight: '100vh', background: '#f8f9fa' },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '20px 40px', background: 'white', boxShadow: '0 2px 10px rgba(0,0,0,0.1)' },
  headerLeft: { display: 'flex', alignItems: 'center', gap: '20px' },
  backLink: { textDecoration: 'none', color: '#667eea', fontWeight: '500' },
  addBtn: { padding: '10px 20px', background: '#667eea', color: 'white', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: '500' },
  main: { padding: '40px', maxWidth: '900px', margin: '0 auto' },
  statsGrid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(140px, 1fr))', gap: '16px', marginBottom: '32px' },
  statCard: { background: 'white', padding: '20px', borderRadius: '12px', textAlign: 'center', boxShadow: '0 2px 10px rgba(0,0,0,0.05)' },
  statValue: { display: 'block', fontSize: '28px', fontWeight: '700', color: '#ff6b6b' },
  statLabel: { display: 'block', fontSize: '13px', color: '#888', marginTop: '4px' },
  form: { background: 'white', padding: '24px', borderRadius: '12px', marginBottom: '24px', boxShadow: '0 2px 10px rgba(0,0,0,0.05)' },
  formGrid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))', gap: '12px', marginBottom: '12px' },
  input: { padding: '12px', borderRadius: '8px', border: '1px solid #ddd', fontSize: '14px' },
  submitBtn: { marginTop: '12px', padding: '12px 24px', background: '#00b894', color: 'white', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: '500' },
  list: { display: 'flex', flexDirection: 'column', gap: '12px' },
  empty: { textAlign: 'center', color: '#888', padding: '40px' },
  entryCard: { background: 'white', padding: '16px', borderRadius: '12px', borderLeft: '4px solid #ff6b6b', boxShadow: '0 2px 10px rgba(0,0,0,0.05)' },
  entryHeader: { display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '8px' },
  entryDate: { fontWeight: '600', color: '#333' },
  badge: { padding: '4px 10px', background: '#ff6b6b20', color: '#ff6b6b', borderRadius: '12px', fontSize: '13px', fontWeight: '500' },
  entryStats: { display: 'flex', gap: '16px', fontSize: '14px', color: '#666' },
  entryVitals: { display: 'flex', gap: '16px', fontSize: '13px', color: '#ff6b6b', marginTop: '6px' },
  entryNotes: { marginTop: '8px', fontSize: '14px', color: '#888', fontStyle: 'italic' },
  loading: { display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }
}