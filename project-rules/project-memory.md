# Project Memory

## Decisões Arquiteturais
- Arquitetura separada em lógica (`logic.py`), interface gráfica (`ui_components.py`), e ponto de entrada (`main.py`).
- Uso do `PySide6` (Qt) para a interface gráfica.
- "GPS de Diretórios Dinâmico": lógica para detectar se roda em Flatpak, AppImage ou Nativo, redirecionando o salvamento de dados para `~/.backup_facil_pro` (com sistema de migração retroativa) ou `~/.config/`.
- Uso de Threads (QThread) em operações pesadas, como busca e exclusão de arquivos duplicados, garantindo a responsividade da UI.
- Backups incrementais controlados via banco de dados SQLite e Hashes super-rápidos via `xxhash`.
- Criptografia e compressão em formato `.7z` utilizando AES-256 (via `py7zr`).
- Suporte a seleção de arquivos isolados para backup (além de diretórios completos). Arquivos isolados são armazenados diretamente na raiz do contêiner `.7z`.
- Restauração Seletiva e Interativa: Leitura do conteúdo do `.7z` em memória e extração filtrada de alvos selecionados via checkbox pelo usuário.
- Pipeline de empacotamento: 
  - Linux: Scripts unificados através do menu interativo `gerenciador_builds.sh` (abrangendo Flatpak, DEB e limpeza de cache).
  - Windows: Script PowerShell automatizado que utiliza uma virtual environment independente (`venv_win`) para evitar conflitos de arquitetura e pacotes com desenvolvedores utilizando o WSL.

## Tecnologias Oficiais
- Python 3.11+
- PySide6 (Interface Gráfica)
- py7zr (Motor de compressão/criptografia)
- SQLite3 (Integridade incremental)
- xxhash (Hashing e integridade em alta velocidade)
- Keyring (Segurança de credenciais)

## Regras Permanentes
- Manter a separação de responsabilidades (UI e Lógica).
- Garantir suporte e tratamento de caminhos considerando o ambiente Sandbox do Flatpak.

## Bugs Históricos Importantes
- **WSL/Linux (Falta de Bibliotecas):** Usuários frequentemente esbarravam em falhas ao tentar criar o `venv` (falta de `python3-venv`), compilar pacotes C/C++ como `xxhash` (falta de `build-essential`), e falhas de runtime ao tentar tocar áudio com `PySide6.QtMultimedia` (falta de `libpulse0` e `libasound2`). O `README.md` conta agora com um bloco robusto de dependências preventivas.

## Limitações Conhecidas
- (Espaço reservado para limitações conhecidas)

## Roadmap
- Migrar o ícone em PNG (`icon.png`) para formato SVG (`icon.svg`) para suporte vetorial aprimorado.

## Recursos Não Remover
- Monitor de Desempenho em Tempo Real (MB/s).
- Filtros avançados com Expressões Regulares (Regex).
- Integração segura com `keyring` para credenciais.

## Convenções de Código
- Código formatado e nomeado prioritariamente em português para a interface e variáveis relativas ao domínio (ex: `JanelaPrincipal`, `AbaBackup`, etc).
- Modularização clara nos arquivos em `src/`.

## Convenções de UI
- Estilo "Dark Profissional" injetado via QSS global no arquivo `main.py` (fundo `#1e1e1e`, texto `#e0e0e0`, destaques `#27ae60` e `#007acc`).
- Organização de navegação baseada em abas (`QTabWidget`).
