# ASP.NET Core MVC — Razor views

## ViewModel

```csharp
public sealed record OrderDetailViewModel(
    Guid Id,
    string Number,
    string CustomerName,
    string StatusText,
    bool CanCancel,
    IReadOnlyList<OrderLineViewModel> Lines)
{
    public static OrderDetailViewModel From(OrderDetailDto o) => new(
        o.Id, o.Number, o.CustomerName, o.Status.ToDisplayText(),
        CanCancel: o.Status is OrderStatus.New or OrderStatus.Confirmed,
        o.Lines.Select(OrderLineViewModel.From).ToList());
}
```

- **Každý view má vlastní ViewModel** – immutable `record`, jen to, co view zobrazuje, už připravené (texty, formáty, příznaky).
- Rozhodnutí typu „smí se zobrazit tlačítko Zrušit“ počítá ViewModel nebo služba (`CanCancel`), ne `@if` s business podmínkou ve view.
- ✗ Entita ve view (`@model Order`). Lazy loading při renderování, únik dat do HTML, view svázaný s doménou.
- ✗ `ViewBag` / `ViewData` pro data stránky. Výjimka: titulek stránky a podobná metadata layoutu, a to s konstantním klíčem.

## Co patří do view

- ✓ Zobrazení, smyčky přes připravená data, podmínky na zobrazovacích příznacích, formátování přes sdílené helpery.
- ✗ Volání služeb (`@inject` repository / `DbContext`), výpočty, LINQ s filtrováním, `try/catch`.
- `@inject` ve view jen pro zobrazovací služby: `IViewLocalizer`, `IOptions<UiOptions>`, feature flagy.
- Formátování čísel, měn a dat přes jeden sdílený helper nebo tag helper s explicitní kulturou, ne `ToString("N2")` roztroušené po views.

## Znovupoužití

| Potřeba | Nástroj |
|---|---|
| kus markupu bez vlastních dat | **partial** (`<partial name="_OrderLines" model="Model.Lines" />`) |
| kus stránky s vlastními daty (menu, košík, notifikace) | **view component** (`<vc:cart-summary />`) |
| opakovaný HTML prvek s atributy (badge, ikona, pole formuláře) | **tag helper** |
| rozvržení stránky | layout + `@section` |

```csharp
public sealed class CartSummaryViewComponent(ICartQueries cart, ICurrentUser user) : ViewComponent
{
    public async Task<IViewComponentResult> InvokeAsync()
        => View(await cart.GetSummaryAsync(user.Id, HttpContext.RequestAborted));
}
```

- Partial s daty je špatně zvolený nástroj – partial nesmí sahat pro data. Použij view component.
- ✗ `@Html.Partial` / `@Html.RenderPartial` (synchronní). Vždy `<partial>` tag helper nebo `@await Html.PartialAsync`.
- Názvy partials s podtržítkem (`_OrderLines.cshtml`), sdílené v `Views/Shared`.

## Tag helpers místo HTML helperů

```cshtml
<a asp-action="Detail" asp-route-id="@order.Id">@order.Number</a>
<form asp-action="Cancel" asp-route-id="@Model.Id" method="post">…</form>
<link rel="stylesheet" href="~/css/app.css" asp-append-version="true" />
<script src="~/js/orders.js" asp-append-version="true"></script>
```

- Tag helpers jako výchozí (`asp-for`, `asp-action`, `asp-route-*`, `asp-append-version`). HTML helpery (`@Html.ActionLink`, `@Html.TextBoxFor`) jen ve starém kódu, nové nepřidávat.
- `asp-append-version="true"` u vlastních CSS a JS – cache busting bez ručního verzování.
- `@addTagHelper` a společné `@using` v `_ViewImports.cshtml`, ne v jednotlivých views.

## Layout a sekce

- Jeden hlavní `_Layout.cshtml`; odlišné rozvržení (admin, tisk) jako další layout, ne podmínky v jednom.
- Skripty stránky do `@section Scripts { … }` vykreslené na konci `<body>`. Volitelné sekce `RenderSectionAsync("Scripts", required: false)`.
- Titulek a meta tagy stránky podle `seo/meta-tags.md`.

## Data pro JavaScript

```cshtml
<script>
    const orderConfig = @Json.Serialize(Model.ClientConfig);
</script>
```

- Data do JavaScriptu jen přes `@Json.Serialize` (HTML-bezpečně escapované). ✗ `var name = '@Model.Name';` – Razor kóduje pro HTML, ne pro JavaScript.
- Lepší než inline skripty: `data-*` atributy na elementu a skript v samostatném souboru (kompatibilní s CSP, viz `security/sec-headers.md`).

## Kompilace a výkon

- Views se kompilují při buildu; chyba ve view = chyba buildu. `AddRazorRuntimeCompilation` jen ve vývoji, nikdy v produkci (pro vývoj stačí Hot Reload).
- Dlouhé seznamy vždy stránkované na serveru; view nikdy nedostane „všechno“.
- Fragmenty sdílené všemi uživateli (menu, patička) lze cachovat `<cache>` tag helperem s `vary-by`; nic, co závisí na uživateli, bez `vary-by-user`.
