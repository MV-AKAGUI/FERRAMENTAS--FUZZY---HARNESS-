import chainlit as cl

@cl.on_chat_start
async def on_chat_start():
    # Mensagem de boas-vindas do Chainlit
    await cl.Message(
        content="""🚀 **Interface de Agentes Iniciada!**
        
Esta é a interface do seu sistema de **Homeostase Computacional**. 
Em breve, as mensagens digitadas aqui serão roteadas para o **LangGraph**, passarão pelo **Ollama** (Qwen, Mistral, SaulLM) e buscarão dados no **PostgreSQL (RAG)**."""
    ).send()

@cl.on_message
async def on_message(message: cl.Message):
    # Por enquanto é apenas um eco. Depois plugaremos a Lógica Fuzzy aqui.
    resposta_simulada = f"🧠 *Agente escutou:* '{message.content}'. (O cérebro LangGraph será plugado aqui em breve!)"
    await cl.Message(content=resposta_simulada).send()
