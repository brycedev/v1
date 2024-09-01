-- create users table
create table public .users (
  id uuid primary key,
  username text unique not null,
  email text unique not null,
  full_name text,
  avatar_url text,
  bio text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  constraint fk_auth_user foreign key (id) references auth.users(id) on
  delete
    cascade
);

-- create index on username for faster lookups
create index idx_users_username on public .users (username);

-- enable row level security (rls)
alter table
  public .users enable row level security;

-- create a trigger to update the updated_at column
create
or replace function update_updated_at() returns trigger as $$ begin
  new .updated_at = now();

return new;

end;

$$ language plpgsql;

create trigger users_updated_at before
update
  on public .users for each row execute function update_updated_at();

-- create a policy to allow users to read all profiles
create policy read_all_profiles on public .users for
select
  using (true);

-- create a policy to allow users to update their own profile
create policy update_own_profile on public .users for
update
  using (auth.uid() = id);