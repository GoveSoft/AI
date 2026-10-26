# Metriky

Zdroj dat: stavové soubory běhů `.claude/runs/<slug>/stav.md` (počty kol, eskalace, commity), git historie a evaly. Sbírat čtvrtletně.

| Metrika | Definice | Proč | Cíl |
|---|---|---|---|
| Úkoly napoprvé | úkoly schválené reviewerem i testerem v 1. kole / všechny úkoly | kvalita zadání a vývojáře | <!-- --> |
| Průměr kol na úkol | součet kol / počet úkolů | efektivita smyčky | <!-- --> |
| Míra eskalací | úkoly eskalované po 3 kolech / všechny úkoly | kde AI nestačí | <!-- --> |
| Zachycení před PR | vady nalezené reviewerem/testerem / vady nalezené celkem (včetně PR review a produkce) | účinnost kontrol | <!-- --> |
| Vady z AI kódu v produkci | incidenty s příčinou v kódu z agentního běhu | bezpečnost procesu | 0 |
| Zásahy hooků | počet zamítnutí podle pravidla | co agenti zkoušejí obejít | sledovat trend |
| Záchyt reviewer evalu | viz [evals/reviewer](../evals/reviewer/) | kvalita agenta | <!-- --> |
| Pokrytí onboardingem | proškolení / uživatelé AI nástrojů | AI gramotnost | 100 % |
| Platná prohlášení | uživatelé s platným [prohlášením](../governance/account-attestation.md) / uživatelé AI nástrojů | kontrola soukromých účtů | 100 % |

## Hodnoty

| Čtvrtletí | Projekty | Úkoly | Napoprvé | Kola/úkol | Eskalace | Poznámka |
|---|---|---|---|---|---|---|
| 2026 Q4 | | | | | | první sběr |
