# Lidské brány

AI připravuje, člověk rozhoduje. Tabulka uvádí každé místo, kde agentní proces čeká na člověka, a **jak je to zajištěné**: instrukcí v definici agenta (spoléhá na model) nebo technicky hookem (model to obejít nemůže).

| # | Rozhodnutí | Kdo rozhoduje | Zajištění | Kde |
|---|---|---|---|---|
| 1 | Výběr varianty návrhu | vývojář / architekt | instrukce: architekt variantu nevybírá, srovnání bez bodování | [navrh.md](../plugin/commands/navrh.md) |
| 2 | Schválení plánu úkolů a akceptačních kritérií | vývojář | instrukce: bez schválení se nevolá `vyvojar` | [manager.md](../plugin/commands/manager.md), krok 1 |
| 3 | Schválení nové grafiky | vývojář / designér | instrukce: bez schválení náhledů se nevolá `vyvojar` | [manager.md](../plugin/commands/manager.md), krok 2-0 |
| 4 | Vytvoření a spuštění DB migrace | vývojář | **hook**: `guard-bash` zamítá `dotnet ef migrations add/remove`, `database update/drop`; `guard-write` chrání `/Migrations/` | [hooks-config.project.example.json](../templates/hooks-config.project.example.json) |
| 5 | Pokračování po 3 neúspěšných kolech | vývojář | instrukce: manažer se zastaví a čeká | [manager.md](../plugin/commands/manager.md), Ochrana proti zacyklení |
| 6 | Zápis poučení do profilu projektu | vývojář | instrukce: zápis až po souhlasu | [manager.md](../plugin/commands/manager.md), Konec |
| 7 | Push a merge | vývojář + reviewer PR | **hook**: `guard-bash` zamítá `git push` (uživatelská konfigurace); merge chrání branch protection | [hooks-config.user.example.json](../templates/hooks-config.user.example.json) |

## Nezávislé ověření

Kdo kód píše, ten ho neschvaluje:

- `vyvojar` necommituje a nedělá `git add` – commit dělá manažer až po kontrole.
- `reviewer` (kód) a `tester` (chování) běží souběžně a nezávisle; hlášení vývojáře berou jako tvrzení, ne jako fakt.
- `tester` nesmí tvrdit ověření, které neprovedl; vývojář nemá prohlížeč, takže chování v UI nemůže „ověřit“ sám.
- Po vývojáři se vynuceně spustí build (**hook** `build-on-stop`); při chybě agent nesmí skončit.

## Pravidla pro změny

- Přesun brány z „instrukce“ na „hook“ je vítaný (vyšší úroveň v [MATURITY.md](../MATURITY.md)).
- Zrušení nebo oslabení brány vyžaduje ADR v [evidence/decisions](../evidence/decisions/) a schválení vlastníka governance.
- Projekt smí bránu vypnout (`disableRules`, `allowPatterns`) jen se zdůvodněním v profilu projektu.
