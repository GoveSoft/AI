# Plugin `govesoft` pro Claude Code

Subagenti, příkazy, skill a ochranné hooky pro řízený agentní vývoj. Definice jsou obecné; projektová specifika (spuštění aplikace, účty, checklist reviewera, poučení) patří do projektového profilu, ne do kopií agentů.

## Obsah

| Soubor | Role |
|---|---|
| [commands/navrh.md](commands/navrh.md) | `/navrh` – dva nezávislé návrhy řešení (architekt A ∥ B) a srovnání podle matice; vybírá člověk |
| [commands/manager.md](commands/manager.md) | `/manager` – plán s akceptačními kritérii (schvaluje člověk), smyčka (grafik →) vývojář → reviewer ∥ tester (→ ui-ux), commit a úklid po každém úkolu, stavový soubor |
| [agents/architekt.md](agents/architekt.md) | Návrh řešení nad skutečným stavem projektu (Opus) |
| [agents/vyvojar.md](agents/vyvojar.md) | Implementuje jeden úkol včetně testů k AC; necommituje (Sonnet) |
| [agents/reviewer.md](agents/reviewer.md) | Code review diffu proti pravidlům projektu a pokrytí AC testy; jen čte (Opus) |
| [agents/tester.md](agents/tester.md) | Ověří chování proti AC – build, testy, běžící aplikace, prohlížeč (Sonnet) |
| [agents/ui-ux.md](agents/ui-ux.md) | Posoudí UI z hlediska použitelnosti, konzistence a přístupnosti (Sonnet) |
| [agents/grafik.md](agents/grafik.md) | SVG ilustrace, ikony a OG obrázky podle stylového průvodce, náhled v headless Chrome; schvaluje člověk |
| [skills/claude-md](skills/claude-md/SKILL.md) | Vytvoření stručného `CLAUDE.md` k repozitáři (průzkum, otázky, max ~60 řádků) |
| [hooks/](hooks/) | `guard-bash.ps1` (skenery, procesy v popředí, změna portu, zakázané příkazy), `guard-write.ps1` (chráněné cesty), `build-on-stop.ps1` (build po vývojáři, chyby mu vrátí), `cleanup.ps1` (osiřelé procesy) |

Lidské brány: výběr varianty (`/navrh`), schválení plánu, schválení grafiky, vytvoření migrace, eskalace po 3 kolech, push/merge. Podrobně v [governance/human-in-the-loop.md](../governance/human-in-the-loop.md).

## Požadavky

- Claude Code s podporou pluginů.
- PowerShell 7 (`pwsh`) v `PATH` – hooky jsou napsané pro něj. Vestavěná pravidla `guard-bash.ps1` řeší procesní hygienu na Windows.
- Pro testera a ui-ux: Claude in Chrome.

## Instalace (doporučeno: plugin)

```
/plugin marketplace add govesoft/ai
/plugin install govesoft@govesoft
```

Konkrétní verzi lze připnout tagem: `/plugin marketplace add govesoft/ai#v1.0.0`. Hooky se zaregistrují samy z [hooks/hooks.json](hooks/hooks.json), do `settings.json` se nic nepíše.

Uživatelská konfigurace hooků (platí pro všechny projekty):

```powershell
New-Item -ItemType Directory -Force $HOME\.claude\hooks | Out-Null
Copy-Item templates\hooks-config.user.example.json $HOME\.claude\hooks\hooks-config.json
```

`cleanup.ps1` má výchozí `"dryRun": true` – nejdřív jen loguje do `.scratch/cleanup.log`. Ostrý režim zapněte, až log projdete.

> **Ověřit při první instalaci:** příkazy z pluginu mohou být dostupné i jako `/govesoft:manager` a subagenti pod jménem `govesoft:vyvojar`. Matcher `SubagentStop` je proto napsaný jako `(.*:)?vyvojar`, aby fungoval s prefixem i bez něj. Po instalaci zkontrolujte `/agents` a že se po vývojáři spustí build.

## Instalace ručně (bez pluginu)

```powershell
Copy-Item plugin\agents\*.md   $HOME\.claude\agents\
Copy-Item plugin\commands\*.md $HOME\.claude\commands\
New-Item -ItemType Directory -Force $HOME\.claude\hooks, $HOME\.claude\skills\claude-md | Out-Null
Copy-Item plugin\hooks\*.ps1   $HOME\.claude\hooks\
Copy-Item plugin\skills\claude-md\SKILL.md $HOME\.claude\skills\claude-md\
Copy-Item templates\hooks-config.user.example.json $HOME\.claude\hooks\hooks-config.json
```

Hooky pak zaregistrovat v `~/.claude/settings.json` – stejný obsah jako [hooks/hooks.json](hooks/hooks.json), jen `${CLAUDE_PLUGIN_ROOT}` nahradit `$HOME/.claude`.

## V projektu

1. [templates/profil.template.md](../templates/profil.template.md) → `.claude/agentic/profil.md` a vyplnit.
2. [templates/hooks-config.project.example.json](../templates/hooks-config.project.example.json) → `.claude/hooks-config.json` a upravit (port, zakázané příkazy, chráněné cesty, `buildOnStop`).
3. Do `.gitignore` přidat `/.claude/runs/` a `/.scratch/`.
4. [templates/claude-settings.project.json](../templates/claude-settings.project.json) → `.claude/settings.json` (zákaz čtení souborů se secrets; povinné pro soukromé účty).

Projektový `.claude/agents/<jméno>.md` přebíjí globálního agenta – projektová specifika proto nepište do kopií agentů, ale do profilu, jinak se firemní opravy nepropíšou.

## Použití

Postup je popsaný ve [workflows/agentic-dev-loop.md](../workflows/agentic-dev-loop.md) a [workflows/dual-design.md](../workflows/dual-design.md). Agenty lze volat i samostatně, např. „nech agenta reviewer projít poslední změny“.

## Verzování

Každá změna agenta, příkazu nebo hooku zvedá `version` v [.claude-plugin/plugin.json](.claude-plugin/plugin.json) a má záznam v [CHANGELOG.md](../CHANGELOG.md). Změna chování hooku musí mít test v [evals/hooks](../evals/hooks/).
