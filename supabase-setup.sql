-- ============================================================
-- PIB NSR — Tabelas + segurança (RLS) para login e painel admin
-- Execute isto no Supabase: SQL Editor > New query > Run
-- ============================================================

-- ------------------------------------------------------------
-- 1) Tabela de administradores
--    Cada linha = um usuário (do Supabase Auth) que é admin.
-- ------------------------------------------------------------
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  created_at timestamptz default now()
);

alter table public.admins enable row level security;

-- Qualquer pessoa logada pode LER a lista de admins
-- (necessário pra checar "sou admin?" e listar na tela admin-users.html)
create policy "admins_select_logged_in"
  on public.admins for select
  to authenticated
  using (true);

-- Só quem já é admin pode ADICIONAR novo admin
create policy "admins_insert_only_admin"
  on public.admins for insert
  to authenticated
  with check (
    exists (select 1 from public.admins a where a.user_id = auth.uid())
  );

-- Só quem já é admin pode REMOVER admin
create policy "admins_delete_only_admin"
  on public.admins for delete
  to authenticated
  using (
    exists (select 1 from public.admins a where a.user_id = auth.uid())
  );


-- ------------------------------------------------------------
-- 2) Tabela da agenda / eventos
--    Uma linha por evento (dia da semana, nome, ícone, horários)
-- ------------------------------------------------------------
create table if not exists public.agenda_events (
  id bigint generated always as identity primary key,
  day int not null check (day between 0 and 6), -- 0=domingo ... 6=sábado
  name text not null,
  icon text default 'fa-church',
  time text,           -- horário único (ex: "19h30"), OU
  items jsonb,          -- lista de sub-itens (ex: [{"name":"EBD","time":"9h00"}])
  sort_order int default 0,
  updated_at timestamptz default now(),
  updated_by text
);

alter table public.agenda_events enable row level security;

-- Qualquer visitante (mesmo sem login) pode LER a agenda — site público
create policy "agenda_select_public"
  on public.agenda_events for select
  to anon, authenticated
  using (true);

-- Só admins podem INSERIR
create policy "agenda_insert_only_admin"
  on public.agenda_events for insert
  to authenticated
  with check (
    exists (select 1 from public.admins a where a.user_id = auth.uid())
  );

-- Só admins podem ATUALIZAR
create policy "agenda_update_only_admin"
  on public.agenda_events for update
  to authenticated
  using (
    exists (select 1 from public.admins a where a.user_id = auth.uid())
  );

-- Só admins podem DELETAR
create policy "agenda_delete_only_admin"
  on public.agenda_events for delete
  to authenticated
  using (
    exists (select 1 from public.admins a where a.user_id = auth.uid())
  );


-- ------------------------------------------------------------
-- 3) Eventos padrão (só roda se a tabela estiver vazia)
-- ------------------------------------------------------------
insert into public.agenda_events (day, name, icon, items, sort_order)
select * from (values
  (0, 'Domingo', 'fa-church', '[{"name":"EBD","time":"9h00"},{"name":"Culto de Celebração","time":"10h00"}]'::jsonb, 1)
) as v(day, name, icon, items, sort_order)
where not exists (select 1 from public.agenda_events);

insert into public.agenda_events (day, name, icon, time, sort_order)
select * from (values
  (3, 'Culto de Oração', 'fa-pray', '19h30', 2),
  (4, 'Juniores', 'fa-child', '18h00', 3),
  (5, 'Adolescentes', 'fa-users', '19h30', 4),
  (6, 'Jovens', 'fa-user-graduate', '19h30', 5)
) as v(day, name, icon, time, sort_order)
where not exists (select 1 from public.agenda_events where name in ('Culto de Oração','Juniores','Adolescentes','Jovens'));


-- ============================================================
-- PASSO MANUAL — criar o PRIMEIRO administrador (você)
-- ============================================================
-- 1. No Supabase: Authentication > Users > Add user
--    Crie seu e-mail e senha, e clique em "Auto Confirm User" (importante!).
-- 2. Copie o UID gerado (coluna "UID" da lista de usuários).
-- 3. Rode o comando abaixo, TROCANDO o UID e o e-mail pelos seus:

-- insert into public.admins (user_id, email) values
--   ('COLE-O-UID-AQUI', 'seuemail@exemplo.com');
