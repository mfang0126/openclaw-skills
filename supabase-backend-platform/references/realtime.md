# Realtime Subscriptions

> Supabase reference: realtime subscriptions patterns and examples.

## Realtime Subscriptions

### Database Changes
```typescript
// Subscribe to inserts
const channel = supabase
  .channel('posts-insert')
  .on(
    'postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'posts'
    },
    (payload) => {
      console.log('New post:', payload.new)
    }
  )
  .subscribe()

// Subscribe to updates
const channel = supabase
  .channel('posts-update')
  .on(
    'postgres_changes',
    {
      event: 'UPDATE',
      schema: 'public',
      table: 'posts',
      filter: 'id=eq.1'
    },
    (payload) => {
      console.log('Updated:', payload.new)
      console.log('Previous:', payload.old)
    }
  )
  .subscribe()

// Subscribe to all changes
const channel = supabase
  .channel('posts-all')
  .on(
    'postgres_changes',
    {
      event: '*',
      schema: 'public',
      table: 'posts'
    },
    (payload) => {
      console.log('Change:', payload)
    }
  )
  .subscribe()

// Unsubscribe
supabase.removeChannel(channel)
```

### Presence (Track Online Users)
```typescript
// Track presence
const channel = supabase.channel('room-1')

// Track current user
channel
  .on('presence', { event: 'sync' }, () => {
    const state = channel.presenceState()
    console.log('Online users:', state)
  })
  .on('presence', { event: 'join' }, ({ key, newPresences }) => {
    console.log('User joined:', newPresences)
  })
  .on('presence', { event: 'leave' }, ({ key, leftPresences }) => {
    console.log('User left:', leftPresences)
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await channel.track({
        user_id: userId,
        online_at: new Date().toISOString()
      })
    }
  })

// Untrack
await channel.untrack()
```

### Broadcast (Send Messages)
```typescript
// Broadcast messages
const channel = supabase.channel('chat-room')

channel
  .on('broadcast', { event: 'message' }, (payload) => {
    console.log('Message:', payload)
  })
  .subscribe()

// Send message
await channel.send({
  type: 'broadcast',
  event: 'message',
  payload: { text: 'Hello', user: 'John' }
})
```
