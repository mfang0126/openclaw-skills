# Database Operations

> Supabase reference: database operations patterns and examples.

## Database Operations

### PostgREST API Basics
Supabase auto-generates REST API from Postgres schema:

```typescript
// SELECT * FROM posts
const { data, error } = await supabase
  .from('posts')
  .select('*')

// SELECT with filters
const { data } = await supabase
  .from('posts')
  .select('*')
  .eq('status', 'published')
  .order('created_at', { ascending: false })
  .limit(10)

// SELECT with joins
const { data } = await supabase
  .from('posts')
  .select(`
    *,
    author:profiles(name, avatar),
    comments(count)
  `)

// INSERT
const { data, error } = await supabase
  .from('posts')
  .insert({ title: 'Hello', content: 'World' })
  .select()
  .single()

// UPDATE
const { data } = await supabase
  .from('posts')
  .update({ status: 'published' })
  .eq('id', postId)
  .select()

// DELETE
const { error } = await supabase
  .from('posts')
  .delete()
  .eq('id', postId)

// UPSERT
const { data } = await supabase
  .from('posts')
  .upsert({ id: 1, title: 'Updated' })
  .select()
```

### Advanced Queries
```typescript
// Full-text search
const { data } = await supabase
  .from('posts')
  .select('*')
  .textSearch('title', 'postgresql', {
    type: 'websearch',
    config: 'english'
  })

// Range queries
const { data } = await supabase
  .from('posts')
  .select('*')
  .gte('created_at', '2024-01-01')
  .lte('created_at', '2024-12-31')

// Array contains
const { data } = await supabase
  .from('posts')
  .select('*')
  .contains('tags', ['postgres', 'supabase'])

// JSON operations
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('metadata->theme', 'dark')

// Count without data
const { count } = await supabase
  .from('posts')
  .select('*', { count: 'exact', head: true })

// Pagination
const pageSize = 10
const page = 2
const { data } = await supabase
  .from('posts')
  .select('*')
  .range(page * pageSize, (page + 1) * pageSize - 1)
```

### Database Functions and RPC
```typescript
// Call Postgres function
const { data, error } = await supabase
  .rpc('get_trending_posts', {
    days: 7,
    min_score: 10
  })

// Example function in SQL
/*
CREATE OR REPLACE FUNCTION get_trending_posts(
  days INTEGER,
  min_score INTEGER
)
RETURNS TABLE (
  id UUID,
  title TEXT,
  score INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT p.id, p.title, COUNT(v.id)::INTEGER as score
  FROM posts p
  LEFT JOIN votes v ON p.id = v.post_id
  WHERE p.created_at > NOW() - INTERVAL '1 day' * days
  GROUP BY p.id
  HAVING COUNT(v.id) >= min_score
  ORDER BY score DESC;
END;
$$ LANGUAGE plpgsql;
*/
```
