param()

Write-Host "==========================================" -ForegroundColor Blue
Write-Host "  🛠️  GERADOR DE EXECUTÁVEL (WINDOWS) 🛠️ " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Blue

# 1. Obter a versão do arquivo logic.py
$version = "0.0.0"
$match = Select-String -Path "src\logic.py" -Pattern 'APP_VERSION = "(.*?)"'
if ($match) {
    $version = $match.Matches.Groups[1].Value
} else {
    Write-Host "⚠️ AVISO: Nao foi possivel detectar a versao em src\logic.py. Usando padrao." -ForegroundColor Yellow
}

$appName = "Backup_Facil_Pro_v$version"
Write-Host "📦 Versao detectada: v$version" -ForegroundColor Green

Write-Host "`n[1] Limpando arquivos e caches antigos..." -ForegroundColor Cyan
if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
if (Test-Path "dist") { Remove-Item -Recurse -Force "dist" }
Remove-Item -Force "*.spec" -ErrorAction SilentlyContinue

Write-Host "`n[2] Iniciando o PyInstaller (PySide6)..." -ForegroundColor Cyan
python -m PyInstaller --noconsole --onefile --name $appName --icon="assets\icons\icon.ico" --add-data "assets;assets" --hidden-import logic --hidden-import ui_components src\main.py

Write-Host "`n[3] Limpeza final profunda..." -ForegroundColor Cyan
if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
Remove-Item -Force "*.spec" -ErrorAction SilentlyContinue
Get-ChildItem -Path . -Filter "__pycache__" -Directory -Recurse | Remove-Item -Force -Recurse

Write-Host "`n==========================================" -ForegroundColor Blue
Write-Host "✅ SUCESSO ABSOLUTO!" -ForegroundColor Green
Write-Host "O arquivo $appName.exe esta pronto na pasta 'dist'!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Blue
Read-Host -Prompt "Pressione Enter para sair..."
