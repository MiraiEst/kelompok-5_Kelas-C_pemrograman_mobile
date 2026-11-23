-- Supabase Storage setup for Imagi Auction photos.
-- Run once in Supabase Dashboard -> SQL Editor -> New query -> Run.
--
-- Only the photo FILES live here; login and data stay on Firebase.
-- The app uploads with the anon key, so Supabase can't tell which Firebase user
-- is uploading. These rules limit what can be uploaded (JPEG images up to 5 MB,
-- only in the app's folders) but not who uploads. Good enough for a class
-- project; for production, upload through a Cloud Function instead.

-- Public bucket: anyone with the URL can view a photo (needed to show them in the app).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', true, 5242880, array['image/jpeg'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Folders the app writes to:
--   listings/{uid}/{listingId}/{index}.jpg
--   users/{uid}/avatar.jpg
--   cases/{uid}/{caseId}/{index}.jpg
drop policy if exists "imagi photos insert" on storage.objects;
create policy "imagi photos insert" on storage.objects
  for insert to anon, authenticated
  with check (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] in ('listings', 'users', 'cases')
    and storage.extension(name) = 'jpg'
  );

-- Replacing a file (new avatar, re-uploaded listing photo) needs select + update.
drop policy if exists "imagi photos select" on storage.objects;
create policy "imagi photos select" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'photos');

drop policy if exists "imagi photos update" on storage.objects;
create policy "imagi photos update" on storage.objects
  for update to anon, authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] in ('listings', 'users'))
  with check (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] in ('listings', 'users')
    and storage.extension(name) = 'jpg'
  );

-- No delete policy: files can't be deleted from the app.
