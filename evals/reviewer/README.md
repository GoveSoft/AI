# Eval reviewera

Ověřuje, že agent `reviewer` najde chyby zasazené do diffu a nehlásí neexistující problémy.

## Struktura případu

```
cases/<NNN-nazev>/
  zadani.md        # úkol s AC, jak ho dostane reviewer
  diff.patch       # změna k posouzení
  ocekavane.md     # nálezy, které musí padnout, a věci, které nálezem být nesmí
```

## Spuštění

1. Ve cvičném repozitáři aplikovat `diff.patch` na čistý stav.
2. Zavolat agenta: „nech agenta reviewer posoudit změny podle `zadani.md`“.
3. Porovnat hlášení s `ocekavane.md` a zapsat výsledek do tabulky níže.

Metriky: **záchyt** = nalezené povinné nálezy / všechny povinné; **falešné nálezy** = počet blokujících nálezů, které v `ocekavane.md` nejsou.

## Výsledky

| Datum | Verze pluginu | Model | Případ | Záchyt | Falešné nálezy | Verdikt |
|---|---|---|---|---|---|---|
| | | | | | | |

> Další krok: automatizovat přes `claude -p` v CI, až bude sada mít aspoň 5 případů.
