# Politika používání AI při vývoji

Stav: **návrh** · Platnost od: <!-- datum --> · Schválil: <!-- jméno -->

## Účel a rozsah

Politika platí pro všechny zaměstnance a dodavatele GoveSoft, kteří při vývoji, testování, dokumentaci nebo provozu používají nástroje generativní AI, a pro všechny projekty – interní i klientské.

## Schválené nástroje

Politika se vztahuje na každý nástroj generativní AI bez ohledu na poskytovatele. Na kódu a datech GoveSoft se smí používat jen nástroj uvedený v tabulce a jen s firemním účtem.

| Nástroj | Účet | Použití | Doplňující podmínky |
|---|---|---|---|
| Claude a Claude Code | firemní plán Team | vývoj, review, testování | v projektech s agenty plugin [govesoft](../plugin/) |
| Codex | firemní plán ChatGPT Business | vývoj, review, testování | schválení platí až po ověření doby uchovávání dat a omezení podle [data-handling.md](data-handling.md#účty-a-poskytovatelé) |

Další nástroj se do tabulky přidává pull requestem po schválení <!-- role -->. Žádost obsahuje účel, kam tečou data a jak nástroj splňuje podmínky níže.

## Podmínky pro AI nástroje

1. **Obchodní podmínky.** Nástroj je používaný na základě smlouvy nebo podmínek, které dovolují komerční použití, a smluvní stranou je GoveSoft.
2. **Žádné trénování na našich datech.** Poskytovatel na vstupech a výstupech netrénuje, a to podle podmínek nebo nastavení vynuceného správcem.
3. **Správa účtů firmou.** Firma uživatele přidává a odebírá a při odchodu zaměstnance ukončí přístup.
4. **Zabezpečené přihlášení.** Jednotné přihlášení nebo dvoufaktorové ověření.
5. **Známé zpracování dat.** Doba uchovávání a místo zpracování jsou zjištěné a zapsané v [data-handling.md](data-handling.md#účty-a-poskytovatelé).
6. **Technická opatření** podle [data-handling.md](data-handling.md#technická-opatření) a [lidské brány](human-in-the-loop.md) lze v nástroji dodržet.

Soukromé a spotřebitelské účty se nepoužívají, ani když je platí firma: firma je nespravuje a podmínky poskytovatelů je často omezují na nekomerční použití ([ADR 0003](../evidence/decisions/0003-firemni-ucty-a-kriteria-ai-nastroju.md)).

Každý uživatel před prvním použitím vyplní [prohlášení uživatele AI](account-attestation.md) a obnovuje ho jednou ročně a při podstatné změně této politiky.

## Dohledatelnost

Postup vzniku změny se dokládá v repozitáři, ne odkazem na konverzaci, která nemusí být ostatním přístupná:

- popis pull requestu se shrnutím zadání a klíčových rozhodnutí,
- u agentních běhů archivovaný záznam běhu (u pluginu `govesoft` soubor `.claude/runs/<slug>/stav.md`) v [evidence/case-studies](../evidence/case-studies/),
- architektonická rozhodnutí jako ADR.

Commit smí uvádět použitý AI nástroj podpisovým řádkem.

## Odpovědnost

- **Za kód odpovídá člověk, který ho commituje nebo schvaluje**, bez ohledu na to, kdo ho napsal. AI není autor ani schvalovatel.
- Každá změna generovaná AI prochází stejným review a CI jako ruční změna.
- Vývojář rozumí kódu, který odevzdává. Kód, kterému nerozumí, nemerguje.

## Povinná pravidla

1. Data podle [data-handling.md](data-handling.md) – žádné secrets, osobní údaje ani data klienta bez jeho souhlasu.
2. Lidské brány podle [human-in-the-loop.md](human-in-the-loop.md) se neobcházejí. Vypnutí hooku v projektu musí být zdůvodněné v profilu projektu.
3. Projekt používající agenty má popsaná pravidla pro daný nástroj. U Claude Code jsou to `CLAUDE.md`, profil `.claude/agentic/profil.md` a konfigurace hooků.
4. Kód podléhající licenci třetích stran nevkládat do promptů v rozporu s licencí; výstup AI, který zjevně reprodukuje cizí kód, nepoužít.

## Zakázané použití

- Rozhodování o lidech (hodnocení zaměstnanců, výběr uchazečů) bez lidského rozhodnutí.
- Generování obsahu, který se vydává za lidský tam, kde klient nebo zákon vyžaduje opak.
- <!-- doplnit -->

## Klientské projekty

Použití AI na projektu klienta musí dovolovat smlouva nebo písemný souhlas klienta. Bez toho se na projektu AI nepoužívá. Na vyžádání klientovi předáme tento repozitář jako popis procesu.

## Školení

Každý, kdo AI nástroje používá, absolvuje [onboarding](../workflows/onboarding.md) před prvním použitím na produkčním kódu. Absolvování se eviduje (EU AI Act, čl. 4 – AI gramotnost).

## Porušení a incidenty

Únik dat do AI nástroje nebo škoda způsobená výstupem AI se hlásí jako bezpečnostní incident <!-- kam -->. Poučení se zapisuje do [risk-register.md](risk-register.md).
