# Security Best Practices

> Supabase reference: security best practices patterns and examples.

## Security Best Practices

### API Key Management
```typescript
// NEVER expose service_role key in client
// Use anon key for client-side
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY! // Public
)

// Service role key only on server
const supabaseAdmin = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!, // Secret, bypasses RLS
  { auth: { persistSession: false } }
)
```

### RLS Best Practices
```sql
-- Always enable RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Default deny (no policy = no access)
-- Explicitly grant access with policies

-- Test policies as different users
SET request.jwt.claims.sub = 'user-id';
SELECT * FROM posts; -- Test as this user

-- Disable RLS only for admin operations
-- Use service_role key from server, never client
```

### Input Validation
```typescript
// Validate on client and server
function validatePost(data: unknown) {
  const schema = z.object({
    title: z.string().min(1).max(200),
    content: z.string().max(10000).optional()
  })

  return schema.parse(data)
}

// Server-side validation in Edge Function
serve(async (req) => {
  const body = await req.json()

  try {
    const validated = validatePost(body)
    // Process validated data
  } catch (error) {
    return new Response(
      JSON.stringify({ error: 'Invalid input' }),
      { status: 400 }
    )
  }
})
```

### Environment Variables
```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ... # Public
SUPABASE_SERVICE_ROLE_KEY=eyJ... # Secret, server-only

# Production: Use environment variables in hosting platform
# Never commit .env files to git
```
