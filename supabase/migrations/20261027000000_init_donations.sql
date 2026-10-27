-- Donations, projects, and public tracker access.

create extension if not exists pgcrypto;

create table public.projects (
  id    text primary key,
  name  text not null,
  active boolean not null default true
);

insert into public.projects (id, name) values
  ('sembako',   'Sembako untuk keluarga prasejahtera'),
  ('beasiswa',  'Beasiswa belajar anak'),
  ('kesehatan', 'Bantuan kesehatan darurat');

create type public.donation_status as enum
  ('pending', 'verified', 'distributed', 'proof_uploaded');

create table public.donations (
  id           uuid primary key default gen_random_uuid(),
  token        text not null unique default encode(gen_random_bytes(12), 'hex'), -- dipakai di link pelacak
  base         integer not null check (base >= 10000),
  code         smallint not null check (code between 1 and 999),
  total        integer generated always as (base + code) stored,
  project_id   text not null references public.projects(id),
  donor_name   text,
  message      text check (char_length(message) <= 280),
  status       public.donation_status not null default 'pending',
  verified_at  timestamptz,
  distributed_at timestamptz,
  proof_urls   text[] not null default '{}',
  proof_note   text,
  created_at   timestamptz not null default now()
);

-- Satu nominal total hanya boleh dipakai satu donasi yang masih pending,
-- supaya transfer bisa dicocokkan ke donasi yang benar.
create unique index donations_pending_total_uq
  on public.donations (total) where status = 'pending';

alter table public.projects  enable row level security;
alter table public.donations enable row level security;

-- Project aktif boleh dibaca publik.
create policy "projects readable" on public.projects
  for select to anon, authenticated using (active);

-- Tabel donations tertutup untuk anon; hanya admin (authenticated) yang punya akses langsung.
create policy "admin all" on public.donations
  for all to authenticated using (true) with check (true);

-- Buat donasi: pilih kode unik acak yang belum terpakai untuk nominal tersebut.
create function public.create_donation(
  p_base int, p_project text, p_name text default null, p_message text default null
) returns table (token text, total int, code int)
language plpgsql security definer set search_path = public as $$
declare
  c int; tries int := 0; d public.donations;
begin
  loop
    c := 1 + floor(random() * 999)::int;
    begin
      insert into public.donations (base, code, project_id, donor_name, message)
      values (p_base, c, p_project, nullif(trim(p_name), ''), nullif(trim(p_message), ''))
      returning * into d;
      return query select d.token, d.total, d.code::int;
      return;
    exception when unique_violation then
      tries := tries + 1;
      if tries > 20 then raise exception 'Kode unik habis, coba nominal lain'; end if;
    end;
  end loop;
end $$;

-- Baca status satu donasi lewat token (tanpa membuka seluruh tabel).
create function public.get_donation(p_token text)
returns table (
  total int, project_name text, donor_name text, message text, status public.donation_status,
  created_at timestamptz, verified_at timestamptz, distributed_at timestamptz,
  proof_urls text[], proof_note text
)
language sql stable security definer set search_path = public as $$
  select d.total, p.name, d.donor_name, d.message, d.status,
         d.created_at, d.verified_at, d.distributed_at, d.proof_urls, d.proof_note
  from donations d join projects p on p.id = d.project_id
  where d.token = p_token;
$$;

-- Agregat publik untuk dashboard transparansi (tanpa data pribadi).
create view public.public_summary as
select project_id,
       count(*) filter (where status <> 'pending')                       as donors,
       coalesce(sum(base) filter (where status <> 'pending'), 0)         as raised,
       coalesce(sum(base) filter (where status in ('distributed','proof_uploaded')), 0) as distributed
from public.donations group by project_id;

grant select on public.public_summary to anon, authenticated;
grant execute on function public.create_donation(int, text, text, text) to anon, authenticated;
grant execute on function public.get_donation(text) to anon, authenticated;

-- Bucket bukti penyaluran: publik bisa lihat, hanya admin yang bisa unggah.
insert into storage.buckets (id, name, public) values ('proofs', 'proofs', true)
on conflict (id) do nothing;

create policy "proofs admin upload" on storage.objects
  for insert to authenticated with check (bucket_id = 'proofs');
create policy "proofs admin update" on storage.objects
  for update to authenticated using (bucket_id = 'proofs');
