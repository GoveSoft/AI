# Onboarding

## Vývojář (cca 1 hodina)

1. Přečíst [governance/ai-policy.md](../governance/ai-policy.md), [data-handling.md](../governance/data-handling.md) a [human-in-the-loop.md](../governance/human-in-the-loop.md).
2. Soukromý účet: **před prvním použitím** vypnout v nastavení soukromí trénování na konverzacích a zapnout dvoufaktorové ověření přihlašovacího účtu.
3. Vyplnit [prohlášení uživatele AI](../governance/account-attestation.md).
4. Nainstalovat plugin a uživatelskou konfiguraci hooků podle [plugin/README.md](../plugin/README.md).
5. Na cvičném projektu projít: `/navrh` na malém zadání, výběr varianty, `/manager`, schválení plánu, jeden úkol až po commit.
6. Potvrdit absolvování <!-- kam: formulář / záznam v HR systému -->. Evidence slouží jako doklad AI gramotnosti (EU AI Act, čl. 4).

## Nový projekt (cca 1 hodina)

Podrobný průvodce s příklady pro ASP.NET Core MVC: [first-project.md](first-project.md).

- [ ] `CLAUDE.md` vygenerovaný skillem `claude-md` a zkontrolovaný člověkem
- [ ] Importy standardů podle [standards-in-projects.md](standards-in-projects.md)
- [ ] `.claude/agentic/profil.md` z [templates/profil.template.md](../templates/profil.template.md)
- [ ] `.claude/hooks-config.json` z [templates/hooks-config.project.example.json](../templates/hooks-config.project.example.json) – port, chráněné cesty, `buildOnStop`
- [ ] `.gitignore` doplněný o [templates/gitignore.snippet](../templates/gitignore.snippet)
- [ ] `.claude/settings.json` ze [templates/claude-settings.project.json](../templates/claude-settings.project.json) – zákaz čtení secrets
- [ ] U klientského projektu ověřeno, že smlouva použití AI dovoluje ([ai-policy.md](../governance/ai-policy.md))
