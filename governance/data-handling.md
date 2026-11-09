# Nakládání s daty v AI nástrojích

Stav: **návrh** · Schválil: <!-- jméno -->

## Klasifikace

| Třída | Příklady | Do AI nástroje |
|---|---|---|
| Veřejné | open-source kód, veřejná dokumentace | ano |
| Interní | kód GoveSoft, interní dokumentace | ano, jen [schválené nástroje](ai-policy.md#schválené-nástroje) s firemním účtem |
| Klientské | kód a dokumentace klienta | jen pokud to dovoluje smlouva nebo písemný souhlas klienta, ověřuje se u každého klienta; jen schválené nástroje s firemním účtem |
| Důvěrné | secrets, klíče, connection stringy, certifikáty | **nikdy** |
| Osobní údaje | produkční data s PII, logy s PII, exporty databází | **nikdy**; pro ladění používat anonymizovaná nebo syntetická data |

## Technická opatření

- Secrets mimo repozitář (User Secrets, Key Vault) – viz [standards/backend/environment-config](../standards/backend/environment-config/index.md) a [standards/backend/security](../standards/backend/security/index.md). Agent tak secrets v kódu nevidí.
- Logy bez PII – viz [standards/backend/observability](../standards/backend/observability/index.md).
- `.scratch/` a `.claude/runs/` jsou v `.gitignore` a necommitují se.
- Agentní AI nástroj nesmí číst soubory se secrets ani je vypisovat přes shell. Nástroj, který to neumí omezit, se na projektu se secrets v pracovním adresáři nepoužívá.
- Zařízení, na kterých AI nástroje běží, mají šifrovaný disk, protože nástroje ukládají přepisy relací lokálně.

Implementace pro Claude Code:

- **Zákaz čtení souborů se secrets** v nastavení projektu (`permissions.deny`) podle [templates/claude-settings.project.json](../templates/claude-settings.project.json) – `.env`, certifikáty a klíče, lokální konfigurace se secrets, úložiště User Secrets.
- **Hook zamítá běžné způsoby výpisu a kopírování secrets přes shell** (`dotnet user-secrets list`, čtení nebo kopírování `.env` a dalších souborů se secrets, výpis proměnných prostředí) – uživatelská konfigurace [hooks-config.user.example.json](../templates/hooks-config.user.example.json), ověřeno testy v [evals/hooks](../evals/hooks/). Hook kontroluje text příkazu, takže nezachytí každý způsob čtení souboru.
- Šablona nastavení vypíná příkaz `/feedback` a dotazníky kvality relace, kterými by se přepis relace mohl dostat k poskytovateli.
- Projektový `hooks-config.json` může přes `protectedPaths` a `denyCommands` zablokovat přístup k dalším citlivým souborům a příkazům (např. připojení k produkční databázi).

## Účty a poskytovatelé

Na kódu a datech GoveSoft se používají jen firemní účty ([podmínky](ai-policy.md#podmínky-pro-ai-nástroje)). Za každý schválený nástroj je tady jeden řádek, který se ověřuje při schválení a při roční revizi.

| Nástroj a účet | Trénování na datech | Uchovávání u poskytovatele | Ověřeno | Zdroj |
|---|---|---|---|---|
| Claude Code, plán Team | ne (obchodní podmínky) | standardně 30 dní | 2026-11-09 | [Data usage](https://code.claude.com/docs/en/data-usage) |
| Codex, plán ChatGPT Business | ne ve výchozím stavu | neověřeno, zjistit v administraci nebo smlouvě před schválením | 2026-11-09 | [Plány Codexu](https://learn.chatgpt.com/docs/pricing) |

Výjimky u Claude Code, se kterými je nutné počítat:

- Přepisy odeslané příkazy `/feedback`, `/bug` a `/share` se uchovávají 5 let. Přepis sdílený po dotazníku kvality relace až 6 měsíců.
- Claude Code ukládá přepisy relací lokálně jako prostý text do `~/.claude/projects/`, standardně na 30 dní.

Implementace pro Codex (při nastavení projektu vyzkoušet, že omezení opravdu platí, protože chování se může lišit mezi CLI a aplikací):

- [Profil oprávnění](https://developers.openai.com/codex/permissions) zakazuje hodnotou `deny` čtení stejných souborů jako šablona pro Claude Code.
- Přístup k síti zůstává vypnutý a režim `danger-full-access` se nepoužívá.
- Žádosti o schválení posuzuje člověk (`approvals_reviewer = "user"`).

## Co dělat při chybě

Pokud do AI nástroje unikne důvěrný údaj (např. klíč v promptu nebo v souboru, který agent četl): klíč okamžitě zneplatnit a vyměnit, nahlásit jako incident podle [ai-policy.md](ai-policy.md).
