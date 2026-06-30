#!/bin/bash

# Define as cores para o terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sem cor

limpar_caches() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}    🧹 FAXINA DE COMPILAÇÃO E CACHE   🧹${NC}"
    echo -e "${BLUE}========================================${NC}"

    echo -n "🗑️  Removendo diretórios do Flatpak-Builder (build-dir e .flatpak-builder)... "
    rm -rf build-dir .flatpak-builder
    echo -e "${GREEN}Concluído!${NC}"

    echo -n "🗑️  Removendo arquivos de instalação gerados (.deb, .flatpak e .AppImage)... "
    rm -f *.deb *.flatpak Backup_Facil_Pro*.AppImage
    echo -e "${GREEN}Concluído!${NC}"

    echo -n "🗑️  Removendo diretórios do PyInstaller e AppImage (build, dist, build_deb, AppDir e .spec)... "
    rm -rf build dist build_deb AppDir *.spec
    echo -e "${GREEN}Concluído!${NC}"

    echo -n "🗑️  Removendo cache do Python (__pycache__)... "
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
    echo -e "${GREEN}Concluído!${NC}"
    
    echo -n "🗑️  Removendo ambiente virtual do Windows (venv_win)... "
    rm -rf venv_win
    echo -e "${GREEN}Concluído!${NC}"
    
    echo -e "${GREEN}✅ Faxina finalizada!${NC}"
}

gerar_deb() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}  🛠️  GERADOR DE PACOTE .DEB AUTOMÁTICO  🛠️  ${NC}"
    echo -e "${BLUE}========================================${NC}"

    if [[ "$VIRTUAL_ENV" == "" ]]; then
        echo -e "${RED}❌ Erro: Ambiente virtual não ativado!${NC}"
        echo -e "Rode: ${YELLOW}source venv/bin/activate${NC} antes de executar este script."
        return 1
    fi

    VERSION=$(grep -oP 'APP_VERSION = "\K[^"]+' src/logic.py)
    if [ -z "$VERSION" ]; then
        echo -e "${RED}❌ Erro: Não foi possível ler a APP_VERSION no src/logic.py${NC}"
        return 1
    fi
    echo -e "📦 Versão detectada: ${GREEN}v${VERSION}${NC}"

    if ! python -c "import PyInstaller" &> /dev/null; then
        echo -e "${YELLOW}⚠️ PyInstaller não encontrado. Instalando no ambiente virtual...${NC}"
        pip install pyinstaller
    else
        echo -e "${GREEN}✅ PyInstaller detectado.${NC}"
    fi

    echo -e "\n⏳ Compilando o binário a partir do código fonte..."
    python -m PyInstaller --noconsole --onefile --name "Backup_Facil_Pro" \
        --icon="assets/icons/icon.png" \
        --add-data "assets:assets" \
        --hidden-import=plyer.platforms.linux.notification \
        --paths "src" \
        src/main.py

    if [ ! -f "dist/Backup_Facil_Pro" ]; then
        echo -e "${RED}❌ Erro: A compilação falhou. Executável não gerado.${NC}"
        return 1
    fi

    echo -e "\n⏳ Montando a estrutura do pacote .deb..."
    BUILD_DIR="build_deb"
    rm -rf $BUILD_DIR
    mkdir -p $BUILD_DIR/DEBIAN
    mkdir -p $BUILD_DIR/usr/bin
    mkdir -p $BUILD_DIR/usr/share/applications
    mkdir -p $BUILD_DIR/usr/share/icons/hicolor/256x256/apps

    cp dist/Backup_Facil_Pro $BUILD_DIR/usr/bin/backup-facil-pro
    chmod +x $BUILD_DIR/usr/bin/backup-facil-pro
    cp assets/icons/icon.png $BUILD_DIR/usr/share/icons/hicolor/256x256/apps/backup-facil-pro.png

    cat <<EOF > $BUILD_DIR/usr/share/applications/backup-facil-pro.desktop
[Desktop Entry]
Name=Backup Fácil Pro
Comment=Ferramenta profissional para automação de backups
Exec=/usr/bin/backup-facil-pro
Icon=backup-facil-pro
Terminal=false
Type=Application
Categories=Utility;System;Archiving;
EOF

    cat <<EOF > $BUILD_DIR/DEBIAN/control
Package: backup-facil-pro
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Maintainer: VaGNaroK
Description: Ferramenta de desktop robusta para automação, gestão e criptografia de backups locais.
EOF

    DEB_NAME="backup-facil-pro_${VERSION}_amd64.deb"
    echo -e "\n⏳ Fechando o pacote..."
    dpkg-deb --build $BUILD_DIR $DEB_NAME

    echo -e "\n${GREEN}✅ Sucesso Absoluto!${NC}"
    echo -e "O instalador ${BLUE}${DEB_NAME}${NC} está pronto na raiz do seu projeto!"
}

gerar_flatpak() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}  🛠️  GERADOR DE FLATPAK AUTOMÁTICO  🛠️  ${NC}"
    echo -e "${BLUE}========================================${NC}"

    VERSION=$(grep -oP 'APP_VERSION = "\K[^"]+' src/logic.py)

    if [ -z "$VERSION" ]; then
        echo -e "${YELLOW}⚠️  Erro: Não foi possível ler a APP_VERSION no src/logic.py${NC}"
        return 1
    fi

    echo -e "📦 Versão detectada: ${GREEN}v${VERSION}${NC}"
    echo -e "⏳ Iniciando compilação no contêiner..."

    # Compila sem instalar automaticamente e exporta para o diretório 'repo'
    flatpak-builder --repo=repo build-dir io.github.vagnarok.BackupFacilPro.yml --force-clean

    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}⚠️  Erro: Falha ao compilar o Flatpak!${NC}"
        return 1
    fi

    BUNDLE_NAME="Backup_Facil_Pro_v${VERSION}.flatpak"
    echo -e "⏳ Gerando o arquivo instalador final..."

    flatpak build-bundle repo "$BUNDLE_NAME" io.github.vagnarok.BackupFacilPro

    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}⚠️  Erro: Falha ao gerar o arquivo .flatpak!${NC}"
        return 1
    fi

    echo -e "${GREEN}✅ Sucesso Absoluto!${NC}"
    echo -e "O instalador ${BLUE}${BUNDLE_NAME}${NC} foi gerado na raiz do projeto."

    read -p "Deseja instalar o Flatpak agora no seu sistema? (s/n): " INSTALL_CHOICE
    if [[ "$INSTALL_CHOICE" == "s" || "$INSTALL_CHOICE" == "S" ]]; then
        echo -e "⏳ Instalando o pacote Flatpak..."
        flatpak install --user --reinstall -y "$BUNDLE_NAME"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Pacote instalado com sucesso!${NC}"
        else
            echo -e "${RED}❌ Erro durante a instalação do Flatpak.${NC}"
        fi
    else
        echo -e "Instalação pulada pelo usuário."
    fi
}

menu() {
    while true; do
        echo -e "\n${YELLOW}========================================${NC}"
        echo -e "${YELLOW}     MENU GERENCIADOR DE BUILDS     ${NC}"
        echo -e "${YELLOW}========================================${NC}"
        echo -e "1) Gerar pacote .DEB"
        echo -e "2) Gerar pacote .FLATPAK"
        echo -e "3) Gerar AMBOS (.DEB e .FLATPAK)"
        echo -e "4) Limpar caches e sujeiras de build"
        echo -e "5) Sair"
        echo -e "${YELLOW}========================================${NC}"
        
        read -p "Escolha uma opção: " OPCAO
        
        case $OPCAO in
            1)
                gerar_deb
                ;;
            2)
                gerar_flatpak
                ;;
            3)
                gerar_deb
                gerar_flatpak
                ;;
            4)
                limpar_caches
                ;;
            5)
                echo -e "Saindo..."
                break
                ;;
            *)
                echo -e "${RED}❌ Opção inválida! Tente novamente.${NC}"
                ;;
        esac
    done
}

# Executa o menu
menu
