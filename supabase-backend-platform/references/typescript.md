# TypeScript Type Generation

> Supabase reference: typescript type generation patterns and examples.

## TypeScript Type Generation

### Generate Types from Database
```bash
# Install CLI
npm install -D supabase

# Login
npx supabase login

# Link project
npx supabase link --project-ref your-project-ref

# Generate types
npx supabase gen types typescript --project-id your-project-ref > types/supabase.ts

# Or from local database
npx supabase gen types typescript --local > types/supabase.ts
```

### Use Generated Types
```typescript
// types/supabase.ts (generated)
export type Database = {
  public: {
    Tables: {
      posts: {
        Row: {
          id: string
          title: string
          content: string | null
          author_id: string
          created_at: string
        }
        Insert: {
          id?: string
          title: string
          content?: string | null
          author_id: string
          created_at?: string
        }
        Update: {
          id?: string
          title?: string
          content?: string | null
          author_id?: string
          created_at?: string
        }
      }
    }
  }
}

// Usage
import { createClient } from '@supabase/supabase-js'
import { Database } from '@/types/supabase'

const supabase = createClient<Database>(url, key)

// Type-safe queries
const { data } = await supabase
  .from('posts') // TypeScript knows this table exists
  .select('title, content') // Autocomplete for columns
  .single()

// data is typed as { title: string; content: string | null }
```
