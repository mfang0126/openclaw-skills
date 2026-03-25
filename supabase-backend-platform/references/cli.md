# Supabase CLI and Local Development

> Supabase reference: supabase cli and local development patterns and examples.

## Supabase CLI and Local Development

### Setup Local Development
```bash
# Initialize Supabase
npx supabase init

# Start local Supabase (Postgres, Auth, Storage, etc.)
npx supabase start

# Stop
npx supabase stop

# Reset database
npx supabase db reset

# Status
npx supabase status
```

### Database Migrations
```bash
# Create migration
npx supabase migration new create_posts_table

# Edit migration file
# supabase/migrations/20240101000000_create_posts_table.sql

# Apply migrations
npx supabase db push

# Pull remote schema
npx supabase db pull

# Diff local vs remote
npx supabase db diff
```

### Migration Example
```sql
-- supabase/migrations/20240101000000_create_posts_table.sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT,
  author_id UUID NOT NULL REFERENCES auth.users(id),
  status TEXT NOT NULL DEFAULT 'draft',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view published posts"
ON posts FOR SELECT
USING (status = 'published');

CREATE POLICY "Users can create their own posts"
ON posts FOR INSERT
WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Users can update their own posts"
ON posts FOR UPDATE
USING (auth.uid() = author_id);

-- Indexes
CREATE INDEX posts_author_id_idx ON posts(author_id);
CREATE INDEX posts_status_idx ON posts(status);

-- Trigger for updated_at
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON posts
FOR EACH ROW
EXECUTE FUNCTION moddatetime(updated_at);
```
