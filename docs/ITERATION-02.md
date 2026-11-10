# Game2 Iteration 02 · The town remembers (v0.2.0-dev)

> This is a visual/audio prototype pass, not a finished photorealistic game or a Steam demo.

## Delivered
- Added original resource-free ambient audio synthesis (no copyrighted music or third-party SFX): dusk insect hum, fridge/fan, radio interference, shrine wind, two radio anomaly cues.
- Added historically inspired *fictional* period props: phone booth, overhead electricity poles, fading shop awning, analog television/CRT equipment, drinks on shelves, paper calendars, shrine talismans, incense and ritual notices.
- Added three optional clues (wall calendar, broadcast suspension notice, nameless ancestral tablet). Required four-clue timeline deduction is unchanged.
- Listening to the early 21:47 tape triggers a subtle shift: mist and daylight change; the broadcast station and street show additional anomalous signs, accompanied by non-verbal static.
- UI dialogue is scrollable for smaller screens / long text.
- Headless tests check all hotspots, audio data, the first anomaly and save/deduction transitions.
- Windows x64 export is available as a PR artifact and main-branch artifact.

## Creative direction
- Preserve the case: Lin Xiaohe missing 2003-07-17 21:10, tape at 21:47, public broadcast at 22:16. The broadcast carried a pre-existing imitation of her voice.
- Nightmare cues are sparse. No jump scares, running monsters, combat, photography magic or mandatory chase.
- Cultural grounding: the 2003-town look draws from everyday public spaces, whereas “封声” and the deity/being “听山的” remain invented folklore; do not misrepresent as documented rites.
- The present prototype uses boxes, cylinders, emissive accents and text. Real PBR materials, architectural meshes, authored motion, licensed Chinese typography, voiced dialogue and professionally mixed sound are still outstanding.
- Do not add real brand logos, radio recordings, or copyrighted popular music.

## Desktop validation checklist
1. Main street loads, WASD and mouse work, walk to 3 entrance triggers.
2. Shop has fan, bottles, calendar clue + original ledger.
3. Radio has CRT and tapes, log, stop-broadcast notice and 21:47 tape.
4. Shrine shows tablets/offerings and two optional lore clues.
5. Pick up tape; verify ambient sound and the surroundings shift subtly.
6. Open notebook J; the required four clues unlock the deduction.
7. Wrong answers retain progress; correct answer triggers the ending and saves it.
8. Save/relaunch and inspect persistence; check the audio is comfortably quiet; test Windows 1080p and 720p.

## Next iteration (PBR / narrative polish)
- Pick one photographically grounded art bible (Wuhan/Hubei-inspired architecture if documented and licensed) instead of mixing unrelated Chinese regions.
- Replace walls/roofs/rooms with authored mesh modules; PBR plaster/tiles/wood/metal, optimized textures and baked lights.
- Add two fully developed NPC interviews so contradictory human accounts matter as much as paranormal clues.
- Complete 20-minute guided playtest; tune pacing before expanding to another case.
