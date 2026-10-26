# GoveSoft AI Engineering

Jak ve [GoveSoft](https://govesoft.com) vyvíjíme software s AI: pravidla používání, kódové standardy, nástroje pro Claude Code a doklady, že proces funguje.

Repozitář slouží dvěma účelům:

1. **Pro vývojáře** – jedno místo, odkud se instalují agenti, hooky a standardy do projektů.
2. **Pro klienty, audit a vedení** – doložení, že práci s AI řídíme: kdo za co odpovídá, kde rozhoduje člověk, co se technicky vynucuje a jak to měříme.

## Struktura

| Složka | Co v ní je | Pro koho |
|---|---|---|
| [governance/](governance/) | Politika používání AI, nakládání s daty, lidské brány, rizika, mapování na normy | vedení, audit, klient |
| [MATURITY.md](MATURITY.md) | Model vyzrálosti a aktuální sebehodnocení | vedení, klient |
| [standards/](standards/) | 26 sad kódových pravidel (.NET, architektura, frontend, obecné) pro promptování AI | vývojáři, agenti |
| [plugin/](plugin/) | Plugin pro Claude Code: subagenti, `/manager`, `/navrh`, skill `claude-md`, ochranné hooky | vývojáři |
| [workflows/](workflows/) | Popis procesů – agentní smyčka, dva nezávislé návrhy, onboarding | vývojáři, vedení |
| [templates/](templates/) | Šablony pro projekty: `CLAUDE.md`, profil agentů, konfigurace hooků, zadání, ADR | vývojáři |
| [evals/](evals/) | Testy hooků a evaluační případy agentů | vývojáři, audit |
| [evidence/](evidence/) | Metriky, případové studie, rozhodnutí o AI procesu | vedení, klient, audit |

## Rychlý start (vývojář)

```
/plugin marketplace add govesoft/ai
/plugin install govesoft@govesoft
```

Pak v projektu: vyplnit profil a konfiguraci hooků podle [plugin/README.md](plugin/README.md), vygenerovat `CLAUDE.md` skillem `claude-md` a naimportovat potřebné sady ze [standards/](standards/). Celý postup je v [workflows/onboarding.md](workflows/onboarding.md), nasazení na existující projekt krok za krokem v [workflows/first-project.md](workflows/first-project.md).

## Principy

- **Člověk rozhoduje, AI připravuje.** Plán, výběr návrhu, migrace, grafika, push a merge schvaluje vždy člověk.
- **Pravidla jsou vynucená, ne jen napsaná.** Co jde vynutit technicky, vynucuje hook (zákaz migrací, chráněné cesty, build po vývojáři).
- **Oddělené role.** Kdo kód píše, ten ho neschvaluje: reviewer a tester ověřují vývojáře nezávisle.
- **Měříme.** Tvrzení o přínosu AI dokládáme daty v [evidence/](evidence/).

## Přispívání

Pravidla pro změny jsou v [CONTRIBUTING.md](CONTRIBUTING.md), historie v [CHANGELOG.md](CHANGELOG.md).
