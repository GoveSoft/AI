# ASP.NET Core MVC — Bezpečnost

Obecná pravidla (hlavičky, CSRF, CORS, secrets, rate limiting) jsou v `security/`. Tady jsou pasti specifické pro MVC.

## Výchozí nastavení v Program.cs

```csharp
builder.Services.AddControllersWithViews(o =>
{
    o.Filters.Add(new AutoValidateAntiforgeryTokenAttribute());   // všechny POST/PUT/DELETE
});

builder.Services.AddAuthorization(o =>
{
    o.FallbackPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build();                                                // co není označené, vyžaduje přihlášení
});

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/chyba");
    app.UseHsts();
}
app.UseStatusCodePagesWithReExecute("/chyba/{0}");
```

- **Antiforgery globálně**, ne `[ValidateAntiForgeryToken]` na jednotlivých akcích – nová akce bez atributu by byla nechráněná. Výjimka (webhook) jen `[IgnoreAntiforgeryToken]` se zdůvodněním v komentáři.
- **Autorizace jako výchozí** přes `FallbackPolicy`. Veřejné akce explicitně `[AllowAnonymous]` – reviewer je vidí v diffu.
- Statické soubory: ověřte, zda jsou chráněné, nebo veřejné podle záměru. `UseStaticFiles` před autorizací je obsluhuje bez kontroly; u `MapStaticAssets` (.NET 9+) jde o endpointy a fallback politika se na ně může vztahovat.
- Chybové stránky bez detailů výjimky a stack trace; detail jen do logu s CorrelationId (`observability/`).

## Overposting (mass assignment)

```csharp
// ✗ Uživatel pošle IsAdmin=true nebo OwnerId=… v těle formuláře
public async Task<IActionResult> Edit(User user) { db.Update(user); … }

// ✗ [Bind] – whitelist v řetězci, na který se při přidání vlastnosti zapomene
public async Task<IActionResult> Edit([Bind("Name,Email")] User user) { … }

// ✓ Input model obsahuje jen to, co smí uživatel měnit
public async Task<IActionResult> Edit(Guid id, ProfileEditInput input, CancellationToken ct) { … }
```

- Vlastník, role, stav, ceny, příznaky schválení **nikdy** z formuláře. Přicházejí z přihlášeného uživatele nebo z databáze.
- Hidden pole je uživatelský vstup stejně jako textové pole.

## IDOR – přístup k cizím objektům

- ID v URL a ve formuláři je vstup od uživatele. Akce `Detail(id)`, `Edit(id)`, `Delete(id)` musí ověřit, že přihlášený uživatel smí právě tento objekt vidět nebo měnit.
- Kontrola v query nebo handleru (filtr podle vlastníka / tenanta), ne až ve view. Výsledek pro cizí objekt je `NotFound()`, ne `Forbid()` – neprozrazuje, že objekt existuje.
- Pro resource-based autorizaci `IAuthorizationService.AuthorizeAsync(User, resource, policy)` – viz `security/sec-auth.md`.

## Open redirect

```csharp
[HttpPost, AllowAnonymous]
public async Task<IActionResult> Login(LoginInput input, string? returnUrl, CancellationToken ct)
{
    …
    return LocalRedirect(Url.IsLocalUrl(returnUrl) ? returnUrl : "/");
}
```

- `returnUrl` a jakákoli URL od uživatele jen přes `LocalRedirect` (vyhodí výjimku pro cizí doménu) nebo s kontrolou `Url.IsLocalUrl`. ✗ `Redirect(returnUrl)`.

## XSS

- Razor kóduje výstup `@…` automaticky. Riziko vzniká jen obejitím:
  - ✗ `@Html.Raw(Model.Description)` s obsahem od uživatele. Pokud je nutné zobrazit formátovaný text, sanitizovat při ukládání (whitelist značek, knihovna HtmlSanitizer) a `Raw` použít jen na sanitizovaný výstup.
  - ✗ Hodnota vložená do JavaScriptu nebo do `onclick` atributu. Data pro JS přes `@Json.Serialize` nebo `data-*` atributy (viz `mvc-views.md`).
  - ✗ Uživatelská hodnota v `href` bez kontroly schématu (`javascript:`).
- Content Security Policy podle `security/sec-headers.md`; inline skripty ji komplikují, proto skripty v souborech.

## Cookies a přihlášení

- Autentizační cookie `HttpOnly`, `Secure`, `SameSite=Lax` (výchozí v ASP.NET Core Identity – neoslabovat).
- Po přihlášení a změně oprávnění nová cookie (Identity to dělá; u vlastní autentizace hlídat session fixation).
- Odhlášení jen přes POST s antiforgery tokenem, ne odkazem (GET).

## AJAX volání z MVC stránek

- POST přes `fetch` posílá antiforgery token v hlavičce (`RequestVerificationToken`), token z `@Html.AntiForgeryToken()` nebo `IAntiforgery.GetAndStoreTokens` – viz `security/sec-csrf-cors.md`.
- Endpoint pro AJAX má stejnou autorizaci a kontrolu IDOR jako stránka.
