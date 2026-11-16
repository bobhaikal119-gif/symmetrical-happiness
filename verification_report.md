# DEEPWELL — Milestone 4C Delivery Gate

**Result: PASS** — validated on **Godot 4.7.2.stable.official.ed1daf0bf**, Windows, Radeon RX550/550 Series.

## Concise delivery checklist

| Gate | Result | Evidence |
| --- | --- | --- |
| Parser/resources/static typing | **PASS** | [Editor import](<tests/artifacts/4c_import.log>), [warning-strict compile](<tests/artifacts/4c_compile.log>), no observed errors in final runs |
| Pure simulation layer | **PASS** | LiquidGrid and WorldGenerator are RefCounted at canonical simulation paths; no Node/SceneTree/render/autoload dependencies; [audit](<tests/artifacts/4c_static.log>) |
| Composition/player SRP | **PASS** | [Main](<src/main/Main.gd>) **81 lines**, [Player](<src/entities/player/Player.gd>) **87 lines**; Main only calls fixed ticks, Swimming owns all aquatic forces/sampling |
| UI isolation | **PASS** | AimCrosshair/HUD use signals, settings and screen-local input only; no actor/liquid node references |
| Locked SignalBus | **PASS** | Every pre-4C declaration compared to baseline and unchanged; additions only |
| Gear OCP | **PASS** | ItemDef metadata drives passive equipment capabilities. Tests add a new gear ID without modifying Oxygen/Thermal; duplicate copies do not stack |
| Dynamic pixel crosshair | **PASS** | Image→ImageTexture outlined cyan/amber/crimson ticks, spread/recoil, smoothing, reach arc, integer-aligned visual pointer |
| Cursor lifecycle | **PASS** | Real graphical checks: hidden during active focused gameplay; visible for settings/craft/shop/direct pause/focus loss/scene teardown; reset deferred callback fixed |
| Water simulation | **PASS** | Gravity, horizontal spread, connected hydraulic head, sealed edges, fill bounds, volume conservation, terrain/hatch displacement and bounded work |
| Water/lava reaction | **PASS** | Equal1:1 consumption accounted; full cooled unit deposits basalt; tiny contact does not create full block; no untracked liquid loss |
| Aquifers | **PASS** | Same-seed deterministic14 sealed water chambers +3 deep magma pockets; safe dry spawn; no duplicate terrain lava authority |
| Read-only liquid visuals | **PASS** | Culled cyan volumes/depth shading/animated foam; finite capped splashes; zero budget clears them; renderer never mutates solver |
| Diving mechanics | **PASS** | Partial waterline head/torso distinction, full body ratio1, buoyancy/drag/diagonal input/Jump; live physics tests passed |
| Oxygen/thermal | **PASS** | Underwater8/s overrides refill/deep rate; rebreather4/s; wetsuit removes only water chill; lava still heats/damages; suffocation retained |
| Liquid persistence | **PASS** | Exact roundtrip, existing-save replacement on Windows, malformed/wrong-seed/stale-terrain rejection without mutation, explicit requests only |
| Pixel art and contrast | **PASS** | Distinct16×16 outlined diving icons; crosshair/ink contrast cyan **8.86:1**, amber **8.84:1**, crimson **5.05:1**; warning ink/cream **15.62:1** |
| Existing4A/4B systems | **PASS** | Settings/input/reset, room/crafting/placement, trade/reentrancy suites retained and passed |
| Hygiene | **PASS** | Audit of **87 project files /64 global classes**: no duplicate class_name, missing literal resource path, autoload shadow or unfinished stubs |

## Implementation

- [LiquidGrid](<src/simulation/LiquidGrid.gd>): sparse deterministic cellular state with liquid types none/water/lava and0..1 fill. Sealed boundaries; conservative gravity/local equalization and bounded connected saturated-path hydraulic pressure.
- [WorldGenerator](<src/simulation/WorldGenerator.gd>): pure replacement for the former scene generator; existing strata/ores/caves/starter seam retained, deterministic aquifers/magma added.
- [LiquidRenderer](<src/presentation/LiquidRenderer.gd>): unshaded translucent cyan/foam/depth visuals read from the grid; camera/radius culling and finite decorative pixel splash particles.
- [SwimmingComponent](<src/components/SwimmingComponent.gd>): exact head-point waterline sampling and head-to-feet body-overlap integration; buoyancy, drag, directional propulsion and splash transitions.
- [EquipmentComponent](<src/components/EquipmentComponent.gd>): passive carried capabilities from ItemDef slot/multiplier metadata. [Oxygen](<src/components/OxygenComponent.gd>) and [Thermal](<src/components/ThermalComponent.gd>) consume capability snapshots rather than gear IDs.
- [AimCrosshair](<src/ui/AimCrosshair.gd>): signal-pure precision pointer with actual mining spread/recoil telemetry. Auxiliary world reticle keeps only its16×16 grid outline to avoid duplicate cross marks.
- [SaveManager](<src/autoload/SaveManager.gd>): explicit autoload liquid checkpoint service, safe non-object binary snapshots and SHA256 terrain identity. Profile-tab controls use signals, not world references.
- [LiquidRuntimeCoordinator](<src/services/LiquidRuntimeCoordinator.gd>): typed closed-hatch barriers supplied to pure solver; conservative displaced reserve handles water in newly blocked cells.

## Executed evidence

- [Conservation, pressure, reaction, snapshots, generation and icon tests](<tests/milestone4c_liquids.gd>) — [PASS log](<tests/artifacts/4c_liquids.log>).
- [Diving, metadata gear, recoil, save safety and fixed-tick tests](<tests/milestone4c_diving.gd>) — [PASS log](<tests/artifacts/4c_diving.log>).
- [Live swim physics and pause tests](<tests/milestone4c_livephysics.gd>) — [PASS log](<tests/artifacts/4c_livephysics.log>).
- [Real BlastDoor flow/barrier tests](<tests/milestone4c_hatch.gd>) — [PASS log](<tests/artifacts/4c_hatch.log>).
- [Graphical cursor/state/smoothing/splash/HUD tests](<tests/milestone4c_visual.gd>) — [PASS log](<tests/artifacts/4c_visual.log>).
- [Architecture/path/art/contrast audit](<tests/audit_milestone4c.py>) — [PASS log](<tests/artifacts/4c_static.log>).
- Retained4A [settings](<tests/artifacts/4c_settings_regression.log>), [input](<tests/artifacts/4c_input_regression.log>) and [reset](<tests/artifacts/4c_reset.log>) — PASS.
- Retained4B [pure/art/theme](<tests/artifacts/4c_building_pure.log>), [building/housing/crafting](<tests/artifacts/4c_building_regression.log>) and [trade](<tests/artifacts/4c_trade_regression.log>) — PASS.
- Normal Vulkan Forward+180-frame launch completed without observed errors; graphical checks also ran under OpenGL Compatibility.

Tests exposed and corrected two integration defects before delivery: adjacent-column pressure did not communicate through a roofed U-conduit, and deferred crosshair activity callbacks could query a detached viewport during Reset Session. Both now have passing regressions.

## Screenshots and review

- [Cyan precision crosshair](<tests/artifacts/4c_crosshair_cyan.png>) · [Amber lock/spread](<tests/artifacts/4c_crosshair_amber.png>) · [Crimson out-of-reach](<tests/artifacts/4c_crosshair_crimson.png>)
- [Water/foam and diving alert](<tests/artifacts/4c_water_diving.png>)
- [Rebreather/wetsuit telemetry](<tests/artifacts/4c_diving_gear.png>) · [150% HUD](<tests/artifacts/4c_hud_scale_150.png>)
- [16×16 diving icon sheet](<tests/artifacts/4c_gear_icons.png>)
- [Milestone4B baseline](<milestone4c-baseline.zip>) · [review diff](<tests/artifacts/milestone4c_review.diff>)

## Deliberate scope boundaries

1. Liquid checkpoint is **not a full world/player save**. It restores fluid state only for the same world seed and exact foreground/background terrain. Mining/building/basalt changes invalidate old snapshots; rejected loads do not change current fluids. No stale snapshot auto-load occurs.
2. Rebreather and wetsuit are **passive while carried**. Duplicate copies do not stack, and removing the last copy restores default capabilities. Catalog now has24 recipes.
3. Reaction consumes equal water/lava amounts; basalt requires one cumulative cooled lava unit at an empty lava cell. Displaced liquids remain accountable in reserve until local capacity returns.
4. Hydraulic propagation is intentionally bounded:2048 active cells/step,128 cells/pressure search,8192 pressure nodes/step. These are performance safeguards, not a claim of a physically exact fluid solver.
5. Crosshair recoil is driven by the current player mining tool; the game has no separate player firing action. Existing turret behavior remains separate.
6. No claim is made about long-duration balance/performance beyond these executed automated and graphical checks.
