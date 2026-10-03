import streamlit as st

st.set_page_config(page_title="Arquiteto Neural", page_icon="🧠")
st.title("🚀 Interface de Agentes Iniciada!")

st.markdown("""
Esta é a interface do seu sistema de **Homeostase Computacional**.
Em breve, as mensagens digitadas aqui serão roteadas para o **LangGraph**, passarão pelo **Ollama** (Qwen, Mistral, SaulLM) e buscarão dados no **PostgreSQL (RAG)**.
""")

if "messages" not in st.session_state:
    st.session_state.messages = []

for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

if prompt := st.chat_input("Diga Olá para o Arquiteto Neural..."):
    with st.chat_message("user"):
        st.markdown(prompt)
    st.session_state.messages.append({"role": "user", "content": prompt})

    resposta = f"🧠 *Agente escutou:* '{prompt}'. (O cérebro LangGraph será plugado aqui em breve!)"
    with st.chat_message("assistant"):
        st.markdown(resposta)
    st.session_state.messages.append({"role": "assistant", "content": resposta})
