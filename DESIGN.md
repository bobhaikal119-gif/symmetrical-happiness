# DEEPWELL — Pixel Interface & Architecture Contract

## Visual identity

A subterranean industrial field terminal, not a generic engine inspector. All raster art is procedural, nearest-filtered, 16×16 pixels with a one-pixel ink outline and distinct shadow/midtone/highlight silhouettes. Avoid shared fallback-square sprites.

## Windows and rhythm

- Crafting and Quartermaster windows use procedural **9-slice StyleBoxTexture** frames with 1–2px ink outlines (`#0E1018`, `#14151F`). No rounded corners or unstyled grey panels.
- Emerald/teal headers (`#2E9E7B`) use **ink** text for accessible contrast and an explicit `[X]` button. Recessed slate interior (`#202936`) uses cream text (`#F4E8CD`). Parchment (`#F4E8CD`) uses ink (`#0E1018`).
- Layout uses an **8px rhythm**, integer font sizes **8 / 16 / 24**, fixed numeric columns and right-aligned counts/prices/CR balances. Rows must not overlap or clip; long text wraps or is deliberately ellipsized with a tooltip.
- Every actionable button, tab, item slot and trade control defines **normal, hover, pressed, focus and disabled** states. Focus must remain visible on keyboard navigation. Interactions emit `SignalBus.ui_button_clicked`.
- Primary and disabled text must meet **4.5:1** against their actual backgrounds. Emerald is an accent/background, not low-contrast body text.
- Empty, locked, unavailable-station, insufficient-credit and rejected-trade states are explicit and useful. No filler marketing, decorative stat cards or silent invalid actions.

## Architecture

- `Main` composes typed services and dependencies. Algorithms, reward budgets, pause reasons, housing scans and power synchronization live in dedicated services, not the composition root.
- `Player` owns movement/physics orchestration only. Appearance, interaction, inventory/station detection and economy use components.
- Pure simulations use RefCounted and exchange value data/local signals; they never depend on scene objects, autoload dispatchers, render layers or scene traversal. Scene adapters live outside `src/simulation/`.
- Placement uses ItemDef metadata; crafting uses RecipeDef station/category metadata; trade uses ShopRegistry quotes/ItemDef values. Item-ID branches are confined to registries/art definitions, never components/UI.
- BlastDoor, CraftingStation and ColonistNpc inherit the typed InteractableEntity contract. No `has_method` guessing for these interactions.
- UI receives snapshots/events through SignalBus and registries/autoloads. It never resolves Player, WorldGrid or world-entity node paths.
- Preserve existing SignalBus signatures; additions are additive. No unfinished stubs or empty implementation bodies.

## Delivery gate

Run engine import, warning-strict compilation, pure room/recipe/trade tests, input/pause regression tests, generated-art uniqueness checks, resource/class audit and a graphical capture. Report concrete PASS/FAIL evidence and remaining limitations rather than claiming untested perfection.
