# Contribuindo com o ops-toolkit

Obrigado por contribuir! Este guia cobre tudo que você precisa pra adicionar um script novo do zero até o merge na main.

---

## Pré-requisitos

**PowerShell:**
- PowerShell 5.1+ (obrigatório — muitos ambientes ainda rodam 5.1)
- PSScriptAnalyzer: `Install-Module -Name PSScriptAnalyzer -Scope CurrentUser`
- Pester 5.x: `Install-Module -Name Pester -Force -Scope CurrentUser -SkipPublisherCheck`

**Bash:**
- bash 4+
- ShellCheck: `sudo apt-get install shellcheck` ou `brew install shellcheck`
- bats-core: `sudo apt-get install bats` ou `npm install -g bats`

---

## Como adicionar um script novo

### 1. Criar a branch

```bash
git checkout -b feat/network-novo-script
```

Use prefixos de Conventional Commits: `feat/`, `fix/`, `docs/`, `chore/`.

### 2. Escrever o script

Coloque na pasta da categoria correta em `scripts/`:

- `scripts/network/` — diagnóstico de rede
- `scripts/windows/` — operações Windows
- `scripts/active-directory/` — AD
- `scripts/backup/` — backups
- `scripts/office365/` — Microsoft 365
- `scripts/linux/` — sistemas Linux

**PowerShell — estrutura obrigatória:**

```powershell
<#
.SYNOPSIS
Descrição curta (1 linha).

.DESCRIPTION
Descrição completa.

.PARAMETER Target
Descrição do parâmetro.

.EXAMPLE
.\meu-script.ps1 -Target "valor"

.NOTES
Author: Bruno K. Dalcastel
Min PowerShell: 5.1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Target
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
```

**Bash — estrutura obrigatória:**

```bash
#!/usr/bin/env bash
#
# meu-script.sh — descrição curta
#
# Usage: ./meu-script.sh [-o output.txt]
#
# Author: Bruno K. Dalcastel
# Requires: bash 4+, coreutils

set -euo pipefail
IFS=$'\n\t'

main() {
    # lógica aqui
}

main "$@"
```

### 3. Escrever o teste

**Regra de ouro: script sem teste não entra na main.**

- PowerShell → `tests/<categoria>/nome-do-script.Tests.ps1` (Pester 5.x)
- Bash → `tests/<categoria>/nome-do-script.bats` (bats-core)

### 4. Rodar lint local

```bash
# PowerShell
pwsh -c "Invoke-ScriptAnalyzer -Path ./scripts -Recurse -Severity Warning"

# Bash
find scripts -name '*.sh' -exec shellcheck {} +
```

Zero warnings = pode seguir.

### 5. Rodar testes local

```bash
# PowerShell (Pester)
pwsh -c "Invoke-Pester ./tests -Output Detailed"

# Bash (bats)
bats tests/**/*.bats
```

### 6. Abrir o PR

```bash
git add scripts/network/meu-script.ps1 tests/network/meu-script.Tests.ps1
git commit -m "feat(network): add meu-script"
git push -u origin feat/network-meu-script
gh pr create --title "feat(network): add meu-script" --body "..."
```

---

## Padrão de commits (Conventional Commits)

| Prefixo | Quando usar |
|---|---|
| `feat(categoria):` | Novo script ou nova funcionalidade |
| `fix(categoria):` | Correção de bug em script existente |
| `test(categoria):` | Adiciona ou corrige teste |
| `docs:` | Atualiza documentação |
| `chore(ci):` | Atualiza workflows ou ferramentas |
| `refactor(categoria):` | Refatora sem mudar comportamento |

Exemplos:
```
feat(network): add traceroute visualization script
fix(windows): handle missing WMI namespace in get-system-info
test(linux): add edge cases for system-report
docs: add office365 section to README
chore(ci): bump pester to 5.6
```

---

## Checklist do PR

Antes de abrir o PR, confirme:

- [ ] Script está na pasta de categoria correta
- [ ] Script tem comment-based help completo (PowerShell) ou header de uso (Bash)
- [ ] Lint local passou sem warnings
- [ ] Teste existe e passa localmente
- [ ] Nenhum dado de cliente, IP ou credencial no código
- [ ] Commit message segue Conventional Commits

---

## Dúvidas

Abra uma [issue](https://github.com/brunokdalcastel/ops-toolkit/issues) com a tag `question`.
