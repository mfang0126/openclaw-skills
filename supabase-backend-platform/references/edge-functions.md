# Edge Functions

> Supabase reference: edge functions patterns and examples.

## Edge Functions

### Edge Function Basics
Serverless functions on Deno runtime:

```bash
# Create function
supabase functions new my-function

# Serve locally
supabase functions serve

# Deploy
supabase functions deploy my-function
```

### Edge Function Example
```typescript
// supabase/functions/my-function/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    // Get auth header
    const authHeader = req.headers.get('Authorization')!

    // Create Supabase client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    // Verify user
    const { data: { user }, error } = await supabase.auth.getUser()
    if (error) throw error

    // Process request
    const { data } = await supabase
      .from('posts')
      .select('*')
      .eq('author_id', user.id)

    return new Response(
      JSON.stringify({ data }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
```

### Invoke Edge Function
```typescript
// From client
const { data, error } = await supabase.functions.invoke('my-function', {
  body: { name: 'John' }
})

// With auth
const { data, error } = await supabase.functions.invoke('my-function', {
  headers: {
    Authorization: `Bearer ${session.access_token}`
  },
  body: { name: 'John' }
})
```
