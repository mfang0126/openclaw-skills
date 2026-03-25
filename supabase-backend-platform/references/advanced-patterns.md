# Advanced Patterns

> Supabase reference: advanced patterns patterns and examples.

## Advanced Patterns

### Optimistic Updates
```typescript
'use client'

import { useState, useOptimistic } from 'react'
import { createClient } from '@/lib/supabase/client'

export function PostList({ initialPosts }: { initialPosts: Post[] }) {
  const [posts, setPosts] = useState(initialPosts)
  const [optimisticPosts, addOptimisticPost] = useOptimistic(
    posts,
    (state, newPost: Post) => [...state, newPost]
  )

  const supabase = createClient()

  const createPost = async (title: string) => {
    const tempPost = {
      id: crypto.randomUUID(),
      title,
      created_at: new Date().toISOString()
    }

    addOptimisticPost(tempPost)

    const { data } = await supabase
      .from('posts')
      .insert({ title })
      .select()
      .single()

    if (data) {
      setPosts([...posts, data])
    }
  }

  return (
    <div>
      {optimisticPosts.map((post) => (
        <div key={post.id}>{post.title}</div>
      ))}
    </div>
  )
}
```

### Infinite Scroll
```typescript
'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'

const PAGE_SIZE = 20

export function InfinitePostList() {
  const [posts, setPosts] = useState<Post[]>([])
  const [page, setPage] = useState(0)
  const [hasMore, setHasMore] = useState(true)

  const supabase = createClient()

  useEffect(() => {
    const loadMore = async () => {
      const { data } = await supabase
        .from('posts')
        .select('*')
        .range(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1)
        .order('created_at', { ascending: false })

      if (data) {
        setPosts([...posts, ...data])
        setHasMore(data.length === PAGE_SIZE)
      }
    }

    loadMore()
  }, [page])

  return (
    <div>
      {posts.map((post) => (
        <div key={post.id}>{post.title}</div>
      ))}
      {hasMore && (
        <button onClick={() => setPage(page + 1)}>
          Load More
        </button>
      )}
    </div>
  )
}
```

### Debounced Search
```typescript
'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { useDebounce } from '@/hooks/use-debounce'

export function SearchPosts() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<Post[]>([])
  const debouncedQuery = useDebounce(query, 300)

  const supabase = createClient()

  useEffect(() => {
    if (!debouncedQuery) {
      setResults([])
      return
    }

    const search = async () => {
      const { data } = await supabase
        .from('posts')
        .select('*')
        .textSearch('title', debouncedQuery)
        .limit(10)

      if (data) setResults(data)
    }

    search()
  }, [debouncedQuery])

  return (
    <div>
      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search posts..."
      />
      {results.map((post) => (
        <div key={post.id}>{post.title}</div>
      ))}
    </div>
  )
}
```

---
