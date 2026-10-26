# ASP.NET Core MVC — Formuláře & validace

## Input model a PRG

```csharp
public sealed class OrderEditInput
{
    [Required, StringLength(200)]
    public string Note { get; set; } = "";

    [Range(1, 1000)]
    public int Quantity { get; set; }

    public OrderEditCommand ToCommand(OrderId id) => new(id, Note.Trim(), Quantity);
}

[HttpGet("{id:guid}/upravit")]
public async Task<IActionResult> Edit(Guid id, CancellationToken ct)
{
    var order = await queries.GetForEditAsync(new OrderId(id), ct);
    return order is null ? NotFound() : View(OrderEditInput.From(order));
}

[HttpPost("{id:guid}/upravit")]
public async Task<IActionResult> Edit(Guid id, OrderEditInput input, CancellationToken ct)
{
    if (!ModelState.IsValid) return View(input);

    var result = await dispatcher.SendAsync(input.ToCommand(new OrderId(id)), ct);
    if (result.IsFailure)
    {
        ModelState.AddModelError(string.Empty, result.Error.Message);   // business chyba → do formuláře
        return View(input);
    }

    TempData[FlashKeys.Success] = "Objednávka byla uložena.";
    return RedirectToAction(nameof(Detail), new { id });               // PRG
}
```

- **Input model** = mutable třída pro binding, jen pole formuláře. Oddělený od ViewModelu pro zobrazení (pokud view potřebuje i číselníky, obal: `OrderEditViewModel { Input, Statuses }`), od commandu i od entity.
- **Post/Redirect/Get:** úspěšný POST vždy končí redirectem. ✗ `return View()` po úspěšném uložení – F5 odešle formulář znovu.
- Neúspěch → stejný view se stejným input modelem. Číselníky pro selecty se při návratu musí znovu načíst.
- Business chyba z handleru (`Result`) se zobrazí ve formuláři (`ModelState.AddModelError`), nevyhazuje se výjimka.
- `TempData` jen pro krátké zprávy po redirectu (flash message) – výchozí provider ukládá do cookie, takže malé a jednoduché hodnoty. ✗ Objekty a seznamy v `TempData`, ✗ `Session` pro stav formuláře.

## Validace

- **DataAnnotations na input modelu** pro tvar vstupu (povinnost, délka, rozsah, formát). Generují i klientskou validaci.
- **Business pravidla** (unikátnost, stav objednávky, oprávnění) ve validátoru commandu v pipeline (`cqrs/cqrs-pipeline.md`) nebo v doméně. Spustí se vždy, i když klientská validace selže nebo chybí.
- FluentValidation v MVC: volat validátor explicitně (v akci nebo v pipeline) a chyby přenést do `ModelState`. Automatickou integraci do MVC pipeline FluentValidation už nedoporučuje.
- Klientská validace je UX, ne ochrana. Server validuje vždy.
- Chybové zprávy česky a konkrétně (`ErrorMessage = "Zadejte množství 1–1000."`) nebo z resources; ne výchozí anglické.

## Formulář ve view

```cshtml
@model OrderEditInput

@* Formulář na stejnou akci: id doplní ambientní hodnota z aktuální routy *@
<form asp-action="Edit" method="post">
    <div asp-validation-summary="ModelOnly" role="alert"></div>

    <label asp-for="Note">Poznámka</label>
    <textarea asp-for="Note"></textarea>
    <span asp-validation-for="Note"></span>

    <label asp-for="Quantity">Množství</label>
    <input asp-for="Quantity" inputmode="numeric" />
    <span asp-validation-for="Quantity"></span>

    <button type="submit">Uložit</button>
</form>

@section Scripts { <partial name="_ValidationScriptsPartial" /> }
```

- `<form>` s `asp-action` / `asp-controller` vloží antiforgery token automaticky. ✗ Ruční `<form action="/…">` bez tag helperu – token chybí.
- `asp-validation-summary="ModelOnly"` pro chyby celého formuláře, `asp-validation-for` u polí.
- Přístupnost a mobilní atributy (`label`, `autocomplete`, `inputmode`) podle `responsive-pwa/forms.md`.
- Ochrana proti dvojímu odeslání: tlačítko po odeslání zablokovat v JS; server musí být odolný i tak (idempotence u plateb a objednávek, viz `resilience/`).

## Česká kultura: čísla a data

Nejčastější past v českých MVC aplikacích: desetinná čárka.

```csharp
var cs = new CultureInfo("cs-CZ");
builder.Services.Configure<RequestLocalizationOptions>(o =>
{
    o.DefaultRequestCulture = new RequestCulture(cs);
    o.SupportedCultures = o.SupportedUICultures = [cs];
});
app.UseRequestLocalization();   // před UseRouting / MapControllerRoute
```

- Server: hodnoty z formuláře se parsují kulturou požadavku → bez `UseRequestLocalization` s `cs-CZ` se `12,5` nenaváže (nebo se naváže jinak, než uživatel zamýšlel).
- Klient: jQuery Validation ve výchozím stavu přijímá jen desetinnou tečku. Pro `cs-CZ` je nutné upravit metody `number` a `range` (nebo použít knihovnu s podporou kultur), jinak klientská validace odmítne `12,5`, kterou server přijme.
- Ověřit oběma směry u každého pole typu `decimal`, `double`, `DateTime`, `DateOnly`: zadání `12,5`, `12.5`, `1 000,5`, datum `1. 2. 2026`.
- Hodnoty v query stringu a v route se parsují invariantně (tečka) – filtry s desetinnými čísly v URL podle toho.

## Upload souborů

- `IFormFile` v input modelu, limit velikosti (`[RequestSizeLimit]`, `FormOptions`), kontrola typu podle obsahu, uložení mimo `wwwroot` – podrobně `security/sec-uploads-deps.md`.
- Formulář s `enctype="multipart/form-data"`.
