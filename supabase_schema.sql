-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. PROFILES (Extends Supabase Auth)
create table public.profiles (
  id uuid references auth.users not null primary key,
  email text,
  full_name text,
  phone text,
  role text default 'client' check (role in ('client', 'admin')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.profiles enable row level security;

-- Policies for Profiles
create policy "Public profiles are viewable by everyone." on public.profiles for select using (true);
create policy "Users can insert their own profile." on public.profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile." on public.profiles for update using (auth.uid() = id);

-- 2. TESTS (Catálogo de Pruebas)
create table public.tests (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  description text,
  price numeric not null,
  requirements text, -- e.g. "Ayuno 8 horas"
  category text, -- e.g. "Hematología", "Química"
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.tests enable row level security;

-- Policies for Tests
create policy "Tests are viewable by everyone." on public.tests for select using (true);
create policy "Only admins can insert tests." on public.tests for insert with check (
  exists ( select 1 from public.profiles where id = auth.uid() and role = 'admin' )
);
create policy "Only admins can update tests." on public.tests for update using (
  exists ( select 1 from public.profiles where id = auth.uid() and role = 'admin' )
);
create policy "Only admins can delete tests." on public.tests for delete using (
  exists ( select 1 from public.profiles where id = auth.uid() and role = 'admin' )
);

-- 3. BRANCHES (Sucursales)
create table public.branches (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  address text not null,
  phone text,
  latitude numeric,
  longitude numeric,
  opening_hours text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.branches enable row level security;

-- Policies for Branches
create policy "Branches are viewable by everyone." on public.branches for select using (true);
create policy "Only admins can manage branches." on public.branches for all using (
  exists ( select 1 from public.profiles where id = auth.uid() and role = 'admin' )
);

-- 4. QUOTES (Cotizaciones)
create table public.quotes (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id), -- Can be null for guest quotes if needed, but let's assume logged in for now
  total_amount numeric not null,
  status text default 'pending' check (status in ('pending', 'confirmed', 'completed')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.quote_items (
  id uuid default uuid_generate_v4() primary key,
  quote_id uuid references public.quotes(id) on delete cascade not null,
  test_id uuid references public.tests(id) not null,
  price_at_time numeric not null -- Store price in case it changes later
);

-- Enable RLS
alter table public.quotes enable row level security;
alter table public.quote_items enable row level security;

-- Policies for Quotes
create policy "Users can view their own quotes." on public.quotes for select using (auth.uid() = user_id);
create policy "Users can insert their own quotes." on public.quotes for insert with check (auth.uid() = user_id);
create policy "Admins can view all quotes." on public.quotes for select using (
  exists ( select 1 from public.profiles where id = auth.uid() and role = 'admin' )
);

-- Policies for Quote Items
create policy "Users can view their own quote items." on public.quote_items for select using (
  exists ( select 1 from public.quotes where id = quote_items.quote_id and user_id = auth.uid() )
);

create policy "Users can insert their own quote items." on public.quote_items for insert with check (
  exists ( select 1 from public.quotes where id = quote_items.quote_id and user_id = auth.uid() )
);

-- Trigger to create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name', 'client');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
