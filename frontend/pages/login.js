import { useState } from 'react'
import { useAuth } from '../context/AuthContext'
import Link from 'next/link'

export default function Login() {
  const { signIn, signUp, signInWithOAuth } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [isSignUp, setIsSignUp] = useState(false)
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState(null)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError(null)
    setMessage(null)
    setLoading(true)

    try {
      if (isSignUp) {
        await signUp(email, password)
        setMessage('Check your email to confirm your account!')
      } else {
        await signIn(email, password)
      }
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleOAuth = async (provider) => {
    setError(null)
    try {
      await signInWithOAuth(provider)
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <h1 style={styles.title}>🐝 BusyBee</h1>
        <p style={styles.subtitle}>Your Life OS</p>

        <form onSubmit={handleSubmit} style={styles.form}>
          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            style={styles.input}
            required
          />
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            style={styles.input}
            required
          />
          
          {error && <div style={styles.error}>{error}</div>}
          {message && <div style={styles.success}>{message}</div>}

          <button type="submit" style={styles.button} disabled={loading}>
            {loading ? 'Loading...' : isSignUp ? 'Sign Up' : 'Sign In'}
          </button>
        </form>

        <p style={styles.toggle}>
          {isSignUp ? 'Already have an account?' : "Don't have an account?"}{' '}
          <button onClick={() => { setIsSignUp(!isSignUp); setError(null); setMessage(null) }} style={styles.link}>
            {isSignUp ? 'Sign In' : 'Sign Up'}
          </button>
        </p>

        <div style={styles.divider}>
          <span>or continue with</span>
        </div>

        <div style={styles.oauth}>
          <button onClick={() => handleOAuth('github')} style={styles.oauthButton}>
            GitHub
          </button>
          <button onClick={() => handleOAuth('google')} style={styles.oauthButton}>
            Google
          </button>
        </div>
      </div>
    </div>
  )
}

const styles = {
  container: {
    minHeight: '100vh',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    padding: '20px'
  },
  card: {
    background: 'white',
    borderRadius: '16px',
    padding: '40px',
    width: '100%',
    maxWidth: '400px',
    boxShadow: '0 10px 40px rgba(0,0,0,0.2)'
  },
  title: {
    fontSize: '32px',
    textAlign: 'center',
    margin: '0 0 8px 0',
    color: '#1a1a2e'
  },
  subtitle: {
    textAlign: 'center',
    color: '#666',
    marginBottom: '32px'
  },
  form: {
    display: 'flex',
    flexDirection: 'column',
    gap: '16px'
  },
  input: {
    padding: '14px',
    borderRadius: '8px',
    border: '1px solid #ddd',
    fontSize: '16px',
    outline: 'none',
    transition: 'border-color 0.2s'
  },
  button: {
    padding: '14px',
    borderRadius: '8px',
    border: 'none',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    color: 'white',
    fontSize: '16px',
    fontWeight: '600',
    cursor: 'pointer',
    transition: 'opacity 0.2s'
  },
  error: {
    padding: '12px',
    borderRadius: '8px',
    background: '#fee',
    color: '#c00',
    fontSize: '14px'
  },
  success: {
    padding: '12px',
    borderRadius: '8px',
    background: '#efe',
    color: '#060',
    fontSize: '14px'
  },
  toggle: {
    textAlign: 'center',
    marginTop: '16px',
    color: '#666'
  },
  link: {
    background: 'none',
    border: 'none',
    color: '#667eea',
    cursor: 'pointer',
    fontSize: 'inherit'
  },
  divider: {
    textAlign: 'center',
    margin: '24px 0',
    color: '#999',
    fontSize: '14px'
  },
  oauth: {
    display: 'flex',
    gap: '12px'
  },
  oauthButton: {
    flex: 1,
    padding: '12px',
    borderRadius: '8px',
    border: '1px solid #ddd',
    background: 'white',
    cursor: 'pointer',
    fontSize: '14px',
    fontWeight: '500',
    transition: 'background 0.2s'
  }
}