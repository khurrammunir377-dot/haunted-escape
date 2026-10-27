# Haunted Escape - Real Art & Audio Guide

This guide tells you what real assets the game needs, where to look, and how to keep the store listing legal.
I could not download or license-check assets from inside my environment, so everything below must be verified by you.

## 1. Golden rules for licenses
- Prefer **CC0 / public domain** assets. No credit needed, safe for commercial games.
- **CC-BY** is fine, but you must credit the author (put credits in an in-game "Credits" screen and in the store description).
- Avoid **NC (non-commercial)**, **ND**, and anything "editorial only". Avoid AI-generated assets unless you have checked the tool's commercial terms.
- Never use ripped assets from other games, movies, or music tracks.
- Keep a file `LICENSES.csv` with: asset name, author, source URL, license, date downloaded, where used. Re-open each asset's page and re-check the license on the day you download it, because pages change.
- Google Play can remove apps for copyright problems. Keep your proof.

## 2. Where to look (verify each license yourself)
| Need | Sources to check | Usual license (verify!) |
|---|---|---|
| PBR textures (brick, asphalt, wood, plaster) | Poly Haven, ambientCG | CC0 |
| HDRI skies | Poly Haven | CC0 |
| 3D models (props, furniture, vehicles) | Poly Haven, Quaternius, Kenney, Sketchfab (filter by CC0 / CC-BY) | CC0 / CC-BY |
| Characters + animations | Mixamo (free with an Adobe account - read their current terms), Quaternius | Varies |
| Sound effects | Freesound (filter CC0), Sonniss GDC bundles (read terms), Pixabay Sound | Varies |
| Music | Incompetech, OpenGameArt, Pixabay Music, or hire a composer | CC-BY / Pixabay / custom |
| UI icons / fonts | Kenney, Google Fonts (OFL), game-icons.net (CC-BY) | CC0 / OFL / CC-BY |

## 3. What the game needs (priority order)
### Priority 1 - biggest visual jump
1. **Buildings**: 3 modular facade sets (brick, concrete, glass) with PBR maps. 1024-2048 px textures.
2. **Street**: asphalt, sidewalk, curb, crosswalk decals, manhole, puddle normal map.
3. **Vehicles**: 4 cars, 1 bus, 1 truck, 1 police car, 1 scooter. 8-15k triangles each, 1-2 materials.
4. **People**: 6 pedestrians, 1 zombie, rigged and animated (idle, walk, run, attack). 5-8k triangles.
5. **House interior**: 12-20 furniture props (sofa, bed, bookshelf, wardrobe, hospital bed, gurney, IV stand). 1-4k triangles each.
### Priority 2
6. **Ghosts**: 5 designs (ghost, stalker, banshee, brute, blinker) + the Warden boss. Rigged, with emissive eyes.
7. **Dog**: rigged, run + idle.
8. **Trees, street furniture, lamps, signs, shop interiors**.
### Audio list
- Loops (30-90 s, seamless): city night ambience, rain, wind, house room tone, hospital hum.
- One-shots: footsteps (wood, tile, concrete, wet street), doors, creaks, whispers, heartbeat, camera flash, coin, key, shop bell, car horn x3, engine loop, thunder x3, fireworks, banshee scream, boss roar, UI taps.
- Music: calm exploration, tension, chase, boss, menu, ending. Provide stems if possible so the game can mix them (the web build already mixes pad + tension + sub + chase layers).
- Voice (optional): diary page narration, shopkeeper lines.

## 4. Mobile budgets (low-end Android target)
- Whole scene: aim for under 200k visible triangles and under 150 draw calls.
- Textures: 1024 px for most, 2048 px only for hero assets. Use one texture atlas per kit. Compress (ASTC / ETC2 in Godot import settings).
- Characters: 5-8k triangles, 1 material, 30-50 bones max.
- Audio: Ogg Vorbis, 44.1 kHz. Music 96-128 kbps stereo, SFX mono. Total audio under 40 MB.
- App size: Google Play base limit is 200 MB for the AAB; aim for under 150 MB.
- Use LODs and distance culling for the city (the web build already hides far objects).

## 5. Folder layout and naming (use the same in Godot or Unity)
```
assets/
  models/  vehicles/ people/ ghosts/ props/ buildings/ street/
  textures/ <material>_albedo.jpg  _normal.jpg  _rough.jpg
  audio/   sfx/ music/ ambience/ voice/
  ui/      icons/ fonts/
LICENSES.csv
```
Name files lowercase with underscores: `car_sedan_01.glb`, `zombie_walk.glb`, `amb_rain_loop.ogg`.
Export models as **glTF 2.0 (.glb)**; Godot imports it natively.

## 6. Import checklist
- Apply scale (1 unit = 1 metre) and set the origin at the floor centre.
- Check normals, remove hidden faces, merge duplicate materials.
- Bake lighting only if needed; use real-time lights sparingly on mobile.
- Test every sound at low volume on a phone speaker and with earphones.
- Trim silence from audio and loop-test the seams.

## 7. Suggested order
1. Pick the engine (see GODOT_PORT_PLAN.md).
2. Collect Priority 1 assets and fill LICENSES.csv.
3. Swap assets one category at a time and measure frame rate on a low-end phone after each.
4. Add audio, then music stems.
