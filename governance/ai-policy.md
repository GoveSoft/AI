# Politika používání AI při vývoji

Stav: **návrh** · Platnost od: <!-- datum --> · Schválil: <!-- jméno -->

## Účel a rozsah

Politika platí pro všechny zaměstnance a dodavatele GoveSoft, kteří při vývoji, testování, dokumentaci nebo provozu používají nástroje generativní AI, a pro všechny projekty – interní i klientské.

## Schválené nástroje

| Nástroj | Použití | Podmínky |
|---|---|---|
| Claude a Claude Code s pluginem [govesoft](../plugin/) – firemní plán (Team/Enterprise) | vývoj, review, testování | bez dalších podmínek nad rámec této politiky |
| Claude a Claude Code s pluginem [govesoft](../plugin/) – soukromý účet (Pro/Max) | vývoj, review, testování | jen za podmínek v oddílu [Soukromé účty](#soukromé-účty) |
| <!-- doplnit --> | | |

Jiné nástroje jen po schválení <!-- role -->. Žádost obsahuje: účel, kam tečou data, podmínky poskytovatele k trénování na datech.

## Soukromé účty

Soukromý účet (plán Free, Pro nebo Max zaplacený zaměstnancem nebo firmou na jméno zaměstnance) firma nespravuje: nevidí jeho nastavení, nemůže ho vynutit ani při odchodu zaměstnance odebrat přístup ke konverzacím. Proto platí přísnější podmínky než pro firemní plán.

1. **Prohlášení před prvním použitím.** Uživatel vyplní [prohlášení uživatele AI](account-attestation.md) a obnovuje ho jednou ročně a při každé změně podmínek poskytovatele.
2. **Trénování vypnuté.** V nastavení soukromí účtu je vypnuté použití konverzací pro trénování modelů. U spotřebitelských plánů Anthropicu je to volba uživatele a určuje i dobu uchovávání dat (30 dní při vypnutí, 5 let při zapnutí) – viz [data-handling.md](data-handling.md#nastavení-účtů).
3. **Zabezpečený přístup.** Účet, přes který se uživatel do Claude přihlašuje (e-mail nebo Google), má zapnuté dvoufaktorové ověření.
4. **Klientský kód jen se souhlasem klienta,** který výslovně připouští zpracování u poskytovatele AI na účtech, které GoveSoft nespravuje. Bez takového souhlasu se na klientském projektu soukromý účet nepoužívá.
5. **Technická opatření v projektu** podle [data-handling.md](data-handling.md#technická-opatření) jsou povinná, ne doporučená: zákaz čtení souborů se secrets a ochranné hooky.
6. **Při odchodu ze společnosti** uživatel smaže konverzace obsahující firemní nebo klientský kód a potvrdí to.

## Dohledatelnost

Postup vzniku změny se dokládá v repozitáři, ne odkazem na konverzaci (ta je u soukromého účtu přístupná jen jejímu majiteli):

- popis pull requestu se shrnutím zadání a klíčových rozhodnutí,
- u agentních běhů archivovaný stavový soubor (`.claude/runs/<slug>/stav.md`) v [evidence/case-studies](../evidence/case-studies/),
- architektonická rozhodnutí jako ADR.

## Odpovědnost

- **Za kód odpovídá člověk, který ho commituje nebo schvaluje**, bez ohledu na to, kdo ho napsal. AI není autor ani schvalovatel.
- Každá změna generovaná AI prochází stejným review a CI jako ruční změna.
- Vývojář rozumí kódu, který odevzdává. Kód, kterému nerozumí, nemerguje.

## Povinná pravidla

1. Data podle [data-handling.md](data-handling.md) – žádné secrets, osobní údaje ani data klienta bez jeho souhlasu.
2. Lidské brány podle [human-in-the-loop.md](human-in-the-loop.md) se neobcházejí. Vypnutí hooku v projektu musí být zdůvodněné v profilu projektu.
3. Projekt používající agenty má `CLAUDE.md`, profil `.claude/agentic/profil.md` a konfiguraci hooků.
4. Kód podléhající licenci třetích stran nevkládat do promptů v rozporu s licencí; výstup AI, který zjevně reprodukuje cizí kód, nepoužít.

## Zakázané použití

- Rozhodování o lidech (hodnocení zaměstnanců, výběr uchazečů) bez lidského rozhodnutí.
- Generování obsahu, který se vydává za lidský tam, kde klient nebo zákon vyžaduje opak.
- <!-- doplnit -->

## Klientské projekty

Použití AI na projektu klienta se řídí smlouvou. Výchozí stav: <!-- doplnit: informujeme klienta / vyžadujeme souhlas -->. Použití soukromých účtů vyžaduje vždy výslovný souhlas klienta (viz [Soukromé účty](#soukromé-účty)). Na vyžádání klientovi předáme tento repozitář jako popis procesu.

## Školení

Každý, kdo AI nástroje používá, absolvuje [onboarding](../workflows/onboarding.md) před prvním použitím na produkčním kódu. Absolvování se eviduje (EU AI Act, čl. 4 – AI gramotnost).

## Porušení a incidenty

Únik dat do AI nástroje nebo škoda způsobená výstupem AI se hlásí jako bezpečnostní incident <!-- kam -->. Poučení se zapisuje do [risk-register.md](risk-register.md).
