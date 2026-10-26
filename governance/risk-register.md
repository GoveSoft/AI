# Registr rizik AI

Hodnocení: pravděpodobnost (P) a dopad (D) 1–3, skóre = P × D. Revize čtvrtletně.

| ID | Riziko | P | D | Skóre | Opatření | Zajištění | Vlastník |
|---|---|---|---|---|---|---|---|
| R1 | Únik secrets nebo osobních údajů do AI nástroje | 2 | 3 | 6 | Secrets mimo repo, logy bez PII, firemní účty | [data-handling.md](data-handling.md) | <!-- --> |
| R2 | Chybný kód projde do produkce | 2 | 3 | 6 | Nezávislý reviewer a tester, build hook, lidský PR review, CI | [human-in-the-loop.md](human-in-the-loop.md) | <!-- --> |
| R3 | Nevratná změna dat (migrace, drop) provedená agentem | 1 | 3 | 3 | Hook blokuje EF migrace a zápis do `/Migrations/` | `guard-bash`, `guard-write` | <!-- --> |
| R4 | Bezpečnostní zranitelnost v generovaném kódu | 2 | 3 | 6 | Sada [security](../standards/backend/security/index.md), reviewer, security scan v CI | standardy + CI projektu | <!-- --> |
| R5 | Agent obchází pravidla nebo předstírá ověření | 2 | 2 | 4 | Oddělení rolí, tester nepřebírá tvrzení vývojáře, eskalace po 3 kolech | definice agentů | <!-- --> |
| R6 | Osiřelé procesy a zablokované prostředí vývojáře | 2 | 1 | 2 | `guard-bash` (procesy v popředí), `cleanup.ps1` | hooky | <!-- --> |
| R7 | Ztráta know-how – vývojář nerozumí kódu, který odevzdal | 2 | 2 | 4 | Odpovědnost za commit u člověka, review PR | [ai-policy.md](ai-policy.md) | <!-- --> |
| R8 | Závislost na jednom poskytovateli AI | 2 | 2 | 4 | Standardy v obecném Markdownu, použitelné i v jiných nástrojích | <!-- doplnit plán B --> | <!-- --> |
| R9 | Porušení licence nebo smlouvy s klientem | 1 | 3 | 3 | Pravidla pro klientské projekty | [ai-policy.md](ai-policy.md) | <!-- --> |
| R10 | Soukromé účty mimo správu firmy: nevhodné nastavení dat, nemožnost odebrat přístup při odchodu | 2 | 3 | 6 | Povinné nastavení (trénování vypnuté, 2FA), prohlášení uživatele, klientský kód jen se souhlasem, technická opatření proti čtení secrets, cílově firemní plán | [ai-policy.md](ai-policy.md#soukromé-účty), [account-attestation.md](account-attestation.md) | <!-- --> |

## Historie

| Datum | Změna |
|---|---|
| 2026-10 | Výchozí návrh registru; R10 po rozhodnutí povolit soukromé účty ([ADR 0002](../evidence/decisions/0002-soukrome-ucty-za-podminek.md)) |
