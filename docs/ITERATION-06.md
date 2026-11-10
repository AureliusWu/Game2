# Game2 · v0.6.0-dev — Witness Performance and Real Screenshot Capture

## Shipped in this iteration
- Low-poly witnesses are now built with separate head and arm pivots: subtle procedural breathing/idle sway and gestures when questioned. Each NPC retains its original outfit, name tag and evidence topics.
- In wide desktop layouts, witness dialogue moves to the right side of the screen so the character stays visible near the aiming reticle. Small windows fall back to centered, scrollable text.
- F12 captures the **actual rendered viewport** as a PNG in the Godot app user-data screenshots folder. The HUD shows the precise resulting absolute path after saving. This is a manual capture at runtime, not a mocked picture nor an automatic screenshot from CI.
- Headless tests check both witness rigs, gesture response, settling to idle, and stable screenshot filename creation; prior investigation, deduction, save and ambient checks stay intact.

## Desktop testing
1. Start game, enter the shop and face the shopkeeper. Check subtle idle motion.
2. Press E to ask questions. On 1100px+ wide screens the panel should sit to the right, leaving the character visible. Watch for brief head and arm gestures.
3. Repeat for station chief at radio room.
4. Press F12 in street or during dialogue. The bottom-left HUD briefly gives the saved full path to a real PNG.
5. Open that file in Windows. Validate exposure, character framing, UI overlap, 720p/1080p/fullscreen and font readability.
6. Finish the existing case and reload save to check continuity.

## Limitations / next art gate
- This is procedural **micro-performance**: no skeletal rig, facial animation, voiced lines, lip sync or motion capture.
- Photo capture requires a running rendered desktop viewport; headless tests cannot validate PNG image content. Screenshots are saved to the local computer, not automatically uploaded to the repository.
- Existing environment and character materials are still prototype quality, not professional PBR. Do not market this as a Steam-ready demo.
- Future art milestone needs source-authored modular building/character assets and human visual QA; build success alone is insufficient.
