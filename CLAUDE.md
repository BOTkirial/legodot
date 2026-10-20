# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

A Godot 4.4 (Forward Plus, Jolt Physics) 3D project simulating LEGO Technic pieces — bricks, insertable axles/klips, gears, and a motorized engine — with mouse-driven drag & snap assembly. GDScript only, no external build system, no test runner or CI.

## Running the project

There is no CLI build/test/lint pipeline. Development happens through the Godot editor:

- Godot 4 binary is at `/home/cedric.marinot@elosi.lan/Bureau/Godot.x86_64` (see `.vscode/settings.json`).
- Run the project: `Godot.x86_64 --path /home/cedric.marinot@elosi.lan/projets/legodot`
- Main scene is `lego/lego_main.tscn` (set via `run/main_scene` in `project.godot`).
- To sanity-check GDScript syntax without opening the editor UI: `Godot.x86_64 --headless --check-only --script <file>.gd` (or a full `--headless --quit` run of the project scene) — there is no other lint/test mechanism in this repo.

## Architecture

### Snap-assembly pattern (the core mechanic)

Every placeable object (`Brick`, `Insertable`, `Gear`, `LegoEngine`) extends `LegoPiece` (`lego/_commons/lego_piece.gd`), which defines the shared drag/snap contract:

- **`findSnapTransform() -> Transform3D`**: probes whichever surface children the piece happens to have (`stickyFemaleSurface`, `stickyMaleSurface`, `insertableFemaleSurface` — checked via GDScript's duck-typed `"prop" in self`) and returns the transform the piece would snap to, or an empty `Transform3D()` if nothing is in range.
- **`snap(newTransform)`**: applies the transform, marks the matched connectors on both sides unavailable, and reparents the piece onto whatever it just connected to.

Surfaces come in two independent connector systems that pieces mix and match by adding the corresponding child node:

1. **Sticky pins** (stud/anti-stud, for stacking bricks vertically): `StickyMaleSurface`/`StickyFemaleSurface` (`lego/Brick/Sticky*Surface/`) hold grids of `StickyMalePin`/`StickyFemalePin`. Matching surfaces must belong to different piece hierarchies (checked via `Utils.get_ancestors`) and pins within 0.05 units snap; rotation snaps to the nearest multiple of `PI/2`.
2. **Insertable segments** (axle/klip through-holes, for horizontal axle insertion): `InsertableFemaleSurface` (owned by bricks/engine) holds `InsertableFemaleSegment`s; `Insertable` (the axle/klip piece itself, `lego/Insertable/insertable_male.gd`) generates a row of `InsertableMaleSegment`s along its length. Both segment types carry a `type` (`"klip"` or `"axle"`) and only match same-type, in-range, available segments.

Each connector node tracks its own `available: bool` and recolors via `Overlay.setColor` (green = available, red = taken, blue = drag preview) — `Overlay` (`lego/_commons/Materials/Overlay/brick_overlay.gd`) is the shared translucent-material helper used for all placement previews.

### Drag & drop flow

`Draggable` (`lego/Brick/Draggable/draggable.gd`, for bricks/gears/engine) and `DraggableInsertable` (`lego/Insertable/Draggable/draggable.gd`, for axles/klips) are near-identical `Area3D` children that:

1. On mouse-down over the piece (and not over UI — `Utils.is_mouse_over_ui()`), mark all currently-connected pins/segments as `available` again (so the piece can re-snap elsewhere, including back to its own spot) and spawn two clones via `instantiate_clone()`: a visible `clone` that follows the mouse (raycast onto a horizontal plane at pickup height, `Utils.ray_intersect_plane_from_camera`), and a hidden `stickyClone` that snaps to `findSnapTransform()` and turns green/visible when a snap is available.
2. Mouse wheel while dragging: rotates the clone (`PI/16` steps) normally, or moves it vertically when Shift is held.
3. On mouse-up: if a snap was found, calls `brick.snap(stickyClone.global_transform)` on the *original* piece (not the clone), then frees both clones.

Both `Draggable` and `DraggableInsertable` expose a static `anyDragging` flag consumed by `OrbitCamera` (`lego/_commons/Cameras/OrbitCamera/orbit_camera.gd`) to suppress zoom-by-scroll while a piece is being rotated/moved.

### Piece self-configuration (`@tool` scripts)

`Brick`, `Insertable`, `InsertableFemaleSurface`/`Segment`, `StickyMale/FemaleSurface`, `Gear`, `LegoEngine` are all `@tool` scripts with `@export` setters that call an `update()` method to rebuild geometry/child nodes live in the editor when a parameter changes (e.g. changing `Brick.width`/`depth` resizes the mesh, repositions the sticky/insertable surfaces, and regenerates pins). When editing these, preserve the setter → `update()` pattern rather than doing one-off imperative sizing elsewhere.

`instantiate_clone()` is implemented per-class (not on `LegoPiece`) because each piece type wires up its own overlay/material duplication; keep new piece types consistent with the existing ones rather than pulling this into the base class.

### Mechanical simulation (in progress, see README.md)

`MechanicUtils` (`lego/_commons/mechanic_utils.gd`, autoloaded as global) converts between voltage/current/torque/rpm/rad-s for the engine. `LegoEngine.toggleRunning()` computes `speed_rads`/`torque_nm` and pushes them onto whatever `Insertable` axle segment is plugged into its `engineFemaleSegment`, found via `InsertableFemaleSegment.findInsertedMaleSegement()` (nearest unavailable male segment — this is how "what's plugged into me" is discovered, since connections aren't stored as references). `Insertable._process` currently just spins the whole axle at `input_speed_rads` regardless of gears; propagating speed/torque through connected `Gear`s (via `teethCount` ratios and `inertiaMoment`) and tracking which gears/wheels an axle drives is unfinished — see the TODO list in `README.md`.

### Utils autoloads

`Utils` and `MechanicUtils` (`lego/_commons/`) are registered as autoload singletons in `project.godot` and called globally without a node reference (e.g. `Utils.getAllStickyMaleSurfaces()`, `MechanicUtils.rmp_to_rads(...)`). `Utils` also owns the connector group name constants (`GROUP_STICKY_MALE_SURFACE`, etc.) used by every surface's `_ready()` to register itself, and the ancestor/root-reparenting helpers (`get_ancestors`, `get_common_ancestor`, `move_to_root`) used throughout the snap-transform math to avoid a piece snapping to its own descendant/ancestor.

### UI

`lego/UI/brick_configurator.gd` (attached to `BrickConfigurator.tscn`) is a tab switcher (`showMenu`) for an add-piece modal described in `README.md` (type selection, dimensions, color, preview, "add to scene") — currently only the tab-switching skeleton exists, `showMenu` just prints. `CustomButton` (`lego/UI/Components/button.gd`) is a hand-drawn (Polygon2D/Line2D) button control with hover/press states and an `on_click` signal; reuse it instead of Godot's built-in `Button` for consistency with the existing UI.

### Assets

`lego/models/` contains third-party LEGO part meshes (`.stl`/`.glb`, converted via `.gltf`/`.import` sidecars) organized by category (axles, beams, bricks, engines, gears, wheels); these are reference geometry, not something to regenerate. `lego/Gear/Scenes/Gear_9.tscn` … `Gear_38.tscn` are pre-built gear scenes for tooth counts 9–38, loaded dynamically by `Gear._ready()` via `str("res://lego/Gear/Scenes/Gear_", teethCount, ".tscn")`.
