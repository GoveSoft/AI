# ASP.NET Core MVC — controllery a Razor views

Pro ASP.NET Core MVC (.NET 8+) se serverově renderovanými Razor views. Klasické ASP.NET MVC 5 na .NET Frameworku sem nepatří – liší se pipeline, DI i bezpečnostní výchozí nastavení. Navazuje na `csharp/`, `security/`, `database-ef/`, `cqrs/`, `observability/`, `responsive-pwa/forms.md`, `testing-advanced/test-integration.md`.

## Moduly

@mvc-controllers.md
@mvc-views.md
@mvc-forms-validation.md
@mvc-security.md

## Rychlá kontrola

- [ ] Controller je tenký: přijme vstup, zavolá službu / handler, vybere výsledek. Žádné dotazy do `DbContext` ani business pravidla v akci
- [ ] View dostává **ViewModel**, nikdy entitu. POST akce přijímá **input model**, nikdy entitu (overposting)
- [ ] Žádný `[Bind]` – místo whitelistu vlastností samostatný input model
- [ ] Každá POST akce: `ModelState.IsValid` → při chybě znovu stejný view se stejným modelem; při úspěchu **redirect** (PRG)
- [ ] Antiforgery globálně (`AutoValidateAntiforgeryTokenAttribute`), formuláře přes `<form asp-…>` tag helper
- [ ] Autorizace výchozí pro vše (`FallbackPolicy`), výjimky explicitně `[AllowAnonymous]`; přístup k objektu podle ID ověřen v handleru (IDOR)
- [ ] Návratové URL jen přes `LocalRedirect` / `Url.IsLocalUrl` (open redirect)
- [ ] Žádné `@Html.Raw` s daty od uživatele; data pro JavaScript přes `@Json.Serialize`
- [ ] Žádná logika ve view kromě zobrazovací; opakované části jako partial, tag helper nebo view component
- [ ] Odkazy a URL z tag helperů (`asp-action`, `asp-route-*`), ne ručně skládané řetězce
- [ ] Desetinná čísla a data ve formulářích ověřená v české kultuře (čárka) na serveru i v klientské validaci
- [ ] Async akce s `CancellationToken`, žádné `.Result` / `.Wait()`
- [ ] Chybové stránky přes `UseExceptionHandler` + `UseStatusCodePagesWithReExecute`, v produkci žádná developer exception page
- [ ] Integrační testy přes `WebApplicationFactory` pro klíčové toky včetně antiforgery a autorizace

## Kdy MVC NEpoužívat

- Stránka = jeden formulář nebo jeden pohled bez sdílených akcí → Razor Pages jsou jednodušší (stejné principy této sady platí).
- Bohatá interaktivita bez reloadu (živé filtry, drag & drop, real-time) → Blazor (`blazor/`) nebo cílený JavaScript nad MVC, ne SPA framework vedle MVC bez rozhodnutí v ADR.
- Čisté API pro jiné klienty → `[ApiController]` podle `api-design/`, ne MVC akce vracející JSON.
