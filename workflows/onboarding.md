# Onboarding

## Vývojář (cca 1 hodina)

1. Přečíst [governance/ai-policy.md](../governance/ai-policy.md), [data-handling.md](../governance/data-handling.md) a [human-in-the-loop.md](../governance/human-in-the-loop.md).
2. Získat firemní účet ke [schváleným AI nástrojům](../governance/ai-policy.md#schválené-nástroje) a zapnout jednotné přihlášení nebo dvoufaktorové ověření.
3. Vyplnit [prohlášení uživatele AI](../governance/account-attestation.md).
4. U Claude Code nainstalovat plugin a uživatelskou konfiguraci hooků podle [plugin/README.md](../plugin/README.md). U jiného agentního nástroje nastavit omezení podle [pravidel pro data](../governance/data-handling.md#technická-opatření) a [lidských bran](../governance/human-in-the-loop.md#jiné-ai-nástroje).
5. U Claude Code na cvičném projektu projít: `/navrh` na malém zadání, výběr varianty, `/manager`, schválení plánu, jeden úkol až po commit.
6. Potvrdit absolvování <!-- kam: formulář / záznam v HR systému -->. Evidence slouží jako doklad AI gramotnosti (EU AI Act, čl. 4).

## Nový projekt (cca 1 hodina)

Podrobný průvodce s příklady pro ASP.NET Core MVC: [first-project.md](first-project.md). Seznam platí pro Claude Code, u jiného nástroje se nastavují obdobná omezení.

- [ ] `CLAUDE.md` vygenerovaný skillem `claude-md` a zkontrolovaný člověkem
- [ ] Importy standardů podle [standards-in-projects.md](standards-in-projects.md)
- [ ] `.claude/agentic/profil.md` z [templates/profil.template.md](../templates/profil.template.md)
- [ ] `.claude/hooks-config.json` z [templates/hooks-config.project.example.json](../templates/hooks-config.project.example.json) – port, chráněné cesty, `buildOnStop`
- [ ] `.gitignore` doplněný o [templates/gitignore.snippet](../templates/gitignore.snippet)
- [ ] `.claude/settings.json` ze [templates/claude-settings.project.json](../templates/claude-settings.project.json) – zákaz čtení secrets
- [ ] U klientského projektu ověřeno, že smlouva použití AI dovoluje ([ai-policy.md](../governance/ai-policy.md))
