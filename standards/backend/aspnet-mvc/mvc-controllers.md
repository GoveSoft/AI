# ASP.NET Core MVC — Controllery & routing

## Tenký controller

```csharp
[Route("objednavky")]
public sealed class OrdersController(IOrderQueries queries, IDispatcher dispatcher) : Controller
{
    [HttpGet("")]
    public async Task<IActionResult> Index([FromQuery] OrderFilterInput filter, CancellationToken ct)
    {
        var page = await queries.GetListAsync(filter.ToQuery(), ct);
        return View(OrderListViewModel.From(page, filter));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Detail(Guid id, CancellationToken ct)
    {
        var order = await queries.GetDetailAsync(new OrderId(id), ct);
        return order is null ? NotFound() : View(OrderDetailViewModel.From(order));
    }
}
```

- Akce dělá tři věci: **přijme vstup → zavolá službu nebo handler → vybere výsledek** (`View`, `RedirectToAction`, `NotFound`, `Forbid`).
- ✗ `DbContext` v controlleru, LINQ dotazy v akci, výpočty a business pravidla. Patří do query / handleru (viz `cqrs/`), aby šly testovat bez HTTP.
- ✗ Jeden „God controller“ s desítkami akcí. Controller = jedna oblast (feature), velké celky do **Areas** (`[Area("Admin")]`).
- `sealed` a primární konstruktor; závislosti jen přes DI, žádný service locator (`HttpContext.RequestServices`).
- `CancellationToken` jako parametr akce – MVC ho naváže na `HttpContext.RequestAborted` samo.

## Výsledky akcí

| Situace | Výsledek |
|---|---|
| zobrazení | `View(viewModel)` |
| úspěšný POST | `RedirectToAction(nameof(Detail), new { id })` (PRG, viz `mvc-forms-validation.md`) |
| neplatný vstup | `View(input)` – stejný view, stejný model, chyby v `ModelState` |
| objekt neexistuje / uživatel ho nesmí vidět | `NotFound()` – neprozrazuje existenci |
| přihlášený uživatel bez oprávnění k akci | `Forbid()` |
| návratová URL od uživatele | `LocalRedirect(returnUrl)` (viz `mvc-security.md`) |
| fragment stránky pro AJAX | `PartialView(...)` nebo `ViewComponent(...)` |

- `IActionResult` jako návratový typ akcí MVC; `ActionResult<T>` patří k API controllerům.
- ✗ Akce vracející `Json(...)` jako náhrada API. Pokud stránka potřebuje data asynchronně, malý `[ApiController]` podle `api-design/`, nebo partial view.

## Routing

```csharp
// Program.cs – konvenční routa jako výchozí, atributové routy pro veřejné a české URL
app.MapControllerRoute(
    name: "areas",
    pattern: "{area:exists}/{controller=Home}/{action=Index}/{id?}");
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");
```

- V jednom projektu **jeden styl** jako výchozí: konvenční routy pro interní aplikace, atributové pro veřejné URL (SEO, čeština v URL – viz `seo/`). Míchání jen vědomě.
- Route constrainty (`{id:guid}`, `{id:int}`) – neplatné ID skončí 404 místo výjimky při bindingu.
- URL v kebab-case a bez diakritiky (`/objednavky/nova`), konzistentní s `api-design/`.
- ✗ Ručně skládané URL (`"/Orders/Detail/" + id`). Vždy `Url.Action`, `RedirectToAction`, `asp-action` – přežijí změnu rout.

## Model binding

- Zdroj vstupu explicitně, když není zřejmý: `[FromRoute]`, `[FromQuery]`, `[FromForm]`. Komplexní filtr ze query stringu jako jedna třída (`OrderFilterInput`).
- Vstupní třídy jsou **jen vstup** – žádná logika, žádné navigační vlastnosti, žádné `Id` vlastníka, které má přijít z přihlášeného uživatele.
- Hodnoty z route a query se parsují **invariantní** kulturou, hodnoty z formuláře **aktuální** kulturou požadavku. Desetinná čísla v query stringu proto s tečkou, ve formuláři podle `RequestLocalization` (viz `mvc-forms-validation.md`).

## Filtry

- Průřezové věci (logování, měření, transakce) patří do middleware nebo pipeline handlerů (`cqrs/cqrs-pipeline.md`), ne do MVC filtrů, pokud nepotřebují kontext akce.
- MVC filtr ano: globální antiforgery, autorizace, převod doménové výjimky na `View` s chybou u konkrétní akce.
- Filtry registrovat přes `TypeFilter` / `ServiceFilter` s DI, ne `new` se závislostmi.
- ✗ `OnActionExecuting` v base controlleru jako skrytá logika pro všechny akce. Pokud je nutná, je to filtr se jménem a testem.

## Base controller

- Výchozí stav: **žádný vlastní base controller.** Sdílené pomocníky jako extension metody nebo služby.
- Pokud existuje, obsahuje jen zobrazovací pomocníky (např. `SetFlashMessage`), nikdy závislosti na datech.
