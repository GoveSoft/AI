# 0001: Agentní vývoj s oddělenými rolemi a lidskými branami

Stav: přijato · Datum: 2026-10 <!-- upřesnit datum původního rozhodnutí -->

## Kontext

Jeden AI asistent, který zároveň píše, kontroluje a hodnotí vlastní kód, má sklon přeceňovat svou práci a tvrdit ověření, které neproběhlo. Zároveň některé kroky (migrace, push) jsou nevratné nebo drahé na opravu.

## Rozhodnutí

- Práci dělí role: manažer (řídí, kód nečte), vývojář (píše, necommituje), reviewer a tester (nezávislá kontrola souběžně), ui-ux, grafik.
- Kontrolní agenti dostávají jen zadání, hlášení a diff – ne historii a odůvodnění vývojáře.
- Nevratná a strategická rozhodnutí patří člověku: plán, výběr návrhu, grafika, migrace, eskalace, push a merge.
- Kde to jde, brány vynucuje hook, ne instrukce.
- Silnější model (Opus) pro návrh a review, rychlejší (Sonnet) pro implementaci a testování.

## Důsledky

- Běh je pomalejší než jeden asistent, ale vady se zachytí před commitem a každý krok je dohledatelný ve stavovém souboru.
- Nutná údržba pluginu a evalů jako produktu (verzování, CHANGELOG).
- Brány zajištěné jen instrukcí jsou slabší – postupně převádět na hooky ([human-in-the-loop.md](../../governance/human-in-the-loop.md)).
