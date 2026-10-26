# Očekávané nálezy

## Povinné (blokující)

1. **SQL injection** – `FromSqlRaw` se zřetězeným `customerId`. Oprava: LINQ nebo `FromSql` s interpolací parametru. (standards/backend/security, sec-injection)
2. **`async void`** – `LogExport`; výjimka shodí proces, nelze čekat. (standards/backend/csharp, async)
3. **AC3 nesplněno** – chybí 404 ProblemDetails pro neexistujícího zákazníka.
4. **Chybí test** k AC – diff neobsahuje integrační test.

## Očekávané (neblokující)

- Interpolace v `LogInformation` místo placeholderů (standards/backend/observability).
- Chybí `AsNoTracking` pro read-only dotaz (standards/backend/database-ef).
- CSV bez escapování a bez hlavičky.

## Nesmí být blokujícím nálezem

- Primární konstruktor místo klasického – stylová preference, kód je správně.
