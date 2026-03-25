# Row Level Security (RLS)

> Supabase reference: row level security (rls) patterns and examples.

## Row Level Security (RLS)

### RLS Fundamentals
Postgres Row Level Security controls data access at the database level:

```sql
-- Enable RLS on table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read all published posts
CREATE POLICY "Public posts are viewable by everyone"
ON posts FOR SELECT
USING (status = 'published');

-- Policy: Users can only update their own posts
CREATE POLICY "Users can update own posts"
ON posts FOR UPDATE
USING (auth.uid() = author_id);

-- Policy: Authenticated users can insert posts
CREATE POLICY "Authenticated users can create posts"
ON posts FOR INSERT
WITH CHECK (auth.uid() = author_id);

-- Policy: Users can delete their own posts
CREATE POLICY "Users can delete own posts"
ON posts FOR DELETE
USING (auth.uid() = author_id);
```

### Common RLS Patterns
```sql
-- Public read, authenticated write
CREATE POLICY "Anyone can view posts"
ON posts FOR SELECT
USING (true);

CREATE POLICY "Authenticated users can create posts"
ON posts FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

-- Organization-based access
CREATE POLICY "Users can view org data"
ON documents FOR SELECT
USING (
  organization_id IN (
    SELECT organization_id
    FROM memberships
    WHERE user_id = auth.uid()
  )
);

-- Role-based access
CREATE POLICY "Admins can do anything"
ON posts FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid()
    AND role = 'admin'
  )
);

-- Time-based access
CREATE POLICY "View published or scheduled posts"
ON posts FOR SELECT
USING (
  status = 'published'
  OR (status = 'scheduled' AND publish_at <= NOW())
);
```

### RLS Helper Functions
```sql
-- Get current user ID
SELECT auth.uid();

-- Get current user JWT
SELECT auth.jwt();

-- Get specific claim
SELECT auth.jwt()->>'email';

-- Custom claims
SELECT auth.jwt()->'app_metadata'->>'role';
```
