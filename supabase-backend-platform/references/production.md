# Production Deployment

> Supabase reference: production deployment patterns and examples.

## Production Deployment

### Database Optimization
```sql
-- Add indexes for common queries
CREATE INDEX posts_created_at_idx ON posts(created_at DESC);
CREATE INDEX posts_author_status_idx ON posts(author_id, status);

-- Optimize full-text search
CREATE INDEX posts_title_search_idx ON posts
USING GIN (to_tsvector('english', title));

-- Analyze query performance
EXPLAIN ANALYZE
SELECT * FROM posts WHERE author_id = 'xxx';

-- Vacuum and analyze
VACUUM ANALYZE posts;
```

### Connection Pooling
```typescript
// Use connection pooling for serverless
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(url, key, {
  db: {
    schema: 'public',
  },
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
  global: {
    headers: { 'x-my-custom-header': 'my-value' },
  },
})

// Configure pool in Supabase dashboard
// Settings > Database > Connection pooling
```

### Monitoring
```typescript
// Enable query logging
const supabase = createClient(url, key, {
  global: {
    fetch: async (url, options) => {
      console.log('Query:', url)
      return fetch(url, options)
    }
  }
})

// Monitor in Supabase Dashboard
// - Database performance
// - API usage
// - Storage usage
// - Auth activity
```

### Backup Strategy
```bash
# Automatic backups (Pro plan+)
# Daily backups with point-in-time recovery

# Manual backup
pg_dump -h db.xxx.supabase.co -U postgres -d postgres > backup.sql

# Restore
psql -h db.xxx.supabase.co -U postgres -d postgres < backup.sql
```
