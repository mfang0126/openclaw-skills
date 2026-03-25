# Storage

> Supabase reference: storage patterns and examples.

## Storage

### File Upload
```typescript
// Upload file
const { data, error } = await supabase.storage
  .from('avatars')
  .upload('public/avatar1.png', file, {
    cacheControl: '3600',
    upsert: false
  })

// Upload with progress
const { data, error } = await supabase.storage
  .from('avatars')
  .upload('public/avatar1.png', file, {
    onUploadProgress: (progress) => {
      console.log(`${progress.loaded}/${progress.total}`)
    }
  })

// Upload from URL
const { data, error } = await supabase.storage
  .from('avatars')
  .uploadToSignedUrl('path', token, file)
```

### File Operations
```typescript
// Download file
const { data, error } = await supabase.storage
  .from('avatars')
  .download('public/avatar1.png')

// Get public URL
const { data } = supabase.storage
  .from('avatars')
  .getPublicUrl('public/avatar1.png')

// Create signed URL (temporary access)
const { data, error } = await supabase.storage
  .from('avatars')
  .createSignedUrl('private/document.pdf', 3600) // 1 hour

// List files
const { data, error } = await supabase.storage
  .from('avatars')
  .list('public', {
    limit: 100,
    offset: 0,
    sortBy: { column: 'name', order: 'asc' }
  })

// Delete file
const { data, error } = await supabase.storage
  .from('avatars')
  .remove(['public/avatar1.png'])

// Move file
const { data, error } = await supabase.storage
  .from('avatars')
  .move('public/avatar1.png', 'public/avatar2.png')
```

### Image Transformations
```typescript
// Transform image
const { data } = supabase.storage
  .from('avatars')
  .getPublicUrl('avatar1.png', {
    transform: {
      width: 200,
      height: 200,
      resize: 'cover',
      quality: 80
    }
  })

// Available transformations
// width, height, resize (cover|contain|fill),
// quality (1-100), format (origin|jpeg|png|webp)
```

### Storage RLS
```sql
-- Enable RLS on storage
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = 'public');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```
