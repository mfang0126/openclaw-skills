# Authentication

> Supabase reference: authentication patterns and examples.

## Authentication

### Email/Password Authentication
```typescript
// Sign up
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password',
  options: {
    data: {
      name: 'John Doe',
      avatar_url: 'https://...'
    }
  }
})

// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'secure-password'
})

// Sign out
const { error } = await supabase.auth.signOut()

// Get current user
const { data: { user } } = await supabase.auth.getUser()

// Get session
const { data: { session } } = await supabase.auth.getSession()
```

### OAuth Providers
```typescript
// Sign in with OAuth
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'github',
  options: {
    redirectTo: 'http://localhost:3000/auth/callback',
    scopes: 'repo user'
  }
})

// Available providers
// github, google, gitlab, bitbucket, azure, discord, facebook,
// linkedin, notion, slack, spotify, twitch, twitter, apple
```

### Magic Links
```typescript
// Send magic link
const { data, error } = await supabase.auth.signInWithOtp({
  email: 'user@example.com',
  options: {
    emailRedirectTo: 'http://localhost:3000/auth/callback'
  }
})

// Verify OTP
const { data, error } = await supabase.auth.verifyOtp({
  email: 'user@example.com',
  token: '123456',
  type: 'email'
})
```

### Phone Authentication
```typescript
// Sign in with phone
const { data, error } = await supabase.auth.signInWithOtp({
  phone: '+1234567890'
})

// Verify phone OTP
const { data, error } = await supabase.auth.verifyOtp({
  phone: '+1234567890',
  token: '123456',
  type: 'sms'
})
```

### Auth State Management
```typescript
// Listen to auth changes
supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'SIGNED_IN') {
    console.log('User signed in:', session?.user)
  }
  if (event === 'SIGNED_OUT') {
    console.log('User signed out')
  }
  if (event === 'TOKEN_REFRESHED') {
    console.log('Token refreshed')
  }
})

// Update user metadata
const { data, error } = await supabase.auth.updateUser({
  data: { theme: 'dark' }
})

// Change password
const { data, error } = await supabase.auth.updateUser({
  password: 'new-password'
})
```
