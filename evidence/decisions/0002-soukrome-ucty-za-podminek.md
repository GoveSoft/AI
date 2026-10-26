# 0002: Soukromé účty Claude povolené za přísnějších podmínek

Stav: přijato · Datum: 2026-10-26 · Rozhodl: Milan Chvojka

## Kontext

Vývojáři používají soukromé účty Claude (plány Pro/Max), ne firemní plán. Firma u nich nespravuje nastavení dat, nevidí, kdo AI používá, a při odchodu zaměstnance nemůže odebrat přístup ke konverzacím. U spotřebitelských plánů Anthropicu je použití konverzací pro trénování volbou uživatele a určuje i dobu uchovávání (30 dní / 5 let). Odkaz na konverzaci v commitu je u soukromého účtu přístupný jen majiteli, takže jako doklad postupu nefunguje.

## Zvažované varianty

1. Jen firemní plán (Team/Enterprise) – nejvyšší kontrola, vyšší náklady, změna pro všechny uživatele.
2. Soukromé účty bez zvláštních pravidel – nejjednodušší, ale firma nemůže doložit ochranu dat.
3. **Soukromé účty za přísnějších podmínek** – povinná nastavení, prohlášení uživatele, technická opatření nezávislá na typu účtu.

## Rozhodnutí

Varianta 3. Podmínky jsou v [ai-policy.md – Soukromé účty](../../governance/ai-policy.md#soukromé-účty) a [data-handling.md](../../governance/data-handling.md):

- trénování vypnuté, dvoufaktorové ověření, roční [prohlášení uživatele](../../governance/account-attestation.md),
- klientský kód jen s výslovným souhlasem klienta,
- povinný zákaz čtení secrets v nastavení Claude Code a hooky proti jejich výpisu přes shell,
- dohledatelnost postupu v repozitáři (PR, archivovaný `stav.md`, ADR), ne odkazem na konverzaci; commity bez podpisových řádků AI.

## Důsledky

- Kontrola nastavení stojí na prohlášení uživatele, ne na technickém vynucení – governance zůstává v [MATURITY.md](../../MATURITY.md) na úrovni 2–3.
- Nové riziko R10 v [registru rizik](../../governance/risk-register.md).
- Přechod na firemní plán zůstává cílovým stavem; přehodnotit při růstu počtu uživatelů nebo na žádost klienta.
