# Changelog

Formát podle [Keep a Changelog](https://keepachangelog.com/cs/1.1.0/), verze pluginu podle [SemVer](https://semver.org/lang/cs/). Verze = `version` v [plugin/.claude-plugin/plugin.json](plugin/.claude-plugin/plugin.json).

## [1.0.0] – 2026-10-26

### Přidáno

- Governance: politika AI, nakládání s daty, lidské brány, registr rizik, mapování na normy (návrhy ke schválení).
- Model vyzrálosti a výchozí sebehodnocení.
- Plugin `govesoft` pro Claude Code s marketplace: agenti, příkazy `/manager` a `/navrh`, skill `claude-md` (dříve `CLAUDE.prompt.md`), hooky registrované přes `hooks.json`.
- Sada standardů `backend/aspnet-mvc` (controllery a routing, Razor views, formuláře a validace včetně české kultury, bezpečnost MVC).
- Workflows včetně průvodce prvním nasazením na existující projekt ([workflows/first-project.md](workflows/first-project.md)).
- Šablony zadání a `CLAUDE.md`, evaly hooků (Pester, 28 případů) a první případ evalu reviewera.
- Uživatelská konfigurace hooků zakazuje agentům `git push`, výpis `dotnet user-secrets list`, čtení `.env` přes shell a `printenv`.
- Soukromé účty Claude povolené za přísnějších podmínek ([ADR 0002](evidence/decisions/0002-soukrome-ucty-za-podminek.md)): povinné nastavení účtu, [prohlášení uživatele](governance/account-attestation.md), riziko R10, šablona [claude-settings.project.json](templates/claude-settings.project.json) se zákazem čtení souborů se secrets.
- CI: validace JSON, odkazů, frontmatteru, verze; testy hooků.

### Změněno

- Sady standardů seskupené do `standards/backend`, `architecture`, `frontend`, `general`; `external-apis` přesunuto do `standards/references`. Obsah sad beze změny.
- `SubagentStop` matcher pro build `(.*:)?vyvojar` – funguje s prefixem pluginu i bez něj.
