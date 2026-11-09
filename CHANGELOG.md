# Changelog

Formát podle [Keep a Changelog](https://keepachangelog.com/cs/1.1.0/), verze pluginu podle [SemVer](https://semver.org/lang/cs/). Verze = `version` v [plugin/.claude-plugin/plugin.json](plugin/.claude-plugin/plugin.json).

## [1.0.2] – 2026-11-09

### Změněno

- Na kódu a datech GoveSoft se používají jen schválené AI nástroje s firemním účtem, pro Claude plán Team ([ADR 0003](evidence/decisions/0003-firemni-ucty-a-kriteria-ai-nastroju.md), nahrazuje ADR 0002). Politika, pravidla pro data, lidské brány a prohlášení uživatele platí obecně pro všechny AI nástroje.
- Codex na plánu ChatGPT Business je zapsaný jako podmíněně schválený nástroj s popsanými omezeními.
- Riziko R10 se týká neschválených nástrojů a účtů. Sebehodnocení oblasti Nástroje sníženo na úroveň 3.
- Šablona nastavení Claude Code vypíná `/feedback` a dotazníky kvality relace.

### Opraveno

- Uživatelská konfigurace zachytává `git push` s globálními přepínači, čtení a kopírování dalších souborů se secrets a výpis proměnných přes `env` a `Env:`. Projektová konfigurace zachytává `dotnet-ef` a EF příkazy s přepínači.

### Přidáno

- Validace repozitáře odmítne schválený dokument s nevyplněnými místy.

## [1.0.1] – 2026-11-05

### Opraveno

- Úklid procesů má bezpečný výchozí režim `dryRun`, vyžaduje konkrétní existující adresář projektu a při vadné konfiguraci nic neukončuje. Skenery mimo doložený kontext projektu a skenery se stále běžícím rodičem ponechává běžet.
- Build hook při poškozené konfiguraci, neplatném příkazu nebo chybě spuštění vrací blokující chybu místo tichého přeskočení. Pro buildy bez formátu chyb MSBuild vrací také konec logu.
- Ochrana zápisu vyhodnocuje relativní cesty vůči `cwd` události, případně kořeni projektu, a normalizuje segmenty `.` a `..` před kontrolou chráněných cest.
- Ochranné hooky při neplatném vstupu, poškozené konfiguraci a vadných regulárních výrazech odmítají operaci s vysvětlením.

### Přidáno

- Regresní testy chybových stavů, buildu a bezpečného úklidu se simulovanými procesy; rozšíření původních případů o relativní cesty.

### Upřesněno

- Dokumentace rozlišuje kontrolu zachycených operací hookem od izolace oprávnění a uvádí podmínky aktivace. README odděluje existující nástroje od dosud nevyplněné evidence výsledků.

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
