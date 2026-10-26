# Standardy v projektech

Sady pravidel ve [standards/](../standards/) jsou obyčejný Markdown. Agent je čte, když na ně odkazuje `CLAUDE.md` projektu.

## Napojení

Doporučeno: repozitář jako git submodule, aby projekt měl připnutou verzi standardů.

```
git submodule add https://github.com/govesoft/ai.git .govesoft
```

V `CLAUDE.md` projektu importovat jen sady, které projekt používá:

```
@.govesoft/standards/backend/csharp/index.md
@.govesoft/standards/backend/api-design/index.md
@.govesoft/standards/general/nasa/index.md
```

Každý `index.md` obsahuje rychlou kontrolu a seznam modulů; podrobné moduly agent čte jen v relevantní situaci, aby nezahlcoval kontext.

## Projektové výjimky

Odchylku od standardu zapište do `CLAUDE.md` projektu jako pravidlo s důvodem, případně jako ADR. Reviewer kontroluje proti `CLAUDE.md`, checklistu v profilu a importovaným sadám.

## Aktualizace

`git submodule update --remote .govesoft` – změny standardů popisuje [CHANGELOG.md](../CHANGELOG.md).
