# První nasazení na existující projekt

Průvodce od nainstalovaného pluginu po první dokončené zadání. Příklady jsou pro ASP.NET Core MVC s EF Core, postup je ale stejný pro jakýkoli projekt.

Máte dvě fáze:

1. **Zahřátí** – jednou na projekt, cca 1 hodina. Výsledkem je společný základ, ze kterého agenti vycházejí.
2. **První zadání** – malé a dobře ověřitelné. Slouží hlavně ke kalibraci profilu, ne k rychlému dodání.

Předpoklad: máte nainstalovaný plugin a uživatelskou konfiguraci hooků podle [plugin/README.md](../plugin/README.md).

---

## Fáze 1: zahřátí

### 1. Napojení standardů

```
git submodule add https://github.com/govesoft/ai.git .govesoft
```

Vyberte sady, které projekt opravdu používá. Pro typickou ASP.NET Core MVC aplikaci s EF Core:

| Sada | Proč |
|---|---|
| `backend/aspnet-mvc` | controllery, views, formuláře, bezpečnost MVC |
| `backend/csharp` | jazyk, async, výjimky |
| `backend/database-ef` | migrace, dotazy, N+1 |
| `backend/security` | OWASP, hlavičky, CSRF |
| `backend/observability` | logování bez PII |
| `general/testing-advanced` | integrační testy přes `WebApplicationFactory` |
| `frontend/tailwind`, `frontend/responsive-pwa` | jen pokud je projekt používá |

Víc sad neznamená lepší výsledek – každá importovaná sada zabírá kontext agentů. Podrobnosti v [standards-in-projects.md](standards-in-projects.md).

### 2. `CLAUDE.md`

V Claude Code v kořeni projektu:

```
Vytvoř CLAUDE.md pro tento repozitář.
```

Spustí se skill `claude-md`. Claude projde `.sln`, `.csproj`, CI, README a git log, zjistí přesné příkazy pro build a testy a pak vám položí 5–8 otázek na věci, které z kódu nevyčte.

**Odpovídejte konkrétně – tohle je nejcennější část zahřátí.** Typické otázky a dobré odpovědi:

- *Na co se nesahá?* „`Legacy/` je převzatý kód, neopravovat, jen volat přes `ILegacyGateway`.“
- *Jaké chyby se opakují?* „Zapomenuté `AsNoTracking` u seznamů; texty natvrdo místo `.resx`.“
- *Workflow?* „Migrace vytváří vždy člověk, commity česky podle Conventional Commits.“

Výsledek (max ~60 řádků) zkontrolujte a doplňte importy sad z kroku 1 do sekce Kontext:

```
@.govesoft/standards/backend/aspnet-mvc/index.md
@.govesoft/standards/backend/csharp/index.md
@.govesoft/standards/backend/database-ef/index.md
```

### 3. Profil pro agenty

Zkopírujte [templates/profil.template.md](../templates/profil.template.md) do `.claude/agentic/profil.md`. Nejdůležitější sekce:

**Spuštění aplikace** – port musí odpovídat `applicationUrl` v `Properties/launchSettings.json`:

```markdown
Port **5080**. Neměň ho (uložená hesla v prohlížeči, OAuth redirect URI).

1. Build: `dotnet build Shop.sln > .scratch/<složka>/build.log 2>&1`
2. Na pozadí: `dotnet run --project src/Shop.Web --no-launch-profile --urls http://localhost:5080`
3. Start ověř: `curl -s -o /dev/null -w "%{http_code}" http://localhost:5080/` → `200` nebo `302`
```

**Účty** – oblast aplikace a testovací účet, bez hesel (autofill prohlížeče nebo soubor mimo repo).

**Checklist reviewera** – jen pravidla ověřitelná nad diffem, s odkazem na zdroj. Pro MVC například:

```markdown
- **MVC-1:** POST akce končí redirectem (PRG) – aspnet-mvc/mvc-forms-validation.md
- **MVC-2:** view dostává ViewModel, POST přijímá input model, nikdy entitu – aspnet-mvc/index.md
- **MVC-3:** nová akce s veřejným přístupem má [AllowAnonymous] a zdůvodnění v PR
- **DATA-1:** seznamy s AsNoTracking a stránkováním na serveru – database-ef
- **UI-1:** texty v .resx, žádné řetězce natvrdo ve views
```

**Mimo zájem agentů** – `Migrations/`, `wwwroot/lib/`, generované CSS.

### 4. Konfigurace hooků

[templates/hooks-config.project.example.json](../templates/hooks-config.project.example.json) → `.claude/hooks-config.json`:

```json
{
  "port": 5080,
  "denyCommands": [
    { "pattern": "dotnet\\s+ef\\s+(migrations\\s+(add|remove)|database\\s+(update|drop))",
      "message": "EF migrace vytváří jen uživatel. Uprav model a napiš uživateli, že migraci musí vytvořit sám." }
  ],
  "protectedPaths": [
    { "pattern": "/Migrations/", "message": "Migrace vytváří jen uživatel." },
    { "pattern": "/wwwroot/lib/", "message": "Knihovny třetích stran se neupravují, spravuje je LibMan." }
  ],
  "buildOnStop": ["dotnet", "build", "Shop.sln"]
}
```

Do `.gitignore` přidejte obsah [templates/gitignore.snippet](../templates/gitignore.snippet).

### 4b. Zákaz čtení secrets

[templates/claude-settings.project.json](../templates/claude-settings.project.json) → `.claude/settings.json` projektu (commitovat, platí pro celý tým). Zakazuje Claude Code číst `.env`, `secrets.json`, lokální `appsettings.*.local.json`, certifikáty a klíče a úložiště User Secrets. Seznam doplňte o další soubory se secrets, které projekt má. Pro soukromé účty povinné ([data-handling.md](../governance/data-handling.md#technická-opatření)).

Ověření: pokyn „Přečti soubor .env“ musí Claude odmítnout s odkazem na nastavení oprávnění.

### 5. Ověření, že vše funguje

Ještě bez `/manager`, v běžné session:

| Pokyn | Co ověřuje | Očekávaný výsledek |
|---|---|---|
| „Vysvětli mi architekturu projektu a kde je logika objednávek.“ | `CLAUDE.md` a standardy | odpověď odpovídá skutečnosti; pokud ne, chybí to v `CLAUDE.md` |
| „Spusť build a testy.“ | příkazy | build a testy projdou stejně jako u vás |
| „Spusť aplikaci a ověř, že běží.“ | hooky, profil | hook zamítne `dotnet run` v popředí, Claude ji spustí na pozadí, ověří `curl` a ukončí |
| „Vytvoř migraci AddNote.“ | lidská brána | hook příkaz zamítne s vaší zprávou |
| „Nech agenta reviewer projít posledních 5 commitů.“ | reviewer + checklist | nálezy odkazují na ID z checklistu |

Co nefunguje, opravte teď – v běhu `/manager` by to stálo celá kola. Pak commit: `chore: příprava projektu pro agenty`.

---

## Fáze 2: první zadání

### Výběr

Zvolte něco malého, ohraničeného a s viditelným výsledkem:

- ✓ filtr a export na existujícím seznamu, nový jednoduchý formulář, validace a texty u stávajícího formuláře
- ✗ změna architektury, nová autentizace, cokoli s rozsáhlou migrací dat

### 1. Zadání

Podle [templates/zadani.template.md](../templates/zadani.template.md), uložit např. jako `docs/zadani/export-objednavek.md`. Cíl, rozsah, co do zadání nepatří, omezení. Neověřené hodnoty nepište jako fakta – napište, jak se mají zjistit.

### 2. `/navrh docs/zadani/export-objednavek.md` (u prvního malého zadání volitelné)

Dva architekti nezávisle připraví varianty A a B, dostanete srovnávací tabulku. **Variantu vybíráte vy**; zvolené řešení se zapíše do zadání. Podrobně v [dual-design.md](dual-design.md).

### 3. `/manager docs/zadani/export-objednavek.md`

Manažer navrhne plán, například:

| # | Úkol | Ověření | UI | Model |
|---|---|---|---|---|
| 1 | Query exportu s filtrem a stránkováním + testy | testy | ne | ne |
| 2 | Akce `Export` vracející CSV, oprávnění | testy + `curl` | ne | ne |
| 3 | Tlačítko Export na seznamu objednávek | prohlížeč | ano | ne |

Každý úkol má akceptační kritéria (AC1, AC2, …). **Plán schvalujete vy.** Tady se vyplatí být přísný: nejasná AC = zbytečná kola. Ptejte se: „Jak tester pozná, že AC2 platí?“

### 4. Smyčka pro každý úkol

Bez vašeho zásahu, pokud vše projde:

1. `vyvojar` napíše kód a testy.
2. Hook spustí build; chyby vrátí vývojáři k opravě.
3. Mění se datový model? Manažer se zastaví a **migraci vytvoříte vy**.
4. `reviewer` (kód proti standardům a checklistu) a `tester` (aplikace, AC v prohlížeči) běží souběžně.
5. U UI úkolu `ui-ux`.
6. Commit úkolu a 2–3 věty od manažera.

Neprojde-li úkol, vrací se vývojáři s konkrétními nálezy. Po 3 kolech se manažer zastaví a čeká na vás. Celý průběh je ve [agentic-dev-loop.md](agentic-dev-loop.md).

### 5. Konec běhu

- Shrnutí: commity, náměty, otevřené otázky.
- Návrh 0–3 poučení do profilu (např. „tester se do adminu přihlašuje účtem admin@test“). **Schvalujete vy.**
- Push a pull request děláte vy. PR review člověkem probíhá jako u každé jiné změny.

### 6. Retrospektiva

Projděte `.claude/runs/<slug>/stav.md`:

- Kolik kol potřeboval který úkol a proč se vracel?
- Opakovaný nález reviewera → nové pravidlo do checklistu nebo `CLAUDE.md`.
- Tester se nemohl přihlásit nebo nevěděl, jak ověřit → doplnit profil.
- Nález, který platí pro všechny projekty → návrh změny agenta nebo standardu v tomto repozitáři.

Čísla zapište do [evidence/metrics.md](../evidence/metrics.md); zajímavý běh jako případovou studii do [evidence/case-studies](../evidence/case-studies/).

---

## Co očekávat

- **První 2–3 zadání** ladí profil, `CLAUDE.md` a checklist víc, než šetří čas. To je v pořádku a patří to k zavedení.
- **Pak** se smyčka zrychlí: méně kol na úkol, méně eskalací. Sledujte to v metrikách – je to nejlepší doklad, že proces dozrává.
- Pokud úkoly opakovaně padají na stejném místě, problém je obvykle v zadání nebo profilu, ne v agentech.
