import { AuthProvider, useAuth } from '../context/AuthContext'
import { useRouter } from 'next/router'
import { useEffect } from 'react'

function ProtectedRoute({ children }) {
  const { user, loading } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (!loading && !user) {
      router.push('/login')
    }
  }, [user, loading, router])

  if (loading) return <div>Loading...</div>
  if (!user) return null
  
  return children
}

export default function App({ Component, pageProps }) {
  return (
    <AuthProvider>
      <Component {...pageProps} />
    </AuthProvider>
  )
}