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
- Pipeline de empacotamento universal via `flatpak-builder`, e scripts para `.deb`, `.AppImage` portátil e executável Windows.

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
- (Espaço reservado para documentação de bugs passados)

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
