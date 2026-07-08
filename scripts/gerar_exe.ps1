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
    if (-not $env:CI) { Read-Host -Prompt "Pressione Enter para sair..." }
    exit
}

# 0.1.5. Verificar se o Python esta instalado
try {
    $pythonVer = & python --version 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Python nao encontrado" }
    Write-Host "[i] Python detectado: $pythonVer" -ForegroundColor Green
} catch {
    Write-Host "[X] ERRO: Python nao esta instalado ou nao foi adicionado as Variaveis de Ambiente (PATH)." -ForegroundColor Red
    if (-not $env:CI) { Read-Host -Prompt "Pressione Enter para sair..." }
    exit
}

# 0.2. Gerenciar Ambiente Virtual Dedicado para Windows (venv_win)
$venvPath = Join-Path $projectRoot.Path "venv_win"
$pythonExe = Join-Path $venvPath "Scripts\python.exe"

if (-not (Test-Path $pythonExe)) {
    Write-Host "`n[i] Ambiente virtual dedicado (venv_win) para Windows nao encontrado. Criando agora..." -ForegroundColor Yellow
    python -m venv venv_win
    if (-not $?) {
        Write-Host "[X] ERRO: Falha ao criar o ambiente virtual. Verifique se o Python esta instalado nas Variaveis de Ambiente." -ForegroundColor Red
        if (-not $env:CI) { Read-Host -Prompt "Pressione Enter para sair..." }
        exit
    }
}

Write-Host "`n[i] Instalando/Atualizando dependencias (isso pode levar um minuto)..." -ForegroundColor Yellow
& $pythonExe -m pip install --upgrade pip | Out-Null
& $pythonExe -m pip install -r requirements.txt
if (-not $?) {
    Write-Host "[X] ERRO: Falha ao instalar dependencias do requirements.txt." -ForegroundColor Red
    if (-not $env:CI) { Read-Host -Prompt "Pressione Enter para sair..." }
    exit
}

# 0.3. Baixar e extrair o TestDisk (photorec_win.exe) automaticamente
$binDir = Join-Path $projectRoot.Path "assets\bin"
if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null
}
$photorecPath = Join-Path $binDir "photorec_win.exe"

if (-not (Test-Path $photorecPath)) {
    Write-Host "`n[i] Baixando TestDisk (photorec_win.exe) do servidor CGSecurity..." -ForegroundColor Yellow
    $zipPath = Join-Path $projectRoot.Path "testdisk.zip"
    $tempDir = Join-Path $projectRoot.Path "temp_testdisk"
    
    try {
        Invoke-WebRequest -Uri "https://www.cgsecurity.org/testdisk-7.2.win.zip" -OutFile $zipPath
        Write-Host "[i] Extraindo arquivo ZIP..." -ForegroundColor Yellow
        Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
        
        $extractedExe = Join-Path $tempDir "testdisk-7.2\photorec_win.exe"
        if (Test-Path $extractedExe) {
            Copy-Item -Path $extractedExe -Destination $photorecPath -Force
            Write-Host "[OK] photorec_win.exe injetado com sucesso na pasta assets\bin!" -ForegroundColor Green
        } else {
            Write-Host "[X] ERRO: Nao foi possivel encontrar o photorec_win.exe no zip extraido." -ForegroundColor Red
        }
    } catch {
        Write-Host "[X] ERRO ao baixar o TestDisk: $_" -ForegroundColor Red
    } finally {
        if (Test-Path $zipPath) { Remove-Item -Path $zipPath -Force }
        if (Test-Path $tempDir) { Remove-Item -Recurse -Force -Path $tempDir }
    }
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
& $pythonExe -m PyInstaller --noconsole --onefile --name $appName --icon="assets\icons\icon.ico" --add-data "assets;assets" --add-binary "assets\bin\photorec_win.exe;." --paths "src" src\main.py

Write-Host "`n[3] Limpeza final profunda..." -ForegroundColor Cyan
if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
Remove-Item -Force "*.spec" -ErrorAction SilentlyContinue
Get-ChildItem -Path . -Filter "__pycache__" -Directory -Recurse | Remove-Item -Force -Recurse

Write-Host "`n==========================================" -ForegroundColor Blue
Write-Host "[OK] SUCESSO ABSOLUTO!" -ForegroundColor Green
Write-Host "O arquivo $appName.exe esta pronto na pasta 'dist'!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Blue
if (-not $env:CI) { Read-Host -Prompt "Pressione Enter para sair..." }
