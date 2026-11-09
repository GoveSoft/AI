# Lidské brány

AI připravuje, člověk rozhoduje. Tabulka uvádí každé místo, kde agentní proces čeká na člověka, a **jak je to zajištěné**: instrukcí v definici agenta nebo hookem, který kontroluje zachycenou operaci. Hooky vyžadují aktivní registraci a příslušnou konfiguraci; jejich skutečný rozsah popisují omezení níže.

| # | Rozhodnutí | Kdo rozhoduje | Zajištění | Kde |
|---|---|---|---|---|
| 1 | Výběr varianty návrhu | vývojář / architekt | instrukce: architekt variantu nevybírá, srovnání bez bodování | [navrh.md](../plugin/commands/navrh.md) |
| 2 | Schválení plánu úkolů a akceptačních kritérií | vývojář | instrukce: bez schválení se nevolá `vyvojar` | [manager.md](../plugin/commands/manager.md), krok 1 |
| 3 | Schválení nové grafiky | vývojář / designér | instrukce: bez schválení náhledů se nevolá `vyvojar` | [manager.md](../plugin/commands/manager.md), krok 2-0 |
| 4 | Vytvoření a spuštění DB migrace | vývojář | **hook**: `guard-bash` zamítá `dotnet ef migrations add/remove`, `database update/drop`; `guard-write` chrání `/Migrations/` | [hooks-config.project.example.json](../templates/hooks-config.project.example.json) |
| 5 | Pokračování po 3 neúspěšných kolech | vývojář | instrukce: manažer se zastaví a čeká | [manager.md](../plugin/commands/manager.md), Ochrana proti zacyklení |
| 6 | Zápis poučení do profilu projektu | vývojář | instrukce: zápis až po souhlasu | [manager.md](../plugin/commands/manager.md), Konec |
| 7 | Push a merge | vývojář + reviewer PR | **hook**: `guard-bash` zamítá `git push` (uživatelská konfigurace); merge chrání branch protection, pokud je na GitHubu zapnutá | [hooks-config.user.example.json](../templates/hooks-config.user.example.json) |

## Rozsah technických kontrol

- `guard-bash` porovnává text příkazu s regulárními výrazy. Neanalyzuje obsah libovolného skriptu, aliasu ani všechny možné způsoby provedení stejné operace.
- `guard-write` kontroluje cesty nástrojů `Write`, `Edit` a `NotebookEdit`, včetně normalizace relativních cest. Nepokrývá zápis přes shell ani nerozpoznává všechny cíle symbolických odkazů.
- Blokování `git push` je v uživatelské konfigurační šabloně, blokování EF migrací a cest v projektové šabloně. Samotná instalace pluginu tyto konfigurace nevytvoří. Chybějící soubor je volitelný; existující poškozenou konfiguraci ochranný hook odmítne.
- `allowPatterns` mohou povolit i jinak zakázaný příkaz. Výjimky a vypnutá pravidla vyžadují zdůvodnění v profilu projektu.
- Ochranu větví je nutné nastavit a ověřit na GitHubu. Soubor `CODEOWNERS` sám nezajišťuje povinné schválení změny.
- Hooky jsou další vrstvou kontroly. Omezení přístupu k produkci, oprávnění účtů, lidské review a CI se nastavují samostatně.

## Jiné AI nástroje

Brány platí pro každý AI nástroj. Zajištění v tabulce výše popisuje Claude Code s pluginem `govesoft`; hooky ani definice agentů jiné nástroje nekontrolují. U jiného nástroje proto platí:

- Plán, výběr návrhu, grafiku a pokračování po neúspěších schvaluje člověk před dalším krokem.
- Migrace, push, merge a přístup k produkci provádí člověk. Agentní režim nástroje je smí provést, jen když je nástroj předem blokuje nebo vyžaduje potvrzení člověkem.
- Změna prochází stejným pull requestem, review a CI jako každá jiná změna.
- U Codexu blokují `git push` a EF migrace [pravidla](https://learn.chatgpt.com/docs/agent-configuration/rules) `prefix_rule` s `decision = "forbidden"`. Pravidla jsou experimentální a složitější příkazy nerozkládají, proto hlavní pojistkou zůstává ochrana větve na GitHubu.

## Nezávislé ověření

Kdo kód píše, ten ho neschvaluje:

- `vyvojar` necommituje a nedělá `git add` – commit dělá manažer až po kontrole.
- `reviewer` (kód) a `tester` (chování) běží souběžně a nezávisle; hlášení vývojáře berou jako tvrzení, ne jako fakt.
- `tester` nesmí tvrdit ověření, které neprovedl; vývojář nemá prohlížeč, takže chování v UI nemůže „ověřit“ sám.
- Po vývojáři spouští **hook** `build-on-stop` build, pokud je nastavené `buildOnStop`. Při neúspěchu, vadné konfiguraci nebo chybě spuštění vrátí blokující chybu. Opakovaný stop s `stop_hook_active` již neblokuje kvůli ochraně před zacyklením; finální ověření zůstává na testerovi a CI.

## Pravidla pro změny

- Přesun brány z „instrukce“ na „hook“ je vítaný (vyšší úroveň v [MATURITY.md](../MATURITY.md)).
- Zrušení nebo oslabení brány vyžaduje ADR v [evidence/decisions](../evidence/decisions/) a schválení vlastníka governance.
- Projekt smí bránu vypnout (`disableRules`, `allowPatterns`) jen se zdůvodněním v profilu projektu.
