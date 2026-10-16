# ============================================
# DAI_VIBE_CODE AUTO-START DAEMON
# Garante que Ollama + Dai_Vibe_Code estão SEMPRE ativos
# ============================================
# Versão: 1.0 | Data: 2026-10-16
# Responsável: Claude PMO (Orquestrador)
# ============================================

param(
    [string]$Mode = "start",  # start | stop | status | restart
    [int]$Port = 11434       # Ollama port
)

$ErrorActionPreference = "SilentlyContinue"

# ============================================
# CONFIGURAÇÕES
# ============================================
$OllamaExe = "C:\Users\Ronaldo Akagui.SUG00245\AppData\Local\Programs\Ollama\ollama.exe"
$OllamaPort = $Port
$LogDir = "C:\Users\RONALD~1.SUG\AppData\Local\Temp\dai-vibe-code"
$LogFile = "$LogDir\daemon.log"
$StatusFile = "$LogDir\status.json"

# Criar diretório de logs
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# ============================================
# FUNÇÕES
# ============================================

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp | $Message" | Tee-Object -FilePath $LogFile -Append
}

function Start-OllamaService {
    Write-Log "🚀 Iniciando Ollama..."

    if (-not (Test-Path $OllamaExe)) {
        Write-Log "❌ ERRO: Ollama não encontrado em $OllamaExe"
        return $false
    }

    # Verificar se já está rodando
    $existing = Get-Process ollama -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Log "✅ Ollama já está rodando (PID: $($existing.Id))"
        return $true
    }

    # Iniciar Ollama
    try {
        Start-Process -FilePath $OllamaExe -ArgumentList "serve" `
            -WindowStyle Hidden -ErrorAction Stop

        Start-Sleep -Seconds 3

        # Verificar resposta
        $response = Invoke-WebRequest -Uri "http://localhost:$OllamaPort/api/tags" `
            -ErrorAction SilentlyContinue -TimeoutSec 5

        if ($response.StatusCode -eq 200) {
            Write-Log "✅ Ollama iniciado com sucesso (porta $OllamaPort)"

            # Listar modelos
            $models = $response.Content | ConvertFrom-Json | Select-Object -ExpandProperty models
            Write-Log "📦 Modelos disponíveis: $($models.Count)"
            $models | ForEach-Object {
                Write-Log "   - $($_.name)"
            }
            return $true
        }
    } catch {
        Write-Log "❌ Erro ao iniciar Ollama: $_"
        return $false
    }
}

function Get-OllamaStatus {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$OllamaPort/api/tags" `
            -ErrorAction SilentlyContinue -TimeoutSec 5

        if ($response.StatusCode -eq 200) {
            $models = $response.Content | ConvertFrom-Json | Select-Object -ExpandProperty models
            return @{
                status = "ATIVO"
                port = $OllamaPort
                modelos = $models.Count
                modelos_lista = $models.name
                timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }
    } catch {
        return @{
            status = "INATIVO"
            erro = $_.Exception.Message
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
}

function Write-StatusFile {
    param([hashtable]$Status)
    $Status | ConvertTo-Json | Set-Content -Path $StatusFile -Force
}

# ============================================
# MAIN
# ============================================

switch ($Mode.ToLower()) {
    "start" {
        Write-Log "════════════════════════════════════════"
        Write-Log "DAI_VIBE_CODE DAEMON - START"
        Write-Log "════════════════════════════════════════"

        $success = Start-OllamaService

        if ($success) {
            Write-Log "✅ DAI_VIBE_CODE está PRONTO"
            Write-Log "   → Ollama: http://localhost:$OllamaPort"
            Write-Log "   → Log: $LogFile"

            $status = Get-OllamaStatus
            Write-StatusFile $status

            # Mostrar no console também
            $status | ConvertTo-Json | Write-Host
        } else {
            Write-Log "❌ FALHA ao iniciar DAI_VIBE_CODE"
            exit 1
        }
    }

    "stop" {
        Write-Log "════════════════════════════════════════"
        Write-Log "DAI_VIBE_CODE DAEMON - STOP"
        Write-Log "════════════════════════════════════════"

        $processes = Get-Process ollama -ErrorAction SilentlyContinue
        if ($processes) {
            $processes | Stop-Process -Force
            Write-Log "✅ Ollama parado"
        } else {
            Write-Log "ℹ️ Ollama não estava rodando"
        }
    }

    "status" {
        $status = Get-OllamaStatus
        Write-Host ($status | ConvertTo-Json -Depth 2)

        if ($status.status -eq "ATIVO") {
            exit 0
        } else {
            exit 1
        }
    }

    "restart" {
        Write-Log "Reiniciando..."
        & $PSCommandPath -Mode "stop"
        Start-Sleep -Seconds 2
        & $PSCommandPath -Mode "start"
    }

    default {
        Write-Host "Uso: .\start-dai-vibe-code-daemon.ps1 [-Mode <start|stop|status|restart>] [-Port 11434]"
    }
}
