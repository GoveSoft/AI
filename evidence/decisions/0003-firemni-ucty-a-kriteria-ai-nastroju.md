# 0003: Firemní účty a jednotná kritéria pro AI nástroje

Stav: přijato · Datum: 2026-11-09 · Rozhodl: Milan Chvojka · Nahrazuje: [ADR 0002](0002-soukrome-ucty-za-podminek.md)

## Kontext

[ADR 0002](0002-soukrome-ucty-za-podminek.md) povolilo soukromé účty Claude za přísnějších podmínek. Nezávislý audit toto rozhodnutí zpochybnil. [Spotřebitelské podmínky Anthropicu](https://www.anthropic.com/legal/consumer-terms) v oddílu 11 uvádějí „you will not use our Services for any commercial or business purposes“, takže další podmínky na straně GoveSoft problém neřeší. Firma navíc soukromé účty nespravuje.

GoveSoft nepoužívá jen Claude Code, ale i jiné AI nástroje. Pravidla vázaná na jednoho poskytovatele by ostatní nástroje nepokrývala.

## Zvažované varianty

1. Ponechat soukromé účty za podmínek – bez nákladů, ale v rozporu s podmínkami poskytovatele a bez správy účtů.
2. **Firemní účty a kritéria společná pro všechny nástroje** – pro Claude plán Team, ostatní nástroje po splnění stejných kritérií.
3. Jen API – přesné účtování a obchodní podmínky, ale nepokrývá běžnou práci v aplikaci Claude.

## Rozhodnutí

Varianta 2:

- Pro Claude a Claude Code přecházíme na firemní plán Team.
- Soukromé a spotřebitelské účty se na kódu a datech GoveSoft nepoužívají, u žádného poskytovatele.
- AI nástroj je schválený, až když splní [kritéria v politice](../../governance/ai-policy.md#podmínky-pro-ai-nástroje) a je zapsaný v seznamu schválených nástrojů.
- Lidské brány a pravidla pro data platí pro každý nástroj. Plugin a hooky jsou jejich implementací pro Claude Code.
- Zrušuje se pravidlo „commity bez podpisových řádků AI“ z ADR 0002. Podpisový řádek je dovolený, protože podporuje dohledatelnost. Dokladem postupu zůstává repozitář, ne odkaz na konverzaci.

## Důsledky

- Politika začne platit až po dokončení přechodu na Team a jejím schválení.
- Každý další používaný nástroj se musí posoudit a zapsat, jinak jeho používání politika nedovoluje.
- Riziko R10 v [registru rizik](../../governance/risk-register.md) se mění na používání neschválených nástrojů a účtů.
- Jiné nástroje hooky z pluginu nekontrolují. Omezení popisují [lidské brány](../../governance/human-in-the-loop.md#jiné-ai-nástroje).
