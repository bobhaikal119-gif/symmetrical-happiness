# DEEPWELL — Milestone 4C

Procedural 16×16-pixel survival/mining game for **Godot 4.7.2**. Open [project.godot](<project.godot>) and run. Block textures are bundled pixel-art PNGs; entities, window frames and click audio are generated in code. No external downloads are needed to play.

## Block texture pack

All **17 non-air block types** use dedicated 16×16 RGBA textures, plus an exposed-dirt **grass** visual. Dirt, stone and the grass silhouette are recovered from the supplied reference images, with small clean palettes and nearest-neighbor rendering. Ores share the same stone host and have distinct authored mineral veins; constructed blocks have metal seams, bolts, cable insulation and translucent glass. Air stays transparent.

[BlockTextures](<src/presentation/BlockTextures.gd>) is the shared source for the runtime world atlas, building-item icons and placement ghosts. Simulated magma uses the lava artwork clipped to its actual fill height. Grass is a cosmetic variant of shallow dirt with open sky, not a new simulation ID; mining/placement updates its exposure even across chunk boundaries. The existing snowy surface biome, block health, collisions, drops and world generation are unchanged.

The [natural](<tools/generate_natural_textures.py>), [ore/hazard](<tools/generate_ore_textures.py>) and [construction](<tools/generate_construction_textures.py>) generators reproduce the bundled PNGs using Python/Pillow. The natural generator retains local copies of the supplied references; no network access or user attachment directory is needed after the first copy.

```powershell
Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --quit
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/block_textures.gd
Godot_v4.7.2-stable_win64_console.exe --path . --rendering-method gl_compatibility --script res://tests/block_textures_visual.gd
```

[Texture pack verification](<tests/artifacts/block_textures_verification.md>) records coverage, regression checks and preview evidence. Browser searches for `grass block 2d`, `dirt block 2d` and `stone block 2d` were attempted, but CAPTCHA/unrelated results prevented useful references; the supplied images were the visual source, not downloaded third-party art.

## Precision aim, aquifers and diving

The active-gameplay pointer is a procedural outlined crosshair: **cyan** in reach, **amber** on a real Smart Cursor lock, **crimson** out of reach. Mining expands its ticks with spread/recoil; it settles when released. Aim smoothing follows the existing preference. Craft/shop/settings, direct pause, focus loss and scene exit restore the native pointer.

World generation now creates **14 sealed subterranean aquifers** and **three deep magma pockets**, with deterministic seed-based placement. Mining a chamber shell releases real simulated water. The pure liquid solver uses a fixed **50ms tick**, downward flow, connected pressure equalization, sealed world edges and conservative displacement when terrain or a closed hatch occupies fluid.

- **Swim:** A/D + W/S (or remapped directional actions) propel in any direction; hold **Jump** to stroke upward. Buoyancy and drag are component-owned.
- **Oxygen:** Only the head being below the actual waterline starts underwater drain. Base drain is **8/s**, replacing—not adding to—deep drain and overriding surface/heater refill. Torso/boots immersion alone does not consume underwater air.
- **Cold water:** Adds torso-dependent chill. Lava heats and damages instead; a wetsuit is not lava protection.
- **Diving Rebreather:** craft at a fabricator; **carry to equip**, reducing underwater O2 drain by50%.
- **Thermal Wetsuit:** craft at a fabricator; **carry to equip**, removing added water chill while ambient cold remains. Duplicate gear copies do not stack. The HUD and recipe owned column show equipped capabilities.
- **Water + lava:** consume equal contacting volumes1:1. One cumulative full unit of cooled lava deposits basalt once its lava cell empties; small contacts do not create a full block. Reaction and displaced reserve volume are tracked explicitly.

### Explicit liquid checkpoints

Open **Esc → Profile → Liquid Snapshot** to save/restore water and lava. The default checkpoint is `user://liquids.save`. This is **not a full world/player save**: it restores fluids only for the same seed and exact foreground/background terrain signature. Mining/building/solidification after a checkpoint makes that old checkpoint incompatible; rejected loads leave current liquids unchanged. Snapshots are never automatically applied to a new expedition.

## Build a subterranean outpost

1. Mine the exposed stone/iron/coal/copper/quartz seam just below the landing area. Inventory starts empty; resources are earned, not granted.
2. Open crafting with **C / Tab**. Build an **Ore Smelter** by hand, select its owned output, close the panel and right-click/E to place it. The ghost is emerald when valid and crimson when blocked or beyond reach.
3. Stand within **80px** of a smelter to refine ingots. Craft a **Tech Fabricator** at the smelter for advanced equipment. Categories and station badges explain unavailable recipes; the component rechecks physical station range on every craft.
4. Place **Steel Plate** or **Reinforced Glass** in the foreground and **Hull Wall** behind the room interior. Background plating can be placed behind the player without creating collision.
5. A habitable room needs **12–512 connected interior cells**, a closed solid boundary, Hull Wall coverage on every interior cell, a framed boundary **Blast Door**, a **Camp Heater** and a **Wall Flare** inside. A door remains a housing boundary while open. Open tunnels, hazards, missing plating or fixtures reject housing.
6. The Quartermaster moves into a valid room, patrols its safe floor and cycles nearby doors. Interact with **F**, or right-click the NPC, to trade. Invalidating the room removes its resident; repeated scans do not duplicate residents.

### Crafting and selection

The catalog has **24 recipes** across **Tools / Building / Stations / Survival**, gated by **hand / smelter / fabricator**. Click an owned output slot to select a building item, or use a consumable/upgrade. There is no separate world-object lookup in the UI.

Default quick slots:

| Key | Item |
| --- | --- |
| 1 | Support Beam |
| 2 | Power Cable |
| 3 | Hull Wall |
| 4 | Steel Plate |
| 5 | Reinforced Glass |
| 6 | Blast Door |
| 7 | Ore Smelter |
| 8 | Camp Heater |
| 9 | Wall Flare |

Other placeable items can be selected from their crafting output slots. Foreground/structures cannot overlap actors or existing structures. Background plating may overlap them. Blast Doors open on proximity or interaction and refuse to close through an actor.

## Quartermaster credits

Sell raw minerals/crystals/ingots for their catalog value. Buy Fuel Cells, Nano-Medkits, Drill Overclock Modules, Extended O2 Tanks and Precursor Schematics. Buy prices are twice the item base value; quantities are **1–99**, and permanent upgrades install once.

- **Fuel Cell:** restore 40 battery charge when used.
- **Nano-Medkit:** restore 45 integrity when used.
- **Drill Overclock Module:** install +25% manual mining speed.
- **Extended O2 Tank:** install +50 maximum oxygen.
- **Precursor Schematic:** crafting ingredient for advanced upgrades.

Transactions require an open shop and a nearby housed Quartermaster. Ingredients, item counts and credits commit atomically with reentrant callbacks blocked. UI shows installed upgrades and disables repeat purchases. Credits/upgrades are session state and reset with the expedition; preferences remain persistent.

## Settings and controls retained from 4A

**Esc** closes an active craft/shop modal first, otherwise opens settings. Settings always pause; craft/shop use the Auto-Pause preference. Gameplay input remains blocked in any menu even if simulation continues. Rebinding Escape cancels capture before closing settings.

| Action | Default |
| --- | --- |
| Move | A/D or Left/Right |
| Jump | Space |
| Mine | Left mouse / Q |
| Place/use | Right mouse / E |
| Interact | F, or right-click the interactable |
| Crafting | C / Tab |
| Smart Cursor | Ctrl / HUD badge |
| Flashlight | L |
| Settings | Esc |

All six settings sections persist through ConfigFile to `user://settings.cfg`. Remapping replaces only keyboard events and preserves mouse input. Smart Cursor, smoothing, mouse swap, suit tint, render distance, Full/Fast lighting, FPS cap and performance snapshots remain supported.

## Architecture and visual contract

See [DESIGN.md](<DESIGN.md>), [4B integration contracts](<MILESTONE4B_CONTRACTS.md>) and [4C integration contracts](<MILESTONE4C_CONTRACTS.md>).

- [Main](<src/main/Main.gd>) is an 81-line composition root with bounded fixed-tick stepping; dedicated scene services own pause, presentation budgets, network wiring, housing coordination and telemetry.
- [LiquidGrid](<src/simulation/LiquidGrid.gd>) and [WorldGenerator](<src/simulation/WorldGenerator.gd>) are pure RefCounted value services. [LiquidRenderer](<src/presentation/LiquidRenderer.gd>) reads liquid state; it never advances or modifies the simulation.
- [Swimming](<src/components/SwimmingComponent.gd>) owns submersion/forces. [Equipment](<src/components/EquipmentComponent.gd>) derives passive capabilities from ItemDef metadata; Oxygen/Thermal contain no gear-ID branches.
- [AimCrosshair](<src/ui/AimCrosshair.gd>) and underwater HUD alerts consume signals/settings only, with no actor/liquid node references.
- [Player](<src/entities/player/Player.gd>) is movement/physics orchestration; appearance, typed interactions, inventory/stations and economy are components.
- All classes under [simulation](<src/simulation/WorldGrid.gd>) are RefCounted with no scene/autoload dependencies. Local world events cross a [scene adapter](<src/services/WorldEventBridge.gd>) into unchanged legacy SignalBus contracts.
- ItemDef metadata controls placement/effects/value; RecipeDef controls station/category. UI receives value snapshots/events only.
- Doors, stations and colonists share the abstract [InteractableEntity](<src/entities/structures/InteractableEntity.gd>) contract.
- [AntiSlopTheme](<src/ui/AntiSlopTheme.gd>) supplies procedural nine-slice sharp frames, teal/cream/ink palettes, all five interactive states and click signals. HUD and settings use the same pixel skin.

## Validation

Run editor import first so new global classes are registered, then the tests:

```powershell
Godot_v4.7.2-stable_win64_console.exe --headless --path . --editor --quit
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/compiler_warnings.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/milestone4c_liquids.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/milestone4c_diving.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/milestone4c_livephysics.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/milestone4b_pure.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/milestone4b_integration.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/milestone4b_transactions.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/milestone4a_smoke.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/milestone4a_input.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/milestone4a_reset.gd
Godot_v4.7.2-stable_win64_console.exe --path . --rendering-method gl_compatibility --script res://tests/milestone4c_visual.gd
python tests/audit_milestone4c.py
```

[Delivery gate and evidence](<verification_report.md>). The workspace is not a Git repository, so [baseline snapshot](<milestone4c-baseline.zip>) and [generated source diff](<tests/artifacts/milestone4c_review.diff>) support review. Test-only inventory fixtures are not granted by the game.
