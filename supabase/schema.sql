-- शाही ब्याव: Supabase database setup
create extension if not exists pgcrypto;

create table if not exists public.weddings (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  slug text not null unique check (slug ~ '^[a-z0-9-]{3,60}$'),
  groom text not null default 'वर का नाम',
  bride text not null default 'वधू का नाम',
  groom_parents text default '',
  bride_parents text default '',
  family text default 'समस्त परिवार',
  wedding_at timestamptz,
  muhurta text default '',
  venue text default '',
  address text default '',
  map_url text default '',
  message text default '',
  blessing text default '',
  groom_photo text default '',
  bride_photo text default '',
  music_url text default '',
  music_off boolean not null default false,
  events jsonb not null default '[]'::jsonb,
  gallery jsonb not null default '[]'::jsonb,
  wine text not null default '#4b1023',
  gold text not null default '#d7b36a',
  published boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.rsvps (
  id uuid primary key default gen_random_uuid(),
  wedding_id uuid not null references public.weddings(id) on delete cascade,
  guest_name text not null check (char_length(guest_name) between 1 and 100),
  guest_count integer not null check (guest_count between 1 and 30),
  attending text not null check (attending in ('yes','no','maybe')),
  message text not null default '' check (char_length(message) <= 500),
  created_at timestamptz not null default now()
);

create index if not exists weddings_owner_idx on public.weddings(owner_id);
create index if not exists rsvps_wedding_idx on public.rsvps(wedding_id, created_at desc);

alter table public.weddings enable row level security;
alter table public.rsvps enable row level security;

drop policy if exists "Guests can read published active invitations" on public.weddings;
create policy "Guests can read published active invitations"
on public.weddings for select to anon, authenticated
using (published = true and active = true);

drop policy if exists "Owners can read their weddings" on public.weddings;
create policy "Owners can read their weddings"
on public.weddings for select to authenticated
using (owner_id = auth.uid());

drop policy if exists "Owners can create weddings" on public.weddings;
create policy "Owners can create weddings"
on public.weddings for insert to authenticated
with check (owner_id = auth.uid());

drop policy if exists "Owners can update weddings" on public.weddings;
create policy "Owners can update weddings"
on public.weddings for update to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

drop policy if exists "Guests can submit RSVP for a published invitation" on public.rsvps;
create policy "Guests can submit RSVP for a published invitation"
on public.rsvps for insert to anon, authenticated
with check (
  exists (
    select 1 from public.weddings w
    where w.id = wedding_id and w.published = true and w.active = true
  )
);

drop policy if exists "Only wedding owners can read RSVPs" on public.rsvps;
create policy "Only wedding owners can read RSVPs"
on public.rsvps for select to authenticated
using (
  exists (
    select 1 from public.weddings w
    where w.id = wedding_id and w.owner_id = auth.uid()
  )
);

-- Storage: सार्वजनिक निमंत्रण चित्र/संगीत पढ़ सकते हैं; केवल संबंधित wedding owner अपलोड/बदल/हटा सकता है.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('wedding-media', 'wedding-media', true, 12582912,
  array['image/jpeg','image/png','image/webp','image/avif','audio/mpeg','audio/mp4','audio/aac','audio/ogg'])
on conflict (id) do update set public = true, file_size_limit = 12582912;

drop policy if exists "Public can view wedding media" on storage.objects;
create policy "Public can view wedding media"
on storage.objects for select to anon, authenticated
using (bucket_id = 'wedding-media');

drop policy if exists "Owners upload into their wedding folder" on storage.objects;
create policy "Owners upload into their wedding folder"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'wedding-media'
  and exists (
    select 1 from public.weddings w
    where w.slug = split_part(name, '/', 1)
      and w.owner_id = auth.uid()
  )
);

drop policy if exists "Owners update their wedding media" on storage.objects;
create policy "Owners update their wedding media"
on storage.objects for update to authenticated
using (
  bucket_id = 'wedding-media'
  and exists (
    select 1 from public.weddings w
    where w.slug = split_part(name, '/', 1)
      and w.owner_id = auth.uid()
  )
)
with check (
  bucket_id = 'wedding-media'
  and exists (
    select 1 from public.weddings w
    where w.slug = split_part(name, '/', 1)
      and w.owner_id = auth.uid()
  )
);

drop policy if exists "Owners delete their wedding media" on storage.objects;
create policy "Owners delete their wedding media"
on storage.objects for delete to authenticated
using (
  bucket_id = 'wedding-media'
  and exists (
    select 1 from public.weddings w
    where w.slug = split_part(name, '/', 1)
      and w.owner_id = auth.uid()
  )
);
