# Nakládání s daty v AI nástrojích

Stav: **návrh** · Schválil: <!-- jméno -->

## Klasifikace

| Třída | Příklady | Do AI nástroje |
|---|---|---|
| Veřejné | open-source kód, veřejná dokumentace | ano |
| Interní | kód GoveSoft, interní dokumentace | ano, schválené nástroje; soukromý účet jen za podmínek [ai-policy.md](ai-policy.md#soukromé-účty) |
| Klientské | kód a dokumentace klienta | jen pokud to smlouva s klientem dovoluje <!-- ověřit u každého klienta -->; na soukromém účtu jen s výslovným souhlasem klienta |
| Důvěrné | secrets, klíče, connection stringy, certifikáty | **nikdy** |
| Osobní údaje | produkční data s PII, logy s PII, exporty databází | **nikdy**; pro ladění používat anonymizovaná nebo syntetická data |

## Technická opatření

- Secrets mimo repozitář (User Secrets, Key Vault) – viz [standards/backend/environment-config](../standards/backend/environment-config/index.md) a [standards/backend/security](../standards/backend/security/index.md). Agent tak secrets v kódu nevidí.
- Logy bez PII – viz [standards/backend/observability](../standards/backend/observability/index.md).
- `.scratch/` a `.claude/runs/` jsou v `.gitignore` a necommitují se.
- **Zákaz čtení souborů se secrets** v nastavení Claude Code projektu (`permissions.deny`) podle [templates/claude-settings.project.json](../templates/claude-settings.project.json) – `.env`, certifikáty a klíče, lokální konfigurace se secrets, úložiště User Secrets.
- **Hook zamítá výpis secrets přes shell** (`dotnet user-secrets list`, čtení `.env` příkazem) – uživatelská konfigurace [hooks-config.user.example.json](../templates/hooks-config.user.example.json), ověřeno testy v [evals/hooks](../evals/hooks/).
- Projektový `hooks-config.json` může přes `protectedPaths` a `denyCommands` zablokovat přístup k dalším citlivým souborům a příkazům (např. připojení k produkční databázi).

Pro soukromé účty jsou tato opatření povinná, pro firemní plán důrazně doporučená.

## Nastavení účtů

Ověřeno podle [oznámení Anthropicu ze srpna 2025](https://www.anthropic.com/news/updates-to-our-consumer-terms) <!-- před schválením zkontrolovat aktuální podmínky -->:

| Plán | Trénování na konverzacích | Uchovávání | Povinné nastavení |
|---|---|---|---|
| Team, Enterprise, API | nepoužívá se (obchodní podmínky) | podle smlouvy | – |
| Free, Pro, Max (soukromý účet) | volba uživatele v nastavení soukromí | 30 dní při vypnutí, 5 let při zapnutí | **trénování vypnuté**, dvoufaktorové ověření přihlašovacího účtu, [prohlášení](account-attestation.md) |

Volba se týká nových a obnovených konverzací a coding sessions. Konverzace vedené při zapnutém trénování už mohly být použity a vypnutí je nevrací. Uživatel proto ověřuje nastavení **před** prvním použitím na firemním kódu.

## Co dělat při chybě

Pokud do AI nástroje unikne důvěrný údaj (např. klíč v promptu nebo v souboru, který agent četl): klíč okamžitě zneplatnit a vyměnit, nahlásit jako incident podle [ai-policy.md](ai-policy.md).
