# Mapování na normy a regulaci

Tabulka ukazuje, kde v repozitáři je doklad k požadavku. Nejde o prohlášení o shodě – to vyžaduje posouzení odpovědnou osobou.

## ISO/IEC 27001:2022 (Annex A)

| Opatření | Doklad |
|---|---|
| A.5.12 Klasifikace informací | [data-handling.md](data-handling.md) |
| A.5.23 Bezpečnost cloudových služeb | [ai-policy.md](ai-policy.md) – schválené nástroje a podmínky pro soukromé účty, [account-attestation.md](account-attestation.md) |
| A.6.3 Povědomí a školení | [onboarding.md](../workflows/onboarding.md), [account-attestation.md](account-attestation.md) |
| A.8.25 Bezpečný životní cyklus vývoje | [agentic-dev-loop.md](../workflows/agentic-dev-loop.md), [human-in-the-loop.md](human-in-the-loop.md) |
| A.8.28 Bezpečné programování | [standards/backend/security](../standards/backend/security/index.md), [standards/general/nasa](../standards/general/nasa/index.md) |
| A.8.32 Řízení změn | lidské brány, PR review, [CONTRIBUTING.md](../CONTRIBUTING.md) |

## ISO/IEC 42001:2023 (systém řízení AI)

| Oblast | Doklad |
|---|---|
| Politika AI | [ai-policy.md](ai-policy.md) |
| Role a odpovědnosti | [ai-policy.md](ai-policy.md) – Odpovědnost, [governance/README.md](README.md) – vlastníci |
| Posouzení rizik AI | [risk-register.md](risk-register.md) |
| Lidský dohled | [human-in-the-loop.md](human-in-the-loop.md) |
| Monitorování a měření | [evidence/metrics.md](../evidence/metrics.md) |
| Neustálé zlepšování | [MATURITY.md](../MATURITY.md), poučení v profilech, [evidence/decisions](../evidence/decisions/) |

## EU AI Act

GoveSoft je při vývoji v roli **uživatele (deployer)** obecných AI nástrojů, ne jejich poskytovatele. Asistent pro programování sám o sobě nespadá mezi vysoce rizikové systémy.

| Požadavek | Doklad |
|---|---|
| Čl. 4 – AI gramotnost zaměstnanců | [onboarding.md](../workflows/onboarding.md), evidence školení <!-- doplnit --> |
| Vývoj AI systémů pro klienty (pokud nastane) | <!-- doplnit: posoudit klasifikaci rizika u každého takového projektu --> |
