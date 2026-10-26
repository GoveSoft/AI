# Přispívání

## Postup

1. Větev s prefixem (`feature/`, `fix/`, `docs/`), commity podle Conventional Commits – viz [standards/general/git-cicd](standards/general/git-cicd/index.md).
2. Pull request podle šablony; CI musí projít.
3. Schválení vlastníkem dotčené oblasti podle [CODEOWNERS](.github/CODEOWNERS).

## Pravidla podle oblasti

| Měníte | Potřeba |
|---|---|
| agenta, příkaz, skill, hook | zvýšit `version` v [plugin.json](plugin/.claude-plugin/plugin.json), záznam v [CHANGELOG.md](CHANGELOG.md) |
| chování hooku nebo konfigurační šablony | případ v [evals/hooks](evals/hooks/) |
| agenta `reviewer` | spustit [eval reviewera](evals/reviewer/) a zapsat výsledek |
| lidskou bránu (oslabení, zrušení) | ADR v [evidence/decisions](evidence/decisions/), schválení vlastníka governance |
| governance dokument | schválení vlastníka dokumentu, datum v hlavičce |
| sadu standardů | záznam v CHANGELOG; přejmenování nebo přesun sady je breaking change (rozbije importy v projektech) |

## Verzování pluginu

- **major** – změna, po které je nutné upravit projekty (přejmenovaný agent, nová povinná konfigurace, přesun standardů)
- **minor** – nový agent, příkaz, pravidlo hooku
- **patch** – oprava formulace, chyby

Vydání: tag `vX.Y.Z` na `main`. Projekty mohou připnout verzi přes `/plugin marketplace add govesoft/ai#vX.Y.Z`.

## Lokální kontrola

```powershell
pwsh -File scripts/Validate-Repo.ps1
Invoke-Pester ./evals/hooks
```
