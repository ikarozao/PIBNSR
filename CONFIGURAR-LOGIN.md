# Como configurar o login e publicar no Netlify

O site usa o **Supabase** para login e para guardar os dados da agenda.
É gratuito para o tamanho de uma igreja e não exige servidor — o
`js/supabase-config.js` já está com as chaves do seu projeto.

## Passo 1 — Criar as tabelas no Supabase

1. Acesse https://supabase.com/dashboard e abra seu projeto.
2. Vá em **SQL Editor** (menu lateral) → **New query**.
3. Abra o arquivo `supabase-setup.sql` (está na pasta do site), copie todo
   o conteúdo, cole no editor e clique em **Run**.
   - Isso cria as tabelas `admins` e `agenda_events`, as regras de
     segurança (RLS), e já popula a agenda com os eventos padrão.

## Passo 2 — Ativar login por e-mail/senha

1. No Supabase, vá em **Authentication → Providers**.
2. Confirme que **Email** está habilitado (já vem ativado por padrão).
3. (Opcional, recomendado) Em **Authentication → Settings**, desative
   "Confirm email" se quiser que os admins consigam logar sem precisar
   clicar num link de confirmação — como as contas serão criadas
   manualmente por você mesmo, isso simplifica.

## Passo 3 — Criar o primeiro administrador (você)

1. No Supabase, vá em **Authentication → Users → Add user**.
2. Preencha e-mail e senha, e marque **"Auto Confirm User"**.
3. Clique em **Create user**.
4. Copie o **UID** que aparece na lista de usuários.
5. Volte no **SQL Editor** e rode (troque UID e e-mail pelos seus):

```sql
insert into public.admins (user_id, email) values
  ('COLE-O-UID-AQUI', 'seuemail@exemplo.com');
```

Pronto — esse usuário já é administrador. Os próximos 4 admins da
liderança você mesmo consegue adicionar depois, direto pela tela
`admin-users.html` do site (ela te guia a criar o usuário no Dashboard
e depois liberar o acesso admin por lá).

## Passo 4 — Publicar no Netlify

1. Acesse https://app.netlify.com
2. Clique em **"Add new site" → "Deploy manually"**.
3. Arraste a pasta `PIBNSR` (a pasta inteira, com `index.html` dentro)
   para a área de upload.
4. Aguarde o deploy terminar — o Netlify já te dá uma URL do tipo
   `nome-aleatorio.netlify.app`. Você pode trocar esse nome em
   **Site settings → Change site name**.

> Alternativa: se preferir, conecte o Netlify direto a um repositório
> Git (GitHub/GitLab) com esses arquivos, e todo `git push` atualiza o
> site automaticamente.

## Passo 5 — Testar

1. Acesse a URL do Netlify + `/login.html`.
2. Entre com o e-mail/senha criados no Passo 3.
3. Você será redirecionado para `admin.html`, onde pode editar a agenda.
4. Ao salvar, a página inicial já mostra os eventos atualizados
   automaticamente para qualquer visitante.

## Resumo do que cada pessoa vê

- **Visitante comum**: vê o site normalmente, com a agenda sempre atualizada.
- **Pessoa logada, mas sem permissão de admin**: navega normal, mas não
  consegue abrir `admin.html` (é redirecionada de volta pro início).
- **Admin**: acessa `admin.html` para editar a agenda, e `admin-users.html`
  para adicionar/remover outros administradores.

## Dúvidas comuns

- **"É seguro deixar a chave do Supabase visível no código?"** Sim — a
  chave usada (`sb_publishable_...`) é a chave pública, feita para rodar
  no navegador. Quem protege os dados de verdade são as políticas de
  segurança (RLS) criadas pelo `supabase-setup.sql`, que garantem que só
  admins conseguem editar a agenda, mesmo que alguém veja essa chave.
- **"Por que não dá pra criar novo admin direto pelo painel?"** Criar
  contas de outras pessoas exige a chave "service_role" do Supabase, que
  nunca deve aparecer no código do site (isso deixaria qualquer visitante
  criar contas). Por isso o fluxo pede pra criar a conta no Dashboard e
  só liberar a permissão de admin pelo site.
- **"É gratuito?"** Sim, o plano gratuito do Supabase e do Netlify são
  mais que suficientes para o tráfego de um site de igreja.
