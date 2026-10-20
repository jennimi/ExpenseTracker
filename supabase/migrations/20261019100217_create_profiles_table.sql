create table profiles (
  user_id uuid primary key,
  display_name text,
  timezone text default 'Asia/Jakarta',
  created_at timestamp default now()
);

alter table profiles enable row level security;

create policy "Users can view own profile" on profiles
  for select using (auth.uid() = user_id);
