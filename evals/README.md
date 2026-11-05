# Evals

Doklad, že nástroje dělají, co tvrdíme. Změna hooku nebo agenta se vydává jen se zelenými evaly.

| Sada | Co ověřuje | Spuštění | V CI |
|---|---|---|---|
| [hooks/](hooks/) | Připravené případy ochrany příkazů a cest, chybové stavy, build a úklid procesů | `Invoke-Pester ./evals/hooks` (Pester 5+) | ano |
| [reviewer/](reviewer/) | Reviewer najde zasazené chyby a nevymýšlí falešné nálezy | ručně, viz README | zatím ne |

## Přidání případu

- **Hook:** přidat řádek do `hooks/guard-*.cases.json` (`expect`: `allow` / `deny`, volitelně `reason` = část textu zamítnutí). Každá změna pravidla v hooku nebo v konfiguračních šablonách potřebuje aspoň jeden případ.
- **Reviewer:** nová složka v `reviewer/cases/` podle [reviewer/README.md](reviewer/README.md).

`FailureModes.Tests.ps1` ověřuje vadné vstupy a konfiguraci i skutečné spuštění testovacího build příkazu v podprocesu. `Cleanup.Tests.ps1` používá simulované procesy: systémové dotazy a ukončování nahrazuje testovacími funkcemi. Testy tedy neukončují skutečné procesy a neověřují integraci s Windows CIM ani celou relaci Claude Code.
