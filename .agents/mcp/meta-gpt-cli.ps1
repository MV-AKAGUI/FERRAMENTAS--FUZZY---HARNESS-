# META_GPT CLI Wrapper para Claude Code
# Uso: ./meta-gpt-cli.ps1 -Task "seu_prompt" [-Model "deepseek-r1"]

param(
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]$Task,

    [Parameter(Mandatory=$false)]
    [ValidateSet("deepseek-r1", "qwen2.5-coder", "claude-opus-5-5")]
    [string]$Model = "claude-opus-5-5",

    [Parameter(Mandatory=$false)]
    [switch]$Watch
)

$MetaGPTRoot = Join-Path $PSScriptRoot "../../.venv/meta_gpt"
$Workspace = Join-Path $PSScriptRoot "../../daisugi_workspace"

# Criar diretórios
New-Item -ItemType Directory -Force -Path $MetaGPTRoot | Out-Null
New-Item -ItemType Directory -Force -Path $Workspace | Out-Null

Write-Host "🚀 Meta_GPT DAISUGI CLI" -ForegroundColor Cyan
Write-Host "Task: $Task" -ForegroundColor Yellow
Write-Host "Model: $Model" -ForegroundColor Yellow
Write-Host "Workspace: $Workspace" -ForegroundColor Gray

# Construir JSON para MCP
$Request = @{
    method = "execute_workflow"
    params = @{
        task = $Task
        model = $Model
        workspace = $Workspace
    }
} | ConvertTo-Json

# Invocar Meta_GPT Server
try {
    $Response = & python (Join-Path $PSScriptRoot "meta-gpt-server.py") |
        % { $_ | ConvertFrom-Json }

    if ($Response.status -eq "completed") {
        Write-Host "✅ Workflow completed" -ForegroundColor Green
        Write-Host $Response.output
    } else {
        Write-Host "❌ Workflow failed" -ForegroundColor Red
        Write-Host $Response.error
        exit 1
    }

    if ($Watch) {
        Write-Host "`n📁 Workspace: $Workspace" -ForegroundColor Cyan
        Get-ChildItem -Recurse -Path $Workspace | Select-Object FullName
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
