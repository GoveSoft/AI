# Coding standards GoveSoft

Sady pravidel (Markdown) pro promptování AI asistentů. Stačí v promptu odkázat na `index.md` příslušné sady. Každý `index.md` obsahuje rychlou kontrolu a seznam modulů. Přehled všech sad je v [index.md](index.md).

## Backend / .NET

| Sada | Obsah |
|---|---|
| [csharp](backend/csharp/index.md) | Pojmenování (`_camelCase` fieldy, PascalCase konstanty), async/await bez `async void`, nullable reference types, žádné magic strings, specifické výjimky, architektura, unit testy s fake implementacemi místo mocků |
| [aspnet-mvc](backend/aspnet-mvc/index.md) | Tenké controllery, ViewModel pro view a input model pro POST (žádné entity, žádný `[Bind]`), PRG, tag helpers, partial vs. view component, globální antiforgery a fallback autorizace, IDOR, open redirect, desetinná čárka v `cs-CZ` |
| [api-design](backend/api-design/index.md) | REST URL v kebab-case, HTTP status kódy, RFC 9457 ProblemDetails, cursor paginace, FluentValidation, verzování v URL |
| [database-ef](backend/database-ef/index.md) | EF Core migrace, indexy na FK, soft delete přes query filter, audit columns, AsNoTracking, žádné N+1 |
| [blazor](backend/blazor/index.md) | Interactive Server: vědomý render mode, prerendering bez dvojího načítání, DbContext přes factory, žádný HttpContext v komponentách, dispose odběrů, InvokeAsync, sticky sessions |
| [environment-config](backend/environment-config/index.md) | User Secrets / Key Vault, strongly-typed options s ValidateOnStart, Docker jako non-root, health probes |
| [observability](backend/observability/index.md) | Serilog se strukturovaným logováním, bez PII, CorrelationId, health checks, OpenTelemetry |
| [performance](backend/performance/index.md) | Nejdřív měřit (dotnet-counters, BenchmarkDotNet), async až dolů, alokace v hot paths (Span, ArrayPool), FrozenDictionary, source generatory, HybridCache, output cache, streamování |
| [resilience](backend/resilience/index.md) | IHttpClientFactory + `AddStandardResilienceHandler`, retry jen pro přechodné chyby, circuit breaker, timeouty, EF execution strategy, Idempotency-Key, fallback |
| [email-notifications](backend/email-notifications/index.md) | Outbox pattern, plain-text alternativa, unsubscribe, SPF/DKIM/DMARC, hard bounce |
| [security](backend/security/index.md) | OWASP Top 10: injection, CSP/HSTS hlavičky, CSRF, CORS, rate limiting, bezpečné uploady, závislosti |

## Architektura & návrh

| Sada | Obsah |
|---|---|
| [design-principles](architecture/design-principles/index.md) | SOLID v moderním C#, composition over inheritance, Law of Demeter, feature cohesion, YAGNI / KISS / DRY, kdy interface s jednou implementací |
| [design-patterns](architecture/design-patterns/index.md) | GoF vzory idiomaticky v .NET 8+ (DI, keyed services, Scrutor decorator, specification, state, middleware), ke každému „kdy ne" |
| [clean-architecture](architecture/clean-architecture/index.md) | Rozhodovací tabulka stylů, závislosti dovnitř, porty a adaptéry, `internal` jako výchozí, architektonické testy (NetArchTest) |
| [ddd](architecture/ddd/index.md) | Bohatý model bez public setterů, value objects jako record, strongly-typed IDs, malé agregáty, repository per aggregate, domain events, bounded contexts a ACL |
| [cqrs](architecture/cqrs/index.md) | Command vs. query, jeden handler = jeden use case, decoratory pro validaci a logování, vertical slices, MediatR/AutoMapper jen po licenčním rozhodnutí |
| [modular-monolith](architecture/modular-monolith/index.md) | Modul = bounded context, vlastní DbContext a schéma, komunikace přes `*.Contracts` a integration events, bez transakcí přes moduly, cesta k mikroslužbě |
| [event-driven](architecture/event-driven/index.md) | Domain vs. integration events, aditivní verzování kontraktů, Outbox/Inbox, retry + DLQ, choreografie vs. sagy, event sourcing jen vědomě |
| [adr](architecture/adr/index.md) | Architecture Decision Records v `docs/adr/`, šablona, přijatý ADR se nemění, ale nahrazuje; AI agent ADR čte před architektonickou změnou |

## Frontend / web

| Sada | Obsah |
|---|---|
| [javascript](frontend/javascript/index.md) | TypeScript strict, `const` jako výchozí, žádné `any`, ošetřené async chyby, řazení importů |
| [tailwind](frontend/tailwind/index.md) | Mobile-first třídy, bez arbitrárních hodnot, kontejnery, obrázky s aspect-*, motion-safe |
| [responsive-pwa](frontend/responsive-pwa/index.md) | Mobile-first, touch targety 44 px, manifest, service worker, formuláře, Lighthouse PWA ≥ 90 |
| [seo](frontend/seo/index.md) | Title + meta description, canonical, jeden H1, sitemap, Core Web Vitals, strukturovaná data, a11y |

## Obecné

| Sada | Obsah |
|---|---|
| [nasa](general/nasa/index.md) | NASA JPL 10 pravidel (Holzmann) adaptovaná pro C#/JS: omezené smyčky, krátké funkce, assertions, kontrola návratových hodnot |
| [testing-advanced](general/testing-advanced/index.md) | Testovací pyramida, unit vs. integrační test podle vrstvy, fake místo mocků, determinismus (FakeTimeProvider), Builder, WebApplicationFactory, Testcontainers, bUnit pro Blazor, coverage po vrstvách, mutační testy |
| [git-cicd](general/git-cicd/index.md) | Conventional Commits, prefixy větví, squash merge, CI pipeline, žádné secrets v commitu |
| [external-apis](references/external-apis/index.md) | Reference externích služeb (Mapy.com Tile API: URL, jazyky, rate limit) |

## Použití v projektu

V `CLAUDE.md` projektu importujte jen sady, které projekt opravdu používá:

```
@<cesta-k-repu>/standards/backend/csharp/index.md
@<cesta-k-repu>/standards/general/nasa/index.md
```

Nebo přímo v promptu: „Dodržuj pravidla z `standards/backend/csharp/index.md`.“
Postup pro napojení repozitáře do projektu je ve [workflows/standards-in-projects.md](../workflows/standards-in-projects.md).
