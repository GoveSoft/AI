# Úkol: Export objednávek do CSV

- AC1: `GET /api/orders/export?customerId={id}` vrátí CSV objednávek zákazníka.
- AC2: Export se zaloguje (počet řádků, ID zákazníka).
- AC3: Neexistující zákazník → 404 ProblemDetails.

Ověření: integrační test.
