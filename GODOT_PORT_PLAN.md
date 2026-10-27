# Haunted Escape - Godot 4 Porting Plan

## Why port
The web game proves the design, but a store release with real art, lighting and audio runs better and looks better in a real engine.
**Godot 4** is free (MIT), has small Android builds, a Mobile renderer, and imports glTF directly. **Unity** is also fine if you already know it, but has licensing/runtime terms you must read.
This plan uses Godot; the structure maps to Unity too.

## System map (web game -> Godot)
| Web game | Godot 4 |
|---|---|
| Player walk/turn/run/stamina | `CharacterBody3D` + script (starter included: `player.gd`) |
| Touch stick + look | `InputEventScreenTouch/Drag` (in starter), later `TouchScreenButton` for action buttons |
| House grid maps (3 floors) | Build real rooms in scenes (GridMap or imported modular kit); `NavigationRegion3D` per floor |
| Stairs | Ramps / stair meshes with `NavigationLink3D` between floors |
| Ghost types + AI | `ghost.gd` with `NavigationAgent3D`; later a state machine |
| Camera flash cone | Dot-product + `PhysicsRayQueryParameters3D` (in starter) |
| City, roads, buildings | Modular scenes + `MultiMeshInstance3D` for repeated props; `VisibleOnScreenNotifier3D` / distance culling |
| Traffic + pedestrians | `PathFollow3D` on `Path3D` loops; simple stop logic at traffic lights |
| Traffic lights | Timer node + `Area3D` stop zones |
| Drivable car | `VehicleBody3D` |
| Shops with power-ups | Scene per shop + Control-based shop UI |
| Coins, keys, notes | `Area3D` pickups |
| Day/night, events | `WorldEnvironment` + `DirectionalLight3D` driven by one clock; rain via `GPUParticles3D` |
| Adaptive music | `AudioStreamPlayer` per stem, volumes driven by a tension value |
| Positional ghost voice | `AudioStreamPlayer3D` on each ghost |
| Save / settings / high scores | `GameState` autoload (starter included) |
| Awards, daily, locker | Data resources + UI scenes |
| Recording / share clip | Android screen recording needs a plugin; alternatively use the phone's built-in recorder |

## Milestones (rough, one developer)
1. **M1 (1-2 weeks) Prototype**: starter project, one room, player, one ghost, flash, hide, key, exit. Test on a real phone.
2. **M2 (2-3 weeks) House**: full 3-floor Hartwell House with real assets, stairs, navmesh, all ghost types, wardrobes, diary notes.
3. **M3 (3-4 weeks) City**: roads, buildings kit, traffic/pedestrian loops, lights, zebra crossing, shops, coins, car, zombies/dogs/rogue car.
4. **M4 (2 weeks) Meta**: shops, awards, daily challenge, locker, save, settings, tutorial, accessibility options.
5. **M5 (2 weeks) Audio and polish**: real SFX, music stems, adaptive mixing, particles, post effects.
6. **M6 (2-3 weeks) Release**: performance pass, bug fixing, store assets, privacy policy, closed testing, release.

## Mobile settings (Godot)
- Renderer: **Mobile** (Vulkan). Provide a **Compatibility** build for very old phones.
- Project Settings: 3D scaling 0.75 on Low, MSAA off, shadows only for the main light, shadow distance 40 m.
- Import textures as VRAM compressed (ASTC / ETC2). Use `MultiMesh` for trees, lamps, benches.
- Use occlusion culling / room-and-portals for the house if frame rate drops.
- Cap frame rate at 30/60 with a setting; add an auto-quality step like the web build.

## Android export steps
1. Install Android Studio (SDK + platform tools), JDK 17, and the Godot Android export templates.
2. In Godot: Project > Install Android Build Template. Set package name, version code, icons.
3. Create a **keystore** (keep it safe and backed up; you cannot update the app without it).
4. Export as **AAB** (Play) and APK (testing). Enable arm64-v8a.
5. Upload to Google Play Console > Internal testing first.

## Monetisation plugins (later)
- Ads: AdMob plugin for Godot. Add Google's user-consent flow where required.
- Purchases: Google Play Billing plugin. Keep power-ups that decide survival out of paid items.

## Quality checklist before release
- Test on at least 3 phones (low, mid, high). Watch heat and battery.
- No crash on interruptions (calls, app switching, screen off). Save often.
- Back button, rotation lock, notch/cutout safe areas.
- Subtitles, reduce-scares and left-handed options all work.
- Privacy policy URL, Data Safety form, content rating, store screenshots and trailer.

## Risks
- Art cost and time are the biggest risks. Start with a small first release (one house + city) and add content in updates.
- Untested starter code: expect to fix small errors when you first open it.
