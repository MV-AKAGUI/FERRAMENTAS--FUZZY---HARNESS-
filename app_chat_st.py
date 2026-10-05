import streamlit as st
import psycopg2
from langchain_ollama import OllamaEmbeddings
import os
from PIL import Image
import base64

def get_base64_image(image_path):
    with open(image_path, "rb") as img_file:
        return f"data:image/png;base64,{base64.b64encode(img_file.read()).decode()}"

# ==========================================
# CONFIGURAÇÃO DE TELA (LAYOUT WIDE)
# ==========================================
st.set_page_config(page_title="Clínica Neural | Dai", page_icon="👩🏻‍💼", layout="wide")

# ==========================================
# 0. TELA DE AUTENTICAÇÃO (LOGIN)
# ==========================================
if "autenticado" not in st.session_state:
    st.session_state.autenticado = False

# Banco de dados Mock para testes de Perfil
MOCK_USERS = {
    "admin": {"senha": "123", "perfil": "Diretoria", "nome": "Ronaldo"},
    "dev": {"senha": "123", "perfil": "Desenvolvimento", "nome": "Engenheiro"},
    "cliente": {"senha": "123", "perfil": "Cliente B2B", "nome": "Parceiro Daisugi"}
}

if not st.session_state.autenticado:
    # Mostramos o Avatar na portaria também para dar boas-vindas
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        if os.path.exists("Dai_Avatar.png"):
            st.image("Dai_Avatar.png", width=150)
            
        st.markdown("<h1 style='color: #00B4D8;'>🔒 Portaria - Daisugi</h1>", unsafe_allow_html=True)
        st.markdown("*Por favor, identifique-se antes de acessar a clínica.*")
        
        with st.form("login_form"):
            usuario = st.text_input("Usuário (Dica: admin, dev, cliente)").lower()
            senha = st.text_input("Senha (Dica: 123)", type="password")
            submit_btn = st.form_submit_button("Entrar na Clínica")
            
            if submit_btn:
                if usuario in MOCK_USERS and MOCK_USERS[usuario]["senha"] == senha:
                    st.session_state.autenticado = True
                    st.session_state.paciente_nome = MOCK_USERS[usuario]["nome"]
                    st.session_state.paciente_perfil = MOCK_USERS[usuario]["perfil"]
                    st.rerun()
                else:
                    st.error("❌ Credenciais inválidas.")
    
    # Se não autenticado, paramos o código aqui
    st.stop()

# ==========================================
# 1. CONEXÃO COM O RAG (O Cérebro da Dai)
# ==========================================
def get_db_connection():
    return psycopg2.connect(
        host="localhost",
        port="5432",
        database="memoria_vetorial",
        user="admin",
        password="masterkey123"
    )

def setup_dai_memory():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("CREATE EXTENSION IF NOT EXISTS vector;")
        cur.execute("""
            CREATE TABLE IF NOT EXISTS dai_memoria (
                id SERIAL PRIMARY KEY,
                texto_original TEXT,
                embedding vector(768),
                acao_tipo TEXT,
                destino TEXT,
                criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        st.error(f"Erro na homeostase do banco de dados: {e}")

setup_dai_memory()

@st.cache_resource
def get_embeddings_model():
    return OllamaEmbeddings(model="nomic-embed-text")

embedder = get_embeddings_model()

def buscar_na_memoria(texto):
    vetor_busca = embedder.embed_query(texto)
    vetor_str = f"[{','.join(map(str, vetor_busca))}]"
    
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT texto_original, acao_tipo, destino, embedding <-> %s::vector AS distancia
        FROM dai_memoria
        ORDER BY distancia ASC
        LIMIT 1;
    """, (vetor_str,))
    
    resultado = cur.fetchone()
    cur.close()
    conn.close()
    return resultado, vetor_busca

# ==========================================
# 3. INTERFACE DA CLÍNICA
# ==========================================

# Botão de Logout no topo da barra lateral
with st.sidebar:
    st.markdown(f"👤 **Usuário Logado:** {st.session_state.paciente_nome}")
    st.markdown(f"🏷️ **Perfil de Acesso:** {st.session_state.paciente_perfil}")
    if st.button("Sair (Logout)"):
        st.session_state.autenticado = False
        st.rerun()

col_chat, col_salas = st.columns([6, 4])

# ----------------------------------------------------
# LADO DIREITO: O CORREDOR E PRONTUÁRIOS
# ----------------------------------------------------
with col_salas:
    st.markdown(f"### 🚪 Corredor de {st.session_state.paciente_perfil}")
    
    # Renderiza as portas dependendo do perfil do usuário
    col_s1, col_s2 = st.columns(2)
    
    if st.session_state.paciente_perfil == "Desenvolvimento":
        with col_s1:
            st.success("💻 Dr. Taylor Code (Orquestrador)\n\n`🟢 Online`")
            st.info("⚙️ DevOps (Infra)\n\n`🟢 Online`")
        with col_s2:
            st.warning("🐛 Caçador de Bugs (QA)\n\n`🟢 Online`")
            
    elif st.session_state.paciente_perfil == "Cliente B2B":
        with col_s1:
            st.info("📈 Dr. Qwen (Consultoria)\n\n`🟢 Online`")
        with col_s2:
            st.warning("⚖️ Dr. Saul (Contratos)\n\n`🟢 Online`")
            
    else: # Diretoria / Admin vê tudo
        with col_s1:
            st.info("📈 Dr. Qwen (Finanças)\n\n`🟢 Online`")
            st.error("🔍 Mistral (Investigador)\n\n`🟢 Online`")
        with col_s2:
            st.warning("⚖️ Dr. Saul (Jurídico)\n\n`🟢 Online`")
            st.success("🧠 Llama 3.1 (Maestro)\n\n`🟢 Online`")
    
    st.markdown("---")
    
    # FICHA DO PACIENTE
    st.markdown("### 📋 Ficha do Paciente (Prontuário)")
    st.text_area("Histórico Clínico e Queixas Anteriores:", value="Nenhum histórico grave registrado hoje.\n\nAguardando triagem...", height=100, disabled=True)
    
    # RESULTADO / LAUDO FINAL
    st.markdown("### 💊 Laudo de Triagem / Diagnóstico")
    
    # Checa se existe um laudo guardado na sessao
    laudo_texto = st.session_state.get("laudo_final", "Nenhum laudo emitido ainda. Fale com a Dai à esquerda.")
    st.success(laudo_texto)


# ----------------------------------------------------
# LADO ESQUERDO: A RECEPÇÃO (CHAT DA DAI)
# ----------------------------------------------------
with col_chat:
    st.markdown("<h3 style='color: #00B4D8;'>台 Dai - Triagem e Roteamento</h3>", unsafe_allow_html=True)
    st.markdown("<span style='color: #00A86B;'>*A Recepção Inteligente baseada em Equilibrio, Memória e Sentido.*</span>", unsafe_allow_html=True)

    if "messages" not in st.session_state or st.session_state.messages[0]["content"] != "Olá, sou a Dai. O que te trouxe até aqui? Como posso te ajudar?":
        st.session_state.messages = [{"role": "assistant", "content": "Olá, sou a Dai. O que te trouxe até aqui? Como posso te ajudar?"}]

    # Carrega a imagem via Base64 (Método à prova de falhas)
    if os.path.exists("Dai_Avatar.png"):
        dai_avatar = get_base64_image("Dai_Avatar.png")
    else:
        dai_avatar = "👩🏻‍💼"

    # Renderiza o histórico
    for message in st.session_state.messages:
        avatar = dai_avatar if message["role"] == "assistant" else "👤"
        with st.chat_message(message["role"], avatar=avatar):
            st.markdown(message["content"])

    # Input do usuário
    if prompt := st.chat_input("Diga sua queixa à Dai..."):
        st.session_state.messages.append({"role": "user", "content": prompt})
        with st.chat_message("user", avatar="👤"):
            st.markdown(prompt)

        with st.chat_message("assistant", avatar=dai_avatar):
            if prompt.strip().lower() == "/auditoria":
                st.session_state.laudo_final = "🕵️ Auditoria interna acionada. Imprimindo logs no console."
                st.markdown("🤫 Extraindo registros da mente vetorial...")
                st.session_state.messages.append({"role": "assistant", "content": "🤫 Extraindo registros da mente vetorial..."})
                st.rerun()
            
            resultado, vetor = buscar_na_memoria(prompt)
            distancia = resultado[3] if resultado else 999.0
            
            if resultado and distancia < 0.3:
                destino = resultado[2]
                resposta_dai = f"🔍 Suas métricas são claras. Encaminhando para o **{destino}**..."
                st.session_state.laudo_final = f"✅ Triagem Concluída: Rota identificada para {destino}."
                st.markdown(resposta_dai)
                st.session_state.messages.append({"role": "assistant", "content": resposta_dai})
                st.rerun() # Atualiza a tela para mostrar o laudo na direita
            else:
                resposta_dai = (
                    "Para que eu possa direcionar sua queixa para o corredor correto, preciso que refine seu pedido:\n"
                    "**(i) O QUE** você precisa resolver?\n"
                    "**(ii) COMO** espera que a equipe ajude?\n"
                    "**(iii) POR QUE** isso é uma prioridade agora?"
                )
                st.session_state.laudo_final = "⚠️ Pendente: A Dai solicitou mais clareza ao paciente antes de acionar os especialistas."
                st.markdown(resposta_dai)
                st.session_state.messages.append({"role": "assistant", "content": resposta_dai})
                st.rerun() # Atualiza o painel direito
