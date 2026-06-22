#!/bin/bash

# Define as cores para o terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sem cor

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    🧹 FAXINA DE COMPILAÇÃO E CACHE   🧹${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. Removendo pacotes de instalação finais na raiz
echo -n "🗑️  Removendo arquivos .deb e .flatpak... "
rm -f *.deb *.flatpak
echo -e "${GREEN}Concluído!${NC}"

# 2. Removendo pastas de cache do Flatpak
echo -n "🗑️  Removendo diretórios do Flatpak-Builder (build-dir e .flatpak-builder)... "
rm -rf build-dir .flatpak-builder
echo -e "${GREEN}Concluído!${NC}"

# 3. Removendo pastas temporárias do PyInstaller (.deb e .exe)
echo -n "🗑️  Removendo diretórios do PyInstaller (build, dist e arquivos .spec)... "
rm -rf build dist *.spec
echo -e "${GREEN}Concluído!${NC}"

# 4. Removendo cache do Python (__pycache__)
echo -n "🗑️  Removendo cache do Python (__pycache__)... "
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
echo -e "${GREEN}Concluído!${NC}"

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Faxina finalizada! Seu repositório está limpo.${NC}"

