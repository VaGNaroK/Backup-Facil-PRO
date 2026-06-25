param()

Write-Host "==========================================" -ForegroundColor Blue
Write-Host "  [!] GERADOR DE EXECUTAVEL (WINDOWS) [!]" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Blue

# 0. Ajustar o diretorio de trabalho para a raiz do projeto
$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $projectRoot.Path
Write-Host "[i] Diretorio de trabalho: $($projectRoot.Path)" -ForegroundColor Gray

# 0.1. Verificar se os arquivos essenciais existem
$requiredPaths = @("src\main.py", "src\logic.py", "assets", "requirements.txt")
$missingFiles = $false
foreach ($path in $requiredPaths) {
    if (-not (Test-Path $path)) {
        Write-Host "[X] ERRO: Arquivo/Pasta essencial nao encontrado: $path" -ForegroundColor Red
        $missingFiles = $true
    }
}
if ($missingFiles) {
    Write-Host "[X] ERRO: Nao foi possivel encontrar os arquivos base do projeto." -ForegroundColor Red
    Read-Host -Prompt "Pressione Enter para sair..."
    exit
}

# 0.2. Gerenciar Ambiente Virtual (venv) e Dependencias Automaticamente
$venvPath = Join-Path $projectRoot.Path "venv"
$pythonExe = Join-Path $venvPath "Scripts\python.exe"

if (-not (Test-Path $venvPath)) {
    Write-Host "`n[i] Ambiente virtual (venv) nao encontrado. Criando agora (pode levar alguns segundos)..." -ForegroundColor Yellow
    python -m venv venv
    if (-not $?) {
        Write-Host "[X] ERRO: Falha ao criar o ambiente virtual. Verifique se o Python esta instalado nas Variaveis de Ambiente." -ForegroundColor Red
        Read-Host -Prompt "Pressione Enter para sair..."
        exit
    }
}

Write-Host "`n[i] Instalando/Atualizando dependencias (isso pode levar um minuto)..." -ForegroundColor Yellow
& $pythonExe -m pip install --upgrade pip | Out-Null
& $pythonExe -m pip install -r requirements.txt
if (-not $?) {
    Write-Host "[X] ERRO: Falha ao instalar dependencias do requirements.txt." -ForegroundColor Red
    Read-Host -Prompt "Pressione Enter para sair..."
    exit
}

# 1. Obter a versao do arquivo logic.py
$version = "0.0.0"
$match = Select-String -Path "src\logic.py" -Pattern 'APP_VERSION = "(.*?)"'
if ($match) {
    $version = $match.Matches.Groups[1].Value
} else {
    Write-Host "[!] AVISO: Nao foi possivel detectar a versao em src\logic.py. Usando padrao." -ForegroundColor Yellow
}

$appName = "Backup_Facil_Pro_v$version"
Write-Host "`n[i] Versao detectada: v$version" -ForegroundColor Green

Write-Host "`n[1] Limpando arquivos e caches antigos..." -ForegroundColor Cyan
if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
if (Test-Path "dist") { Remove-Item -Recurse -Force "dist" }
Remove-Item -Force "*.spec" -ErrorAction SilentlyContinue

Write-Host "`n[2] Iniciando o PyInstaller (PySide6)..." -ForegroundColor Cyan
& $pythonExe -m PyInstaller --noconsole --onefile --name $appName --icon="assets\icons\icon.ico" --add-data "assets;assets" --hidden-import logic --hidden-import ui_components src\main.py

Write-Host "`n[3] Limpeza final profunda..." -ForegroundColor Cyan
if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
Remove-Item -Force "*.spec" -ErrorAction SilentlyContinue
Get-ChildItem -Path . -Filter "__pycache__" -Directory -Recurse | Remove-Item -Force -Recurse

Write-Host "`n==========================================" -ForegroundColor Blue
Write-Host "[OK] SUCESSO ABSOLUTO!" -ForegroundColor Green
Write-Host "O arquivo $appName.exe esta pronto na pasta 'dist'!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Blue
Read-Host -Prompt "Pressione Enter para sair..."
