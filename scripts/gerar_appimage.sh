#!/bin/bash

# Define as cores para o terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sem cor

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  🛠️  GERADOR DE PACOTE APPIMAGE AUTOMÁTICO  🛠️  ${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. Verifica se está rodando dentro do VENV
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo -e "${RED}❌ Erro: Ambiente virtual não ativado!${NC}"
    echo -e "Rode: ${YELLOW}source venv/bin/activate${NC} antes de executar este script."
    exit 1
fi

# 2. Extrai a versão dinamicamente do logic.py
VERSION=$(grep -oP 'APP_VERSION = "\K[^"]+' src/logic.py)
if [ -z "$VERSION" ]; then
    echo -e "${RED}❌ Erro: Não foi possível ler a APP_VERSION no src/logic.py${NC}"
    exit 1
fi
echo -e "📦 Versão detectada: ${GREEN}v${VERSION}${NC}"

# 3. Verifica e instala o PyInstaller se necessário
if ! python -c "import PyInstaller" &> /dev/null; then
    echo -e "${YELLOW}⚠️ PyInstaller não encontrado. Instalando no ambiente virtual...${NC}"
    pip install pyinstaller
else
    echo -e "${GREEN}✅ PyInstaller detectado.${NC}"
fi

# 4. Compila o binário com PyInstaller no modo ONEDIR (Pasta)
# Usar --onedir é vital para AppImage para evitar lentidão e dupla-extração na abertura
echo -e "\n⏳ Compilando o binário a partir do código fonte (modo pasta/onedir)..."
python -m PyInstaller --noconsole --onedir --name "Backup_Facil_Pro" \
    --icon="assets/icons/icon.png" \
    --add-data "assets:assets" \
    --hidden-import=plyer.platforms.linux.notification \
    --paths "src" \
    src/main.py

# Verifica se a compilação teve sucesso
if [ ! -d "dist/Backup_Facil_Pro" ]; then
    echo -e "${RED}❌ Erro: A compilação falhou. Pasta executável não gerada.${NC}"
    exit 1
fi

# 5. Prepara a estrutura do AppDir
echo -e "\n⏳ Montando a estrutura do AppDir..."
APPDIR="AppDir"
rm -rf $APPDIR
mkdir -p $APPDIR/usr/bin
mkdir -p $APPDIR/usr/share/applications
mkdir -p $APPDIR/usr/share/icons/hicolor/256x256/apps

# 6. Copia os arquivos compilados para o AppDir
echo -e "⏳ Movendo arquivos compilados..."
cp -r dist/Backup_Facil_Pro/* $APPDIR/usr/bin/

# 7. Registra ícone na raiz (necessário pro AppImage) e na pasta share
cp assets/icons/icon.png $APPDIR/backup-facil-pro.png
cp assets/icons/icon.png $APPDIR/usr/share/icons/hicolor/256x256/apps/backup-facil-pro.png

# 8. Cria o arquivo .desktop na raiz (obrigatório pro AppImage) e na pasta share
cat <<EOF > $APPDIR/backup-facil-pro.desktop
[Desktop Entry]
Name=Backup Fácil Pro
Comment=Ferramenta profissional para automação de backups
Exec=Backup_Facil_Pro
Icon=backup-facil-pro
Terminal=false
Type=Application
Categories=Utility;System;Archiving;
EOF
cp $APPDIR/backup-facil-pro.desktop $APPDIR/usr/share/applications/

# 9. Cria o AppRun (Gatilho principal que o AppImage chama)
echo -e "⏳ Criando script AppRun..."
cat <<'EOF' > $APPDIR/AppRun
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"
export PATH="${HERE}/usr/bin:${PATH}"
# Corrige possíveis problemas do PySide6 não achar bibliotecas C no sistema alvo
export LD_LIBRARY_PATH="${HERE}/usr/bin:${LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="${HERE}/usr/bin/PySide6/Qt/plugins"

exec "${HERE}/usr/bin/Backup_Facil_Pro" "$@"
EOF
chmod +x $APPDIR/AppRun

# 10. Baixa o appimagetool (caso ainda não exista no projeto)
if [ ! -f "appimagetool-x86_64.AppImage" ]; then
    echo -e "\n⏳ Baixando appimagetool oficial..."
    wget -qO appimagetool-x86_64.AppImage https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x appimagetool-x86_64.AppImage
fi

# 11. Gera o AppImage final
APPIMAGE_NAME="Backup_Facil_Pro-v${VERSION}-x86_64.AppImage"
echo -e "\n⏳ Gerando o arquivo .AppImage final usando o appimagetool..."
ARCH=x86_64 ./appimagetool-x86_64.AppImage $APPDIR $APPIMAGE_NAME

# Verifica sucesso e finaliza
if [ -f "$APPIMAGE_NAME" ]; then
    echo -e "\n${GREEN}✅ Sucesso Absoluto!${NC}"
    echo -e "O aplicativo portável ${BLUE}${APPIMAGE_NAME}${NC} está pronto na raiz do seu projeto!"
else
    echo -e "\n${RED}❌ Falha na geração do AppImage.${NC}"
fi

# 12. Limpeza da sujeira de compilação
echo -e "\n⏳ Limpando arquivos temporários de build..."
rm -rf $APPDIR
rm -rf build/
rm -rf dist/
rm -f Backup_Facil_Pro.spec
