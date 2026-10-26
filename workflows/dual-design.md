# Dva nezávislé návrhy (`/navrh`)

U větší feature nebo architektonické změny vzniknou souběžně dva návrhy od dvou nezávislých instancí agenta `architekt`. Varianta B je výslovně vedena k jinému než nejpřímočařejšímu přístupu. Návrhy o sobě navzájem nevědí.

## Proč

Jeden návrh od AI působí přesvědčivě, i když není nejlepší. Dva nezávislé návrhy odhalí místa, kde existuje skutečná volba, i místa, která oba přehlížejí.

## Postup

1. `/navrh <cesta k zadání>` – vzniknou `.claude/runs/<slug>/navrh-A.md` a `navrh-B.md`.
2. Manažer ukáže srovnání podle matice: konzistence architektury (50 %), výkon (25 %), rychlost vývoje (25 %), migrace a rizika. **Body nepřiděluje a variantu nevybírá.**
3. Variantu vybírá člověk (lidská brána).
4. Zvolené řešení se zapíše do zadání jako aktuální stav. Zamítnuté varianty zůstávají v `.claude/runs/<slug>/`.
5. Pokud jde o architektonické rozhodnutí, zapište ADR do `docs/adr/` projektu podle [templates/adr.template.md](../templates/adr.template.md).
6. Pokračuje se [agentní smyčkou](agentic-dev-loop.md).
