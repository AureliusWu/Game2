# Game2 v0.4.0-dev · Case 01: focused interaction & quiet horror

## Implemented
- Reworked hotspot selection: camera-centered target selection at <=3.3 m with physics raycast occlusion against layer-1 static geometry. Evidence behind walls should no longer be selectable. Target must be visibly near the reticle.
- Street-facing building windows now attach to the *outside* of old shop/broadcast buildings; prior generation accidentally placed details inside the solid blocks. Added weathered sills and facade bands while keeping geometry modular.
- New objective hint on upper-right side, updated as the four mandatory timeline clues are collected. Doesn't reveal the correct deduction.
- Modal windows adapt to viewport dimensions (within the current 16:9 desktop layout).
- Interview topics now offer both "continue questioning" and "finish" buttons, removing unnecessary re-approaches to witness.
- Post-21:47 tape: first time leaving the broadcast room and returning to the street, a one-time narrative anomaly is recorded in the journal. Original, non-verbal audio, no borrowed voices.
- The 2003 public telephone has a pre/post-tape interaction and an additional optional clue. No extra puzzle mechanic.
- CI case test checks gaze, phone gating, town echo, persistence, existing testimony and four mandatory clue deduction.
- All assets in this iteration are procedural; there are still **no final textured character meshes, voice performances or professional PBR scans**.

## Player path
1. Read missing-person poster. Go to shop, inspect ledger, ask Wu Shen about the written name.
2. Visit broadcast office, inspect log and 21:47 tape; interview station chief.
3. Exit into the street and hear the impossible announcement. Return to the public phone for optional extra clue.
4. Consult notebook with J, solve the timeline deduction; there is no battle or chase.

## Known limits
- Continuous first-person movement and interactive geometry still require Windows desktop hands-on QA. Headless tests verify scripts and logical states, not presentation or accessibility.
- First-person 3D, simulated materials, dated signage and static witness placeholders remain WIP. This is **not the Steam demo**.
- “封声” and “听山的” are fictional folklore. Real regional rituals should be researched and cited before claiming historical fidelity.
- Audio is procedural radio/insect/electrical noise and no professionally recorded speech.

## Manual QA checklist
- Inspect clue sightlines from streets and rooms; confirm no through-wall prompts.
- Return to town after tape: scene shows one-time anomaly only, including after saving/reloading.
- Check telephone before/after tape, J notebook, NPC "continue questioning" flow.
- At 720p, 1080p and fullscreen: labels and buttons readable, modal doesn't overflow.
- Confirm the four required clues remain necessary for ending.
- Test escape / mouse control / right of app focus, then review Windows performance.

## Next
After human playtesting, prioritize original period-authentic environment modules, locally grounded visual references, and genuinely authored characters before making more systems.
