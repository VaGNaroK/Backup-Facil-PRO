📝 Changelog - Backup Fácil Professional
Este arquivo registra todas as mudanças notáveis feitas no projeto Backup Fácil Professional desde o seu início.

## [0.4.1] - 2026-06-24

### Adicionado
- **Restauração Seletiva:** A aba de Restauração foi completamente reformulada. Agora é possível listar o conteúdo de um arquivo `.7z` antes de extrair e utilizar caixas de seleção interativas para recuperar pastas ou arquivos específicos.
- **Ferramentas de Seleção em Massa:** Adicionados botões "Marcar Todos", "Desmarcar Todos" na aba de Restauração, e um botão "Seleção Inteligente (Manter 1 de cada)" na aba de Remover Duplicados para facilitar limpezas em grande escala.
- **Checkboxes Vetoriais (UI):** O estilo visual das caixas de seleção em listas e árvores foi atualizado para utilizar ícones SVG vetoriais (injetados dinamicamente), garantindo renderização perfeita no tema Dark do PySide6, sem esticamento ou bugs gráficos.
- **Suporte a AppImage:** Adicionado script de automação oficial (`gerar_appimage.sh`) para construção de pacotes portáteis universais em formato `.AppImage` (empacotados sem dupla extração no modo `--onedir` para máxima performance de inicialização).

### Alterado
- **Migração para xxHash:** O motor de integridade e checagem de arquivos substituiu o algoritmo MD5 pelo **xxHash** nativo em C (extremamente rápido e focado em performance não-criptográfica), aumentando violentamente a velocidade de busca de duplicatas e criação de backups.
- **Buffer de Leitura de Disco:** O tamanho do bloco de leitura para arquivos grandes (`chunk_size`) subiu de 4KB para 8KB, tirando o máximo de proveito da velocidade extra de processamento do novo motor xxHash.
- **Limpeza de Builds Inteligente:** O script `limpar_builds.sh` foi atualizado para gerenciar eficientemente as compilações do AppImage. Agora ele elimina sobras de compilação e versões antigas geradas, preservando automaticamente a ferramenta base (`appimagetool`) para economizar internet em builds futuros.

### Corrigido
- **Filesystem Read-Only do AppImage:** Eliminado um erro crítico de E/S (`OSError 30`) que impedia a abertura do app. O GPS de diretórios foi ensinado a desviar a gravação do banco de dados (da partição bloqueada do AppImage) diretamente para a pasta segura e persistente `~/.config/backup_facil_pro/`.
- **Notificações Fantasmas (PyInstaller):** Resolvido o erro silencioso (`ModuleNotFoundError: No module named plyer.platforms`) que bloqueava as notificações de conclusão de backup em versões portáteis/compiladas (DEB e AppImage), forçando o carregamento do módulo nativo do Linux via importação oculta no script de build.

## [0.4.0] - 2026-06-21

### Adicionado
- **Motor de Busca de Duplicatas (fdupes):** Nova aba contendo uma ferramenta profissional de busca de arquivos idênticos, utilizando um rigoroso algoritmo de 4 camadas (Tamanho -> MD5 4KB -> MD5 Total -> Byte-a-byte).
- **Compressão Multi-Threading:** Adicionado seletor na UI para o usuário escolher o número de threads que o motor `.7z` vai usar (via `py7zr`), alavancando a velocidade de backup em computadores mais robustos.
- **Cabeçalhos Descritivos (UX):** Adicionados títulos padronizados e textos explicativos intuitivos no topo de todas as abas secundárias (Restauração, Comparador, Agendamento, Logs e Dashboard) garantindo uma navegação e usabilidade muito mais premium.
- **Feedback Sonoro (UX):** Implementado um sinal sonoro agradável nativo (`assets/sounds/done.wav`) que avisa automaticamente quando um processo de backup gigantesco é concluído, para que o usuário não precise ficar vigiando a tela.

### Corrigido
- **Aviso sobre DBUS no Linux:** Omitida a mensagem chata do Plyer resolvendo a ausência da dependência silenciosa `dbus-python` no requirements do ambiente virtual.
- **Falha de Inicialização do py7zr (Thread Crash):** O erro interno do `py7zr` (Object has no attribute 'header') causado por descarte prematuro da instância do arquivo foi contornado encapsulando a escrita adequadamente no bloco contextual e resolvendo a indentação defeituosa do script de backup.
- **Visualização de Caminhos:** Ocultado o corte fixo de colunas (Stretch) na árvore de resultados das duplicatas para que o usuário possa redimensionar e ler caminhos de pasta muito compridos.
- **Visibilidade UI (UX):** Checkboxes customizados na árvore da aba de duplicatas para harmonizar e estarem totalmente visíveis e estéticos no Modo Dark do App.

## [0.3.9] - 2026-04-12

### Adicionado
- **Suporte Oficial a Flatpak:** Criado o manifesto YAML e estrutura de build para empacotamento em sandbox (isolamento de segurança nativo do Linux).
- **Monitor de Desempenho em Tempo Real:** Adicionada uma thread paralela que calcula e exibe a velocidade real de gravação (MB/s) diretamente na interface gráfica.
- **Pipeline de Compilação Automatizada:** - Inclusão do script `scripts/gerar_flatpak.sh` para automação total do empacotamento universal.
    - Reestruturação completa do script `scripts/gerar_deb.sh`, que agora detecta o ambiente virtual, instala dependências (PyInstaller) automaticamente e gera o instalador .deb com um único comando.

### Alterado
- **Roteamento Dinâmico de Diretórios (GPS):** O motor de lógica agora detecta automaticamente o ambiente (Flatpak vs Nativo) para evitar erros de permissão "Read-Only".
- **Integração de Logs:** A aba de Logs agora registra também as operações de Restauração, além das de Backup.

### Alterado
- **Roteamento Dinâmico de Diretórios:** O motor de lógica agora detecta automaticamente variáveis de ambiente (`FLATPAK_ID`). Se rodar dentro da bolha de segurança, o app roteia a criação de dados para o cofre permitido do usuário, evitando o bloqueio de diretório "Read-Only".

## [0.3.8] - 2026-04-09
### 🐛 Corrigido
- **Comunicação de Logs (UI):** Corrigido o bug onde a aba de Logs ficava vazia durante o processo. Implementado o sistema de `Signals` do PySide6 para transmitir o status da `AbaBackup` diretamente para a `AbaLogs`.
- **Crash de Rolagem de Texto:** Resolvido o erro `AttributeError: 'QTextCursor' object has no attribute 'End'` ao adicionar a importação absoluta da classe `QTextCursor`.
- **Dependências de Sistema:** Documentada a necessidade de pacotes gráficos (`libxcb-cursor0`) e de notificação (`python3-dbus`, `libnotify-bin`) para instalações limpas no Linux Mint.

## [0.3.7] - 2026-04-09
### 🚀 Melhorado
- **Single Source of Truth (Fonte Única de Verdade):** A versão da aplicação agora é centralizada no topo do arquivo `logic.py`. A aba "Sobre" e o script de compilação `gerar_deb.sh` foram programados para ler a versão dinamicamente deste único local.
- **Padronização de Diretório:** A pasta raiz do projeto foi renomeada para um padrão universal (`backup_facil`), evitando que espaços ou números de versão quebrem a estrutura do ambiente virtual (`venv`).

### 🐛 Corrigido
- **Comparador de Backups:** Implementado um tratamento de erro limpo. Quando um backup criptografado é comparado sem a senha (ou com senha errada), o sistema agora exibe um alerta amigável na interface em vez de falhar com a mensagem bruta do `py7zr`.
- **Compilação PyInstaller:** Adicionadas as flags `--paths "src"` e `--hidden-import` ao comando de compilação para garantir que os módulos `logic.py` e `ui_components.py` não sejam ignorados na geração do executável.



## [0.3.7] - 2026-04-03
Atualiza para v0.3.7, aprimora tratamento de erros de senha e padroniza nome do diretório, correção de bugs.


## [0.3.5] - 2026-03-31
🚀 Adicionado
Automação de limpeza no script gerar_deb.sh para remover arquivos .deb antigos e evitar confusão de versões.

Documentação completa no README.md com instruções de clonagem (git clone).

## 🔧 Corrigido
**Caminho do Ícone:** Ajustado o arquivo .desktop para usar o caminho absoluto /usr/share/pixmaps/, garantindo que o ícone oficial apareça no Menu do Linux Mint.

**Versão do Pacote:** Corrigido o erro de cache onde o script gerava versões antigas por falta de salvamento do arquivo.

**Formatação do README:** Corrigida a pré-visualização no VS Code que estava "engolindo" o texto dentro de blocos de código.

## [0.3.4] - O Grande Salto Profissional (Refatoração MVC)
🏗️ Arquitetura e Organização
- **Nova Estrutura de Diretórios:** Migração de "Flat Structure" para uma estrutura organizada:

src/: Código fonte.

assets/: Ícones e imagens.

scripts/: Automação de compilação.

data/: Configurações e bancos de dados locais (ignorado pelo Git).

GPS de Diretórios: Implementação de lógica dinâmica para localização de arquivos. No Linux instalado, o app agora salva dados em ~/.config/backup_facil_pro para evitar erros de permissão (PermissionError).

## 🎨 Interface Gráfica (GUI)
**Migração de Framework:** Substituição do CustomTkinter pelo PySide6 (Qt) para uma interface mais robusta e profissional.

**UI Multi-Abas:** Implementação de abas para Dashboard, Backup, Restauração e a nova aba de Comparação.

Dark Mode Profissional: Estilização via QSS (Qt Style Sheets) com foco em usabilidade.

## 🧠 Motor de Backup (Logic)
**Threads de Execução:** Migração para QThreads, permitindo que o backup rode em background sem travar a interface.

**Backup Incremental:** Novo sistema usando SQLite e Hashes MD5 para copiar apenas arquivos novos ou alterados.

**Criptografia AES-256:** Suporte a senhas em arquivos .7z via py7zr.

**Filtros Regex:** Implementação de filtros avançados para ignorar arquivos/pastas via expressões regulares.

**Aba de Comparação:** Nova funcionalidade para analisar diferenças entre dois arquivos de backup antes da restauração.

## 📦 Distribuição e DevOps
**Instalador Linux (.deb):** Criação do script gerar_deb.sh que gera um pacote instalável nativo para Linux Mint/Debian.

C**ompilação Windows (.exe):** Script gerar_exe.bat atualizado para a nova estrutura e PySide6.

**Requirements.txt:** Padronização das dependências do projeto.

**.gitignore:** Configuração de segurança para não subir arquivos sensíveis ou binários pesados para o GitHub.

[0.3.0] a [0.3.3] - Primeiras Implementações
Definição das funcionalidades básicas de compressão.

Implementação inicial do histórico em JSON.

Integração básica com o agendador de tarefas (schedule).

Adição de notificações nativas via plyer.

Nota: A partir da versão 0.3.4, o projeto adotou o padrão de versionamento semântico e arquitetura modular.