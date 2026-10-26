# Evals

Doklad, že nástroje dělají, co tvrdíme. Změna hooku nebo agenta se vydává jen se zelenými evaly.

| Sada | Co ověřuje | Spuštění | V CI |
|---|---|---|---|
| [hooks/](hooks/) | Hooky zamítají a povolují přesně to, co mají včetně ochrany secrets (28 případů) | `Invoke-Pester ./evals/hooks` | ano |
| [reviewer/](reviewer/) | Reviewer najde zasazené chyby a nevymýšlí falešné nálezy | ručně, viz README | zatím ne |

## Přidání případu

- **Hook:** přidat řádek do `hooks/guard-*.cases.json` (`expect`: `allow` / `deny`, volitelně `reason` = část textu zamítnutí). Každá změna pravidla v hooku nebo v konfiguračních šablonách potřebuje aspoň jeden případ.
- **Reviewer:** nová složka v `reviewer/cases/` podle [reviewer/README.md](reviewer/README.md).
