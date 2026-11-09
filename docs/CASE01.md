# Game2 / 旧梦乡：广播里的人 — First playable slice

Status: prototype, NOT a Steam-ready build.

## Identity
- Windows-first; 16:9; first-person 3D, semi-realistic art direction.
- Genre: Chinese folk-horror mystery, 2000s millennium nostalgia, dreamcore spatial unease, cosmic unknown.
- Tone: nostalgic and quiet before gradually becoming unsettling.
- No combat, crafting, chase sequences, supernatural player powers, or mandatory jump scares.
- World and folklore are fiction. “封声” and “听山的” are invented for this setting; do not label them as a real local tradition.

## Core case
Present day (2026): the investigator receives a cassette dated 2003-07-17, with a 2003 missing-person announcement and a voice that sounds like the protagonist.
The township appears unchanged from 2003. The player examines:
1. Missing poster — girl Lin Xiaohe reported missing 21:10 on July 17.
2. Shop ledger — Lin Xiaohe purchased soda on July 20 (a contradiction that needs later resolution).
3. Radio log — public missing person announcement at 22:16 on July 17.
4. Tape — Lin Xiaohe's voice recorded at 21:47, BEFORE the public announcement.
5. Ritual document — invented folk prohibition on naming people through broadcast equipment.

Deduction in prototype: the anomalous voice predates the official broadcast, so the broadcast spread the voice but did not originate it. This resolves the *time-order mystery*, not the entire disappearance. The later game must distinguish human deception, misremembered testimony, and the supernatural.

## Prototype loop
- Wander in the street.
- Approach small highlighted investigation markers; press E/F.
- Travel to shop, radio station, and shrine through door markers.
- Read evidence cards. Read notebook with J.
- Once the four mandatory timeline clues are found, start deduction from notebook.
- Correct selection unlocks the eerie closing monologue and persisted completion.
- Escape closes overlays, or toggles the mouse cursor.

## Visual art rules
1. Realistic proportions, recognizably Chinese 2000s public spaces.
2. Warm summer nostalgia, not exclusively filthy/dark imagery.
3. Strange details should be sparse and meaningful (wrong date, repeated audio, impossible memory).
4. 3D blocks/solid colors in this milestone are temporary graybox objects, not final art.
5. Replace primitives with original/licensed PBR assets, decals, signage, night lighting, and room dressing.
6. Never use copyrighted product logos/music in bundled assets without appropriate rights.

## Next milestones
- P1: CI parse + smoke; verify collision, mouse capture, clue pickup, save and deduction in actual desktop play.
- P2: Replace street/rooms with coherent modular architecture, textures, environmental audio, readable Chinese fonts.
- P3: Dialogue NPCs and branching interview contradictions; robust clue-state tests.
- P4: 20–30 minute edited Demo with sound, UX, localization, accessible graphics options.
- P5: quality gates, performance validation, store assets, Steam Direct procedures.

## Acceptance criteria for the current PR
- Godot 4.7.2 imports without parse errors in CI.
- Scene smoke test instantiates player and game root.
- Town, shop, radio station, and shrine have walkable/interactable spaces.
- Five discoverable clues; four required for deduction.
- Wrong answer offers evidence-based feedback, correct answer completes the prototype.
- Progress persists to user://case01-save.json.
- EXE can be exported from main via CI (this still requires actual manual gameplay QA).
