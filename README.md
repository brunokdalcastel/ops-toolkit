# ops-toolkit

[![Lint](https://github.com/brunokdalcastel/ops-toolkit/actions/workflows/lint.yml/badge.svg)](https://github.com/brunokdalcastel/ops-toolkit/actions/workflows/lint.yml)
[![Test](https://github.com/brunokdalcastel/ops-toolkit/actions/workflows/test.yml/badge.svg)](https://github.com/brunokdalcastel/ops-toolkit/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Biblioteca de scripts PowerShell e Bash para operações de TI no dia a dia — diagnóstico de rede, inventário, Active Directory, backup e muito mais.

Cada script é **lintado**, **testado** e **documentado** via GitHub Actions. Sem scripts espalhados em pastas locais, pendrive ou WhatsApp.

---

## Scripts disponíveis

| Categoria | Script | Descrição |
|---|---|---|
| **Rede** | `test-connectivity.ps1` | Diagnóstico de conectividade: DNS, ping, traceroute |
| **Linux** | `system-report.sh` | Relatório de saúde: CPU, memória, disco, uptime |
| **Windows** | `get-system-info.ps1` | Inventário de hardware e software _(em breve)_ |
| **Windows** | `get-disk-health.ps1` | Status SMART e espaço em disco _(em breve)_ |
| **AD** | `get-ad-health.ps1` | dcdiag + repadmin + FSMO _(em breve)_ |
| **AD** | `find-locked-users.ps1` | Lista contas bloqueadas _(em breve)_ |
| **Backup** | `backup-mikrotik.sh` | Exporta config via SSH _(em breve)_ |

---

## Pré-requisitos

**PowerShell:**
- Windows PowerShell 5.1+ ou PowerShell 7+
- Sem módulos extras (exceto onde indicado no script)

**Bash:**
- bash 4+, coreutils, procps
- Testado em Ubuntu 20.04/22.04 e Debian 11

---

## Como usar

```powershell
# Diagnóstico de rede (PowerShell)
.\scripts\network\test-connectivity.ps1 -Target google.com
```

```
Target       : google.com
DnsResolved  : True
IpAddress    : 142.250.219.206
PingSuccess  : True
AvgLatencyMs : 18
HopCount     : 7
TestedAt     : 2026-04-24 09:15:33
```

```bash
# Relatório do sistema (Bash/Linux)
bash scripts/linux/system-report.sh
```

---

## Estrutura do projeto

```
ops-toolkit/
├── scripts/
│   ├── network/          # Scripts de diagnóstico de rede
│   ├── windows/          # Scripts para Windows
│   ├── active-directory/ # Scripts para Active Directory
│   ├── backup/           # Scripts de backup
│   ├── office365/        # Scripts para Microsoft 365
│   └── linux/            # Scripts para Linux
├── tests/                # Testes Pester (PowerShell) e bats (Bash)
├── docs/                 # Documentação MkDocs
└── .github/workflows/    # CI/CD com GitHub Actions
```

---

## Contribuindo

Veja [CONTRIBUTING.md](CONTRIBUTING.md) para o guia completo de como adicionar scripts, rodar testes localmente e o padrão de commits.

---

## Licença

[MIT](LICENSE) — Bruno K. Dalcastel
