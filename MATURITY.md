# Model vyzrálosti práce s AI

Model hodnotí šest oblastí na stupnici 1–5. Každá úroveň má ověřitelné kritérium; úroveň se uznává jen s odkazem na doklad v tomto repozitáři.

## Úrovně

| Úroveň | Název | Charakteristika |
|---|---|---|
| 1 | Ad hoc | Jednotlivci používají AI po svém, bez pravidel a sdílení |
| 2 | Opakovatelná | Sdílené prompty a postupy, ale závislé na konkrétních lidech |
| 3 | Definovaná | Zapsaná pravidla a nástroje, jednotná distribuce, lidské brány |
| 4 | Řízená | Pravidla technicky vynucená, výsledky měřené a vyhodnocované |
| 5 | Optimalizovaná | Systematické zlepšování na základě dat, evaluace změn před nasazením |

## Oblasti a kritéria

| Oblast | Úroveň 3 (definovaná) | Úroveň 4 (řízená) | Úroveň 5 (optimalizovaná) |
|---|---|---|---|
| **Governance** | Schválená [politika](governance/ai-policy.md) a [pravidla pro data](governance/data-handling.md) | [Registr rizik](governance/risk-register.md) s vlastníky a pravidelnou revizí | Mapování na ISO/IEC 42001 auditované třetí stranou |
| **Standardy** | [Sady pravidel](standards/) sdílené napříč projekty | Projekty je importují v `CLAUDE.md`, reviewer proti nim kontroluje | Pravidla upravovaná podle nálezů z review a incidentů |
| **Nástroje** | [Plugin](plugin/) s agenty a příkazy, verzovaný | Hooky vynucují lidské brány a chráněné cesty | Změny agentů procházejí [evaly](evals/) před vydáním |
| **Proces** | [Popsané workflow](workflows/) s lidskými branami | Stavové soubory běhů, eskalace po 3 kolech | Poučení z běhů se systematicky vracejí do profilů a agentů |
| **Lidé** | [Onboarding](workflows/onboarding.md) pro nové vývojáře | Evidované proškolení (AI gramotnost) | Interní sdílení praxe, mentoring |
| **Měření** | Definované [metriky](evidence/metrics.md) | Metriky sbírané pravidelně z běhů | Rozhodnutí o procesu podložená trendy |

## Sebehodnocení

<!-- Aktualizovat jednou za čtvrtletí. Úroveň uznat jen s doklademi; chybějící doklad = nižší úroveň. -->

Datum: 2026-10 · Hodnotil: <jméno>

| Oblast | Úroveň | Doklad | Co chybí k další úrovni |
|---|---|---|---|
| Governance | 2 | Pravidla existují implicitně v hoocích a agentech; soukromé účty povolené za podmínek ([ADR 0002](evidence/decisions/0002-soukrome-ucty-za-podminek.md)) | Schválit [ai-policy.md](governance/ai-policy.md) a [data-handling.md](governance/data-handling.md), sebrat [prohlášení uživatelů](governance/account-attestation.md); pro úroveň 4 firemní plán nebo doložená kontrola nastavení soukromých účtů |
| Standardy | 3 | [standards/](standards/) – 26 sad | Doložit import v projektech, reviewer checklisty v profilech |
| Nástroje | 4 | [plugin/](plugin/), hooky [guard-bash](plugin/hooks/guard-bash.ps1), [guard-write](plugin/hooks/guard-write.ps1), [build-on-stop](plugin/hooks/build-on-stop.ps1) | Evaly agentů v CI ([evals/reviewer](evals/reviewer/)) |
| Proces | 3 | [agentic-dev-loop.md](workflows/agentic-dev-loop.md), [dual-design.md](workflows/dual-design.md) | Sběr dat ze stavových souborů běhů |
| Lidé | 1 | – | Onboarding a evidence proškolení |
| Měření | 1 | – | Začít sbírat [metriky](evidence/metrics.md) |

> Návrh výchozího hodnocení vychází jen z obsahu repozitáře. Před zveřejněním ho potvrďte podle skutečného stavu ve firmě.
