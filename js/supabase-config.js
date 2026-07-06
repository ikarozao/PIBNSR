// ============================================================
// CONFIGURAÇÃO DO SUPABASE
// ============================================================
const SUPABASE_URL = "https://dzcjcvyyuaidsgzagyqv.supabase.co";
const SUPABASE_KEY = "sb_publishable_CqOBy88WQvZugRVoUeJCqA_jmoUQ44s";

const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

// ------------------------------------------------------------
// Helper: verifica se o usuário logado é admin
// ------------------------------------------------------------
async function isAdmin(user) {
  if (!user) return false;
  const { data, error } = await supabase
    .from('admins')
    .select('user_id')
    .eq('user_id', user.id)
    .maybeSingle();
  if (error) {
    console.warn('Erro ao checar admin:', error.message);
    return false;
  }
  return !!data;
}

// ------------------------------------------------------------
// Helper: pega o usuário logado atual (ou null)
// ------------------------------------------------------------
async function getCurrentUser() {
  const { data } = await supabase.auth.getUser();
  return data?.user || null;
}

// ------------------------------------------------------------
// Helper: protege uma página, exige login (e opcionalmente admin)
// Uso: protectPage({ requireAdmin: true }).then(user => {...})
// ------------------------------------------------------------
async function protectPage({ requireAdmin = false } = {}) {
  const user = await getCurrentUser();
  if (!user) {
    window.location.href = 'login.html';
    return null;
  }
  if (requireAdmin) {
    const admin = await isAdmin(user);
    if (!admin) {
      alert('Você não tem permissão de administrador.');
      window.location.href = 'index.html';
      return null;
    }
  }
  return user;
}
